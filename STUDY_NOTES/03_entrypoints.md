# 03. 진입점 — 프로그램은 어떻게 시작되는가

> **이 문서에서 다루는 큰 맥락**
>
> 어떤 프로그램이든 "실행하면 제일 먼저 실행되는 코드"가 있습니다. nanobot은 CLI(명령줄 도구)로 시작하며,
> 모든 실행 경로는 `nanobot/cli/commands.py`의 Typer 앱(`app`)으로 수렴합니다. 이 문서는
> `nanobot/__main__.py` → `cli/commands.py`로 이어지는 흐름, Typer `app`과 실제 하위 명령들
> (`onboard`, `agent`, `serve`, `webui`, `trigger`, `status`, 그리고 sub-typer인 `gateway`/`channels`/
> `plugins`/`provider`), `[project.scripts]` 연결, 그리고 `cli/` 하위 보조 모듈들의 역할을
> 라인 근거와 함께 설명합니다.
>
> **정확성 참고:** 사용자 초기 계획에는 `models`라는 명령이 언급되었지만, 실제 저장소에서
> `nanobot/cli/models.py`는 **명령이 아니라 온보딩용 헬퍼 모듈**이며 현재 스텁 상태입니다
> (아래 [cli/models.py](#climodelspy--모델-정보-헬퍼스텁) 참고). 추측 대신 실제 코드에 근거합니다.

## 이 문서의 소목차

1. [두 진입 경로: 콘솔 스크립트와 `python -m`](#두-진입-경로-콘솔-스크립트와-python--m)
2. [`nanobot/__main__.py` 라인바이라인](#nanobot__main__py-라인바이라인)
3. [Typer `app` 정의](#typer-app-정의)
4. [최상위 명령들](#최상위-명령들)
5. [Sub-typer 명령 그룹들](#sub-typer-명령-그룹들)
6. [`cli/` 보조 모듈들의 역할](#cli-보조-모듈들의-역할)

---

## 두 진입 경로: 콘솔 스크립트와 `python -m`

- **콘솔 스크립트** — `pyproject.toml` L147-L148:
  ```toml
  [project.scripts]
  nanobot = "nanobot.cli.commands:app"
  ```
  패키지를 설치하면 `nanobot`이라는 실행 파일이 생기고, 실행 시 `nanobot.cli.commands` 모듈의 `app` 객체를 호출합니다.
- **모듈 실행** — `python -m nanobot`은 `nanobot/__main__.py`를 실행합니다.

두 경로 모두 결국 **`cli/commands.py`의 Typer `app`** 을 실행합니다.

> 참고: CLI 외에 **Python SDK 진입점**도 있습니다 — `nanobot/nanobot.py`의 `Nanobot` 클래스
> (AGENTS.md "Entry Points"). 코드에서 nanobot을 라이브러리로 임베드할 때 씁니다([13](13_api_sdk_webui.md) 참고).

---

## `nanobot/__main__.py` 라인바이라인

파일 전체는 다음과 같습니다.

```python
from nanobot.cli.commands import app

if __name__ == "__main__":
    app()
```

- 1행: `cli/commands.py`에서 Typer 앱 객체 `app`을 가져옵니다.
- 3-4행: 이 파일이 `python -m nanobot`으로 직접 실행될 때만(`__name__ == "__main__"`) `app()`을 호출합니다.
  import만 될 때는 실행되지 않습니다.

**왜 이렇게 얇은가:** 진입점 파일은 "어디로 들어가는지"만 정의하고, 실제 로직은 `cli/commands.py`에 모아두는
관례입니다. 덕분에 콘솔 스크립트 경로와 `python -m` 경로가 같은 코드를 공유합니다.

---

## Typer `app` 정의

`cli/commands.py` L195-L200:

```python
app = typer.Typer(
    name="nanobot",
    context_settings={"help_option_names": ["-h", "--help"]},
    help=f"{__logo__} nanobot - Personal AI Assistant",
    no_args_is_help=True,
)
```

- `typer.Typer(...)`는 하위 명령을 담는 CLI 애플리케이션입니다.
- `no_args_is_help=True`(L199): 인자 없이 `nanobot`만 치면 도움말을 보여줍니다.
- `-h`/`--help`를 도움말 옵션으로 등록(L197).

파일 상단에서는 실행에 필요한 사전 작업도 합니다:
- **Windows UTF-8 강제**(L14-L20): 콘솔 인코딩이 utf-8이 아니면 재설정. 이모지/다국어 입력 깨짐 방지.
- **로깅 설정**(L27-L39): 기본 loguru 핸들러를 제거하고 nanobot 통일 포맷으로 재등록.
- **`@app.callback()` `main`**(L580-L587): 모든 명령 공통 옵션. `--version`/`-v`(L582-584)를 주면
  `version_callback`(L574-577)이 버전을 찍고 종료합니다.

---

## 최상위 명령들

각 명령은 `@app.command()` 데코레이터로 등록됩니다. 실제 정의 위치(라인)와 역할:

| 명령 | 정의 | 역할(docstring 근거) |
| --- | --- | --- |
| `onboard` | L595-596 | 대화형 설정 마법사. 워크스페이스/설정 파일을 초기화(`--workspace`, `--config`). 실제 질문 흐름은 `cli/onboard.py`. |
| `trigger` | L1070-1071 | "로컬 트리거" 메시지를 그 트리거에 묶인 채팅 세션으로 전달("Deliver a local trigger message to its bound chat session", L1077). `triggers/local_store.py` 사용. |
| `serve` | L1104-1105 | **OpenAI 호환 API 서버** 시작("/v1/chat/completions", L1113). `aiohttp` 필요(없으면 `nanobot plugins enable api` 안내, L1117). `nanobot/api/server.py`의 `create_app` 사용(L1120). |
| `webui` | L1187-1188 | 로컬 WebUI 준비 + 게이트웨이 시작 + 브라우저 열기("Prepare the local WebUI, start the gateway, and open the browser workbench", L1206). |
| `agent` | L1829-1830 | 에이전트와 **직접 대화**("Interact with the agent directly", L1838). `--message/-m`로 단발 질의, 없으면 대화형 REPL. 기본 세션 `cli:direct`(L1832). |
| `status` | L2252-2253 | 현재 설정/프로바이더 상태 표시. |

> 예: `nanobot agent -m "안녕"` 은 한 번 질의하고 답을 출력하며, `nanobot agent` 는 대화형 셸을 엽니다.

### `agent` 명령이 조립하는 것

`agent` 명령(L1829~)은 실행 시 다음을 import·구성합니다(L1839-1841 등):
- `MessageBus`(`bus/queue.py`) — inbound/outbound 큐.
- `CronService`(`cron/service.py`) — 스케줄 작업.
- `AgentLoop`(`agent/loop.py`, 파일 상단 L64에서 import) — 실제 턴 처리.

즉 `agent` 명령은 "CLI를 하나의 채널처럼" 두고 `MessageBus` → `AgentLoop`로 메시지를 흘려보내는
최소 실행 환경을 만듭니다. 이 흐름의 내부는 [04_agent_loop.md](04_agent_loop.md)에서 다룹니다.

---

## Sub-typer 명령 그룹들

일부 기능은 하위 그룹으로 묶여 `app.add_typer(...)`로 등록됩니다.

### `gateway` 그룹 (L1813-1821)

`create_gateway_app(...)`(`cli/gateway.py` L35)로 만든 Typer를 `name="gateway"`로 붙입니다.
`nanobot gateway`는 인자 없이도 실행 가능(`invoke_without_command=True`, `cli/gateway.py` L46)하며
전경(foreground) 게이트웨이를 띄웁니다. 하위 명령(`cli/gateway.py`):
- `status`(L163-164), `logs`(L171-172), `stop`(L189-190), `restart`(L205-206),
  `install-service`(L232-233), `uninstall-service`(L268-269).

게이트웨이는 장기 실행 오케스트레이터입니다([10_gateway_and_channels.md](10_gateway_and_channels.md)).

### `channels` 그룹 (L2105)

`app.add_typer(channels_app, name="channels")`. 하위: `channels_status`(L2109), `channels_login`(L2138).
채널 상태 확인과 로그인(예: WhatsApp/Weixin QR 로그인 등)을 담당합니다.

### `plugins` 그룹 (L2172)

`app.add_typer(plugins_app, name="plugins")`. 하위: `plugins_list`(L2176), `plugins_enable`(L2196),
`plugins_disable`(L2225). 앞서 [02](02_modules_and_stack.md)에서 본 선택 기능(extras/채널)을
켜고 끕니다 — 내부적으로 `nanobot/optional_features.py`를 호출합니다.

### `provider` 그룹 (L2298)

`app.add_typer(provider_app, name="provider")`. 하위: `provider_login`(L2375), `provider_logout`(L2406).
OAuth 기반 프로바이더(OpenAI Codex, GitHub Copilot; L2304-2307)의 로그인/로그아웃을 처리합니다.

---

## `cli/` 보조 모듈들의 역할

`cli/` 디렉토리의 나머지 파일들은 `commands.py`가 쓰는 부품입니다.

### `cli/gateway.py` — 게이트웨이 Typer 팩토리
`create_gateway_app(...)`(L35-)가 게이트웨이 관련 Typer를 만들어 돌려줍니다. 명령 처리 함수와
게이트웨이 런타임(`GatewayRuntime`) 연결, 서비스 설치(systemd 등)를 포함합니다. `commands.py`는
이 팩토리를 호출해 `gateway` 하위 그룹을 얻습니다(L1813-1821).

### `cli/onboard.py` — 대화형 온보딩 마법사
파일 첫 줄 "Interactive onboarding questionnaire for nanobot"(L1). `questionary`로 프로바이더/모델/채널을
질문하며 `config.json`을 만듭니다. `questionary` 미설치 환경에 대비해 import를 `try/except`로 감쌉니다(L10-13).

### `cli/models.py` — 모델 정보 헬퍼(스텁)
파일 docstring(L1-6): "Model database / autocomplete is temporarily disabled while litellm is being replaced.
All public function signatures are preserved so callers continue to work without changes." 즉 현재
`get_all_models()`는 `[]`(L13-14), `find_model_info()`는 `None`(L17-18)을 돌려주는 **의도적 스텁**입니다.
온보딩 마법사(`onboard.py` L20-24)가 이 함수들을 호출하지만, 실제 모델 자동완성은 비활성 상태입니다.
**설계 의도:** 외부 라이브러리(litellm) 교체 중에도 호출부가 깨지지 않도록 시그니처만 유지한 것입니다.

### `cli/stream.py` — CLI 스트리밍 렌더러
파일 docstring(L1-8): Rich `Live`(`transient=True`)로 스트리밍 중 마크다운을 제자리 갱신하고,
스트리밍 종료 후 최종본을 다시 렌더해 화면에 남깁니다. `StreamRenderer`, `ThinkingSpinner`를 제공하며
`commands.py`가 대화형 출력에 사용합니다(L74에서 import).

---

다음 문서에서는 이 진입점들이 도달하는 심장부, 에이전트 루프를 봅니다 → [04_agent_loop.md](04_agent_loop.md).
