# 4. Memory and Session Management (메모리와 세션 관리)

nanobot의 기억은 "지금 이 순간은 가볍게, 시간이 지나면 성찰적으로"라는 철학 위에 있다(`docs/memory.md`). 이를 위해 기억을 여러 계층으로 나눈다.

| 계층 | 위치 | 성격 |
|---|---|---|
| 세션 히스토리 | `<workspace>/sessions/*.jsonl` | 살아있는 단기 대화 |
| 히스토리 아카이브 | `<workspace>/memory/history.jsonl` | 압축된 과거 턴의 append-only 아카이브 |
| 장기 지식 | `SOUL.md`, `USER.md`, `memory/MEMORY.md` | 지속되는 지식 파일 |
| 버전 기록 | `<workspace>/memory/.git/` (`GitStore`) | 장기 파일의 변경 이력 |

두 흐름이 이 계층을 잇는다.

1. **Consolidator** — 대화가 컨텍스트 창을 압박할 만큼 커지면 가장 오래된 안전한 구간을 요약해 `history.jsonl`에 append.
2. **Dream** — cron 스케줄로 도는 느린 계층. `history.jsonl`의 새 항목과 현재 `SOUL/USER/MEMORY`를 읽어 장기 파일을 최소 변경으로 수정.

## 관련 서브시스템

- 세션 저장/로드/복구/포크: `nanobot/session/manager.py` → [4.1 Session Manager](04.1-session-manager.md).
- 메모리 스토어와 Dream: `nanobot/agent/memory.py` → [4.2 Memory Store and Dream System](04.2-memory-store-and-dream-system.md).
- 컨솔리데이션과 유휴 auto-compact: `nanobot/agent/autocompact.py`, `Consolidator` → [4.3 Consolidation and AutoCompact](04.3-consolidation-and-autocompact.md).

## 사용자 제어 명령

메모리는 감춰져 있지 않다. `/dream`, `/dream-log`, `/dream-restore`, `/dream-prompt` 명령으로 검사·안내·복원할 수 있다(`nanobot/command/builtin.py`, [8.1](08.1-cli-commands-reference.md)).

### 참조 파일

- `nanobot/session/manager.py`, `nanobot/session/keys.py`, `nanobot/session/goal_state.py`
- `nanobot/agent/memory.py`, `nanobot/agent/autocompact.py`
- `nanobot/utils/gitstore.py`
- `docs/memory.md`
