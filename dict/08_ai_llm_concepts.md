# 사전 08. AI/LLM 일반 개념 (General AI/LLM Concepts)

> nanobot 고유 용어가 아닌, 이 저장소를 이해하는 데 필요한 일반 AI/LLM 배경 개념.
> 더 깊은 배경은 [STUDY_NOTES/tech_background/](../STUDY_NOTES/tech_background/01_tool_calling_agents.md)를 보세요.
> 전체 색인은 [README](README.md)를 보세요.

---

### LLM
**한글:** 대규모 언어 모델 · **분류:** 기초

방대한 텍스트로 학습되어 다음 [Token](#token)을 예측하는 신경망(Transformer 기반).
[Prompt](#prompt)를 주면 이어질 텍스트를 생성하며, 이 단순한 능력 위에
[Tool Calling](#tool-calling) 등 에이전트 기능이 쌓입니다.

- **하위 개념:** [Token](#token), [Context Window](#context-window), [Hallucination](#hallucination)
- **관련 용어:** [Provider](01_core_architecture.md#provider)

### Prompt
**한글:** 프롬프트 · **분류:** 기초

[LLM](#llm)에 주는 입력 텍스트 전체. 역할(system/user/assistant/tool)별 메시지 목록으로 구조화됩니다.

- **하위 개념:** [System Prompt](03_memory_context_session.md#system-prompt)
- **관련 용어:** [Context](03_memory_context_session.md#context)

### Token
**한글:** 토큰 · **분류:** 기초

모델이 텍스트를 처리하는 최소 단위(대략 영어 4글자 ≈ 1토큰, 한글은 더 비쌈).
비용·[Context Window](#context-window)·[Input Budget](03_memory_context_session.md#input-budget)이
모두 토큰 단위로 계산됩니다.

- **상위 개념:** [LLM](#llm)
- **하위 개념:** [Tokenizer](#tokenizer)

### Tokenizer
**한글:** 토크나이저 · **분류:** 기초

텍스트 ↔ [Token](#token) 열 변환기. 현대 LLM은 대부분 [BPE](#bpe) 계열을 씁니다.

- **상위 개념:** [Token](#token)
- **하위 개념:** [BPE](#bpe), [tiktoken](#tiktoken)

### BPE
**한글:** 바이트 쌍 부호화 (Byte Pair Encoding) · **분류:** 기초

자주 나오는 바이트 쌍을 반복 병합해 어휘를 만드는 토큰화 알고리즘(Sennrich et al. 2016이 NMT에 도입,
GPT-2가 byte-level로 정착).

- **상위 개념:** [Tokenizer](#tokenizer)

### tiktoken
**분류:** 기초 · 라이브러리

OpenAI의 고속 [BPE](#bpe) 구현(`cl100k_base` 등). API 호출 없이 로컬에서 토큰 수를 정확히 셀 수 있어,
nanobot의 `utils/helpers.py`가 절단/추정에 사용합니다.

- **상위 개념:** [Tokenizer](#tokenizer)
- **관련 용어:** [Input Budget](03_memory_context_session.md#input-budget)

### Context Window
**한글:** 컨텍스트 창 · **분류:** 기초

모델이 한 요청에서 볼 수 있는 총 [Token](#token) 한도(입력+출력). Transformer의
self-attention 계산량이 길이 제곱에 비례하는 것이 유한한 근본 이유입니다.

- **상위 개념:** [LLM](#llm)
- **관련 용어:** [Context Compression](#context-compression), [Lost in the Middle](#lost-in-the-middle)

### Hallucination
**한글:** 환각 · **분류:** 기초

모델이 사실이 아닌 내용을 그럴듯하게 생성하는 현상. nanobot의
[Dream](03_memory_context_session.md#dream)이 "실제 파일 diff로만 상태 전진" 같은
검증 게이트를 두는 이유입니다.

- **상위 개념:** [LLM](#llm)

### In-Context Learning
**한글:** 컨텍스트 내 학습 · **분류:** 기초

가중치 변경 없이 **프롬프트에 넣어준 정보/예시만으로** 모델이 새 지식·방식을 활용하는 능력.
[Memory](03_memory_context_session.md#memory)와 [Skill](01_core_architecture.md#skill) 주입이
효과를 갖는 근거입니다.

- **관련 용어:** [Fine-tuning](#fine-tuning)

### Fine-tuning
**한글:** 파인튜닝 · **분류:** 기초

모델 가중치 자체를 추가 학습으로 바꾸는 것. nanobot의 자기개선은 파인튜닝이 아니라
[In-Context Learning](#in-context-learning)용 텍스트 자산 갱신입니다.

- **관련 용어:** [Reflection](#reflection)

### Agent Loop (concept)
**한글:** 에이전트 루프(개념) · **분류:** 에이전트

"LLM 호출 → 도구 호출 요청? → 실행 → 결과 추가 → 재호출"의 반복 구조.
nanobot에서는 [AgentRunner](01_core_architecture.md#agentrunner)가 구현합니다.

- **하위 개념:** [Tool Calling](#tool-calling), [ReAct](#react)

### Tool Calling
**한글:** 도구 호출 (= function calling) · **분류:** 에이전트

모델에게 도구 목록과 [JSON Schema](#json-schema)를 주면, 모델이 구조화된 호출 요청을 생성하는 기능
(OpenAI 2023.06 정식화). 런타임이 실행하고 결과를 돌려주면 추론이 이어집니다.
모든 tool_call에는 대응하는 tool result가 있어야 합니다
(→ [Orphan Tool Result](03_memory_context_session.md#orphan-tool-result)).

- **상위 개념:** [Agent Loop (concept)](#agent-loop-concept)
- **하위 개념:** [JSON Schema](#json-schema)
- **관련 용어:** [Tool](01_core_architecture.md#tool), [MCP](#mcp)

### JSON Schema
**분류:** 에이전트 · 표준

JSON 데이터의 형태(타입/필수 필드/제약)를 선언하는 표준 명세(json-schema.org).
[Tool Calling](#tool-calling)에서 도구 파라미터의 계약서 역할을 하며,
nanobot의 [Tool Schema](02_tools_and_skills.md#tool-schema)가 이를 생성합니다.

- **상위 개념:** [Tool Calling](#tool-calling)

### ReAct
**분류:** 에이전트 · 논문 (Yao et al. 2022, arXiv:2210.03629)

"생각(Thought) → 행동(Action) → 관찰(Observation)"을 교차시키는 프롬프트 패턴 —
오늘날 [Tool Calling](#tool-calling) API의 원형입니다.

- **상위 개념:** [Agent Loop (concept)](#agent-loop-concept)

### Context Compression
**한글:** 컨텍스트 압축 · **분류:** 컨텍스트 관리

오래되거나 덜 중요한 대화를 요약/삭제해 [Context Window](#context-window) 안에 핵심을 유지하는 기법.
nanobot 구현은 [AutoCompact](03_memory_context_session.md#autocompact)와
[Context Governance](03_memory_context_session.md#context-governance)입니다.

- **하위 개념:** [Summarization](#summarization), [Sliding Window](#sliding-window)
- **관련 용어:** [Lost in the Middle](#lost-in-the-middle)

### Summarization
**한글:** 요약 (기반 압축) · **분류:** 컨텍스트 관리

오래된 구간을 LLM으로 요약해 원문 대신 유지하는 손실 압축.
nanobot의 [Consolidation](03_memory_context_session.md#consolidation)이 이 방식입니다.

- **상위 개념:** [Context Compression](#context-compression)

### Sliding Window
**한글:** 슬라이딩 윈도우 · **분류:** 컨텍스트 관리

최근 N개 메시지는 항상 원문으로 유지하고 그 이전만 압축하는 방식.
[AutoCompact](03_memory_context_session.md#autocompact)의 최근 8개 유지가 이것입니다.

- **상위 개념:** [Context Compression](#context-compression)

### Lost in the Middle
**분류:** 컨텍스트 관리 · 논문 (Liu et al. 2023, arXiv:2307.03172)

관련 정보가 컨텍스트 **중간**에 있을 때 모델 활용도가 떨어지는 현상(U자형 곡선) —
"길게 넣을 수 있어도 다 넣지 말라"는 압축의 품질 근거입니다.

- **관련 용어:** [Context Compression](#context-compression)

### Hierarchical Memory
**한글:** 계층적 메모리 · **분류:** 메모리 · 논문 (MemGPT, arXiv:2310.08560)

컨텍스트 창을 RAM, 외부 저장소를 디스크로 보고 런타임이 페이징하는 관점.
인지과학 대응: 작업 기억(컨텍스트) / 일화 기억(사건 로그) / 의미 기억(정제된 사실).
nanobot: 세션 원문 → 세션 요약 → [Durable Files](03_memory_context_session.md#durable-files).

- **관련 용어:** [Memory](03_memory_context_session.md#memory)

### Reflection
**한글:** 반성 (루프) · **분류:** 자기개선 · 논문 (Reflexion arXiv:2303.11366, Generative Agents arXiv:2304.03442)

에이전트가 경험을 주기적으로 되돌아보고 교훈을 추출해 다음 실행의 입력으로 만드는 과정.
nanobot의 [Dream](03_memory_context_session.md#dream)이 이 계열입니다.

- **관련 용어:** [Skill Library](#skill-library)

### Skill Library
**한글:** 스킬 라이브러리 · **분류:** 자기개선

성공한 절차를 재사용 가능한 단위로 축적하는 것([Voyager](#voyager)가 대표).
nanobot의 [Skill](01_core_architecture.md#skill) + [skill-creator](02_tools_and_skills.md#skill-creator)가
문서 기반 구현입니다.

- **하위 개념:** [Voyager](#voyager), [Agent Skills](#agent-skills)

### Voyager
**분류:** 자기개선 · 논문 (Wang et al. 2023, arXiv:2305.16291)

마인크래프트에서 성공한 행동을 코드 스킬로 저장·조합한 평생 학습 에이전트 —
[Skill Library](#skill-library) 아이디어의 대표 실증.

- **상위 개념:** [Skill Library](#skill-library)

### Agent Skills
**분류:** 자기개선 · 규격 (Anthropic, 2025)

`SKILL.md` + frontmatter로 문서 기반 스킬을 표준화한 규격.
nanobot의 [SKILL.md](02_tools_and_skills.md#skillmd) 형식이 같은 계열입니다.

- **상위 개념:** [Skill Library](#skill-library)

### MCP
**한글:** 모델 컨텍스트 프로토콜 · **분류:** 프로토콜 (Anthropic, 2024.11)

LLM 앱(호스트)과 도구/데이터 제공자(서버) 사이의 표준 프로토콜([JSON-RPC](#json-rpc) 기반).
도구를 한 번 서버로 만들면 여러 호스트가 재사용 — N×M 통합 문제를 N+M으로 줄입니다.
nanobot 구현은 [MCPToolWrapper](02_tools_and_skills.md#mcptoolwrapper)입니다.

- **하위 개념:** [JSON-RPC](#json-rpc), [stdio Transport](#stdio-transport),
  [Streamable HTTP](#streamable-http)
- **관련 용어:** [LSP](#lsp), [Tool Calling](#tool-calling)

### JSON-RPC
**분류:** 프로토콜 · 표준 (2.0, 2010)

JSON으로 원격 함수를 호출하는 경량 규약(`method`/`params`/`id`).
[MCP](#mcp)와 [LSP](#lsp)의 공통 기반입니다.

- **상위 개념:** [MCP](#mcp)

### stdio Transport
**분류:** 프로토콜

호스트가 서버를 자식 프로세스로 띄워 표준입출력으로 [JSON-RPC](#json-rpc)를 주고받는
[MCP](#mcp) 전송 방식. 로컬 도구에 적합(네트워크 노출 없음).

- **상위 개념:** [MCP](#mcp)

### SSE
**한글:** Server-Sent Events · **분류:** 프로토콜

HTTP 연결 하나로 서버→클라이언트 단방향 스트림을 보내는 웹 표준.
LLM [Streaming](04_providers_and_llm.md#streaming) 응답과 초기 [MCP](#mcp) 원격 전송에 쓰였습니다.

- **관련 용어:** [Streamable HTTP](#streamable-http)

### Streamable HTTP
**분류:** 프로토콜

[MCP](#mcp) 2025-03-26 규격의 원격 전송 — 단일 엔드포인트로 [SSE](#sse) 방식을 대체/개선했습니다.

- **상위 개념:** [MCP](#mcp)

### LSP
**한글:** 언어 서버 프로토콜 · **분류:** 프로토콜 (Microsoft, 2016)

에디터(N)×언어(M) 통합 폭발을 [JSON-RPC](#json-rpc) 표준으로 푼 프로토콜 — [MCP](#mcp)의 직접적 영감.

- **관련 용어:** [MCP](#mcp)

### Model Routing
**한글:** 모델 라우팅 · **분류:** 신뢰성/비용

요청 특성이나 설정에 따라 어떤 모델을 쓸지 고르는 것(가용성 폴백, 비용 캐스케이드 등).
nanobot은 [Model Preset](01_core_architecture.md#model-preset)(수동 선택)과
[FallbackProvider](04_providers_and_llm.md#fallbackprovider)(실패 대응)를 씁니다.

- **관련 용어:** [Circuit Breaker](04_providers_and_llm.md#circuit-breaker)
