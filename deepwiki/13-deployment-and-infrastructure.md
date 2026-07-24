# 13. Deployment and Infrastructure (배포와 인프라)

이 장은 nanobot을 실제로 운영·배포하는 방법과, 개발/CI 인프라를 다룬다.

## 배포 표면

nanobot은 하나의 게이트웨이 프로세스로 여러 표면을 서빙한다([8.2](08.2-gateway-runtime-and-background-services.md)).

| 표면 | 기본 포트 | 비고 |
|---|---|---|
| Gateway health/control | `18790` | `GatewayConfig` |
| WebSocket / WebUI | `8765` | `WebSocketChannel` |
| OpenAI 호환 API | `8900` | `ApiConfig`(별도 `nanobot serve`) |

배포 전 점검: `nanobot status`로 config/provider/workspace를 확인하고, 프로바이더 자격증명과 워크스페이스 쓰기 권한을 검증한다([1.1](01.1-getting-started.md)).

## 영속성

컨테이너/서비스로 운영할 때는 워크스페이스(`~/.nanobot/workspace/`)와 설정(`~/.nanobot/config.json`)을 볼륨으로 영속화해야 세션·메모리·cron이 재시작 후에도 유지된다([4](04-memory-and-session-management.md)).

## 자격증명과 보안

- API 키는 환경 변수 치환(`${ENV}`)으로 주입하는 것이 안전하다([2.1](02.1-config-schema-and-loader.md)).
- 원격 노출 시 API/WebSocket 모두 인증 토큰과 TLS를 사용한다([10.1](10.1-api-endpoints-and-authentication.md), [7.4](07.4-websocket-channel-and-webui-protocol.md)).
- `0.0.0.0` 바인드는 인증 없이는 거부된다.

## 하위 문서

- [13.1 Docker and Container Deployment](13.1-docker-and-container-deployment.md)
- [13.2 Testing and CI](13.2-testing-and-ci.md)

### 참조 파일

- `Dockerfile`, `docker-compose.yml`, `entrypoint.sh`
- `.github/workflows/ci.yml`
- `docs/deployment.md`
