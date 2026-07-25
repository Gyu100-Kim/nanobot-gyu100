# 사전 02. 도구와 스킬 (Tools & Skills)

> [Tool](01_core_architecture.md#tool)/[Skill](01_core_architecture.md#skill) 계층의 세부 용어.
> 전체 색인은 [README](README.md), 노드 클래스 정의는 [00_content_classes.md](00_content_classes.md)를 보세요.
>
> 표기 규약: **상위 개념 = 이 개념을 기반(전제)으로 만들어진 파생 개념**, **하위 개념 = 이 개념을 규정하기 위해 필요한 기반/전제 개념**.

---

### ToolRegistry
**클래스:** [Component](00_content_classes.md#component) · **한글:** 도구 레지스트리 · **코드:** `nanobot/agent/tools/registry.py`

등록된 모든 [Tool](01_core_architecture.md#tool)의 목록을 관리하고 이름으로 실행을 디스패치하는
중심 객체 — [Registry Pattern](#registry-pattern)의 구현입니다. 모델이 `read_file`이라는 이름으로
호출을 요청하면 레지스트리가 해당 도구 객체를 찾아 `execute()`를 부릅니다.
[MCPToolWrapper](#mcptoolwrapper)처럼 `mcp_` 접두 도구는 내장 도구 뒤로 정렬해 모델이 내장 도구를
우선 보게 합니다.

- **하위 개념(기반·전제):** [Registry Pattern](#registry-pattern), [Tool](01_core_architecture.md#tool)
- **상위 개념(이를 기반으로 파생):** [Tool Discovery](#tool-discovery), [Tool Scope](#tool-scope)
- **관련 용어:** [AgentRunner](01_core_architecture.md#agentrunner)

### Registry Pattern
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 레지스트리 패턴

"이름 → 객체" 매핑을 중앙 등록소 하나에 모아, 이름만 알면 어떤 구현이든 찾아 쓸 수 있게 하는 패턴.
새 항목 추가가 "등록 한 줄"로 끝나므로 [Plugin Architecture](#plugin-architecture)의 기반이 됩니다.

**예시:** [ToolRegistry](#toolregistry)(도구),
[Channel Registry](05_channels_gateway_ui.md#channel-registry)(채널),
[Provider Registry](04_providers_and_llm.md#provider-registry)(프로바이더) — nanobot의 3대 레지스트리.

- **상위 개념(이를 기반으로 파생):** [ToolRegistry](#toolregistry),
  [Channel Registry](05_channels_gateway_ui.md#channel-registry),
  [Provider Registry](04_providers_and_llm.md#provider-registry)

### Plugin Architecture
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 플러그인 아키텍처

코어를 수정하지 않고 외부에서 기능을 **꽂아 넣을 수 있게** 확장점을 설계하는 방식.
"Core stays small; extend at the edges"라는 nanobot의 설계 이념(`.agent/design.md`) 그 자체입니다.

**예시:** [Entry-point Plugin](#entry-point-plugin)으로 별도 pip 패키지가 자기 도구/채널을 nanobot에
등록하는 것, [MCP](08_ai_llm_concepts.md#mcp) 서버로 외부 도구를 연결하는 것.

- **상위 개념(이를 기반으로 파생):** [Entry-point Plugin](#entry-point-plugin), [Tool Discovery](#tool-discovery)
- **관련 용어:** [Registry Pattern](#registry-pattern), [Decoupling](01_core_architecture.md#decoupling)

### Tool Discovery
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 도구 자동 발견 · **코드:** `nanobot/agent/tools/loader.py`

`tools/` 패키지를 [pkgutil](09_dev_stack.md#pkgutil)로 스캔해 도구 모듈을 자동 등록하는 메커니즘.
"파일을 그 디렉토리에 두면 도구가 된다" — 등록 코드를 어디에 추가할지 몰라도 되는 관례 기반
(convention over configuration) 설계입니다. [_SKIP_MODULES](#_skip_modules)에 있는 인프라 모듈은
제외되고, 외부 패키지는 [Entry-point Plugin](#entry-point-plugin)으로 합류합니다.

- **하위 개념(기반·전제):** [ToolRegistry](#toolregistry), [Plugin Architecture](#plugin-architecture)
- **상위 개념(이를 기반으로 파생):** [_SKIP_MODULES](#_skip_modules), [Entry-point Plugin](#entry-point-plugin)

### _SKIP_MODULES
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/agent/tools/loader.py`

[Tool Discovery](#tool-discovery)에서 제외되는 모듈 이름 목록: `base`, `schema`, `registry`,
`context`, `loader`, `config`, `file_state`, `sandbox`, `mcp`, `runtime_state` 등.
도구가 아닌 인프라이거나([Sandbox](07_security_isolation.md#sandbox)), 특수 경로로 등록되는
([MCPToolWrapper](#mcptoolwrapper)) 모듈들입니다 — 자동 발견의 "예외 명단".

- **하위 개념(기반·전제):** [Tool Discovery](#tool-discovery)

### Entry-point Plugin
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 엔트리포인트 플러그인

파이썬 패키징의 [Entry Points](09_dev_stack.md#entry-points) 규격(`nanobot.tools`,
`nanobot.channels` 그룹)으로 **별도 설치된 외부 패키지**가 도구/채널을 nanobot에 등록하는 방식.

**예시:** 누군가 `nanobot-jira`라는 패키지를 만들어 `[project.entry-points."nanobot.tools"]`에
자기 도구를 선언해 배포하면, 사용자는 `pip install nanobot-jira`만으로 Jira 도구를 얻습니다.

- **하위 개념(기반·전제):** [Tool Discovery](#tool-discovery), [Plugin Architecture](#plugin-architecture),
  [Entry Points](09_dev_stack.md#entry-points)

### ToolResult
**클래스:** [Component](00_content_classes.md#component) · **한글:** 도구 실행 결과 · **코드:** `nanobot/agent/tools/base.py`

도구 실행의 표준 반환 객체(성공 내용 또는 `error`). 핵심 설계는 **오류도 삼키지 않고 모델에게
텍스트로 돌려준다**는 것 — 모델이 오류 메시지를 읽고 스스로 다른 방법을 시도하게 합니다
(self-correction).

**예시:** `read_file`이 없는 파일을 받으면 예외 대신 `error="File not found: x.txt"`를 돌려주고,
모델은 이를 보고 `list_dir`로 실제 파일명을 확인한 뒤 다시 시도합니다.

- **하위 개념(기반·전제):** [Tool](01_core_architecture.md#tool)
- **관련 용어:** [Tool Calling](08_ai_llm_concepts.md#tool-calling)

### Tool Schema
**클래스:** [Component](00_content_classes.md#component) · **한글:** 도구 스키마 · **코드:** `nanobot/agent/tools/schema.py`

도구 파라미터를 [JSON Schema](08_ai_llm_concepts.md#json-schema)로 선언하기 위한 타입 클래스들
(`StringSchema`, `IntegerSchema`, `ObjectSchema` 등). `to_json_schema()`가 표준 dict를 만들어
[Provider](01_core_architecture.md#provider)에 전달됩니다 — 모델이 읽는 "도구의 계약서"를
파이썬답게 쓰는 도우미입니다.

- **하위 개념(기반·전제):** [Tool](01_core_architecture.md#tool),
  [JSON Schema](08_ai_llm_concepts.md#json-schema)

### Tool Scope
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 도구 스코프

각 도구가 쓰일 수 있는 문맥(`core`, `subagent`)을 제한하는 속성(`_scopes`).

**예시:** [Subagent](01_core_architecture.md#subagent)에는 또 다른 서브에이전트를 만드는
[SpawnTool](#spawntool)을 주지 않아 무한 증식을 막습니다 —
[Least Privilege](07_security_isolation.md#least-privilege)의 도구 계층 적용.

- **하위 개념(기반·전제):** [ToolRegistry](#toolregistry),
  [Least Privilege](07_security_isolation.md#least-privilege)

### ExecTool
**클래스:** [Component](00_content_classes.md#component) · **한글:** 셸 실행 도구 · **코드:** `nanobot/agent/tools/shell.py`

셸 명령을 실행하는 도구 — 에이전트에게 가장 강력하고 가장 위험한 능력.
[Sandbox Backend](07_security_isolation.md#sandbox-backend)로 명령을 감싸고 하드
[Timeout](07_security_isolation.md#timeout)(기본 60초)으로 폭주를 차단합니다.
Windows에서는 PowerShell(`pwsh` 우선)이 기본입니다.

- **하위 개념(기반·전제):** [Tool](01_core_architecture.md#tool)
- **상위 개념(이를 기반으로 파생):** [Exec Session](#exec-session)
- **관련 용어:** [bubblewrap](07_security_isolation.md#bubblewrap)

### Exec Session
**클래스:** [Component](00_content_classes.md#component) · **한글:** 실행 세션 · **코드:** `nanobot/agent/tools/exec_session.py`

상태 유지형(interactive) 셸 세션 관리자(`ExecSessionManager`). 일회성 [ExecTool](#exectool)과 달리
프로세스를 살려 두고 [WriteStdinTool](#writestdintool)로 입력을 이어 보낼 수 있습니다.

**예시:** 파이썬 REPL을 열어 두고 여러 턴에 걸쳐 변수를 유지하며 실험하거나, `ssh` 접속 후
비밀번호 프롬프트에 응답하는 시나리오.

- **하위 개념(기반·전제):** [ExecTool](#exectool)
- **상위 개념(이를 기반으로 파생):** [WriteStdinTool](#writestdintool)

### WriteStdinTool
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/agent/tools/exec_session.py`

살아 있는 [Exec Session](#exec-session) 프로세스의 표준입력에 텍스트/특수키를 쓰는 도구.
대화형 프로그램(REPL, 에디터, 프롬프트) 제어에 쓰입니다.

- **하위 개념(기반·전제):** [Exec Session](#exec-session)

### Filesystem Tools
**클래스:** [Component](00_content_classes.md#component) · **한글:** 파일시스템 도구 · **코드:** `nanobot/agent/tools/filesystem.py`

파일 읽기/쓰기/편집/목록 도구 모음. 모든 경로는
[Workspace Policy](07_security_isolation.md#workspace-policy) 경계 검사를 거치며,
[File State](#file-state)로 "읽기 전 편집" 경고와 중복 읽기 감지를 합니다 — 모델이 보지도 않은
파일을 덮어쓰는 사고를 막는 안전장치입니다.

- **하위 개념(기반·전제):** [Tool](01_core_architecture.md#tool)
- **상위 개념(이를 기반으로 파생):** [apply_patch](#apply_patch), [File State](#file-state),
  [Path Utils](#path-utils)

### apply_patch
**클래스:** [Component](00_content_classes.md#component) · **한글:** 패치 적용 도구 · **코드:** `nanobot/agent/tools/apply_patch.py`

여러 파일 변경을 하나의 패치 텍스트로 기술해 원자적으로 적용하는 편집 도구.
"3개 파일을 고치다가 2번째에서 실패"하는 어중간한 상태 대신, 전부 성공 또는 전부 실패를 보장하는
방향의 설계입니다.

- **하위 개념(기반·전제):** [Filesystem Tools](#filesystem-tools)
- **관련 용어:** [Atomic Write](03_memory_context_session.md#atomic-write)

### Web Tools
**클래스:** [Component](00_content_classes.md#component) · **한글:** 웹 도구 · **코드:** `nanobot/agent/tools/web.py`, `search.py`

URL 가져오기(fetch)와 웹 검색 도구. 검색은 [ddgs](09_dev_stack.md#ddgs)(API 키 불필요)를 쓰고,
fetch는 [SSRF](07_security_isolation.md#ssrf) 방어와
[DNS Pinning](07_security_isolation.md#dns-pinning)을 거칩니다 — 에이전트가 인터넷을 읽되
내부망은 못 읽게 하는 경계입니다.

- **하위 개념(기반·전제):** [Tool](01_core_architecture.md#tool)
- **관련 용어:** [httpx](09_dev_stack.md#httpx)

### MessageTool
**클래스:** [Component](00_content_classes.md#component) · **한글:** 메시지 도구 · **코드:** `nanobot/agent/tools/message.py`

에이전트가 턴 도중 사용자에게 직접 메시지를 보내는 도구 — 긴 작업 중의 중간 보고에 쓰입니다.
[Heartbeat](06_scheduling_automation.md#heartbeat) 실행 중에는 `set_suppress_delivery`로 전송이
억제됩니다(할 일 점검 때마다 사용자에게 알림이 가는 소음 방지).

- **하위 개념(기반·전제):** [Tool](01_core_architecture.md#tool)

### SpawnTool
**클래스:** [Component](00_content_classes.md#component) · **한글:** 스폰 도구 · **코드:** `nanobot/agent/tools/spawn.py`

[Subagent](01_core_architecture.md#subagent)를 띄워 작업을 위임하는 도구.

**예시:** "이 저장소 전체를 분석해줘" 같은 오래 걸리는 일을 서브에이전트에 맡기면, 메인 대화는
계속 응답 가능하고 완료 시 결과만 보고받습니다.

- **하위 개념(기반·전제):** [Tool](01_core_architecture.md#tool),
  [Subagent](01_core_architecture.md#subagent)

### Cron Tool
**클래스:** [Component](00_content_classes.md#component) · **한글:** 크론 도구 · **코드:** `nanobot/agent/tools/cron.py`

에이전트가 스스로 [Cron Job](06_scheduling_automation.md#cron-job)을 등록/삭제하는 도구.

**예시:** 사용자가 "매일 아침 9시에 일정 알려줘"라고 하면, 에이전트가 이 도구로
`0 9 * * *` 스케줄의 잡을 등록합니다 — 자연어가 실제 스케줄이 되는 경로입니다.

- **하위 개념(기반·전제):** [Tool](01_core_architecture.md#tool), [Cron](06_scheduling_automation.md#cron)

### MyTool
**클래스:** [Component](00_content_classes.md#component) · **한글:** 자기 관리 도구 · **코드:** `nanobot/agent/tools/self.py`

에이전트가 자기 자신의 런타임 상태를 조회/조작하는 도구.
[Runtime State Protocol](#runtime-state-protocol)을 통해 [AgentLoop](01_core_architecture.md#agentloop)
상태에 접근합니다 — 도구가 루프 구현에 직접 의존하지 않게 하는 경계를 사이에 둡니다.

- **하위 개념(기반·전제):** [Tool](01_core_architecture.md#tool)
- **상위 개념(이를 기반으로 파생):** [Runtime State Protocol](#runtime-state-protocol)

### Runtime State Protocol
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/agent/tools/runtime_state.py`

[AgentLoop](01_core_architecture.md#agentloop) 상태를 [MyTool](#mytool)에 노출하는 파이썬 Protocol
(구조적 타이핑 인터페이스 — "이 메서드들만 있으면 무엇이든 OK").
[Decoupling](01_core_architecture.md#decoupling)의 타입 수준 실현입니다.

- **하위 개념(기반·전제):** [MyTool](#mytool), [Decoupling](01_core_architecture.md#decoupling)

### MCPToolWrapper
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/agent/tools/mcp.py`

[MCP](08_ai_llm_concepts.md#mcp) 서버가 제공하는 원격 도구를 nanobot
[Tool](01_core_architecture.md#tool) 인터페이스로 감싸는 [Adapter Pattern](01_core_architecture.md#adapter-pattern)
구현. 도구 이름에 `mcp_<server>_` 접두를 붙이고,
[stdio Transport](08_ai_llm_concepts.md#stdio-transport)와 HTTP/[SSE](08_ai_llm_concepts.md#sse)를
지원하며, 원격 연결은 [PinnedDNSAsyncTransport](07_security_isolation.md#pinneddnsasynctransport)로
보호합니다.

**예시:** GitHub MCP 서버를 설정에 추가하면 `mcp_github_create_issue` 같은 도구가 자동으로
모델에게 노출됩니다.

- **하위 개념(기반·전제):** [Tool](01_core_architecture.md#tool), [MCP](08_ai_llm_concepts.md#mcp),
  [Adapter Pattern](01_core_architecture.md#adapter-pattern)

### Long Task Tool
**클래스:** [Component](00_content_classes.md#component) · **한글:** 장기 작업 도구 · **코드:** `nanobot/agent/tools/long_task.py`

[Sustained Goal](03_memory_context_session.md#sustained-goal)을 세션 메타데이터에 등록하는
`LongTaskTool`과 완료를 기록하는 `CompleteGoalTool`. 활성 목표는 매 턴
[Runtime Context](03_memory_context_session.md#runtime-context)에 미러링되어, 이력이 압축되어도
"지금 무엇을 하던 중인지"가 사라지지 않습니다.

- **하위 개념(기반·전제):** [Tool](01_core_architecture.md#tool)
- **관련 용어:** [Goal State](03_memory_context_session.md#goal-state)

### Image Generation Tool
**클래스:** [Component](00_content_classes.md#component) · **한글:** 이미지 생성 도구 · **코드:** `nanobot/agent/tools/image_generation.py`

텍스트 프롬프트로 이미지를 생성하는 도구.
[Image Generation Provider](04_providers_and_llm.md#image-generation-provider)에 위임합니다.

- **하위 개념(기반·전제):** [Tool](01_core_architecture.md#tool)

### File State
**클래스:** [Component](00_content_classes.md#component) · **한글:** 파일 상태 추적 · **코드:** `nanobot/agent/tools/file_state.py`

파일 읽기 이력을 추적해 "읽지 않고 편집" 경고와 중복 읽기 감지를 제공하는 인프라 모듈
([_SKIP_MODULES](#_skip_modules) 대상). 모델의 부주의한 파일 조작을 절차적으로 견제합니다.

- **하위 개념(기반·전제):** [Filesystem Tools](#filesystem-tools)

### Path Utils
**클래스:** [Component](00_content_classes.md#component) · **한글:** 경로 유틸 · **코드:** `nanobot/agent/tools/path_utils.py`

워크스페이스 스코프 도구들이 공유하는 경로 헬퍼.
[Workspace Policy](07_security_isolation.md#workspace-policy) 경계 검사와 연동됩니다.

- **하위 개념(기반·전제):** [Filesystem Tools](#filesystem-tools)

### Tool Hint
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 도구 힌트

"지금 어떤 도구가 실행 중인지"를 UI에 실시간 표시하는 진행 신호.
[Progress Hook](01_core_architecture.md#progress-hook)을 타고
[WebUI](05_channels_gateway_ui.md#webui)로 전달됩니다 — 긴 턴에서 사용자가 "멈췄나?" 하고
불안해하지 않게 하는 UX 장치입니다.

- **하위 개념(기반·전제):** [Progress Hook](01_core_architecture.md#progress-hook)

### SkillsLoader
**클래스:** [Component](00_content_classes.md#component) · **한글:** 스킬 로더 · **코드:** `nanobot/agent/skills.py`

내장(`nanobot/skills/`)과 워크스페이스의 [Skill](01_core_architecture.md#skill)을 찾아 읽는 로더.
워크스페이스 스킬이 같은 이름의 내장 스킬을 오버라이드합니다(사용자 커스텀 우선).
`build_skills_summary()`로 **요약만** 컨텍스트에 넣습니다 —
[Progressive Disclosure](#progressive-disclosure)의 구현.

- **하위 개념(기반·전제):** [Skill](01_core_architecture.md#skill)

### SKILL.md
**클래스:** [Artifact](00_content_classes.md#artifact) · **코드:** `nanobot/skills/*/SKILL.md`

스킬 하나를 기술하는 마크다운 파일 형식 — [Frontmatter](#frontmatter) 메타데이터(이름, 한 줄 설명)
+ 본문 절차. Anthropic [Agent Skills](08_ai_llm_concepts.md#agent-skills) 규격과 같은 계열입니다.

- **하위 개념(기반·전제):** [Skill](01_core_architecture.md#skill), [Markdown](#markdown)
- **관련 용어:** [Frontmatter](#frontmatter)

### skill-creator
**클래스:** [Artifact](00_content_classes.md#artifact) · **코드:** `nanobot/skills/skill-creator/`

"새 스킬을 만드는 방법"을 기술한 내장 스킬 — 에이전트가 **스스로 능력을 확장**할 수 있게 하는
자기개선 장치. "스킬을 만드는 스킬"이라는 메타 구조가 핵심입니다
([Reflection](08_ai_llm_concepts.md#reflection), [Voyager](08_ai_llm_concepts.md#voyager) 계열).

- **하위 개념(기반·전제):** [Skill](01_core_architecture.md#skill),
  [Skill Library](08_ai_llm_concepts.md#skill-library)

### Progressive Disclosure
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 점진적 로딩

스킬 **요약(이름+한 줄)만 상시 컨텍스트에 넣고**, 본문은 필요할 때 파일 읽기로 로드하는 2단계 구조.

**예시:** 스킬 20개의 본문 전부(수만 토큰)를 항상 넣는 대신 요약 20줄만 넣고, 모델이 "github 스킬이
필요하겠다"고 판단하면 그때 `read_file`로 본문을 가져옵니다 —
[Context Window](08_ai_llm_concepts.md#context-window) 예산의 스킬 측 해법.

- **관련 용어:** [Context Compression](08_ai_llm_concepts.md#context-compression),
  [SkillsLoader](#skillsloader)

### Frontmatter
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 프런트매터

[Markdown](#markdown) 파일 맨 앞에 `---`로 구분해 넣는 구조화된 메타데이터 블록(YAML 형식).
본문(사람용 텍스트)과 메타데이터(기계용 필드)를 한 파일에 공존시키는 관행입니다.

**예시:** [SKILL.md](#skillmd)의 서두 —

```markdown
---
name: github
description: GitHub PR/이슈 작업 절차
---
# GitHub 스킬
...
```

- **상위 개념(이를 기반으로 파생):** [SKILL.md](#skillmd)
- **하위 개념(기반·전제):** [Markdown](#markdown)

### Markdown
**클래스:** [Technology](00_content_classes.md#technology) · **한글:** 마크다운 · **등장:** 2004 (Gruber & Swartz)

`#`, `-`, `**` 같은 간단한 기호로 서식을 표현하는 경량 마크업 언어. 사람이 읽고 쓰기 쉽고 LLM도 잘
다루기 때문에, nanobot은 기억([MEMORY.md](03_memory_context_session.md#memorymd)),
스킬([SKILL.md](#skillmd)), 프롬프트 템플릿을 모두 마크다운으로 저장합니다 —
"에이전트의 지식은 사람이 열어 볼 수 있는 텍스트"라는 설계 철학의 토대입니다.

- **상위 개념(이를 기반으로 파생):** [SKILL.md](#skillmd), [Frontmatter](#frontmatter),
  [Durable Files](03_memory_context_session.md#durable-files)
