# 01. 전체 소스코드 구조 개요

> **이 문서에서 다루는 큰 맥락**
>
> nanobot 저장소를 처음 열면 파일이 수백 개라 어디부터 봐야 할지 막막합니다. 이 문서는
> **"숲을 먼저 본 뒤 나무로 내려가기"** 위해, `nanobot/` 패키지의 디렉토리 지도와 최상위 모듈,
> 프로그램이 시작되는 진입점, 사용 언어를 정리합니다. 각 디렉토리가 어떤 책임을 지는지 한 줄로 파악하고,
> 이후 문서에서 그 디렉토리를 깊게 파고들 수 있게 하는 것이 목표입니다.
>
> 근거 문서: <a href="../AGENTS.md">AGENTS.md</a>(High-Level Architecture),
> <a href="../docs/architecture.md">docs/architecture.md</a>, <a href="../pyproject.toml">pyproject.toml</a>.

## 비유로 먼저 이해하기 — 큰 건물의 층별 안내도

처음 보는 큰 건물에 들어가면 먼저 **층별 안내도**를 봅니다. 이 문서가 바로 nanobot이라는
건물의 층별 안내도입니다. 수백 개의 파일을 하나하나 보기 전에, "몇 층에 어떤 부서가 있는지"만
먼저 파악하는 것입니다.

- `nanobot/` 폴더가 건물 본관입니다. 그 안의 폴더 하나하나가 "부서 사무실"입니다.
  예: `agent/`는 두뇌 부서, `channels/`는 안내 데스크 부서, `providers/`는 외부 AI 연결 부서.
- `webui/`는 별관(웹 화면을 만드는 곳), `docs/`는 안내 책자, `tests/`는 품질 검사실입니다.
- "진입점(entry point)"이란 **건물의 정문**입니다. 어떤 문으로 들어와도
  결국 `nanobot/cli/commands.py`라는 로비로 모이게 되어 있습니다.

읽는 요령: 아래 디렉토리 지도 표에서 각 폴더의 "한 줄 책임"만 눈에 익혀 두세요.
지금 다 외울 필요는 전혀 없습니다. 뒤의 문서를 읽다가 "이 파일이 어디 소속이지?" 싶을 때
다시 돌아와 지도를 보면 됩니다.

**꼭 가져가야 할 것 3가지**

1. 코드 본체는 `nanobot/` 패키지이고, 폴더 이름이 곧 역할이다.
2. 정문(진입점)은 두 개(`nanobot` 명령, `python -m nanobot`)지만 모두 `cli/commands.py`로 모인다.
3. 본체는 Python(3.11+), 웹 화면은 TypeScript/React(bun으로 빌드)라는 두 언어로 되어 있다.

---

## 이 문서의 소목차

