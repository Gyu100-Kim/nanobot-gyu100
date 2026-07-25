# 사전 05. 채널·게이트웨이·UI (Channels, Gateway & UI)

> 외부 세계와의 접점: 채팅 플랫폼 연동, 장기 실행 프로세스, 웹 UI와 API.
> 전체 색인은 [README](README.md), 노드 클래스 정의는 [00_content_classes.md](00_content_classes.md)를 보세요.
>
> 표기 규약: **상위 개념 = 더 특수한 개념**(예시·구현·특수화), **하위 개념 = 더 일반적인 개념**(일반화).

---

### Channel Manager
**클래스:** [Component](00_content_classes.md#component) · **한글:** 채널 매니저 · **코드:** `nanobot/channels/manager.py`

설정에 활성화된 [Channel](01_core_architecture.md#channel)들을 찾아 생성·시작·정지시키는 조율자.
채널 하나가 죽어도 다른 채널은 계속 돌게 오류를 격리합니다.

- **하위 개념(더 일반):** [Channel](01_core_architecture.md#channel)
- **관련 용어:** [Gateway](01_core_architecture.md#gateway)

### Channel Registry
**클래스:** [Component](00_content_classes.md#component) · **한글:** 채널 레지스트리 · **코드:** `nanobot/channels/registry.py`

채널 이름 → 구현 클래스 매핑을 관리하는 [Registry Pattern](02_tools_and_skills.md#registry-pattern)
구현. [pkgutil](09_dev_stack.md#pkgutil) 스캔과
[Entry-point Plugin](02_tools_and_skills.md#entry-point-plugin)으로 자동 채워집니다 —
[Tool Discovery](02_tools_and_skills.md#tool-discovery)와 같은 방식의 채널판입니다.

- **하위 개념(더 일반):** [Channel](01_core_architecture.md#channel),
  [Registry Pattern](02_tools_and_skills.md#registry-pattern)

### Platform Channels
**클래스:** [Component](00_content_classes.md#component) · **한글:** 플랫폼 채널 · **코드:** `nanobot/channels/*.py`

Telegram, Discord, Slack, Feishu, Matrix, WhatsApp, Email 등 실제 메시징 플랫폼별
[Channel](01_core_architecture.md#channel) 구현들. 각 플랫폼 SDK는
[Optional Dependencies](09_dev_stack.md#optional-dependencies)라서 쓰는 것만 설치합니다
(`pip install nanobot-ai[telegram]`).

- **하위 개념(더 일반):** [Channel](01_core_architecture.md#channel)

### WebSocket Channel
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/channels/websocket.py`

[WebUI](#webui)가 접속하는 [WebSocket](#websocket) 기반 채널. 다른 채널과 달리 외부 플랫폼이 아니라
nanobot 자신이 서버가 되며, [WebSocket Multiplex Protocol](#websocket-multiplex-protocol)로
대화·이벤트·제어를 한 연결에 싣습니다.

- **하위 개념(더 일반):** [Channel](01_core_architecture.md#channel), [WebSocket](#websocket)
- **상위 개념(더 특수):** [WebSocket Multiplex Protocol](#websocket-multiplex-protocol)

### WebSocket
**클래스:** [Protocol](00_content_classes.md#protocol) · **한글:** 웹소켓

[HTTP](#http)로 시작해 업그레이드되는 **양방향 상시 연결** 프로토콜(RFC 6455). 요청-응답만 가능한
HTTP와 달리 서버가 먼저 말을 걸 수 있어, 실시간 채팅·알림에 적합합니다.

**예시:** [WebUI](#webui)에서 에이전트의 [Streaming](04_providers_and_llm.md#streaming) 응답이
타이핑되듯 나타나는 것 — 서버가 [Delta](04_providers_and_llm.md#delta)를 밀어 넣는(push) 것입니다.

- **상위 개념(더 특수):** [WebSocket Channel](#websocket-channel)
- **하위 개념(더 일반):** [HTTP](#http)
- **관련 용어:** [websockets](09_dev_stack.md#websockets)

### HTTP
**클래스:** [Protocol](00_content_classes.md#protocol)

웹의 기본 요청-응답 프로토콜. 클라이언트가 요청(메서드 + URL + 헤더 + 본문)을 보내면 서버가
응답(상태 코드 + 본문)을 돌려줍니다. nanobot에서는 [API Server](#api-server), 웹 fetch 도구,
모든 LLM API 호출([httpx](09_dev_stack.md#httpx))의 토대입니다.

- **상위 개념(더 특수):** [WebSocket](#websocket), [SSE](08_ai_llm_concepts.md#sse),
  [OpenAI-Compatible API](#openai-compatible-api)

### WebSocket Multiplex Protocol
**클래스:** [Protocol](00_content_classes.md#protocol) · **한글:** 웹소켓 다중화 프로토콜

하나의 [WebSocket](#websocket) 연결 위에 여러 논리 스트림(대화 메시지, 진행 이벤트, 세션 제어)을
태그 붙여 싣는 nanobot의 자체 규약. 연결을 스트림마다 따로 여는 비용을 아낍니다.

- **하위 개념(더 일반):** [WebSocket Channel](#websocket-channel)
- **관련 용어:** [Tool Hint](02_tools_and_skills.md#tool-hint)

### WebUI
**클래스:** [Component](00_content_classes.md#component) · **코드:** `webui/` (빌드 산출물 `nanobot/web/dist/`)

[React (JS)](09_dev_stack.md#react-js) + [TypeScript](09_dev_stack.md#typescript) +
[Vite](09_dev_stack.md#vite)로 만든 [SPA](#spa) 웹 클라이언트. [bun](09_dev_stack.md#bun)으로 빌드해
파이썬 휠에 **번들로 포함**되므로, 사용자는 Node 없이도 `nanobot gateway` 후 브라우저만 열면 됩니다.

- **하위 개념(더 일반):** [SPA](#spa)
- **관련 용어:** [WebSocket Channel](#websocket-channel),
  [WebUI Turn Coordinator](03_memory_context_session.md#webui-turn-coordinator)

### SPA
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 단일 페이지 애플리케이션 (Single Page Application)

페이지 이동 없이 자바스크립트가 화면을 갈아끼우는 웹앱 형태. 첫 로드 후에는 서버와 데이터만
주고받아 네이티브 앱 같은 사용감을 줍니다. [React (JS)](09_dev_stack.md#react-js) 같은 UI
라이브러리가 이 방식의 표준 도구입니다.

- **상위 개념(더 특수):** [WebUI](#webui)

### Gateway Service
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/gateway/service.py`, `runtime.py`

[Gateway](01_core_architecture.md#gateway)의 실제 구현 — 채널, [AgentLoop](01_core_architecture.md#agentloop),
[CronService](06_scheduling_automation.md#cronservice), [AutoCompact](03_memory_context_session.md#autocompact)를
기동/정지하는 생명주기 관리자입니다.

- **하위 개념(더 일반):** [Gateway](01_core_architecture.md#gateway)
- **상위 개념(더 특수):** [Health Endpoint](#health-endpoint)

### Health Endpoint
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 헬스 엔드포인트

프로세스 생존/상태를 [HTTP](#http)로 알려주는 점검 창구. 컨테이너 오케스트레이터나 모니터링이
"살아 있나?"를 기계적으로 확인하는 데 씁니다.

- **하위 개념(더 일반):** [Gateway Service](#gateway-service)

### API Server
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/api/server.py`

[OpenAI-Compatible API](#openai-compatible-api)(`/v1/chat/completions`, `/v1/models`)를 노출하는
HTTP 서버. 외부 프로그램이 nanobot 에이전트를 "그냥 OpenAI 모델인 것처럼" 호출할 수 있게 합니다.

**예시:** OpenAI SDK의 `base_url`을 nanobot 게이트웨이로 바꾸면, 기존 코드가 그대로
nanobot 에이전트와 대화합니다.

- **상위 개념(더 특수):** [OpenAI-Compatible API](#openai-compatible-api)
- **하위 개념(더 일반):** [HTTP](#http)

### OpenAI-Compatible API
**클래스:** [Protocol](00_content_classes.md#protocol)

OpenAI Chat Completions API의 요청/응답 형식(JSON 스키마, 엔드포인트 경로)을 그대로 따르는 것 —
사실상(de facto)의 업계 표준 규격입니다. 클라이언트 생태계(SDK, 앱)를 재사용할 수 있어,
nanobot은 서버로서 이를 제공하고([API Server](#api-server)), 클라이언트로서도 이를 사용합니다
([OpenAI-Compatible Provider](04_providers_and_llm.md#openai-compatible-provider)).

- **하위 개념(더 일반):** [HTTP](#http)

### SDK Clients
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/sdk/`

게이트웨이에 원격 접속하는 파이썬 클라이언트. 인프로세스 임베드인
[Nanobot (SDK Facade)](01_core_architecture.md#nanobot-sdk-facade)와 달리, 이미 떠 있는 게이트웨이에
네트워크로 붙습니다.

- **관련 용어:** [Gateway](01_core_architecture.md#gateway)

### Apps
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/apps/`

에이전트 위에 얹는 응용 기능 모음(캔버스 등). "Core stays small" 원칙에 따라 코어 밖 가장자리에
위치합니다.

- **관련 용어:** [Plugin Architecture](02_tools_and_skills.md#plugin-architecture)
