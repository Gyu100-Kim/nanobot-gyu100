# 09. LLM 프로바이더 — 모델을 갈아끼우고 폴백하기

> **이 문서에서 다루는 큰 맥락**
>
> nanobot은 특정 LLM[(용어사전)](../dict/08_ai_llm_concepts.md#llm) 회사에 묶이지 않습니다. **프로바이더(Provider[(용어사전)](../dict/01_core_architecture.md#provider))** 는 "LLM에게 대화를 보내고 응답을 받는"
> 공통 인터페이스이고, Anthropic·OpenAI·Azure·Bedrock·GitHub Copilot 등 여러 구현체가 그 인터페이스를 따릅니다.
> 이 문서는 공통 기반 `base.py`의 `LLMProvider`, 프로바이더 메타데이터의 단일 진실 공급원 `registry.py`,
> 설정으로부터 실제 인스턴스를 만드는 `factory.py`, 그리고 실패 시 다른 모델로 넘어가는 `fallback_provider.py`를
> 라인 근거로 설명합니다.

## 이 문서의 소목차

1. [프로바이더 계층 전체 그림](#프로바이더-계층-전체-그림)
2. [공통 인터페이스: `base.py`의 `LLMProvider`](#공통-인터페이스-basepy의-llmprovider)
3. [`registry.py` — 프로바이더 메타데이터의 단일 진실](#registrypy--프로바이더-메타데이터의-단일-진실)
4. [`factory.py` — 설정에서 인스턴스 만들기](#factorypy--설정에서-인스턴스-만들기)
5. [`fallback_provider.py` — 폴백과 서킷 브레이커](#fallback_providerpy--폴백과-서킷-브레이커)
6. [구현체들](#구현체들)

---

## 프로바이더 계층 전체 그림

- `LLMProvider`(추상): `chat`/`chat_stream` 등을 정의. 재시도/타임아웃/에러 분류 공통 로직 포함.
- 각 구현체(`anthropic_provider.py` 등)가 실제 API 호출을 담당.
- `registry.py`의 `ProviderSpec`이 "이 프로바이더는 어떤 백엔드/키/기능을 쓰는가"를 선언.
- `factory.make_provider(config)`가 설정을 읽어 알맞은 구현체를 만들고, 폴백이 설정돼 있으면 `FallbackProvider`로 감쌈.
- [04](04_agent_loop.md)의 `AgentRunner`가 이 프로바이더를 호출.

---

## 공통 인터페이스: `base.py`의 `LLMProvider`

`nanobot/providers/base.py`의 `LLMProvider`(L193-) — 모든 프로바이더의 기반.

핵심 자료구조:
- `ToolCallRequest`(L48-) — LLM이 요청한 도구 호출 하나(이름/인자/id).
- `LLMResponse`(L150-) — 프로바이더 응답(내용/도구 호출/사용량/finish reason 등).
- `GenerationSettings`(L182-) — temperature/max_tokens/reasoning 등 생성 파라미터.

추상 메서드:
- `chat(...)`(L368-369, `@abstractmethod`) — 한 번의 (비스트리밍) 대화 요청.
- `chat_stream(...)`(L621-) — 스트리밍 대화(델타를 콜백으로 흘려보냄).

공통 재시도/에러 처리(구현체가 공유):
- `_CHAT_RETRY_DELAYS = (1, 2, 4)`(L198) — 지수적 재시도 간격(초).
- `_TRANSIENT_ERROR_MARKERS`(L202-217) — "429/500/timeout/overloaded/connection…" 등 **일시적 오류** 판별 문자열
  (중국어 메시지 "速率限制"까지 포함). 이런 오류는 재시도합니다.
- `_NON_RETRYABLE_429_ERROR_TOKENS`(L220-229) — "insufficient_quota/billing_hard_limit…" 등 **재시도 무의미**한 429
  (돈/쿼터 문제). 재시도하지 않습니다.
- `chat_with_retry`(L724-)/`chat_stream_with_retry`(L665-) — 위 규칙에 따라 재시도/하트비트 대기를 감싼 진입점.

**왜 base에 재시도를 모으나(설계 의도):** 어떤 프로바이더든 네트워크 오류/레이트리밋을 겪습니다. 공통 로직을
base에 두면 구현체는 "API 한 번 호출"만 신경 쓰면 되고, 재시도 정책을 한 곳에서 관리할 수 있습니다.
또한 "돈 문제(quota)"처럼 재시도해도 소용없는 오류를 구분해 불필요한 반복을 막습니다.

---

## `registry.py` — 프로바이더 메타데이터의 단일 진실

`nanobot/providers/registry.py`의 `ProviderSpec`은 프로바이더의 성격을 선언하는 데이터입니다:
- name, keywords(모델명 매칭용), env_key(API 키 환경변수), backend(어느 구현체를 쓸지),
- gateway/local/direct/oauth 여부, 기본 API base, 모델명 접두 제거 규칙, 프롬프트 캐싱 지원,
  thinking/reasoning 스타일, 전사(transcription) 전용 여부 등.

파일 상단 주석이 **새 프로바이더 추가 절차**를 명시합니다:
> "1. Add a ProviderSpec[(용어사전)](../dict/04_providers_and_llm.md#providerspec) to PROVIDERS below. 2. Add a field to ProvidersConfig in config/schema.py. Done."

**왜 단일 레지스트리인가(설계 의도):** 프로바이더별 특성이 코드 곳곳에 흩어지면 새 프로바이더 추가가 어렵습니다.
`ProviderSpec` 하나에 모아두면 "선언"만으로 대부분의 동작이 결정됩니다(데이터 주도 설계). `find_by_name`,
`create_dynamic_spec`(factory가 import, L11)로 조회/동적 생성합니다.

---

## `factory.py` — 설정에서 인스턴스 만들기

`nanobot/providers/factory.py`(L1 "Create LLM providers from config").

- `ProviderSnapshot`(L14-19): 만들어진 provider + model + context_window_tokens + signature를 묶은 불변 스냅샷.
  `signature`는 설정이 바뀌었는지 감지해 재생성 여부를 판단하는 데 쓰입니다([04](04_agent_loop.md)의 `_refresh_provider_snapshot`).
- `_make_provider_core(...)`: 모델 프리셋을 해석해 provider name/config/`ProviderSpec`을 얻고, 백엔드에 따라 구현체를 만듭니다:
  - `openai_codex` → `OpenAICodexProvider`
  - `azure_openai` → `AzureOpenAIProvider`
  - `github_copilot` → `GitHubCopilotProvider`
  - `anthropic` → `AnthropicProvider`
  - `bedrock` → `BedrockProvider`
  - 기본 → `openai_compat`(OpenAI 호환) provider
  API 키/base 검증과 생성 설정(temperature 등) 적용도 여기서 합니다.
- `make_provider(config, ...)`(L172 부근): `_make_provider_core`로 primary provider를 만든 뒤,
  fallback 프리셋이 있으면 `FallbackProvider(primary=..., fallback_presets=..., provider_factory=lambda fb: _make_provider_core(...))`로
  감쌉니다. 즉 **폴백 provider는 필요할 때 factory로 지연 생성**됩니다.
- `build_provider_snapshot(...)`: 폴백까지 고려해 **가장 작은 context window**를 스냅샷에 저장합니다.
  **왜?** primary와 fallback의 컨텍스트 한도가 다르면, 더 작은 쪽에 맞춰야 폴백해도 프롬프트가 안전합니다.

---

## `fallback_provider.py` — 폴백과 서킷 브레이커

`nanobot/providers/fallback_provider.py`의 `FallbackProvider`. primary 모델이 실패하면 대체 모델로 넘깁니다.

상수:
- `_PRIMARY_FAILURE_THRESHOLD = 3` — primary가 연속 3회 실패하면
- `_PRIMARY_COOLDOWN_S = 60` — 60초 동안 primary를 건너뛰고 곧장 fallback을 씀(**서킷 브레이커**).

폴백하는 오류(일시적/용량 문제): `timeout`, `connection`, `server_error`, `rate_limit`, `overloaded`.
폴백하지 **않는** 오류(넘어가도 소용없거나 넘기면 안 되는 것): `authentication`, `auth`, `permission`,
`content_filter`, `refusal`, `context_length`, `invalid_request`.

설계 요점:
- **요청 범위(request-scoped) 페일오버**: 한 요청 안에서 primary 실패 → fallback 시도.
- **이미 content가 스트리밍된 뒤에는 폴백하지 않음** — 사용자에게 중복 출력이 가는 것을 막기 위함.
  (단 타임아웃으로 스트림이 멈춘(stall) 경우는 새 세그먼트에서 복구 가능.)
- **서킷 브레이커**: primary가 계속 죽으면 매번 재시도해 지연시키지 않고, 잠시(60초) primary를 우회합니다.
- **재귀 페일오버 방지**: fallback이 또 fallback을 부르는 무한 연쇄를 막습니다.

**왜 이렇게 세밀한가:** 폴백은 "안정성"을 위한 것이지만, 아무 오류에나 폴백하면 (인증 오류처럼) 근본 문제를
숨기거나 (이미 출력된 내용 중복처럼) 사용자 경험을 해칩니다. 그래서 오류 종류를 분류해 **폴백해도 되는 것만** 넘깁니다.
배경은 [tech_background/05](tech_background/05_model_routing_fallback.md)를 보세요.

---

## 구현체들

`nanobot/providers/`의 실제 파일(확인됨):

| 파일 | 역할 |
| --- | --- |
| `openai_compat_provider.py` | OpenAI 호환 API(대부분의 서드파티 게이트웨이 포함) — 기본 백엔드. |
| `openai_responses/` | OpenAI Responses API 전용 구현(디렉토리). |
| `anthropic_provider.py` | Anthropic Claude. |
| `azure_openai_provider.py` | Azure OpenAI. |
| `bedrock_provider.py` | AWS Bedrock. |
| `github_copilot_provider.py` | GitHub Copilot(OAuth). |
| `openai_codex_provider.py` | OpenAI Codex(OAuth). |
| `image_generation.py` | 이미지 생성 프로바이더. |
| `transcription.py` | 오디오 전사(음성→텍스트). |
| `base.py` / `registry.py` / `factory.py` / `fallback_provider.py` | 위에서 설명한 공통/조립 계층. |

다음 문서에서는 이 프로바이더/도구/루프를 장기 실행으로 묶는 게이트웨이와 채널을 봅니다 → [10_gateway_and_channels.md](10_gateway_and_channels.md).
