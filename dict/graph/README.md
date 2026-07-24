# 용어집 그래프 데이터 (Glossary Graph Export)

[dict/](../README.md)의 모든 용어와 용어 간 관계를 그래프 DB로 옮기기 위한 데이터입니다.
대상 DB는 **Neo4j**와, 대표적인 오픈소스(소스 공개) 그래프 DB로 **Memgraph** 를 지정합니다 —
Memgraph는 Cypher 쿼리 언어와 Bolt 프로토콜이 Neo4j와 호환되어 **동일한 임포트 파일을 그대로 사용**할 수
있습니다. (CSV는 범용 형식이므로 ArangoDB, NebulaGraph 등 다른 그래프 DB로도 변환이 쉽습니다.)

## 파일

| 파일 | 내용 |
|---|---|
| `nodes.csv` | 용어 노드. 열: `id:ID`(전역 고유 앵커), `name`, `category`(주제 파일), `file`(정의 위치), `:LABEL`(`Term`) — Neo4j `neo4j-admin import` 헤더 규격 |
| `edges.csv` | 관계. 열: `:START_ID`, `:END_ID`, `:TYPE` |
| `import.cypher` | `MERGE` 기반 Cypher 스크립트 — Neo4j·Memgraph 어느 쪽에서든 그대로 실행 가능(멱등) |

## 관계 타입

| 타입 | 의미 |
|---|---|
| `HAS_SUBCONCEPT` | 계층 관계: A → B 는 "B가 A의 하위 개념"(항목의 `상위/하위 개념` 필드에서 추출, 방향 정규화) |
| `RELATED_TO` | 계층은 아니지만 밀접한 관련(항목의 `관련 용어` 필드) |
| `MENTIONS` | 설명 본문에서 다른 용어를 언급(본문 링크에서 추출; 위 두 관계와 중복되면 제외) |

## 임포트 방법

### Neo4j / Memgraph — Cypher 스크립트 (권장, 멱등)

```bash
# Neo4j
cypher-shell -u neo4j -p <password> -f import.cypher
# Memgraph (mgconsole)
mgconsole < import.cypher
```

### Neo4j — 대량 CSV 임포트 (빈 DB 초기 적재)

```bash
neo4j-admin database import full --nodes=nodes.csv --relationships=edges.csv neo4j
```

### Memgraph — CSV 적재 (LOAD CSV)

```cypher
LOAD CSV FROM "/path/to/nodes.csv" WITH HEADER AS row
CREATE (:Term {id: row["id:ID"], name: row.name, category: row.category, file: row.file});

LOAD CSV FROM "/path/to/edges.csv" WITH HEADER AS row
MATCH (a:Term {id: row[":START_ID"]}), (b:Term {id: row[":END_ID"]})
CREATE (a)-[:RELATES {type: row[":TYPE"]}]->(b);
```

## 예시 쿼리

```cypher
// Sandbox의 하위 개념 트리 (3단계)
MATCH p = (t:Term {id: "sandbox"})-[:HAS_SUBCONCEPT*1..3]->(sub) RETURN p;

// 가장 많이 연결된 허브 용어 상위 10개
MATCH (t:Term)-[r]-() RETURN t.name, count(r) AS degree ORDER BY degree DESC LIMIT 10;

// 두 용어 사이의 최단 연결 경로
MATCH p = shortestPath((a:Term {id: "dream"})-[*]-(b:Term {id: "cron"})) RETURN p;
```

## 재생성

이 데이터는 `dict/*.md`의 항목 구조(제목·`상위/하위 개념`·`관련 용어`·본문 링크)에서 기계적으로
추출한 것입니다. 마크다운을 수정한 뒤에는 같은 규칙으로 재추출하면 항상 문서와 동기화됩니다.
