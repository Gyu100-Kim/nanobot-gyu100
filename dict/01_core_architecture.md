# 사전 01. 코어 아키텍처 (Core Architecture)

> nanobot의 뼈대를 이루는 용어들: 메시지가 들어와서 답이 나가기까지의 경로에 등장하는 구성요소와
> 그 바탕이 되는 설계 패턴. 전체 색인은 [README](README.md), 노드 클래스 정의는
> [00_content_classes.md](00_content_classes.md)를 보세요.
>
> 표기 규약: **상위 개념 = 이 개념을 기반(전제)으로 만들어진 파생 개념**, **하위 개념 = 이 개념을 규정하기 위해 필요한 기반/전제 개념**.

---

### Agent
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 에이전트

[LLM](08_ai_llm_concepts.md#llm)이 [Tool](#tool)을 호출하며 목표를 향해 여러 단계를 스스로 수행하는
소프트웨어. 단순 챗봇이 "질문 → 한 번의 답변"으로 끝난다면, 에이전트는 "관찰 → 판단 → 행동 →
결과 확인"의 [에이전트 루프](08_ai_llm_concepts.md#agent-loop-concept)를 목표 달성까지 반복합니다.

**예시:** "내 워크스페이스의 파이썬 파일 개수를 세줘"라는 요청에 대해, 에이전트는
① 셸 도구로 `find . -name "*.py" | wc -l` 실행을 요청하고 ② 결과(예: `42`)를 관찰한 뒤
③ "42개입니다"라고 답합니다 — 모델 혼자서는 알 수 없는 사실을 도구로 알아낸 것입니다.
nanobot 자체가 하나의 에이전트 프레임워크이고, [Subagent](#subagent)나
[Nanobot 파사드](#nanobot-sdk-facade)로 감싼 인스턴스는 에이전트의 더 특수한 형태입니다.

- **상위 개념(이를 기반으로 파생):** [AgentLoop](#agentloop), [Subagent](#subagent),
  [Nanobot (SDK Facade)](#nanobot-sdk-facade)
- **관련 용어:** [Tool Calling](08_ai_llm_concepts.md#tool-calling), [ReAct](08_ai_llm_concepts.md#react),
  [Session](#session)

### AgentLoop
**클래스:** [Component](00_content_classes.md#component) · **한글:** 에이전트 루프(클래스) · **코드:** `nanobot/agent/loop.py`

메시지 단위의 **바깥 턴 [State Machine](#state-machine)**. [MessageBus](#messagebus)에서
[InboundMessage](#inboundmessage)를 소비해 [Session Key](#session-key)를 결정하고,
[Context](03_memory_context_session.md#context)를 구축한 뒤 [AgentRunner](#agentrunner)에게 실행을
맡기고, 결과를 [OutboundMessage](#outboundmessage)로 발행합니다.

**예시:** Telegram에서 "안녕"이 도착하면 → 세션 키 `telegram:12345` 결정 → 이력·메모리·스킬 요약으로
컨텍스트 구축 → 러너 실행 → 응답을 Telegram 채널로 발행 — 이 한 바퀴가 AgentLoop의 한 [Turn](#turn)입니다.
`.agent/design.md`의 제약상 이 파일과 `runner.py`는 "핵심 경로"로, 변경을 최소화해야 합니다.

- **상위 개념(이를 기반으로 파생):** [TurnState](#turnstate), [Hook](#hook)
- **하위 개념(기반·전제):** [Agent](#agent), [State Machine](#state-machine),
  [Agent Loop (concept)](08_ai_llm_concepts.md#agent-loop-concept)
- **관련 용어:** [AgentRunner](#agentrunner), [MessageBus](#messagebus),
  [Runtime Checkpoint](#runtime-checkpoint)

### AgentRunner
**클래스:** [Component](00_content_classes.md#component) · **한글:** 에이전트 러너 · **코드:** `nanobot/agent/runner.py`

한 [Turn](#turn) 안에서 "[Provider](#provider) 호출 → [Tool](#tool) 실행 → 결과 반영 → 재호출"을
반복하는 **안쪽 루프**. [Streaming](04_providers_and_llm.md#streaming) 델타 처리, 반복 상한,
[Injection](#injection) 처리를 담당합니다. [AgentLoop](#agentloop)가 "무엇을 보여줄지"를 준비한다면,
러너는 "모델과의 실제 대화"를 굴립니다.

**예시:** 모델이 `read_file` 호출을 요청 → 러너가 [ToolRegistry](02_tools_and_skills.md#toolregistry)로
실행 → 파일 내용을 tool result 메시지로 추가 → 모델 재호출 → 모델이 최종 답 생성 → 턴 종료.

- **하위 개념(기반·전제):** [Agent Loop (concept)](08_ai_llm_concepts.md#agent-loop-concept)
- **상위 개념(이를 기반으로 파생):** [Injection](#injection)
- **관련 용어:** [Tool Calling](08_ai_llm_concepts.md#tool-calling), [Delta](04_providers_and_llm.md#delta)

### State Machine
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 상태머신

시스템이 가질 수 있는 **상태(state)의 유한한 집합**과 상태 간 **전이(transition) 규칙**으로 동작을
기술하는 모델. "지금 어느 상태인가"만 알면 다음에 무엇을 해야 하는지가 결정되므로, 복잡한 흐름을
추적·복구 가능하게 만듭니다.

**예시:** [AgentLoop](#agentloop)의 [TurnState](#turnstate)(RESTORE → BUILD → RUN → SAVE)와
[Circuit Breaker](04_providers_and_llm.md#circuit-breaker)(Closed → Open → Half-open)가
이 사전에 등장하는 대표적 상태머신입니다.

- **상위 개념(이를 기반으로 파생):** [TurnState](#turnstate), [Circuit Breaker](04_providers_and_llm.md#circuit-breaker)

### MessageBus
**클래스:** [Component](00_content_classes.md#component) · **한글:** 메시지 버스 · **코드:** `nanobot/bus/queue.py`

[Channel](#channel)과 에이전트 코어를 [Decoupling](#decoupling)하는 비동기 버스.
inbound/outbound 두 개의 [asyncio.Queue](09_dev_stack.md#asyncioqueue)를 갖고, 채널은 발행만,
[AgentLoop](#agentloop)는 소비만 하므로 서로의 구현을 몰라도 됩니다 —
[Producer-Consumer](#producer-consumer) 패턴의 적용입니다.

**예시:** Telegram 채널과 Discord 채널이 동시에 메시지를 발행해도, 에이전트 코어는 "어느 플랫폼에서
왔는지"와 무관하게 [InboundMessage](#inboundmessage)라는 동일한 형태로 하나씩 꺼내 처리합니다.

- **상위 개념(이를 기반으로 파생):** [InboundMessage](#inboundmessage), [OutboundMessage](#outboundmessage)
- **하위 개념(기반·전제):** [Producer-Consumer](#producer-consumer), [Decoupling](#decoupling)
- **관련 용어:** [asyncio](09_dev_stack.md#asyncio)

### Producer-Consumer
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 생산자-소비자 패턴

생산자는 큐에 넣기만 하고 소비자는 큐에서 꺼내기만 하는 동시성 패턴. 양쪽이 서로를 기다리지 않아도
되고(속도 차 흡수), 서로의 존재를 몰라도 됩니다. 큐가 완충재(buffer) 역할을 합니다.

**예시:** [MessageBus](#messagebus)에서 채널(생산자)과 [AgentLoop](#agentloop)(소비자)의 관계.

- **상위 개념(이를 기반으로 파생):** [MessageBus](#messagebus)
- **관련 용어:** [asyncio.Queue](09_dev_stack.md#asyncioqueue), [Decoupling](#decoupling)

### Decoupling
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 결합도 낮추기(분리)

구성요소들이 서로의 내부 구현을 모르게 하여, 한쪽의 변경이 다른 쪽에 파급되지 않게 하는 설계 원칙.
중간에 표준화된 인터페이스(큐, 이벤트, 추상 클래스)를 끼워 실현합니다.

**예시:** nanobot에서 새 채팅 플랫폼을 추가할 때 에이전트 코어를 한 줄도 고치지 않아도 되는 이유 —
[MessageBus](#messagebus)와 [Channel](#channel) 추상화가 코어와 플랫폼을 분리하기 때문입니다.

- **상위 개념(이를 기반으로 파생):** [MessageBus](#messagebus), [Adapter Pattern](#adapter-pattern),
  [Provider](#provider)

### Adapter Pattern
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 어댑터 패턴

호환되지 않는 인터페이스를 가진 외부 시스템을, 내가 원하는 표준 인터페이스로 **변환해 끼우는** 패턴
(GoF 디자인 패턴). 외부의 다양성을 경계에서 흡수하고 내부는 단일 형태만 다루게 합니다.

**예시:** [Channel](#channel)은 "Telegram API ↔ [InboundMessage](#inboundmessage)" 변환 어댑터이고,
[Provider](#provider)는 "각 벤더 SDK ↔ 공통 채팅 인터페이스" 변환 어댑터입니다.

- **상위 개념(이를 기반으로 파생):** [Channel](#channel), [Provider](#provider)
- **하위 개념(기반·전제):** [Decoupling](#decoupling)

### Facade Pattern
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 파사드 패턴

복잡한 내부 서브시스템을 **간단한 단일 진입 객체** 뒤에 숨기는 패턴(GoF). 사용자는 파사드의 몇 개
메서드만 알면 되고, 내부의 여러 구성요소 조립은 파사드가 대신합니다.

**예시:** [Nanobot (SDK Facade)](#nanobot-sdk-facade) — `Nanobot.from_config()` 한 줄이 내부적으로
설정 로드, [Provider](#provider) 생성, [AgentLoop](#agentloop) 구성을 모두 수행합니다.

- **상위 개념(이를 기반으로 파생):** [Nanobot (SDK Facade)](#nanobot-sdk-facade)

### InboundMessage
**클래스:** [Component](00_content_classes.md#component) · **한글:** 인바운드 메시지 · **코드:** `nanobot/bus/events.py`

외부 플랫폼에서 들어온 사용자 메시지를 표준화한 이벤트 객체(채널명, chat_id, sender_id, 본문, 미디어).
모든 [Channel](#channel)이 자기 플랫폼의 메시지를 이 형태로 변환해 [MessageBus](#messagebus)에
발행하므로, 코어는 플랫폼 차이를 모릅니다. [Pydantic](09_dev_stack.md#pydantic) 모델이라
필드 누락/타입 오류가 생성 시점에 잡힙니다.

- **하위 개념(기반·전제):** [MessageBus](#messagebus)
- **관련 용어:** [OutboundMessage](#outboundmessage), [Session Key](#session-key)

### OutboundMessage
**클래스:** [Component](00_content_classes.md#component) · **한글:** 아웃바운드 메시지 · **코드:** `nanobot/bus/events.py`

에이전트의 응답을 표준화한 이벤트 객체. [MessageBus](#messagebus)를 거쳐 원래 [Channel](#channel)이
플랫폼별 형식(Telegram 마크다운, Slack 블록 등)으로 변환해 전송합니다.

- **하위 개념(기반·전제):** [MessageBus](#messagebus)
- **관련 용어:** [InboundMessage](#inboundmessage)

### Turn
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 턴

사용자 메시지 하나에 대한 요청-응답 한 사이클. 한 턴 안에서 [AgentRunner](#agentrunner)가 여러 번의
[LLM](08_ai_llm_concepts.md#llm) 호출과 [Tool](#tool) 실행을 반복할 수 있습니다 —
"턴 1개 = LLM 호출 N개"일 수 있다는 점이 단순 챗봇과의 차이입니다.

**예시:** "이 저장소 요약해줘" 한 마디(1턴)에 대해 내부적으로는 `list_dir` → `read_file` × 3 →
최종 요약 생성으로 LLM 호출이 5번 일어날 수 있습니다.

- **상위 개념(이를 기반으로 파생):** [TurnState](#turnstate), [Turn Continuation](#turn-continuation),
  [Cron Turns](06_scheduling_automation.md#cron-turns)
- **관련 용어:** [Session](#session)

### TurnState
**클래스:** [Component](00_content_classes.md#component) · **한글:** 턴 상태 · **코드:** `nanobot/agent/loop.py`

한 [Turn](#turn)의 진행 단계를 나타내는 [State Machine](#state-machine) 국면:
RESTORE(이전 상태 복원) → BUILD(컨텍스트 구축) → RUN(러너 실행) → SAVE(저장).
크래시 시 어느 단계까지 갔는지 알 수 있어 [Runtime Checkpoint](#runtime-checkpoint) 복구의 기준이 됩니다.

- **하위 개념(기반·전제):** [Turn](#turn), [State Machine](#state-machine)
- **관련 용어:** [Runtime Checkpoint](#runtime-checkpoint)

### Session
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 세션 · **코드:** `nanobot/session/manager.py`

하나의 대화 맥락과 그 이력. "어제 하던 이야기"를 이어가려면 어딘가에 대화가 저장되어 있어야 하는데,
그 저장 단위가 세션입니다. nanobot은 세션을 [JSONL](03_memory_context_session.md#jsonl) 파일
(`<workspace>/sessions/*.jsonl`)로 저장합니다 — SQLite 같은 DB가 아니라 사람이 열어 볼 수 있는
텍스트 파일입니다.

- **상위 개념(이를 기반으로 파생):** [Session Key](#session-key), [Unified Session](#unified-session),
  [Session Manager](03_memory_context_session.md#session-manager)
- **관련 용어:** [Workspace](#workspace), [AutoCompact](03_memory_context_session.md#autocompact)

### Session Key
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 세션 키 · **코드:** `nanobot/session/keys.py`

세션을 식별하는 문자열. 채널·chat_id 조합으로 결정되며, 같은 키의 메시지는 같은 대화 이력을 공유합니다.

**예시:** Telegram 개인 대화는 `telegram:12345`, SDK 기본 세션은 `sdk:default`,
[Heartbeat](06_scheduling_automation.md#heartbeat)는 전용 키 `heartbeat`를 씁니다.

- **하위 개념(기반·전제):** [Session](#session)
- **관련 용어:** [Unified Session](#unified-session), [InboundMessage](#inboundmessage)

### Unified Session
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 통합 세션

여러 [Channel](#channel)이 **하나의 세션 키를 공유**해 대화 이력을 이어가는 기능.

**예시:** 출근길에 Telegram으로 시킨 일을 사무실에서 [WebUI](05_channels_gateway_ui.md#webui)로 열면
같은 대화가 이어집니다 — "어디서 말 걸어도 같은 비서"를 만드는 장치입니다.

- **하위 개념(기반·전제):** [Session](#session)
- **관련 용어:** [Session Key](#session-key), [Channel](#channel)

### Workspace
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 워크스페이스 · **코드:** 기본 `~/.nanobot/workspace/`

에이전트의 홈 디렉토리. 세션([JSONL](03_memory_context_session.md#jsonl)),
[Memory](03_memory_context_session.md#memory), [Skill](#skill),
[Cron Store](06_scheduling_automation.md#cron-store)가 이 아래에 있으며, 파일 도구와
[Sandbox](07_security_isolation.md#sandbox)의 접근 경계이기도 합니다 — "에이전트의 집이자 울타리".

- **관련 용어:** [Workspace Policy](07_security_isolation.md#workspace-policy),
  [Durable Files](03_memory_context_session.md#durable-files)

### Channel
**클래스:** [Component](00_content_classes.md#component) · **한글:** 채널 · **코드:** `nanobot/channels/base.py`

외부 메시징 플랫폼과 nanobot을 잇는 [Adapter Pattern](#adapter-pattern) 구현. 플랫폼 메시지 ↔
[InboundMessage](#inboundmessage)/[OutboundMessage](#outboundmessage) 변환을 담당합니다.
[Tool Discovery](02_tools_and_skills.md#tool-discovery)와 같은 방식([pkgutil](09_dev_stack.md#pkgutil)
스캔 + [Entry-point Plugin](02_tools_and_skills.md#entry-point-plugin))으로 자동 등록됩니다.

- **상위 개념(이를 기반으로 파생):** [Platform Channels](05_channels_gateway_ui.md#platform-channels),
  [WebSocket Channel](05_channels_gateway_ui.md#websocket-channel),
  [Channel Manager](05_channels_gateway_ui.md#channel-manager)
- **하위 개념(기반·전제):** [Adapter Pattern](#adapter-pattern)
- **관련 용어:** [Gateway](#gateway), [Pairing](#pairing)

### Gateway
**클래스:** [Component](00_content_classes.md#component) · **한글:** 게이트웨이 · **코드:** `nanobot/gateway/`

`nanobot gateway` 명령으로 뜨는 **장기 실행 오케스트레이터**. 모든 [Channel](#channel),
[CronService](06_scheduling_automation.md#cronservice), [AgentLoop](#agentloop),
[WebUI](05_channels_gateway_ui.md#webui)를 한 프로세스에서 구동합니다. 상시 대기하는 비서를 만들려면
이 프로세스가 계속 떠 있어야 합니다.

- **상위 개념(이를 기반으로 파생):** [Gateway Service](05_channels_gateway_ui.md#gateway-service),
  [Health Endpoint](05_channels_gateway_ui.md#health-endpoint)
- **관련 용어:** [Channel](#channel), [Cron](06_scheduling_automation.md#cron)

### Provider
**클래스:** [Component](00_content_classes.md#component) · **한글:** 프로바이더 · **코드:** `nanobot/providers/base.py`

[LLM](08_ai_llm_concepts.md#llm) 백엔드의 공통 추상화 — "메시지 목록과 도구 목록을 주면 응답/도구
호출을 돌려주는" 인터페이스. 어떤 벤더든 같은 방식으로 갈아끼울 수 있게 하는
[Adapter Pattern](#adapter-pattern)입니다.

**예시:** 설정에서 모델명만 `claude-...` → `gpt-...`로 바꾸면, 코어 코드 변경 없이
[Anthropic Provider](04_providers_and_llm.md#anthropic-provider) 대신
[OpenAI-Compatible Provider](04_providers_and_llm.md#openai-compatible-provider)가 선택됩니다.

- **상위 개념(이를 기반으로 파생):** [Provider Base](04_providers_and_llm.md#provider-base),
  [FallbackProvider](04_providers_and_llm.md#fallbackprovider),
  [Provider Registry](04_providers_and_llm.md#provider-registry)
- **하위 개념(기반·전제):** [Adapter Pattern](#adapter-pattern)
- **관련 용어:** [Model Preset](#model-preset), [Model Routing](08_ai_llm_concepts.md#model-routing)

### Tool
**클래스:** [Component](00_content_classes.md#component) · **한글:** 도구 · **코드:** `nanobot/agent/tools/base.py`

[LLM](08_ai_llm_concepts.md#llm)이 호출할 수 있는 능력 단위. 이름·설명·파라미터
[Tool Schema](02_tools_and_skills.md#tool-schema)를 선언하고 `execute()`를 구현하면,
모델이 그 설명을 읽고 필요할 때 호출을 요청합니다.

**예시:** 파일을 읽는 `read_file`, 셸을 실행하는 [ExecTool](02_tools_and_skills.md#exectool),
웹을 검색하는 [Web Tools](02_tools_and_skills.md#web-tools) — 각각이 Tool의 더 특수한 사례입니다.

- **상위 개념(이를 기반으로 파생):** [ExecTool](02_tools_and_skills.md#exectool),
  [Filesystem Tools](02_tools_and_skills.md#filesystem-tools),
  [MCPToolWrapper](02_tools_and_skills.md#mcptoolwrapper), [SpawnTool](02_tools_and_skills.md#spawntool)
- **관련 용어:** [Tool Calling](08_ai_llm_concepts.md#tool-calling),
  [ToolRegistry](02_tools_and_skills.md#toolregistry)

### Skill
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 스킬 · **코드:** `nanobot/agent/skills.py`, `nanobot/skills/`

코드가 아니라 **마크다운([SKILL.md](02_tools_and_skills.md#skillmd))** 로 기술된 작업 절차/지식.
[Tool](#tool)이 "할 수 있는 것"(능력)이라면 스킬은 "하는 방법"(노하우)입니다.

**예시:** `github` 스킬은 "PR을 만들 때 이런 순서로 이런 명령을 써라"라는 절차 문서이고,
실제 명령 실행은 [ExecTool](02_tools_and_skills.md#exectool)이 합니다.

- **상위 개념(이를 기반으로 파생):** [SkillsLoader](02_tools_and_skills.md#skillsloader),
  [SKILL.md](02_tools_and_skills.md#skillmd), [skill-creator](02_tools_and_skills.md#skill-creator)
- **하위 개념(기반·전제):** [Skill Library](08_ai_llm_concepts.md#skill-library)
- **관련 용어:** [Progressive Disclosure](02_tools_and_skills.md#progressive-disclosure)

### Subagent
**클래스:** [Component](00_content_classes.md#component) · **한글:** 서브에이전트 · **코드:** `nanobot/agent/tools/spawn.py`

메인 에이전트가 [SpawnTool](02_tools_and_skills.md#spawntool)로 띄우는 **격리된 배경 작업자**.
자체 대화와 제한된 [Tool Scope](02_tools_and_skills.md#tool-scope)를 갖고, 완료 결과만 부모에게
보고합니다. 긴 작업을 메인 대화를 막지 않고 처리하는 수단입니다.

- **하위 개념(기반·전제):** [Agent](#agent)
- **관련 용어:** [SpawnTool](02_tools_and_skills.md#spawntool),
  [Least Privilege](07_security_isolation.md#least-privilege)

### Hook
**클래스:** [Component](00_content_classes.md#component) · **한글:** 훅 · **코드:** `nanobot/agent/hook.py`

턴 진행의 특정 지점(시작/도구 실행/완료)에 끼어들 수 있는 확장점. "프레임워크가 내 코드를 불러주는"
제어 역전(Inversion of Control) 방식으로, [SDK](05_channels_gateway_ui.md#sdk-clients) 사용자가
코어 수정 없이 커스텀 동작을 주입할 수 있습니다.

- **상위 개념(이를 기반으로 파생):** [Progress Hook](#progress-hook)
- **하위 개념(기반·전제):** [AgentLoop](#agentloop)

### Progress Hook
**클래스:** [Component](00_content_classes.md#component) · **한글:** 진행 훅 · **코드:** `nanobot/agent/progress_hook.py`

턴 진행 상황(어떤 도구를 실행 중인지 등)을 실시간으로 밖에 알리는 [Hook](#hook)의 특수화.
[WebUI](05_channels_gateway_ui.md#webui)의 [Tool Hint](02_tools_and_skills.md#tool-hint) 표시가
이를 사용합니다.

- **하위 개념(기반·전제):** [Hook](#hook)

### Injection
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 인젝션(메시지 주입) · **코드:** `nanobot/agent/runner.py`

에이전트가 아직 턴을 도는 **도중에** 도착한 사용자 메시지를 진행 중인 대화에 끼워 넣는 기능.

**예시:** 에이전트가 파일 정리를 하는 중에 사용자가 "아, `.bak` 파일은 빼줘"라고 보내면, 턴을 끝내고
다시 시작하는 대신 진행 중인 대화에 그 지시가 주입됩니다. `_MAX_INJECTIONS_PER_TURN` 같은 상한으로
무한 연장을 방지합니다. (보안 용어 [Prompt Injection](07_security_isolation.md#prompt-injection)과는
전혀 다른 개념입니다.)

- **하위 개념(기반·전제):** [AgentRunner](#agentrunner)

### Turn Continuation
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 턴 이어가기 · **코드:** `nanobot/session/turn_continuation.py`

반복 상한 등으로 중단된 턴을 다음 요청에서 이어서 진행할 수 있게 하는 메커니즘. 긴 작업이 상한에
걸려도 "처음부터 다시"가 아니라 "멈춘 곳부터"가 가능해집니다.

- **하위 개념(기반·전제):** [Turn](#turn)
- **관련 용어:** [Runtime Checkpoint](#runtime-checkpoint)

### Runtime Checkpoint
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 런타임 체크포인트

턴 도중 상태를 저장해 크래시 후 복구할 수 있게 하는 영속화 장치. [TurnState](#turnstate)의 단계
정보와 함께, "저장 안 된 진행분"이 통째로 날아가는 것을 막습니다.

- **관련 용어:** [TurnState](#turnstate), [Turn Continuation](#turn-continuation),
  [Atomic Write](03_memory_context_session.md#atomic-write)

### Command Router
**클래스:** [Component](00_content_classes.md#component) · **한글:** 커맨드 라우터 · **코드:** `nanobot/command/`

`/`로 시작하는 [Slash Command](#slash-command)를 LLM에 보내지 않고 직접 처리하는 라우터.
결정적(deterministic)이어야 하는 조작(세션 초기화 등)을 모델의 변덕에서 분리합니다.

- **상위 개념(이를 기반으로 파생):** [Slash Command](#slash-command)

### Slash Command
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 슬래시 커맨드 · **코드:** `nanobot/command/`

`/new`, `/help`처럼 채팅에서 바로 실행되는 내장 명령. [LLM](08_ai_llm_concepts.md#llm) 호출 없이
[Command Router](#command-router)가 처리하므로 빠르고, 항상 같은 결과를 냅니다.

- **하위 개념(기반·전제):** [Command Router](#command-router)

### Pairing
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 페어링 · **코드:** `nanobot/pairing/`

모르는 사람의 DM에 에이전트가 응답하지 않도록, 채널별 **페어링 코드**로 발신자를 승인하는 절차와
그 저장소. 개인 비서가 아무에게나 대답하면 안 되기 때문입니다.

- **관련 용어:** [Channel](#channel)

### Config
**클래스:** [Component](00_content_classes.md#component) · **한글:** 설정 · **코드:** `nanobot/config/schema.py`, `loader.py`

`~/.nanobot/config.json`에서 로드되는 [Pydantic](09_dev_stack.md#pydantic) 기반 설정. JSON 관행을
위한 [camelCase Alias](09_dev_stack.md#camelcase-alias)를 지원하고, `${VAR}` 패턴은 로드 시
환경변수로 치환됩니다(없으면 `ValueError` — 조용한 오설정 방지).

- **상위 개념(이를 기반으로 파생):** [Model Preset](#model-preset)
- **관련 용어:** [Pydantic](09_dev_stack.md#pydantic), [Workspace](#workspace)

### Model Preset
**클래스:** [Component](00_content_classes.md#component) · **한글:** 모델 프리셋 · **코드:** `nanobot/agent/model_presets.py`

"이 용도에는 이 프로바이더의 이 모델과 이 파라미터"를 묶어 이름 붙인 설정 단위 — 수동
[Model Routing](08_ai_llm_concepts.md#model-routing)의 수단.

**예시:** 대화용에는 큰 모델, [Dream](03_memory_context_session.md#dream) 같은 배경 작업에는 싸고
빠른 모델을 프리셋으로 지정해 비용을 조절할 수 있습니다.

- **하위 개념(기반·전제):** [Config](#config), [Model Routing](08_ai_llm_concepts.md#model-routing)
- **관련 용어:** [Temperature](04_providers_and_llm.md#temperature)

### Nanobot (SDK Facade)
**클래스:** [Component](00_content_classes.md#component) · **한글:** Nanobot 파사드 · **코드:** `nanobot/nanobot.py`

nanobot을 파이썬 라이브러리로 임베드하기 위한 진입점 클래스 — [Facade Pattern](#facade-pattern)의
구현. `Nanobot.from_config()`으로 만들고 `await bot.run("...")`으로 한 턴을 실행합니다.

```python
bot = Nanobot.from_config()
result = await bot.run("Summarize this repo")
print(result.content)
```

- **하위 개념(기반·전제):** [Agent](#agent), [Facade Pattern](#facade-pattern)
- **관련 용어:** [SDK Clients](05_channels_gateway_ui.md#sdk-clients), [AgentLoop](#agentloop)
