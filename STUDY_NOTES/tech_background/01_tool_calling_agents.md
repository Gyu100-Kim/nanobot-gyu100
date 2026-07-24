# 배경지식 01. Tool-calling(function-calling) 에이전트

> **이 문서에서 다루는 큰 맥락**
>
> "에이전트"라는 말의 핵심은 LLM이 **텍스트만 뱉는 게 아니라 도구를 호출해 실제 행동**한다는 것입니다.
> 이 문서는 (1) tool-calling의 정의와 등장 배경, (2) 최신 동향, (3) nanobot이 이를 어떻게 구현하는지를
> `nanobot/agent/runner.py`와 `agent/tools/schema.py` 근거로 연결합니다.

## 소목차
1. [정의와 등장 배경](#정의와-등장-배경)
2. [최신 동향](#최신-동향)
3. [nanobot에서의 실제 구현](#nanobot에서의-실제-구현)

---

## 정의와 등장 배경

**Tool calling(=function calling)**: LLM에게 "사용 가능한 함수(도구) 목록과 각 함수의 인자 스키마(JSON Schema)"를
알려주면, 모델이 필요할 때 "이 함수를 이런 인자로 불러 달라"는 **구조화된 호출 요청**을 생성하는 기능입니다.
런타임(에이전트)이 그 함수를 실제로 실행하고 결과를 모델에게 돌려주면, 모델이 이어서 추론을 계속합니다.

**왜 등장했나:** 초기 LLM은 학습 시점 지식에 갇혀 있고(실시간 정보 없음), 계산·파일 접근·외부 API 호출을 못 했습니다.
"모델이 외부 능력을 호출"하게 하면 이 한계를 깨고 실제 작업을 수행할 수 있습니다. 이것이 ReAct(추론+행동) 패턴과
OpenAI/Anthropic의 function-calling API로 표준화되었습니다.

---

## 최신 동향

- **병렬 도구 호출**: 한 턴에 여러 도구를 동시에 요청해 지연을 줄임.
- **표준 스키마**: 대부분의 프로바이더가 JSON Schema로 파라미터를 기술하는 방식으로 수렴.
- **다단계 에이전트 루프**: 도구 결과를 보고 다시 도구를 부르는 반복(iteration)으로 복잡한 작업 수행.
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
- 반복 제한 상수: `_MAX_INJECTIONS_PER_TURN = 3`, `_MAX_INJECTION_CYCLES = 5` 등으로 무한 도구 호출을 방지.
- `_run_core()`가 "프로바이더 호출 → 도구 호출 요청 수신 → `_execute_tools()`로 실행 → 결과를 메시지에 추가 →
  다시 호출"을 `max_iterations`까지 반복합니다.
- 도구 실행은 [05](../05_tools.md)의 `ToolRegistry.execute()`로 위임되며, 오류도 `ToolResult.error`로 모델에게
  피드백해 **스스로 다른 방법을 시도**하게 합니다.

**정리:** nanobot은 tool-calling의 교과서적 구조(스키마 선언 → 모델의 구조화된 호출 → 실행 → 결과 반환 → 반복)를
`schema.py`(선언)와 `runner.py`(루프)로 명확히 구현합니다.
