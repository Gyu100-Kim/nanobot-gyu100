# nanobot DeepWiki (코드베이스 학습용 위키)

이 위키는 `nanobot` 코드베이스를 학습하기 위한 한국어 문서 모음이다. 기존 사용자 문서(`docs/`)와 분리된, **코드 내부 구조**에 초점을 둔 학습용 위키다. 각 페이지는 실제 소스 코드(`nanobot/` 모듈, `webui/`, `docs/`, `pyproject.toml` 등)를 근거로 작성했으며, 관련 파일 경로를 참조로 명시한다.

- 서술 언어: 한국어
- 코드 식별자·파일 경로·클래스/함수 이름: 원문(영어) 유지
- 대상 저장소: `Gyu100-Kim/nanobot-gyu100`

## 목차

### 1. [Overview (개요)](01-overview.md)
- 1.1 [Getting Started (시작하기)](01.1-getting-started.md)
- 1.2 [Core Concepts (핵심 개념)](01.2-core-concepts.md)

### 2. [Configuration (설정)](02-configuration.md)
- 2.1 [Config Schema and Loader (설정 스키마와 로더)](02.1-config-schema-and-loader.md)
- 2.2 [Providers and Model Presets (프로바이더와 모델 프리셋)](02.2-providers-and-model-presets.md)

### 3. [Agent Core (에이전트 코어)](03-agent-core.md)
- 3.1 [Agent Loop and Turn State Machine (에이전트 루프와 턴 상태 머신)](03.1-agent-loop-and-turn-state-machine.md)
- 3.2 [Agent Runner and LLM Provider Interface (에이전트 러너와 LLM 프로바이더 인터페이스)](03.2-agent-runner-and-llm-provider-interface.md)
- 3.3 [Context Builder and System Prompts (컨텍스트 빌더와 시스템 프롬프트)](03.3-context-builder-and-system-prompts.md)
- 3.4 [Sub-agents and Parallel Execution (서브에이전트와 병렬 실행)](03.4-sub-agents-and-parallel-execution.md)

### 4. [Memory and Session Management (메모리와 세션 관리)](04-memory-and-session-management.md)
- 4.1 [Session Manager (세션 매니저)](04.1-session-manager.md)
- 4.2 [Memory Store and Dream System (메모리 스토어와 Dream 시스템)](04.2-memory-store-and-dream-system.md)
- 4.3 [Consolidation and AutoCompact (컨솔리데이션과 자동 컴팩션)](04.3-consolidation-and-autocompact.md)

### 5. [LLM Providers (LLM 프로바이더)](05-llm-providers.md)
- 5.1 [OpenAI-Compatible Provider (OpenAI 호환 프로바이더)](05.1-openai-compatible-provider.md)
- 5.2 [Anthropic, Azure, Bedrock, and Specialized Providers](05.2-anthropic-azure-bedrock-and-specialized-providers.md)

### 6. [Tools (도구)](06-tools.md)
- 6.1 [Shell Execution and Filesystem Tools (Shell 실행과 파일시스템 도구)](06.1-shell-execution-and-filesystem-tools.md)
- 6.2 [Web, Search, and MCP Tools (웹·검색·MCP 도구)](06.2-web-search-and-mcp-tools.md)
- 6.3 [Cron, Image Generation, and Other Tools (Cron·이미지 생성·기타 도구)](06.3-cron-image-generation-and-other-tools.md)

### 7. [Channels (채널)](07-channels.md)
- 7.1 [Telegram and Discord (텔레그램과 디스코드)](07.1-telegram-and-discord.md)
- 7.2 [Feishu, Matrix, and WeChat (Feishu·Matrix·WeChat)](07.2-feishu-matrix-and-wechat.md)
- 7.3 [Slack, WhatsApp, and Other (Slack·WhatsApp·기타)](07.3-slack-whatsapp-and-other.md)
- 7.4 [WebSocket Channel and WebUI Protocol (WebSocket 채널과 WebUI 프로토콜)](07.4-websocket-channel-and-webui-protocol.md)

### 8. [CLI and Gateway (CLI와 게이트웨이)](08-cli-and-gateway.md)
- 8.1 [CLI Commands Reference (CLI 명령 레퍼런스)](08.1-cli-commands-reference.md)
- 8.2 [Gateway Runtime and Background Services (게이트웨이 런타임과 백그라운드 서비스)](08.2-gateway-runtime-and-background-services.md)

### 9. [WebUI (웹 UI)](09-webui.md)
- 9.1 [Frontend Components and State (프론트엔드 컴포넌트와 상태)](09.1-frontend-components-and-state.md)
- 9.2 [Backend WebUI APIs (백엔드 WebUI API)](09.2-backend-webui-apis.md)

### 10. [OpenAI-Compatible API Server (OpenAI 호환 API 서버)](10-openai-compatible-api-server.md)
- 10.1 [API Endpoints and Authentication (API 엔드포인트와 인증)](10.1-api-endpoints-and-authentication.md)
- 10.2 [Python SDK (파이썬 SDK)](10.2-python-sdk.md)

### 11. [Security (보안)](11-security.md)
- 11.1 [Network Security and SSRF Guard (네트워크 보안과 SSRF 가드)](11.1-network-security-and-ssrf-guard.md)
- 11.2 [Workspace Policy and Sandboxing (워크스페이스 정책과 샌드박싱)](11.2-workspace-policy-and-sandboxing.md)

### 12. [Skills System (스킬 시스템)](12-skills-system.md)
- 12.1 [Built-in Skills Reference (내장 스킬 레퍼런스)](12.1-built-in-skills-reference.md)

### 13. [Deployment and Infrastructure (배포와 인프라)](13-deployment-and-infrastructure.md)
- 13.1 [Docker and Container Deployment (Docker와 컨테이너 배포)](13.1-docker-and-container-deployment.md)
- 13.2 [Testing and CI (테스트와 CI)](13.2-testing-and-ci.md)

### 14. [Glossary (용어집)](14-glossary.md)

## 읽는 순서 제안

1. 처음이라면: [1. Overview](01-overview.md) → [1.1 Getting Started](01.1-getting-started.md) → [1.2 Core Concepts](01.2-core-concepts.md).
2. 런타임 동작이 궁금하다면: [3. Agent Core](03-agent-core.md)와 [4. Memory and Session Management](04-memory-and-session-management.md).
3. 확장/통합이 목적이라면: [5. LLM Providers](05-llm-providers.md), [6. Tools](06-tools.md), [7. Channels](07-channels.md), [12. Skills System](12-skills-system.md).
4. 운영/보안이 목적이라면: [11. Security](11-security.md)와 [13. Deployment and Infrastructure](13-deployment-and-infrastructure.md).

용어가 낯설면 언제든 [14. Glossary](14-glossary.md)를 참고하라.
