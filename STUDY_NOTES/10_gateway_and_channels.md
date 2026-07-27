# 10. 게이트웨이와 채널 — 오래 실행되며 세상과 연결하기

> **이 문서에서 다루는 큰 맥락**
>
> **채널(Channel[(용어사전)](../dict/01_core_architecture.md#channel))** 은 텔레그램/디스코드/슬랙/WebUI 같은 "바깥 세계"와 nanobot을 잇는 어댑터입니다. 들어온
> 메시지를 MessageBus의 inbound로 넣고, 나가는 메시지를 각 플랫폼 형식으로 보냅니다. **게이트웨이(Gateway[(용어사전)](../dict/01_core_architecture.md#gateway))** 는
> 이 채널들과 에이전트 루프·cron을 한 프로세스에서 **오래 실행**하는 오케스트레이터입니다. 이 문서는
> 채널 공통 인터페이스(`channels/base.py`), 발견/디스패치(`manager.py`, `registry.py`), 게이트웨이 실행
> (`_run_gateway`, `gateway/runtime.py`, `gateway/service.py`)을 라인 근거로 설명합니다.

## 비유로 먼저 이해하기 — 24시간 편의점과 여러 개의 출입문

지금까지의 문서는 "메시지 하나가 처리되는 과정"이었다면, 이 문서는 **가게 전체를 24시간
열어 두는 방법**입니다.

- **게이트웨이(Gateway)** = 24시간 편의점 그 자체. `nanobot gateway` 명령으로 켜면
  모든 출입문(채널)과 시간제 아르바이트(cron 스케줄), 웹 화면(WebUI)까지 한 프로세스에서
  계속 돌아갑니다.
- **채널(Channel)** = 출입문. Telegram 문, Discord 문, Slack 문, 웹 문... 문마다 생김새는
  달라도 하는 일은 같습니다: 손님 말을 받아 표준 서식(`InboundMessage`)으로 바꿔 접수함에
  넣고, 답장(`OutboundMessage`)을 받아 손님의 언어(각 플랫폼 API)로 전해 줍니다.
  그래서 모든 문은 `BaseChannel`이라는 같은 설계도를 따릅니다.
- **문지기 역할도 합니다** — 아무나 들어오지 못하게, 허용된 사용자인지(allowlist/pairing)
  문 앞에서 확인합니다.
- **새 문 달기** — 새 메신저를 지원하고 싶으면 `BaseChannel` 설계도대로 클래스 하나를
  만들어 폴더에 넣으면 됩니다. `ChannelManager`가 자동으로 발견해 함께 엽니다.

**꼭 가져가야 할 것 3가지**

1. 게이트웨이 = 채널 + cron + WebUI를 한꺼번에 상시 실행하는 오케스트레이터.
2. 모든 채널은 `BaseChannel` 규격을 따르므로 "표준 서식 변환기"만 새로 쓰면 새 채널이 된다.
3. 채널은 입장 검사(허용 목록·페어링)도 담당한다.

---

## 이 문서의 소목차

1. [게이트웨이 = 장기 실행 오케스트레이터](#게이트웨이--장기-실행-오케스트레이터)
2. [`BaseChannel` — 채널 공통 인터페이스](#basechannel--채널-공통-인터페이스)
3. [인바운드 흐름: `_handle_message` 라인바이라인](#인바운드-흐름-_handle_message-라인바이라인)
4. [`ChannelManager` — 발견/시작/아웃바운드 디스패치](#channelmanager--발견시작아웃바운드-디스패치)
5. [`registry.py` — pkgutil + entry_points 발견](#registrypy--pkgutil--entry_points-발견)
6. [`gateway/runtime.py`, `gateway/service.py`](#gatewayruntimepy-gatewayservicepy)
7. [실제 채널 목록과 새 채널 추가](#실제-채널-목록과-새-채널-추가)

---

## 게이트웨이 = 장기 실행 오케스트레이터

`nanobot gateway` 명령([03](03_entrypoints.md))은 결국 `cli/commands.py`의 `_run_gateway(...)`(L1301-)를 실행합니다.
이 함수가 하나의 이벤트 루프에서 다음을 함께 띄웁니다(L1312-1326 import에서 구성요소가 드러남):

- `MessageBus`(L1332), `RuntimeEventBus`(L1333) — 메시지/런타임 이벤트 버스.
- `build_provider_snapshot(config)`(L1335) — 프로바이더 스냅샷([09](09_providers.md)).
- `SessionManager`(L1339) — 세션 저장소([06](06_state_and_persistence.md)).
- `ChannelManager` — 채널들.
- `CronService` + cron store(L1360) — 스케줄러([11](11_cron_and_triggers.md)).
- `WebuiTurnCoordinator`, 트리거 러너, 토큰 사용량 훅 등.

또한 `health_server_enabled`(L1309) 옵션으로 **헬스 엔드포인트**를 띄워 "게이트웨이가 살아있는지"를 외부에서 확인할 수 있게 합니다.

**왜 게이트웨이인가(설계 의도):** CLI 한 번 실행(`agent`)은 대화 한 번이면 끝입니다. 하지만 텔레그램 봇처럼
"항상 켜져 메시지를 기다리는" 서비스는 장기 실행 프로세스가 필요합니다. 게이트웨이는 그 상시 실행 컨테이너로,
채널·에이전트·cron을 한 곳에 묶어 관리합니다.

---

## `BaseChannel` — 채널 공통 인터페이스

`nanobot/channels/base.py`의 `BaseChannel`(L21-)은 모든 채널의 추상 기반입니다.

클래스 속성(L29-33):
- `name`/`display_name` — 채널 식별자/표시명.
- `send_progress`(L31) — 진행상황("생각 중…")을 보낼지.
- `send_tool_hints`(L32) — 도구 사용 힌트 표시 여부.
- `show_reasoning`(L33) — reasoning 표시 여부.

생성자(L35-46): `config`, `bus`(MessageBus[(용어사전)](../dict/01_core_architecture.md#messagebus)), `_running` 플래그를 보관.

추상 메서드(각 채널이 반드시 구현):
- `start()`(L74-84): 플랫폼에 연결하고 **장기 실행**하며 수신 메시지를 `_handle_message()`로 전달(docstring L79-83).
- `stop()`(L86-89): 정리.
- `send(msg)`(L91-102): OutboundMessage를 플랫폼으로 전송. **실패 시 예외를 던져야** manager가 재시도 정책을 한 곳에서 적용(docstring L99-101).

선택적 오버라이드(기본 구현 있음):
- `transcribe_audio`(L48-60): 오디오 → Whisper 전사.
- `login(force)`(L62-72): QR 스캔 등 대화형 로그인(기본 `True`).
- `send_delta`/`send_reasoning_delta`/`send_reasoning_end`(L104-)/`send_file_edit_events` 등 스트리밍 전송 훅.

**설계 요점:** 필수(`start`/`stop`/`send`)는 abstractmethod로 강제하고, 스트리밍/전사/로그인 등 플랫폼별 부가기능은
기본 no-op으로 두어 **최소한만 구현하면 동작**하게 했습니다.

---

## 인바운드 흐름: `_handle_message` 라인바이라인

각 채널이 수신 메시지를 받으면 `_handle_message(...)`(L218-266)를 호출합니다.

- **L229** `if not self.is_allowed(sender_id):` — 권한 확인. 허용되지 않은 발신자면:
  - DM이면 **페어링 코드**를 생성해 보냅니다(L231-243). **왜?** 아무나 봇에 명령하지 못하도록, 처음 접근하는
    사용자에게 코드를 발급해 사용자가 이를 승인 절차에 쓰게 합니다(`nanobot/pairing/`).
  - DM이 아니면 접근 거부 로그만 남기고 무시(L245-250).
- **L252-254** — 스트리밍 지원 채널이면 메타데이터에 `_wants_stream=True`를 추가.
- **L256-264** — `InboundMessage`를 구성(채널/발신자/chat_id/내용/미디어/메타/세션키 오버라이드).
- **L266** `await self.bus.publish_inbound(msg)` — 버스에 발행 → 여기서부터 [04](04_agent_loop.md)의 AgentLoop가 받습니다.

`default_config()`(L268-271)는 온보딩 시 기본 설정(`{"enabled": False}`)을 돌려주며, 플러그인이 오버라이드해 자동 채웁니다.

---

## `ChannelManager` — 발견/시작/아웃바운드 디스패치

> **쉽게 말하면:** 모든 출입문(채널)의 열쇠 꾸러미를 든 관리인입니다. 설정에서 켜진 문들을 찾아 열고, 답장이 나오면 "이건 Telegram 문으로, 저건 Discord 문으로" 배달할 문을 골라 줍니다.

`nanobot/channels/manager.py`의 `ChannelManager`(L70-):

- `_init_channels()`(L112-): "pkgutil scan + entry_points plugins"로 채널을 **발견**합니다(docstring L113).
  설정에서 활성화된 채널만 인스턴스화합니다.
- `start_all()`(L246-)/`_start_channel`(L239-): 각 채널의 `start()`를 백그라운드 태스크로 실행.
- `stop_all()`(L284-): 모든 채널 정리.
- `_dispatch_outbound()`(L333-): **아웃바운드 루프**. `bus.consume_outbound()`(L348)로 나갈 메시지를 받아
  대상 채널의 `send()`로 보냅니다. 중복 억제(`_should_suppress_outbound` L311, `_fingerprint_content` L307),
  스트리밍 델타 합치기(`_coalesce_stream_deltas` L524), 재시도(`_send_with_retry` L588)를 여기서 일괄 처리.
  **왜 한 곳에서:** 재시도/중복 억제 같은 정책을 각 채널이 제각각 구현하지 않고 manager가 공통 적용합니다.
- `get_status()`(L622-)/`enabled_channels()`(L633-): 상태 조회.

---

## `registry.py` — pkgutil + entry_points 발견

`nanobot/channels/registry.py`:
- `discover_channel_names()`(L17-): `pkgutil.iter_modules`(L23)로 `channels/` 패키지의 모듈 이름을 **싸게** 나열
  (import 없이 이름만).
- `load_channel_class(module_name)`(L28-): 필요한 채널만 실제 import해서 `BaseChannel` 서브클래스를 얻음.
- `discover_plugins(...)`(L40-): `entry_points(group="nanobot.channels")`(L45)로 **외부 플러그인** 채널 발견.
- `discover_enabled(...)`(L56-)/`discover_all()`(L95-): 이름을 먼저 나열하고 활성화된 것만 import(docstring L65-66).
  **왜 지연 import(설계 의도):** 채널마다 무거운 의존성(telegram SDK 등)이 있으므로, 전부 import하면 시작이 느리고
  설치 안 된 extra 때문에 실패합니다([02](02_modules_and_stack.md)의 lazy deps와 같은 철학).

---

## `gateway/runtime.py`, `gateway/service.py`

이 둘은 게이트웨이 **프로세스 관리** 계층입니다(위 `_run_gateway`가 실제 실행 본체라면, 이쪽은 그것을 띄우고 감독).

- **`gateway/runtime.py`**의 `GatewayRuntime`(L110-):
  - `build_gateway_command(...)`(L60-): 게이트웨이를 띄울 자식 프로세스 명령 구성.
  - `start_background(options)`(L149-): 백그라운드로 게이트웨이 프로세스 시작.
  - `stop(timeout_s=20)`(L189-)/`restart(...)`(L205-): 종료/재시작(POSIX/Windows 각각 `_terminate_posix` L291 / `_terminate_windows` L312).
  - `status(...)`(L212-): 실행 상태(`GatewayStatus` L38) 조회. `refresh_state_pid`(L131)로 상태 파일의 PID를 현재 프로세스로 자가 치유.
  - `read_log_tail`/`follow_logs`(L247-, L257-): 로그 확인.
- **`gateway/service.py`**(L1 "Install and manage OS-level gateway services"): 게이트웨이를 **OS 서비스**로 설치/관리
  (예: macOS `launchd` plist — `plistlib` import). 부팅 시 자동 실행 등록 등.

**요지:** `runtime.py` = "이 세션에서 게이트웨이 프로세스를 켜고/끄고/상태 보기", `service.py` = "OS 부팅 서비스로 등록".

---

## 실전 예제로 차근차근 따라가기 — 가게 문 여는 아침부터 배달까지

`nanobot gateway`를 실행한 순간부터 답장 배달까지를 따라가 봅니다.

**1단계 — 개점 준비.** `_run_gateway`가 한 이벤트 루프 안에 부품을 차례로 조립합니다:
`MessageBus`(접수함) → 프로바이더 스냅샷(두뇌 연결) → `SessionManager`(공책 서랍) →
`ChannelManager`(문 관리인) → `CronService`(알람 시계). 필요하면 헬스 엔드포인트도 켜서
외부에서 "가게 살아 있나요?"를 확인할 수 있게 합니다.

**2단계 — 문 열기.** `ChannelManager._init_channels()`가 `channels/` 폴더를 스캔해
설정에서 `enabled: true`인 채널만 골라 import하고(꺼진 채널의 무거운 SDK는 아예
불러오지 않음 — 지연 import), `start_all()`이 각 채널의 `start()`를 백그라운드
태스크로 띄웁니다. 이제 Telegram 문, WebSocket 문이 각자 플랫폼에 접속해 대기합니다.

**3단계 — 손님 입장 검사.** Telegram으로 낯선 사람이 DM을 보내면, 채널의
`_handle_message`가 `is_allowed(sender_id)`로 확인합니다. 허용 목록에 없으면
페어링 코드를 발급해 돌려보내고, 허용된 사용자면 메시지를 `InboundMessage`로 바꿔
`publish_inbound`로 접수함에 넣습니다. 여기서부터는 [04](04_agent_loop.md)의 세계입니다.

**4단계 — 배달.** 에이전트가 답을 만들어 outbound 큐에 넣으면, manager의
`_dispatch_outbound` 루프가 그것을 꺼내 "channel 필드가 telegram이네" 하고
해당 채널의 `send()`를 부릅니다. 전송 실패 시 재시도, 같은 내용 중복 억제,
스트리밍 조각 합치기 같은 배달 정책은 채널이 아니라 manager가 한 곳에서 처리합니다.

**5단계 — 폐점.** 종료 신호가 오면 `stop_all()`이 모든 채널을 정리하고,
세션 캐시를 fsync로 눌러 담은 뒤 프로세스가 내려갑니다.

---

## 실제 채널 목록과 새 채널 추가

`nanobot/channels/`에 실제 존재하는 채널 구현(확인됨):

```text
dingtalk  discord  email  feishu  matrix  mattermost  mochat  msteams
napcat  qq  signal  slack  telegram  websocket  wecom  weixin  whatsapp
```

(`websocket.py`는 WebUI가 붙는 WebSocket[(용어사전)](../dict/05_channels_gateway_ui.md#websocket) 채널 — [13](13_api_sdk_webui.md)의 WebUI[(용어사전)](../dict/05_channels_gateway_ui.md#webui) 프로토콜과 연결.)

**새 채널 추가 절차(구조에서 도출):**
1. `channels/`에 새 모듈을 만들어 `BaseChannel`을 상속하고 `name`/`start`/`stop`/`send`를 구현.
2. `_handle_message`를 통해 수신 메시지를 버스로 넘김.
3. `registry.discover_channel_names()`(pkgutil)가 자동으로 이름을 잡으므로, 설정에서 `enabled: true`만 하면 동작.
4. 외부 배포 플러그인이라면 `entry_points`의 `nanobot.channels` 그룹에 등록(코어 수정 불필요).

**채널 생명주기:** `manager._init_channels()` 발견 → `start_all()`이 각 채널 `start()`를 장기 태스크로 실행 →
채널이 메시지 수신 시 `_handle_message` → `publish_inbound` → AgentLoop[(용어사전)](../dict/01_core_architecture.md#agentloop) 처리 → outbound → `_dispatch_outbound`가
`send()` 호출 → 종료 시 `stop_all()`.

다음 문서에서는 게이트웨이 안에서 도는 스케줄러/트리거를 봅니다 → [11_cron_and_triggers.md](11_cron_and_triggers.md).
