# 13. API 서버 · Python SDK · WebUI — 바깥에서 nanobot 쓰기

> **이 문서에서 다루는 큰 맥락**
>
> 지금까지는 nanobot 내부였습니다. 이 문서는 **외부에서 접근하는 3가지 통로**를 다룹니다:
> (1) `nanobot/api/` — **OpenAI 호환 HTTP 서버**(다른 앱이 nanobot을 "OpenAI처럼" 호출), (2) `nanobot/sdk/` —
> **Python SDK**(코드에서 세션/메모리/런타임 제어), (3) `nanobot/web/` + `webui/` — **번들 WebUI**(브라우저 UI,
> WebSocket 프로토콜로 게이트웨이와 통신). `nanobot/apps/`(앱 매니페스트)도 함께 봅니다.

## 이 문서의 소목차

1. [세 통로 한눈에](#세-통로-한눈에)
2. [OpenAI 호환 API 서버: `api/server.py`](#openai-호환-api-서버-apiserverpy)
3. [인증 미들웨어 라인바이라인](#인증-미들웨어-라인바이라인)
4. [Python SDK: `sdk/`](#python-sdk-sdk)
5. [WebUI와 WebSocket 프로토콜](#webui와-websocket-프로토콜)
6. [`apps/` — 앱 매니페스트](#apps--앱-매니페스트)

---

## 세 통로 한눈에

| 통로 | 위치 | 무엇을 위한 것 |
| --- | --- | --- |
| HTTP API | `nanobot/api/server.py` | 다른 프로그램이 OpenAI 호환 `/v1/chat/completions`로 nanobot 호출 |
| Python SDK | `nanobot/sdk/` | 파이썬 코드에서 세션/메모리/런타임을 직접 제어 |
| WebUI | `nanobot/web/`(번들) + `webui/`(소스) | 브라우저 채팅 UI, WebSocket으로 게이트웨이와 통신 |

세 통로 모두 결국 [04](04_agent_loop.md)의 `AgentLoop`를 재사용합니다 — 입력 형식만 다를 뿐 두뇌는 하나입니다.

---

## OpenAI 호환 API 서버: `api/server.py`

`nanobot/api/server.py`(L3 "Provides /v1/chat/completions and /v1/models endpoints") — aiohttp 기반.

엔드포인트(`create_app` L431-433에서 등록):
- **`POST /v1/chat/completions`** → `handle_chat_completions`(L206-). JSON과 `multipart/form-data`(이미지 첨부) 모두 지원(L207).
  - 스트리밍이면 SSE(`_sse_chunk` L99)로 토큰을 흘려보냄(`_on_stream` L261, `_on_stream_end` L267).
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

## Python SDK: `sdk/`

`nanobot/sdk/`(L1 "Internal helpers for the high-level nanobot Python SDK"). 코드에서 직접 제어하는 클라이언트들:

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

- **소스**: `webui/` — Vite 기반 React/TypeScript SPA(`package.json`, `bun.lock`, `src/`, `index.html` 확인).
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
