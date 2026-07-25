# 사전 09. 개발 스택 (Development Stack)

> nanobot이 딛고 선 언어/라이브러리/빌드 도구.
> 전체 색인은 [README](README.md)를 보세요.

---

### Python 3.11+
**분류:** 언어

nanobot의 구현 언어(최소 버전 3.11). [asyncio](#asyncio) 성능 개선과 타입 문법(`X | None`)이 기준입니다.

- **하위 개념:** [asyncio](#asyncio), [ContextVar](#contextvar), [pkgutil](#pkgutil)

### asyncio
**분류:** 언어 · 표준 라이브러리

파이썬의 협력적 동시성 프레임워크. 하나의 스레드에서 [Coroutine](#coroutine)들이
I/O 대기 시점에 서로 양보하며 실행됩니다. 채널/프로바이더/도구가 모두 I/O 바운드인
nanobot에 알맞은 모델입니다.

- **상위 개념:** [Python 3.11+](#python-311)
- **하위 개념:** [Coroutine](#coroutine), [asyncio.Queue](#asyncioqueue)

### Coroutine
**한글:** 코루틴 · **분류:** 언어

`async def`로 정의되어 `await` 지점에서 중단/재개되는 함수. [asyncio](#asyncio)의 실행 단위입니다.

- **상위 개념:** [asyncio](#asyncio)

### asyncio.Queue
**분류:** 언어

코루틴 간 안전한 비동기 큐. [MessageBus](01_core_architecture.md#messagebus)의
inbound/outbound 큐가 이것입니다.

- **상위 개념:** [asyncio](#asyncio)

### ContextVar
**분류:** 언어 · 표준 라이브러리 (`contextvars`)

비동기 태스크마다 독립된 값을 갖는 변수 — 스레드로컬의 asyncio 버전.
[Workspace Access](07_security_isolation.md#workspace-access)가 태스크별 접근 경계에 씁니다.

- **상위 개념:** [Python 3.11+](#python-311)

### pkgutil
**분류:** 언어 · 표준 라이브러리

패키지 안의 모듈들을 열거하는 표준 라이브러리.
[Tool Discovery](02_tools_and_skills.md#tool-discovery)와 채널 자동 발견의 기반입니다.

- **상위 개념:** [Python 3.11+](#python-311)

### Entry Points
**한글:** 엔트리 포인트 · **분류:** 패키징

파이썬 패키지가 "이 이름으로 이 객체를 제공한다"고 선언하는 패키징 표준 메타데이터.
`[project.scripts]`(CLI 명령 `nanobot`)와 플러그인 그룹(`nanobot.tools`, `nanobot.channels`)에 쓰입니다.

- **관련 용어:** [Entry-point Plugin](02_tools_and_skills.md#entry-point-plugin), [hatchling](#hatchling)

### Optional Dependencies
**한글:** 선택적 의존성 (lazy deps) · **분류:** 패키징

`pyproject.toml`의 `[project.optional-dependencies]` — `pip install nanobot[telegram]`처럼
필요한 채널/기능의 의존성만 설치하는 방식. `nanobot/optional_features.py`가 미설치 기능을
안내 메시지와 함께 우아하게 비활성화합니다.

- **관련 용어:** [Platform Channels](05_channels_gateway_ui.md#platform-channels), [Exact Pinning](#exact-pinning)

### Exact Pinning
**한글:** 버전 고정 · **분류:** 패키징

의존성 버전에 상한·하한을 두는 정책. 재현성이 좋아지는 대신 다른 패키지와의 충돌 여지가 커지는
트레이드오프가 있습니다.

- **관련 용어:** [Optional Dependencies](#optional-dependencies)

### hatchling
**분류:** 빌드

nanobot의 파이썬 빌드 백엔드. 커스텀 훅(`hatch_build.py`)으로
[WebUI](05_channels_gateway_ui.md#webui) 번들을 휠에 포함시킵니다.

- **관련 용어:** [Entry Points](#entry-points)

### Pydantic
**분류:** 라이브러리

타입 힌트 기반 데이터 검증/직렬화 라이브러리. [Config](01_core_architecture.md#config) 스키마와
버스 이벤트 모델의 기반입니다.

- **하위 개념:** [pydantic-settings](#pydantic-settings), [camelCase Alias](#camelcase-alias)

### pydantic-settings
**분류:** 라이브러리

환경변수/파일에서 설정을 읽어 [Pydantic](#pydantic) 모델로 검증하는 확장.

- **상위 개념:** [Pydantic](#pydantic)

### camelCase Alias
**분류:** 라이브러리 · 관행

JSON 관행(camelCase)과 파이썬 관행(snake_case)을 잇는 [Pydantic](#pydantic) 별칭 설정 —
`config.json`의 `apiKey`가 파이썬의 `api_key`로 매핑됩니다.

- **상위 개념:** [Pydantic](#pydantic)

### Typer
**분류:** 라이브러리

타입 힌트 기반 CLI 프레임워크(Click 계열). `nanobot/cli/commands.py`의
`agent`, `gateway`, `onboard`, `serve`, `webui`, `status` 등 명령이 Typer 앱입니다.

- **관련 용어:** [Rich](#rich)

### httpx
**분류:** 라이브러리

동기/비동기 겸용 HTTP 클라이언트. [Web Tools](02_tools_and_skills.md#web-tools)와 여러 채널이 쓰고,
커스텀 트랜스포트 지원 덕분에
[PinnedDNSAsyncTransport](07_security_isolation.md#pinneddnsasynctransport)를 끼울 수 있습니다.

- **관련 용어:** [websockets](#websockets)

### websockets
**분류:** 라이브러리

파이썬 WebSocket 서버/클라이언트 라이브러리.
[WebSocket Channel](05_channels_gateway_ui.md#websocket-channel)의 기반입니다.

- **관련 용어:** [httpx](#httpx)

### Rich
**분류:** 라이브러리

터미널 서식(색/표/마크다운) 라이브러리. CLI 대화 모드의 출력을 담당합니다.

- **관련 용어:** [prompt-toolkit](#prompt-toolkit)

### prompt-toolkit
**분류:** 라이브러리

고급 터미널 입력(멀티라인, 히스토리, 키바인딩) 라이브러리. CLI 대화 모드의 입력을 담당합니다.

- **관련 용어:** [questionary](#questionary)

### questionary
**분류:** 라이브러리

대화형 선택/질문 UI 라이브러리. `nanobot onboard` 마법사가 사용합니다.

- **상위 개념:** [prompt-toolkit](#prompt-toolkit)

### loguru
**분류:** 라이브러리

설정이 간편한 로깅 라이브러리. nanobot 전반의 로거입니다.

### Jinja2
**분류:** 라이브러리

텍스트 템플릿 엔진. `nanobot/templates/`의
[System Prompt](03_memory_context_session.md#system-prompt) 렌더링에 쓰입니다.

- **관련 용어:** [Bootstrap Templates](03_memory_context_session.md#bootstrap-templates)

### ddgs
**분류:** 라이브러리

DuckDuckGo 검색 결과를 가져오는 라이브러리(API 키 불필요).
[Web Tools](02_tools_and_skills.md#web-tools)의 검색 백엔드입니다.

### dulwich
**분류:** 라이브러리

순수 파이썬 [Git](#git) 구현 — git 바이너리 없이 커밋/조회가 가능합니다.
메모리 파일의 버전 관리(`utils/gitstore`)에 쓰입니다.

- **관련 용어:** [Git](#git)

### filelock
**분류:** 라이브러리

파일 기반 프로세스 간 잠금. 여러 프로세스가 같은 세션/저장소를 동시에 건드리는 것을 막습니다.

### Git
**분류:** 도구

분산 버전 관리 시스템. nanobot에서는 코드 관리 외에도 [Dream](03_memory_context_session.md#dream)의
"실제 변경 검증"(diff)과 메모리 감사 이력에 활용됩니다.

- **관련 용어:** [dulwich](#dulwich)

### ruff
**분류:** 개발 도구

고속 파이썬 린터. 이 저장소는 규칙 E, F, I, N, W(E501 제외), 줄 길이 100을 씁니다.
`.agent/gotchas.md`: `ruff format`은 금지, `ruff check`만 사용.

- **관련 용어:** [pytest](#pytest)

### pytest
**분류:** 개발 도구

파이썬 테스트 프레임워크. `asyncio_mode = "auto"`라서 async 테스트 함수를 데코레이터 없이 씁니다.
테스트는 `nanobot/` 패키지 구조를 미러링합니다.

- **관련 용어:** [ruff](#ruff)

### bun
**분류:** JS 도구

고속 JavaScript 런타임/패키지 매니저(npm 대체). [WebUI](05_channels_gateway_ui.md#webui)의
설치/빌드/테스트(`bun run build` 등)에 쓰입니다.

- **관련 용어:** [Vite](#vite)

### Vite
**분류:** JS 도구

빠른 프론트엔드 빌드 도구/개발 서버. [WebUI](05_channels_gateway_ui.md#webui)의 빌드 기반이며,
개발 프록시 설정은 `webui/vite.config.ts`에 있습니다.

- **관련 용어:** [React](#react-js)

### React (JS)
**분류:** JS 라이브러리

컴포넌트 기반 UI 라이브러리. [WebUI](05_channels_gateway_ui.md#webui)의 화면 계층입니다.

- **관련 용어:** [TypeScript](#typescript)

### TypeScript
**분류:** JS 언어

JavaScript에 정적 타입을 더한 언어. [WebUI](05_channels_gateway_ui.md#webui)의 구현 언어입니다.

- **관련 용어:** [React](#react-js)
