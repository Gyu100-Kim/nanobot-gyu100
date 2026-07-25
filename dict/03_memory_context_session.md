# 사전 03. 메모리·컨텍스트·세션 (Memory, Context & Session)

> 에이전트의 "기억"에 관한 용어: 모델에게 무엇을 보여주고(컨텍스트), 무엇을 저장하고(세션/메모리),
> 무엇을 줄이는가(압축). 전체 색인은 [README](README.md)를 보세요.

---

### Context
**한글:** 컨텍스트 · **분류:** 컨텍스트 · **코드:** `nanobot/agent/context.py`

한 번의 [LLM](08_ai_llm_concepts.md#llm) 호출에 들어가는 모든 입력의 조립체 —
[System Prompt](#system-prompt), [Memory](#memory), [Skill](01_core_architecture.md#skill) 요약,
최근 대화, [Runtime Context](#runtime-context), 현재 메시지. `build_messages()`가 조립합니다.

- **하위 개념:** [System Prompt](#system-prompt), [Runtime Context](#runtime-context),
  [Context Governance](#context-governance)
- **관련 용어:** [Context Window](08_ai_llm_concepts.md#context-window)

### System Prompt
**한글:** 시스템 프롬프트 · **분류:** 컨텍스트 · **코드:** `nanobot/templates/`

모델에게 정체성·규칙·환경을 알려주는 최상단 지시문. nanobot은
[Jinja2](09_dev_stack.md#jinja2) 마크다운 템플릿(`identity.md`, `platform_policy.md` 등)에서 렌더링합니다.
`.agent/gotchas.md`의 경고처럼, 템플릿 수정은 코드 수정만큼 에이전트 행동을 바꿉니다.

- **상위 개념:** [Context](#context), [Prompt](08_ai_llm_concepts.md#prompt)
- **관련 용어:** [Bootstrap Templates](#bootstrap-templates)

### Runtime Context
**한글:** 런타임 컨텍스트 · **분류:** 컨텍스트

매 턴 갱신되는 실행 정보(현재 시각, 활성 [Sustained Goal](#sustained-goal) 등).
[Prompt Caching](04_providers_and_llm.md#prompt-caching) 적중을 위해 사용자 콘텐츠 **뒤에** 붙여
앞부분(prefix)을 안정시킵니다.

- **상위 개념:** [Context](#context)

### Bootstrap Templates
**한글:** 부트스트랩 템플릿 · **분류:** 컨텍스트 · **코드:** `nanobot/templates/`

새 [Workspace](01_core_architecture.md#workspace)를 초기화할 때 복사되는 시드 파일들
(`SOUL.md`, `HEARTBEAT.md` 등의 원형). `utils/prompt_templates.py`가 로드합니다.

- **상위 개념:** [System Prompt](#system-prompt)

### Context Governance
**한글:** 컨텍스트 거버넌스 · **분류:** 컨텍스트 · **코드:** `nanobot/agent/context_governance.py`

모델에 보내기 직전의 메시지 목록을 검증·절단하는 규칙 모음: [Input Budget](#input-budget) 계산,
[Orphan Tool Result](#orphan-tool-result) 제거, `snip_history`로 오래된 이력 절단.

- **상위 개념:** [Context](#context)
- **하위 개념:** [Input Budget](#input-budget), [Orphan Tool Result](#orphan-tool-result)

### Input Budget
**한글:** 입력 예산 · **분류:** 컨텍스트 · **코드:** `context_governance.py`

한 요청에서 입력이 쓸 수 있는 [Token](08_ai_llm_concepts.md#token) 상한:
`context_window − max_output − 안전 버퍼`. 초과분은 오래된 이력부터 잘립니다.

- **상위 개념:** [Context Governance](#context-governance)
- **관련 용어:** [Context Window](08_ai_llm_concepts.md#context-window),
  [max_tokens](04_providers_and_llm.md#max_tokens)

### Orphan Tool Result
**한글:** 고아 도구 결과 · **분류:** 컨텍스트

짝이 되는 tool_call이 (절단 등으로) 사라진 tool result 메시지.
[Provider](01_core_architecture.md#provider)가 요청을 거부하므로,
[Context Governance](#context-governance)가 제거하거나 누락된 짝을 백필합니다.

- **상위 개념:** [Context Governance](#context-governance)
- **관련 용어:** [Tool Calling](08_ai_llm_concepts.md#tool-calling)

### Session Manager
**한글:** 세션 매니저 · **분류:** 세션 · **코드:** `nanobot/session/manager.py`

[Session](01_core_architecture.md#session)의 [JSONL](#jsonl) 저장/로드/압축을 담당.
`get_history(max_tokens=...)`로 토큰 예산 내의 이력을 돌려줍니다.

- **상위 개념:** [Session](01_core_architecture.md#session)
- **하위 개념:** [last_consolidated Cursor](#last_consolidated-cursor)

### JSONL
**분류:** 세션 · 형식

한 줄에 JSON 객체 하나씩 쌓는 append-only 파일 형식(JSON Lines). 손상에 강하고(마지막 줄만 깨짐)
추가가 빠르므로 세션/이력 저장에 적합합니다. nanobot 세션은 SQLite가 아니라 JSONL입니다.

- **관련 용어:** [Session Manager](#session-manager), [history.jsonl](#historyjsonl)

### AutoCompact
**한글:** 자동 압축 · **분류:** 세션 · **코드:** `nanobot/agent/autocompact.py`

**유휴(idle) 세션**의 긴 이력을 배경에서 [Consolidation](#consolidation)으로 요약하는 서비스.
최근 8개 메시지(`_RECENT_SUFFIX_MESSAGES`)는 원문 유지 —
[Sliding Window](08_ai_llm_concepts.md#sliding-window) 앵커입니다.

- **상위 개념:** [Session](01_core_architecture.md#session),
  [Context Compression](08_ai_llm_concepts.md#context-compression)
- **관련 용어:** [Consolidation](#consolidation)

### Consolidation
**한글:** 통합(요약) · **분류:** 세션

오래된 대화 구간을 [LLM](08_ai_llm_concepts.md#llm)으로 [Summarization](08_ai_llm_concepts.md#summarization)해
원문 대신 요약본을 유지하는 것. [last_consolidated Cursor](#last_consolidated-cursor)로
어디까지 요약했는지 추적합니다.

- **상위 개념:** [AutoCompact](#autocompact)
- **관련 용어:** [Dream](#dream)

### last_consolidated Cursor
**한글:** 통합 커서 · **분류:** 세션

세션 메타데이터에 저장되는 "여기까지 요약 완료" 위치 표시.
같은 구간의 중복 요약을 막고, 이후 턴에는 요약본+최근 원문만 모델에 보냅니다.

- **상위 개념:** [Session Manager](#session-manager), [Consolidation](#consolidation)

### Memory
**한글:** (장기) 메모리 · **분류:** 메모리 · **코드:** `nanobot/agent/memory.py`

대화가 끝나도 유지되는 지식 저장소. nanobot은 벡터 DB가 아니라 **사람이 읽을 수 있는
마크다운 [Durable Files](#durable-files)** 를 씁니다 — 투명하고 [Git](09_dev_stack.md#git)으로 감사 가능합니다.

- **하위 개념:** [Durable Files](#durable-files), [history.jsonl](#historyjsonl), [Dream](#dream)
- **관련 용어:** [Hierarchical Memory](08_ai_llm_concepts.md#hierarchical-memory)

### Durable Files
**한글:** 영속 파일 · **분류:** 메모리 · **코드:** `<workspace>/memory/`, `SOUL.md` 등

에이전트의 정체성과 기억을 담는 마크다운 파일들: [MEMORY.md](#memorymd), [SOUL.md](#soulmd),
[USER.md](#usermd). [Dream](#dream)이 이 파일들을 갱신합니다.

- **상위 개념:** [Memory](#memory)
- **하위 개념:** [MEMORY.md](#memorymd), [SOUL.md](#soulmd), [USER.md](#usermd)

### MEMORY.md
**분류:** 메모리 · **코드:** `<workspace>/memory/MEMORY.md`

축적된 사실/선호를 담는 장기 기억 파일 — 인지과학의
[의미 기억(semantic memory)](08_ai_llm_concepts.md#hierarchical-memory)에 해당합니다.

- **상위 개념:** [Durable Files](#durable-files)

### SOUL.md
**분류:** 메모리 · **코드:** 워크스페이스 루트

에이전트의 성격/정체성을 정의하는 파일. [System Prompt](#system-prompt)에 주입되며,
[Dream](#dream)의 갱신 대상이기도 합니다.

- **상위 개념:** [Durable Files](#durable-files)

### USER.md
**분류:** 메모리

사용자에 대해 알게 된 정보(선호, 습관)를 담는 파일.

- **상위 개념:** [Durable Files](#durable-files)

### history.jsonl
**분류:** 메모리 · **코드:** `<workspace>/memory/history.jsonl`

모든 대화 경험이 append되는 사건 로그 — [일화 기억(episodic memory)](08_ai_llm_concepts.md#hierarchical-memory).
[Dream](#dream)이 이를 읽어 [Durable Files](#durable-files)로 증류합니다.

- **상위 개념:** [Memory](#memory)
- **관련 용어:** [JSONL](#jsonl), [Dream Cursor](#dream-cursor)

### Dream
**한글:** 드림(기억 통합) · **분류:** 메모리 · **코드:** `nanobot/agent/memory.py`

[Cron](06_scheduling_automation.md#cron)으로 주기 실행되는 **기억 통합 작업**:
[history.jsonl](#historyjsonl)의 미처리 기록과 현재 메모리 파일 내용을 프롬프트로 만들어,
파일 편집 도구만 가진 제한 레지스트리로 [Durable Files](#durable-files)를 갱신합니다.
실제 [Git](09_dev_stack.md#git) diff가 있을 때만 [Dream Cursor](#dream-cursor)를 전진시키는
보수적 설계로 환각을 억제합니다([Reflection](08_ai_llm_concepts.md#reflection) 계열).

- **상위 개념:** [Memory](#memory)
- **하위 개념:** [Dream Cursor](#dream-cursor)
- **관련 용어:** [Least Privilege](07_security_isolation.md#least-privilege)

### Dream Cursor
**분류:** 메모리 · **코드:** `<workspace>/memory/.dream_cursor`

[Dream](#dream)이 [history.jsonl](#historyjsonl)의 어디까지 처리했는지 기록하는 위치 파일.

- **상위 개념:** [Dream](#dream)

### Sustained Goal
**한글:** 지속 목표 · **분류:** 세션 · **코드:** `nanobot/session/goal_state.py`

한 [Turn](01_core_architecture.md#turn)을 넘어 계속 추적되는 목표.
[Long Task Tool](02_tools_and_skills.md#long-task-tool)이 세션 메타데이터에 등록하고,
매 턴 [Runtime Context](#runtime-context)에 미러링되어 압축 후에도 유지됩니다.

- **하위 개념:** [Goal State](#goal-state)
- **관련 용어:** [Heartbeat](06_scheduling_automation.md#heartbeat)

### Goal State
**한글:** 목표 상태 · **분류:** 세션 · **코드:** `nanobot/session/goal_state.py`

[Sustained Goal](#sustained-goal)의 등록/완료 상태를 세션 메타데이터로 관리하는 모듈.

- **상위 개념:** [Sustained Goal](#sustained-goal)

### History Visibility
**한글:** 이력 가시성 · **분류:** 세션 · **코드:** `nanobot/session/history_visibility.py`

세션 이력 중 어떤 메시지를 모델/UI에 보일지 제어하는 규칙(내부 마커, 시스템 잡 이력 숨김 등).

- **상위 개념:** [Session](01_core_architecture.md#session)

### WebUI Turn Coordinator
**분류:** 세션 · **코드:** `nanobot/session/webui_turns.py`

[WebUI](05_channels_gateway_ui.md#webui)에 필요한 턴 이벤트(`_turn_end`, `_goal_status`, 제목 갱신 등)를
조율하는 계층. `.agent/design.md`에 따라 UI 와이어 세부사항은 코어가 아닌 이곳에 둡니다.

- **상위 개념:** [Session](01_core_architecture.md#session)
- **관련 용어:** [WebSocket Channel](05_channels_gateway_ui.md#websocket-channel)
