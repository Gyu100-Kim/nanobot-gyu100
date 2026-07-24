# 1. Overview (개요)

## nanobot이란

nanobot은 파이썬으로 작성된 경량 오픈소스 AI 에이전트 프레임워크다. React/TypeScript 기반의 WebUI를 함께 제공한다. 핵심은 하나의 작은 에이전트 루프(agent loop)로, 채팅 채널에서 메시지를 받아 LLM 프로바이더를 호출하고, 도구(tool)를 실행하며, 세션·메모리를 관리한다.

핵심 정보는 `pyproject.toml`에 정의되어 있다.

- 패키지 이름: `nanobot-ai`, 버전 `0.2.2`
- 요구 파이썬: `>=3.11`
- 라이선스: MIT
- CLI 엔트리포인트: `nanobot = "nanobot.cli.commands:app"` (`[project.scripts]`)

주요 의존성으로는 `typer`(CLI), `pydantic`/`pydantic-settings`(설정 스키마), `anthropic`·`openai`(프로바이더 SDK), `httpx`(HTTP), `mcp`(Model Context Protocol), `websockets`, `croniter`(cron), `dulwich`(메모리 git 저장), `tiktoken`(토큰 추정), `jinja2`(프롬프트 템플릿) 등이 있다.

## 런타임 형태

nanobot은 하나의 작은 코어 루프와 그 루프로 진입하는 여러 경로를 가진다. 데이터 흐름은 다음과 같다(`AGENTS.md`, `docs/architecture.md`).

```
Channel (CLI, WebUI, chat apps)
   -> MessageBus (InboundMessage)      nanobot/bus/queue.py
   -> AgentLoop (세션·워크스페이스·컨텍스트)  nanobot/agent/loop.py
   -> AgentRunner (provider/tool 루프)  nanobot/agent/runner.py
   -> Provider (LLM 백엔드)             nanobot/providers/
   -> Tools (files, shell, web, MCP, cron) nanobot/agent/tools/
   -> MessageBus (OutboundMessage)
   -> Channel
```

- **Channels**(`nanobot/channels/`)는 외부 플랫폼에서 메시지를 받아 `InboundMessage` 이벤트를 비동기 `MessageBus`(`nanobot/bus/queue.py`)로 발행한다.
- **`AgentLoop`**(`nanobot/agent/loop.py`)는 인바운드 메시지를 소비하고, 세션 키와 워크스페이스 스코프를 정하고, 컨텍스트를 만들며, 턴(turn)을 조율한다.
- **`AgentRunner`**(`nanobot/agent/runner.py`)는 실제 LLM 대화 루프를 담당한다. 프로바이더에 메시지를 보내고, 스트리밍 델타·추론 블록을 처리하고, 도구 호출을 실행해 결과를 다시 모델에 넣는다.
- 최종 응답은 `OutboundMessage`로 발행되어 원래 채널로 돌아간다.

## 주요 서브시스템

| 서브시스템 | 위치 | 역할 |
|---|---|---|
| Agent Loop / Runner | `nanobot/agent/loop.py`, `runner.py` | 코어 처리 엔진. 세션·훅·컨텍스트 관리와 다중 턴 LLM 대화 실행 |
| LLM Providers | `nanobot/providers/` | Anthropic, OpenAI 호환, Azure, Bedrock, Codex, Copilot 등 백엔드 |
| Channels | `nanobot/channels/` | Telegram, Discord, Slack, Feishu, Matrix 등 플랫폼 연동 |
| Tools | `nanobot/agent/tools/` | filesystem, shell, web, MCP, cron, image, subagent 등 |
| Memory | `nanobot/agent/memory.py` | 장기 메모리와 Dream 통합(consolidation) |
| Session | `nanobot/session/` | 세션별 히스토리, 컴팩션, TTL 기반 auto-compaction |
| Config | `nanobot/config/schema.py`, `loader.py` | Pydantic 설정 스키마와 로딩 |
| WebUI | `webui/`, `nanobot/webui/` | React SPA와 게이트웨이 백엔드 API |
| API Server | `nanobot/api/server.py` | OpenAI 호환 HTTP API |
| Command Router | `nanobot/command/` | 슬래시 명령 라우팅 |
| Security | `nanobot/security/` | 워크스페이스 샌드박싱, SSRF 방어 |

## 진입점

- **CLI 일회성**: `nanobot agent -m "Hello!"` — 인바운드 메시지 하나가 에이전트 루프를 거쳐 터미널에 답을 출력.
- **CLI 대화형**: `nanobot agent` — 세션 히스토리가 유지되는 터미널 채팅.
- **Gateway**: `nanobot gateway` — 채팅 앱, WebUI, heartbeat, Dream, cron 등 장기 실행 서비스.
- **OpenAI 호환 API**: `nanobot serve` — `/v1/chat/completions` 프로그래밍 접근.
- **WebUI**: `nanobot webui` — WebSocket 채널이 서빙하는 브라우저 워크벤치(기본 포트 `8765`).

## 이 위키의 사용법

이 `deepwiki/`는 기존 프로젝트 문서(`docs/`)와 분리된 코드베이스 학습용 위키다. 각 장은 실제 소스 파일·클래스·함수를 근거로 서술하며, 관련 파일 경로를 명시한다. 다음 단계는 [1.1 Getting Started](01.1-getting-started.md)와 [1.2 Core Concepts](01.2-core-concepts.md)를 참고하라. 전체 목차는 [README.md](README.md)에 있다.

### 참조 파일

- `pyproject.toml`, `README.md`, `AGENTS.md`
- `docs/architecture.md`, `docs/concepts.md`
- `nanobot/agent/loop.py`, `nanobot/agent/runner.py`
- `nanobot/bus/queue.py`, `nanobot/bus/events.py`
