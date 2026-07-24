# 6. Tools (도구)

도구는 LLM에게 노출되는 에이전트의 능력이다. 파일 읽기/쓰기, shell 실행, 웹 검색/조회, MCP 서버 호출, cron, 이미지 생성, 서브에이전트 스폰 등이 모두 도구다. 구현은 `nanobot/agent/tools/` 아래에 있다.

## 도구 계약 (`base.py`)

모든 도구는 `Tool` 베이스를 상속한다(`nanobot/agent/tools/base.py`).

- `Schema` — 파라미터 스키마. JSON schema를 생성하고(`to_json_schema`), 입력을 검증·형변환(`validate`, `_cast`)한다.
- `ToolResult` — 실행 결과(성공/오류, 콘텐츠, 메타데이터).
- `Tool` 속성/메서드:
  - `name`, `description`, `parameters` — 모델에 노출되는 스키마.
  - `execute(**kwargs) -> ToolResult` — 실제 동작(추상).
  - `read_only` — 읽기 전용 여부(병렬 실행 안전성 판단).
  - `concurrency_safe` — 동시 실행 가능 여부.
  - `exclusive` — 배타 실행 필요 여부.

러너는 이 속성으로 도구 배치를 나눠 병렬/순차 실행한다(`AgentRunner._partition_tool_batches`, [3.2](03.2-agent-runner-and-llm-provider-interface.md)).

`ContextAware` 계열 도구는 `set_context(ctx)`로 현재 요청 컨텍스트(채널, chat_id, session_key, 워크스페이스)를 받는다.

## 레지스트리와 로더

- `ToolRegistry`(`registry.py`) — 도구 등록/조회/스키마 생성/실행을 관리. `register(tool)`, `get(name)`, `definitions()`(모델에 보낼 도구 목록), `execute(name, args)`.
- `ToolLoader`(`loader.py`) — 내장 도구 모듈을 `pkgutil`로 스캔하고, 엔트리포인트 플러그인을 발견해 로드. `load(ctx, registry, scope=...)`로 스코프(예: `subagent`)에 맞춰 도구를 등록.
- `ToolContext`(`context.py`) — 도구 로딩에 필요한 컨텍스트(config, workspace, file state store, 샌드박스 상태).

## 도구 카테고리

| 카테고리 | 파일 | 대표 도구 |
|---|---|---|
| Filesystem | `filesystem.py`, `search.py`, `apply_patch.py` | `read_file`, `write_file`, `edit_file`, `find_files`, `grep` |
| Shell | `shell.py`, `exec_session.py`, `sandbox.py` | `exec` |
| Web / Search | `web.py` | `web_search`, `web_fetch` |
| MCP | `mcp.py` | 동적으로 래핑된 MCP 도구/리소스 |
| Cron | `cron.py` | `cron` |
| Image | `image_generation.py` | `image_generation` |
| Subagent | `spawn.py` | `spawn` |
| Long task | `long_task.py` | 지속 목표(long-goal) |
| Messaging | `message.py` | `message` |
| Self / Runtime | `self.py`, `runtime_state.py` | `my` |
| CLI apps | `cli_apps.py` | CLI 앱 실행 |

## 하위 문서

- [6.1 Shell Execution and Filesystem Tools](06.1-shell-execution-and-filesystem-tools.md)
- [6.2 Web, Search, and MCP Tools](06.2-web-search-and-mcp-tools.md)
- [6.3 Cron, Image Generation, and Other Tools](06.3-cron-image-generation-and-other-tools.md)

### 참조 파일

- `nanobot/agent/tools/base.py`, `registry.py`, `loader.py`, `context.py`
- `nanobot/agent/tools/*.py`
