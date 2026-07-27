# 배경지식 02. 컨텍스트 압축(Context Compression)

> **이 문서에서 다루는 큰 맥락**
>
> LLM의 컨텍스트 창(context window)은 유한합니다(예: 20만 토큰). 대화가 길어지면 반드시 무언가를 줄여야 합니다.
> 이 문서는 (1) 컨텍스트 압축의 정의, (2) 이를 이해하기 위한 하위 개념들(토큰과 토크나이저, 컨텍스트 창,
> lost-in-the-middle, 요약 기반 압축, 슬라이딩 윈도우, 계층적 메모리, 프롬프트 캐시), (3) 개념 간 관계,
> (4) 근간 논문/기술 문서, (5) nanobot의 `agent/autocompact.py`·`context_governance.py`와 `tiktoken` 기반
> 토큰 계산으로의 연결을 다룹니다.

## 비유로 먼저 이해하기 — 책상 크기의 한계와 요약 노트

AI에게는 한 번에 볼 수 있는 **책상 크기의 한계**(컨텍스트 창)가 있습니다. 대화가 길어지면
서류가 책상을 넘치게 되죠. 컨텍스트 압축이란 **"오래된 서류를 요약 노트 한 장으로 바꿔
책상 공간을 확보하는 기술"**입니다.

먼저 알아야 할 사실들:

- **서류의 양은 "토큰"으로 잽니다** — 토큰은 AI가 글을 읽는 최소 조각(대략 단어의
  일부~한 단어)입니다. 책상 크기도, 요금도 토큰 수로 계산됩니다.
- **책상이 크다고 다 좋은 건 아닙니다** — 서류가 아주 많으면 AI는 **중간에 둔 서류를
  잘 놓칩니다**(lost in the middle 현상). 그래서 무작정 다 쌓기보다 요약이 필요합니다.
- **요약에도 대가가 있습니다** — 요약본은 세부 사항을 잃습니다. 또, 서류 배치를 바꾸면
  "지난번과 같은 배치면 싸게 해 주는 할인"(프롬프트 캐시)이 깨져 오히려 비싸질 수 있어
  **언제 요약하느냐**의 균형이 중요합니다.

nanobot의 해법: 평소에는 최근 대화를 그대로 두고, 한도에 가까워지면 오래된 부분을
요약으로 교체(consolidation)하며, 놀고 있는 세션은 한가할 때 미리 요약해 둡니다(AutoCompact).

**꼭 가져가야 할 것 3가지**

1. 토큰 = AI가 읽는 글의 최소 단위이자 비용/한도의 측정 단위.
2. 압축의 기본 전략 = "오래된 대화 → 요약문으로 교체, 최근 대화 → 원본 유지".
3. 요약 시점은 "한도 초과 방지 vs 캐시 할인 유지"의 균형으로 정한다.

---

