# 사전 01. 코어 아키텍처 (Core Architecture)

> nanobot의 뼈대를 이루는 용어들: 메시지가 들어와서 답이 나가기까지의 경로에 등장하는 구성요소.
> 전체 색인은 [README](README.md)를 보세요.

---

### Agent
**한글:** 에이전트 · **분류:** 코어

[LLM](08_ai_llm_concepts.md#llm)이 [Tool](#tool)을 호출하며 목표를 향해 여러 단계를 스스로 수행하는 소프트웨어.
단순 챗봇과 달리 "관찰 → 판단 → 행동"의 [에이전트 루프](08_ai_llm_concepts.md#agent-loop-concept)를 돕니다.
nanobot 자체가 하나의 에이전트 프레임워크입니다.

- **하위 개념:** [AgentLoop](#agentloop), [Tool](#tool), [Session](#session)
- **관련 용어:** [Tool Calling](08_ai_llm_concepts.md#tool-calling), [ReAct](08_ai_llm_concepts.md#react)

### AgentLoop
**한글:** 에이전트 루프(클래스) · **분류:** 코어 · **코드:** `nanobot/agent/loop.py`

메시지 단위의 **바깥 턴 상태머신**. [MessageBus](#messagebus)에서 [InboundMessage](#inboundmessage)를 소비해
[Session Key](#session-key)를 결정하고, [Context](03_memory_context_session.md#context)를 구축한 뒤
[AgentRunner](#agentrunner)에게 실행을 맡기고, 결과를 [OutboundMessage](#outboundmessage)로 발행합니다.
`.agent/design.md`의 제약상 이 파일과 `runner.py`는 "핵심 경로"로, 변경을 최소화해야 합니다.

- **상위 개념:** [Agent](#agent)
- **하위 개념:** [AgentRunner](#agentrunner), [Turn](#turn), [TurnState](#turnstate), [Hook](#hook)
- **관련 용어:** [MessageBus](#messagebus), [Session](#session), [Nanobot (SDK)](#nanobot-sdk-facade)

### AgentRunner
**한글:** 에이전트 러너 · **분류:** 코어 · **코드:** `nanobot/agent/runner.py`

한 [Turn](#turn) 안에서 "[Provider](#provider) 호출 → [Tool](#tool) 실행 → 결과 반영 → 재호출"을
반복하는 **안쪽 루프**. [Streaming](04_providers_and_llm.md#streaming) 델타 처리, 반복 상한,
[Injection](#injection) 처리를 담당합니다.

- **상위 개념:** [AgentLoop](#agentloop)
- **하위 개념:** [Injection](#injection), [Tool Hint](02_tools_and_skills.md#tool-hint)
- **관련 용어:** [Tool Calling](08_ai_llm_concepts.md#tool-calling), [ToolRegistry](02_tools_and_skills.md#toolregistry)

### MessageBus
**한글:** 메시지 버스 · **분류:** 코어 · **코드:** `nanobot/bus/queue.py`

[Channel](#channel)과 에이전트 코어를 분리(decouple)하는 비동기 큐.
inbound/outbound 두 개의 [asyncio.Queue](09_dev_stack.md#asyncioqueue)를 갖고,
채널은 발행만, [AgentLoop](#agentloop)는 소비만 하므로 서로의 구현을 몰라도 됩니다.

- **하위 개념:** [InboundMessage](#inboundmessage), [OutboundMessage](#outboundmessage)
- **관련 용어:** [Channel](#channel), [asyncio](09_dev_stack.md#asyncio)

### InboundMessage
**한글:** 인바운드 메시지 · **분류:** 코어 · **코드:** `nanobot/bus/events.py`

외부 플랫폼에서 들어온 사용자 메시지를 표준화한 이벤트 객체(채널명, chat_id, sender_id, 본문, 미디어 등).
모든 [Channel](#channel)이 자기 플랫폼의 메시지를 이 형태로 변환해 [MessageBus](#messagebus)에 발행합니다.

- **상위 개념:** [MessageBus](#messagebus)
- **관련 용어:** [OutboundMessage](#outboundmessage), [Session Key](#session-key)

### OutboundMessage
**한글:** 아웃바운드 메시지 · **분류:** 코어 · **코드:** `nanobot/bus/events.py`

에이전트의 응답을 표준화한 이벤트 객체. [MessageBus](#messagebus)를 거쳐 원래 [Channel](#channel)이
플랫폼별 형식으로 변환해 전송합니다.

- **상위 개념:** [MessageBus](#messagebus)
- **관련 용어:** [InboundMessage](#inboundmessage)

### Turn
**한글:** 턴 · **분류:** 코어

사용자 메시지 하나에 대한 요청-응답 한 사이클. 한 턴 안에서 [AgentRunner](#agentrunner)가
여러 번의 [LLM](08_ai_llm_concepts.md#llm) 호출과 [Tool](#tool) 실행을 반복할 수 있습니다.

- **상위 개념:** [AgentLoop](#agentloop)
- **하위 개념:** [TurnState](#turnstate), [Turn Continuation](#turn-continuation)
- **관련 용어:** [Session](#session)

### TurnState
**한글:** 턴 상태 · **분류:** 코어 · **코드:** `nanobot/agent/loop.py`

한 [Turn](#turn)의 진행 단계를 나타내는 상태머신 국면(RESTORE → BUILD → RUN → SAVE).
크래시 시 어느 단계까지 갔는지 알 수 있어 [Runtime Checkpoint](#runtime-checkpoint) 복구의 기준이 됩니다.

- **상위 개념:** [Turn](#turn)
- **관련 용어:** [Runtime Checkpoint](#runtime-checkpoint)

### Session
**한글:** 세션 · **분류:** 코어 · **코드:** `nanobot/session/manager.py`

하나의 대화 맥락과 그 이력. nanobot은 세션을 [JSONL](03_memory_context_session.md#jsonl) 파일
(`<workspace>/sessions/*.jsonl`)로 저장합니다(SQLite가 아님).

- **하위 개념:** [Session Key](#session-key), [Unified Session](#unified-session),
  [Session Manager](03_memory_context_session.md#session-manager)
- **관련 용어:** [Workspace](#workspace), [AutoCompact](03_memory_context_session.md#autocompact)

### Session Key
**한글:** 세션 키 · **분류:** 코어 · **코드:** `nanobot/session/keys.py`

세션을 식별하는 문자열(예: `telegram:12345`, `sdk:default`, `heartbeat`).
채널·chat_id 조합으로 결정되며, 같은 키의 메시지는 같은 대화 이력을 공유합니다.

- **상위 개념:** [Session](#session)
- **관련 용어:** [Unified Session](#unified-session), [InboundMessage](#inboundmessage)

### Unified Session
**한글:** 통합 세션 · **분류:** 코어

여러 [Channel](#channel)(예: Telegram과 WebUI)이 **하나의 세션 키를 공유**해 대화 이력을 이어가는 기능.
"어디서 말 걸어도 같은 비서"를 만드는 장치입니다.

- **상위 개념:** [Session](#session)
- **관련 용어:** [Session Key](#session-key), [Channel](#channel)

### Workspace
**한글:** 워크스페이스 · **분류:** 코어 · **코드:** 기본 `~/.nanobot/workspace/`

에이전트의 홈 디렉토리. 세션([JSONL](03_memory_context_session.md#jsonl)),
[Memory](03_memory_context_session.md#memory), [Skill](#skill), cron 저장소 등이 이 아래에 있으며,
파일 도구와 [Sandbox](07_security_isolation.md#sandbox)의 접근 경계이기도 합니다.

- **관련 용어:** [Workspace Policy](07_security_isolation.md#workspace-policy),
  [Durable Files](03_memory_context_session.md#durable-files)

### Channel
**한글:** 채널 · **분류:** 코어 · **코드:** `nanobot/channels/base.py`

외부 메시징 플랫폼(Telegram, Slack 등)과 nanobot을 잇는 어댑터.
플랫폼 메시지 ↔ [InboundMessage](#inboundmessage)/[OutboundMessage](#outboundmessage) 변환을 담당합니다.
[pkgutil 자동 발견](02_tools_and_skills.md#tool-discovery)과 같은 방식으로 자동 등록됩니다.

- **하위 개념:** [Channel Manager](05_channels_gateway_ui.md#channel-manager),
  [Platform Channels](05_channels_gateway_ui.md#platform-channels),
  [WebSocket Channel](05_channels_gateway_ui.md#websocket-channel)
- **관련 용어:** [Gateway](#gateway), [Pairing](#pairing)

### Gateway
**한글:** 게이트웨이 · **분류:** 코어 · **코드:** `nanobot/gateway/`

`nanobot gateway` 명령으로 뜨는 **장기 실행 오케스트레이터**. 모든 [Channel](#channel),
[CronService](06_scheduling_automation.md#cronservice), [AgentLoop](#agentloop),
[WebUI](05_channels_gateway_ui.md#webui)를 한 프로세스에서 구동합니다.

- **하위 개념:** [Gateway Service](05_channels_gateway_ui.md#gateway-service),
  [Health Endpoint](05_channels_gateway_ui.md#health-endpoint)
- **관련 용어:** [Channel](#channel), [Cron](06_scheduling_automation.md#cron)

### Provider
**한글:** 프로바이더 · **분류:** 코어 · **코드:** `nanobot/providers/base.py`

[LLM](08_ai_llm_concepts.md#llm) 백엔드(Anthropic, OpenAI 등)의 공통 추상화.
"메시지 목록과 도구 목록을 주면 응답/도구 호출을 돌려주는" 인터페이스로,
어떤 백엔드든 같은 방식으로 갈아끼울 수 있게 합니다.

- **하위 개념:** [Provider Registry](04_providers_and_llm.md#provider-registry),
  [FallbackProvider](04_providers_and_llm.md#fallbackprovider),
  [Anthropic Provider](04_providers_and_llm.md#anthropic-provider)
- **관련 용어:** [Model Preset](#model-preset), [Model Routing](08_ai_llm_concepts.md#model-routing)

### Tool
**한글:** 도구 · **분류:** 코어 · **코드:** `nanobot/agent/tools/base.py`

[LLM](08_ai_llm_concepts.md#llm)이 호출할 수 있는 능력 단위(파일 읽기, 셸 실행 등).
이름·설명·[Tool Schema](02_tools_and_skills.md#tool-schema)를 선언하고 `execute()`를 구현합니다.

- **하위 개념:** [ToolRegistry](02_tools_and_skills.md#toolregistry),
  [ToolResult](02_tools_and_skills.md#toolresult), [ExecTool](02_tools_and_skills.md#exectool)
- **관련 용어:** [Tool Calling](08_ai_llm_concepts.md#tool-calling), [MCP](08_ai_llm_concepts.md#mcp)

### Skill
**한글:** 스킬 · **분류:** 코어 · **코드:** `nanobot/agent/skills.py`, `nanobot/skills/`

코드가 아니라 **마크다운([SKILL.md](02_tools_and_skills.md#skillmd))** 로 기술된 작업 절차/지식.
[Tool](#tool)이 "할 수 있는 것"이라면 스킬은 "하는 방법"입니다.

- **하위 개념:** [SkillsLoader](02_tools_and_skills.md#skillsloader),
  [skill-creator](02_tools_and_skills.md#skill-creator)
- **관련 용어:** [Skill Library](08_ai_llm_concepts.md#skill-library),
  [Progressive Disclosure](02_tools_and_skills.md#progressive-disclosure)

### Subagent
**한글:** 서브에이전트 · **분류:** 코어 · **코드:** `nanobot/agent/tools/spawn.py`

메인 에이전트가 [SpawnTool](02_tools_and_skills.md#spawntool)로 띄우는 **격리된 배경 작업자**.
자체 대화와 제한된 [Tool Scope](02_tools_and_skills.md#tool-scope)를 갖고, 완료 결과만 부모에게 보고합니다.

- **상위 개념:** [Agent](#agent)
- **관련 용어:** [SpawnTool](02_tools_and_skills.md#spawntool)

### Hook
**한글:** 훅 · **분류:** 코어 · **코드:** `nanobot/agent/hook.py`

턴 진행의 특정 지점(시작/도구 실행/완료 등)에 끼어들 수 있는 확장점.
[SDK](05_channels_gateway_ui.md#sdk-clients) 사용자가 커스텀 동작을 주입할 때 씁니다.

- **상위 개념:** [AgentLoop](#agentloop)
- **하위 개념:** [Progress Hook](#progress-hook)

### Progress Hook
**한글:** 진행 훅 · **분류:** 코어 · **코드:** `nanobot/agent/progress_hook.py`

턴 진행 상황(어떤 도구를 실행 중인지 등)을 실시간으로 밖에 알리는 [Hook](#hook).
[WebUI](05_channels_gateway_ui.md#webui)의 [Tool Hint](02_tools_and_skills.md#tool-hint) 표시가 이를 사용합니다.

- **상위 개념:** [Hook](#hook)

### Injection
**한글:** 인젝션(메시지 주입) · **분류:** 코어 · **코드:** `nanobot/agent/runner.py`

에이전트가 아직 턴을 도는 **도중에** 도착한 사용자 메시지를 진행 중인 대화에 끼워 넣는 기능.
`_MAX_INJECTIONS_PER_TURN` 같은 상한으로 무한 연장을 방지합니다.
(보안 용어 [Prompt Injection](07_security_isolation.md#prompt-injection)과는 다른 개념입니다.)

- **상위 개념:** [AgentRunner](#agentrunner)

### Turn Continuation
**한글:** 턴 이어가기 · **분류:** 코어 · **코드:** `nanobot/session/turn_continuation.py`

반복 상한 등으로 중단된 턴을 다음 요청에서 이어서 진행할 수 있게 하는 메커니즘.

- **상위 개념:** [Turn](#turn)
- **관련 용어:** [Runtime Checkpoint](#runtime-checkpoint)

### Runtime Checkpoint
**한글:** 런타임 체크포인트 · **분류:** 코어

턴 도중 상태를 저장해 크래시 후 복구할 수 있게 하는 영속화 장치.
[TurnState](#turnstate)의 단계 정보와 함께 쓰입니다.

- **관련 용어:** [TurnState](#turnstate), [Turn Continuation](#turn-continuation)

### Command Router
**한글:** 커맨드 라우터 · **분류:** 코어 · **코드:** `nanobot/command/`

`/`로 시작하는 [Slash Command](#slash-command)를 LLM에 보내지 않고 직접 처리하는 라우터.

- **하위 개념:** [Slash Command](#slash-command)

### Slash Command
**한글:** 슬래시 커맨드 · **분류:** 코어 · **코드:** `nanobot/command/`

`/new`, `/help`처럼 채팅에서 바로 실행되는 내장 명령. [LLM](08_ai_llm_concepts.md#llm) 호출 없이
[Command Router](#command-router)가 처리하므로 빠르고 결정적입니다.

- **상위 개념:** [Command Router](#command-router)

### Pairing
**한글:** 페어링 · **분류:** 코어 · **코드:** `nanobot/pairing/`

모르는 사람의 DM에 에이전트가 응답하지 않도록, 채널별 **페어링 코드**로 발신자를 승인하는 절차/저장소.

- **관련 용어:** [Channel](#channel)

### Config
**한글:** 설정 · **분류:** 코어 · **코드:** `nanobot/config/schema.py`, `loader.py`

`~/.nanobot/config.json`에서 로드되는 [Pydantic](09_dev_stack.md#pydantic) 기반 설정.
JSON 호환을 위한 [camelCase Alias](09_dev_stack.md#camelcase-alias)를 지원하고,
`${VAR}` 패턴은 로드 시 환경변수로 치환됩니다(없으면 `ValueError`).

- **하위 개념:** [Model Preset](#model-preset)
- **관련 용어:** [Pydantic](09_dev_stack.md#pydantic), [Workspace](#workspace)

### Model Preset
**한글:** 모델 프리셋 · **분류:** 코어 · **코드:** `nanobot/agent/model_presets.py`

"이 용도에는 이 프로바이더의 이 모델과 이 파라미터"를 묶어 이름 붙인 설정 단위.
용도별([Dream](03_memory_context_session.md#dream)용, 대화용 등) 모델을 골라 쓰는
수동 [Model Routing](08_ai_llm_concepts.md#model-routing)의 수단입니다.

- **상위 개념:** [Config](#config)
- **관련 용어:** [Provider](#provider), [Temperature](04_providers_and_llm.md#temperature)

### Nanobot (SDK Facade)
**한글:** Nanobot 파사드 · **분류:** 코어 · **코드:** `nanobot/nanobot.py`

nanobot을 파이썬 라이브러리로 임베드하기 위한 진입점 클래스.
`Nanobot.from_config()`으로 만들고 `await bot.run("...")`으로 한 턴을 실행합니다.
내부적으로 [AgentLoop](#agentloop)를 감싸는 파사드(facade) 패턴입니다.

- **상위 개념:** [Agent](#agent)
- **관련 용어:** [SDK Clients](05_channels_gateway_ui.md#sdk-clients), [AgentLoop](#agentloop)
