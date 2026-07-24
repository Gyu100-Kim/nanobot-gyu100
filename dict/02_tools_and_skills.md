# 사전 02. 도구와 스킬 (Tools & Skills)

> [Tool](01_core_architecture.md#tool)/[Skill](01_core_architecture.md#skill) 계층의 세부 용어.
> 전체 색인은 [README](README.md)를 보세요.

---

### ToolRegistry
**한글:** 도구 레지스트리 · **분류:** 도구 인프라 · **코드:** `nanobot/agent/tools/registry.py`

등록된 모든 [Tool](01_core_architecture.md#tool)의 목록을 관리하고 이름으로 실행을 디스패치하는 중심 객체.
[MCPToolWrapper](#mcptoolwrapper)처럼 `mcp_` 접두 도구는 내장 도구 뒤로 정렬합니다.

- **상위 개념:** [Tool](01_core_architecture.md#tool)
- **하위 개념:** [Tool Discovery](#tool-discovery), [Tool Scope](#tool-scope)
- **관련 용어:** [AgentRunner](01_core_architecture.md#agentrunner)

### ToolResult
**한글:** 도구 실행 결과 · **분류:** 도구 인프라 · **코드:** `nanobot/agent/tools/base.py`

도구 실행의 표준 반환 객체(성공 내용 또는 `error`). 오류도 삼키지 않고 모델에게 텍스트로
돌려줘 스스로 다른 방법을 시도하게 합니다(self-correction).

- **상위 개념:** [Tool](01_core_architecture.md#tool)
- **관련 용어:** [Tool Calling](08_ai_llm_concepts.md#tool-calling)

### Tool Schema
**한글:** 도구 스키마 · **분류:** 도구 인프라 · **코드:** `nanobot/agent/tools/schema.py`

도구 파라미터를 [JSON Schema](08_ai_llm_concepts.md#json-schema)로 선언하기 위한 타입 클래스들
(`StringSchema`, `IntegerSchema`, `ObjectSchema` 등). `to_json_schema()`가 표준 dict를 만들어
[Provider](01_core_architecture.md#provider)에 전달됩니다.

- **상위 개념:** [Tool](01_core_architecture.md#tool)
- **관련 용어:** [JSON Schema](08_ai_llm_concepts.md#json-schema)

### Tool Discovery
**한글:** 도구 자동 발견 · **분류:** 도구 인프라 · **코드:** `nanobot/agent/tools/loader.py`

`tools/` 패키지를 [pkgutil](09_dev_stack.md#pkgutil)로 스캔해 도구 모듈을 자동 등록하는 메커니즘.
외부 패키지는 [Entry-point Plugin](#entry-point-plugin)으로 합류합니다.
[_SKIP_MODULES](#_skip_modules)에 있는 인프라 모듈은 제외됩니다.

- **상위 개념:** [ToolRegistry](#toolregistry)
- **하위 개념:** [_SKIP_MODULES](#_skip_modules), [Entry-point Plugin](#entry-point-plugin)

### _SKIP_MODULES
**분류:** 도구 인프라 · **코드:** `nanobot/agent/tools/loader.py`

[Tool Discovery](#tool-discovery)에서 제외되는 모듈 목록(`base`, `schema`, `registry`, `context`,
`loader`, `config`, `file_state`, `sandbox`, `mcp`, `runtime_state` 등) — 도구가 아닌 인프라이거나
([Sandbox](07_security_isolation.md#sandbox)), 특수 경로로 등록되는([MCPToolWrapper](#mcptoolwrapper)) 모듈들입니다.

- **상위 개념:** [Tool Discovery](#tool-discovery)

### Entry-point Plugin
**한글:** 엔트리포인트 플러그인 · **분류:** 도구 인프라

파이썬 패키징의 [Entry Points](09_dev_stack.md#entry-points) 규격(`nanobot.tools`, `nanobot.channels` 그룹)으로
외부 패키지가 도구/채널을 nanobot에 등록하는 방식. 코어 수정 없는 확장(`.agent/design.md` 원칙)의 수단입니다.

- **상위 개념:** [Tool Discovery](#tool-discovery)
- **관련 용어:** [Entry Points](09_dev_stack.md#entry-points)

### Tool Scope
**한글:** 도구 스코프 · **분류:** 도구 인프라

각 도구가 쓰일 수 있는 문맥(`core`, `subagent` 등)을 제한하는 속성(`_scopes`).
[Subagent](01_core_architecture.md#subagent)에게 위험한 도구를 주지 않는
[Least Privilege](07_security_isolation.md#least-privilege)의 적용입니다.

- **상위 개념:** [ToolRegistry](#toolregistry)

### ExecTool
**한글:** 셸 실행 도구 · **분류:** 도구 · **코드:** `nanobot/agent/tools/shell.py`

셸 명령을 실행하는 도구. [Sandbox Backend](07_security_isolation.md#sandbox-backend)로 명령을 감싸고
하드 [Timeout](07_security_isolation.md#timeout)(기본 60초)으로 폭주를 차단합니다.
Windows에서는 PowerShell(`pwsh` 우선)이 기본입니다.

- **상위 개념:** [Tool](01_core_architecture.md#tool)
- **관련 용어:** [bubblewrap](07_security_isolation.md#bubblewrap), [Exec Session](#exec-session)

### Exec Session
**한글:** 실행 세션 · **분류:** 도구 · **코드:** `nanobot/agent/tools/exec_session.py`

상태 유지형(interactive) 셸 세션 관리자(`ExecSessionManager`). 일회성 [ExecTool](#exectool)과 달리
프로세스를 살려 두고 [WriteStdinTool](#writestdintool)로 입력을 이어 보낼 수 있습니다.

- **상위 개념:** [ExecTool](#exectool)
- **하위 개념:** [WriteStdinTool](#writestdintool)

### WriteStdinTool
**분류:** 도구 · **코드:** `nanobot/agent/tools/exec_session.py`

살아 있는 [Exec Session](#exec-session) 프로세스의 표준입력에 텍스트/특수키를 쓰는 도구.
대화형 프로그램(REPL, 비밀번호 프롬프트) 제어에 쓰입니다.

- **상위 개념:** [Exec Session](#exec-session)

### Filesystem Tools
**한글:** 파일시스템 도구 · **분류:** 도구 · **코드:** `nanobot/agent/tools/filesystem.py`

파일 읽기/쓰기/편집/목록 도구 모음. 모든 경로는
[Workspace Policy](07_security_isolation.md#workspace-policy) 경계 검사를 거치며,
[File State](#file-state)로 "읽기 전 편집" 경고와 중복 읽기 감지를 합니다.

- **상위 개념:** [Tool](01_core_architecture.md#tool)
- **관련 용어:** [apply_patch](#apply_patch), [Path Utils](#path-utils)

### apply_patch
**한글:** 패치 적용 도구 · **분류:** 도구 · **코드:** `nanobot/agent/tools/apply_patch.py`

여러 파일 변경을 하나의 패치 텍스트로 기술해 원자적으로 적용하는 편집 도구.
줄 단위 편집보다 큰 변경에 적합합니다.

- **상위 개념:** [Filesystem Tools](#filesystem-tools)

### Web Tools
**한글:** 웹 도구 · **분류:** 도구 · **코드:** `nanobot/agent/tools/web.py`, `search.py`

URL 가져오기(fetch)와 웹 검색 도구. 검색은 [ddgs](09_dev_stack.md#ddgs)를 쓰고,
fetch는 [SSRF](07_security_isolation.md#ssrf) 방어와
[DNS Pinning](07_security_isolation.md#dns-pinning)을 거칩니다.

- **상위 개념:** [Tool](01_core_architecture.md#tool)
- **관련 용어:** [httpx](09_dev_stack.md#httpx)

### MessageTool
**한글:** 메시지 도구 · **분류:** 도구 · **코드:** `nanobot/agent/tools/message.py`

에이전트가 턴 도중 사용자에게 직접 메시지를 보내는 도구.
[Heartbeat](06_scheduling_automation.md#heartbeat) 실행 중에는 `set_suppress_delivery`로
전송이 억제됩니다(무의미한 알림 방지).

- **상위 개념:** [Tool](01_core_architecture.md#tool)

### SpawnTool
**한글:** 스폰 도구 · **분류:** 도구 · **코드:** `nanobot/agent/tools/spawn.py`

[Subagent](01_core_architecture.md#subagent)를 띄워 작업을 위임하는 도구.
긴 작업을 메인 대화에서 분리해 병렬로 처리할 수 있게 합니다.

- **상위 개념:** [Tool](01_core_architecture.md#tool), [Subagent](01_core_architecture.md#subagent)

### Cron Tool
**한글:** 크론 도구 · **분류:** 도구 · **코드:** `nanobot/agent/tools/cron.py`

에이전트가 스스로 [Cron Job](06_scheduling_automation.md#cron-job)을 등록/삭제하는 도구.
"매일 아침 9시에 알려줘" 같은 요청을 실제 스케줄로 만듭니다.

- **상위 개념:** [Tool](01_core_architecture.md#tool), [Cron](06_scheduling_automation.md#cron)

### MyTool
**한글:** 자기 관리 도구 · **분류:** 도구 · **코드:** `nanobot/agent/tools/self.py`

에이전트가 자기 자신의 런타임 상태를 조회/조작하는 도구.
[Runtime State Protocol](#runtime-state-protocol)을 통해 [AgentLoop](01_core_architecture.md#agentloop)
상태에 접근합니다.

- **상위 개념:** [Tool](01_core_architecture.md#tool)
- **관련 용어:** [Runtime State Protocol](#runtime-state-protocol)

### MCPToolWrapper
**분류:** 도구 · **코드:** `nanobot/agent/tools/mcp.py`

[MCP](08_ai_llm_concepts.md#mcp) 서버가 제공하는 원격 도구를 nanobot [Tool](01_core_architecture.md#tool)
인터페이스로 감싸는 래퍼. 도구 이름에 `mcp_<server>_` 접두를 붙이고,
[stdio Transport](08_ai_llm_concepts.md#stdio-transport)와 HTTP/[SSE](08_ai_llm_concepts.md#sse)를 지원하며,
[PinnedDNSAsyncTransport](07_security_isolation.md#pinneddnsasynctransport)로 원격 연결을 보호합니다.

- **상위 개념:** [Tool](01_core_architecture.md#tool), [MCP](08_ai_llm_concepts.md#mcp)

### Long Task Tool
**한글:** 장기 작업 도구 · **분류:** 도구 · **코드:** `nanobot/agent/tools/long_task.py`

[Sustained Goal](03_memory_context_session.md#sustained-goal)을 세션 메타데이터에 등록하는
`LongTaskTool`과 종료를 기록하는 `CompleteGoalTool`. 활성 목표는 매 턴
[Runtime Context](03_memory_context_session.md#runtime-context)에 미러링되어 압축 후에도 유지됩니다.

- **상위 개념:** [Tool](01_core_architecture.md#tool)
- **관련 용어:** [Goal State](03_memory_context_session.md#goal-state)

### Image Generation Tool
**한글:** 이미지 생성 도구 · **분류:** 도구 · **코드:** `nanobot/agent/tools/image_generation.py`

텍스트 프롬프트로 이미지를 생성하는 도구.
[Image Generation Provider](04_providers_and_llm.md#image-generation-provider)에 위임합니다.

- **상위 개념:** [Tool](01_core_architecture.md#tool)

### File State
**한글:** 파일 상태 추적 · **분류:** 도구 인프라 · **코드:** `nanobot/agent/tools/file_state.py`

파일 읽기 이력을 추적해 "읽지 않고 편집" 경고와 중복 읽기 감지를 제공하는 인프라 모듈
([_SKIP_MODULES](#_skip_modules) 대상).

- **상위 개념:** [Filesystem Tools](#filesystem-tools)

### Path Utils
**한글:** 경로 유틸 · **분류:** 도구 인프라 · **코드:** `nanobot/agent/tools/path_utils.py`

워크스페이스 스코프 도구들이 공유하는 경로 헬퍼.
[Workspace Policy](07_security_isolation.md#workspace-policy) 경계 검사와 연동됩니다.

- **상위 개념:** [Filesystem Tools](#filesystem-tools)

### Runtime State Protocol
**분류:** 도구 인프라 · **코드:** `nanobot/agent/tools/runtime_state.py`

[AgentLoop](01_core_architecture.md#agentloop) 상태를 [MyTool](#mytool)에 노출하는 파이썬 Protocol
(구조적 타이핑 인터페이스). 도구가 루프 구현에 직접 의존하지 않게 하는 경계입니다.

- **상위 개념:** [MyTool](#mytool)

### Tool Hint
**한글:** 도구 힌트 · **분류:** 도구 인프라

"지금 어떤 도구가 실행 중인지"를 UI에 실시간 표시하는 진행 신호.
[Progress Hook](01_core_architecture.md#progress-hook)을 타고
[WebUI](05_channels_gateway_ui.md#webui)로 전달됩니다.

- **상위 개념:** [Progress Hook](01_core_architecture.md#progress-hook)

### SkillsLoader
**한글:** 스킬 로더 · **분류:** 스킬 · **코드:** `nanobot/agent/skills.py`

내장([`nanobot/skills/`](#skillmd))과 워크스페이스의 [Skill](01_core_architecture.md#skill)을 찾아 읽는 로더.
워크스페이스 스킬이 같은 이름의 내장 스킬을 오버라이드합니다.
`build_skills_summary()`로 요약만 컨텍스트에 넣습니다([Progressive Disclosure](#progressive-disclosure)).

- **상위 개념:** [Skill](01_core_architecture.md#skill)

### SKILL.md
**분류:** 스킬 · **코드:** `nanobot/skills/*/SKILL.md`

스킬 하나를 기술하는 마크다운 파일 형식(frontmatter 메타데이터 + 본문 절차).
Anthropic [Agent Skills](08_ai_llm_concepts.md#agent-skills) 규격과 같은 계열입니다.

- **상위 개념:** [Skill](01_core_architecture.md#skill)

### skill-creator
**분류:** 스킬 · **코드:** `nanobot/skills/skill-creator/`

"새 스킬을 만드는 방법"을 기술한 내장 스킬 — 에이전트가 **스스로 능력을 확장**할 수 있게 하는
자기개선 장치입니다([Reflection](08_ai_llm_concepts.md#reflection),
[Voyager](08_ai_llm_concepts.md#voyager) 계열 아이디어).

- **상위 개념:** [Skill](01_core_architecture.md#skill)

### Progressive Disclosure
**한글:** 점진적 로딩 · **분류:** 스킬

스킬 **요약(이름+한 줄)만 상시 컨텍스트에 넣고**, 본문은 필요할 때 파일 읽기로 로드하는 2단계 구조.
[Context Window](08_ai_llm_concepts.md#context-window) 예산을 아끼는 스킬 측의 해법입니다.

- **상위 개념:** [Skill](01_core_architecture.md#skill)
- **관련 용어:** [Context Compression](08_ai_llm_concepts.md#context-compression)