## 소목차
1. [정의와 핵심 아이디어](#정의와-핵심-아이디어)
2. [하위 개념 상세](#하위-개념-상세)
3. [개념 간 관계](#개념-간-관계)
4. [역사와 근간 논문/기술 문서](#역사와-근간-논문기술-문서)
5. [최신 동향](#최신-동향)
6. [nanobot에서의 실제 구현](#nanobot에서의-실제-구현)

---

## 정의와 핵심 아이디어

**컨텍스트 압축**: 오래되거나 덜 중요한 대화를 **요약/삭제/치환**해 컨텍스트 창 안에 핵심 정보를 유지하는 기법.

**왜 필요한가:**
1. **하드 한도** — 창을 넘기면 요청 자체가 거부됩니다(`context_length_exceeded`).
2. **비용·지연** — 입력 토큰은 그대로 요금이고, 길수록 첫 토큰까지의 지연(TTFT)이 커집니다.
3. **품질** — 잡음이 많으면 모델의 주의가 흐려집니다. 연구로도 확인된 "lost in the middle" 현상(아래 참고)이 있어,
   무작정 길게 넣는 것이 오히려 해로울 수 있습니다.

핵심 아이디어: **"디스크의 원문은 절대 잃지 않되, 모델에게 보내는 사본만 예산에 맞게 줄인다."**
저장(무손실)과 전송(손실 압축)을 분리하면, 나중에 언제든 원문으로 되돌아갈 수 있습니다.

---

## 하위 개념 상세

### (a) 토큰(token)과 토크나이저 — 압축의 측정 단위
**토큰**은 모델이 텍스트를 처리하는 최소 단위입니다(대략 영어 4글자 ≈ 1토큰, 한글은 글자당 1~3토큰으로 더 비쌈).
현대 LLM은 대부분 **BPE[(용어사전)](../../dict/08_ai_llm_concepts.md#bpe)(Byte Pair Encoding)** 계열 토크나이저를 씁니다 — 자주 나오는 바이트 쌍을 반복적으로
병합해 어휘를 만드는 알고리즘(Sennrich et al., 2016이 기계번역에 도입, GPT-2가 byte-level BPE로 정착).
OpenAI의 **tiktoken[(용어사전)](../../dict/08_ai_llm_concepts.md#tiktoken)** 라이브러리는 이 BPE 토크나이저(예: `cl100k_base`)의 고속 구현으로,
"이 텍스트가 몇 토큰인가"를 API 호출 없이 로컬에서 정확히 셀 수 있게 해 줍니다.
**왜 세는 것이 중요한가:** 무엇을 얼마나 자를지는 토큰 수를 알아야 계산할 수 있습니다. 문자 수 근사는
언어/이모지/코드에 따라 크게 어긋납니다.

### (b) 컨텍스트 창(context window)과 입력 예산
컨텍스트 창 = 모델이 한 요청에서 볼 수 있는 총 토큰(입력+출력). 실무에서는 다음과 같이 **입력 예산**을 계산합니다:

```text
input_budget = context_window − max_output_tokens − 안전 버퍼
```

출력 몫과 버퍼를 먼저 빼 두지 않으면, 입력이 창을 꽉 채워 출력이 잘리는 사고가 납니다.

### (c) Lost in the middle — 긴 컨텍스트의 함정
Liu et al.(2023)의 실험: 관련 정보가 컨텍스트 **중간**에 있을 때 모델 성능이 크게 떨어지고,
**시작과 끝**에 있을 때 가장 좋습니다(U자형 곡선). 시사점: (1) 긴 컨텍스트를 살 수 있어도 다 쓰는 게 능사가 아니고,
(2) 중요한 정보(시스템 규칙, 현재 요청)는 앞/뒤에 배치해야 하며, (3) 중간의 오래된 대화가 압축 1순위 후보입니다.

### (d) 요약 기반 압축(summarization)과 통합(consolidation)
오래된 구간을 LLM으로 요약해 원문 대신 요약본을 유지하는 방식. **손실 압축**이므로 두 가지 규율이 필요합니다:
- **경계 규칙**: user 턴 경계, tool_call↔result 짝(→ [01](01_tool_calling_agents.md))을 깨뜨리지 않게 잘라야
  프로바이더가 요청을 거부하지 않습니다.
- **커서(cursor)**: "여기까지는 이미 요약됐다"는 위치 표시를 유지해야 같은 구간을 중복 요약하지 않습니다.

### (e) 슬라이딩 윈도우 + 앵커(anchor)
최근 N개 메시지(윈도우)는 항상 원문으로 유지하고, 그 이전은 요약/삭제하는 방식.
"최근 대화는 지금 맥락에 직결되므로 원문이 필요하고, 오래된 것은 요지만 있으면 된다"는 경험칙에 기반합니다.
시스템 프롬프트나 초기 지시 같은 **앵커**는 윈도우 밖이라도 별도로 보존합니다. StreamingLLM(2023)은 어텐션 수준에서도
초기 토큰(attention sink)을 유지하는 것이 안정성에 중요함을 보였습니다 — 같은 직관의 저수준 버전입니다.

### (f) 계층적 메모리(hierarchical memory) — OS의 가상 메모리 비유
MemGPT(2023)가 정식화한 관점: 컨텍스트 창을 **RAM**, 외부 저장소를 **디스크**로 보고,
에이전트 런타임이 둘 사이에서 정보를 **페이징**(불러오기/내보내기)하는 운영체제 역할을 합니다.
단기(대화 원문) / 중기(세션 요약) / 장기(메모리 파일)로 계층을 나누면, 각 계층에 맞는 압축 정책을 적용할 수 있습니다
(→ [03_self_improving_agents.md](03_self_improving_agents.md)의 장기 메모리와 연결).

### (g) 프롬프트 캐시(prompt caching)와의 긴장 관계
프로바이더들은 "이전 요청과 앞부분(prefix)이 같으면" 그 부분의 계산을 재사용해 비용/지연을 줄입니다
(Anthropic prompt caching, OpenAI cached input 등). 따라서 컨텍스트를 다듬을 때 **앞부분을 자주 바꾸면 캐시가 깨집니다.**
"자주 바뀌는 것(현재 시각 등)은 뒤에, 안정적인 것(시스템 프롬프트)은 앞에"가 실무 규칙입니다.

---

## 개념 간 관계

```text
토큰/토크나이저 (측정)
    │ 셀 수 있어야
    ▼
입력 예산 계산 (context window − 출력 − 버퍼)
    │ 초과분 처리
    ▼
압축 정책 선택
    ├─ 슬라이딩 윈도우 (최근 원문 유지)
    ├─ 요약/통합 (오래된 것 → 요약본, 커서로 추적)
    └─ 계층적 메모리 (요약을 장기 메모리로 승격 → 03 문서)
    │ 제약
    ├─ 경계 규칙 (tool_call 짝, user 턴 시작 → 01 문서)
    ├─ lost-in-the-middle (중간이 압축 1순위)
    └─ 프롬프트 캐시 (앞부분 안정성 유지)
```

압축은 tool-calling(이력 무결성), 장기 메모리(승격 대상), 캐시(배치 순서)와 얽혀 있어 **단독 기능이 아니라
컨텍스트 엔지니어링 전체의 한 축**입니다.

---

## 역사와 근간 논문/기술 문서

| 시기 | 이정표 | 내용 |
| --- | --- | --- |
| 2016 | **BPE 서브워드 분절** (Sennrich et al., arXiv:1508.07909) | 기계번역에 BPE 도입 — 현대 토크나이저의 뿌리. |
| 2017 | **Transformer[(용어사전)](../../dict/08_ai_llm_concepts.md#transformer)** (Vaswani et al., arXiv:1706.03762) | self-attention의 계산량이 시퀀스 길이의 제곱(O(n²)) — 컨텍스트 창이 유한한 근본 이유. |
| 2019 | **GPT-2 byte-level BPE** | 바이트 수준 BPE로 어떤 유니코드 텍스트도 처리 — tiktoken 계열의 직계 조상. |
| 2023.07 | **Lost in the Middle[(용어사전)](../../dict/08_ai_llm_concepts.md#lost-in-the-middle)** (Liu et al., arXiv:2307.03172) | 긴 컨텍스트 중간 정보의 활용 저하를 실증. |
| 2023.09 | **StreamingLLM** (Xiao et al., arXiv:2309.17453) | attention sink — 초기 토큰 유지가 무한 스트리밍의 열쇠. |
| 2023.10 | **MemGPT** (Packer et al., arXiv:2310.08560) | "LLM[(용어사전)](../../dict/08_ai_llm_concepts.md#llm) as OS" — 컨텍스트를 RAM처럼 관리하는 계층적 메모리 정식화. |
| 2023.10 | **LLMLingua** (Jiang et al., arXiv:2310.05736) | 작은 모델로 프롬프트 자체를 압축(토큰 삭제)하는 계열의 대표. |
| 2024 | **프롬프트 캐시 상용화** (Anthropic/OpenAI/DeepSeek) | prefix 재사용으로 비용·지연 절감 — 압축과의 상호작용이 실무 이슈로. |

읽어볼 1차 자료:
- Lost in the Middle: https://arxiv.org/abs/2307.03172
- MemGPT: https://arxiv.org/abs/2310.08560
- StreamingLLM: https://arxiv.org/abs/2309.17453
- tiktoken: https://github.com/openai/tiktoken
- Anthropic prompt caching 문서: https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching

---

## 최신 동향

- **요약 기반 압축**: 오래된 구간을 LLM으로 요약해 원문 대신 요약본을 유지 — 코딩 에이전트들의 "auto-compact"가 대표.
- **슬라이딩 윈도우 + 앵커**: 최근 N개 + 중요한 초기 맥락을 유지.
- **계층적 메모리**: 단기(대화)·장기(메모리 파일) 분리(→ [03_self_improving_agents.md](03_self_improving_agents.md)).
- **토큰 예산 기반 절단**: 남은 예산에 맞춰 tail부터 채우는 방식.
- **컨텍스트 창 확대와의 공존**: 창이 100만 토큰이 되어도 비용·지연·lost-in-the-middle 때문에 압축은 여전히 필요.

---

## nanobot에서의 실제 구현

### 토큰 계산 — `tiktoken`
`nanobot/utils/helpers.py`가 tiktoken을 사용합니다(L16 `import tiktoken`, L25 `tiktoken.get_encoding("cl100k_base")`).
- `truncate_text_to_tokens(text, max_tokens)`(L318-): 텍스트를 토큰 상한으로 절단. tiktoken이 없으면 "~4글자/토큰"
  추정으로 폴백(L323). [07](../07_prompt_and_context.md)의 최근 히스토리 8000토큰 절단이 이 함수입니다.
- `estimate_message_tokens(message)`(L616-): 메시지 하나의 토큰 추정. [06](../06_state_and_persistence.md)의
  `get_history(max_tokens=...)`와 [07](../07_prompt_and_context.md)의 `ContextGovernor.snip_history`가 이를 사용.
- `estimate_prompt_tokens_chain(...)`(L660-): "프로바이더 자체 카운터 → tiktoken 폴백" 순으로 추정(L669 `"tiktoken"`).

### 입력 예산 — `agent/context_governance.py`
위 (b)의 공식 그대로입니다: `input_budget()`(L92-)이 `context_window_tokens − max_output − SNIP_SAFETY_BUFFER`를
계산합니다. `prepare_for_model`(L75-)이 경계 규칙(고아 tool result 제거 `drop_orphan_tool_results` L232,
짝 백필 `backfill_missing_tool_results` L258)을 지키며 오래된 히스토리부터 잘라냅니다(`snip_history` L380)
— 위 (d)의 경계 규칙 구현.

### 유휴 세션 자동 압축 — `agent/autocompact.py`
[07](../07_prompt_and_context.md)에서 상세히 본 `AutoCompact`가 요약 기반 압축의 대표 구현입니다.
- `_RECENT_SUFFIX_MESSAGES = 8`(L18): 최근 8개는 원문 유지 — 위 (e)의 슬라이딩 윈도우 앵커.
- 유휴(idle) 세션의 긴 대화를 배경에서 `consolidator.compact_idle_session(...)`으로 **요약**해 저장.
- 세션의 `last_consolidated` 커서([06](../06_state_and_persistence.md))로 "어디까지 요약했는지" 추적 — 위 (d)의 커서.
- 이후 턴에는 요약본 + 최근 원문만 모델에 보냅니다.

### 프롬프트 캐시 배려 — `agent/context.py`
`build_messages()`는 매 턴 바뀌는 런타임 컨텍스트(현재 시각 등)를 **사용자 콘텐츠 뒤에** 붙여 앞부분(prefix)을
안정시킵니다(주석 L226-229; [07](../07_prompt_and_context.md)) — 위 (g)의 캐시 친화 배치.

**정리:** nanobot은 "tiktoken으로 정확히 세고(측정) → 예산 초과분을 요약/절단(압축) → 경계 규칙과 캐시를
배려(무결성/효율)"하는 구조로, MemGPT식 계층 관리(세션 원문 → 세션 요약 → 장기 메모리)를 파일 기반으로 실용화한
사례입니다. 측정은 `utils/helpers.py`, 압축 정책은 `autocompact.py`/`context_governance.py`에 있습니다.
---

## 차근차근 정리 — 한 장면으로 복습

대화가 300턴쯤 쌓인 세션을 상상해 봅시다.

1. 모델의 컨텍스트 창(책상 크기)은 유한한데 대화(서류)는 계속 쌓입니다. 전부 올려놓으면
   비용이 폭증하고, 한도를 넘으면 요청 자체가 거부됩니다.
2. 그래서 보내기 전에 **토큰 수를 셉니다**(tiktoken) — "이 가방이 지금 몇 kg인가".
3. 한도에 가까우면 **오래된 구간을 요약**으로 바꿉니다(원본은 디스크에 그대로 두고,
   보낼 사본만). nanobot에서는 세션 통합과 `AutoCompact`가 이 일을 합니다.
4. 자르는 위치는 아무 데나가 아닙니다 — 도구 호출/결과 짝이 깨지지 않도록, 대화 턴
   경계에 맞춰 자릅니다(`ContextGovernor`).
5. "중간에 둔 정보는 모델이 잘 놓친다"(lost in the middle)는 연구 결과 때문에,
   중요한 것(시스템 프롬프트·최근 대화)은 앞뒤에 배치합니다.

### 직접 확인해 볼 질문

1. 압축은 왜 "디스크의 원본"이 아니라 "보낼 사본"에만 적용해야 할까?
2. 요약으로 바꾸면 무엇을 얻고 무엇을 잃는가? (비용/속도 vs 세부 정보)
3. 자를 때 도구 호출/결과 짝을 지켜야 하는 이유는?

다음으로: 요약된 기억을 영구 보존하는 방법 → [03_self_improving_agents.md](03_self_improving_agents.md).
