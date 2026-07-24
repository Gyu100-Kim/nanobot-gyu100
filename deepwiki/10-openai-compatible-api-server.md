# 10. OpenAI-Compatible API Server (OpenAI 호환 API 서버)

nanobot은 OpenAI 호환 HTTP API를 제공해, 기존 OpenAI 클라이언트/SDK로 nanobot 에이전트를 프로그래밍 방식으로 사용할 수 있게 한다. 구현은 `nanobot/api/server.py`이며 `aiohttp` 위에 있다.

## 실행

```bash
nanobot serve
```

`serve` 명령(`nanobot/cli/commands.py`)이 API 서버를 띄운다. 설정은 `ApiConfig`(`nanobot/config/schema.py`).

- `host`(기본 `127.0.0.1`), `port`(기본 `8900`), `timeout`(120s), `apiKey`.
- `host`가 `0.0.0.0`/`::`이면 `apiKey` 없이 시작할 수 없다(`wildcard_host_requires_auth`, [2.1](02.1-config-schema-and-loader.md)).

## 고정 세션 모델

모든 요청은 하나의 지속 API 세션으로 라우팅된다(`API_SESSION_KEY = "api:default"`, `API_CHAT_ID = "default"`). 즉 API는 상태를 가진 단일 에이전트 세션으로 동작한다. 세션 ID를 헤더/필드로 지정하면 다른 세션으로 분리할 수도 있다([10.1](10.1-api-endpoints-and-authentication.md)).

## 엔드포인트 요약

| 엔드포인트 | 핸들러 | 역할 |
|---|---|---|
| `GET /health` | `handle_health` | 헬스 체크 |
| `GET /v1/models` | `handle_models` | 모델(프리셋) 목록 |
| `POST /v1/chat/completions` | `handle_chat_completions` | 채팅 완성(스트리밍/비스트리밍) |

앱 생성은 `create_app(...)`가 담당하며, 인증 미들웨어가 붙는다.

## 하위 문서

- [10.1 API Endpoints and Authentication](10.1-api-endpoints-and-authentication.md)
- [10.2 Python SDK](10.2-python-sdk.md)

### 참조 파일

- `nanobot/api/server.py` (`create_app`, `handle_chat_completions`, `handle_models`, `handle_health`)
- `nanobot/config/schema.py` (`ApiConfig`)
- `docs/openai-api.md`
