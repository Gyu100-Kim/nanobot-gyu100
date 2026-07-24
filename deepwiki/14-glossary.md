# 14. Glossary (용어집)

nanobot 코드베이스에서 자주 쓰이는 용어와 식별자를 정리한다. 코드 식별자는 원문(영어) 그대로 표기한다.

## 코어

- **`AgentLoop`** — 채널을 마주하는 턴 조율 엔진. 세션·컨텍스트·훅을 관리한다(`nanobot/agent/loop.py`, [3.1](03.1-agent-loop-and-turn-state-machine.md)).
- **`AgentRunner`** — 모델을 마주하는 반복 루프. 프로바이더 호출·도구 실행을 반복한다(`nanobot/agent/runner.py`, [3.2](03.2-agent-runner-and-llm-provider-interface.md)).
- **`TurnState`** — 한 턴의 상태 머신 단계(RESTORE/COMPACT/COMMAND/BUILD/RUN/SAVE/RESPOND/DONE).
- **`TurnContext`** — 한 턴의 모든 가변 상태를 담는 dataclass.
- **`ContextBuilder`** — 시스템 프롬프트와 메시지 배열을 조립(`nanobot/agent/context.py`, [3.3](03.3-context-builder-and-system-prompts.md)).
- **`MessageBus`** — 채널과 코어를 잇는 비동기 큐(`nanobot/bus/queue.py`).
- **`InboundMessage` / `OutboundMessage`** — 버스를 흐르는 입출력 메시지 이벤트(`nanobot/bus/events.py`).

## 프로바이더

- **`LLMProvider`** — 모든 LLM 백엔드의 추상 베이스(`nanobot/providers/base.py`, [3.2](03.2-agent-runner-and-llm-provider-interface.md)).
- **`ProviderSpec`** — 프로바이더 메타데이터(레지스트리 항목, `nanobot/providers/registry.py`, [2.2](02.2-providers-and-model-presets.md)).
- **`OpenAICompatProvider`** — OpenAI 호환 기본 구현([5.1](05.1-openai-compatible-provider.md)).
- **`FallbackProvider`** — 프라이머리 실패 시 대체 체인([5.2](05.2-anthropic-azure-bedrock-and-specialized-providers.md)).
- **Model Preset** — 모델+생성 파라미터의 이름 붙은 묶음(`ModelPresetConfig`, [2.2](02.2-providers-and-model-presets.md)).
- **thinking style / reasoning effort** — 프로바이더별 추론 토글/강도([5.1](05.1-openai-compatible-provider.md)).

## 메모리·세션

- **Session** — 하나의 대화. `<workspace>/sessions/*.jsonl`에 저장([4.1](04.1-session-manager.md)).
- **session key** — 채널/채팅을 대화에 매핑하는 키(`session_key_for_channel`).
- **Consolidator** — 컨텍스트 예산 압박 시 오래된 메시지를 `history.jsonl`로 요약([4.3](04.3-consolidation-and-autocompact.md)).
- **AutoCompact** — 유휴 세션을 TTL로 아카이브([4.3](04.3-consolidation-and-autocompact.md)).
- **Dream** — 히스토리 아카이브를 읽어 장기 메모리(`SOUL/USER/MEMORY`)를 갱신하는 통합 잡([4.2](04.2-memory-store-and-dream-system.md)).
- **`MemoryStore`** — 메모리 파일과 히스토리 아카이브 관리(`nanobot/agent/memory.py`).
- **`GitStore`** — 장기 메모리 파일의 버전 관리(`nanobot/utils/gitstore.py`).
- **sustained goal / long-goal** — 여러 턴에 걸친 장기 목표(`nanobot/session/goal_state.py`, [6.3](06.3-cron-image-generation-and-other-tools.md)).

## 도구

- **`Tool` / `ToolRegistry` / `ToolLoader`** — 도구 계약·등록·자동 발견(`nanobot/agent/tools/`, [6](06-tools.md)).
- **`ToolResult`** — 도구 실행 결과.
- **MCP** — Model Context Protocol. 외부 도구/리소스/프롬프트를 표준 프로토콜로 노출([6.2](06.2-web-search-and-mcp-tools.md)).
- **subagent** — 격리된 백그라운드 러너(`SubagentManager`, `spawn` 도구, [3.4](03.4-sub-agents-and-parallel-execution.md)).

## 채널·표면

- **Channel** — 외부 메시징 플랫폼 연동(`nanobot/channels/`, [7](07-channels.md)).
- **`ChannelManager`** — 채널 발견·조율.
- **WebSocketChannel** — nanobot이 서버가 되어 WebUI에 서비스하는 채널([7.4](07.4-websocket-channel-and-webui-protocol.md)).
- **Gateway** — 장기 실행 런타임(`nanobot gateway`, [8.2](08.2-gateway-runtime-and-background-services.md)).
- **CronService** — 예약 작업 서비스(`nanobot/cron/service.py`).
- **Heartbeat** — 주기적 작업 목록 점검(`HEARTBEAT.md`, [8.2](08.2-gateway-runtime-and-background-services.md)).

## 설정·경로

- **`Config`** — 루트 Pydantic 설정(`nanobot/config/schema.py`, [2](02-configuration.md)).
- **workspace** — 인스턴스 상태 저장 디렉토리(`~/.nanobot/workspace/`).
- **config** — 인스턴스 설정 파일(`~/.nanobot/config.json`).
- **model preset / provider** — [2.2](02.2-providers-and-model-presets.md) 참조.

## 보안

- **SSRF Guard** — 내부/사설 주소로의 요청 차단(`nanobot/security/network.py`, [11.1](11.1-network-security-and-ssrf-guard.md)).
- **DNS pinning** — 검증된 IP를 연결에 고정해 rebinding 방지(`PinnedDNSAsyncTransport`).
- **Workspace Boundary** — 파일/셸 접근을 워크스페이스로 제한(`WorkspaceBoundaryError`, [11.2](11.2-workspace-policy-and-sandboxing.md)).
- **WorkspaceScope** — 클라이언트별 접근 범위(`nanobot/security/workspace_access.py`).
- **sandbox** — 셸 실행 격리(bubblewrap 등, `nanobot/agent/tools/sandbox.py`).

## API·SDK

- **OpenAI-compatible API** — `/v1/chat/completions` 등 HTTP API(`nanobot/api/server.py`, [10.1](10.1-api-endpoints-and-authentication.md)).
- **`Nanobot`** — 파이썬 SDK 진입점(`nanobot/nanobot.py`, [10.2](10.2-python-sdk.md)).
- **`RunResult`** — SDK 실행 결과.

### 참조 파일

- 각 항목의 소스는 링크된 문서를 참조.
- `docs/architecture.md`, `docs/concepts.md`, `AGENTS.md`
