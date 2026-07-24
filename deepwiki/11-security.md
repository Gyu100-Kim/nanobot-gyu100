# 11. Security (보안)

nanobot은 임의 도구(shell, 파일, 웹)를 LLM이 호출할 수 있으므로, 여러 계층의 보안 통제를 둔다. 구현은 `nanobot/security/` 아래에 있다.

## 보안 계층

| 계층 | 위치 | 목적 |
|---|---|---|
| 네트워크(SSRF) | `nanobot/security/network.py` | 웹/MCP 요청이 내부·사설 주소로 향하지 못하게 차단 |
| 워크스페이스 경계 | `nanobot/security/workspace_policy.py` | 파일/셸 접근을 워크스페이스 안으로 제한 |
| 워크스페이스 접근 스코프 | `nanobot/security/workspace_access.py` | 클라이언트(로컬/원격)별 접근 범위와 샌드박싱 |

이 밖에 CLI 진입 시 활성화되는 PTH 파일 가드 등 부가 조치가 있다(`AGENTS.md`, `.agent/security.md`).

## 인증 통제(요약)

- API 서버: `0.0.0.0` 바인드 시 `apiKey` 강제, Bearer 토큰 `hmac` 비교([10.1](10.1-api-endpoints-and-authentication.md)).
- WebSocket/WebUI: 원격 연결 토큰, 워크스페이스 스코프 제한([7.4](07.4-websocket-channel-and-webui-protocol.md)).
- 채널: 허용 목록과 DM 페어링(`nanobot/pairing/`, [7](07-channels.md)).

## 도구 위반 처리

러너는 도구 실행 중 보안 위반을 분류해 안전하게 모델에 전달한다(`AgentRunner._classify_violation`, `_is_ssrf_violation`, `_is_workspace_violation`, `_ssrf_soft_payload`, [3.2](03.2-agent-runner-and-llm-provider-interface.md)). 즉 위반은 프로세스를 죽이지 않고, 에이전트가 스스로 교정할 수 있는 오류로 반환된다.

## 하위 문서

- [11.1 Network Security and SSRF Guard](11.1-network-security-and-ssrf-guard.md)
- [11.2 Workspace Policy and Sandboxing](11.2-workspace-policy-and-sandboxing.md)

### 참조 파일

- `nanobot/security/network.py`, `workspace_policy.py`, `workspace_access.py`
- `nanobot/agent/runner.py` (위반 분류)
- `.agent/security.md`, `AGENTS.md`
