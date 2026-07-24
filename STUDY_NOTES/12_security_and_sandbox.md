# 12. 보안과 격리 — 에이전트를 안전하게 가두기

> **이 문서에서 다루는 큰 맥락**
>
> 에이전트는 셸을 실행하고 파일을 읽고 웹을 가져옵니다 — 강력하지만 위험합니다. nanobot은 세 겹으로 방어합니다:
> (1) **워크스페이스 스코프** — 파일 접근을 정해진 폴더 안으로 제한(`security/workspace_policy.py`,
> `workspace_access.py`), (2) **네트워크 SSRF 방어** — 내부/사설 주소로의 요청 차단(`security/network.py`),
> (3) **셸 샌드박싱** — bubblewrap 등으로 명령 실행을 격리(`agent/tools/sandbox.py`, `shell.py`, `exec_session.py`).
> 단, 애플리케이션 수준 가드는 OS 샌드박스를 대체하지 않는다는 점을 코드가 명시합니다(`workspace_policy.py` docstring).

## 이 문서의 소목차

1. [세 겹 방어 개요](#세-겹-방어-개요)
2. [워크스페이스 경계: `workspace_policy.py`](#워크스페이스-경계-workspace_policypy)
3. [워크스페이스 스코프: `workspace_access.py`](#워크스페이스-스코프-workspace_accesspy)
4. [네트워크 SSRF 방어: `network.py` 라인바이라인](#네트워크-ssrf-방어-networkpy-라인바이라인)
5. [셸 샌드박스: `sandbox.py`의 bubblewrap](#셸-샌드박스-sandboxpy의-bubblewrap)
6. [`shell.py`와 `exec_session.py`](#shellpy와-exec_sessionpy)

---

## 세 겹 방어 개요

- **파일 경계**(무엇을 읽고 쓸 수 있나): `workspace_policy.py` + `workspace_access.py`.
- **네트워크 경계**(어디로 요청할 수 있나): `network.py`의 SSRF 검사.
- **실행 경계**(셸이 무엇을 만질 수 있나): `sandbox.py`의 bubblewrap 래핑 + `shell.py`/`exec_session.py`의 타임아웃/스코프.

`workspace_policy.py`의 모듈 docstring이 철학을 요약합니다: "These helpers are application-level guards. … they are
**not a replacement for an OS sandbox**." 즉 이 가드들은 실수/우발적 접근을 막는 1차 방어이고, 진짜 격리는
OS 샌드박스(bubblewrap/macOS App Sandbox)가 맡습니다.

---

## 워크스페이스 경계: `workspace_policy.py`

파일 경로가 워크스페이스 밖으로 나가지 못하게 하는 헬퍼입니다.

- `WorkspaceBoundaryError`(L20-): 경계 위반 시 던지는 `PermissionError` 하위 예외.
- `resolve_path(path, workspace, strict=False)`(L24-29): 경로를 절대경로로 정규화(`.resolve()`).
  **왜 resolve?** `../../etc/passwd` 같은 상대 경로 트릭을 실제 경로로 펼쳐서 판단하기 위함입니다.
- `is_path_within(path, root)`(L44-): 경로가 root(워크스페이스) 이하인지 판단.
  - L47-49 — 양쪽을 `expanduser().resolve()`한 뒤 `relative_to(resolved_root)`가 성공하면 내부, 실패(ValueError)면 외부.
  - **왜 relative_to인가:** 심볼릭 링크/`..`를 모두 펼친 절대경로끼리 비교하므로, 문자열 비교보다 안전하게 "정말
    그 폴더 안인지"를 판정합니다.

파일 도구(`filesystem.py`, [05](05_tools.md))는 이 헬퍼로 매 접근을 검사해 워크스페이스 밖 파일을 거부합니다.

---

## 워크스페이스 스코프: `workspace_access.py`

"지금 이 실행이 어떤 접근 권한을 갖는가"를 **컨텍스트 변수**로 관리합니다(L1 "Workspace access scope and sandbox
capability helpers").

- `_CURRENT_WORKSPACE_SCOPE: ContextVar[...]`(L24-): 현재 스코프를 담는 `ContextVar`. **왜 ContextVar인가:**
  asyncio에서 동시에 여러 턴/서브에이전트가 돌 때, 각 실행 문맥이 서로 다른 스코프를 안전하게 가질 수 있습니다
  (전역 변수와 달리 태스크별로 격리).
- `WorkspaceScopeError`(L30-): 스코프 위반 예외.
- `WorkspaceSandboxStatus`(L42-43): 현재 OS 샌드박스 상태(예: `macos_app_sandbox`, L20)를 런타임 표시/도구에 제공.
- `WorkspaceScope`(L66-): 워크스페이스 경로 + 샌드박스 상태 등을 묶은 스코프 객체.

이 스코프는 [05](05_tools.md)에서 본 도구의 `_scopes`(`{"core", "subagent", "memory"}` 등)와 연동되어,
어떤 실행에서 어떤 도구가 허용되는지 결정합니다(예: Dream은 파일 편집 도구만).

---

## 네트워크 SSRF 방어: `network.py` 라인바이라인

**SSRF(Server-Side Request Forgery)**: 공격자가 서버를 꼬드겨 내부망(사내 서버, 클라우드 메타데이터 `169.254.169.254` 등)에
요청을 보내게 하는 공격. 웹 도구가 임의 URL을 가져오므로 반드시 막아야 합니다(L1 docstring).

`resolve_url_target(url, allow_loopback=False)`(L64-107):
- **L80-81** — 스킴이 `http`/`https`가 아니면 거부(`file://`, `gopher://` 등 차단).
- **L82-87** — 도메인/호스트명 없으면 거부.
- **L89-92** `socket.getaddrinfo(hostname, ...)` — 호스트명을 **실제 IP로 해석**. 해석 실패 시 거부.
  **왜 해석까지 하나:** `evil.com`이 `10.0.0.1`로 해석되도록 만든 DNS 트릭을 막으려면, 이름이 아니라 **최종 IP**를 검사해야 합니다.
- **L94-100** — 해석된 모든 주소를 수집.
- **L101-102** — `allow_loopback`이 켜졌고 **모든** 주소가 루프백일 때만 루프백 허용(docstring L67-70: RFC1918/link-local/메타데이터는 불허).
- **L103-105** `for addr in addrs: if _is_private(addr): return False, "Blocked: … private/internal address"` —
  하나라도 사설/내부 주소면 전체 거부. **왜 하나라도?** 여러 IP 중 하나만 내부여도 그쪽으로 연결될 수 있기 때문입니다.
- **L107** — 모두 통과하면 검증된 공용 IP들을 반환.

보조:
- `_is_private(addr)`(L57-61): 화이트리스트(`_allowed_networks`)에 있으면 허용, 아니면 `_BLOCKED_NETWORKS`에
  속하는지로 판단.
- `configure_ssrf_whitelist(cidrs)`(L32-): Tailscale `100.64.0.0/10`처럼 의도적으로 허용할 CIDR을 등록.
- `pin_resolved_url_dns(...)`(L177-)/`PinnedDNSAsyncTransport`(L219-): 검증한 IP로 **DNS를 고정**해 실제 연결.
  **왜?** 검증 시점과 연결 시점 사이에 DNS가 바뀌는 **TOCTOU/DNS rebinding** 공격을 막습니다(검증한 IP로만 연결).

---

## 셸 샌드박스: `sandbox.py`의 bubblewrap

`nanobot/agent/tools/sandbox.py`는 셸 명령을 **OS 격리**로 감쌉니다. docstring(L1-6)이 "새 백엔드를 추가하려면
`_wrap_<name>` 함수를 만들어 `_BACKENDS`에 등록하라"고 안내합니다(확장 가능한 설계).

`_bwrap(command, workspace, cwd)`(L14-54) — **bubblewrap**(`bwrap`) 격리:
- **L17-19 (docstring)** — 워크스페이스만 읽기/쓰기로 bind-mount하고, 그 부모 디렉토리(=`config.json`이 있는 곳)는
  **fresh tmpfs로 가림**. media 디렉토리는 읽기 전용으로 마운트.
- **L40** `["bwrap", "--new-session", "--die-with-parent", "--setenv", "HOME", str(ws)]` —
  새 세션, 부모와 함께 종료, HOME을 워크스페이스로 설정.
- **L41-44** — `/usr`(필수)와 `/bin`,`/lib`,`/etc/ssl/certs` 등(있으면)을 **읽기 전용**으로 마운트.
- **L45-52** — `--proc`/`--dev`/`--tmpfs /tmp`; `--tmpfs {ws.parent}`로 **설정 디렉토리를 마스킹**;
  워크스페이스만 `--bind`로 읽기/쓰기; media는 `--ro-bind-try`로 읽기 전용; `--chdir`로 작업 디렉토리 설정 후 `sh -c command`.
- **L57** `_BACKENDS = {"bwrap": _bwrap}` — 백엔드 등록 테이블.
- **L60-64** `wrap_command(sandbox, ...)`: 이름으로 백엔드를 찾아 명령을 래핑. 없는 이름이면 `ValueError`.

**설계 요점:** 명령을 그냥 실행하지 않고 "워크스페이스만 보이고 설정/홈은 가려진" 격리 환경 안에서 실행합니다.
LLM이 실수로/악의적으로 `~/.nanobot/config.json`(API 키 포함 가능)을 읽거나 시스템을 훼손하는 것을 막습니다.

---

## `shell.py`와 `exec_session.py`

- **`shell.py`**의 `ExecTool`(L139-, `_scopes = {"core", "subagent"}` L141):
  - `ExecToolConfig`(L54-): `timeout`(기본 60초, L57 "Hard timeout (s); 0 = no limit")과 `sandbox`(기본 `""` L60).
  - L29 `from nanobot.agent.tools.sandbox import wrap_command` — 설정된 sandbox 백엔드로 명령을 래핑해 실행.
  - **하드 타임아웃**으로 무한 루프/멈춘 명령을 강제 종료. **왜?** 에이전트가 응답 없는 명령에 영원히 매달리지 않게.
- **`exec_session.py`**: 상태를 유지하는 **장기 실행 셸 세션**(대화형 프로세스). `ExecSessionManager`(L186-)가
  여러 세션을 관리하고, `WriteStdinTool`(L411-, `_scopes = {"core", "subagent"}`)로 실행 중인 프로세스에 입력을 보냄,
  `ListExecSessionsTool`(L555-)로 세션 목록 조회. **왜 세션형 셸이 필요한가:** `python` REPL이나 `ssh`처럼
  한 번 띄워 여러 번 상호작용해야 하는 프로그램을 다루기 위해서입니다.

추가 배경은 [tech_background/06_execution_isolation.md](tech_background/06_execution_isolation.md)에서 다룹니다.
저장소의 보안 경계 문서(<a href="../.agent/security.md">.agent/security.md</a>)도 참고하세요.

다음 문서에서는 외부 접근 계층(API/SDK/WebUI)을 봅니다 → [13_api_sdk_webui.md](13_api_sdk_webui.md).
