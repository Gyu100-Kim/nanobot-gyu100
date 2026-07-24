# 08. 장기 기억과 Dream, 그리고 Skills — 자기개선

> **이 문서에서 다루는 큰 맥락**
>
> [06](06_state_and_persistence.md)의 세션이 "대화 하나하나"의 기록이라면, 여기서 다루는 **메모리**는
> 세션을 넘나드는 **오래 남는 지식**입니다. nanobot은 durable memory 파일(`MEMORY.md`, `SOUL.md`, `USER.md`)과
> append-only `history.jsonl`을 두고, 주기적으로 **Dream**(꿈)이라는 배경 작업이 그 기록을 정리해
> 메모리 파일을 스스로 갱신합니다 — 이것이 nanobot의 "자기개선" 메커니즘입니다. 함께, **Skill**은
> `SKILL.md` 마크다운으로 에이전트에게 절차/지식을 가르치는 방식입니다. 근거는 `agent/memory.py`,
> `agent/skills.py`, `nanobot/skills/`, 그리고 Dream을 스케줄하는 `cli/commands.py`입니다.

## 이 문서의 소목차

1. [메모리 파일들: `MemoryStore`](#메모리-파일들-memorystore)
2. [`history.jsonl` append와 커서](#historyjsonl-append와-커서)
3. [Dream: 주기적 기억 통합](#dream-주기적-기억-통합)
4. [Dream은 어떻게 스케줄되는가](#dream은-어떻게-스케줄되는가)
5. [Skills: `SKILL.md`로 가르치기](#skills-skillmd로-가르치기)
6. [내장 스킬 목록](#내장-스킬-목록)

---

## 메모리 파일들: `MemoryStore`

`nanobot/agent/memory.py`의 `MemoryStore`(L40-41) docstring:
"Pure file I/O for memory files: MEMORY.md, history.jsonl, SOUL.md, USER.md."
즉 순수 파일 입출력 계층입니다(요약/LLM 호출은 별도의 `Consolidator`, L735). 관리 대상(L64-77):

- `memory/MEMORY.md`(L64) — 장기 사실(long-term facts). 에이전트가 기억해야 할 요점.
- `memory/history.jsonl`(L65) — append-only 사건 로그(자동 증가 커서 포함).
- `SOUL.md` — 에이전트의 성격/정체성. `USER.md` — 사용자에 대한 정보.
- `.dream_cursor`(L77) — Dream이 어디까지 처리했는지 표시하는 커서.
- 레거시 `HISTORY.md` → `history.jsonl` 일회성 마이그레이션(L95, L127).

`_DREAM_CONTENT_PATHS = ("SOUL.md", "USER.md", "memory/MEMORY.md")`(L47): Dream이 편집할 수 있는
"durable content" 파일 집합.

`get_memory_context()`(L241-)/`read_memory()`(L217-)는 시스템 프롬프트에 넣을 메모리 텍스트를 제공합니다
([07](07_prompt_and_context.md) `build_system_prompt` L86-88).

---

## `history.jsonl` append와 커서

`append_history(...)`(L247-)는 사건 하나를 `history.jsonl`에 붙이고 **자동 증가 커서**를 돌려줍니다
(docstring L254 "Append entry to history.jsonl and return its auto-incrementing cursor").

- `strip_think`로 템플릿/사고 누출을 제거한 뒤 기록.
- 항목 수 hard cap을 적용.
- **락(filelock)** 으로 "커서 할당 + append"를 원자화. **왜?** 여러 곳(여러 세션/백그라운드 작업)이 동시에
  같은 파일에 쓰면 커서가 꼬이거나 줄이 섞일 수 있습니다.
- JSONL 한 줄로 기록하고 `.cursor`/커서 상태를 갱신.

**커서의 의미:** Dream은 "지난번에 커서 N까지 처리했다"를 `.dream_cursor`로 기억하고, 그 이후의 새 항목만
다음에 처리합니다. 이 append-only + 커서 조합이 "무엇을 아직 정리 안 했는가"를 추적하는 핵심입니다.

---

## Dream: 주기적 기억 통합

**Dream**은 쌓인 `history.jsonl`을 읽어 LLM이 durable memory 파일을 갱신하게 하는 배경 작업입니다.

- `get_last_dream_cursor()`/`set_last_dream_cursor()`(L481-497): 처리 지점(`.dream_cursor`) 읽기/쓰기.
- `build_dream_prompt(max_entries=20)`(L531-557): 미처리 history(커서 이후)를 최대 20개 모아,
  Dream 템플릿(`templates/agent/dream.md`) + **현재 메모리 파일들의 실제 내용**(`_render_current_memory_files`, L559-579)
  + 대화 이력을 하나의 프롬프트로 만듭니다. 처리할 게 없으면 `None`.
  - **왜 현재 파일 내용을 임베드하나(설계 의도):** 모델이 "머릿속 낡은 기억"이 아니라 **실제 파일**을 근거로
    편집하게 해, 존재하지 않는 줄을 고치려다 실패하거나 감사 기록을 지어내는 문제를 없앱니다(docstring L536-539).
- `build_dream_tools()`(L592-): Dream 실행에는 **제한된 도구 레지스트리**만 줍니다 — `ReadFileTool`,
  `EditFileTool`, `WriteFileTool`, `ApplyPatchTool`(L595-597). **왜?** Dream은 오직 메모리 파일 편집만 해야 하므로
  셸/웹 같은 위험한 도구를 배제합니다(최소 권한).
- `dream_content_diff()`(L581-590): git으로 durable 파일들의 **실제 변경**을 요약합니다. **왜?** 커서를
  전진시킬지 여부를 LLM의 자기 보고가 아니라 "진짜 파일이 바뀌었는가"로 판단하기 위함입니다(docstring L584-586).

---

## Dream은 어떻게 스케줄되는가

Dream은 **cron 작업**으로 돕니다([11](11_cron_and_triggers.md)). `cli/commands.py`의 `on_cron_job` 콜백(L1431-)에서:

- **L1437** `if job.name == "dream":` — cron 작업 이름이 `"dream"`이면 **에이전트 루프를 거치지 않고 직접** 실행
  (주석 L1436 "Dream is an internal job — run directly, not through the agent loop").
- **L1448** `result = store.build_dream_prompt()` — 처리할 게 없으면(L1449) 종료.
- **L1454-1460** `resp = await agent.process_direct(prompt, session_key=key, ephemeral=True, tools=store.build_dream_tools(), ...)`
  — 제한된 도구로, 임시(ephemeral) 내부 세션에서 Dream을 실행.
- **L1462-1468** — `dream_content_diff()`로 실제 변경을 확인해 **변경이 있을 때만** 커서를 전진(`set_last_dream_cursor`).
  변경이 없으면 커서 유지(L1470-1479). **자기 보고를 신뢰하지 않는 설계.**
- **L1490-1496** — git이 초기화돼 있으면 diff 기반 커밋 메시지로 자동 커밋(메모리 변경의 버전 관리).
- **L1497-1498** — `compact_history()`로 history를 정리하고 오래된 dream 세션을 prune.

즉 흐름은 **"cron이 dream 작업을 트리거 → 미처리 history 수집 → 제한된 도구로 메모리 파일 편집 → 실제 diff 확인 →
커서 전진 + 커밋"** 입니다. [tech_background/03](tech_background/03_self_improving_agents.md)에서 배경을 다룹니다.

---

## Skills: `SKILL.md`로 가르치기

`nanobot/agent/skills.py`의 `SkillsLoader`(L21-) docstring(L25):
"Skills are markdown files (SKILL.md) that teach the agent how to use ..." — **스킬은 실행 코드가 아니라
마크다운 문서**입니다. 각 스킬은 `<root>/<name>/SKILL.md`(L42, L89) 구조입니다.

- `BUILTIN_SKILLS_DIR = Path(__file__).parent.parent / "skills"`(L12) — 내장 스킬 위치(`nanobot/skills/`).
- `list_skills(filter_unavailable=True)`(L51-): 워크스페이스 스킬 + 내장 스킬을 합칩니다. 같은 이름이면
  **워크스페이스가 우선**(사용자 커스터마이즈 우선). disabled/요구사항 미충족 스킬은 필터링.
- `load_skills_for_context(skill_names)`(L94-): 지정된 스킬의 마크다운(frontmatter 제거 후)을 컨텍스트에 삽입.
- `build_skills_summary(exclude=...)`(L111-): 이름/설명/경로/사용가능 여부만 담은 **요약**을 만듭니다.
  [07](07_prompt_and_context.md)에서 본 것처럼, 전체 본문 대신 요약만 시스템 프롬프트에 넣고 필요할 때 본문을
  읽게 하는 **점진적 로딩** 설계입니다.
- `get_always_skills()`(L221-): "항상 활성"으로 표시된 스킬 목록. 이들의 본문은 매 턴 `# Active Skills`로 주입됩니다.

**왜 마크다운 스킬인가(설계 의도):** 새 능력을 추가할 때 파이썬 코드를 짜는 대신 절차서를 글로 적으면 됩니다.
비개발자도 스킬을 만들 수 있고, `skill-creator` 스킬을 통해 에이전트가 스스로 스킬을 만들 수도 있습니다.
스킬의 YAML frontmatter에는 이름/설명/요구사항 등 메타데이터가 담깁니다.

---

## 내장 스킬 목록

`nanobot/skills/`에 실제 존재하는 디렉토리(확인됨):

```text
clawhub  cron  github  image-generation  long-goal  memory  my
skill-creator  summarize  tmux  update-setup  weather  README.md
```

사용자 계획에서 언급한 대표 스킬과 실제:
- `skill-creator` — 새 스킬을 만드는 스킬(자기 확장).
- `memory` — 메모리/Dream 사용 절차(`skills/memory/SKILL.md`).
- `summarize` — 요약 절차.
- `long-goal` — 장기 목표 수행 절차([11](11_cron_and_triggers.md)의 sustained goal와 연결).
- 그 외 실제 존재: `cron`, `github`, `image-generation`, `tmux`, `weather`, `clawhub`, `update-setup`, `my`.

다음 문서에서는 이 모든 것을 실행하는 LLM 프로바이더 계층을 봅니다 → [09_providers.md](09_providers.md).
