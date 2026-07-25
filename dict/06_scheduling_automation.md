# 사전 06. 스케줄링과 자동화 (Scheduling & Automation)

> 사용자가 말을 걸지 않아도 에이전트가 움직이게 하는 장치들.
> 전체 색인은 [README](README.md), 노드 클래스 정의는 [00_content_classes.md](00_content_classes.md)를 보세요.
>
> 표기 규약: **상위 개념 = 더 특수한 개념**(예시·구현·특수화), **하위 개념 = 더 일반적인 개념**(일반화).

---

### Cron
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 크론

유닉스에서 유래한 시간 기반 작업 스케줄링 개념. [Cron Expression](#cron-expression)이라는 5필드
문자열로 "언제"를 표현합니다. nanobot은 OS의 crontab이 아니라 자체
[CronService](#cronservice)를 [Gateway](01_core_architecture.md#gateway) 안에서 돌립니다 —
설치 환경(Windows 포함)과 무관하게 동작하기 위해서입니다.

- **상위 개념(더 특수):** [CronService](#cronservice), [Cron Job](#cron-job),
  [Cron Expression](#cron-expression), [Heartbeat](#heartbeat)
- **관련 용어:** [croniter](#croniter)

### Cron Expression
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 크론 표현식

`분 시 일 월 요일` 5개 필드로 스케줄을 표현하는 문자열 형식.

**예시:** `0 9 * * *` = 매일 09:00, `*/15 * * * *` = 15분마다, `0 9 * * 1` = 매주 월요일 09:00.

- **하위 개념(더 일반):** [Cron](#cron)
- **관련 용어:** [croniter](#croniter)

### croniter
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `croniter`

[Cron Expression](#cron-expression)을 파싱해 "다음 실행 시각"을 계산해 주는 파이썬 라이브러리.
[CronService](#cronservice)가 스케줄 계산에 사용합니다.

- **관련 용어:** [Cron](#cron)

### CronService
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/cron/service.py`

[Cron Job](#cron-job) 목록을 로드해 시간이 되면 실행하는 스케줄러 서비스.
[Gateway](01_core_architecture.md#gateway)와 함께 뜨며, 실행은
[Bound Runner](#bound-runner)를 통해 에이전트 턴으로 변환됩니다.

- **하위 개념(더 일반):** [Cron](#cron)
- **상위 개념(더 특수):** [Bound Runner](#bound-runner)
- **관련 용어:** [Cron Store](#cron-store)

### Cron Job
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 크론 잡 · **코드:** `nanobot/cron/types.py`

등록된 예약 작업 하나 — 스케줄([Cron Expression](#cron-expression)), 실행할 메시지/프롬프트,
전달 방식 등을 담습니다. 사용자가 직접 등록할 수도, 에이전트가
[Cron Tool](02_tools_and_skills.md#cron-tool)로 스스로 등록할 수도 있습니다.

**예시:** `{ schedule: "0 9 * * *", message: "오늘 일정 요약해줘", channel: "telegram" }`.

- **하위 개념(더 일반):** [Cron](#cron)
- **관련 용어:** [Trigger](#trigger)

### Cron Store
**클래스:** [Artifact](00_content_classes.md#artifact) · **한글:** 크론 저장소 · **코드:** `<workspace>/cron/jobs.json`

[Cron Job](#cron-job) 목록이 저장되는 JSON 파일. 재시작해도 예약이 유지되고, 사람이 직접 열어
확인/수정할 수 있습니다.

- **하위 개념(더 일반):** [CronService](#cronservice)

### Bound Runner
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/cron/bound_runner.py`

크론 실행을 특정 세션/채널에 **바인딩된** 에이전트 턴으로 바꿔 주는 실행기.
"예약 작업도 결국 하나의 [Turn](01_core_architecture.md#turn)"으로 수렴시켜, 크론용 별도 실행
경로를 만들지 않습니다.

- **하위 개념(더 일반):** [CronService](#cronservice)
- **관련 용어:** [Cron Turns](#cron-turns)

### Session Delivery
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/cron/session_delivery.py`

크론 실행 결과를 어느 세션/채널로 전달할지 결정하는 계층.

**예시:** "매일 9시 일정 알림"의 결과를 Telegram 대화방으로 보낼지, 조용히 세션에만 기록할지의 결정.

- **하위 개념(더 일반):** [CronService](#cronservice)

### Cron Turns
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/agent/cron_turns.py`

크론 발 턴의 이력 기록 방식을 다루는 모듈 — 시스템이 만든 턴을 사용자 대화와 구분해
[History Visibility](03_memory_context_session.md#history-visibility) 규칙을 적용합니다.

- **하위 개념(더 일반):** [Turn](01_core_architecture.md#turn), [Bound Runner](#bound-runner)

### Automation Turns
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/agent/automation_turns.py`

크론 외 자동화(트리거 등)로 시작된 턴의 공통 처리 — 표시 이름, 이력 규칙 등.

- **하위 개념(더 일반):** [Turn](01_core_architecture.md#turn)
- **관련 용어:** [Trigger](#trigger)

### Trigger
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 트리거 · **코드:** `nanobot/triggers/`

시간이 아닌 **사건**으로 에이전트 턴을 시작시키는 확장점. [Cron](#cron)이 "몇 시에"라면 트리거는
"무슨 일이 생기면"입니다.

**예시:** 파일 변경 감지, 웹훅 수신 시 에이전트에게 처리를 시키는 시나리오.

- **관련 용어:** [Automation Turns](#automation-turns)

### Heartbeat
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 하트비트

주기적 [Cron Job](#cron-job)으로 [HEARTBEAT.md](#heartbeatmd)의 할 일 목록을 점검하는 메커니즘 —
"에이전트의 맥박". 과거의 전용 Heartbeat 서비스는 제거되고 크론 잡 방식으로 통합되었습니다
(특수 실행 경로 하나를 없앤 단순화). 점검 중 보고 소음은
[MessageTool](02_tools_and_skills.md#messagetool)의 `set_suppress_delivery`로 억제됩니다.

**예시:** 30분마다 "HEARTBEAT.md를 읽고 지금 할 일이 있으면 하라"는 턴이 조용히 돌고, 실제로
할 일이 있을 때만 사용자에게 알림이 갑니다.

- **하위 개념(더 일반):** [Cron](#cron)
- **상위 개념(더 특수):** [HEARTBEAT.md](#heartbeatmd)
- **관련 용어:** [Sustained Goal](03_memory_context_session.md#sustained-goal)

### HEARTBEAT.md
**클래스:** [Artifact](00_content_classes.md#artifact) · **코드:** `nanobot/templates/HEARTBEAT.md` → 워크스페이스

[Heartbeat](#heartbeat)가 점검하는 할 일 목록 파일. 사용자와 에이전트 모두 편집할 수 있는
[Markdown](02_tools_and_skills.md#markdown) — "에이전트의 상비 체크리스트".

- **하위 개념(더 일반):** [Heartbeat](#heartbeat),
  [Bootstrap Templates](03_memory_context_session.md#bootstrap-templates)
