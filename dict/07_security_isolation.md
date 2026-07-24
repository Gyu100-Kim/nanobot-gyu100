# 사전 07. 보안과 격리 (Security & Isolation)

> 에이전트에게 셸/네트워크를 주면서도 피해 범위를 좁히는 장치들.
> 전체 색인은 [README](README.md)를 보세요.

---

### Sandbox
**한글:** 샌드박스 · **분류:** 격리 · **코드:** `nanobot/agent/tools/sandbox.py`

신뢰할 수 없는 코드가 접근할 수 있는 파일/프로세스 범위를 제한하는 실행 환경.
nanobot은 [bubblewrap](#bubblewrap) 백엔드로 [ExecTool](02_tools_and_skills.md#exectool) 명령을 감쌉니다.

- **하위 개념:** [Sandbox Backend](#sandbox-backend), [bubblewrap](#bubblewrap)
- **관련 용어:** [Defense in Depth](#defense-in-depth)

### Sandbox Backend
**한글:** 샌드박스 백엔드 · **분류:** 격리 · **코드:** `sandbox.py`의 `_BACKENDS`

샌드박스 구현을 갈아끼울 수 있게 하는 확장점(`wrap_command(...)`). 현재는 `bwrap` 하나이며,
더 강한 격리([Container](#container) 등)로 확장할 여지를 둔 구조입니다.

- **상위 개념:** [Sandbox](#sandbox)

### bubblewrap
**분류:** 격리 · 도구 (bwrap)

[Linux Namespaces](#linux-namespaces)로 **비특권 샌드박스**를 만드는 경량 도구(Flatpak 프로젝트 출신).
"필요한 경로만 명시적으로 bind-mount"하는 화이트리스트 방식: 시스템 경로는 읽기 전용,
[Workspace](01_core_architecture.md#workspace)만 읽기/쓰기, 설정 디렉토리는 `--tmpfs`로 가림.

- **상위 개념:** [Sandbox](#sandbox)
- **관련 용어:** [Least Privilege](#least-privilege)

### Linux Namespaces
**한글:** 리눅스 네임스페이스 · **분류:** 격리 · OS 기능

커널이 프로세스에게 자원의 "사적인 뷰"(mount, PID, network, user)를 주는 기능 —
[Container](#container)와 [bubblewrap](#bubblewrap)의 공통 기반입니다.

- **하위 개념:** [seccomp](#seccomp)

### seccomp
**분류:** 격리 · OS 기능

프로세스가 호출 가능한 **시스템 콜 자체를 필터링**하는 리눅스 커널 기능(seccomp-bpf).
[Linux Namespaces](#linux-namespaces)가 "무엇이 보이는가"라면 seccomp은 "무엇을 할 수 있는가"의 제한입니다.

- **상위 개념:** [Linux Namespaces](#linux-namespaces)

### Container
**한글:** 컨테이너 · **분류:** 격리

[Linux Namespaces](#linux-namespaces)+cgroups로 프로세스를 격리하는 기술(Docker 등).
커널을 호스트와 공유하므로 MicroVM(Firecracker)보다 격리가 약합니다.
nanobot 자체도 Docker로 배포 가능합니다(`Dockerfile`).

- **관련 용어:** [Sandbox](#sandbox)

### Least Privilege
**한글:** 최소 권한 원칙 · **분류:** 보안 원칙

"작업에 필요한 최소한의 권한만 부여"(Saltzer & Schroeder, 1975). nanobot 곳곳에 적용됩니다:
[Tool Scope](02_tools_and_skills.md#tool-scope), [Dream](03_memory_context_session.md#dream)의
편집 도구 전용 레지스트리, [Workspace Policy](#workspace-policy)의 경로 제한.

- **관련 용어:** [Defense in Depth](#defense-in-depth)

### Defense in Depth
**한글:** 다층 방어 · **분류:** 보안 원칙

어느 한 층도 완벽하지 않다는 전제로 여러 겹을 쌓는 전략. nanobot은
OS [Sandbox](#sandbox) + [Timeout](#timeout) + [Workspace Policy](#workspace-policy) +
네트워크 가드([SSRF](#ssrf)/[DNS Pinning](#dns-pinning))의 다층 구조이며,
애플리케이션 가드는 OS 샌드박스의 **대체가 아니라 보완**입니다(`.agent/security.md`).

- **관련 용어:** [Least Privilege](#least-privilege)

### Prompt Injection
**한글:** 프롬프트 인젝션 · **분류:** 위협

에이전트가 읽는 외부 콘텐츠(웹페이지, 도구 결과)에 숨겨진 지시문으로 모델을 조종하는 공격.
시스템 프롬프트만으로 완전히 막을 수 없어, [Sandbox](#sandbox) 등 구조적 격리가 마지막 방어선입니다.
(nanobot의 [Injection](01_core_architecture.md#injection)(메시지 주입)과는 다른 용어입니다.)

- **관련 용어:** [Defense in Depth](#defense-in-depth)

### SSRF
**한글:** 서버측 요청 위조 · **분류:** 위협 · **코드:** `nanobot/security/network.py`

에이전트가 공격자가 지정한 URL로 **대신 요청**하게 만들어 내부 자원(사설망, 루프백,
클라우드 메타데이터 `169.254.169.254`)을 읽게 하는 공격(OWASP Top 10 A10).
방어: 호스트명을 실제 IP로 해석한 뒤 사설/내부 대역이면 차단(`resolve_url_target`).

- **하위 개념:** [DNS Rebinding](#dns-rebinding)
- **관련 용어:** [Web Tools](02_tools_and_skills.md#web-tools)

### DNS Rebinding
**분류:** 위협

검사 시점엔 공인 IP, 실제 연결 시점엔 내부 IP로 DNS 응답을 바꿔 [SSRF](#ssrf) 검사를 우회하는 공격
([TOCTOU](#toctou)의 네트워크판). 방어는 [DNS Pinning](#dns-pinning)입니다.

- **상위 개념:** [SSRF](#ssrf)

### DNS Pinning
**한글:** DNS 고정 · **분류:** 방어 · **코드:** `nanobot/security/network.py`

검사할 때 해석한 IP로만 실제 연결을 맺고 재해석을 허용하지 않는 [DNS Rebinding](#dns-rebinding) 방어.
[PinnedDNSAsyncTransport](#pinneddnsasynctransport)로 구현됩니다.

- **하위 개념:** [PinnedDNSAsyncTransport](#pinneddnsasynctransport)

### PinnedDNSAsyncTransport
**분류:** 방어 · **코드:** `nanobot/security/network.py`

[httpx](09_dev_stack.md#httpx)용 커스텀 트랜스포트 — 검증 시점의 IP를 고정해 연결합니다.
[Web Tools](02_tools_and_skills.md#web-tools)와 원격
[MCPToolWrapper](02_tools_and_skills.md#mcptoolwrapper) 연결이 사용합니다.

- **상위 개념:** [DNS Pinning](#dns-pinning)

### TOCTOU
**분류:** 위협 · 개념 (Time-Of-Check to Time-Of-Use)

"검사한 시점"과 "사용한 시점" 사이에 대상이 바뀌는 시간차 공격의 총칭.
[DNS Rebinding](#dns-rebinding)이 대표적인 네트워크 사례입니다.

- **관련 용어:** [DNS Pinning](#dns-pinning)

### Workspace Policy
**한글:** 워크스페이스 정책 · **분류:** 방어 · **코드:** `nanobot/security/workspace_policy.py`

파일 도구의 접근을 [Workspace](01_core_architecture.md#workspace) 경계 안으로 제한하는 정책 계층.
docstring이 명시하듯 OS [Sandbox](#sandbox)의 대체가 아닌 보완입니다.

- **하위 개념:** [Workspace Access](#workspace-access)
- **관련 용어:** [Path Utils](02_tools_and_skills.md#path-utils)

### Workspace Access
**분류:** 방어 · **코드:** `nanobot/security/workspace_access.py`

[Workspace Policy](#workspace-policy)의 활성 스코프를 [ContextVar](09_dev_stack.md#contextvar)로 관리하는 모듈 —
비동기 태스크마다 독립된 경계를 갖게 합니다.

- **상위 개념:** [Workspace Policy](#workspace-policy)

### Timeout
**한글:** 타임아웃 · **분류:** 방어

실행 시간의 하드 상한. [ExecTool](02_tools_and_skills.md#exectool)은 기본 60초로
무한 루프/폭주 명령을 차단합니다 — 자원 축의 [Defense in Depth](#defense-in-depth) 층입니다.

- **관련 용어:** [Sandbox](#sandbox)

### PTH File Guard
**분류:** 방어 · **코드:** `nanobot/security/`

파이썬 `.pth` 파일(인터프리터 시작 시 자동 실행될 수 있는 경로 설정 파일)을 이용한
지속 공격을 막는 가드. CLI 진입 시 활성화됩니다.

- **관련 용어:** [Defense in Depth](#defense-in-depth)
