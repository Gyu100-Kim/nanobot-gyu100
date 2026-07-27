# 배경지식 01. Tool-calling(function-calling) 에이전트

> **이 문서에서 다루는 큰 맥락**
>
> "에이전트"라는 말의 핵심은 LLM이 **텍스트만 뱉는 게 아니라 도구를 호출해 실제 행동**한다는 것입니다.
> 이 문서는 (1) tool-calling의 정의와 핵심 아이디어, (2) 이를 이해하기 위한 하위 개념들
> (JSON Schema[(용어사전)](../../dict/08_ai_llm_concepts.md#json-schema), 에이전트 루프, ReAct[(용어사전)](../../dict/08_ai_llm_concepts.md#react), 병렬 호출, 도구 결과 피드백 등), (3) 개념들 사이의 관계,
> (4) 근간이 되는 논문/기술 문서와 역사, (5) nanobot이 이를 어떻게 구현하는지를
> `nanobot/agent/runner.py`와 `agent/tools/schema.py` 근거로 연결합니다.

## 비유로 먼저 이해하기 — 전화 상담원에게 손발 빌려주기

AI(LLM)는 전화 상담원과 같습니다. **말은 잘하지만 직접 움직일 수는 없습니다.**
"tool calling"은 상담원이 "3번 창구에서 서류 좀 떼어 주세요"라고 **정확한 서식으로 요청**하면,
직원(프로그램)이 대신 처리하고 결과를 읽어 주는 방식입니다.

핵심 아이디어 세 가지:

1. **서식의 표준화(JSON Schema)** — 어떤 도구가 있고 무엇을 적어 내야 하는지를
   기계가 읽을 수 있는 서식으로 정의합니다. 상담원(AI)은 이 서식을 보고 빈칸을 채웁니다.
2. **반복 루프(agent loop)** — 한 번의 요청으로 끝나지 않습니다. "서류 떼기 → 결과 보고 →
   다음 판단 → 또 요청"을 목표가 끝날 때까지 반복합니다.
3. **결과 짝 맞추기** — 요청서마다 번호(ID)가 있어서, 어떤 결과가 어떤 요청에 대한
   답인지 반드시 짝을 맞춰 돌려줘야 합니다. 짝이 안 맞으면 API가 거부합니다.

이 문서의 뒷부분은 이 아이디어의 역사(2022년 ReAct 논문 → 2023년 OpenAI function calling
공식화 → 오늘날의 표준)와, nanobot 코드에서 이것이 어디에 구현되어 있는지를 연결합니다.

**꼭 가져가야 할 것 3가지**

1. AI는 도구를 "직접 실행"하지 않는다 — 서식(JSON)에 맞는 요청서만 쓴다.
2. 에이전트다움의 본질은 "호출 ↔ 결과 확인"의 반복 루프다.
3. 도구 요청과 결과는 ID로 1:1 짝을 맞춰야 한다.

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

**Tool[(용어사전)](../../dict/01_core_architecture.md#tool) calling(=function calling)**: LLM에게 "사용 가능한 함수(도구) 목록과 각 함수의 인자 스키마(JSON Schema)"를
알려주면, 모델이 필요할 때 "이 함수를 이런 인자로 불러 달라"는 **구조화된 호출 요청**을 생성하는 기능입니다.
런타임(에이전트)이 그 함수를 실제로 실행하고 결과를 모델에게 돌려주면, 모델이 이어서 추론을 계속합니다.

**왜 등장했나:** 초기 LLM은 세 가지 근본 한계가 있었습니다.
1. **지식 단절(knowledge cutoff)** — 학습 시점 이후의 정보를 모릅니다.
2. **행동 불능** — 계산·파일 접근·외부 API 호출을 할 수 없어 "말만" 합니다.
3. **환각(hallucination)** — 모르는 것을 아는 것처럼 지어냅니다.

"모델이 외부 능력을 호출"하게 하면 이 세 한계를 동시에 완화합니다: 검색으로 최신 정보를 얻고,
셸/파일 도구로 실제 작업을 수행하고, 계산기·DB 조회처럼 **검증 가능한 근거**를 바탕으로 답하게 됩니다.

핵심 통찰은 단순합니다: **"모델은 텍스트 생성기일 뿐이므로, '행동'도 텍스트(구조화된 호출 요청)로 표현하게 하고,
그 텍스트를 해석·실행하는 것은 런타임이 맡는다."** 모델과 실행기의 이 역할 분리가 tool-calling 설계의 전부입니다.

---

## 하위 개념 상세

### (a) JSON Schema — 도구 인터페이스의 공용어
**JSON Schema**는 JSON 데이터의 형태(타입/필수 필드/제약)를 선언하는 표준 명세입니다(json-schema.org, IETF 드래프트).
tool-calling에서는 각 도구의 **파라미터 계약서** 역할을 합니다. 예:

```json
{
  "type": "object",
  "properties": {
    "path": {"type": "string", "description": "읽을 파일 경로"},
    "limit": {"type": "integer", "minimum": 1}
  },
  "required": ["path"]
}
```

모델은 이 스키마를 보고 "path는 문자열로, limit은 정수로" 채워야 함을 이해합니다.
**왜 JSON Schema인가:** (1) 언어 중립적이고, (2) 검증기가 이미 풍부하며, (3) OpenAI가 2023년 function calling API에서
채택하면서 사실상 업계 표준이 되었습니다. 이후 Anthropic(tool use), Google(Gemini function calling) 모두 같은 방식으로 수렴했습니다.

### (b) 에이전트 루프(agent loop) — 관찰→판단→행동의 반복
한 번의 도구 호출로 끝나는 작업은 드뭅니다. 에이전트 루프는:

```text
사용자 메시지
  → LLM 호출 (도구 목록 포함)
  → 모델이 tool_call 반환?
      예: 도구 실행 → 결과를 대화에 추가 → 다시 LLM 호출 (반복)
      아니오: 최종 답변 반환
```

이 반복 구조 덕분에 모델이 "파일을 읽고 → 내용을 보고 → 수정하고 → 테스트를 돌리는" 다단계 작업을 할 수 있습니다.
**반복 상한(max iterations)** 은 필수 안전장치입니다 — 모델이 무한히 도구를 부르는 폭주를 막습니다.

### (c) ReAct — 추론(Reasoning)과 행동(Acting)의 교차
ReAct(Yao et al., 2022)는 "생각(Thought) → 행동(Action) → 관찰(Observation)"을 명시적으로 교차시키는 프롬프트 패턴입니다.
네이티브 function calling API가 없던 시절, 모델이 텍스트로 `Action: search[...]` 같은 형식을 출력하면
런타임이 정규식으로 파싱해 실행했습니다. 오늘날의 tool-calling API는 ReAct의 "행동을 텍스트로 표현"이라는
아이디어를 **구조화된 프로토콜(JSON)** 로 정식화한 것이라 볼 수 있습니다.

### (d) 도구 결과 피드백(tool result) — 짝 맞추기 규칙
모델이 `tool_call`(고유 id 포함)을 내면, 런타임은 실행 결과를 **그 id를 참조하는 `tool` role 메시지**로 되돌려야 합니다.
대부분의 프로바이더는 "모든 tool_call에는 대응하는 tool result가 있어야 한다"는 규칙을 강제하며,
짝이 안 맞으면(고아 tool result, 결과 없는 tool_call) 요청을 거부합니다. 이것이 대화 이력을 자를 때
"합법적 경계"를 지켜야 하는 이유입니다(→ [02_context_compression.md](02_context_compression.md)).

또 하나 중요한 관행: **도구 실행이 실패해도 예외를 삼키지 말고 오류 텍스트를 결과로 모델에게 돌려줍니다.**
모델은 오류를 읽고 스스로 다른 방법을 시도할 수 있습니다("self-correction").

### (e) 병렬 도구 호출(parallel tool calls)
모델이 한 응답에서 **여러 tool_call을 동시에** 요청하는 기능(OpenAI 2023년 11월 DevDay에서 도입).
서로 독립적인 작업(파일 3개 읽기 등)을 한 왕복으로 처리해 지연을 줄입니다. 런타임은 결과들을 각 id에 맞춰 돌려줍니다.

### (f) 구조화된 출력(structured output)과의 관계
tool-calling은 "모델이 스키마를 따르는 JSON을 생성"하는 능력에 기반하므로,
JSON mode / constrained decoding(문법 제약 디코딩) 같은 **구조화된 출력** 기술과 뿌리가 같습니다.
프로바이더들은 학습(함수 호출 데이터로 파인튜닝)과 디코딩 제약을 병행해 스키마 위반을 줄입니다.

---

## 개념 간 관계

```text
JSON Schema (도구의 계약서)
    │ 선언
    ▼
Tool calling API (모델이 구조화된 호출 생성)
    │ 반복
    ▼
Agent loop (호출 → 실행 → 결과 피드백 → 재호출)   ←— ReAct의 정식화
    │ 확장
    ├─ 병렬 호출 (지연 감소)
    ├─ 도구 결과 짝 맞추기 (이력 무결성 → 컨텍스트 압축과 충돌 지점)
    └─ MCP (도구를 프로세스 밖 표준 프로토콜로: → 04_mcp.md)
```

- tool-calling은 **에이전트의 손발**, 컨텍스트 관리(→ [02](02_context_compression.md))는 **기억력**,
  모델 라우팅(→ [05](05_model_routing_fallback.md))은 **두뇌 선택**, 격리(→ [06](06_execution_isolation.md))는 **안전벨트**입니다.
- 도구가 많아질수록 스키마가 컨텍스트를 차지하므로, 도구 설계와 컨텍스트 압축은 서로 트레이드오프 관계입니다.

---

## 역사와 근간 논문/기술 문서

| 시기 | 이정표 | 내용 |
| --- | --- | --- |
| 2021 | **WebGPT** (OpenAI, arXiv:2112.09332) | 브라우저 명령을 텍스트로 출력하게 학습 — "행동을 텍스트로"의 초기 실증. |
| 2022.05 | **MRKL Systems** (AI21, arXiv:2205.00445) | LLM을 라우터로, 전문 모듈(계산기·DB)을 실행기로 두는 신경-기호 아키텍처 제안. |
| 2022.10 | **ReAct** (Yao et al., arXiv:2210.03629) | Thought/Action/Observation 교차 프롬프팅 — 에이전트 루프의 원형. |
| 2023.02 | **Toolformer** (Schick et al., Meta, arXiv:2302.04761) | 모델이 스스로 "어디서 어떤 API를 부를지"를 학습 — 도구 사용을 학습 목표로 정식화. |
| 2023.05 | **Gorilla** (Patil et al., arXiv:2305.15334) | 대규모 API 호출 정확도를 위한 파인튜닝, 이후 **Berkeley Function Calling Leaderboard(BFCL)** 벤치마크로 발전. |
| 2023.06 | **OpenAI Function Calling API** | gpt-4-0613/gpt-3.5-turbo-0613에서 JSON Schema 기반 함수 호출 정식 출시 — 업계 표준의 기점. |
| 2023.11 | OpenAI **parallel tool calls** / Assistants API | 병렬 호출, 도구 상태 관리의 플랫폼화. |
| 2024 | Anthropic **tool use** GA, **MCP[(용어사전)](../../dict/08_ai_llm_concepts.md#mcp)** 공개 | 프로바이더 간 수렴 + 도구의 프로토콜 표준화(→ [04_mcp.md](04_mcp.md)). |

읽어볼 1차 자료:
- ReAct: *ReAct: Synergizing Reasoning and Acting in Language Models* — https://arxiv.org/abs/2210.03629
- Toolformer: *Toolformer: Language Models Can Teach Themselves to Use Tools* — https://arxiv.org/abs/2302.04761
- Gorilla/BFCL: https://arxiv.org/abs/2305.15334 , https://gorilla.cs.berkeley.edu/leaderboard.html
- OpenAI function calling 가이드: https://platform.openai.com/docs/guides/function-calling
- Anthropic tool use 가이드: https://docs.anthropic.com/en/docs/build-with-claude/tool-use
- JSON Schema 명세: https://json-schema.org/

---

## 최신 동향

- **병렬 도구 호출**: 한 턴에 여러 도구를 동시에 요청해 지연을 줄임.
- **표준 스키마 수렴**: 대부분의 프로바이더가 JSON Schema로 파라미터를 기술.
- **다단계 에이전트 루프**: 도구 결과를 보고 다시 도구를 부르는 반복으로 복잡한 작업 수행. 코딩 에이전트가 대표 사례.
- **함수 호출 전용 벤치마크**: BFCL, τ-bench 등 — 호출 정확도(AST 일치), 다중 턴 도구 사용을 정량 평가.
- **MCP**(→ [04_mcp.md](04_mcp.md))로 도구를 프로세스 외부에서 표준 프로토콜로 연결하는 흐름.

---

## nanobot에서의 실제 구현

### 도구 스키마 — `agent/tools/schema.py`
도구 파라미터는 JSON Schema로 표현됩니다. `schema.py`(L1 docstring)는 `StringSchema`(L20), `IntegerSchema`(L54),
`NumberSchema`(L90), `BooleanSchema`(L126), `ArraySchema`(L152), `ObjectSchema`(L187) 등을 제공하고, 각기
`to_json_schema()`(L38, L74, …)로 표준 JSON Schema dict를 만듭니다. 이것이 [05](../05_tools.md)의 `Tool.to_schema()`가
프로바이더에 넘기는 `function.parameters`가 됩니다.
- 흥미로운 세부: "Python은 `bool` 상속이 안 되므로 불리언은 `BooleanSchema`로 처리"(docstring L9) — 실제 코드
  제약까지 반영한 설계.

### 도구 실행 루프 — `agent/runner.py`
[04](../04_agent_loop.md)에서 본 `AgentRunner`가 tool-calling 루프의 본체입니다.
- 반복 제한 상수: `_MAX_INJECTIONS_PER_TURN = 3`, `_MAX_INJECTION_CYCLES = 5` 등으로 무한 도구 호출을 방지
  — 위 (b)의 "반복 상한" 안전장치.
- `_run_core()`가 "프로바이더 호출 → 도구 호출 요청 수신 → `_execute_tools()`로 실행 → 결과를 메시지에 추가 →
  다시 호출"을 `max_iterations`까지 반복합니다 — 위 (b)의 에이전트 루프 그대로.
- 도구 실행은 [05](../05_tools.md)의 `ToolRegistry.execute()`로 위임되며, 오류도 `ToolResult.error`로 모델에게
  피드백해 **스스로 다른 방법을 시도**하게 합니다 — 위 (d)의 self-correction 관행.
- 도구 호출↔결과 짝 맞추기는 `context_governance.py`의 `drop_orphan_tool_results`/`backfill_missing_tool_results`가
  방어합니다([07](../07_prompt_and_context.md)) — 위 (d)의 짝 규칙을 이력 절단 이후에도 보장.

**정리:** nanobot은 tool-calling의 교과서적 구조(스키마 선언 → 모델의 구조화된 호출 → 실행 → 결과 반환 → 반복)를
`schema.py`(선언)와 `runner.py`(루프)로 명확히 구현합니다. 그 뿌리는 ReAct의 "행동을 텍스트로" 아이디어와
OpenAI function calling API의 JSON Schema 표준화에 있습니다.
