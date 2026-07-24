# 배경지식 02. 컨텍스트 압축(Context Compression)

> **이 문서에서 다루는 큰 맥락**
>
> LLM의 컨텍스트 창(context window)은 유한합니다(예: 20만 토큰). 대화가 길어지면 반드시 무언가를 줄여야 합니다.
> 이 문서는 (1) 컨텍스트 압축의 정의/배경, (2) 동향, (3) nanobot의 `agent/autocompact.py`와 `tiktoken` 기반
> 토큰 계산으로의 연결을 다룹니다.

## 소목차
1. [정의와 등장 배경](#정의와-등장-배경)
2. [최신 동향](#최신-동향)
3. [nanobot에서의 실제 구현](#nanobot에서의-실제-구현)

---

## 정의와 등장 배경

**컨텍스트 압축**: 오래되거나 덜 중요한 대화를 **요약/삭제/치환**해 컨텍스트 창 안에 핵심 정보를 유지하는 기법.
- **왜 필요한가:** (1) 창을 넘기면 요청 자체가 거부되고, (2) 토큰이 많을수록 비용·지연이 커지며, (3) 잡음이 많으면
  모델의 주의가 흐려집니다("lost in the middle"). 따라서 "중요한 것만 압축해 남기는" 것이 품질과 비용 모두에 이롭습니다.

토큰(token)은 모델이 텍스트를 세는 단위(대략 영어 4글자 ≈ 1토큰). 토큰 수를 정확히 알아야 무엇을 얼마나 자를지 계산할 수 있습니다.

---

## 최신 동향

- **요약 기반 압축**: 오래된 구간을 LLM으로 요약해 원문 대신 요약본을 유지.
- **슬라이딩 윈도우 + 앵커**: 최근 N개 + 중요한 초기 맥락을 유지.
- **계층적 메모리**: 단기(대화)·장기(메모리 파일) 분리(→ [03_self_improving_agents.md](03_self_improving_agents.md)).
- **토큰 예산 기반 절단**: 남은 예산에 맞춰 tail부터 채우는 방식.

---

## nanobot에서의 실제 구현

### 토큰 계산 — `tiktoken`
`nanobot/utils/helpers.py`가 tiktoken을 사용합니다(L16 `import tiktoken`, L25 `tiktoken.get_encoding("cl100k_base")`).
- `truncate_text_to_tokens(text, max_tokens)`(L318-): 텍스트를 토큰 상한으로 절단. tiktoken이 없으면 "~4글자/토큰"
  추정으로 폴백(L323). [07](../07_prompt_and_context.md)의 최근 히스토리 8000토큰 절단이 이 함수입니다.
- `estimate_message_tokens(message)`(L616-): 메시지 하나의 토큰 추정. [06](../06_state_and_persistence.md)의
  `get_history(max_tokens=...)`와 [07](../07_prompt_and_context.md)의 `ContextGovernor.snip_history`가 이를 사용.
- `estimate_prompt_tokens_chain(...)`(L660-): "프로바이더 자체 카운터 → tiktoken 폴백" 순으로 추정(L669 `"tiktoken"`).

### 유휴 세션 자동 압축 — `agent/autocompact.py`
[07](../07_prompt_and_context.md)에서 상세히 본 `AutoCompact`가 대표 구현입니다.
- `_RECENT_SUFFIX_MESSAGES = 8`(L18): 최근 8개는 원문 유지(슬라이딩 윈도우 앵커).
- 유휴(idle) 세션의 긴 대화를 배경에서 `consolidator.compact_idle_session(...)`으로 **요약**해 저장.
- 세션의 `last_consolidated` 커서([06](../06_state_and_persistence.md))로 "어디까지 요약했는지" 추적하고,
  이후 턴에는 요약본 + 최근 원문만 모델에 보냅니다.

**정리:** nanobot은 "tiktoken으로 정확히 세고(측정) → 예산 초과분을 요약/절단(압축)"하는 두 축으로 컨텍스트를
관리합니다. 측정은 `utils/helpers.py`, 압축 정책은 `autocompact.py`/`context_governance.py`에 있습니다.
