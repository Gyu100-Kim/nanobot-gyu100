# 11. 스케줄링과 트리거 — 시간이 되면 스스로 움직이기

> **이 문서에서 다루는 큰 맥락**
>
> 지금까지는 "사용자가 말을 걸면 응답"하는 흐름이었습니다. 하지만 nanobot은 **정해진 시간/주기**에 스스로
> 일을 하기도 합니다 — 매일 아침 요약, 주기적 Dream[(용어사전)](../dict/03_memory_context_session.md#dream)([08](08_memory_and_dream.md)) 등. 이를 담당하는 것이
> `nanobot/cron/`(스케줄러)와 `nanobot/triggers/`(외부 트리거)입니다. 이 문서는 croniter[(용어사전)](../dict/06_scheduling_automation.md#croniter) 기반 스케줄 계산,
> 타이머 루프, 작업 실행 흐름, 그리고 세션에 결과를 배달하는 방식을 라인 근거로 설명합니다.

## 비유로 먼저 이해하기 — 알람 시계와 아침 점검 루틴

사람이 시키지 않아도 정해진 시간에 스스로 움직이는 기능입니다. 두 가지 장치가 나옵니다.

- **알람 시계(cron)** — "매일 아침 9시에 뉴스 요약해 줘"처럼 시간표를 등록해 두면,
  시간이 됐을 때 에이전트가 스스로 턴을 시작합니다. 시간표는 `0 9 * * *` 같은
  **cron 표현식**(분 시 일 월 요일)으로 적으며, croniter라는 라이브러리가
  "다음 울릴 시각"을 계산해 줍니다. 작동 원리는 단순합니다: 모든 알람 중 **가장 먼저 울릴
  것 하나**만 골라 타이머를 맞추고, 울리면 실행하고, 다시 다음 알람에 타이머를 맞춥니다.
- **아침 점검 루틴(Heartbeat)** — 워크스페이스의 `HEARTBEAT.md`라는 할 일 목록을 주기적으로
  열어 보고, **할 일이 있을 때만** AI를 깨웁니다. 목록이 비어 있으면 AI를 부르지 않아
  비용을 아낍니다.
- **초인종(트리거, `triggers/`)** — 시간이 아니라 "외부에서 벨을 누르면" 반응하는 장치입니다.

**꼭 가져가야 할 것 3가지**

1. cron 작업 = "시간표 + 시킬 일"이며, 시간이 되면 평범한 에이전트 턴 하나로 실행된다.
2. 타이머는 항상 "가장 가까운 알람 하나"에만 맞춘다 (울리면 재계산).
3. Heartbeat는 할 일이 있는지 먼저 확인하고, 있을 때만 LLM을 호출하는 절약형 루틴이다.

---

## 이 문서의 소목차

1. [cron 서브시스템 구조](#cron-서브시스템-구조)
2. [자료구조: `cron/types.py`](#자료구조-crontypespy)
3. [다음 실행 시각 계산 — croniter](#다음-실행-시각-계산--croniter)
4. [타이머 루프: `start` → `_arm_timer` → `_on_timer`](#타이머-루프-start--_arm_timer--_on_timer)
5. [작업 실행: `_execute_job`와 `on_job` 콜백](#작업-실행-_execute_job와-on_job-콜백)
6. [세션 배달과 에이전트 턴](#세션-배달과-에이전트-턴)
7. [`triggers/` — 외부 트리거](#triggers--외부-트리거)

---

## cron 서브시스템 구조

`nanobot/cron/`의 파일(확인됨)과 역할:

| 파일 | 역할 |
| --- | --- |
| `service.py` | `CronService` — 작업 저장/로드, 다음 실행 계산, 타이머 루프, 실행. |
| `types.py` | `CronSchedule`/`CronPayload`/`CronJob`/`CronStore` 등 자료구조. |
| `bound_runner.py` | 특정 세션/에이전트에 **바인딩된** cron 작업을 실제로 돌리는 러너. |
| `session_delivery.py` | cron 결과를 대상 세션/채널로 배달. |
| `session_turns.py` | cron 작업을 세션 턴으로 변환(`is_bound_cron_job` 등). |
| `webui_metadata.py` | WebUI에 노출할 cron 메타데이터. |

cron store는 워크스페이스의 `cron/jobs.json`([10](10_gateway_and_channels.md) `_run_gateway` L1360)에 저장됩니다.
게이트웨이가 `CronService`를 만들어 함께 실행합니다.

---

## 자료구조: `cron/types.py`

- `CronSchedule`(L7-): 스케줄 종류를 담습니다. `kind`가 `"at"`(특정 시각), `"every"`(주기), `"cron"`(cron 식)이며
  각각 `at_ms`, `every_ms`, `expr`/`tz` 필드를 씁니다.
- `CronPayload`(L21-): 작업이 실행할 내용(어떤 프롬프트/세션/채널로 배달할지).
- `CronJobState`(L46-): `next_run_at_ms`(L49) 등 실행 상태(마지막 상태/오류 포함).
- `CronJob`(L56-): 이름/스케줄/페이로드/상태를 묶은 작업. `from_dict`(L70)로 JSON에서 복원.
- `CronStore`(L82-): 작업 목록 컨테이너(`jobs.json`의 표현).

**왜 세 종류의 스케줄인가:** 일회성 알림(`at`), 단순 주기(`every`), 복잡한 달력 규칙(`cron`)을 모두 표현하기 위해서입니다.

---

## 다음 실행 시각 계산 — croniter

`_compute_next_run(schedule, now_ms)`(`service.py` L43-69)가 "다음에 언제 실행할지"를 밀리초로 계산합니다.

- **L45-46** `kind == "at"`: 지정 시각(`at_ms`)이 아직 미래면 그 시각, 아니면 `None`(다시 실행 안 함).
- **L48-52** `kind == "every"`: 지금(`now_ms`)으로부터 `every_ms` 뒤.
- **L54-65** `kind == "cron"`:
  - L58 `from croniter import croniter` — croniter 라이브러리([02](02_modules_and_stack.md))를 지연 import.
  - L61 — `schedule.tz`가 있으면 그 타임존, 없으면 로컬 타임존.
  - L62-63 `base_dt = datetime.fromtimestamp(base_time, tz=tz)`; `cron = croniter(schedule.expr, base_dt)`
    — 기준 시각에서 cron 식을 파싱.
  - L64-65 `next_dt = cron.get_next(datetime)` — 다음 발화 시각을 얻어 ms로 변환.
  - L66-67 — 파싱 실패 시 `None`(잘못된 cron 식이 서비스를 죽이지 않음).

**왜 croniter인가:** `"0 9 * * 1-5"`(평일 오전 9시) 같은 표준 cron 식을 직접 파싱하는 것은 번거롭고 실수하기 쉽습니다.
croniter가 이를 정확히 계산해 줍니다.

---

## 타이머 루프: `start` → `_arm_timer` → `_on_timer`

> **쉽게 말하면:** 알람이 100개 있어도 시계는 하나면 됩니다. "가장 먼저 울릴 알람"에만 타이머를 맞추고, 울리면 그 일을 실행한 뒤 다시 다음 알람 시각을 계산해 타이머를 다시 맞춥니다.

`CronService`(L142-)는 asyncio[(용어사전)](../dict/09_dev_stack.md#asyncio) 타이머로 동작합니다.

- **`start()`**(L489-507): 저장소를 로드(L492). 손상됐으면(`None`) 빈 목록으로 덮어써 데이터를 잃지 않도록
  **시작을 거부**하고 예외(L493-503) — 방어적 설계. 정상이면 `_recompute_next_runs()`(L504)로 모든 작업의 다음
  실행을 계산하고, 저장 후 `_arm_timer()`(L506)로 첫 타이머를 건다.
- **`_recompute_next_runs()`**(L516-525): enabled인 작업마다 `_compute_next_run`으로 `next_run_at_ms`를 갱신.
- **`_get_next_wake_ms()`**(L527-533): 모든 작업 중 **가장 이른** 다음 실행 시각을 찾음.
- **`_arm_timer()`**(L535-555): 그 가장 이른 시각까지(또는 `max_sleep_ms`까지) `asyncio.sleep` 후 `_on_timer()`를 호출하는
  태스크를 만듭니다(L550-555). **왜 max_sleep 상한?** 아주 먼 미래까지 잠들지 않고 주기적으로 깨어 store 재로드/재계산을 하기 위함.
- **`_on_timer()`**(L557-581): 깨어나면
  - L559 store를 다시 로드(외부에서 작업이 추가/수정됐을 수 있으므로 hot reload).
  - L570-573 `now >= next_run_at_ms`인 **due(기한 도래) 작업**을 모음.
  - L575-576 각 작업을 `_execute_job`으로 실행.
  - L581 다시 `_arm_timer()`로 다음 타이머를 건다(루프).

---

## 작업 실행: `_execute_job`와 `on_job` 콜백

`_execute_job(job)`(L583-)은 작업 하나를 실행합니다.

- **L589-590** `if self.on_job: await self.on_job(job)` — 실제 동작은 서비스가 직접 하지 않고 **주입된 콜백**
  `on_job`에 위임합니다. 게이트웨이에서 이 콜백이 [08](08_memory_and_dream.md)에서 본
  `on_cron_job`(`cli/commands.py` L1431-)입니다. 그 콜백이 작업 이름에 따라 분기합니다:
  - `"dream"` → 메모리 통합 직접 실행([08](08_memory_and_dream.md)).
  - `"heartbeat"` → `HEARTBEAT.md`의 활성 작업 점검(아래 상세).
  - 그 외 → 에이전트 턴으로 실행(아래).
- **L592-606** — 성공/스킵(`CronJobSkippedError`, L35)/취소/오류를 `job.state.last_status`에 기록. **왜?** 한 작업의
  실패가 스케줄러 전체를 멈추지 않게 하고, 상태를 남겨 디버깅/WebUI 표시에 씁니다.

### Heartbeat — 주기적 "할 일 점검" 시스템 작업

AGENTS.md가 말하듯 Heartbeat는 "cron 작업으로 점검되는 주기적 작업 목록"입니다(전용 서비스는 제거된 레거시).
`on_cron_job`의 heartbeat 분기(`cli/commands.py` L1501-):

- **L1502-1507** — 작업 이름이 `"heartbeat"`면 워크스페이스의 `HEARTBEAT.md`를 읽음. 파일이 없으면 조용히 종료.
- **L1509-1511** — `_heartbeat_has_active_tasks(content)`(L216-): 헤더/빈 줄/주석을 제외하고 실제 작업 줄이
  있는지 검사. 없으면 LLM을 부르지 않고 종료. **왜?** 할 일이 없는데 매번 LLM[(용어사전)](../dict/08_ai_llm_concepts.md#llm) 턴을 돌리면 토큰 낭비입니다.
- **L1513-1515** — `_pick_heartbeat_target()`으로 결과를 보낼 채널/chat을 고르되, `cli`뿐이면 보내지 않음.
- **L1517-1537** — `_HEARTBEAT_PREAMBLE`(L207-) + `HEARTBEAT.md` 내용을 프롬프트로 만들어 전용 세션
  `"heartbeat"`에서 `process_direct`로 실행. 실행 중에는 `message_tool.set_suppress_delivery(True)`로
  **직접 전송을 막고** 사후 게이트로만 응답을 내보냅니다(중복/우회 전송 방지).
- **L1540-1542** — heartbeat 세션은 `retain_recent_legal_suffix`로 꼬리만 유지해 무한히 자라지 않게 합니다.

---

## 세션 배달과 에이전트 턴

일반 cron 작업(dream/heartbeat가 아닌)은 "특정 세션에서 에이전트가 한 턴을 도는" 형태로 실행됩니다.

- `cron/session_turns.py`의 `is_bound_cron_job`(게이트웨이가 import, [10](10_gateway_and_channels.md) L1318): 작업이
  특정 세션/에이전트에 바인딩됐는지 판별.
- `cron/bound_runner.py`의 `run_bound_cron_job`(L1316 import): 바인딩된 작업을 그 세션 컨텍스트로 실행.
- `cron/session_delivery.py`: 실행 결과(응답)를 대상 채널/세션으로 **배달**(OutboundMessage로 발행).
- `nanobot/agent/cron_turns.py` / `nanobot/agent/automation_turns.py`: cron/자동화가 만든 턴을 세션 이력에
  어떻게 기록·표시할지([06](06_state_and_persistence.md)의 `session/automation_turns.py`와 짝).

**설계 요점:** cron 작업이라도 사용자 대화와 같은 에이전트 파이프라인(컨텍스트 구축 → LLM → 도구 → 응답)을
재사용합니다. 다만 결과는 사용자가 실시간으로 보낸 게 아니므로 `_automation_turn`/`_channel_delivery` 같은
메타로 구분해 이력·재생 시 오해가 없게 합니다.

---

## 실전 예제로 차근차근 따라가기 — "매일 아침 9시 뉴스 요약" 알람의 하루

사용자가 대화 중 "매일 아침 9시에 뉴스 요약해 줘"라고 부탁했다고 합시다.

**1단계 — 알람 등록.** 에이전트가 cron 도구([05](05_tools.md)의 `cron.py`)로
`CronJob(schedule=CronSchedule(kind="cron", expr="0 9 * * *"), payload=...)`을 만들어
`cron/jobs.json`에 저장합니다. `_compute_next_run`이 croniter로 "다음 9시"를 계산해
`next_run_at_ms`에 적어 둡니다.

**2단계 — 시계는 하나.** `CronService`는 등록된 모든 작업 중 **가장 이른** 다음 실행
시각(`_get_next_wake_ms`)까지만 `asyncio.sleep`으로 잠듭니다. 알람이 100개여도
타이머는 하나입니다.

**3단계 — 아침 9시.** `_on_timer`가 깨어나 store를 다시 읽고(그 사이 추가된 작업 반영),
기한이 된 작업을 골라 `_execute_job`으로 실행합니다. 실제 동작은 주입된 `on_job`
콜백이 맡는데, 이 작업은 dream도 heartbeat도 아니므로 **평범한 에이전트 턴 하나**로
실행됩니다: 페이로드의 프롬프트("뉴스 요약해 줘")로 컨텍스트를 짓고, LLM이 웹 검색
도구를 쓰고, 결과가 만들어집니다.

**4단계 — 배달과 재장전.** `session_delivery.py`가 결과를 원래 채널(예: Telegram 방)로
`OutboundMessage`로 배달하고, 이 턴은 `_automation_turn` 메타가 붙어 이력에서
"자동 실행"으로 구분됩니다. 실행 상태(성공/실패)는 `job.state.last_status`에 남고,
서비스는 다시 `_arm_timer`로 내일 9시를 향해 잠듭니다. 작업 하나가 실패해도
상태에만 기록될 뿐 스케줄러 전체는 멈추지 않습니다.

---

## `triggers/` — 외부 트리거

`nanobot/triggers/`는 시간 기반이 아닌 **외부 이벤트** 기반 실행을 담당합니다(파일: `local_runner.py`,
`local_store.py`, `local_types.py`, `local_session_turns.py`, `local_turns.py`).

- `LocalTriggerStore`(게이트웨이 import, [10](10_gateway_and_channels.md) L1325): 로컬 트리거 큐/저장소.
- `run_local_trigger_queue`(L1324 import): 큐에 쌓인 트리거를 소비해 에이전트 턴으로 실행.
- cron과 마찬가지로 결과는 세션 턴으로 변환·배달됩니다(`local_session_turns.py`, `local_turns.py`).

**cron vs triggers:** cron은 "**언제**"(시간)로 발화하고, triggers는 "**무엇이 일어났는가**"(외부 이벤트/큐 항목)로
발화합니다. 둘 다 게이트웨이가 장기 실행하며, 최종적으로는 같은 에이전트 파이프라인으로 수렴합니다.

다음 문서에서는 이 모든 실행을 안전하게 가두는 보안/샌드박스를 봅니다 → [12_security_and_sandbox.md](12_security_and_sandbox.md).
