# 13. API 서버 · Python SDK · WebUI — 바깥에서 nanobot 쓰기

> **이 문서에서 다루는 큰 맥락**
>
> 지금까지는 nanobot 내부였습니다. 이 문서는 **외부에서 접근하는 3가지 통로**를 다룹니다:
> (1) `nanobot/api/` — **OpenAI 호환 HTTP[(용어사전)](../dict/05_channels_gateway_ui.md#http) 서버**(다른 앱이 nanobot을 "OpenAI처럼" 호출), (2) `nanobot/sdk/` —
> **Python SDK**(코드에서 세션/메모리/런타임 제어), (3) `nanobot/web/` + `webui/` — **번들 WebUI[(용어사전)](../dict/05_channels_gateway_ui.md#webui)**(브라우저 UI,
> WebSocket[(용어사전)](../dict/05_channels_gateway_ui.md#websocket) 프로토콜로 게이트웨이와 통신). `nanobot/apps/`(앱 매니페스트)도 함께 봅니다.

## 비유로 먼저 이해하기 — 같은 주방, 세 개의 주문 창구

지금까지는 메신저(채널)로 nanobot을 쓰는 방법이었습니다. 이 문서는 **개발자·브라우저가
쓰는 세 개의 다른 창구**를 다룹니다. 주방(에이전트 코어)은 하나인데 주문 창구만 다릅니다.

- **창구 1: OpenAI 호환 API 서버** — "OpenAI에 주문하는 형식 그대로" 주문을 받는 창구.
  이미 OpenAI 형식으로 만들어진 수많은 앱·라이브러리가 주소만 바꾸면 nanobot을 쓸 수
  있습니다. 표준 규격 콘센트를 흉내 낸 멀티탭인 셈입니다.
- **창구 2: Python SDK** — 파이썬 코드 안에서 `Nanobot` 클래스로 직접 주문하는 창구.
  서버를 띄울 필요 없이 프로그램에 에이전트를 내장할 때 씁니다.
- **창구 3: WebUI** — 브라우저 화면. React로 만든 웹앱이 WebSocket(전화선처럼 계속
  연결된 통신)으로 게이트웨이와 실시간 대화합니다. 답변이 만들어지는 대로 화면에
  흘러나오는 것(스트리밍)도 이 연결 덕분입니다.

**꼭 가져가야 할 것 3가지**

1. 세 창구(API 서버 / Python SDK / WebUI) 모두 결국 같은 에이전트 코어로 이어진다.
2. API 서버는 OpenAI 형식을 흉내 내므로 기존 OpenAI 클라이언트를 그대로 재사용할 수 있다.
3. WebUI는 WebSocket 상시 연결로 스트리밍 답변과 실시간 상태를 주고받는다.

---

## 이 문서의 소목차

1. [세 통로 한눈에](#세-통로-한눈에)
2. [OpenAI 호환 API 서버: `api/server.py`](#openai-호환-api-서버-apiserverpy)
3. [인증 미들웨어 라인바이라인](#인증-미들웨어-라인바이라인)
4. [Python SDK 진입점: `nanobot/nanobot.py`의 `Nanobot`](#python-sdk-진입점-nanobotnanobotpy의-nanobot)
5. [SDK 내부 헬퍼: `sdk/`](#sdk-내부-헬퍼-sdk)
6. [WebUI와 WebSocket 프로토콜](#webui와-websocket-프로토콜)
7. [`apps/` — 앱 매니페스트](#apps--앱-매니페스트)

---

## 세 통로 한눈에

| 통로 | 위치 | 무엇을 위한 것 |
| --- | --- | --- |
| HTTP API | `nanobot/api/server.py` | 다른 프로그램이 OpenAI 호환 `/v1/chat/completions`로 nanobot 호출 |
| Python SDK | `nanobot/nanobot.py`(진입점) + `nanobot/sdk/`(내부) | 파이썬 코드에서 세션/메모리/런타임을 직접 제어 |
| WebUI | `nanobot/web/`(번들) + `webui/`(소스) | 브라우저 채팅 UI, WebSocket으로 게이트웨이와 통신 |

세 통로 모두 결국 [04](04_agent_loop.md)의 `AgentLoop`를 재사용합니다 — 입력 형식만 다를 뿐 두뇌는 하나입니다.

---

## OpenAI 호환 API 서버: `api/server.py`

`nanobot/api/server.py`(L3 "Provides /v1/chat/completions and /v1/models endpoints") — aiohttp 기반.

엔드포인트(`create_app` L431-433에서 등록):
- **`POST /v1/chat/completions`** → `handle_chat_completions`(L206-). JSON과 `multipart/form-data`(이미지 첨부) 모두 지원(L207).
  - 스트리밍이면 SSE[(용어사전)](../dict/08_ai_llm_concepts.md#sse)(`_sse_chunk` L99)로 토큰을 흘려보냄(`_on_stream` L261, `_on_stream_end` L267).
  - 비스트리밍이면 `_chat_completion_response`(L58)로 OpenAI 형식 JSON 반환.
- **`GET /v1/models`** → `handle_models`(L367-). 사용 가능한 모델 목록.
- **`GET /health`** → `handle_health`(L385-). 인증 없이 접근 가능(헬스체크).

**왜 OpenAI 호환인가(설계 의도):** 이미 수많은 도구/라이브러리가 OpenAI API 규격을 말합니다. 같은 규격을 흉내 내면
기존 클라이언트(예: `openai` python 패키지, LangChain 등)가 **base URL만 바꿔** nanobot을 그대로 쓸 수 있습니다.

`create_app(agent_loop, model_name="nanobot", request_timeout=120.0, api_key="")`(L395-400):
- L409 — 최대 요청 크기 20MB(base64 이미지 대비).
- L413 `app["session_locks"] = {}` — **세션 키별 락**. 같은 사용자의 동시 요청이 세션을 망가뜨리지 않게 직렬화.

---

## 인증 미들웨어 라인바이라인

`auth_middleware`(L415-427) — 모든 API 경로에 적용되는 Bearer 토큰 인증.

- **L418-419** — `/health`는 인증 없이 통과(모니터링용).
- **L420-421** — `api_key`가 비어 있으면(설정 안 함) 인증을 건너뜀. **트레이드오프:** 로컬 개인용 편의 vs 노출 위험.
  외부에 열 때는 반드시 키를 설정해야 합니다.
- **L422-424** — `Authorization` 헤더가 `Bearer `로 시작하지 않으면 401.
- **L425-426** `hmac.compare_digest(auth[len("Bearer "):], api_key)` — 키 비교. **왜 `compare_digest`?**
  일반 `==`는 문자열이 일치하는 길이에 따라 시간이 달라져 **타이밍 공격**에 노출됩니다. `compare_digest`는
  상수 시간 비교로 이를 막습니다.

---

## Python SDK 진입점: `nanobot/nanobot.py`의 `Nanobot`

SDK의 **공식 진입점**은 `nanobot/nanobot.py`의 `Nanobot` 클래스입니다(AGENTS.md "Entry Points — Python SDK:
`nanobot/nanobot.py`"). docstring(L64-70)의 사용 예:

```python
bot = Nanobot.from_config()
result = await bot.run("Summarize this repo", hooks=[MyHook()])
print(result.content)
```

- **`Nanobot.__init__`(L73-79)** — `AgentLoop`를 감싸고, 아래 `sdk/`의 클라이언트들을 속성으로 노출합니다:
  `self.sessions = SessionClient(loop)`, `self.memory = MemoryClient(loop)`, `self.runtime = RuntimeClient(loop)`.
- **`from_config(config_path=None, *, workspace=None, model=None, model_preset=None)`(L81-124)** —
  `~/.nanobot/config.json`(기본)을 로드하고(L99, L108), workspace/model 오버라이드를 적용한 뒤
  `AgentLoop.from_config(...)`(L120)로 루프를 만들어 감쌉니다. 즉 SDK도 결국 [04](04_agent_loop.md)의
  동일한 `AgentLoop`를 쓰는 얇은 파사드(facade)입니다.
- **`run(message, *, session_key="sdk:default", channel="cli", ...)`(L126-)** — 한 턴을 돌리고 `RunResult`를 반환.
  기본 세션 키가 `"sdk:default"`(L130)인 점이 [06](06_state_and_persistence.md)의 세션 키 규칙과 이어집니다.
- **`run_streamed`(L174-) / `stream`(L256-)** — 델타 콜백/비동기 이터레이터로 스트리밍 수신.
- **`aclose`(L291-) / `__aenter__`/`__aexit__`(L295-)** — `async with Nanobot.from_config() as bot:` 형태의
  컨텍스트 매니저 사용을 지원.

**왜 파샬드인가(설계 의도):** 내부 구조(버스/루프/세션)를 모르는 사용자도 메서드 몇 개로 임베딩할 수 있게,
복잡한 조립 로직을 한 클래스 뒤로 숨깁니다.

---

## SDK 내부 헬퍼: `sdk/`

`nanobot/sdk/`(L1 "Internal helpers for the high-level nanobot Python SDK") — 위 `Nanobot` 파샬드가 속성으로
노출하는 클라이언트들입니다:

- `SessionClient`(`clients.py` L21-): 세션 제어.
  - `ingest(...)`(L30-): 메시지를 세션에 투입(에이전트 턴 유발).
  - `get`/`list`/`export`/`clear`/`delete`/`flush`(L65-104): 세션 조회/내보내기/삭제/플러시.
- `MemoryClient`(L109-): 메모리 제어. `read`/`write`(L115-119)로 `MEMORY.md`,
  `append_history`/`read_history`(L123-127)로 `history.jsonl`([08](08_memory_and_dream.md)).
- `RuntimeClient`(L135-): 런타임 정보/조작. `model`(L142), `workspace`(L147),
  `compact_session`(L151-, 세션 압축 트리거).
- 그 외 `runtime.py`, `streaming.py`, `types.py`가 SDK의 런타임/스트리밍/타입을 제공.

**왜 SDK인가:** 채널이나 HTTP를 거치지 않고, 파이썬 프로그램이 nanobot을 라이브러리처럼 임베드해 세션·메모리를
직접 다루고 싶을 때 씁니다(테스트, 자동화, 임베딩).

---

## WebUI와 WebSocket 프로토콜

- **소스**: `webui/` — Vite[(용어사전)](../dict/09_dev_stack.md#vite) 기반 React/TypeScript SPA[(용어사전)](../dict/05_channels_gateway_ui.md#spa)(`package.json`, `bun.lock`, `src/`, `index.html` 확인).
- **번들**: 빌드하면 `nanobot/web/dist/`로 출력되어 파이썬 wheel에 포함됩니다(AGENTS.md: "Build outputs to
  ../nanobot/web/dist"). 빌드/개발/테스트 명령:
  ```bash
  cd webui && bun run dev      # 개발 서버 (API/WS를 게이트웨이 :8765로 프록시)
  cd webui && bun run build    # → nanobot/web/dist/
  cd webui && bun run test
  ```
- **통신**: WebUI는 [10](10_gateway_and_channels.md)에서 본 `channels/websocket.py`의 `WebSocketChannel`(L274-)에
  **WebSocket multiplex 프로토콜**로 붙습니다. 메시지는 JSON(`json.loads`/`json.dumps(..., ensure_ascii=False)`,
  L180/L365 등)으로 주고받으며, 인바운드는 다른 채널과 똑같이 `_handle_message` → 버스로 흐릅니다. 즉 WebUI도
  **하나의 채널**일 뿐이라 에이전트 코어는 UI 존재를 몰라도 됩니다(느슨한 결합).
- 개발 서버 프록시 대상(AGENTS.md): `/api`, `/webui`, `/auth`, WebSocket → 게이트웨이 포트 `8765`.

**왜 WebSocket인가:** 채팅은 서버가 먼저 밀어주는(스트리밍 토큰, 진행상황) 실시간 양방향 통신이 필요합니다.
요청-응답만 되는 일반 HTTP보다 WebSocket이 자연스럽습니다.

---

## `apps/` — 앱 매니페스트

`nanobot/apps/`(파일: `protocol.py`, `cli/`). `protocol.py`(L1 docstring)는 "설정으로 관리되는 agent app"의
**중립적 매니페스트 형태**를 정의합니다 — capabilities/trust/설치·제거 계획을 WebUI와 미래 레지스트리가 공유할
작은 어휘(vocabulary)입니다(docstring L3-5). 설치 어댑터 자체는 별도이고, 이 프로토콜은 **묘사(서술)** 만 담당합니다.

**요지:** `apps/`는 "이 에이전트가 어떤 앱/능력을 갖고 있고 어떻게 설치/신뢰하는가"를 표준 형태로 기술해 WebUI가
일관되게 다루게 합니다.

---

이것으로 nanobot 코어 소스 투어를 마칩니다. 배경 기술은 [tech_background/](tech_background/) 문서들에서 이어집니다.
