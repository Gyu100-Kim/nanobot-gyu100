# 07. 프롬프트와 컨텍스트 — LLM에게 무엇을 보여줄 것인가

> **이 문서에서 다루는 큰 맥락**
>
> LLM은 "그 순간 프롬프트로 받은 텍스트"만 알 수 있습니다. 그래서 매 턴 **무엇을, 얼마나** 넣을지가
> 에이전트 품질을 좌우합니다. 이 문서는 시스템 프롬프트/메시지 배열을 조립하는 `ContextBuilder`
> (`nanobot/agent/context.py`), 컨텍스트가 모델 한도를 넘지 않게 다듬는 `ContextGovernor`
> (`context_governance.py`), 유휴 세션 자동 압축 `AutoCompact`(`autocompact.py`), 모델 프리셋
> (`model_presets.py`), 실행 훅(`hook.py`, `progress_hook.py`), 그리고 프롬프트 템플릿(`templates/`)을 다룹니다.

## 비유로 먼저 이해하기 — AI에게 건네는 서류 가방 싸기

AI는 **기억이 없습니다.** 매번 질문할 때마다 "지금까지의 상황 전부"를 서류 가방에 싸서
건네야 합니다. 그 서류 가방이 **컨텍스트(context)**이고, 이 문서는 "가방을 어떻게, 무엇으로
싸는가"를 다룹니다.

가방 안에는 이런 서류가 들어갑니다(조립 담당: `context.py`):

- **행동 지침서(시스템 프롬프트)** — "너는 nanobot이라는 비서다, 이런 규칙을 지켜라"라는
  기본 지시문. `templates/` 폴더의 마크다운으로 관리합니다.
- **자기소개서와 기억 노트** — SOUL.md(성격), USER.md(사용자 정보), MEMORY.md(장기 기억).
- **참고 자료(스킬)** — 작업 요령이 적힌 SKILL.md 문서들. 전부 넣으면 가방이 터지므로
  평소엔 목차만 넣고, 필요할 때 본문을 꺼내 봅니다.
- **최근 대화 기록** — 세션 공책의 최근 페이지들.

문제는 **가방 크기에 한계**(모델의 컨텍스트 창)가 있다는 것. 그래서 두 개의 보조 장치가
있습니다: `ContextGovernor`(가방이 넘치면 오래된 서류부터 빼는 검사원)와
`AutoCompact`(한동안 안 쓰는 공책을 미리 요약해 두는 사서).

**꼭 가져가야 할 것 3가지**

1. AI에게 가는 모든 것은 "시스템 프롬프트 + 기억 파일 + 스킬 + 최근 대화"로 매번 새로 조립된다.
2. 가방 크기(토큰 한도)를 넘지 않도록 `ContextGovernor`가 오래된 것부터 잘라낸다.
3. `AutoCompact`는 놀고 있는 세션을 미리 요약해 다음 대화를 빠르고 싸게 만든다.

---

## 이 문서의 소목차

