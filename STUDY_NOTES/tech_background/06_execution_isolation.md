# 배경지식 06. 실행 격리와 샌드박싱(Execution Isolation)

> **이 문서에서 다루는 큰 맥락**
>
> 에이전트가 셸/코드를 실행한다는 것은 곧 "임의 코드 실행"을 허용한다는 뜻입니다. 이를 안전하게 하려면
> **격리(isolation)** 가 필수입니다. 이 문서는 격리의 정의와 위협 모델, 하위 개념들(최소 권한, Linux 네임스페이스,
> bubblewrap[(용어사전)](../../dict/07_security_isolation.md#bubblewrap), seccomp[(용어사전)](../../dict/07_security_isolation.md#seccomp), 컨테이너/마이크로VM, SSRF[(용어사전)](../../dict/07_security_isolation.md#ssrf), DNS rebinding, 다층 방어)과 그 근간 기술/문서,
> 그리고 nanobot의 `agent/tools/sandbox.py`, `exec_session.py`, `nanobot/security/`로의 연결을 다룹니다.

## 비유로 먼저 이해하기 — 과학 실험실의 안전 수칙

AI 에이전트에게 셸 명령 실행 권한을 주는 것은, 학생에게 **화학 실험**을 시키는 것과
같습니다. 유용하지만 위험하므로 실험실에는 안전 수칙이 겹겹이 있습니다.

- **필요한 시약만 꺼내 주기(최소 권한 원칙)** — 실험에 필요 없는 위험 물질은 아예
  선반에서 치웁니다. 에이전트에게도 꼭 필요한 파일·네트워크 접근만 허용합니다.
- **격리된 실험 부스(네임스페이스와 bubblewrap)** — 리눅스에는 프로세스에게 "가짜 전용
  세계"(파일 시스템, 네트워크, 프로세스 목록이 분리된)를 보여 주는 기능(네임스페이스)이
  있고, bubblewrap은 이를 쉽게 쓰게 해 주는 도구입니다. 부스 안에서 무엇을 쏟아도
  진짜 실험실은 무사합니다.
- **위험 동작 금지 목록(seccomp)** — 프로세스가 운영체제에 요청할 수 있는 동작(시스템 콜)
  중 위험한 것을 커널 수준에서 거부합니다.
- **외부 전화선 검사(SSRF 방어)** — 부스 안에서 "외부에 전화하겠다"고 하면, 그 번호가
  사실 내부 전산망이 아닌지 검사하고, 검사 후 번호를 몰래 바꾸는 속임수(DNS 리바인딩)까지
  막습니다.
- **한 겹으로는 부족(다층 방어)** — 어떤 안전장치든 뚫릴 수 있으므로, 여러 겹을 겹쳐
  하나가 실패해도 다음 겹이 막게 합니다.

**꼭 가져가야 할 것 3가지**

1. 원칙은 최소 권한: 필요한 것만 보이고, 나머지는 아예 존재하지 않는 것처럼.
2. bubblewrap(네임스페이스) 부스 + seccomp 금지 목록 + SSRF 전화선 검사가 겹겹이 작동한다.
3. 완벽한 한 겹은 없다 — 다층 방어가 답이다.

---

## 소목차
1. [정의와 위협 모델](#정의와-위협-모델)
2. [하위 개념 상세](#하위-개념-상세)
3. [개념 간 관계](#개념-간-관계)
4. [역사와 근간 기술/문서](#역사와-근간-기술문서)
5. [최신 동향](#최신-동향)
6. [nanobot에서의 실제 구현](#nanobot에서의-실제-구현)

---

## 정의와 위협 모델

**실행 격리**: 신뢰할 수 없는 코드가 접근할 수 있는 파일/네트워크/프로세스 범위를 제한하는 것.

**왜 필요한가 — LLM[(용어사전)](../../dict/08_ai_llm_concepts.md#llm) 에이전트의 위협 모델:** 에이전트에게 셸을 주면 두 경로로 사고가 납니다.
1. **모델의 실수** — 잘못된 `rm -rf`, 의도치 않은 설정 파일 덮어쓰기. 악의가 없어도 파괴적일 수 있습니다.
2. **프롬프트 인젝션(prompt injection)** — 에이전트가 읽는 외부 콘텐츠(웹페이지, 이메일, 도구 결과)에
   "이 명령을 실행해라" 같은 지시문이 숨어 있으면, 모델이 공격자의 대리인이 될 수 있습니다.
   시스템 프롬프트로 완전히 막을 수 없다는 것이 현재의 공학적 합의이므로, **피해 범위를 구조적으로 좁히는**
   격리가 마지막 방어선입니다.

격리 없이 셸을 주면 비밀 파일(`~/.ssh`, API 키) 유출, 시스템 훼손, 내부망 스캔(SSRF) 등이 가능합니다.
격리는 "최악의 경우 피해 범위(blast radius)"를 좁힙니다.

격리 스펙트럼(약 → 강): 프로세스 권한 제한 → 네임스페이스/샌드박스(bubblewrap, seccomp) → 컨테이너(Docker)
→ 마이크로VM(Firecracker) → 물리적으로 분리된 원격 실행 환경.

---

## 하위 개념 상세

### (a) 최소 권한 원칙(principle of least privilege)
모든 격리 설계의 뿌리가 되는 원칙: **"작업에 필요한 최소한의 권한만 부여한다"** (Saltzer & Schroeder, 1975,
*The Protection of Information in Computer Systems* — 보안 설계 원칙의 고전).
에이전트 맥락에서는 "워크스페이스 디렉토리만 쓰기 가능, 나머지는 읽기 전용 또는 차단"으로 번역됩니다.

### (b) Linux 네임스페이스(namespaces)와 bubblewrap
**네임스페이스**는 Linux 커널이 프로세스에게 "자원의 사적인 뷰"를 주는 기능입니다(`namespaces(7)`):
mount(파일시스템 뷰), PID(프로세스 목록), network(네트워크 스택), user(UID 매핑) 등.
컨테이너 기술(Docker)의 기반이기도 합니다.

**bubblewrap(bwrap)** 은 이 네임스페이스로 **비특권(unprivileged) 샌드박스**를 만드는 경량 도구입니다.
Flatpak(Linux 앱 배포 시스템)의 샌드박스 런타임에서 출발했으며, 핵심 사용법은 "빈 마운트 네임스페이스에서 시작해
필요한 경로만 명시적으로 bind-mount"하는 **화이트리스트** 방식입니다:
- `--ro-bind /usr /usr` — 시스템 경로는 읽기 전용으로.
- `--bind <workspace> <workspace>` — 작업 디렉토리만 읽기/쓰기로.
- `--tmpfs <경로>` — 특정 경로를 빈 임시 파일시스템으로 **가림**(민감한 디렉토리 마스킹).
- `--unshare-pid`, `--die-with-parent` — 프로세스 격리와 생명주기 결속.

root 권한이나 데몬 없이 프로세스 하나를 감쌀 수 있어, 에이전트 셸 도구의 격리에 잘 맞습니다.

### (c) seccomp — 시스템 콜 필터링
**seccomp-bpf**는 프로세스가 호출할 수 있는 **시스템 콜 자체를 필터링**하는 커널 기능입니다.
네임스페이스가 "무엇이 보이는가"를 제한한다면, seccomp은 "무엇을 할 수 있는가"를 제한합니다.
Chrome 렌더러 샌드박스, Docker의 기본 seccomp 프로파일이 대표 사례입니다.

### (d) 컨테이너와 마이크로VM
- **컨테이너(Docker 등)**: 네임스페이스+cgroups 조합. 편리하지만 커널을 호스트와 공유하므로
  커널 취약점이 곧 탈출 경로입니다.
- **마이크로VM(Firecracker)**: AWS가 Lambda/Fargate용으로 만든 초경량 가상 머신(NSDI 2020 논문).
  게스트가 자체 커널을 가져 격리가 강하면서 ~125ms 수준으로 빠르게 부팅합니다. 클라우드 코드 실행
  서비스들의 표준 기반이 되었습니다.
- **gVisor**: 시스템 콜을 사용자 공간에서 가로채 에뮬레이트하는 중간 지대.

강한 격리일수록 무겁고 느려지므로, "로컬 개인 에이전트냐, 멀티테넌트 클라우드냐"에 따라 적정 수준이 다릅니다.

### (e) SSRF(Server-Side Request Forgery)
서버(여기서는 에이전트)가 **공격자가 지정한 URL로 대신 요청**하게 만들어, 원래는 접근할 수 없는
내부 자원(사설망 `10.0.0.0/8`, `192.168.0.0/16`, 루프백 `127.0.0.1`, 클라우드 메타데이터 `169.254.169.254`)을
읽게 하는 공격입니다. OWASP Top 10(2021)에 A10으로 독립 등재될 만큼 흔합니다.
에이전트의 웹 fetch 도구는 "URL을 대신 열어 주는" 기능 그 자체이므로 SSRF의 직접적인 표적입니다.
방어: URL의 호스트명을 **실제 IP로 해석한 뒤** 사설/내부 대역이면 차단.

### (f) DNS rebinding — SSRF 검사의 우회로
검사 시점에는 공인 IP로 응답하고, **실제 연결 시점에는 내부 IP로** DNS 응답을 바꾸는 공격(TOCTOU[(용어사전)](../../dict/07_security_isolation.md#toctou) —
검사와 사용 사이의 시간차 악용). 방어는 **DNS 고정(pinning)**: 검사할 때 해석한 IP로만 실제 연결을 맺고,
재해석을 허용하지 않는 것입니다.

### (g) 다층 방어(defense in depth)
어느 한 층도 완벽하지 않다는 전제로 여러 겹을 쌓는 전략:
OS 샌드박스(파일/프로세스) + 타임아웃(자원) + 애플리케이션 경계 검사(경로 검증) + 네트워크 가드(SSRF/DNS).
한 층이 뚫려도(예: 애플리케이션 경로 검사의 버그) 다음 층(OS 샌드박스)이 받칩니다.
반대로 말하면, **애플리케이션 수준 검사만으로 OS 샌드박스를 대체할 수 없습니다** — 전자는 정책, 후자는 강제입니다.

---

## 개념 간 관계

```text
최소 권한 원칙 (1975, 설계 철학)
    │ 구현 수단 (로컬)
    ├─ 네임스페이스 → bubblewrap (파일시스템 화이트리스트, 비특권)
    ├─ seccomp (시스템 콜 필터)
    └─ 타임아웃/자원 제한 (폭주 차단)
    │ 구현 수단 (강한 격리)
    ├─ 컨테이너 (커널 공유) → 마이크로VM Firecracker (커널 분리)
    │ 네트워크 축
    ├─ SSRF 방어 (IP 해석 후 사설 대역 차단)
    └─ DNS rebinding 방어 (DNS 고정 — TOCTOU 차단)
    │ 전체 전략
    └─ 다층 방어 (OS 강제 + 앱 정책은 보완 관계, 대체 불가)
```

- 격리는 [01](01_tool_calling_agents.md)의 도구(특히 셸/웹)가 만든 위험에 대한 대답입니다.
- 프롬프트 인젝션은 [04](04_mcp.md)의 도구 설명 주입과 같은 뿌리 — "모델이 읽는 모든 텍스트는 잠재적 명령"입니다.

---

## 역사와 근간 기술/문서

| 시기 | 이정표 | 내용 |
| --- | --- | --- |
| 1975 | **Saltzer & Schroeder** 보안 설계 원칙 | 최소 권한, fail-safe defaults 등 — 모든 격리 설계의 고전. |
| 2002- | Linux **네임스페이스** 단계적 도입 | mount(2002)부터 user(2013)까지 — 컨테이너/샌드박스의 커널 기반. |
| 2005 | **seccomp** 커널 병합 (2012 seccomp-bpf) | 시스템 콜 필터링 — Chrome/Docker 샌드박스의 핵심. |
| 2013 | **Docker** 공개 | 네임스페이스+cgroups의 대중화. |
| 2016- | **bubblewrap** (Flatpak 프로젝트) | 비특권 경량 샌드박스 도구 — 데몬 없이 프로세스 단위 격리. |
| 2020 | **Firecracker** (Agache et al., NSDI 2020) | 마이크로VM — 서버리스/코드 실행 서비스의 격리 표준. |
| 2021 | **OWASP Top 10 — A10 SSRF** | SSRF가 독립 항목으로 등재 — 웹 요청 대리 기능의 위험 공인. |
| 2023- | LLM 에이전트 격리 논의 | 프롬프트 인젝션(OWASP LLM Top 10의 LLM01)과 결합된 코드 실행 위험이 부각. |

읽어볼 1차 자료:
- Saltzer & Schroeder: *The Protection of Information in Computer Systems* (1975)
- bubblewrap: https://github.com/containers/bubblewrap
- Firecracker: https://www.usenix.org/conference/nsdi20/presentation/agache
- OWASP SSRF: https://owasp.org/Top10/A10_2021-Server-Side_Request_Forgery_%28SSRF%29/
- OWASP Top 10 for LLM Applications: https://owasp.org/www-project-top-10-for-large-language-model-applications/
- `namespaces(7)` man page: https://man7.org/linux/man-pages/man7/namespaces.7.html

---

## 최신 동향

- 코딩 에이전트들이 **컨테이너/마이크로VM**에서 코드를 실행하는 방향으로 이동.
- Linux **bubblewrap**(bwrap), **seccomp-bpf**, macOS **App Sandbox[(용어사전)](../../dict/07_security_isolation.md#sandbox)** 등 OS 수준 격리 활용.
- 네트워크 측 **SSRF 방어**와 비밀 마스킹이 표준 관행화.
- 프롬프트 인젝션을 전제로 한 설계(권한 분리, 승인 게이트, 읽기 전용 기본값)가 에이전트 프레임워크의 기본기로 정착.

> 참고: 원본 계획에 있던 Modal/Daytona/Singularity 같은 원격 격리 실행 환경은 nanobot 코어 소스에서 확인되지 않으므로
> **nanobot에는 미적용**입니다. nanobot은 로컬 OS 격리(bubblewrap) + 애플리케이션 수준 가드를 씁니다.

---

## nanobot에서의 실제 구현

[12](../12_security_and_sandbox.md)에서 라인 단위로 다뤘습니다. 위 하위 개념과 대응시킨 세 층 요약:

### 1) 셸 샌드박스 — `agent/tools/sandbox.py`
- `_bwrap(command, workspace, cwd)`(L14-54): **bubblewrap**으로 명령을 격리 — 위 (b)의 화이트리스트 방식 그대로.
  워크스페이스만 읽기/쓰기 bind-mount하고(L49), 설정 디렉토리(부모)는 `--tmpfs`로 마스킹(L47 — 위 (b)의 가림 기법),
  시스템 경로는 읽기 전용(L41-44), media는 읽기 전용(L50).
  `--new-session --die-with-parent`(L40)로 세션/생명주기 격리.
- `_BACKENDS = {"bwrap": _bwrap}`(L57), `wrap_command(...)`(L60-64): 백엔드 확장 가능 구조 —
  더 강한 격리(컨테이너 등)로 갈아끼울 수 있는 여지.

### 2) 실행 도구 — `agent/tools/exec_session.py`, `shell.py`
- `shell.py`의 `ExecTool`(L139-): 설정된 sandbox 백엔드로 명령을 래핑(L29 `wrap_command`)하고 **하드 타임아웃**
  (`ExecToolConfig.timeout` 기본 60초, L57)으로 폭주를 차단 — 위 (g)의 자원 제한 층.
- `exec_session.py`: 상태 유지형 셸 세션(`ExecSessionManager` L186-, `WriteStdinTool` L411-)으로 대화형
  프로세스를 관리하되, 도구 `_scopes`(`{"core","subagent"}`)로 사용 문맥을 제한 — 위 (a)의 최소 권한.

### 3) 애플리케이션 가드 — `nanobot/security/`
- `workspace_policy.py`/`workspace_access.py`: 파일 접근을 워크스페이스로 제한(경계 검사, `ContextVar` 스코프)
  — 위 (a)의 최소 권한을 파일 도구 수준에서 적용.
- `network.py`: SSRF 방어(호스트명을 실제 IP로 해석해 사설/내부 주소 차단, `resolve_url_target` L64-107 — 위 (e))
  + DNS 고정(`PinnedDNSAsyncTransport` — 위 (f)의 rebinding/TOCTOU 차단).
- 다만 `workspace_policy.py` docstring이 명시하듯 이 가드들은 **OS 샌드박스의 대체가 아니라 보완**입니다
  — 위 (g)의 다층 방어 원칙을 코드 주석으로 못박은 사례. 저장소의 보안 경계 문서
  <a href="../../.agent/security.md">.agent/security.md</a>도 같은 원칙을 강조합니다.

**정리:** nanobot의 격리는 "OS 샌드박스(bubblewrap) + 타임아웃 + 애플리케이션 경계 가드(파일/네트워크)"의 다층
방어입니다. 원격 격리 실행 환경은 쓰지 않고, 로컬에서 실용적이면서도 여러 겹으로 피해 범위를 좁히는 접근을 택했으며,
그 뿌리는 최소 권한 원칙(1975)과 Linux 네임스페이스/bubblewrap, OWASP의 SSRF 방어 관행에 있습니다.
---

## 차근차근 정리 — 한 장면으로 복습

에이전트에게 셸 도구를 주는 순간 생기는 위험과 방어를 한 줄기로 정리합니다.

1. **위협**: 악의적 프롬프트("이 웹페이지를 요약해 줘" 속에 숨은 명령)가 LLM을 속여
   `cat ~/.nanobot/config.json`(API 키) 같은 명령을 실행하게 만들 수 있습니다.
2. **1차 방어 — 애플리케이션 가드**: 파일 도구는 경로를 완전히 해석한 뒤 워크스페이스
   밖이면 거부하고, 웹 도구는 해석된 IP가 내부망이면 거부합니다(SSRF 방어).
   빠르지만, 코드의 구멍 하나면 뚫립니다.
3. **2차 방어 — OS 샌드박스**: bubblewrap이 리눅스 네임스페이스로 "가짜 작은 세상"을
   만들어 셸을 그 안에서 실행합니다. 워크스페이스만 보이고 설정 디렉토리는 tmpfs로
   가려져 있어, 명령이 성공해도 훔칠 것이 없습니다.
4. **3차 방어 — 자원 제한**: 하드 타임아웃이 무한 루프를 끊습니다.
5. 핵심 사상은 **다층 방어(defense in depth)**: 어느 한 겹도 완벽하지 않으므로,
   서로 다른 원리의 방어를 겹칩니다. nanobot 코드 스스로 "애플리케이션 가드는 OS
   샌드박스의 대체물이 아니다"라고 명시하는 이유입니다.

### 직접 확인해 볼 질문

1. 경로 검사를 문자열 비교가 아니라 `resolve()` 후에 하는 이유는? (`..`/심볼릭 링크)
2. DNS 리바인딩 공격은 무엇이고, DNS 피닝은 어떻게 막는가?
3. 컨테이너(Docker)와 bubblewrap 샌드박스의 차이는?

다음으로: 본편 [12_security_and_sandbox.md](../12_security_and_sandbox.md)의 실제 코드.
