# 사전 04. 프로바이더와 LLM 호출 (Providers & LLM Invocation)

> [Provider](01_core_architecture.md#provider) 계층의 세부 용어: 백엔드 구현체, 폴백/재시도, 스트리밍.
> 전체 색인은 [README](README.md)를 보세요.

---

### Provider Base
**분류:** 프로바이더 · **코드:** `nanobot/providers/base.py`

모든 [Provider](01_core_architecture.md#provider) 구현의 공통 부모. 채팅 호출 인터페이스와
[Retry](#retry) 로직(`_CHAT_RETRY_DELAYS = (1, 2, 4)`, [Transient Error](#transient-error) 마커)을 제공합니다.

- **상위 개념:** [Provider](01_core_architecture.md#provider)
- **하위 개념:** [Retry](#retry)

### Provider Registry
**한글:** 프로바이더 레지스트리 · **분류:** 프로바이더 · **코드:** `nanobot/providers/registry.py`

각 프로바이더의 특성(키워드, API 키 env, 백엔드, 기본 base URL)을 [ProviderSpec](#providerspec)
데이터로 선언한 목록. 새 프로바이더 추가가 "Spec 추가 + config 필드 추가"로 끝나는
**데이터 주도 설계**입니다.

- **상위 개념:** [Provider](01_core_architecture.md#provider)
- **하위 개념:** [ProviderSpec](#providerspec)
- **관련 용어:** [Provider Factory](#provider-factory)

### ProviderSpec
**분류:** 프로바이더 · **코드:** `nanobot/providers/registry.py`

프로바이더 하나의 선언적 명세(이름 매칭 키워드, 환경변수, 기본값). `find_by_name`으로 조회하고
`create_dynamic_spec`으로 동적 생성합니다.

- **상위 개념:** [Provider Registry](#provider-registry)

### Provider Factory
**한글:** 프로바이더 팩토리 · **분류:** 프로바이더 · **코드:** `nanobot/providers/factory.py`

[Config](01_core_architecture.md#config)와 [Provider Registry](#provider-registry)를 보고
알맞은 프로바이더 인스턴스를 생성하는 곳. [FallbackProvider](#fallbackprovider)로 감싸는 것도 여기서 합니다.

- **상위 개념:** [Provider](01_core_architecture.md#provider)

### FallbackProvider
**한글:** 폴백 프로바이더 · **분류:** 프로바이더 · **코드:** `nanobot/providers/fallback_provider.py`

primary 모델 실패 시 대체 모델로 넘기는 래퍼. [Transient Error](#transient-error)만 폴백하고
(인증/정책/[Context Window](08_ai_llm_concepts.md#context-window) 초과는 폴백 금지),
[Circuit Breaker](#circuit-breaker)와 [Streaming](#streaming) 안전장치(내용이 나간 뒤 폴백 금지)를 갖췄습니다.

- **상위 개념:** [Provider](01_core_architecture.md#provider),
  [Model Routing](08_ai_llm_concepts.md#model-routing)
- **하위 개념:** [Circuit Breaker](#circuit-breaker)

### Circuit Breaker
**한글:** 서킷 브레이커 · **분류:** 신뢰성 패턴

연속 실패가 임계치(nanobot: 3회)를 넘으면 일정 시간(60초) 해당 백엔드를 **시도조차 하지 않는** 패턴
(Nygard, *Release It!*). 죽은 서버에 매번 타임아웃을 기다리는 것 자체가 장애이기 때문입니다.

- **상위 개념:** [FallbackProvider](#fallbackprovider)
- **관련 용어:** [Retry](#retry), [Exponential Backoff](#exponential-backoff)

### Retry
**한글:** 재시도 · **분류:** 신뢰성 패턴

같은 백엔드에 잠시 후 다시 시도하는 것. 폴백(다른 모델)보다 먼저 적용됩니다.
nanobot은 [Exponential Backoff](#exponential-backoff)(1→2→4초)를 씁니다.

- **상위 개념:** [Provider Base](#provider-base)
- **관련 용어:** [Transient Error](#transient-error)

### Exponential Backoff
**한글:** 지수 백오프 · **분류:** 신뢰성 패턴

재시도 간격을 지수적으로(1, 2, 4초…) 늘리는 기법. 과부하 서버에 재시도가 몰리는
재시도 폭풍(retry storm)을 막습니다.

- **상위 개념:** [Retry](#retry)

### Transient Error
**한글:** 일시적 오류 · **분류:** 신뢰성 패턴

잠시 후/다른 곳에서 성공할 수 있는 오류: [Rate Limit](#rate-limit), 5xx 서버 오류, 타임아웃, 연결 오류.
반대는 결정적 오류(401/403 인증, 400 잘못된 요청, content filter) — 이건 재시도/폴백해도 소용없습니다.
이 분류가 [FallbackProvider](#fallbackprovider) 정책의 근간입니다.

- **관련 용어:** [Retry](#retry), [FallbackProvider](#fallbackprovider)

### Rate Limit
**한글:** 레이트리밋 (HTTP 429) · **분류:** 신뢰성 패턴

시간당 요청/토큰 한도를 넘었을 때 API가 돌려주는 오류. 대부분 [Transient Error](#transient-error)지만,
"결제 한도 초과" 같은 재시도 불가 429는 nanobot이 별도 토큰으로 구분합니다.

- **상위 개념:** [Transient Error](#transient-error)

### Streaming
**한글:** 스트리밍 · **분류:** LLM 호출

응답을 완성까지 기다리지 않고 [Delta](#delta) 단위로 받아 즉시 표시하는 방식.
체감 지연을 크게 줄이지만, 도중 실패 시 폴백이 까다로워집니다(이미 나간 내용과 중복 위험).

- **하위 개념:** [Delta](#delta)
- **관련 용어:** [SSE](08_ai_llm_concepts.md#sse), [FallbackProvider](#fallbackprovider)

### Delta
**한글:** 델타 · **분류:** LLM 호출

[Streaming](#streaming)에서 한 번에 도착하는 증분 조각(텍스트 몇 글자, 도구 호출 인자 일부).
[AgentRunner](01_core_architecture.md#agentrunner)가 이를 모아 완전한 응답/도구 호출로 조립합니다.

- **상위 개념:** [Streaming](#streaming)

### Reasoning Blocks
**한글:** 추론 블록(thinking) · **분류:** LLM 호출

모델이 최종 답 이전에 생성하는 내부 사고 과정(chain-of-thought). 일부 모델(Claude 확장 사고,
DeepSeek-R1 등)이 노출하며, nanobot은 이를 응답 본문과 분리해 UI 표시/이력 저장을 다르게 처리합니다.

- **관련 용어:** [Streaming](#streaming), [Prompt](08_ai_llm_concepts.md#prompt)

### Temperature
**한글:** 온도 · **분류:** LLM 호출

생성의 무작위성을 조절하는 샘플링 파라미터(0=결정적, 높을수록 다양).
[Model Preset](01_core_architecture.md#model-preset)으로 용도별 설정이 가능합니다.

- **관련 용어:** [max_tokens](#max_tokens)

### max_tokens
**분류:** LLM 호출

한 응답이 생성할 수 있는 최대 [Token](08_ai_llm_concepts.md#token) 수.
[Input Budget](03_memory_context_session.md#input-budget) 계산에서 미리 빼 두는 값입니다.

- **관련 용어:** [Context Window](08_ai_llm_concepts.md#context-window)

### Prompt Caching
**한글:** 프롬프트 캐시 · **분류:** LLM 호출

이전 요청과 앞부분(prefix)이 같으면 그 부분의 계산을 재사용해 비용/지연을 줄이는 프로바이더 기능.
nanobot은 매 턴 바뀌는 [Runtime Context](03_memory_context_session.md#runtime-context)를 뒤에 붙여
prefix를 안정시킵니다.

- **관련 용어:** [Context](03_memory_context_session.md#context)

### Anthropic Provider
**분류:** 프로바이더 구현 · **코드:** `nanobot/providers/anthropic_provider.py`

Anthropic SDK로 Claude 모델을 호출하는 구현체. 확장 사고([Reasoning Blocks](#reasoning-blocks)) 등
Anthropic 고유 기능을 처리합니다.

- **상위 개념:** [Provider Base](#provider-base)

### OpenAI-Compatible Provider
**분류:** 프로바이더 구현 · **코드:** `nanobot/providers/openai_compat_provider.py`

OpenAI Chat Completions API 형식을 따르는 모든 백엔드(OpenAI, OpenRouter, 로컬 vLLM/Ollama 등)를
커버하는 범용 구현체. "OpenAI 호환"이 사실상 업계 표준 와이어 형식이 된 덕분에 하나로 여럿을 지원합니다.

- **상위 개념:** [Provider Base](#provider-base)
- **관련 용어:** [OpenAI-Compatible API](05_channels_gateway_ui.md#openai-compatible-api)

### OpenAI Responses Provider
**분류:** 프로바이더 구현 · **코드:** `nanobot/providers/openai_responses/`

OpenAI의 신형 **Responses API**(Chat Completions의 후속, 상태 유지형)를 쓰는 구현체.

- **상위 개념:** [Provider Base](#provider-base)

### Azure OpenAI Provider
**분류:** 프로바이더 구현 · **코드:** `nanobot/providers/azure_openai_provider.py`

Microsoft Azure에 배포된 OpenAI 모델용 구현체(엔드포인트/인증 방식이 Azure 방식).

- **상위 개념:** [Provider Base](#provider-base)

### Bedrock Provider
**분류:** 프로바이더 구현 · **코드:** `nanobot/providers/bedrock_provider.py`

AWS Bedrock(여러 모델을 AWS 인증으로 쓰는 관리형 서비스)용 구현체.

- **상위 개념:** [Provider Base](#provider-base)

### GitHub Copilot Provider
**분류:** 프로바이더 구현 · **코드:** `nanobot/providers/github_copilot_provider.py`

GitHub Copilot 구독의 모델 접근권을 이용하는 구현체.

- **상위 개념:** [Provider Base](#provider-base)

### OpenAI Codex Provider
**분류:** 프로바이더 구현 · **코드:** `nanobot/providers/openai_codex_provider.py`

OpenAI Codex(코딩 특화) 계정 경로로 모델을 쓰는 구현체.

- **상위 개념:** [Provider Base](#provider-base)

### Image Generation Provider
**한글:** 이미지 생성 프로바이더 · **분류:** 프로바이더 구현 · **코드:** `nanobot/providers/image_generation.py`

텍스트→이미지 생성 백엔드 추상화.
[Image Generation Tool](02_tools_and_skills.md#image-generation-tool)이 사용합니다.

- **상위 개념:** [Provider](01_core_architecture.md#provider)

### Transcription
**한글:** 음성 전사 · **분류:** 프로바이더 구현 · **코드:** `nanobot/providers/transcription.py`, `nanobot/audio/`

음성 메시지를 텍스트로 변환하는 추상화. 음성 지원 [Channel](01_core_architecture.md#channel)
(Telegram 보이스 등)이 사용합니다.

- **상위 개념:** [Provider](01_core_architecture.md#provider)
