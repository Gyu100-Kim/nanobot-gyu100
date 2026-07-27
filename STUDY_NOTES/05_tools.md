# 05. 도구(Tool) 계층 — LLM에게 손발을 달아주기

> **이 문서에서 다루는 큰 맥락**
>
> LLM은 텍스트만 생성할 뿐, 스스로 파일을 읽거나 셸을 실행할 수 없습니다. **도구(Tool[(용어사전)](../dict/01_core_architecture.md#tool))** 는 LLM이
> "이 함수를 이런 인자로 호출해줘"라고 요청하면 실제로 코드를 실행해 결과를 돌려주는 다리입니다.
> 이 문서는 도구의 추상 기반(`base.py`), 파라미터 스키마(`schema.py`), 등록/실행소(`registry.py`),
> 그리고 `pkgutil` 기반 **자동 발견**과 플러그인 엔트리포인트(`loader.py`)를 살펴보고, 대표 도구
> `read_file`(`filesystem.py`)을 라인바이라인으로 읽습니다.
>
> 도구가 실제로 호출되는 시점은 [04_agent_loop.md](04_agent_loop.md)의 `AgentRunner._execute_tools`입니다.

## 비유로 먼저 이해하기 — AI에게 손발 달아 주기

AI(LLM)는 원래 **말만 할 수 있는 두뇌**입니다. 파일을 열지도, 인터넷 검색을 하지도 못합니다.
그래서 nanobot은 AI에게 **공구함(Tool 계층)**을 쥐여 줍니다.

작동 방식은 의외로 단순합니다.

1. **공구 카탈로그 보여 주기** — 각 도구는 "이름 / 설명 / 사용법(넣어야 할 값)"이 적힌
   카탈로그 카드(스키마)를 갖고 있습니다. 대화를 시작할 때 AI에게 이 카탈로그를 통째로
   보여 줍니다.
2. **AI가 주문서 쓰기** — AI는 "read_file 도구를 path='메모.txt'로 실행해 줘"처럼
   정해진 형식(JSON)의 주문서를 씁니다. AI가 직접 실행하는 것이 아닙니다.
3. **nanobot이 대신 실행** — `ToolRegistry`(공구함 관리자)가 주문서를 받아 해당 도구를 찾아
   실행하고, 결과를 다시 AI에게 보여 줍니다.

이 문서의 나머지는 그 세부 사항입니다: 도구 한 개가 지켜야 할 규격(`base.py`),
카탈로그 카드 만드는 법(`schema.py`), 관리자(`registry.py`), 그리고 새 도구를 폴더에
넣기만 하면 자동으로 발견되는 장치(`loader.py`). 마지막에 실제 도구 하나(`read_file`)를
한 줄씩 읽어 봅니다.

**꼭 가져가야 할 것 3가지**

1. AI는 도구를 "직접 실행"하지 않는다 — 주문서(tool call)만 쓰고, 실행은 nanobot이 한다.
2. 모든 도구는 같은 규격(`Tool` 기반 클래스)을 따르므로, 새 도구 추가가 쉽다.
3. 도구는 폴더 스캔(pkgutil)과 플러그인 등록(entry point)으로 **자동 발견**된다.

---

## 이 문서의 소목차

1. [도구 계층 전체 그림](#도구-계층-전체-그림)
2. [`Tool` 추상 기반: `base.py`](#tool-추상-기반-basepy)
3. [파라미터 스키마: `schema.py`](#파라미터-스키마-schemapy)
4. [`ToolRegistry`: 등록·검증·실행](#toolregistry-등록검증실행)
5. [자동 발견과 플러그인: `loader.py`](#자동-발견과-플러그인-loaderpy)
6. [대표 도구들 개요](#대표-도구들-개요)
7. [라인바이라인: `read_file`(`ReadFileTool`)](#라인바이라인-read_filereadfiletool)

---

## 도구 계층 전체 그림

- 모든 도구는 `Tool`(추상 클래스)을 상속하고 `name`/`description`/`parameters`/`execute`를 구현합니다.
- `ToolLoader`가 `nanobot/agent/tools/` 패키지를 스캔해 `Tool` 하위 클래스를 자동 발견하고 `ToolRegistry`에 등록합니다.
- LLM에는 `registry.get_definitions()`가 만든 **함수 스키마 목록**이 전달됩니다.
- LLM이 도구 호출을 요청하면 `registry.execute(name, params)`가 이름 해석 → 캐스팅 → 검증 → 실행을 수행합니다.

---

## `Tool` 추상 기반: `base.py`

`nanobot/agent/tools/base.py`의 `Tool`(L146-L296)이 모든 도구의 계약입니다.

- **필수 추상 멤버**:
  - `name`(L158-162) — 함수 호출에서 쓰는 이름.
  - `description`(L164-168) — LLM이 언제 이 도구를 쓸지 판단하는 설명.
  - `parameters`(L170-174) — 파라미터의 JSON Schema.
  - `execute(**kwargs)`(L209-212) — 실제 실행. 실패는 `ToolResult.error(...)`로 반환.
- **동시성 힌트**:
  - `read_only`(L176-179): 부작용이 없어 병렬 실행이 안전한가(기본 False).
  - `concurrency_safe`(L181-184): `read_only and not exclusive`.
  - `exclusive`(L186-189): 단독 실행이 필요한가.
  **왜?** `AgentRunner`가 여러 도구를 동시에 실행할지(`concurrent_tools`) 결정할 때 사용합니다([04](04_agent_loop.md)의 `_execute_tools`).
- **플러그인 메타데이터**(L191-207): `config_key`, `_plugin_discoverable`, `_scopes`(기본 `{"core"}`),
  그리고 `enabled(ctx)`/`create(ctx)` 훅. `_scopes`는 이 도구가 어떤 실행 맥락(core/subagent/memory 등)에서
  쓰일 수 있는지를 제한합니다.
- **입력 캐스팅/검증**:
  - `cast_params`(L233-238) / `_cast_value`(L240-276): LLM이 문자열로 준 `"3"`을 정수 `3`으로,
    `"true"`를 불리언 `True`로 안전 변환. **왜?** LLM은 종종 타입을 문자열로 흘려보내므로 스키마 기반으로 교정합니다.
  - `validate_params`(L278-285): JSON Schema로 검증, 오류 메시지 리스트 반환.
- **출력 타입 `ToolResult`**(L131-143): `str`을 상속해 문자열처럼 쓰되 `is_error` 플래그를 갖습니다.
  `ToolResult.error(...)`로 오류를 표시합니다. **왜 str 상속인가:** 기존 코드가 도구 결과를 그냥 문자열로
  다뤄도 호환되면서, 오류 여부라는 구조적 정보를 추가로 실어 보내기 위함입니다.
- **`to_schema()`**(L287-296): OpenAI function-calling 형식(`{"type":"function","function":{...}}`)으로 변환.

**편의 데코레이터** `tool_parameters(schema)`(L299-331): `@property def parameters`를 직접 쓰는 대신
클래스에 스키마를 붙여 줍니다. 접근할 때마다 `deepcopy`로 새 사본을 돌려줘(L321) 변형 사고를 막습니다.

---

## 파라미터 스키마: `schema.py`

`base.py`의 `Schema`(L28-128)는 JSON Schema[(용어사전)](../dict/08_ai_llm_concepts.md#json-schema) 조각을 검증하는 공용 로직입니다.

- `validate_json_schema_value(val, schema, path)`(L47-108): 타입/enum/min·max/길이/필수 필드/추가 속성/배열
  항목을 재귀 검증하고 사람이 읽을 오류 메시지를 모읍니다. 예: `"parameter should be integer"`.
- `resolve_json_schema_type`(L36-41): `["string","null"]` 같은 유니온에서 null이 아닌 타입을 뽑습니다(nullable 지원).

구체 스키마 타입(`StringSchema`, `IntegerSchema`, `BooleanSchema` 등)은 `nanobot/agent/tools/schema.py`에 있고,
`filesystem.py`가 이를 import해 파라미터를 선언합니다(L13-18).

**왜 자체 스키마 검증인가(설계 의도):** LLM이 준 인자를 모델에 그대로 신뢰하지 않고, 실행 전에 타입·범위·필수값을
검사해 잘못된 호출을 **친절한 오류 메시지**로 되돌려 LLM이 스스로 교정하게 합니다(`registry.execute`의 hint).

---

## `ToolRegistry`: 등록·검증·실행

> **쉽게 말하면:** 공구함 관리자입니다. 도구를 이름으로 등록해 두고, AI의 주문서가 오면 (1) 그런 도구가 있는지, (2) 빈칸(파라미터)을 제대로 채웠는지 검사한 뒤 실행해 결과를 돌려줍니다.

`nanobot/agent/tools/registry.py`의 `ToolRegistry`(L13-L190).

- **저장소**: `self._tools: dict[str, Tool]`(L21) — 이름→도구 인스턴스. `register`/`unregister`(L24-32)로 관리하며
  변경 시 캐시된 정의(`_cached_definitions`)를 무효화합니다.
- **`get_definitions()`**(L71-94): LLM에 줄 스키마 목록을 만듭니다. 내장 도구를 먼저, `mcp_`로 시작하는 MCP[(용어사전)](../dict/08_ai_llm_concepts.md#mcp) 도구를
  뒤에 두고 각각 이름순 정렬 후 **캐싱**합니다. **왜 안정적 정렬인가:** 프롬프트가 매번 동일해야 프로바이더의
  프롬프트 캐시(prompt caching)가 적중하기 때문입니다([09](09_providers.md)).
- **`prepare_call(name, params)`**(L96-128): 한 도구 호출을 (1) 이름으로 찾고(없으면 유사 이름 제안, L104-105),
  (2) 인자를 dict로 강제(`_coerce_params`), (3) 스키마 캐스팅(`cast_params`), (4) 검증(`validate_params`)합니다.
  실패 시 `ToolResult.error(...)`를 반환합니다.
- **`execute(name, params)`**(L165-179): `prepare_call`로 준비한 뒤 `tool.execute(**params)`를 호출합니다.
  결과가 오류거나 예외가 나면 뒤에 힌트("Analyze the error above and try a different approach.", L167)를 붙여
  반환합니다. **왜?** 도구 실패도 대화의 일부로 LLM에 전달해 스스로 재시도하게 하는 설계입니다.
- `_suggest_name`(L43-54): 영숫자만 남겨 정규화한 이름이 유일하게 일치하면 "혹시 이거?"를 제안합니다(오타 대응).

---

## 자동 발견과 플러그인: `loader.py`

`nanobot/agent/tools/loader.py`의 `ToolLoader`(L20-118)가 도구를 찾아 등록합니다.

- **`discover()`**(L30-60): `pkgutil.iter_modules(...)`로 `tools/` 패키지의 모든 모듈을 순회(L37)하며,
  `_SKIP_MODULES`(L14-17: base/schema/registry/context/loader/config/sandbox/mcp 등 인프라 모듈)는 건너뜁니다.
  각 모듈에서 `Tool`의 구체(추상 아님) 하위 클래스만 골라(L47-55) 모읍니다.
  **왜 pkgutil[(용어사전)](../dict/09_dev_stack.md#pkgutil) 스캔인가(설계 의도):** 새 도구 파일을 추가하기만 하면 자동 등록됩니다. 중앙 목록을
  수동으로 갱신할 필요가 없어 확장이 쉽습니다(자기 등록 패턴).
- **`_discover_plugins()`**(L62-84): `entry_points(group="nanobot.tools")`(L68)로 **외부 패키지가 제공하는
  도구**를 발견합니다. 즉 서드파티가 자기 패키지에 `nanobot.tools` 엔트리포인트를 선언하면 nanobot이 그 도구를 로드합니다.
- **`load(ctx, registry, scope)`**(L86-118): 내장 도구와 플러그인 도구를 순회하며
  (1) `scope`가 도구의 `_scopes`에 없으면 skip(L94), (2) `enabled(ctx)`가 False면 skip(L96),
  (3) `create(ctx)`로 인스턴스화, (4) 이름 충돌 시 경고(플러그인이 내장을 덮어쓰지 못하게 함, L102-107) 후 등록.
- **`_LegacyErrorPrefixTool`**(L121-182): 옛 규약(오류를 `"Error:"` 접두 문자열로 반환)을 쓰는 외부 도구를
  감싸 `ToolResult.error(...)`로 변환하는 호환 래퍼입니다.

---

## 대표 도구들 개요

`tools/` 디렉토리의 실제 파일(확인됨)과 역할:

| 파일 | 역할 |
| --- | --- |
| `filesystem.py` | `read_file`, `write_file`, `edit_file`, `list_dir` 등 파일 조작(`_FsTool` 공통 기반). |
| `shell.py` | 셸 명령 실행(샌드박스 백엔드 연동; [12](12_security_and_sandbox.md)). |
| `apply_patch.py` | 통합 패치(diff) 적용. |
| `web.py` | 웹 페이지 가져오기/본문 추출. |
| `search.py` | 웹 검색(ddgs[(용어사전)](../dict/09_dev_stack.md#ddgs) 기반). |
| `mcp.py` | MCP 서버의 도구를 `mcp_*` 이름으로 노출([tech_background/04](tech_background/04_mcp.md)). |
| `spawn.py` | 서브에이전트 생성/위임(Subagent[(용어사전)](../dict/01_core_architecture.md#subagent)). |
| `image_generation.py` | 이미지 생성. |
| `cron.py` | 예약 작업 등록/관리([11](11_cron_and_triggers.md)). |
| `self.py` | 자기 수정(self-modification) 관련 기능. |
| `sandbox.py` | 샌드박스 실행(인프라 모듈 — `_SKIP_MODULES`에 포함되어 자동 발견 대상 아님). |
| `exec_session.py` | 지속적 실행 세션(상태 유지 셸). |
| `long_task.py` | 지속 목표(sustained goal) 도구: `LongTaskTool`(L111)이 세션 메타데이터에 목표를 등록하고, `CompleteGoalTool`(L193)이 종료를 기록. docstring(L1-15)에 따르면 활성 목표는 매 턴 Runtime Context에 미러링되어(`goal_state_runtime_lines`) **압축(compaction)이 목표를 가리지 못하게** 합니다. 별도 서브에이전트 오케스트레이터는 없음("There is **no** sub-agent orchestrator"). [06](06_state_and_persistence.md)의 `goal_state.py`와 짝. |
| `message.py` | 진행 중 사용자에게 메시지 전송(`MessageTool`; [04](04_agent_loop.md) L1524에서 사용). |
| `cli_apps.py` | CLI 앱 연동. |

그 외 나머지 파일은 도구 자체가 아니라 도구들이 공유하는 **인프라 모듈**입니다(각 파일 docstring 근거):

| 파일 | 역할 |
| --- | --- |
| `context.py` | "Runtime context for tool construction"(L1) — 도구 생성 시 넘겨줄 실행 컨텍스트. `_SKIP_MODULES` 대상. |
| `file_state.py` | "Track file-read state for read-before-edit warnings and read deduplication"(L1) — `read_file`의 중복 읽기 감지와 "읽기 전 편집" 경고에 사용. `_SKIP_MODULES` 대상. |
| `path_utils.py` | "Shared path helpers for workspace-scoped tools"(L1) — 워크스페이스 경계 검사와 연동([12](12_security_and_sandbox.md)). |
| `runtime_state.py` | "RuntimeState protocol: agent loop state exposed to MyTool"(L1) — 에이전트 루프 상태를 `self.py`의 MyTool[(용어사전)](../dict/02_tools_and_skills.md#mytool)에 노출하는 Protocol. `_SKIP_MODULES` 대상. |

> `sandbox.py`, `mcp.py`는 `_SKIP_MODULES`(loader.py L14-17)에 있어 자동 발견에서 제외됩니다. 이들은 다른
> 도구가 사용하는 **인프라**이거나 별도 경로로 등록됩니다.

---

## 실전 예제로 차근차근 따라가기 — 도구 호출 한 건의 일생

[04](04_agent_loop.md)의 예제에서 LLM이 `read_file(path="메모.txt")`를 요청했을 때,
그 요청 한 건이 도구 계층 안에서 어떻게 처리되는지 따라가 봅니다.

**1단계 — 카탈로그는 언제 만들어졌나.** 게이트웨이가 켜질 때 `ToolLoader.discover()`가
`tools/` 폴더의 모듈을 전부 스캔해 `Tool` 하위 클래스를 찾아냈고, `load(...)`가 스코프와
`enabled` 검사를 통과한 도구들을 `ToolRegistry`에 등록해 두었습니다. 대화가 시작되면
`registry.get_definitions()`가 각 도구의 `to_schema()` 결과(이름·설명·파라미터 스키마)를
정렬된 목록으로 만들어 LLM에게 전달합니다. 즉 LLM은 이미 "read_file이라는 도구가 있고,
path라는 문자열 인자를 받는다"는 것을 알고 있는 상태입니다.

**2단계 — 주문서 접수와 검사.** LLM의 응답에 도구 호출이 들어 있으면 runner가
`registry.execute("read_file", {"path": "메모.txt"})`를 부릅니다. `prepare_call`이
차례로 검사합니다:
- 이름 확인 — `_tools` 사전에 "read_file"이 있나? (오타라면 `_suggest_name`이
  "혹시 read_file?"을 제안하는 오류를 돌려줍니다.)
- 타입 교정 — LLM이 `"limit": "50"`처럼 숫자를 문자열로 보냈어도 `cast_params`가
  정수 50으로 바꿔 줍니다.
- 스키마 검증 — 필수 인자가 빠졌거나 타입이 안 맞으면, 실행하지 않고 무엇이 잘못됐는지
  적은 `ToolResult.error(...)`를 돌려줍니다.

**3단계 — 실행과 결과.** 검사를 통과하면 `tool.execute(path="메모.txt")`가 실행됩니다.
`ReadFileTool`은 경로를 워크스페이스 규칙에 맞게 해석하고(밖으로 나가려는 경로는
[12](12_security_and_sandbox.md)의 정책이 차단), 파일을 읽어 `줄번호|내용` 형식의 문자열을
돌려줍니다. 이 문자열이 `{"role": "tool", "tool_call_id": ...}` 메시지가 되어 대화에
붙고, 다음 LLM 호출에서 "읽은 내용"으로 보이게 됩니다.

**실패해도 대화는 계속됩니다.** 파일이 없으면 `ToolResult.error("File not found: ...")`에
"Analyze the error above and try a different approach."라는 힌트가 붙어 LLM에게
전달됩니다. LLM은 이 오류를 읽고 "아, 파일 이름이 다른가 보다. list_dir로 확인해 보자"처럼
스스로 경로를 수정합니다 — 오류조차 대화의 일부로 취급하는 것이 이 설계의 핵심입니다.

---

## 라인바이라인: `read_file`(`ReadFileTool`)

`nanobot/agent/tools/filesystem.py` L246-. 가장 자주 쓰이는 읽기 도구를 통해 도구 한 개의 실제 모습을 봅니다.

- **L246-248** — `ReadFileTool(_FsTool)`. `_scopes = {"core", "subagent", "memory"}`: 메인 에이전트뿐 아니라
  서브에이전트와 Dream/메모리 실행에서도 읽기가 허용됩니다.
- **L250-252** — 상수: `_MAX_CHARS = 128_000`(과도한 출력 방지), `_DEFAULT_LIMIT = 2000`(기본 줄 수), `_MAX_PDF_PAGES = 20`.
- **L254-256** — `name`은 `"read_file"`.
- **L258-271** — `description`. LLM에게 출력 형식(`LINE_NUM|CONTENT`), 이미지/문서 지원, `offset`/`limit` 사용법,
  128K 초과 시 잘림을 알려줍니다. **왜 이렇게 자세한가:** 설명이 곧 LLM의 사용 설명서이기 때문입니다.
- **L273-275** — `read_only = True`: 부작용이 없어 다른 읽기 도구와 병렬 실행이 안전.
- **L277-285** — `execute(path, offset=1, limit=None, pages=None, force=False, **kwargs)`.
- **L287-288** — 경로가 없으면 오류.
- **L290-298** — 장치 경로(`/dev/*` 등) 차단(`_is_blocked_device`): 무한 출력/행(hang) 방지. **보안 고려**([12](12_security_and_sandbox.md)).
- **L294-302** — `self._resolve_read(path)`로 워크스페이스 규칙에 맞게 경로를 해석하고, 존재/파일 여부를 확인.
  없으면 내장 스킬 경로(`_builtin_skill_read_path`)도 시도(L296).
- **L304-310** — 확장자에 따라 PDF/오피스 문서 전용 리더로 분기.
- **L312-318** — 바이트를 읽고, 이미지면 `build_image_content_blocks(...)`로 시각 콘텐츠 블록을 반환(멀티모달).
- **L320-354** — **읽기 중복 제거(dedup)**: 같은 경로+offset+limit을 다시 읽을 때 파일이 안 바뀌었으면
  `[File unchanged since last read: ...]`만 돌려줍니다(L344). 단 `force=true`거나 mtime/해시가 바뀌면 전체를 다시 읽습니다.
  **왜?** LLM이 같은 파일을 반복해서 읽어 컨텍스트를 낭비하는 것을 막는 최적화입니다.
- **L357-365** — UTF-8 디코드, 실패 시 이미지 재확인 또는 "바이너리 파일" 오류.

이 한 도구만 봐도 도구 설계의 원칙이 보입니다: **명확한 설명, 안전한 경로 해석, 보안 차단, 결과 최적화,
그리고 실패 시 LLM이 이해할 오류 메시지**.

---

다음 문서에서는 도구/턴이 남기는 상태가 어떻게 파일로 저장되는지 봅니다 → [06_state_and_persistence.md](06_state_and_persistence.md).
