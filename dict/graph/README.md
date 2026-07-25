# dict/ 지식 그래프 데이터 (Graph Export)

[../](../README.md)의 용어·개념 사전을 그래프 DB로 임포트하기 위한 데이터입니다.
대상 DB: **Neo4j**와 오픈소스 대표 호환 DB인 **Memgraph** (둘 다 Cypher/Bolt 호환이라 같은
파일을 그대로 사용할 수 있습니다).

## 데이터 모델

### 노드 (2종)

| Label | 의미 | 개수 |
|---|---|---|
| `Content` | 용어·개념 사전을 구성하는 용어/개념 노드 | 244 |
| `ContentClass` | Content의 정체(역할) 분류 노드 ([../00_content_classes.md](../00_content_classes.md)) | 9 |

Content 노드 속성: `id`(예: `content:system-prompt`), `name`, `file`(출처 마크다운), `description`.
ContentClass 노드 속성: `id`(예: `class:component`), `name`, `file`.

ID는 `content:` / `class:` 접두로 네임스페이스를 분리해 전역 고유성을 보장합니다.

### 관계 (4종)

| Type | 의미 | 방향 |
|---|---|---|
| `SPECIALIZES` | 출발이 도착보다 **더 특수한(상위)** 개념 | `(:Content 특수)-[:SPECIALIZES]->(:Content 일반)` |
| `BELONGS_TO` | 해당 클래스에 속함 (계층 아님) | `(:Content)-[:BELONGS_TO]->(:ContentClass)` |
| `RELATED_TO` | 계층은 아니지만 밀접히 관련 | Content → Content (정렬된 한 방향만 저장) |
| `MENTIONS` | 설명 본문에서 언급 | Content → Content |

방향 규약 예시 (사전의 상위=특수 / 하위=일반 규약):

```text
(System Prompt)-[:SPECIALIZES]->(Prompt)
(LoRA)-[:SPECIALIZES]->(PEFT)-[:SPECIALIZES]->(Fine-tuning)
```

불변 조건:

- 모든 `Content` 노드는 최소 1개의 `ContentClass`와 `BELONGS_TO`로 연결됩니다.
- `SPECIALIZES`는 Content → Content, `BELONGS_TO`는 Content → ContentClass만 허용됩니다.

## 파일

| 파일 | 내용 |
|---|---|
| `nodes.csv` | 노드 253개 (Content 244 + ContentClass 9), neo4j-admin import 헤더 형식 |
| `edges.csv` | 관계 828개 (SPECIALIZES 219, BELONGS_TO 244, RELATED_TO 144, MENTIONS 221) |
| `import.cypher` | 제약 + MERGE 기반 임포트 스크립트 (Neo4j/Memgraph 공용, 재실행 안전) |

## 임포트 방법

### Neo4j / Memgraph — Cypher 스크립트 (권장)

```bash
# Neo4j
cypher-shell -u neo4j -p <password> -f import.cypher
# Memgraph
mgconsole < import.cypher
```

### Neo4j — 대량 CSV 임포트

```bash
neo4j-admin database import full \
  --nodes=graph/nodes.csv \
  --relationships=graph/edges.csv \
  neo4j
```

(`:LABEL` 컬럼이 Content/ContentClass를 구분합니다.)

### Memgraph — LOAD CSV

```cypher
LOAD CSV FROM "/data/nodes.csv" WITH HEADER AS row
CREATE (n {id: row.`id:ID`, name: row.name, file: row.file, description: row.description});
```

이후 `row.:LABEL` 값에 따라 `SET n:Content` / `SET n:ContentClass`를 적용하거나,
간단히 `import.cypher`를 사용하세요.

## 예시 쿼리

```cypher
// Prompt의 상위(더 특수한) 개념들
MATCH (s:Content)-[:SPECIALIZES]->(g:Content {name: "Prompt"}) RETURN s.name;

// LoRA에서 가장 일반적인 개념까지의 일반화 사슬
MATCH p = (c:Content {name: "LoRA"})-[:SPECIALIZES*]->(g:Content)
WHERE NOT (g)-[:SPECIALIZES]->() RETURN [n IN nodes(p) | n.name];

// 클래스별 용어 수
MATCH (c:Content)-[:BELONGS_TO]->(k:ContentClass)
RETURN k.name, count(c) ORDER BY count(c) DESC;

// Sandbox와 2단계 이내로 연결된 모든 개념
MATCH (a:Content {name: "Sandbox"})-[:SPECIALIZES|RELATED_TO*1..2]-(b:Content)
RETURN DISTINCT b.name;
```

## 재생성

이 데이터는 `../*.md`의 항목·필드(`클래스`, `상위 개념(더 특수)`, `하위 개념(더 일반)`,
`관련 용어`, 본문 링크)에서 기계적으로 추출한 것입니다. 마크다운이 바뀌면 같은 규칙으로
재추출하면 됩니다: `### 제목` = Content 노드, `**클래스:**` 링크 = `BELONGS_TO`,
상위/하위 목록 = `SPECIALIZES`(특수 → 일반 방향으로 정규화), 관련 용어 = `RELATED_TO`,
그 외 본문 링크 = `MENTIONS`.
