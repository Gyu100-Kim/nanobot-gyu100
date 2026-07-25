# nanobot 용어·개념 사전 (Glossary & Concept Dictionary)

이 디렉토리는 `nanobot-gyu100` 저장소를 이해하기 위한 **용어·개념 사전**이자, 그 용어들이
서로 어떻게 연결되는지를 담은 **지식 그래프**입니다. 설명 속 용어를 클릭하면 해당 항목으로
이동하고, 브라우저/에디터의 "뒤로 가기"로 원래 위치로 돌아올 수 있습니다.

**규모:** 용어 246개 · 노드 클래스 9종 · 관계 886개 (그래프 데이터는 [graph/](graph/)에서
Neo4j/Memgraph로 바로 임포트 가능)

## 목차

1. [빠른 시작 — 어떻게 읽을까](#빠른-시작--어떻게-읽을까)
2. [설계 이념 (지식 그래프 모델)](#설계-이념-지식-그래프-모델)
   - [한눈에 보는 모델](#한눈에-보는-모델)
   - [상위/하위 방향 규약 — 기반과 파생](#1-상위하위-방향-규약--기반과-파생)
   - [계층 판정 절차](#2-계층-판정-절차--specializes--related_to--mentions)
   - [노드 정의](#3-노드-정의-노드-명--label)
   - [관계(엣지) 종류](#4-관계엣지-종류)
   - [최초 등장 시기](#5-최초-등장-시기-등장-필드--first_appearance)
   - [설계 이념의 변천사 (시행착오 기록)](#6-설계-이념의-변천사-시행착오-기록)
3. [항목 형식](#항목-형식)
4. [주제별 파일](#주제별-파일)
5. [그래프 데이터](#그래프-데이터)
6. [사전 확장·유지보수 규칙](#사전-확장유지보수-규칙)
7. [전체 색인](#전체-색인-알파벳순-246개)

## 빠른 시작 — 어떻게 읽을까

목적에 따라 다음 경로를 추천합니다.

| 알고 싶은 것 | 시작점 |
|---|---|
| nanobot이 전체적으로 어떻게 동작하나 | [01_core_architecture.md](01_core_architecture.md)의 [Agent](01_core_architecture.md#agent) → [AgentLoop](01_core_architecture.md#agentloop) → [MessageBus](01_core_architecture.md#messagebus) 순서 |
| LLM/AI 기초 개념 | [08_ai_llm_concepts.md](08_ai_llm_concepts.md)의 [LLM](08_ai_llm_concepts.md#llm) → [Attention](08_ai_llm_concepts.md#attention) → [Transformer](08_ai_llm_concepts.md#transformer) 사슬 |
| "이 용어가 뭐지?" 하나만 찾기 | 맨 아래 [전체 색인](#전체-색인-알파벳순-246개)에서 Ctrl+F |
| 그래프 DB로 탐색하기 | [graph/README.md](graph/README.md)의 임포트 절차와 예시 쿼리 |
| 함께 보는 학습자료 | 저장소의 `STUDY_NOTES/` — 이 사전이 "무엇(정의)"이라면 STUDY_NOTES는 "어떻게(코드 흐름)" |

읽는 요령: 항목의 **하위 개념(기반·전제)** 링크를 따라 내려가면 그 개념을 이해하는 데 필요한
바탕이 나오고, **상위 개념(이를 기반으로 파생)** 링크를 따라 올라가면 그 개념을 활용한 더
특수한 것들이 나옵니다.

## 설계 이념 (지식 그래프 모델)

### 한눈에 보는 모델

```text
                  ┌────────────────┐  BELONGS_TO   ┌──────────────────┐
                  │   (:Content)   │──────────────▶│ (:ContentClass)  │
                  │  용어·개념 노드 │   "~에 속한다"  │  역할 분류 노드 9종 │
                  └────────────────┘               └──────────────────┘
                    │      │     │
        SPECIALIZES │      │     │ MENTIONS
      "~를 기반으로  │      │     │ "본문에서 언급"
        파생됨(상위)" ▼      │     ▼
                (:Content) │  (:Content)
                           │ RELATED_TO
                           ▼ "계층 없는 관련"
                       (:Content)
```

- 노드는 **Content**(용어·개념)와 **ContentClass**(역할 분류) 두 종류.
- 계층은 `SPECIALIZES` 하나로 표현하며, 방향은 항상 **파생(특수) → 기반(일반)** 입니다.

### 1. 상위/하위 방향 규약 — 기반과 파생

각 용어(개념)는 다른 용어와 상위 또는 하위 엣지로 직접 연결됩니다.

> **하위 개념 = 이 개념을 규정하기 위해 필요한 기반·전제 개념(더 일반적).**
> **상위 개념 = 이 개념을 기반으로 활용해 만들어진 파생 개념(더 특수적).**
> 하위로 갈수록 일반화되고, 상위로 갈수록 특수화됩니다.

대표 예시 — Attention 계열:

```text
(가장 특수 = 상위)
      BERT            ← Transformer의 Encoder를 활용해 만든 모델 (2018)
       │
       ▼
   Transformer        ← Attention을 활용해 만든 구조, "Attention Is All You Need" (2017)
       │
       ▼
    Attention         ← 먼저 등장한 기반 개념 (2014)
(가장 일반 = 하위)
```

같은 원리의 다른 사슬들:

```text
System Prompt → Prompt              (프롬프트라는 기반 개념의 특수한 형태)
LoRA → PEFT → Fine-tuning           (방법론이 기반 방법론을 활용해 파생)
BERT → Transformer → Attention      (모델이 구조를, 구조가 메커니즘을 활용)
asyncio → Event Loop / Coroutine    (프레임워크가 오래된 일반 개념을 활용)
Atomic Write → fsync                (기법이 시스템 콜 기반 위에 성립)
```

- 각 항목의 `**상위 개념(이를 기반으로 파생):**` = 이 개념을 활용해 만들어진 것들(파생 모델·구현·세부 기법).
- 각 항목의 `**하위 개념(기반·전제):**` = 이 개념을 이해·규정하는 데 필요한 기반들.
- 한 용어는 여러 용어와 동시에 연결될 수 있습니다(엣지 여러 개 허용).
- 그래프 데이터에서는 이 관계를 `(특수/파생)-[:SPECIALIZES]->(일반/기반)` 한 방향으로만 저장합니다.

### 2. 계층 판정 절차 — SPECIALIZES / RELATED_TO / MENTIONS

두 용어 A, B의 관계를 정할 때는 다음 질문 순서로 판단합니다.

1. **"B는 A를 기반·전제로 활용해 만들어졌는가?"** (예: "Transformer를 활용한 예시는
   BERT가 있습니다. BERT는 Transformer의 Encoder를 활용해 만든 모델입니다.")
   → 그렇다면 `B -[:SPECIALIZES]-> A` (B가 상위/파생, A가 하위/기반).
2. **"A를 규정·이해하는 데 B가 반드시 필요한가?"** (예: Transformer의 정의에 Attention이
   필수) → 그렇다면 `A -[:SPECIALIZES]-> B` (A가 상위/파생, B가 하위/기반).
3. 계층은 아니지만 **개념적으로 밀접**한가? (예: Sandbox ↔ Timeout)
   → `RELATED_TO`.
4. 그저 **설명 본문에 링크로 등장**할 뿐인가? → `MENTIONS`만 남기고 계층으로 승격하지
   않습니다.

핵심: 계층은 **링크 등장 여부가 아니라 의미 분석**으로 결정합니다. "설명에 예시로 등장했다"는
사실만으로 상위가 되지 않으며, "A를 활용해 만든 것이 B"라는 파생 관계가 확인될 때만 B가
상위가 됩니다.

### 3. 노드 정의 (노드 명 / label)

노드는 역할에 따라 두 종류로 나뉩니다.

| 노드 명 | 역할 |
|---|---|
| **Content** | 사전을 구성하는 용어·개념 노드 (`01`~`09` 파일의 모든 항목, 246개) |
| **Content Class** | Content의 정체(역할) 분류를 규정하는 노드 ([00_content_classes.md](00_content_classes.md), 9개) |

모든 Content 노드는 **최소 1개의 Content Class**와 `BELONGS_TO` 엣지로 연결됩니다 —
상위/하위가 아닌 "이 클래스에 속한다"는 별도의 엣지입니다. 각 항목의 `**클래스:**` 필드가 이
연결입니다.

클래스 9종과 현재 분포:

| 클래스 | 의미 | 개수 |
|---|---|---|
| [Component](00_content_classes.md#component) | 이 저장소의 구체적 코드 구성요소 | 76 |
| [Concept](00_content_classes.md#concept) | 구현과 독립적으로 성립하는 일반 개념 | 56 |
| [Technology](00_content_classes.md#technology) | 외부 라이브러리·도구·플랫폼 | 36 |
| [Mechanism](00_content_classes.md#mechanism) | 동작 방식·처리 절차 | 25 |
| [Principle](00_content_classes.md#principle) | 설계 원칙·패턴 | 17 |
| [Protocol](00_content_classes.md#protocol) | 통신 규약·표준 | 13 |
| [Artifact](00_content_classes.md#artifact) | 파일·데이터 형식 등 산출물 | 13 |
| [Research](00_content_classes.md#research) | 논문·연구 성과 | 5 |
| [Threat](00_content_classes.md#threat) | 보안 위협 | 5 |

정의 전문은 [00_content_classes.md](00_content_classes.md)를 보세요.

### 4. 관계(엣지) 종류

| 엣지 | 의미 | 방향 | 개수 |
|---|---|---|---|
| `SPECIALIZES` | 출발 노드가 도착 노드를 기반으로 만들어진 파생(상위) 개념 | Content(특수/파생) → Content(일반/기반) | 222 |
| `BELONGS_TO` | 이 클래스에 속함 | Content → Content Class | 246 |
| `RELATED_TO` | 계층은 아니지만 밀접히 관련 | Content ↔ Content (무방향적) | 146 |
| `MENTIONS` | 설명 본문에서 언급 | Content → Content | 272 |

### 5. 최초 등장 시기 (`등장:` 필드 / `first_appearance`)

각 Content 항목은 가능한 경우 메타 줄에 `**등장:** YYYY(-MM)` 형식으로 개념이 처음 등장한
시기를 기록합니다(그래프 노드 속성 `first_appearance`, 현재 49개 항목). 연도만 확실하면
연도만, 불확실하면 "년경"으로 표기하고, 확인할 수 없으면 생략합니다.

주의: 등장 시기는 상·하위 판단의 **참고 정보**일 뿐 절대 기준이 아닙니다. 파생 개념은 보통
기반 개념보다 늦게 등장하지만, **항상 그렇지는 않습니다** — 상위(파생) 용어가 하위(기반)
용어보다 먼저 생긴 경우도 있습니다. 계층은 어디까지나 "어느 개념이 어느 개념을 기반·전제로
규정되는가"라는 의미 분석으로 결정합니다.

### 6. 설계 이념의 변천사 (시행착오 기록)

이 사전의 그래프 모델은 세 차례에 걸쳐 다듬어졌습니다. 같은 실수를 반복하지 않기 위해
기록으로 남깁니다.

**v1 — 최초 구축.** 용어 209개, `HAS_SUBCONCEPT`(상위→하위) 엣지. "상위 = 더 큰 주제,
하위 = 그 아래 세부"라는 통상적 분류 트리 관점이었습니다.

**v2 — 방향 반전과 노드 클래스 도입.** "하위로 갈수록 일반적, 상위로 갈수록 특수"라는
규약을 도입해 방향을 뒤집고(`SPECIALIZES`), Content/ContentClass 노드 모델과 `BELONGS_TO`
엣지를 추가했습니다(244개). 그러나 이때 "설명에 드는 구체적 예시가 곧 상위 개념"이라는
지침을 **단순 링크 등장 여부**로 기계적으로 적용하는 오류가 있었습니다 — 예컨대 Transformer
설명에 Self-Attention이 등장한다는 이유로 Self-Attention을 Transformer의 상위로 둔 것이
대표적 오류입니다.

**v3 — 기반/파생 의미 분석 (현행).** Attention은 Transformer보다 먼저 나온 기반 개념이고,
Transformer는 Attention을 **활용해 만든** 파생 개념이므로 Transformer가 상위입니다
(논문 제목부터 "Attention Is All You Need"). "A를 활용한 예시가 B"(BERT는 Transformer의
Encoder를 활용해 만든 모델)일 때만 B가 A의 상위가 되며, 단순 언급은 `MENTIONS`로만
남깁니다. 이때 전 용어의 계층을 재검토하고 `first_appearance` 속성을 도입했습니다(246개).

## 항목 형식

```markdown
### 용어명
**클래스:** [Component](00_content_classes.md#component) · **한글:** 한글명 · **등장:** YYYY(-MM) · **코드:** `소스 경로`

쉬운 정의와 이 코드베이스에서의 구체적 의미.

**예시:** 구체적인 사용 예 ("이 개념을 활용해 만든" 파생 예시면 상위 개념으로도 연결).

- **상위 개념(이를 기반으로 파생):** [...]
- **하위 개념(기반·전제):** [...]
- **관련 용어:** [...]
```

메타 줄의 필드는 해당하는 것만 적습니다 — `클래스`(필수), `한글`, `등장`, `코드`(저장소
구성요소인 경우), `PyPI`(파이썬 패키지인 경우).

## 주제별 파일

| 파일 | 주제 | 항목 수 | 대표 항목 |
|---|---|---|---|
| [00_content_classes.md](00_content_classes.md) | 노드 클래스 정의 | 9 | Component, Concept, Principle, Threat … |
| [01_core_architecture.md](01_core_architecture.md) | 코어 아키텍처·설계 패턴 | 34 | AgentLoop, MessageBus, Adapter Pattern |
| [02_tools_and_skills.md](02_tools_and_skills.md) | 도구와 스킬 | 32 | ToolRegistry, ExecTool, SKILL.md |
| [03_memory_context_session.md](03_memory_context_session.md) | 메모리·컨텍스트·세션 | 29 | Context, Dream, AutoCompact, JSONL |
| [04_providers_and_llm.md](04_providers_and_llm.md) | 프로바이더와 LLM 호출 | 27 | FallbackProvider, Circuit Breaker |
| [05_channels_gateway_ui.md](05_channels_gateway_ui.md) | 채널·게이트웨이·UI | 15 | WebSocket, WebUI, OpenAI-Compatible API |
| [06_scheduling_automation.md](06_scheduling_automation.md) | 스케줄링과 자동화 | 13 | Cron, Heartbeat, Trigger |
| [07_security_isolation.md](07_security_isolation.md) | 보안과 격리 | 18 | Sandbox, SSRF, Least Privilege |
| [08_ai_llm_concepts.md](08_ai_llm_concepts.md) | AI/LLM 일반 개념 | 44 | LLM, Attention, Transformer, BERT, MCP |
| [09_dev_stack.md](09_dev_stack.md) | 개발 스택 | 34 | asyncio, Pydantic, bun, Vite |

## 그래프 데이터

용어 간 계층·연결 관계는 [graph/](graph/) 디렉토리에 그래프 DB(Neo4j / Memgraph)로 바로 임포트
가능한 형식(`nodes.csv`, `edges.csv`, `import.cypher`)으로 저장되어 있습니다.
자세한 데이터 모델·임포트 절차·예시 쿼리는 [graph/README.md](graph/README.md)를 보세요.

## 사전 확장·유지보수 규칙

새 용어를 추가하거나 기존 항목을 고칠 때의 규칙입니다. 이 규칙들과 설계 사상·시행착오를
재사용 가능한 절차로 정리한 스킬이 [skill/SKILL.md](skill/SKILL.md)에 있습니다.

1. **재귀 확장** — 설명 중 등장하는 용어가 사전에 없으면 새 항목으로 추가합니다. 설명 안의
   모든 전문 용어는 클릭 가능한 링크여야 합니다.
2. **클래스 필수** — 모든 항목은 최소 1개의 클래스([00_content_classes.md](00_content_classes.md))에
   연결합니다.
3. **계층은 의미 분석으로** — [계층 판정 절차](#2-계층-판정-절차--specializes--related_to--mentions)를
   따릅니다. 링크로 등장한다는 이유만으로 상·하위를 만들지 않습니다.
4. **등장 시기** — 확인 가능한 경우 `등장:` 필드를 기록하되, 계층 판단의 참고로만 씁니다.
5. **양방향 표기** — A의 상위에 B를 적으면 B의 하위에 A를 적어 양쪽에서 오갈 수 있게 합니다.
6. **그래프 재생성** — 마크다운 수정 후 [graph/README.md](graph/README.md)의 재생성 규칙대로
   `nodes.csv` / `edges.csv` / `import.cypher`를 다시 추출하고, 개수·불변 조건(클래스 연결,
   엣지 방향)을 검증합니다.

## 전체 색인 (알파벳순, 246개)

[_SKIP_MODULES](02_tools_and_skills.md#_skip_modules) ·
[Adapter Pattern](01_core_architecture.md#adapter-pattern) ·
[Agent](01_core_architecture.md#agent) ·
[Agent Loop (concept)](08_ai_llm_concepts.md#agent-loop-concept) ·
[Agent Skills](08_ai_llm_concepts.md#agent-skills) ·
[AgentLoop](01_core_architecture.md#agentloop) ·
[AgentRunner](01_core_architecture.md#agentrunner) ·
[Anthropic Provider](04_providers_and_llm.md#anthropic-provider) ·
[API Server](05_channels_gateway_ui.md#api-server) ·
[Append-only Log](03_memory_context_session.md#append-only-log) ·
[apply_patch](02_tools_and_skills.md#apply_patch) ·
[Apps](05_channels_gateway_ui.md#apps) ·
[asyncio](09_dev_stack.md#asyncio) ·
[asyncio.Queue](09_dev_stack.md#asyncioqueue) ·
[Atomic Write](03_memory_context_session.md#atomic-write) ·
[Attention](08_ai_llm_concepts.md#attention) ·
[AutoCompact](03_memory_context_session.md#autocompact) ·
[Automation Turns](06_scheduling_automation.md#automation-turns) ·
[Azure OpenAI Provider](04_providers_and_llm.md#azure-openai-provider) ·
[Bedrock Provider](04_providers_and_llm.md#bedrock-provider) ·
[BERT](08_ai_llm_concepts.md#bert) ·
[Bootstrap Templates](03_memory_context_session.md#bootstrap-templates) ·
[Bound Runner](06_scheduling_automation.md#bound-runner) ·
[BPE](08_ai_llm_concepts.md#bpe) ·
[bubblewrap](07_security_isolation.md#bubblewrap) ·
[bun](09_dev_stack.md#bun) ·
[camelCase Alias](09_dev_stack.md#camelcase-alias) ·
[Chain-of-Thought](08_ai_llm_concepts.md#chain-of-thought) ·
[Channel](01_core_architecture.md#channel) ·
[Channel Manager](05_channels_gateway_ui.md#channel-manager) ·
[Channel Registry](05_channels_gateway_ui.md#channel-registry) ·
[Circuit Breaker](04_providers_and_llm.md#circuit-breaker) ·
[Command Router](01_core_architecture.md#command-router) ·
[Config](01_core_architecture.md#config) ·
[Consolidation](03_memory_context_session.md#consolidation) ·
[Container](07_security_isolation.md#container) ·
[Context](03_memory_context_session.md#context) ·
[Context Compression](08_ai_llm_concepts.md#context-compression) ·
[Context Governance](03_memory_context_session.md#context-governance) ·
[Context Window](08_ai_llm_concepts.md#context-window) ·
[ContextVar](09_dev_stack.md#contextvar) ·
[Coroutine](09_dev_stack.md#coroutine) ·
[Cron](06_scheduling_automation.md#cron) ·
[Cron Expression](06_scheduling_automation.md#cron-expression) ·
[Cron Job](06_scheduling_automation.md#cron-job) ·
[Cron Store](06_scheduling_automation.md#cron-store) ·
[Cron Tool](02_tools_and_skills.md#cron-tool) ·
[Cron Turns](06_scheduling_automation.md#cron-turns) ·
[croniter](06_scheduling_automation.md#croniter) ·
[CronService](06_scheduling_automation.md#cronservice) ·
[Cursor](03_memory_context_session.md#cursor) ·
[ddgs](09_dev_stack.md#ddgs) ·
[Decoupling](01_core_architecture.md#decoupling) ·
[Defense in Depth](07_security_isolation.md#defense-in-depth) ·
[Delta](04_providers_and_llm.md#delta) ·
[DNS Pinning](07_security_isolation.md#dns-pinning) ·
[DNS Rebinding](07_security_isolation.md#dns-rebinding) ·
[Dream](03_memory_context_session.md#dream) ·
[Dream Cursor](03_memory_context_session.md#dream-cursor) ·
[dulwich](09_dev_stack.md#dulwich) ·
[Durable Files](03_memory_context_session.md#durable-files) ·
[Embedding](08_ai_llm_concepts.md#embedding) ·
[Entry Points](09_dev_stack.md#entry-points) ·
[Entry-point Plugin](02_tools_and_skills.md#entry-point-plugin) ·
[Event Loop](09_dev_stack.md#event-loop) ·
[Exact Pinning](09_dev_stack.md#exact-pinning) ·
[Exec Session](02_tools_and_skills.md#exec-session) ·
[ExecTool](02_tools_and_skills.md#exectool) ·
[Exponential Backoff](04_providers_and_llm.md#exponential-backoff) ·
[Facade Pattern](01_core_architecture.md#facade-pattern) ·
[FallbackProvider](04_providers_and_llm.md#fallbackprovider) ·
[Few-shot Learning](08_ai_llm_concepts.md#few-shot-learning) ·
[File State](02_tools_and_skills.md#file-state) ·
[filelock](09_dev_stack.md#filelock) ·
[Filesystem Tools](02_tools_and_skills.md#filesystem-tools) ·
[Fine-tuning](08_ai_llm_concepts.md#fine-tuning) ·
[Frontmatter](02_tools_and_skills.md#frontmatter) ·
[fsync](03_memory_context_session.md#fsync) ·
[Gateway](01_core_architecture.md#gateway) ·
[Gateway Service](05_channels_gateway_ui.md#gateway-service) ·
[Git](09_dev_stack.md#git) ·
[GitHub Copilot Provider](04_providers_and_llm.md#github-copilot-provider) ·
[Goal State](03_memory_context_session.md#goal-state) ·
[Graceful Degradation](04_providers_and_llm.md#graceful-degradation) ·
[Grounding](08_ai_llm_concepts.md#grounding) ·
[Hallucination](08_ai_llm_concepts.md#hallucination) ·
[hatchling](09_dev_stack.md#hatchling) ·
[Health Endpoint](05_channels_gateway_ui.md#health-endpoint) ·
[Heartbeat](06_scheduling_automation.md#heartbeat) ·
[HEARTBEAT.md](06_scheduling_automation.md#heartbeatmd) ·
[Hierarchical Memory](08_ai_llm_concepts.md#hierarchical-memory) ·
[History Visibility](03_memory_context_session.md#history-visibility) ·
[history.jsonl](03_memory_context_session.md#historyjsonl) ·
[Hook](01_core_architecture.md#hook) ·
[HTTP](05_channels_gateway_ui.md#http) ·
[httpx](09_dev_stack.md#httpx) ·
[Image Generation Provider](04_providers_and_llm.md#image-generation-provider) ·
[Image Generation Tool](02_tools_and_skills.md#image-generation-tool) ·
[In-Context Learning](08_ai_llm_concepts.md#in-context-learning) ·
[InboundMessage](01_core_architecture.md#inboundmessage) ·
[Injection](01_core_architecture.md#injection) ·
[Input Budget](03_memory_context_session.md#input-budget) ·
[Jinja2](09_dev_stack.md#jinja2) ·
[JSON Schema](08_ai_llm_concepts.md#json-schema) ·
[JSON-RPC](08_ai_llm_concepts.md#json-rpc) ·
[JSONL](03_memory_context_session.md#jsonl) ·
[last_consolidated Cursor](03_memory_context_session.md#last_consolidated-cursor) ·
[Least Privilege](07_security_isolation.md#least-privilege) ·
[Linux Namespaces](07_security_isolation.md#linux-namespaces) ·
[LLM](08_ai_llm_concepts.md#llm) ·
[loguru](09_dev_stack.md#loguru) ·
[Long Task Tool](02_tools_and_skills.md#long-task-tool) ·
[LoRA](08_ai_llm_concepts.md#lora) ·
[Lost in the Middle](08_ai_llm_concepts.md#lost-in-the-middle) ·
[LSP](08_ai_llm_concepts.md#lsp) ·
[Markdown](02_tools_and_skills.md#markdown) ·
[max_tokens](04_providers_and_llm.md#max_tokens) ·
[MCP](08_ai_llm_concepts.md#mcp) ·
[MCPToolWrapper](02_tools_and_skills.md#mcptoolwrapper) ·
[Memory](03_memory_context_session.md#memory) ·
[MEMORY.md](03_memory_context_session.md#memorymd) ·
[MessageBus](01_core_architecture.md#messagebus) ·
[MessageTool](02_tools_and_skills.md#messagetool) ·
[Model Preset](01_core_architecture.md#model-preset) ·
[Model Routing](08_ai_llm_concepts.md#model-routing) ·
[MyTool](02_tools_and_skills.md#mytool) ·
[Nanobot (SDK Facade)](01_core_architecture.md#nanobot-sdk-facade) ·
[OpenAI Codex Provider](04_providers_and_llm.md#openai-codex-provider) ·
[OpenAI Responses Provider](04_providers_and_llm.md#openai-responses-provider) ·
[OpenAI-Compatible API](05_channels_gateway_ui.md#openai-compatible-api) ·
[OpenAI-Compatible Provider](04_providers_and_llm.md#openai-compatible-provider) ·
[Optional Dependencies](09_dev_stack.md#optional-dependencies) ·
[Orphan Tool Result](03_memory_context_session.md#orphan-tool-result) ·
[OutboundMessage](01_core_architecture.md#outboundmessage) ·
[Pairing](01_core_architecture.md#pairing) ·
[Path Utils](02_tools_and_skills.md#path-utils) ·
[PEFT](08_ai_llm_concepts.md#peft) ·
[PinnedDNSAsyncTransport](07_security_isolation.md#pinneddnsasynctransport) ·
[pkgutil](09_dev_stack.md#pkgutil) ·
[Platform Channels](05_channels_gateway_ui.md#platform-channels) ·
[Plugin Architecture](02_tools_and_skills.md#plugin-architecture) ·
[Producer-Consumer](01_core_architecture.md#producer-consumer) ·
[Progress Hook](01_core_architecture.md#progress-hook) ·
[Progressive Disclosure](02_tools_and_skills.md#progressive-disclosure) ·
[Prompt](08_ai_llm_concepts.md#prompt) ·
[Prompt Caching](04_providers_and_llm.md#prompt-caching) ·
[Prompt Engineering](08_ai_llm_concepts.md#prompt-engineering) ·
[Prompt Injection](07_security_isolation.md#prompt-injection) ·
[prompt-toolkit](09_dev_stack.md#prompt-toolkit) ·
[Provider](01_core_architecture.md#provider) ·
[Provider Base](04_providers_and_llm.md#provider-base) ·
[Provider Factory](04_providers_and_llm.md#provider-factory) ·
[Provider Registry](04_providers_and_llm.md#provider-registry) ·
[ProviderSpec](04_providers_and_llm.md#providerspec) ·
[PTH File Guard](07_security_isolation.md#pth-file-guard) ·
[Pydantic](09_dev_stack.md#pydantic) ·
[pydantic-settings](09_dev_stack.md#pydantic-settings) ·
[PyPI](09_dev_stack.md#pypi) ·
[pytest](09_dev_stack.md#pytest) ·
[Python 3.11+](09_dev_stack.md#python-311) ·
[questionary](09_dev_stack.md#questionary) ·
[RAG](08_ai_llm_concepts.md#rag) ·
[Rate Limit](04_providers_and_llm.md#rate-limit) ·
[ReAct](08_ai_llm_concepts.md#react) ·
[React (JS)](09_dev_stack.md#react-js) ·
[Reasoning Blocks](04_providers_and_llm.md#reasoning-blocks) ·
[Reflection](08_ai_llm_concepts.md#reflection) ·
[Registry Pattern](02_tools_and_skills.md#registry-pattern) ·
[Retry](04_providers_and_llm.md#retry) ·
[Rich](09_dev_stack.md#rich) ·
[ruff](09_dev_stack.md#ruff) ·
[Runtime Checkpoint](01_core_architecture.md#runtime-checkpoint) ·
[Runtime Context](03_memory_context_session.md#runtime-context) ·
[Runtime State Protocol](02_tools_and_skills.md#runtime-state-protocol) ·
[Sampling](04_providers_and_llm.md#sampling) ·
[Sandbox](07_security_isolation.md#sandbox) ·
[Sandbox Backend](07_security_isolation.md#sandbox-backend) ·
[SDK Clients](05_channels_gateway_ui.md#sdk-clients) ·
[seccomp](07_security_isolation.md#seccomp) ·
[Self-Attention](08_ai_llm_concepts.md#self-attention) ·
[Session](01_core_architecture.md#session) ·
[Session Delivery](06_scheduling_automation.md#session-delivery) ·
[Session Key](01_core_architecture.md#session-key) ·
[Session Manager](03_memory_context_session.md#session-manager) ·
[Skill](01_core_architecture.md#skill) ·
[Skill Library](08_ai_llm_concepts.md#skill-library) ·
[skill-creator](02_tools_and_skills.md#skill-creator) ·
[SKILL.md](02_tools_and_skills.md#skillmd) ·
[SkillsLoader](02_tools_and_skills.md#skillsloader) ·
[Slash Command](01_core_architecture.md#slash-command) ·
[Sliding Window](08_ai_llm_concepts.md#sliding-window) ·
[SOUL.md](03_memory_context_session.md#soulmd) ·
[SPA](05_channels_gateway_ui.md#spa) ·
[SpawnTool](02_tools_and_skills.md#spawntool) ·
[SSE](08_ai_llm_concepts.md#sse) ·
[SSRF](07_security_isolation.md#ssrf) ·
[State Machine](01_core_architecture.md#state-machine) ·
[stdio Transport](08_ai_llm_concepts.md#stdio-transport) ·
[Streamable HTTP](08_ai_llm_concepts.md#streamable-http) ·
[Streaming](04_providers_and_llm.md#streaming) ·
[Subagent](01_core_architecture.md#subagent) ·
[Summarization](08_ai_llm_concepts.md#summarization) ·
[Sustained Goal](03_memory_context_session.md#sustained-goal) ·
[System Prompt](03_memory_context_session.md#system-prompt) ·
[Temperature](04_providers_and_llm.md#temperature) ·
[tiktoken](08_ai_llm_concepts.md#tiktoken) ·
[Timeout](07_security_isolation.md#timeout) ·
[TOCTOU](07_security_isolation.md#toctou) ·
[Token](08_ai_llm_concepts.md#token) ·
[Tokenizer](08_ai_llm_concepts.md#tokenizer) ·
[Tool](01_core_architecture.md#tool) ·
[Tool Calling](08_ai_llm_concepts.md#tool-calling) ·
[Tool Discovery](02_tools_and_skills.md#tool-discovery) ·
[Tool Hint](02_tools_and_skills.md#tool-hint) ·
[Tool Schema](02_tools_and_skills.md#tool-schema) ·
[Tool Scope](02_tools_and_skills.md#tool-scope) ·
[ToolRegistry](02_tools_and_skills.md#toolregistry) ·
[ToolResult](02_tools_and_skills.md#toolresult) ·
[Transcription](04_providers_and_llm.md#transcription) ·
[Transformer](08_ai_llm_concepts.md#transformer) ·
[Transient Error](04_providers_and_llm.md#transient-error) ·
[Trigger](06_scheduling_automation.md#trigger) ·
[TTL](03_memory_context_session.md#ttl) ·
[Turn](01_core_architecture.md#turn) ·
[Turn Continuation](01_core_architecture.md#turn-continuation) ·
[TurnState](01_core_architecture.md#turnstate) ·
[Type Hint](09_dev_stack.md#type-hint) ·
[Typer](09_dev_stack.md#typer) ·
[TypeScript](09_dev_stack.md#typescript) ·
[Unified Session](01_core_architecture.md#unified-session) ·
[USER.md](03_memory_context_session.md#usermd) ·
[Vector Database](08_ai_llm_concepts.md#vector-database) ·
[Vite](09_dev_stack.md#vite) ·
[Voyager](08_ai_llm_concepts.md#voyager) ·
[Web Tools](02_tools_and_skills.md#web-tools) ·
[WebSocket](05_channels_gateway_ui.md#websocket) ·
[WebSocket Channel](05_channels_gateway_ui.md#websocket-channel) ·
[WebSocket Multiplex Protocol](05_channels_gateway_ui.md#websocket-multiplex-protocol) ·
[websockets](09_dev_stack.md#websockets) ·
[WebUI](05_channels_gateway_ui.md#webui) ·
[WebUI Turn Coordinator](03_memory_context_session.md#webui-turn-coordinator) ·
[Workspace](01_core_architecture.md#workspace) ·
[Workspace Access](07_security_isolation.md#workspace-access) ·
[Workspace Policy](07_security_isolation.md#workspace-policy) ·
[WriteStdinTool](02_tools_and_skills.md#writestdintool) ·
[Zero-shot](08_ai_llm_concepts.md#zero-shot)
