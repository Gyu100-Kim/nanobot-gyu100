# 02. 기술 스택과 의존성

> **이 문서에서 다루는 큰 맥락**
>
> 코드를 읽기 전에 "이 프로젝트가 어떤 부품(라이브러리)으로 만들어졌는지"를 알면 이해가 훨씬 빠릅니다.
> 이 문서는 <a href="../pyproject.toml">pyproject.toml</a>의 의존성을 **역할별로 분류**하고,
> 무거운/특수한 패키지를 항상 설치하지 않는 **선택 의존성(lazy deps)** 설계와 그 처리 코드
> (`nanobot/optional_features.py`), 그리고 **버전 상·하한 고정 전략**의 트레이드오프를 설명합니다.
>
> 모든 근거는 `pyproject.toml`의 실제 라인과 `nanobot/optional_features.py`의 코드입니다.

## 이 문서의 소목차

1. [필수 의존성 역할별 분류](#필수-의존성-역할별-분류)
2. [선택 의존성(optional-dependencies)과 lazy deps](#선택-의존성optional-dependencies과-lazy-deps)
3. [`optional_features.py`가 선택 의존성을 다루는 방식](#optional_featurespy가-선택-의존성을-다루는-방식)
4. [버전 상·하한 고정 전략과 트레이드오프](#버전-상하한-고정-전략과-트레이드오프)
5. [빌드/린트/테스트 설정](#빌드린트테스트-설정)

---

## 필수 의존성 역할별 분류

`pyproject.toml` L25-L52의 `dependencies`를 역할별로 묶으면 다음과 같습니다. (모든 항목은 실제 파일에 존재)

### LLM SDK
- `anthropic>=0.45.0,<1.0.0` (L27) — Claude 계열 프로바이더용.
- `openai>=2.8.0` (L45) — OpenAI 및 OpenAI 호환 프로바이더용.

### HTTP / 네트워크
- `httpx>=0.28.0,<1.0.0` (L32) — 비동기 HTTP 클라이언트.
- `websockets>=16.0,<17.0` (L30), `websocket-client>=1.9.0,<2.0.0` (L31) — WebSocket(서버/클라이언트).
- `oauth-cli-kit>=0.1.6,<1.0.0` (L34) — OAuth 기반 프로바이더 로그인 지원.

### CLI / UI
- `typer>=0.20.0,<1.0.0` (L26) — CLI 프레임워크(진입점의 `app`).
- `rich>=14.0.0,<15.0.0` (L38) — 터미널 리치 출력.
- `prompt-toolkit>=3.0.50,<4.0.0` (L40), `questionary>=2.0.0,<3.0.0` (L41) — 대화형 프롬프트/온보딩.
- `loguru>=0.7.3,<1.0.0` (L35) — 로깅.

### 데이터 검증 / 설정
- `pydantic>=2.12.0,<3.0.0` (L28), `pydantic-settings>=2.12.0,<3.0.0` (L29) — 설정 스키마(`config/schema.py`).
- `pyyaml>=6.0,<7.0.0` (L49) — 스킬 frontmatter 등 YAML 파싱(`agent/skills.py`에서 사용).
- `json-repair>=0.57.0,<1.0.0` (L43) — LLM이 만든 깨진 JSON 복구.
- `chardet>=3.0.2,<6.0.0` (L44) — 인코딩 감지.
- `packaging>=24.0` (L51) — 버전/요구사항 파싱(`optional_features.py`가 `Requirement`로 사용).

### 스케줄링
- `croniter>=6.0.0,<7.0.0` (L39) — cron 표현식 해석(`nanobot/cron/`).

### 웹 콘텐츠 처리
- `ddgs>=9.5.5,<10.0.0` (L33) — 웹 검색(DuckDuckGo).
- `readability-lxml>=0.8.4,<1.0.0` (L36), `lxml-html-clean>=0.4.0,<1.0.0` (L37) — 웹 페이지 본문 추출/정제.

### MCP / 컨텍스트
- `mcp>=1.26.0,<2.0.0` (L42) — Model Context Protocol 클라이언트([04_mcp](tech_background/04_mcp.md)).
- `tiktoken>=0.12.0,<1.0.0` (L46) — 토큰 계수(컨텍스트 압축 판단; [07](07_prompt_and_context.md)).
- `jinja2>=3.1.0,<4.0.0` (L47) — 프롬프트 템플릿 렌더링(`utils/prompt_templates.py`).

### 기타
- `dulwich>=0.22.0,<1.0.0` (L48) — 순수 파이썬 Git 구현(메모리/스킬 버전 관리, `utils/gitstore.py`).
- `filelock>=3.25.2` (L50) — 파일 잠금(동시 접근 보호).

> **초보자용 정리:** nanobot은 "LLM SDK(anthropic/openai) + 비동기 통신(httpx/websockets) +
> CLI/UI(typer/rich) + 설정 검증(pydantic) + 부가 기능(croniter/mcp/tiktoken/dulwich)"의 조합입니다.
> 무거운 채널·클라우드 SDK는 아래의 선택 의존성으로 분리되어 있습니다.

---

## 선택 의존성(optional-dependencies)과 lazy deps

`pyproject.toml` L54-L145의 `[project.optional-dependencies]`는 **"필요할 때만 설치하는 부가 기능"** 목록입니다.
이를 파이썬 생태계에서는 **extras**라고 부르며, `pip install "nanobot-ai[telegram]"`처럼 설치합니다.

주요 extra(모두 실제 파일에 존재):

| extra | 대표 패키지 | 용도 |
| --- | --- | --- |
| `api` (L55-57) | `aiohttp` | OpenAI 호환 API 서버 |
| `azure` (L58-60) | `azure-identity` | Azure OpenAI 인증 |
| `bedrock` (L61-63) | `boto3` | AWS Bedrock |
| `telegram` (L92-96) | `python-telegram-bot`, `socksio`, `python-socks` | Telegram 채널 |
| `discord` (L116-118) | `discord.py` | Discord 채널 |
| `slack` (L87-91) | `slack-sdk`, `slackify-markdown`, `aiohttp` | Slack 채널 |
| `feishu` (L73-75) | `lark-oapi` | Feishu(Lark) 채널 |
| `matrix` (L109-115) | `matrix-nio`, `aiohttp`, `mistune`, `nh3` | Matrix 채널 |
| `whatsapp` (L119-122) | `neonize`, `segno` | WhatsApp 채널 |
| `dingtalk`(L64), `mochat`(L76), `napcat`(L80), `qq`(L83), `wecom`(L97), `weixin`(L100), `msteams`(L104) | 각 플랫폼 SDK | 각 채널 |
| `documents` (L67-72) | `pypdf`, `python-docx`, `openpyxl`, `python-pptx` | 문서 파싱 |
| `pdf`(L126), `olostep`(L129), `langsmith`(L123) | `pymupdf`, `olostep`, `langsmith` | 각 부가 기능 |
| `dev` (L132-145) | `pytest`, `pytest-asyncio`, `ruff`, ... | 개발/테스트 도구 |

**왜 이렇게 나누는가(설계 의도):** Telegram·Discord·Matrix·Bedrock 등은 각자 무겁고 서로 다른 전이 의존성을
끌고 옵니다. 이를 전부 필수로 두면 "텔레그램만 쓰려는 사용자"도 AWS SDK까지 설치해야 하고, 충돌 위험도 커집니다.
extras로 분리하면 **핵심은 가볍게 유지**하고 **사용자가 쓰는 채널/기능만** 설치할 수 있습니다.

일부 extra는 플랫폼 마커를 씁니다. 예: `matrix`의 `matrix-nio[e2e]`는 `sys_platform != 'win32'`에서만,
`matrix-nio`(비 e2e)는 Windows에서만 설치됩니다(L110-111). telegram의 `python-socks`도 비-Windows 한정(L95).
**왜?** 특정 패키지가 특정 OS에서 빌드/동작이 어렵기 때문입니다.

---

## `optional_features.py`가 선택 의존성을 다루는 방식

`nanobot/optional_features.py`는 위 extras를 **런타임에** 발견·검사·설치·활성화합니다.

- **extra 목록 읽기** — `optional_dependency_groups()`(L73-L83)는 소스 트리의 `pyproject.toml`을 직접 읽어
  `dev`를 제외한 extra별 의존성 리스트를 돌려줍니다. 소스가 아니라 설치된 배포본이면
  `optional_dependency_groups_from_metadata()`(L49-L70)가 패키지 메타데이터(`Provides-Extra`, `requires`)로 대체합니다.
  **왜 두 경로인가:** 개발 체크아웃과 설치 환경 모두에서 동작하게 하기 위함입니다.

- **설치 여부 판별** — `extra_installed()`(L168-L171)는 해당 extra의 모든 요구사항이
  `requirement_installed()`(L164-L165)를 통과하는지 검사합니다. `_requirement_installed()`(L114-L134)는
  `importlib.metadata.distribution()`으로 실제 설치 버전을 찾고, 버전 지정자(`req.specifier`)를 만족하는지,
  중첩 extra까지 설치됐는지 재귀 확인합니다.

- **필요 시 설치** — `install_extra()`(L205-L247)는 `python -m pip install ...`을 서브프로세스로 실행합니다
  (L214). 실패 원인이 "pip 없음"이면 `ensurepip`를 돌린 뒤 한 번 재시도(L228-L241)합니다. 타임아웃은 300초(L36).
  **왜 서브프로세스 pip인가:** 실행 중인 파이썬 인터프리터에 새 패키지를 넣기 위한 표준 방법이기 때문입니다.

- **채널 활성화** — `enable_optional_feature()`(L349-L407)는 (1) 미설치면 설치하고, (2) 내장/플러그인 채널이면
  설정 파일(`config.json`)의 `channels.<name>.enabled = true`를 기록합니다(`enable_channel_config()`, L273-L282).
  원격 WebUI에서의 설치는 기본 금지이며(L372-L378, status 403), 이는 보안 고려입니다([12](12_security_and_sandbox.md)).

- **상태 페이로드** — `optional_features_payload()`(L306-L346)는 WebUI가 표시할 "기능 목록 + 설치/활성 상태"를
  만듭니다. 상태 문자열은 `enabled` / `missing_dependency` / `not_enabled`로 구분됩니다(L325).

> **초보자용 정리:** "이 기능 쓰려는데 패키지가 없다"는 상황을 `optional_features.py`가 감지해
> 안내하거나 자동 설치까지 해줍니다. 덕분에 사용자는 필요할 때 채널을 켜기만 하면 됩니다.

---

## 버전 상·하한 고정 전략과 트레이드오프

`dependencies` 대부분은 `>=X,<Y` 형태로 **하한과 상한을 함께** 둡니다. 예:

- `"anthropic>=0.45.0,<1.0.0"` (L27) — 0.45 이상, 1.0 미만.
- `"pydantic>=2.12.0,<3.0.0"` (L28) — 2.x 계열로 고정.

반면 상한 없이 하한만 둔 것도 있습니다:

- `"openai>=2.8.0"` (L45), `"filelock>=3.25.2"` (L50), `"packaging>=24.0"` (L51).

**의미와 트레이드오프:**

- **하한(`>=`)** 은 "이 버전 미만에는 없는 API/버그픽스가 필요하다"는 최소 요구입니다. 너무 낮으면 미지원 API 사용 위험,
  너무 높으면 다른 패키지와 충돌 위험이 커집니다.
- **상한(`<`)** 은 "다음 메이저 버전에서 호환성이 깨질 수 있으니 미리 막는다"는 방어입니다.
  SemVer 관습상 메이저 버전이 오르면(예: 1.0) 호환성 파괴 변경이 흔하기 때문입니다.
  - 장점: 예상치 못한 상위 버전이 설치돼 갑자기 깨지는 일을 예방(재현성↑).
  - 단점: 새 메이저 버전의 개선/보안 패치를 자동으로 받지 못함(수동 상한 갱신 필요).
- **상한이 없는 경우**(openai 등)는 상위 버전 호환을 신뢰하거나, 자주 갱신되어 상한이 병목이 되는 패키지에 대한 선택입니다.

> 이 방식은 흔히 말하는 완전 고정(exact pinning, `==`)과 다릅니다. `==`는 재현성이 가장 강하지만
> 보안 패치조차 자동으로 못 받습니다. nanobot은 **범위 지정**으로 재현성과 유연성의 중간을 택했습니다.
> 진짜 완전 고정은 lockfile(예: `uv.lock`/`requirements.txt`) 역할이며, `pyproject.toml`은 "허용 범위"를 선언합니다.

---

## 빌드/린트/테스트 설정

- **빌드**: hatchling(`pyproject.toml` L155-157). wheel/sdist에 `nanobot/templates/**/*.md`, `nanobot/skills/**`,
  `nanobot/web/dist/**`를 포함(L166-172). `web/dist`는 git 미추적이라 `artifacts`로 별도 지정(L176-178).
- **린트**: ruff — line-length 100(L198), 규칙 `E, F, I, N, W`(L202), `E501`(줄 길이) 무시(L203).
  실행: `ruff check nanobot/`.
- **테스트**: pytest — `asyncio_mode = "auto"`(L206), `testpaths = ["tests"]`(L207). 커버리지 하한 75%(L214).

다음 문서에서는 이 스택 위에서 프로그램이 실제로 어떻게 시작되는지 봅니다 → [03_entrypoints.md](03_entrypoints.md).
