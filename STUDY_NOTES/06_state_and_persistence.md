# 06. 상태와 영속성 — JSONL 세션과 워크스페이스

> **이 문서에서 다루는 큰 맥락**
>
> nanobot은 대화 기록을 **데이터베이스가 아니라 파일**로 저장합니다. 정확히는 세션마다 하나의
> **JSONL[(용어사전)](../dict/03_memory_context_session.md#jsonl) 파일**(줄 하나가 JSON 하나)입니다. (SQLite/FTS5 전문 검색 같은 것은 사용하지 않습니다.)
> 이 문서는 세션 자료구조 `Session`, 저장/로딩을 담당하는 `SessionManager`(`nanobot/session/manager.py`),
> 세션 키 규칙(`keys.py`), 그리고 이력 조립·압축·가시성을 돕는 보조 모듈들을 라인 근거로 설명합니다.
>
> **왜 파일인가(설계 의도):** 개인용 경량 에이전트에서는 별도 DB 서버 없이 파일만으로 이식성·투명성·백업이
> 쉽습니다. 사용자가 `.jsonl`을 직접 열어 대화를 확인/수정할 수 있고, git으로 버전 관리하기도 좋습니다.

## 이 문서의 소목차

1. [저장 위치와 파일 형식](#저장-위치와-파일-형식)
2. [세션 키: `keys.py`](#세션-키-keyspy)
3. [`Session` 자료구조](#session-자료구조)
4. [`get_history()` — LLM에 보낼 이력 조립](#get_history--llm에-보낼-이력-조립)
5. [`SessionManager` — 로딩/저장 라인바이라인](#sessionmanager--로딩저장-라인바이라인)
6. [파일 상한과 압축(consolidation)](#파일-상한과-압축consolidation)
7. [보조 모듈들](#보조-모듈들)

---

## 저장 위치와 파일 형식

세션은 워크스페이스(`~/.nanobot/workspace/`) 아래 `sessions/` 디렉토리에 저장됩니다.
`SessionManager`(`manager.py` L413-L417) docstring: "Sessions are stored as JSONL files in the sessions directory."
파일 경로는 `_get_session_path`(L448-450)에서 `sessions_dir / f"{storage_key}.jsonl"`로 만듭니다.

한 JSONL 파일의 구조(저장 로직 `save`, L646-657 기준):
1. **첫 줄**: `{"_type": "metadata", "key": ..., "created_at": ..., "updated_at": ..., "metadata": {...}, "last_consolidated": N}`
2. **이후 각 줄**: 메시지 하나(`{"role": ..., "content": ..., "timestamp": ...}` 등).

**왜 JSONL인가:** 줄 단위 append/parse가 쉽고, 한 줄이 깨져도 나머지를 복구할 수 있습니다(`_repair`, L566).

---

## 세션 키: `keys.py`

`nanobot/session/keys.py` 전체:
```python
UNIFIED_SESSION_KEY = "unified:default"

def session_key_for_channel(channel: str, chat_id: str, *, unified_session: bool = False) -> str:
    if unified_session:
        return UNIFIED_SESSION_KEY
    return f"{channel}:{chat_id}"
```
- 기본 세션 키는 `"{channel}:{chat_id}"` (예: `telegram:12345`). 즉 **채널+채팅방 = 하나의 대화 세션**입니다.
- `unified_session=True`면 모든 채널을 `"unified:default"` 하나로 합칩니다.
  **왜?** "어디서 말을 걸든 하나의 에이전트가 같은 기억을 공유"하게 하고 싶을 때 씁니다(트레이드오프: 채널 간
  대화가 섞임). 이 키는 [04](04_agent_loop.md)의 `InboundMessage.session_key`와 일치합니다.

---

## `Session` 자료구조

`manager.py` L120-L128:
```python
@dataclass
class Session:
    key: str  # channel:chat_id
    messages: list[dict[str, Any]] = field(default_factory=list)
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)
    metadata: dict[str, Any] = field(default_factory=dict)
    last_consolidated: int = 0  # 이미 파일로 통합된 메시지 수
```
- `last_consolidated`(L128): "여기까지의 메시지는 이미 요약/통합됐다"는 커서. `get_history`는 이 인덱스 **이후**만
  LLM[(용어사전)](../dict/08_ai_llm_concepts.md#llm) 입력으로 씁니다. **왜?** 오래된 대화는 요약본으로 대체하고, 최근 대화만 원문으로 보내 컨텍스트를 아낍니다([07](07_prompt_and_context.md)).
- `__post_init__`(L130-137): 손상된 메타데이터로 `last_consolidated`가 범위를 벗어나면 0으로 리셋(방어).
- `add_message`(L139-148): 메시지에 role/content/timestamp + 추가 kwargs를 붙여 append하고 `updated_at` 갱신.

---

## `get_history()` — LLM에 보낼 이력 조립

`Session.get_history`(L150-284)는 저장된 메시지를 **모델에 보낼 형태**로 가공합니다. 핵심 단계:

- **L162** `unconsolidated = self.messages[self.last_consolidated:]` — 통합 커서 이후만 대상.
- **L164-169** — `max_messages`(개수 상한)로 최근 구간을 자름(`recent_message_start_index`).
- **L173-179** — 가능하면 **user 턴에서 시작**하도록 조정(대화가 중간에서 시작되지 않게).
- **L181-184** — 앞부분의 고아(orphan) 도구 결과 제거(`find_legal_message_start`). 도구 결과만 덩그러니 남으면 안 되기 때문.
- **L187-251** — 각 메시지를 정리:
  - `_command` 표시 메시지는 제외(L188-189) — 슬래시 명령 기록은 LLM 맥락에서 뺌.
  - 이미지 전용 user 턴은 `[image: path]` 브레드크럼을 합성(L194-204). **왜?** 이미지가 사라진 자리를 텍스트로
    남겨야 뒤 이어지는 대화가 "허공에 답한 것"처럼 보이지 않습니다.
  - CLI 앱/MCP 프리셋 첨부도 유사하게 브레드크럼으로 요약(L205-243).
  - `tool_calls`, `tool_call_id`, `reasoning_content` 등 필요한 키만 보존(L248-250).
- **L253-283** — `max_tokens`가 주어지면 **뒤에서부터 토큰 예산**만큼만 유지(L256-262)하고, 다시 첫 user 턴/합법적
  경계에 맞춰 정렬. 토큰 계수는 `estimate_message_tokens`(tiktoken[(용어사전)](../dict/08_ai_llm_concepts.md#tiktoken) 기반; [02](02_modules_and_stack.md)).

**설계 요지:** 저장된 원문은 손대지 않고, **모델에 보낼 사본만** 개수·토큰·경계 규칙에 맞춰 잘라 만듭니다.

---

## `SessionManager` — 로딩/저장 라인바이라인

### `get_or_create(key)` (L478-496)
- L488-489 — 메모리 캐시에 있으면 그대로 반환.
- L491-493 — 없으면 디스크에서 `_load`, 그래도 없으면 새 `Session(key=key)` 생성.
- L495 — 캐시에 넣고 반환. **왜 캐시인가:** 같은 세션을 반복 로드하는 디스크 I/O를 줄입니다.

### `_load(key)` (L498-564)
- L500-523 — 현재 경로에 없으면 **레거시 경로**(옛 파일명 규칙)를 찾아 이동(migration). 단 저장된 키가 다른
  세션이면 건드리지 않음(L509-517). **왜?** 파일명 규칙이 바뀌어도 기존 사용자 데이터를 잃지 않기 위함입니다.
- L535-549 — JSONL을 한 줄씩 읽어 `_type == "metadata"`면 메타데이터로, 아니면 메시지로 분류.
- L551-558 — `Session` 객체로 조립.
- L559-564 — 파싱 실패 시 `_repair`(L566)로 손상 파일에서 최대한 복구.

### `save(session, fsync=False)` (L632-679) — 원자적 저장
- L642-643 — 실제 경로와 임시 파일(`.jsonl.tmp`).
- L646-657 — 임시 파일에 메타데이터 줄 + 메시지 줄들을 기록(`ensure_ascii=False`로 한글 등 그대로 저장).
- L658-660 — `fsync=True`면 파일을 디스크에 강제 플러시.
- L662 `os.replace(tmp_path, path)` — **원자적 교체**. **왜?** 쓰다가 죽어도 원본이 반쯤 덮여 깨지지 않게,
  완성된 임시 파일을 통째로 rename합니다.
- L664-674 — `fsync`면 디렉토리까지 fsync해 rename 자체를 내구화(rclone/NFS/FUSE 대비; docstring L638-640).
- L675-677 — 예외 시 임시 파일 삭제.
- `flush_all()`(L681-695): 종료 시 캐시된 모든 세션을 `fsync=True`로 재저장(graceful shutdown 내구성).

---

## 파일 상한과 압축(consolidation)

세션이 무한히 커지지 않도록 두 메커니즘이 있습니다.

- **`enforce_file_cap`**(L388-410): 메시지 수가 상한(`FILE_MAX_MESSAGES`)을 넘으면 `retain_recent_legal_suffix`로
  최근만 남기고, 잘려나간 오래된 메시지 중 아직 통합 안 된 부분을 `on_archive` 콜백으로 넘겨 원문 아카이브합니다.
  [04](04_agent_loop.md)의 `_state_save`(L1617-1620)에서 호출되며, `on_archive`는 `memory.raw_archive`입니다.
- **`retain_recent_legal_suffix`**(L293-386): "합법적인 최근 꼬리"만 남기는 정교한 슬라이싱. user 턴 경계와
  도구 호출 경계를 지켜 잘라내고, 무엇이 드롭됐고 그중 몇 개가 이미 통합된 것인지(`RetentionResult`)를 돌려줍니다.
- **토큰 기준 통합**은 `Consolidator.maybe_consolidate_by_tokens(...)`가 담당하며([07](07_prompt_and_context.md)),
  `_state_build`/`_state_save`에서 트리거됩니다.

**요지:** 최근 대화는 원문 그대로, 오래된 대화는 요약/아카이브로 — 이 이원 구조가 nanobot 상태 관리의 핵심입니다.

---

## 보조 모듈들

`nanobot/session/`의 나머지 파일(각 파일 docstring 근거):

| 파일 | 역할 |
| --- | --- |
| `webui_turns.py` | "Session[(용어사전)](../dict/01_core_architecture.md#session) turn helpers for WebUI-capable WebSocket[(용어사전)](../dict/05_channels_gateway_ui.md#websocket) sessions"(L1). WebUI[(용어사전)](../dict/05_channels_gateway_ui.md#webui)(WebSocket) 세션의 턴 진행/진행상황 스트리밍 보조. |
| `automation_turns.py` | "Shared handling for session-bound automation turns"(L1). cron/트리거로 생성되는 자동화 턴을 이력에 표시(`_automation_turn` 메타, L10). |
| `turn_continuation.py` | "Internal turn continuation helpers"(L1). 예산 경계(budget-boundary)에서 턴을 이어갈지 결정하는 정책을 `AgentLoop` 밖으로 분리(L3-5). [04](04_agent_loop.md)의 `_state_run` L1590에서 사용. |
| `goal_state.py` | 지속 목표(`long_task`/`complete_goal`)의 세션 메타데이터 헬퍼(L1). `metadata[GOAL_STATE_KEY]`를 읽고 런타임 라인/타임아웃을 계산. |
| `history_visibility.py` | 저장된 이력 메시지의 가시성 판단(L1). `_hidden_history` 마커(L10) 등으로 특정 메시지를 LLM/사용자에게 숨김. |

다음 문서에서는 이 이력이 시스템 프롬프트/컨텍스트로 어떻게 조립·압축되는지 봅니다 → [07_prompt_and_context.md](07_prompt_and_context.md).
