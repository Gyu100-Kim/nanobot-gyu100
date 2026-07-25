# 사전 09. 개발 스택 (Development Stack)

> nanobot이 사용하는 언어 기능, 라이브러리, 개발 도구.
> 전체 색인은 [README](README.md), 노드 클래스 정의는 [00_content_classes.md](00_content_classes.md)를 보세요.
>
> 표기 규약: **상위 개념 = 더 특수한 개념**(예시·구현·특수화), **하위 개념 = 더 일반적인 개념**(일반화).

---

### Python 3.11+
**클래스:** [Technology](00_content_classes.md#technology)

nanobot의 구현 언어와 최소 버전(`pyproject.toml`의 `requires-python`). 3.11은
[asyncio](#asyncio) 성능 개선, 더 나은 오류 메시지, `Self` 타입 등을 제공합니다.

- **상위 개념(더 특수):** [asyncio](#asyncio), [Type Hint](#type-hint), [ContextVar](#contextvar)

### Type Hint
**클래스:** [Technology](00_content_classes.md#technology) · **한글:** 타입 힌트

파이썬 코드에 변수/인자/반환의 타입을 표기하는 문법(`def f(x: int) -> str:`). 실행에는 영향이
없지만 정적 검사기와 에디터가 오류를 미리 잡게 하고, [Pydantic](#pydantic)은 이를 **런타임 검증**
에까지 활용합니다 — nanobot 전반의 안전망입니다.

- **하위 개념(더 일반):** [Python 3.11+](#python-311)
- **관련 용어:** [Pydantic](#pydantic)

### asyncio
**클래스:** [Technology](00_content_classes.md#technology)

파이썬 표준 비동기 프레임워크 — 단일 스레드의 [Event Loop](#event-loop)가 I/O 대기 중인
[Coroutine](#coroutine)들을 갈아타며 동시성을 냅니다. nanobot의 작업(LLM API 대기, 채널 폴링,
크론 대기)은 대부분 I/O 대기라 이 모델에 이상적입니다. 저장소 규칙: "asyncio throughout".

- **하위 개념(더 일반):** [Python 3.11+](#python-311)
- **상위 개념(더 특수):** [Coroutine](#coroutine), [asyncio.Queue](#asyncioqueue),
  [Event Loop](#event-loop)

### Event Loop
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 이벤트 루프

"준비된 작업을 하나 꺼내 실행하고, I/O를 기다리는 작업은 재워 두는" 것을 반복하는 스케줄러 —
[asyncio](#asyncio) 동시성의 심장입니다. 스레드 없이도 수천 개의 대기 작업을 다룰 수 있는 대신,
한 작업이 CPU를 오래 붙들면(블로킹) 전체가 멈춥니다.

- **하위 개념(더 일반):** [asyncio](#asyncio)
- **관련 용어:** [Coroutine](#coroutine)

### Coroutine
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 코루틴

`async def`로 정의되어 `await` 지점에서 **스스로 실행을 양보**할 수 있는 함수.
[Event Loop](#event-loop)는 양보한 코루틴 대신 준비된 다른 코루틴을 실행합니다 — 협력적
멀티태스킹입니다.

**예시:** `await provider.chat(...)` — LLM 응답을 기다리는 몇 초 동안 다른 채널의 메시지 처리가
끼어들 수 있습니다.

- **하위 개념(더 일반):** [asyncio](#asyncio)

### asyncio.Queue
**클래스:** [Technology](00_content_classes.md#technology)

[Coroutine](#coroutine) 간 안전한 전달 통로가 되는 비동기 큐 — `await get()`은 항목이 올 때까지
양보하며 기다립니다. [MessageBus](01_core_architecture.md#messagebus)의 구현 재료입니다.

- **하위 개념(더 일반):** [asyncio](#asyncio)
- **관련 용어:** [Producer-Consumer](01_core_architecture.md#producer-consumer)

### ContextVar
**클래스:** [Technology](00_content_classes.md#technology)

비동기 작업마다 **독립된 값**을 갖는 변수(표준 `contextvars`). 전역 변수는 동시 실행 중인 여러
턴이 서로 덮어쓰지만, ContextVar는 실행 문맥별로 분리됩니다 — 여러 대화를 동시에 처리하는
nanobot에서 "지금 이 턴"의 상태를 안전하게 유지하는 수단입니다.

- **하위 개념(더 일반):** [Python 3.11+](#python-311)

### pkgutil
**클래스:** [Technology](00_content_classes.md#technology)

패키지 안의 모듈을 열거하는 파이썬 표준 라이브러리.
[Tool Discovery](02_tools_and_skills.md#tool-discovery)와
[Channel Registry](05_channels_gateway_ui.md#channel-registry)의 자동 발견이 이것으로 구현됩니다.

- **관련 용어:** [Plugin Architecture](02_tools_and_skills.md#plugin-architecture)

### Entry Points
**클래스:** [Protocol](00_content_classes.md#protocol) · **한글:** 엔트리 포인트

파이썬 패키징 표준의 플러그인 선언 규격 — 패키지가 메타데이터에 "나는 이 그룹에 이 객체를
제공한다"고 선언하면, 호스트가 설치된 패키지들에서 그룹을 조회해 로드합니다.

**예시:** `[project.scripts] nanobot = "nanobot.cli.commands:app"`(CLI 명령 생성),
`nanobot.tools` 그룹([Entry-point Plugin](02_tools_and_skills.md#entry-point-plugin)).

- **상위 개념(더 특수):** [Entry-point Plugin](02_tools_and_skills.md#entry-point-plugin)
- **관련 용어:** [PyPI](#pypi)

### PyPI
**클래스:** [Technology](00_content_classes.md#technology) · **한글:** 파이썬 패키지 인덱스 (Python Package Index)

파이썬 패키지의 공식 저장소 — `pip install`이 내려받는 곳. nanobot은 `nanobot-ai`라는 이름으로
배포되며, [hatchling](#hatchling)이 빌드한 휠(wheel)이 올라갑니다.

- **관련 용어:** [Optional Dependencies](#optional-dependencies), [Entry Points](#entry-points)

### Optional Dependencies
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 선택적 의존성 (extras)

`pip install nanobot-ai[telegram]`처럼 **필요한 기능의 의존성만** 골라 설치하는 파이썬 패키징
기능. 20개 가까운 채널/프로바이더의 SDK를 전부 설치하면 무겁기 때문에, 기본 설치는 가볍게 유지하고
`nanobot/optional_features.py`가 미설치 기능 사용 시 안내 메시지를 냅니다 — "lazy deps" 설계.

- **관련 용어:** [Platform Channels](05_channels_gateway_ui.md#platform-channels),
  [Exact Pinning](#exact-pinning)

### Exact Pinning
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 버전 고정

의존성 버전에 상한·하한을 두어(`>=x,<y`) 예고 없는 호환성 파괴를 막는 정책. 재현성이 좋아지는
대신 보안 패치 수용이 늦어질 수 있는 트레이드오프가 있습니다.

- **관련 용어:** [Optional Dependencies](#optional-dependencies), [PyPI](#pypi)

### hatchling
**클래스:** [Technology](00_content_classes.md#technology)

`pyproject.toml` 기반 파이썬 빌드 백엔드. [WebUI](05_channels_gateway_ui.md#webui) 빌드 산출물
(`nanobot/web/dist/`)을 휠에 포함시키는 것도 이 설정입니다.

- **관련 용어:** [PyPI](#pypi)

### Pydantic
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `pydantic`

[Type Hint](#type-hint)를 **런타임 데이터 검증**으로 바꿔 주는 라이브러리 — 잘못된 데이터가
모델 생성 시점에 즉시 오류를 냅니다. nanobot의 [Config](01_core_architecture.md#config),
버스 이벤트, 크론 타입이 모두 Pydantic 모델입니다.

**예시:** `InboundMessage(chat_id=123)`처럼 문자열 필드에 숫자를 넣으면 저장 훨씬 뒤가 아니라
그 자리에서 검증 오류가 납니다 — 오류를 발생 지점에 가깝게 만드는 설계.

- **하위 개념(더 일반):** [Type Hint](#type-hint)
- **상위 개념(더 특수):** [pydantic-settings](#pydantic-settings),
  [camelCase Alias](#camelcase-alias)
- **관련 용어:** [JSON Schema](08_ai_llm_concepts.md#json-schema)

### pydantic-settings
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `pydantic-settings`

[Pydantic](#pydantic) 모델로 환경변수/설정 파일을 로드하는 확장 —
[Config](01_core_architecture.md#config) 로딩에 사용됩니다.

- **하위 개념(더 일반):** [Pydantic](#pydantic)

### camelCase Alias
**클래스:** [Mechanism](00_content_classes.md#mechanism)

파이썬 필드는 `snake_case`, JSON 키는 `camelCase`를 쓰는 관행 차이를 [Pydantic](#pydantic)
alias로 흡수하는 설정. `config.json`에서 `maxTokens`라고 써도 파이썬의 `max_tokens`에 매핑됩니다.

- **하위 개념(더 일반):** [Pydantic](#pydantic), [Config](01_core_architecture.md#config)

### Typer
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `typer`

[Type Hint](#type-hint) 기반 CLI 프레임워크 — 함수 시그니처가 곧 명령 인터페이스가 됩니다.
`nanobot agent`, `nanobot gateway` 등 CLI(`nanobot/cli/commands.py`)의 뼈대입니다.

- **하위 개념(더 일반):** [Type Hint](#type-hint)
- **관련 용어:** [Rich](#rich)

### httpx
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `httpx`

[asyncio](#asyncio) 네이티브 HTTP 클라이언트. 커스텀 전송 계층을 끼울 수 있어
[PinnedDNSAsyncTransport](07_security_isolation.md#pinneddnsasynctransport) 같은 보안 확장이
가능합니다 — requests의 비동기 시대 후계자입니다.

- **상위 개념(더 특수):** [PinnedDNSAsyncTransport](07_security_isolation.md#pinneddnsasynctransport)
- **관련 용어:** [HTTP](05_channels_gateway_ui.md#http)

### websockets
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `websockets`

파이썬 [WebSocket](05_channels_gateway_ui.md#websocket) 서버/클라이언트 라이브러리 —
[WebSocket Channel](05_channels_gateway_ui.md#websocket-channel)의 구현 재료.

- **관련 용어:** [WebUI](05_channels_gateway_ui.md#webui)

### Rich
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `rich`

터미널에 색·표·마크다운을 렌더링하는 라이브러리. CLI 대화 모드의 출력 품질을 담당합니다.

- **관련 용어:** [Typer](#typer)

### prompt-toolkit
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `prompt-toolkit`

고급 터미널 입력(멀티라인, 히스토리, 자동완성) 라이브러리 — CLI 대화 모드의 입력 담당.

- **관련 용어:** [Rich](#rich)

### questionary
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `questionary`

대화형 선택 프롬프트(화살표로 고르기) 라이브러리 — `nanobot onboard` 마법사에 쓰입니다.

- **관련 용어:** [prompt-toolkit](#prompt-toolkit)

### loguru
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `loguru`

설정이 거의 필요 없는 로깅 라이브러리 — nanobot 전반의 로그 출력을 담당합니다.

### Jinja2
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `jinja2`

`{{ 변수 }}`, `{% if %}` 문법의 텍스트 템플릿 엔진.
[System Prompt](03_memory_context_session.md#system-prompt) 템플릿(`nanobot/templates/`) 렌더링에
사용됩니다 — 프롬프트를 코드에서 분리해 데이터로 관리하게 해 줍니다.

- **관련 용어:** [Bootstrap Templates](03_memory_context_session.md#bootstrap-templates)

### ddgs
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `ddgs`

DuckDuckGo 검색 라이브러리 — API 키 없이 웹 검색을 제공하므로
[Web Tools](02_tools_and_skills.md#web-tools)의 기본 검색 백엔드로 적합합니다.

### dulwich
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `dulwich`

순수 파이썬 [Git](#git) 구현 — git 바이너리 설치 없이 저장소를 다룰 수 있습니다.
[Dream](03_memory_context_session.md#dream)의 diff 검증 같은 내부 Git 조작에 쓰입니다.

- **하위 개념(더 일반):** [Git](#git)

### filelock
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `filelock`

파일 기반 프로세스 간 잠금 라이브러리 — 여러 프로세스가 같은 세션/메모리 파일을 동시에 쓰는
경쟁을 막습니다.

- **관련 용어:** [Atomic Write](03_memory_context_session.md#atomic-write)

### Git
**클래스:** [Technology](00_content_classes.md#technology)

분산 버전 관리 시스템. nanobot에서는 코드 관리를 넘어 **메모리 변경의 감사 추적**으로도 쓰입니다 —
[Dream](03_memory_context_session.md#dream)이 "실제 diff가 있는가"로 작업 진위를 검증합니다.

- **상위 개념(더 특수):** [dulwich](#dulwich)

### ruff
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `ruff`

Rust로 만든 초고속 파이썬 린터/포매터. 이 저장소의 규칙: `E, F, I, N, W`(E501 제외), 라인 길이 100.

- **관련 용어:** [pytest](#pytest)

### pytest
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `pytest`

파이썬 테스트 프레임워크. 이 저장소는 `asyncio_mode = "auto"`로 async 테스트를 데코레이터 없이
지원하며, `tests/`는 `nanobot/` 패키지 구조를 미러링합니다.

- **관련 용어:** [asyncio](#asyncio)

### bun
**클래스:** [Technology](00_content_classes.md#technology)

Node.js 호환의 고속 자바스크립트 런타임 겸 패키지 매니저 —
[WebUI](05_channels_gateway_ui.md#webui)의 설치/빌드/테스트(`bun run build`)에 사용됩니다.

- **관련 용어:** [Vite](#vite)

### Vite
**클래스:** [Technology](00_content_classes.md#technology)

프런트엔드 빌드 도구 — 개발 서버(HMR)와 프로덕션 번들링을 담당합니다.
`webui/vite.config.ts`의 프록시 설정이 개발 중 API/WS 요청을 게이트웨이(:8765)로 넘깁니다.

- **관련 용어:** [bun](#bun), [React (JS)](#react-js)

### React (JS)
**클래스:** [Technology](00_content_classes.md#technology)

컴포넌트 기반 UI 자바스크립트 라이브러리 — [WebUI](05_channels_gateway_ui.md#webui)의 화면 계층.
(AI 논문 [ReAct](08_ai_llm_concepts.md#react)와는 무관합니다.)

- **관련 용어:** [TypeScript](#typescript), [SPA](05_channels_gateway_ui.md#spa)

### TypeScript
**클래스:** [Technology](00_content_classes.md#technology)

자바스크립트에 정적 타입을 더한 언어 — 파이썬 쪽 [Type Hint](#type-hint)+[Pydantic](#pydantic)과
같은 역할을 [WebUI](05_channels_gateway_ui.md#webui)에서 합니다.

- **관련 용어:** [React (JS)](#react-js)
