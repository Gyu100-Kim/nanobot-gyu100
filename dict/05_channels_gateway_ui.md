# 사전 05. 채널·게이트웨이·UI·API (Channels, Gateway, UI & API)

> 바깥세상과의 접점: 메시징 플랫폼, 웹 UI, HTTP API, SDK.
> 전체 색인은 [README](README.md)를 보세요.

---

### Channel Manager
**한글:** 채널 매니저 · **분류:** 채널 · **코드:** `nanobot/channels/manager.py`

설정에 활성화된 [Channel](01_core_architecture.md#channel)들을 발견·생성·시작/정지하는 조정자.
[pkgutil](09_dev_stack.md#pkgutil) 스캔과 [Entry-point Plugin](02_tools_and_skills.md#entry-point-plugin)으로
채널을 찾습니다.

- **상위 개념:** [Channel](01_core_architecture.md#channel)
- **하위 개념:** [Channel Registry](#channel-registry)

### Channel Registry
**한글:** 채널 레지스트리 · **분류:** 채널 · **코드:** `nanobot/channels/registry.py`

채널 이름 → 채널 클래스 매핑. 새 채널을 파일 하나로 추가할 수 있게 하는 등록소입니다.

- **상위 개념:** [Channel Manager](#channel-manager)

### Platform Channels
**한글:** 플랫폼 채널들 · **분류:** 채널 · **코드:** `nanobot/channels/*.py`

개별 메시징 플랫폼 어댑터: Telegram, Discord, Slack, Feishu(Lark), Matrix, WhatsApp, QQ, WeChat,
WeCom, DingTalk, Email, MoChat, MS Teams, Mattermost 등. `.agent/design.md`의 원칙상 각 채널 파일은
공유 추상화 없이 **자체 완결적**으로 유지됩니다(중복 허용 > 조기 추상화).

- **상위 개념:** [Channel](01_core_architecture.md#channel)
- **관련 용어:** [Optional Dependencies](09_dev_stack.md#optional-dependencies)

### WebSocket Channel
**분류:** 채널 · **코드:** `nanobot/channels/websocket.py`

[WebUI](#webui)가 접속하는 [WebSocket](09_dev_stack.md#websockets) 채널.
[WebSocket Multiplex Protocol](#websocket-multiplex-protocol)로 여러 대화/이벤트 스트림을 한 연결에 다중화합니다.

- **상위 개념:** [Channel](01_core_architecture.md#channel)
- **하위 개념:** [WebSocket Multiplex Protocol](#websocket-multiplex-protocol)

### WebSocket Multiplex Protocol
**한글:** 웹소켓 다중화 프로토콜 · **분류:** 채널

하나의 WebSocket 연결 위에서 채팅 메시지, [Tool Hint](02_tools_and_skills.md#tool-hint),
턴 이벤트(`_turn_end` 등), 설정 조회를 함께 주고받는 nanobot의 UI 통신 규약.
UI 와이어 세부는 [WebUI Turn Coordinator](03_memory_context_session.md#webui-turn-coordinator)가 담당합니다.

- **상위 개념:** [WebSocket Channel](#websocket-channel)

### WebUI
**분류:** UI · **코드:** `webui/`(소스), `nanobot/web/dist/`(번들)

[Vite](09_dev_stack.md#vite) 기반 [React](09_dev_stack.md#react-js)/[TypeScript](09_dev_stack.md#typescript)
SPA. [bun](09_dev_stack.md#bun)으로 빌드해 `nanobot/web/dist/`에 넣고 파이썬 휠에 동봉합니다.
개발 서버는 `/api`, `/webui`, `/auth`와 WebSocket을 게이트웨이(:8765)로 프록시합니다.

- **관련 용어:** [WebSocket Channel](#websocket-channel), [Gateway](01_core_architecture.md#gateway)

### Gateway Service
**분류:** 게이트웨이 · **코드:** `nanobot/gateway/service.py`, `runtime.py`

[Gateway](01_core_architecture.md#gateway)의 실제 구동부: 구성요소 초기화, 생명주기 관리, 종료 처리.

- **상위 개념:** [Gateway](01_core_architecture.md#gateway)
- **하위 개념:** [Health Endpoint](#health-endpoint)

### Health Endpoint
**한글:** 헬스 엔드포인트 · **분류:** 게이트웨이

게이트웨이가 살아 있는지 외부(모니터링, Docker healthcheck)가 확인할 수 있는 HTTP 상태 확인 지점.

- **상위 개념:** [Gateway Service](#gateway-service)

### API Server
**분류:** API · **코드:** `nanobot/api/server.py`

nanobot을 프로그램에서 HTTP로 쓰게 하는 [OpenAI-Compatible API](#openai-compatible-api) 서버.
`nanobot serve` 명령으로 구동합니다.

- **하위 개념:** [OpenAI-Compatible API](#openai-compatible-api)

### OpenAI-Compatible API
**한글:** OpenAI 호환 API · **분류:** API

OpenAI의 `/v1/chat/completions`, `/v1/models` 형식을 그대로 따르는 HTTP 인터페이스.
기존 OpenAI 클라이언트 코드가 base URL만 바꿔 nanobot을 쓸 수 있습니다 —
"OpenAI 와이어 형식이 사실상 표준"이 된 생태계 관행의 활용입니다.

- **상위 개념:** [API Server](#api-server)
- **관련 용어:** [OpenAI-Compatible Provider](04_providers_and_llm.md#openai-compatible-provider)

### SDK Clients
**한글:** SDK 클라이언트 · **분류:** SDK · **코드:** `nanobot/sdk/clients.py`

[Nanobot 파사드](01_core_architecture.md#nanobot-sdk-facade)에 붙는 하위 클라이언트들:
`SessionClient`(세션 제어), `MemoryClient`(메모리 접근), `RuntimeClient`(런타임 상태).
파이썬 코드에서 nanobot 내부를 구조적으로 다루는 통로입니다.

- **상위 개념:** [Nanobot (SDK Facade)](01_core_architecture.md#nanobot-sdk-facade)

### Apps
**한글:** 앱 · **분류:** 확장 · **코드:** `nanobot/apps/`

매니페스트로 선언되는 상위 수준 확장 단위(프로토콜: `nanobot/apps/protocol.py`).
도구/스킬 묶음을 하나의 "앱"으로 배포하기 위한 계층입니다.

- **관련 용어:** [Skill](01_core_architecture.md#skill), [Tool](01_core_architecture.md#tool)
