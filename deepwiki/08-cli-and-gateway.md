# 8. CLI and Gateway (CLI와 게이트웨이)

nanobot의 주요 진입점은 CLI다. `pyproject.toml`의 `[project.scripts]`가 `nanobot = "nanobot.cli.commands:app"`을 등록하고, `app`은 `nanobot/cli/commands.py`의 Typer 애플리케이션이다.

## CLI 구조

`app`은 Typer 앱이며, 서브명령과 서브그룹으로 구성된다.

- 루트 콜백: `@app.callback()` — `--version`/`-v`(`version_callback`) 등 전역 옵션.
- 최상위 명령: `onboard`, `agent`, `serve`, `webui`, `trigger`, `status`.
- 서브그룹(`add_typer`):
  - `gateway` — 게이트웨이 실행/서비스 관리(`nanobot/cli/gateway.py`).
  - `channels` — 채널 상태/로그인(`channels status`, `channels login`).
  - `plugins` — 플러그인 관리(`plugins list/enable/disable`).
  - `provider` — 프로바이더 OAuth(`provider login/logout`).

각 명령은 `--config`/`--workspace`로 인스턴스를 분리할 수 있다([1.1](01.1-getting-started.md)).

## 게이트웨이

`nanobot gateway`는 채널·WebUI·heartbeat·Dream·cron 같은 장기 실행 서비스를 띄우는 런타임이다. 실제 조율은 `AgentLoop`와 백그라운드 서비스가 담당한다([8.2](08.2-gateway-runtime-and-background-services.md)).

## 하위 문서

- [8.1 CLI Commands Reference](08.1-cli-commands-reference.md)
- [8.2 Gateway Runtime and Background Services](08.2-gateway-runtime-and-background-services.md)

### 참조 파일

- `nanobot/cli/commands.py` (`app`, 명령들)
- `nanobot/cli/gateway.py` (`gateway_app`)
- `nanobot/cli/onboard.py`, `stream.py`, `models.py`
- `pyproject.toml` (`[project.scripts]`)