1. [컨텍스트는 무엇으로 조립되는가](#컨텍스트는-무엇으로-조립되는가)
2. [`build_system_prompt()` 라인바이라인](#build_system_prompt-라인바이라인)
3. [`build_messages()` — 최종 메시지 배열](#build_messages--최종-메시지-배열)
4. [프롬프트 템플릿: `templates/`](#프롬프트-템플릿-templates)
5. [`ContextGovernor` — 모델 한도 안에 맞추기](#contextgovernor--모델-한도-안에-맞추기)
6. [`AutoCompact` — 유휴 세션 자동 압축](#autocompact--유휴-세션-자동-압축)
7. [`model_presets.py` / 훅](#model_presetspy--훅)

---

## 컨텍스트는 무엇으로 조립되는가

한 턴에 LLM으로 가는 메시지 배열은 크게 두 부분입니다.
1. **시스템 프롬프트**(1개의 `system` 메시지) — 정체성 + 부트스트랩 문서 + 도구 계약 + 메모리 + 스킬 + 최근 이력.
2. **대화 이력 + 현재 사용자 메시지** — [06](06_state_and_persistence.md)의 `get_history()` 결과 + 지금 받은 발화(+런타임 메타).

`ContextBuilder`(`context.py` L51-)의 상수(L54-57)가 규모를 정합니다.
- `BOOTSTRAP_FILES = ["AGENTS.md", "SOUL.md", "USER.md"]`(L54) — 워크스페이스에서 항상 읽어들일 문서.
- `_MAX_RECENT_HISTORY = 50`(L56) — 시스템 프롬프트에 넣을 최근 히스토리 항목 수 상한.
- `_MAX_HISTORY_TOKENS = 8_000`(L57) — 그 히스토리 섹션의 토큰 상한.

---

## `build_system_prompt()` 라인바이라인

`context.py` L66-L117. 여러 조각을 모아 마지막에 구분선으로 잇습니다.

- **L78** `parts = [self._get_identity(...)]` — 정체성 섹션(누구이고 어떤 워크스페이스/OS/파이썬에서 도는지).
  `_get_identity`(L119-132)는 `templates/agent/identity.md`를 렌더링합니다.
- **L80-82** — `_load_bootstrap_files(root)`(L166-177): 워크스페이스의 `AGENTS.md`/`SOUL.md`/`USER.md`가 있으면
  `## 파일명` 헤더와 함께 붙입니다. **왜?** 사용자가 에이전트의 규칙/성격/사용자 정보를 이 파일들로 커스터마이즈합니다.
- **L84** `parts.append(render_template("agent/tool_contract.md"))` — 도구 사용 규약(어떻게 도구를 호출해야 하는지).
- **L86-88** — 메모리 컨텍스트(`memory.get_memory_context()`)를 넣되, 그 내용이 **기본 템플릿 그대로면**
  (사용자가 아직 안 채운 상태) 제외(`_is_template_content`, L179-185). **왜?** 빈 껍데기 메모리로 컨텍스트를 낭비하지 않기 위함.
- **L90-94** — "always" 스킬(항상 활성인 스킬)의 본문을 `# Active Skills`로 삽입([08](08_memory_and_dream.md)).
- **L96-98** — 나머지 스킬은 **요약(summary)만** 넣습니다(`build_skills_summary`, `templates/agent/skills_section.md`).
  **왜 요약만?** 모든 스킬 본문을 다 넣으면 토큰이 폭발합니다. "이런 스킬이 있다"는 목록만 주고, LLM이 필요할 때
  해당 스킬 파일을 읽게 하는 **점진적 로딩(progressive loading)** 설계입니다.
- **L100-112** — `include_memory_recent_history`면 Dream[(용어사전)](../dict/03_memory_context_session.md#dream) 커서 이후의 최근 history를 읽어(`read_recent_history_for_prompt`)
  최근 50개로 자르고(L107), 8000토큰으로 절단(L111) 후 `# Recent History`로 삽입.
- **L114-115** — 아카이브된 컨텍스트 요약(`session_summary`)이 있으면 `[Archived Context Summary]`로 붙임.
- **L117** `return "\n\n---\n\n".join(parts)` — 모든 조각을 `---`로 구분해 하나의 시스템 프롬프트로 결합.

---

## `build_messages()` — 최종 메시지 배열

`context.py` L187-L255. LLM[(용어사전)](../dict/08_ai_llm_concepts.md#llm) 호출용 완전한 메시지 리스트를 만듭니다.

- **L210-216** — 런타임 부가 라인(`extra`)을 모읍니다: 지속 목표 상태(`goal_state_runtime_lines`), MCP/CLI 런타임
  라인(`runtime_lines`), 그리고 호출자가 준 `current_runtime_lines`.
- **L217-223** `runtime_ctx = self._build_runtime_context(...)` — 현재 시각/채널/Chat ID/Sender ID/부가 라인을
  **신뢰하지 않는 런타임 메타 블록**으로 감쌉니다(`_build_runtime_context`, L134-150). **왜 태그로 감싸나:**
  사용자 발화가 아니라 시스템이 붙인 메타데이터임을 모델이 구분하도록(프롬프트 인젝션 방어 성격).
- **L224** `user_content = self._build_user_content(current_message, media)` — 텍스트(+이미지)를 만듭니다.
  이미지가 있으면 base64로 인코딩해 `image_url` 블록으로 구성(L257-279). 멀티모달 입력.
- **L230-233** — 런타임 컨텍스트를 **사용자 콘텐츠 뒤에** 붙여 하나의 user 메시지로 병합.
  주석(L226-229): 시간이 매 턴 바뀌므로 런타임 컨텍스트를 뒤에 두어 **앞부분(user prefix)을 안정**시켜야
  프롬프트 캐시가 적중합니다.
- **L234-248** — `[{"role":"system", "content": build_system_prompt(...)}, *history]`로 배열을 만듭니다.
- **L249-254** — 마지막 메시지가 현재와 같은 role이면(연속 user 등) 내용을 병합(L249-253). **왜?** 일부
  프로바이더는 같은 role 메시지가 연속되면 거부하기 때문입니다.

---

## 프롬프트 템플릿: `templates/`

프롬프트 문구를 코드에 하드코딩하지 않고 `nanobot/templates/`의 마크다운으로 관리합니다(Jinja2[(용어사전)](../dict/09_dev_stack.md#jinja2) 렌더링; [02](02_modules_and_stack.md)).

- 워크스페이스 부트스트랩 원본: `templates/AGENTS.md`, `SOUL.md`, `USER.md`, `HEARTBEAT.md`.
- 에이전트 프롬프트 조각: `templates/agent/` — `identity.md`, `tool_contract.md`, `platform_policy.md`,
  `skills_section.md`, `dream.md`, `consolidator_archive.md`, `max_iterations_message.md`,
  `subagent_system.md`, `subagent_announce.md`, `evaluator.md`, `cron_reminder.md`, `_snippets/`.
- 메모리 기본값: `templates/memory/MEMORY.md`.

**왜 템플릿 분리(설계 의도):** 프롬프트를 코드 배포와 분리해 수정·검토·번역이 쉽고, 사용자가 워크스페이스에
복사된 사본을 커스터마이즈할 수 있습니다(`_is_template_content`로 커스터마이즈 여부를 판별).

---

## `ContextGovernor` — 모델 한도 안에 맞추기

> **쉽게 말하면:** 서류 가방(컨텍스트)이 넘치는지 무게(토큰 수)를 재고, 넘치면 오래된 서류부터 빼는 검사원입니다. 단, 방금 오간 대화나 꼭 필요한 지침서는 빼지 않습니다.

`nanobot/agent/context_governance.py`. LLM에 보내기 직전 메시지를 **정돈**합니다([04](04_agent_loop.md)의 `_run_core`가 호출).

- `ContextGovernanceConfig`(L58-68): `context_window_tokens`, `max_tokens` 등 예산 정보를 담는 dataclass.
- `prepare_for_model(...)`(L75-): 다음을 순차 적용합니다.
  - `normalize_tool_result`(L110): 도구 결과를 규격화.
  - `strip_placeholder_assistant_messages`(L139), `strip_malformed_tool_calls`(L177): 빈/깨진 메시지 정리.
  - `drop_orphan_tool_results`(L232), `backfill_missing_tool_results`(L258): 도구 호출↔결과 짝을 맞춤.
    **왜?** 대부분의 프로바이더는 tool_call과 그 결과가 짝이 맞아야 하며, 고아가 있으면 요청이 거부됩니다.
  - `apply_tool_result_budget`(L298): 도구 결과 길이를 제한.
  - `snip_history`(L380): 입력 예산(`input_budget`, L92-105 = context_window − max_output − 안전버퍼)에 맞게
    오래된 히스토리를 잘라냄. 토큰 추정은 `estimate_prompt_tokens_chain`(tiktoken[(용어사전)](../dict/08_ai_llm_concepts.md#tiktoken) 기반).
- **핵심 원칙:** 디스크의 원문 세션은 그대로 두고, **이번 요청에 보낼 사본**만 압축/수선합니다.

---

## `AutoCompact` — 유휴 세션 자동 압축

`nanobot/agent/autocompact.py`의 `AutoCompact`(L17-)는 **오래 조용한 세션**의 긴 대화를 배경에서 요약해 둡니다.

- `_RECENT_SUFFIX_MESSAGES = 8`(L18): 압축해도 최근 8개 메시지는 원문 유지.
- `_INTERNAL_SESSION_PREFIXES = ("dream:",)`(L19): 내부 세션(Dream)은 압축 대상에서 제외(`_is_internal_session`, L62-63).
- `_is_expired`(L29-): 마지막 활동 시각이 TTL[(용어사전)](../dict/03_memory_context_session.md#ttl)(분)을 넘었는지 판단.
- `_has_compactable_idle_tail`(L37-): 압축 가능한 유휴 꼬리가 있는지 `retain_recent_legal_suffix`로 확인.
- `check_expired(schedule_background, ...)`(L65-): [04](04_agent_loop.md)의 `run()`이 1초 유휴마다 호출.
  만료·비내부·비진행 세션에 대해 `_archive`를 **백그라운드**로 예약.
- `_archive(key)`(L80-): `consolidator.compact_idle_session(...)`(L85)으로 요약을 만들어 저장.
- `prepare_session(session, key)`(L101-): 턴 시작(COMPACT 상태)에서 in-memory/저장된 요약을 복원해
  `pending_summary`로 돌려줍니다([04](04_agent_loop.md) `_state_compact`).

**왜 배경 압축인가:** 사용자가 오래 뒤 다시 말을 걸 때, 그 사이 쌓인 긴 대화를 실시간으로 요약하면 응답이 느려집니다.
유휴 시간에 미리 요약해 두면 다음 턴이 빨라지고 토큰도 절약됩니다.

---

## `model_presets.py` / 훅

- **`model_presets.py`**(L1 "Helpers for runtime model preset selection"): 런타임에 어떤 모델 프리셋을 쓸지 고르고,
  프리셋별 `ProviderSnapshot`을 로딩합니다([09](09_providers.md)의 factory와 연결).
- **`hook.py`**(L1 "Shared lifecycle hook primitives for agent runs"): `AgentHook`/`AgentHookContext` —
  실행 수명주기(`before_run`/`on_error`/`after_run`/`on_finally` 등)에 개입하는 지점. [04](04_agent_loop.md)의
  `AgentRunner.run`이 이 훅을 호출합니다.
- **`progress_hook.py`**(L1 "Agent[(용어사전)](../dict/01_core_architecture.md#agent) hook that adapts runner events into channel progress UI"): 러너 이벤트(스트리밍
  델타, 도구 힌트, reasoning)를 채널 진행상황 UI로 변환하는 훅. CLI/WebUI의 "생각 중…" 표시가 여기서 나옵니다.

다음 문서에서는 장기 기억과 자기개선(Dream/Skills)을 봅니다 → [08_memory_and_dream.md](08_memory_and_dream.md).
