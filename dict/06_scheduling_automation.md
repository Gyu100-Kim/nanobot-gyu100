# 사전 06. 스케줄링과 자동화 (Scheduling & Automation)

> 사용자가 말 걸지 않아도 에이전트가 스스로 움직이게 하는 장치들.
> 전체 색인은 [README](README.md)를 보세요.

---

### Cron
**한글:** 크론 · **분류:** 스케줄링 · **코드:** `nanobot/cron/`

유닉스의 시간 기반 작업 스케줄러에서 온 개념/표기법. `0 9 * * *`(매일 9시) 같은
**크론 표현식**으로 반복 일정을 기술합니다. nanobot은 자체 [CronService](#cronservice)로 구현합니다.

- **하위 개념:** [CronService](#cronservice), [Cron Job](#cron-job), [croniter](#croniter)
- **관련 용어:** [Heartbeat](#heartbeat), [Dream](03_memory_context_session.md#dream)

### croniter
**분류:** 스케줄링 · 라이브러리

크론 표현식에서 "다음 실행 시각"을 계산해 주는 파이썬 라이브러리.
[CronService](#cronservice)가 이 계산 결과로 [asyncio](09_dev_stack.md#asyncio) 타이머를 겁니다.

- **상위 개념:** [Cron](#cron)

### CronService
**분류:** 스케줄링 · **코드:** `nanobot/cron/service.py`

[Cron Job](#cron-job)들을 로드하고, 다음 실행 시각까지 대기했다가 실행하는 서비스.
[Gateway](01_core_architecture.md#gateway) 안에서 상시 구동됩니다.

- **상위 개념:** [Cron](#cron)
- **하위 개념:** [Bound Runner](#bound-runner), [Cron Store](#cron-store)

### Cron Job
**한글:** 크론 잡 · **분류:** 스케줄링 · **코드:** `nanobot/cron/types.py`

스케줄 하나의 정의(이름, 크론 표현식, 실행할 프롬프트/작업, 전달 대상).
에이전트가 [Cron Tool](02_tools_and_skills.md#cron-tool)로 스스로 등록할 수도 있습니다.

- **상위 개념:** [Cron](#cron)
- **관련 용어:** [Cron Store](#cron-store)

### Cron Store
**한글:** 크론 저장소 · **분류:** 스케줄링 · **코드:** `<workspace>/cron/jobs.json`

[Cron Job](#cron-job) 목록의 영속 저장 파일. 재시작해도 일정이 유지됩니다.

- **상위 개념:** [CronService](#cronservice)

### Bound Runner
**분류:** 스케줄링 · **코드:** `nanobot/cron/bound_runner.py`

크론 잡 실행 시 에이전트 턴을 세션/전달 설정에 **바인딩**해 돌리는 실행기.
결과 전달은 [Session Delivery](#session-delivery)가 담당합니다.

- **상위 개념:** [CronService](#cronservice)
- **하위 개념:** [Session Delivery](#session-delivery)

### Session Delivery
**분류:** 스케줄링 · **코드:** `nanobot/cron/session_delivery.py`

크론 턴의 결과를 어느 [Channel](01_core_architecture.md#channel)/채팅으로 보낼지 결정·전달하는 모듈.

- **상위 개념:** [Bound Runner](#bound-runner)

### Cron Turns
**분류:** 스케줄링 · **코드:** `nanobot/agent/cron_turns.py`

크론이 트리거한 턴을 일반 대화 턴과 구분해 처리하는 로직(이력 취급, 세션 선택 등).

- **상위 개념:** [Cron](#cron)
- **관련 용어:** [Automation Turns](#automation-turns)

### Automation Turns
**분류:** 스케줄링 · **코드:** `nanobot/agent/automation_turns.py`, `nanobot/session/automation_turns.py`

자동화(크론/트리거)가 만든 턴의 세션 기록 방식을 다루는 계층 —
사용자 대화 이력을 오염시키지 않게 분리합니다.

- **관련 용어:** [Cron Turns](#cron-turns), [History Visibility](03_memory_context_session.md#history-visibility)

### Trigger
**한글:** 트리거 · **분류:** 스케줄링 · **코드:** `nanobot/triggers/`

시간이 아니라 **로컬 이벤트**(파일 변화 등)로 에이전트 턴을 시작하는 장치.
`nanobot trigger` CLI로 수동 발화도 가능합니다.

- **관련 용어:** [Cron](#cron)

### Heartbeat
**한글:** 하트비트 · **분류:** 스케줄링 · **코드:** `nanobot/cli/commands.py`(heartbeat 분기), `nanobot/templates/HEARTBEAT.md`

워크스페이스의 [HEARTBEAT.md](#heartbeatmd)에 적힌 할 일을 주기적으로 점검하는 **시스템 크론 잡**.
활성 작업이 없으면 [LLM](08_ai_llm_concepts.md#llm) 호출 없이 건너뛰고(비용 절약),
실행 중엔 [MessageTool](02_tools_and_skills.md#messagetool) 직접 전송을 억제하며,
전용 `heartbeat` [Session](01_core_architecture.md#session)을 씁니다.
과거의 전용 서비스는 제거되고 크론 잡 방식만 남았습니다(legacy).

- **상위 개념:** [Cron](#cron)
- **하위 개념:** [HEARTBEAT.md](#heartbeatmd)
- **관련 용어:** [Sustained Goal](03_memory_context_session.md#sustained-goal)

### HEARTBEAT.md
**분류:** 스케줄링 · **코드:** `<workspace>/HEARTBEAT.md`

에이전트가 자율적으로 챙길 작업 목록을 적는 마크다운 파일.
[Heartbeat](#heartbeat) 잡이 이 파일에 활성 항목이 있을 때만 턴을 돕니다.

- **상위 개념:** [Heartbeat](#heartbeat)
