---
name: glossary-knowledge-graph
description: 저장소의 용어·개념 사전(dict/)과 지식 그래프를 구축·확장·유지보수하는 스킬. 새 용어 추가, 계층(상위/하위) 판정, 그래프 데이터(nodes/edges/Cypher) 재생성·검증이 필요할 때 사용.
---

# Glossary Knowledge Graph Builder

저장소를 이해하기 위한 **용어·개념 사전 + 지식 그래프**를 만들고 유지하는 스킬입니다.
`dict/`를 구축하며 겪은 시행착오와 노하우, 그리고 최종 설계 사상을 절차로 정리한 것입니다.

## 최종 사상 (핵심 원칙)

### 1. 계층의 의미: 기반과 파생

> **하위 개념 = 그 개념을 규정하기 위해 필요한 기반·전제 개념 (더 일반적).**
> **상위 개념 = 그 개념을 기반으로 활용해 만들어진 파생 개념 (더 특수적).**

대표 사슬: `BERT → Transformer → Attention` (화살표 = SPECIALIZES, 파생 → 기반).
Attention(2014)이 먼저 나온 기반 개념이고, Transformer(2017)는 그것을 활용해 만든 파생
개념이며(논문 제목이 "Attention Is All You Need"), BERT(2018)는 Transformer의 Encoder를
활용해 만든 모델이므로 가장 상위입니다.

같은 원리: `System Prompt → Prompt`, `LoRA → PEFT → Fine-tuning`,
`asyncio → Event Loop / Coroutine`, `Atomic Write → fsync`.

### 2. 계층은 링크 등장 여부가 아니라 의미 분석으로 결정한다

두 용어 A, B의 관계 판정 절차:

1. "B는 A를 **활용해 만들어진** 것인가?" (예: "Transformer를 활용한 예시는 BERT")
   → `B -[:SPECIALIZES]-> A`.
2. "A를 **규정·이해하는 데 B가 반드시 필요**한가?" (예: Transformer 정의에 Attention 필수)
   → `A -[:SPECIALIZES]-> B`.
3. 계층은 아니지만 개념적으로 밀접한가? → `RELATED_TO`.
4. 그저 설명 본문에 등장할 뿐인가? → `MENTIONS`만. 계층으로 승격하지 않는다.

### 3. 노드 모델: Content + ContentClass

- `(:Content)` — 사전의 용어·개념 노드.
- `(:ContentClass)` — 역할 분류 노드 (Component / Artifact / Mechanism / Concept /
  Principle / Protocol / Threat / Research / Technology 등 소수로 유지).
- 모든 Content는 최소 1개 클래스와 `BELONGS_TO` 엣지로 연결 (계층 아님).

### 4. 최초 등장 시기는 참고 정보

각 항목에 `**등장:** YYYY(-MM)`을 기록하고 그래프 속성 `first_appearance`로 추출한다.
파생 개념은 보통 늦게 등장하지만 **항상 그렇지는 않다** — 등장 시기로 계층을 기계적으로
결정하지 말고 의미 분석의 보조 근거로만 쓴다. 불확실하면 "년경", 모르면 생략.

## 구축 절차

1. **용어 수집** — 소스 트리·문서·설정을 훑어 주요~세부 용어를 주제별 파일
   (`01_xxx.md` ~ `09_xxx.md`)로 배분한다. 역할 분류는 `00_content_classes.md`에 정의.
2. **항목 작성** — 형식:

   ```markdown
   ### 용어명
   **클래스:** [Concept](00_content_classes.md#concept) · **한글:** 한글명 · **등장:** YYYY(-MM) · **코드:** `소스 경로`

   초보자 눈높이의 정의 + 이 코드베이스에서의 구체적 의미.

   **예시:** 구체적 사용 예 ("이 개념을 활용해 만든" 파생 예시면 상위로도 연결).

   - **상위 개념(이를 기반으로 파생):** [...]
   - **하위 개념(기반·전제):** [...]
   - **관련 용어:** [...]
   ```

3. **재귀 확장** — 설명에 등장하는 전문 용어가 사전에 없으면 항목으로 추가하고, 본문의
   모든 전문 용어를 클릭 가능한 상대 링크(`파일.md#앵커`)로 만든다.
4. **양방향 표기** — A의 상위에 B를 적으면 B의 하위에 A를 적는다.
5. **일반 개념의 범위 표시** — 저장소에 구현되지 않은 일반 개념은 "이 저장소와 직접 관련은
   없는 일반 개념" 식으로 명시해, 구현된 것처럼 오해되지 않게 한다.
6. **그래프 추출** — 마크다운에서 기계적으로 추출해 `graph/nodes.csv`, `graph/edges.csv`,
   `graph/import.cypher`(Neo4j/Memgraph 공용)를 생성한다:
   - `### 제목` → Content 노드 (`content:앵커` id)
   - `**클래스:**` 링크 → `BELONGS_TO`
   - `**등장:**` → `first_appearance` 속성
   - 상위 목록 → `(대상) -[:SPECIALIZES]-> (자신)`, 하위 목록 → `(자신) -[:SPECIALIZES]-> (대상)`
   - 관련 용어 → `RELATED_TO` (id 정렬 후 한 방향만 저장해 중복 방지)
   - 그 외 본문 링크 → `MENTIONS`
   - CSV는 `lineterminator="\n"`으로 써야 `git diff --check`를 통과한다.

## 검증 체크리스트 (필수)

- [ ] 모든 상대 링크·앵커 유효 (파일 존재 + 헤딩 앵커 존재)
- [ ] 중복 앵커 없음 (예: `ReAct` vs `React` 충돌 → 헤딩을 `React (JS)`로 구분)
- [ ] 모든 Content 노드에 최소 1개 `BELONGS_TO`
- [ ] `SPECIALIZES`는 Content → Content, `BELONGS_TO`는 Content → ContentClass만
- [ ] 노드 id 전역 고유 (`content:` / `class:` 접두로 네임스페이스 분리)
- [ ] 대표 사슬 방향 확인 (예: `Transformer→Attention`은 있고 역방향은 없어야 함)
- [ ] README의 개수 통계(용어 수·엣지 수·클래스 분포)를 실제 데이터와 일치시킴
- [ ] `git diff --check` 통과, 사전·그래프 파일 외 변경 없음

## 시행착오 기록 (같은 실수 방지)

- **v1**: `HAS_SUBCONCEPT`(상위→하위) 분류 트리 관점으로 시작 — 방향 규약이 모호했다.
- **v2**: "하위=일반, 상위=특수"로 반전하고 Content/ContentClass 도입. 그러나 "설명 속
  예시 = 상위"를 **링크 등장 여부로 기계 적용**해 Self-Attention을 Transformer의 상위로
  두는 오류를 냈다.
- **v3 (현행)**: 기반/파생 **의미 분석**으로 전 계층 재검토, `first_appearance` 도입.
  교훈: (1) 계층 규칙은 반드시 구체 예시(Attention/Transformer/BERT)로 검증하고,
  (2) 본문 언급은 `MENTIONS`에 머물게 하며, (3) 등장 시기는 보조 근거로만 쓴다.
