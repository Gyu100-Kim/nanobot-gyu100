# 배경지식 06. 실행 격리와 샌드박싱(Execution Isolation)

> **이 문서에서 다루는 큰 맥락**
>
> 에이전트가 셸/코드를 실행한다는 것은 곧 "임의 코드 실행"을 허용한다는 뜻입니다. 이를 안전하게 하려면
> **격리(isolation)** 가 필수입니다. 이 문서는 격리의 정의/배경/동향과, nanobot의 `agent/tools/sandbox.py`,
> `exec_session.py`, `nanobot/security/`로의 연결을 다룹니다.

## 소목차
1. [정의와 등장 배경](#정의와-등장-배경)
2. [최신 동향](#최신-동향)
3. [nanobot에서의 실제 구현](#nanobot에서의-실제-구현)

---

## 정의와 등장 배경

**실행 격리**: 신뢰할 수 없는 코드가 접근할 수 있는 파일/네트워크/프로세스 범위를 제한하는 것.
- **왜 필요한가:** LLM은 실수하거나(잘못된 `rm -rf`), 프롬프트 인젝션으로 조종될 수 있습니다. 격리 없이 셸을 주면
  비밀 파일 유출, 시스템 훼손, 내부망 스캔(SSRF) 등이 가능합니다. 격리는 "최악의 경우 피해 범위"를 좁힙니다.

격리 스펙트럼: 프로세스 권한 제한 → 네임스페이스/샌드박스(bubblewrap, seccomp) → 컨테이너(Docker) → 마이크로VM(Firecracker) → 원격 격리 환경.

---

## 최신 동향

- 코딩 에이전트들이 **컨테이너/마이크로VM**에서 코드를 실행하는 방향으로 이동.
- Linux **bubblewrap**(bwrap), **seccomp-bpf**, macOS **App Sandbox** 등 OS 수준 격리 활용.
- 네트워크 측 **SSRF 방어**와 비밀 마스킹이 표준 관행화.

> 참고: 원본 계획에 있던 Modal/Daytona/Singularity 같은 원격 격리 실행 환경은 nanobot 코어 소스에서 확인되지 않으므로
> **nanobot에는 미적용**입니다. nanobot은 로컬 OS 격리(bubblewrap) + 애플리케이션 수준 가드를 씁니다.

---

## nanobot에서의 실제 구현

[12](../12_security_and_sandbox.md)에서 라인 단위로 다뤘습니다. 세 층 요약:

### 1) 셸 샌드박스 — `agent/tools/sandbox.py`
- `_bwrap(command, workspace, cwd)`(L14-54): **bubblewrap**으로 명령을 격리. 워크스페이스만 읽기/쓰기 bind-mount하고
  (L49), 설정 디렉토리(부모)는 `--tmpfs`로 마스킹(L47), 시스템 경로는 읽기 전용(L41-44), media는 읽기 전용(L50).
  `--new-session --die-with-parent`(L40)로 세션/생명주기 격리.
- `_BACKENDS = {"bwrap": _bwrap}`(L57), `wrap_command(...)`(L60-64): 백엔드 확장 가능 구조.

### 2) 실행 도구 — `agent/tools/exec_session.py`, `shell.py`
- `shell.py`의 `ExecTool`(L139-): 설정된 sandbox 백엔드로 명령을 래핑(L29 `wrap_command`)하고 **하드 타임아웃**
  (`ExecToolConfig.timeout` 기본 60초, L57)으로 폭주를 차단.
- `exec_session.py`: 상태 유지형 셸 세션(`ExecSessionManager` L186-, `WriteStdinTool` L411-)으로 대화형
  프로세스를 관리하되, 도구 `_scopes`(`{"core","subagent"}`)로 사용 문맥을 제한.

### 3) 애플리케이션 가드 — `nanobot/security/`
- `workspace_policy.py`/`workspace_access.py`: 파일 접근을 워크스페이스로 제한(경계 검사, `ContextVar` 스코프).
- `network.py`: SSRF 방어(호스트명을 실제 IP로 해석해 사설/내부 주소 차단, `resolve_url_target` L64-107) +
  DNS 고정(`PinnedDNSAsyncTransport`)으로 DNS rebinding 차단.
- 다만 `workspace_policy.py` docstring이 명시하듯 이 가드들은 **OS 샌드박스의 대체가 아니라 보완**입니다.

**정리:** nanobot의 격리는 "OS 샌드박스(bubblewrap) + 타임아웃 + 애플리케이션 경계 가드(파일/네트워크)"의 다층
방어입니다. 원격 격리 실행 환경은 쓰지 않고, 로컬에서 실용적이면서도 여러 겹으로 피해 범위를 좁히는 접근을 택했습니다.
