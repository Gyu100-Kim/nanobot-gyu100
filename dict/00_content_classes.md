# 사전 00. 노드 클래스 정의 (Content Classes)

이 사전의 지식 그래프는 두 종류의 노드로 구성됩니다.

| 노드 명(label) | 의미 |
|---|---|
| **Content** | 용어 개념 사전을 구성하는 용어 혹은 개념 노드 — `01_*.md` ~ `09_*.md`의 모든 항목 |
| **Content Class** | Content의 정체(역할) 분류 정보를 갖는 노드 — 이 파일의 항목들 |

모든 Content 노드는 **최소 1개의 Content Class 노드**와 `BELONGS_TO` 엣지(상위/하위가 아닌
"이 클래스에 속한다"는 의미의 별도 엣지)로 연결됩니다. 각 용어 항목의 `**클래스:**` 필드가
그 연결입니다.

클래스는 "노드의 역할"을 뜻하도록 소수(9개)로 유지하며, 필요 시 이 파일에서 추가/개정합니다.

---

### Component
**한글:** 구성요소

nanobot 코드베이스에 실제로 존재하는 구현물 — 클래스, 모듈, 서비스, 함수.
`**코드:**` 필드로 소스 경로를 가리킬 수 있는 것들입니다.
예: `AgentLoop`, `ToolRegistry`, `FallbackProvider`.

### Artifact
**한글:** 산출물/파일

시스템이 읽고 쓰는 파일·데이터 형식. 코드가 아니라 **데이터**로서 존재합니다.
예: `MEMORY.md`, `history.jsonl`, `SKILL.md`, `jobs.json`.

### Mechanism
**한글:** 동작 방식

특정 클래스 하나로 환원되지 않는, 시스템의 동작·기능·절차.
여러 Component가 협력해 만들어내는 행동입니다.
예: Dream, Streaming, Injection, Heartbeat, Prompt Caching.

### Concept
**한글:** 개념

구현과 독립적으로 성립하는 일반 개념·추상 관념. 이 코드베이스 밖에서도 통용됩니다.
예: Token, Context Window, Agent, Session, Transient Error.

### Principle
**한글:** 원칙/패턴

설계·보안·신뢰성의 원칙과 재사용 가능한 패턴.
예: Least Privilege, Circuit Breaker, Defense in Depth, Sliding Window, Facade Pattern.

### Protocol
**한글:** 프로토콜/규격

둘 이상의 시스템이 합의한 통신 규약·데이터 형식 표준.
예: MCP, JSON-RPC, JSON Schema, HTTP, OpenAI-Compatible API.

### Threat
**한글:** 위협

방어해야 할 공격 기법이나 위험 현상.
예: SSRF, Prompt Injection, DNS Rebinding, Hallucination.

### Research
**한글:** 연구/논문

특정 논문·연구 결과로 존재하는 지식.
예: ReAct, Voyager, Lost in the Middle, MemGPT.

### Technology
**한글:** 기술/도구

이 저장소가 사용하는 외부 언어·라이브러리·도구·OS 기능.
예: Python, Pydantic, bubblewrap, tiktoken, bun.
