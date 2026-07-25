# 사전 03. 메모리·컨텍스트·세션 (Memory, Context & Session)

> 에이전트의 "기억"에 관한 용어: 모델에게 무엇을 보여주고(컨텍스트), 무엇을 저장하고(세션/메모리),
> 무엇을 줄이는가(압축). 전체 색인은 [README](README.md), 노드 클래스 정의는
> [00_content_classes.md](00_content_classes.md)를 보세요.
>
> 표기 규약: **상위 개념 = 더 특수한 개념**(예시·구현·특수화), **하위 개념 = 더 일반적인 개념**(일반화).

---

### Context
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 컨텍스트 · **코드:** `nanobot/agent/context.py`

한 번의 [LLM](08_ai_llm_concepts.md#llm) 호출에 들어가는 모든 입력의 조립체.
모델은 이 조립체에 든 것만 알 수 있으므로, "컨텍스트에 무엇을 넣느냐"가 에이전트의 지능을 좌우합니다.
`build_messages()`가 조립합니다.

**예시:** nanobot의 한 턴 컨텍스트 = [System Prompt](#system-prompt) +
[Memory](#memory) 파일 내용 + [Skill](01_core_architecture.md#skill) 요약 + 최근 대화 이력 +
[Runtime Context](#runtime-context)(현재 시각 등) + 현재 사용자 메시지.

- **상위 개념(더 특수):** [System Prompt](#system-prompt), [Runtime Context](#runtime-context),
  [Context Governance](#context-governance)
- **하위 개념(더 일반):** [Prompt](08_ai_llm_concepts.md#prompt)
- **관련 용어:** [Context Window](08_ai_llm_concepts.md#context-window)

### System Prompt
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 시스템 프롬프트 · **코드:** `nanobot/templates/`

모델에게 정체성·규칙·환경을 알려주는 최상단 지시문 — [Prompt](08_ai_llm_concepts.md#prompt)의 특수한
형태로, 사용자 메시지보다 높은 권위를 갖도록 취급됩니다. nanobot은
[Jinja2](09_dev_stack.md#jinja2) 마크다운 템플릿(`identity.md`, `platform_policy.md` 등)에서
렌더링합니다. `.agent/gotchas.md`의 경고처럼, 템플릿 수정은 코드 수정만큼 에이전트 행동을 바꿉니다.

- **하위 개념(더 일반):** [Prompt](08_ai_llm_concepts.md#prompt), [Context](#context)
- **상위 개념(더 특수):** [Bootstrap Templates](#bootstrap-templates)
- **관련 용어:** [Jinja2](09_dev_stack.md#jinja2)

### Runtime Context
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 런타임 컨텍스트

매 턴 갱신되는 실행 정보 블록 — 현재 시각, 활성 [Sustained Goal](#sustained-goal) 등.
[Prompt Caching](04_providers_and_llm.md#prompt-caching) 적중을 위해 사용자 콘텐츠 **뒤에** 붙여
앞부분(prefix)을 안정시킵니다. "시계는 맨 뒤에 차고 있어야 캐시가 산다"는 배치의 묘입니다.

- **하위 개념(더 일반):** [Context](#context)
- **관련 용어:** [Prompt Caching](04_providers_and_llm.md#prompt-caching)

### Bootstrap Templates
**클래스:** [Artifact](00_content_classes.md#artifact) · **한글:** 부트스트랩 템플릿 · **코드:** `nanobot/templates/`

새 [Workspace](01_core_architecture.md#workspace)를 초기화할 때 복사되는 시드 파일들
([SOUL.md](#soulmd), [HEARTBEAT.md](06_scheduling_automation.md#heartbeatmd)의 원형).
`utils/prompt_templates.py`가 로드합니다 — "새 에이전트의 출고 시 성격".

- **하위 개념(더 일반):** [System Prompt](#system-prompt),
  [Markdown](02_tools_and_skills.md#markdown)

### Context Governance
**클래스:** [Component](00_content_classes.md#component) · **한글:** 컨텍스트 거버넌스 · **코드:** `nanobot/agent/context_governance.py`

모델에 보내기 직전의 메시지 목록을 검증·절단하는 규칙 모음: [Input Budget](#input-budget) 계산,
[Orphan Tool Result](#orphan-tool-result) 제거, `snip_history`로 오래된 이력 절단.
"보내면 API가 거부할 요청"을 사전에 합법 상태로 고치는 마지막 관문입니다.

- **하위 개념(더 일반):** [Context](#context),
  [Context Compression](08_ai_llm_concepts.md#context-compression)
- **상위 개념(더 특수):** [Input Budget](#input-budget), [Orphan Tool Result](#orphan-tool-result)

### Input Budget
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 입력 예산 · **코드:** `context_governance.py`

한 요청에서 입력이 쓸 수 있는 [Token](08_ai_llm_concepts.md#token) 상한:

```text
input_budget = context_window − max_output_tokens − 안전 버퍼
```

**예시:** 창 200K, 출력 예약 8K, 버퍼 2K라면 입력은 190K까지 — 초과분은 오래된 이력부터 잘립니다.
출력 몫을 미리 빼 두지 않으면 "입력은 들어갔는데 답변이 잘리는" 사고가 납니다.

- **하위 개념(더 일반):** [Context Governance](#context-governance),
  [Context Window](08_ai_llm_concepts.md#context-window)
- **관련 용어:** [max_tokens](04_providers_and_llm.md#max_tokens)

### Orphan Tool Result
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 고아 도구 결과

짝이 되는 tool_call이 (절단 등으로) 사라진 tool result 메시지. 모든 tool result는 대응하는
tool_call과 짝을 이뤄야 한다는 [Tool Calling](08_ai_llm_concepts.md#tool-calling) API 규칙 때문에,
고아가 있으면 [Provider](01_core_architecture.md#provider)가 요청 전체를 거부합니다.
[Context Governance](#context-governance)가 제거하거나 누락된 짝을 백필합니다.

- **하위 개념(더 일반):** [Context Governance](#context-governance),
  [Tool Calling](08_ai_llm_concepts.md#tool-calling)

### Session Manager
**클래스:** [Component](00_content_classes.md#component) · **한글:** 세션 매니저 · **코드:** `nanobot/session/manager.py`

[Session](01_core_architecture.md#session)의 [JSONL](#jsonl) 저장/로드/압축을 담당.
`get_history(max_tokens=...)`로 토큰 예산 내의 이력을 돌려줍니다.
저장은 [Atomic Write](#atomic-write)로 해 크래시에도 파일이 반쯤 깨지지 않게 합니다.

- **하위 개념(더 일반):** [Session](01_core_architecture.md#session)
- **상위 개념(더 특수):** [last_consolidated Cursor](#last_consolidated-cursor)

### JSONL
**클래스:** [Artifact](00_content_classes.md#artifact) · **한글:** JSON Lines

한 줄에 JSON 객체 하나씩 쌓는 [Append-only Log](#append-only-log) 파일 형식.
손상에 강하고(깨져도 마지막 줄만) 추가가 O(1)이라 세션/이력 저장에 적합합니다.

**예시:** 세션 파일의 두 줄 —

```text
{"role": "user", "content": "안녕"}
{"role": "assistant", "content": "안녕하세요!"}
```

- **하위 개념(더 일반):** [Append-only Log](#append-only-log)
- **상위 개념(더 특수):** [history.jsonl](#historyjsonl)
- **관련 용어:** [Session Manager](#session-manager)

### Append-only Log
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 추가 전용 로그

기존 내용을 수정하지 않고 **끝에 덧붙이기만** 하는 저장 방식. 쓰기가 빠르고, 동시 접근 충돌이 적고,
과거가 변조되지 않으며, 크래시 시 피해가 마지막 항목으로 국한됩니다. 데이터베이스의 WAL,
블록체인, 이벤트 소싱이 모두 이 원리입니다.

**예시:** nanobot의 [JSONL](#jsonl) 세션 파일과 [history.jsonl](#historyjsonl).

- **상위 개념(더 특수):** [JSONL](#jsonl)
- **관련 용어:** [Atomic Write](#atomic-write)

### Atomic Write
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 원자적 쓰기

파일 쓰기가 "전부 반영" 또는 "전혀 반영 안 됨" 둘 중 하나가 되도록 하는 기법 — 임시 파일에 쓰고
[fsync](#fsync) 후 원자적 rename으로 교체하는 것이 정석입니다. 도중에 전원이 나가도 반쯤 쓰인
파일이 남지 않습니다. nanobot의 메모리 저장이 이 방식을 씁니다(fsync 포함).

- **상위 개념(더 특수):** [fsync](#fsync)
- **관련 용어:** [Runtime Checkpoint](01_core_architecture.md#runtime-checkpoint),
  [apply_patch](02_tools_and_skills.md#apply_patch)

### fsync
**클래스:** [Technology](00_content_classes.md#technology)

OS 버퍼에 있는 쓰기 내용을 **물리 디스크까지 강제로 내리는** 시스템 콜. `write()`만 하면 데이터가
아직 메모리에만 있을 수 있어, 전원 장애 시 유실됩니다. 내구성(durability)이 필요한 저장(체크포인트,
메모리 파일)에서 [Atomic Write](#atomic-write)와 함께 쓰입니다.

- **하위 개념(더 일반):** [Atomic Write](#atomic-write)

### AutoCompact
**클래스:** [Component](00_content_classes.md#component) · **한글:** 자동 압축 · **코드:** `nanobot/agent/autocompact.py`

**유휴(idle) 세션**의 긴 이력을 배경에서 [Consolidation](#consolidation)으로 요약하는 서비스.
사용자가 대화 중일 때가 아니라 한가할 때 정리하므로 응답 지연이 없습니다.
최근 8개 메시지(`_RECENT_SUFFIX_MESSAGES`)는 원문 유지 —
[Sliding Window](08_ai_llm_concepts.md#sliding-window)의 앵커입니다.

- **하위 개념(더 일반):** [Session](01_core_architecture.md#session),
  [Context Compression](08_ai_llm_concepts.md#context-compression)
- **관련 용어:** [Consolidation](#consolidation), [TTL](#ttl)

### TTL
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 유효 시간 (Time To Live)

데이터나 상태가 "얼마나 오래 유효한가"를 정하는 만료 시간. 캐시 만료, DNS 레코드 수명 등에 두루
쓰이는 개념으로, nanobot에서는 세션이 일정 시간 유휴하면 [AutoCompact](#autocompact) 대상이 되는
기준으로 등장합니다.

- **관련 용어:** [AutoCompact](#autocompact)

### Consolidation
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 통합(요약)

오래된 대화 구간을 [LLM](08_ai_llm_concepts.md#llm)으로
[Summarization](08_ai_llm_concepts.md#summarization)해 원문 대신 요약본을 유지하는 것.

**예시:** 300개 메시지의 앞 250개를 "사용자는 X 프로젝트를 진행 중이며 …" 한 단락으로 접고,
이후 턴에는 [요약 + 최근 원문]만 모델에 보냅니다. [last_consolidated Cursor](#last_consolidated-cursor)로
어디까지 접었는지 추적해 중복 요약을 막습니다.

- **하위 개념(더 일반):** [Summarization](08_ai_llm_concepts.md#summarization),
  [AutoCompact](#autocompact)
- **관련 용어:** [Dream](#dream)

### last_consolidated Cursor
**클래스:** [Artifact](00_content_classes.md#artifact) · **한글:** 통합 커서

세션 메타데이터에 저장되는 "여기까지 요약 완료" 위치 표시 — [Cursor](#cursor)의 한 사례입니다.

- **하위 개념(더 일반):** [Session Manager](#session-manager), [Consolidation](#consolidation),
  [Cursor](#cursor)

### Cursor
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 커서(진행 위치)

스트림/로그에서 "여기까지 처리했다"를 기록하는 위치 표식. 커서 이후만 처리하면 되므로
재처리와 중복을 막고, 크래시 후에도 이어서 진행할 수 있습니다.

**예시:** [Dream Cursor](#dream-cursor)(기억 통합 진행 위치),
[last_consolidated Cursor](#last_consolidated-cursor)(세션 요약 진행 위치).

- **상위 개념(더 특수):** [Dream Cursor](#dream-cursor),
  [last_consolidated Cursor](#last_consolidated-cursor)
- **관련 용어:** [Append-only Log](#append-only-log)

### Memory
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** (장기) 메모리 · **코드:** `nanobot/agent/memory.py`

대화가 끝나도 유지되는 지식 저장소. [LLM](08_ai_llm_concepts.md#llm) 자체는 아무것도 기억하지
못하므로(무상태), 기억은 **런타임이 파일로 만들어 매번 다시 보여주는 것**입니다. nanobot은 벡터 DB가
아니라 사람이 읽을 수 있는 [Markdown](02_tools_and_skills.md#markdown)
[Durable Files](#durable-files)를 씁니다 — 투명하고 [Git](09_dev_stack.md#git)으로 감사 가능합니다.

- **상위 개념(더 특수):** [Durable Files](#durable-files), [history.jsonl](#historyjsonl),
  [Dream](#dream)
- **관련 용어:** [Hierarchical Memory](08_ai_llm_concepts.md#hierarchical-memory)

### Durable Files
**클래스:** [Artifact](00_content_classes.md#artifact) · **한글:** 영속 파일

에이전트의 정체성과 기억을 담는 마크다운 파일들. [Dream](#dream)이 갱신합니다.

**예시:** [MEMORY.md](#memorymd)(사실·선호), [SOUL.md](#soulmd)(성격·정체성),
[USER.md](#usermd)(사용자 정보).

- **하위 개념(더 일반):** [Memory](#memory), [Markdown](02_tools_and_skills.md#markdown)
- **상위 개념(더 특수):** [MEMORY.md](#memorymd), [SOUL.md](#soulmd), [USER.md](#usermd)

### MEMORY.md
**클래스:** [Artifact](00_content_classes.md#artifact) · **코드:** `<workspace>/memory/MEMORY.md`

축적된 사실/선호를 담는 장기 기억 파일 — 인지과학의 의미 기억(semantic memory)에 해당합니다
([Hierarchical Memory](08_ai_llm_concepts.md#hierarchical-memory) 참조).

**예시:** "사용자는 커밋 메시지를 영어로 쓰는 것을 선호한다", "프로젝트 X의 저장소는 ~/repos/x이다".

- **하위 개념(더 일반):** [Durable Files](#durable-files)

### SOUL.md
**클래스:** [Artifact](00_content_classes.md#artifact) · **코드:** 워크스페이스 루트

에이전트의 성격/정체성을 정의하는 파일. [System Prompt](#system-prompt)에 주입되며,
[Dream](#dream)의 갱신 대상이기도 합니다 — 에이전트가 경험을 통해 "성격이 다듬어질" 수 있는 통로.

- **하위 개념(더 일반):** [Durable Files](#durable-files)

### USER.md
**클래스:** [Artifact](00_content_classes.md#artifact)

사용자에 대해 알게 된 정보(선호, 습관, 맥락)를 담는 파일.

- **하위 개념(더 일반):** [Durable Files](#durable-files)

### history.jsonl
**클래스:** [Artifact](00_content_classes.md#artifact) · **코드:** `<workspace>/memory/history.jsonl`

모든 대화 경험이 append되는 사건 로그 — 인지과학의 일화 기억(episodic memory)에 해당합니다.
[Dream](#dream)이 이를 읽어 [Durable Files](#durable-files)(의미 기억)로 증류합니다.

- **하위 개념(더 일반):** [Memory](#memory), [JSONL](#jsonl)
- **관련 용어:** [Dream Cursor](#dream-cursor)

### Dream
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 드림(기억 통합) · **코드:** `nanobot/agent/memory.py`

[Cron](06_scheduling_automation.md#cron)으로 주기 실행되는 **기억 통합 작업** — 사람이 자면서
기억을 정리하는 것의 비유입니다. [history.jsonl](#historyjsonl)의 미처리 기록과 현재 메모리 파일
내용을 프롬프트로 만들어, **파일 편집 도구만 가진** 제한 레지스트리로
[Durable Files](#durable-files)를 갱신합니다.

핵심 안전장치: 실제 [Git](09_dev_stack.md#git) diff가 있을 때만 [Dream Cursor](#dream-cursor)를
전진시킵니다 — 모델이 "정리했다"고 말만 하는 [Hallucination](08_ai_llm_concepts.md#hallucination)을
차단하는 검증 게이트([Reflection](08_ai_llm_concepts.md#reflection) 계열의 보수적 구현).

- **하위 개념(더 일반):** [Memory](#memory), [Reflection](08_ai_llm_concepts.md#reflection)
- **상위 개념(더 특수):** [Dream Cursor](#dream-cursor)
- **관련 용어:** [Least Privilege](07_security_isolation.md#least-privilege),
  [Consolidation](#consolidation)

### Dream Cursor
**클래스:** [Artifact](00_content_classes.md#artifact) · **코드:** `<workspace>/memory/.dream_cursor`

[Dream](#dream)이 [history.jsonl](#historyjsonl)의 어디까지 처리했는지 기록하는 위치 파일 —
[Cursor](#cursor)의 한 사례.

- **하위 개념(더 일반):** [Dream](#dream), [Cursor](#cursor)

### Sustained Goal
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 지속 목표 · **코드:** `nanobot/session/goal_state.py`

한 [Turn](01_core_architecture.md#turn)을 넘어 계속 추적되는 목표.
[Long Task Tool](02_tools_and_skills.md#long-task-tool)이 세션 메타데이터에 등록하고, 매 턴
[Runtime Context](#runtime-context)에 미러링되어 이력 압축 후에도 유지됩니다.

**예시:** "이번 주 내내 논문 정리를 도와줘"라는 목표를 등록해 두면, 세션 이력이 여러 번 압축되어도
매 턴 "활성 목표: 논문 정리"가 모델 눈앞에 있습니다.

- **상위 개념(더 특수):** [Goal State](#goal-state)
- **관련 용어:** [Heartbeat](06_scheduling_automation.md#heartbeat)

### Goal State
**클래스:** [Component](00_content_classes.md#component) · **한글:** 목표 상태 · **코드:** `nanobot/session/goal_state.py`

[Sustained Goal](#sustained-goal)의 등록/완료 상태를 세션 메타데이터로 관리하는 모듈.

- **하위 개념(더 일반):** [Sustained Goal](#sustained-goal)

### History Visibility
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 이력 가시성 · **코드:** `nanobot/session/history_visibility.py`

세션 이력 중 어떤 메시지를 모델/UI에 보일지 제어하는 규칙(내부 마커, 시스템 잡 이력 숨김 등).
"저장은 하되 보여주지는 않는다"의 구분을 담당합니다.

- **하위 개념(더 일반):** [Session](01_core_architecture.md#session)

### WebUI Turn Coordinator
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/session/webui_turns.py`

[WebUI](05_channels_gateway_ui.md#webui)에 필요한 턴 이벤트(`_turn_end`, `_goal_status`, 제목 갱신)를
조율하는 계층. `.agent/design.md`에 따라 UI 와이어 세부사항은 코어([AgentLoop](01_core_architecture.md#agentloop))가
아닌 이곳에 둡니다 — 관심사 분리의 사례.

- **하위 개념(더 일반):** [Session](01_core_architecture.md#session)
- **관련 용어:** [WebSocket Channel](05_channels_gateway_ui.md#websocket-channel)