1. [저장소 최상위 레이아웃](#저장소-최상위-레이아웃)
2. [`nanobot/` 패키지 디렉토리 지도](#nanobot-패키지-디렉토리-지도)
3. [최상위 모듈 5종](#최상위-모듈-5종)
4. [진입점: 프로그램은 어디서 시작되는가](#진입점-프로그램은-어디서-시작되는가)
5. [사용 언어와 빌드](#사용-언어와-빌드)
6. [다음 문서로](#다음-문서로)

---

## 저장소 최상위 레이아웃

저장소 루트에는 다음이 있습니다(핵심만 발췌).

- `nanobot/` — 파이썬 패키지 본체(이 학습 노트의 주 대상).
- `webui/` — React/TypeScript 기반 WebUI[(용어사전)](../dict/05_channels_gateway_ui.md#webui) 소스(빌드하면 `nanobot/web/dist/`로 번들됨).
- `docs/` — 공식 문서(architecture, concepts, providers, channels 등).
- `tests/` — 테스트. `nanobot/` 패키지 구조를 그대로 미러링(근거: <a href="../AGENTS.md">AGENTS.md</a> "Tests mirror the `nanobot/` package structure").
- `pyproject.toml` — 프로젝트 메타데이터/의존성/빌드 설정.
- `AGENTS.md`, `CLAUDE.md` — AI 코딩 에이전트용 가이드(`CLAUDE.md`는 `@AGENTS.md` 한 줄만 포함).
- `.agent/` — 아키텍처 제약(`design.md`), 보안 경계(`security.md`), 흔한 함정(`gotchas.md`) 문서.
  AGENTS.md의 "Project-Specific Notes"가 이 세 파일을 가리킵니다. 코드 수정 전 반드시 읽어볼 가치가 있습니다.
- `Dockerfile`, `docker-compose.yml`, `entrypoint.sh` — 컨테이너 배포용.
- `hatch_build.py` — hatchling[(용어사전)](../dict/09_dev_stack.md#hatchling) 커스텀 빌드 훅(`pyproject.toml` L162-163에서 참조).

> 참고: `nanobot`의 배포 패키지 이름은 `nanobot-ai`이고(`pyproject.toml` L2), import 이름은 `nanobot`입니다.

---

## `nanobot/` 패키지 디렉토리 지도

아래는 `nanobot/` 바로 아래의 서브패키지와 그 책임입니다. (실제 `ls nanobot/` 결과에 근거)

| 디렉토리 | 한 줄 책임 | 자세히 다루는 문서 |
| --- | --- | --- |
| `agent/` | 에이전트 두뇌. 턴 상태머신(`loop.py`), LLM/도구 루프(`runner.py`), 컨텍스트/메모리/스킬/서브에이전트 | [04](04_agent_loop.md), [07](07_prompt_and_context.md), [08](08_memory_and_dream.md) |
| `agent/tools/` | LLM이 호출하는 도구들(filesystem, shell, web, mcp, spawn, cron ...)과 등록/발견 인프라 | [05](05_tools.md) |
| `api/` | OpenAI 호환 HTTP[(용어사전)](../dict/05_channels_gateway_ui.md#http) API 서버(`server.py`) | [13](13_api_sdk_webui.md) |
| `apps/` | CLI 앱 프로토콜/유틸(`apps/cli`, `protocol.py`) — 채널로서의 CLI 표현 | [10](10_gateway_and_channels.md), [13](13_api_sdk_webui.md) |
| `audio/` | 음성 전사(transcription) 추상화와 레지스트리 | [09](09_providers.md) |
| `bus/` | `MessageBus`(inbound/outbound 큐)와 이벤트 정의(`events.py`, `queue.py`) | [04](04_agent_loop.md) |
| `channels/` | 외부 채팅 플랫폼 연동(telegram, discord, slack, feishu, matrix, whatsapp, qq, wecom, weixin, dingtalk, email, mochat, msteams, mattermost, napcat, signal, websocket) | [10](10_gateway_and_channels.md) |
| `cli/` | Typer[(용어사전)](../dict/09_dev_stack.md#typer) 기반 CLI(`commands.py`)와 하위 명령 모듈(`gateway.py`, `models.py`, `onboard.py`, `stream.py`) | [03](03_entrypoints.md) |
| `command/` | 슬래시 명령 라우팅(`router.py`)과 내장 명령(`builtin.py`) | [03](03_entrypoints.md) |
| `config/` | Pydantic[(용어사전)](../dict/09_dev_stack.md#pydantic) 기반 설정 스키마(`schema.py`), 로더(`loader.py`), 경로(`paths.py`) | [02](02_modules_and_stack.md), [06](06_state_and_persistence.md) |
| `cron/` | 스케줄링 서비스(`service.py`), 타입(`types.py`), 실행 연결(`bound_runner.py`, `session_delivery.py` ...) | [11](11_cron_and_triggers.md) |
| `gateway/` | 장기 실행 오케스트레이터(`runtime.py`, `service.py`) | [10](10_gateway_and_channels.md) |
| `pairing/` | DM 발신자 승인(pairing) 저장소(`store.py`) | [10](10_gateway_and_channels.md), [12](12_security_and_sandbox.md) |
| `providers/` | LLM[(용어사전)](../dict/08_ai_llm_concepts.md#llm) 프로바이더: base/registry/factory/fallback과 구현체(anthropic, openai_compat, azure, bedrock, github_copilot, openai_codex, openai_responses ...) | [09](09_providers.md) |
| `sdk/` | Python SDK 내부(clients, runtime, streaming, types) | [13](13_api_sdk_webui.md) |
| `security/` | 워크스페이스 접근/정책(`workspace_access.py`, `workspace_policy.py`), 네트워크/SSRF(`network.py`) | [12](12_security_and_sandbox.md) |
| `session/` | 세션 관리(`manager.py`), 세션 키(`keys.py`), 턴 연속성/가시성/목표 상태 | [06](06_state_and_persistence.md) |
| `skills/` | 내장 스킬 마크다운(skill-creator[(용어사전)](../dict/02_tools_and_skills.md#skill-creator), memory, summarize, long-goal, cron, github, image-generation ...) | [08](08_memory_and_dream.md) |
| `templates/` | 부트스트랩/시스템 프롬프트 자료(AGENTS.md, SOUL.md[(용어사전)](../dict/03_memory_context_session.md#soulmd), USER.md[(용어사전)](../dict/03_memory_context_session.md#usermd), HEARTBEAT.md[(용어사전)](../dict/06_scheduling_automation.md#heartbeatmd), `agent/`, `memory/`, `prompts/`) | [07](07_prompt_and_context.md) |
| `triggers/` | 로컬 트리거(`local_runner.py`, `local_store.py`, `local_types.py` ...) | [11](11_cron_and_triggers.md) |
| `utils/` | 공통 유틸(helpers, gitstore, prompt_templates, file_edit_events, runtime ...) | 여러 문서에서 참조 |
| `web/` | 번들된 WebUI 산출물이 놓이는 자리(`web/dist/`는 bun[(용어사전)](../dict/09_dev_stack.md#bun) 빌드 산출물) | [13](13_api_sdk_webui.md) |
| `webui/` | WebUI를 게이트웨이에 붙이는 파이썬 측 API/WS 어댑터(settings_api, media_api, websocket_logging ...) | [13](13_api_sdk_webui.md) |

> **주의(추측 금지 원칙):** 위 표의 디렉토리·파일 이름은 모두 실제 `ls` 결과에 근거합니다.
> 사용자 원 계획에 있던 일부 이름(예: FTS5 세션 검색 등)은 이 저장소에 존재하지 않으므로 표에 넣지 않았습니다.

---

## 최상위 모듈 5종

`nanobot/` 바로 아래(서브패키지가 아닌) 핵심 파일 5개입니다.

1. **`nanobot/__init__.py`** — 패키지 초기화. 버전 해석과 **지연 export**를 담당합니다.
   - `_resolve_version()`(L20-L25): 설치된 dist 메타데이터에서 버전을 읽고, 소스 체크아웃이면
     `pyproject.toml`에서 직접 읽습니다(`_read_pyproject_version()`, L11-L17). 마지막 폴백은 `"0.2.2"`.
   - `__getattr__`(L53-L61) + `_LAZY_EXPORTS`(L31-L50): `import nanobot; nanobot.Nanobot`처럼 접근할 때
     비로소 `.nanobot` 모듈을 import합니다. **왜?** 패키지 import 시 무거운 하위 모듈까지 전부 로드하지 않기 위한
     지연 로딩 패턴입니다(시작 속도/의존성 부담 감소).

2. **`nanobot/__main__.py`** — `python -m nanobot`로 실행될 때의 진입점. `from nanobot.cli.commands import app`
   후 `app()`을 호출하는 3줄짜리 얇은 파일입니다([03](03_entrypoints.md)에서 라인바이라인).

3. **`nanobot/nanobot.py`** — **프로그래밍용 고수준 인터페이스(Python SDK)**. `Nanobot` 클래스와
   `RunStream`/`RunResult` 등을 제공합니다(파일 첫 줄 docstring "High-level programmatic interface to nanobot",
   `AgentLoop`·SDK 런타임을 조합). 자세한 내용은 [13](13_api_sdk_webui.md).

4. **`nanobot/config_base.py`** — 설정 모델의 기반 클래스 `Base`. camelCase/snake_case 키를 모두 받도록
   `alias_generator=to_camel, populate_by_name=True`를 설정합니다. **왜?** 설정 파일은 JSON(camelCase 관습)이지만
   파이썬 코드는 snake_case를 쓰므로 둘 다 허용하기 위함입니다([02](02_modules_and_stack.md), [06](06_state_and_persistence.md)).

5. **`nanobot/optional_features.py`** — **선택 기능(lazy deps) 관리**. `pyproject.toml`의
   `optional-dependencies`를 읽어(`optional_dependency_groups()`, L73-L83) 어떤 extra가 설치됐는지 판별하고
   (`extra_installed()`, L168-L171), 필요 시 `pip install`을 실행(`install_extra()`, L205-L247)합니다.
   또한 채널 활성화/비활성화(`enable_optional_feature`/`disable_optional_feature`)도 담당합니다.
   자세한 lazy deps 설계는 [02](02_modules_and_stack.md).

---

## 진입점: 프로그램은 어디서 시작되는가

두 가지 진입 경로가 있습니다(근거: `pyproject.toml` L147-L148, `nanobot/__main__.py`).

- **콘솔 스크립트**: `pyproject.toml`의 `[project.scripts]`에 `nanobot = "nanobot.cli.commands:app"`이 있어,
  설치 후 `nanobot` 명령이 곧바로 `nanobot/cli/commands.py`의 Typer `app`을 실행합니다.
- **모듈 실행**: `python -m nanobot`은 `nanobot/__main__.py`를 실행하고, 이 파일이 동일한 `app()`을 호출합니다.

즉 **어느 경로로 들어와도 `nanobot/cli/commands.py`의 Typer `app`으로 수렴**합니다. 그 안에서 `agent`,
`gateway`, `onboard`, `serve`, `webui`, `status` 등의 하위 명령이 갈라집니다([03](03_entrypoints.md)에서 상세).
(참고: `cli/models.py`는 하위 명령이 아니라 온보딩용 헬퍼 스텁입니다 — [03](03_entrypoints.md) 참고.)

---

## 사용 언어와 빌드

- **Python `>=3.11`** — `pyproject.toml` L6 `requires-python = ">=3.11"`. asyncio를 전면적으로 사용합니다
  (근거: <a href="../AGENTS.md">AGENTS.md</a> "Python 3.11+, asyncio throughout").
- **WebUI는 JS/TS + bun** — `webui/`에서 `bun run build`로 빌드하며 산출물이 `nanobot/web/dist/`로 들어갑니다
  (근거: <a href="../AGENTS.md">AGENTS.md</a> "Build outputs to ../nanobot/web/dist", `pyproject.toml` L171-L178).
- **빌드 백엔드는 hatchling** — `pyproject.toml` L155-L157. `nanobot/web/dist/`는 git이 추적하지 않지만
  `artifacts`로 지정해 wheel/sdist에 포함시킵니다(L176-L178).
- **린트/테스트** — ruff[(용어사전)](../dict/09_dev_stack.md#ruff)(line-length 100, 규칙 E/F/I/N/W, E501 무시; L197-L203), pytest[(용어사전)](../dict/09_dev_stack.md#pytest)(`asyncio_mode = "auto"`; L205-L207).

---

## 실전 예제로 차근차근 따라가기 — 지도 한 장으로 파일 찾아가기

지도를 읽는 연습을 해 봅시다. 질문: "Telegram으로 온 메시지에 AI가 답하기까지,
어느 부서(폴더)들을 지나갈까?"

**1단계 — 문으로 들어온다.** Telegram 연동 코드는 어디에? 표에서 "외부 채팅 플랫폼
연동"을 찾으면 `channels/`입니다. 즉 `nanobot/channels/telegram/` 근처에 있겠구나,
하고 짐작할 수 있습니다.

**2단계 — 접수함을 거친다.** 채널이 받은 메시지는 큐(대기줄)에 들어갑니다.
"inbound/outbound 큐"라는 설명이 붙은 `bus/`가 그 접수함입니다.

**3단계 — 두뇌가 처리한다.** 메시지를 꺼내 생각하고 도구를 쓰는 곳은 "에이전트 두뇌"
`agent/`, 그중에서도 턴 처리는 `agent/loop.py`와 `agent/runner.py`입니다.
AI 회사에 실제로 전화를 거는 부분은 "LLM 프로바이더" `providers/`이고,
파일 읽기 같은 손발은 `agent/tools/`입니다.

**4단계 — 기록하고 답장한다.** 대화 기록은 "세션 관리" `session/`에 저장되고,
답장은 다시 `bus/` → `channels/`를 거쳐 Telegram으로 나갑니다.

이렇게 **"기능 이름 → 폴더 이름"으로 위치를 짐작하는 것**이 이 지도의 사용법입니다.
polling이니 웹훅이니 하는 세부는 몰라도, "어느 방에 가면 그 코드가 있는지"를
아는 것만으로 이후 문서들이 훨씬 편해집니다.

---

## 다음 문서로

- 기술 스택과 의존성 분류가 궁금하면 → [02_modules_and_stack.md](02_modules_and_stack.md)
- 프로그램 실행 흐름(진입점)을 코드로 따라가려면 → [03_entrypoints.md](03_entrypoints.md)
- 곧바로 에이전트 두뇌로 뛰어들려면 → [04_agent_loop.md](04_agent_loop.md)
