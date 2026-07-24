# 2. Configuration (설정)

nanobot의 모든 런타임 동작은 Pydantic 기반 설정으로 통제된다. 루트 클래스는 `nanobot/config/schema.py`의 `Config(BaseSettings)`이며, 기본 경로는 `~/.nanobot/config.json`이다.

## 설정 파일 형식

`config.json`은 camelCase와 snake_case 키를 모두 받는다. 저장할 때는 camelCase 별칭으로 쓴다(예: `apiKey`, `modelPresets`, `intervalS`, `maxToolResultChars`). 이는 각 모델의 베이스 클래스(`Base`, `nanobot/config/schema.py` 상단)가 alias 생성기를 사용하기 때문이다.

대부분의 예제는 부분 스니펫이다. `nanobot onboard`가 만든 파일에 병합해야 하며, 인스턴스를 초기화할 목적이 아니라면 파일 전체를 대체하지 말라.

## 루트 구조

`Config`의 최상위 섹션(`nanobot/config/schema.py`):

| 섹션 | 클래스 | 역할 |
|---|---|---|
| `agents` | `AgentsConfig` → `AgentDefaults` | 모델 기본값, 반복 한계, 세션 TTL, Dream 등 |
| `channels` | `ChannelsConfig` | 채널 활성화·설정 |
| `transcription` | `TranscriptionConfig` | 음성 전사 프로바이더 |
| `providers` | `ProvidersConfig` | LLM 프로바이더별 자격증명/엔드포인트 |
| `api` | `ApiConfig` | OpenAI 호환 API 서버 |
| `gateway` | `GatewayConfig` | 게이트웨이 host/port, heartbeat |
| `tools` | `ToolsConfig` | 도구별 설정, MCP 서버, SSRF 화이트리스트 |
| `modelPresets` | `dict[str, ModelPresetConfig]` | 이름 붙은 모델 프리셋 |

## agents.defaults 주요 필드

`AgentDefaults`(`schema.py`)의 대표 필드:

- `workspace`: 워크스페이스 경로(기본 `~/.nanobot/workspace`).
- `modelPreset`: 활성 프리셋 이름. 설정되면 아래 개별 필드보다 우선.
- `model`, `provider`, `maxTokens`, `contextWindowTokens`, `temperature`, `reasoningEffort`: 암묵적 `default` 프리셋을 구성.
- `fallbackModels`: 프라이머리 실패 시 대체 체인.
- `maxToolIterations`(기본 200): 한 턴에서 도구 반복 상한.
- `maxConcurrentSubagents`(기본 1): 병렬 subagent 수.
- `maxToolResultChars`(기본 16000): 도구 결과 길이 상한.
- `unifiedSession`: 모든 채널에서 세션 하나 공유.
- `disabledSkills`: 로딩에서 제외할 스킬 이름 목록.
- `sessionTtlMinutes`(별칭 `idleCompactAfterMinutes`, 기본 15): 유휴 auto-compact 임계값.
- `consolidationRatio`(기본 0.5): 압축 후 유지 비율.
- `dream`: `DreamConfig`.

## gateway / api

- `GatewayConfig`: `host`(기본 `127.0.0.1`), `port`(기본 `18790`), `restartMode`(`auto|exec|spawn|exit`), `heartbeat`(`HeartbeatConfig`).
- `ApiConfig`: `host`(기본 `127.0.0.1`), `port`(기본 `8900`), `timeout`(120s), `apiKey`. `host`가 `0.0.0.0`/`::`이면 `apiKey` 없이는 검증(`wildcard_host_requires_auth`)에서 실패해 인증 없는 노출을 막는다.
- `HeartbeatConfig`: `enabled`(기본 true), `intervalS`(기본 30분), `keepRecentMessages`(기본 8).

## tools

`ToolsConfig`는 하위 도구 설정(`web`, `exec`, `file`, `cliApps`, `my`, `imageGeneration`)과 다음을 포함한다.

- `restrictToWorkspace`: 가능한 한 도구 접근을 워크스페이스 내부로 제한하려는 정책 의도.
- `webuiAllowLocalServiceAccess`(기본 true), `webuiAllowRemotePackageInstall`(기본 false).
- `mcpServers`: `dict[str, MCPServerConfig]` — MCP 서버 정의.
- `ssrfWhitelist`: SSRF 차단에서 제외할 CIDR 목록(예: Tailscale용 `["100.64.0.0/10"]`).

## 환경 변수 치환

설정 값에 `${ENV_VAR}` 형태를 쓰면 로드 시 환경 변수로 치환된다(`nanobot/config/loader.py`의 `resolve_config_env_vars`, `_env_replace`). 예:

```json
{ "api": { "apiKey": "${NANOBOT_API_KEY}" } }
```

## 세부 문서

- 스키마와 로더 내부 동작: [2.1 Config Schema and Loader](02.1-config-schema-and-loader.md)
- 프로바이더와 모델 프리셋: [2.2 Providers and Model Presets](02.2-providers-and-model-presets.md)

전체 필드 레퍼런스는 저장소의 `docs/configuration.md`(약 2200줄)에 있다.

### 참조 파일

- `nanobot/config/schema.py` (`Config`, `AgentDefaults`, `ToolsConfig`, `GatewayConfig`, `ApiConfig` …)
- `nanobot/config/loader.py` (`load_config`, `save_config`, `resolve_config_env_vars`)
- `nanobot/config/paths.py`
- `docs/configuration.md`, `docs/concepts.md`
