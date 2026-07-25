# 사전 04. 프로바이더와 LLM 호출 (Providers & LLM Invocation)

> [Provider](01_core_architecture.md#provider) 계층과 LLM API 호출의 신뢰성에 관한 용어.
> 전체 색인은 [README](README.md), 노드 클래스 정의는 [00_content_classes.md](00_content_classes.md)를 보세요.
>
> 표기 규약: **상위 개념 = 이 개념을 기반(전제)으로 만들어진 파생 개념**, **하위 개념 = 이 개념을 규정하기 위해 필요한 기반/전제 개념**.

---

### Provider Base
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/providers/base.py`

모든 프로바이더가 상속하는 추상 클래스 — "메시지 + 도구 목록 → 응답/도구 호출"이라는 공통 계약을
정의합니다. 이 계약 덕에 상위 코드는 어느 벤더인지 신경 쓰지 않습니다.

- **하위 개념(기반·전제):** [Provider](01_core_architecture.md#provider)
- **상위 개념(이를 기반으로 파생):** [Anthropic Provider](#anthropic-provider),
  [OpenAI-Compatible Provider](#openai-compatible-provider), [FallbackProvider](#fallbackprovider)

### Provider Registry
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/providers/registry.py`

[ProviderSpec](#providerspec) 목록을 갖고 모델명/설정으로 프로바이더를 선택하는
[Registry Pattern](02_tools_and_skills.md#registry-pattern) 구현.

**예시:** 모델명이 `claude-`로 시작하면 Anthropic, `gpt-`면 OpenAI 계열 — 이 매칭 규칙이
레지스트리의 spec에 들어 있습니다.

- **하위 개념(기반·전제):** [Provider](01_core_architecture.md#provider),
  [Registry Pattern](02_tools_and_skills.md#registry-pattern)
- **상위 개념(이를 기반으로 파생):** [ProviderSpec](#providerspec)
- **관련 용어:** [Model Routing](08_ai_llm_concepts.md#model-routing)

### ProviderSpec
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/providers/registry.py`

프로바이더 하나의 명세(이름, 모델 접두 패턴, 팩토리, 필요 [Optional Dependencies](09_dev_stack.md#optional-dependencies)).
선언적 데이터로 두어, 새 프로바이더 추가가 "spec 하나 추가"로 끝나게 합니다.

- **하위 개념(기반·전제):** [Provider Registry](#provider-registry)

### Provider Factory
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/providers/factory.py`

[Config](01_core_architecture.md#config)를 읽어 실제 프로바이더 인스턴스를 조립하는 팩토리.
폴백 설정이 있으면 [FallbackProvider](#fallbackprovider)로 감쌉니다 — "무엇을 만들지"를 설정이
결정하고 코드는 조립만 하는 구조입니다.

- **하위 개념(기반·전제):** [Provider](01_core_architecture.md#provider)

### FallbackProvider
**클래스:** [Component](00_content_classes.md#component) · **한글:** 폴백 프로바이더 · **코드:** `nanobot/providers/fallback_provider.py`

여러 프로바이더를 순서대로 시도하는 합성 프로바이더 — 그 자체가
[Provider Base](#provider-base) 인터페이스를 구현해 어디든 일반 프로바이더처럼 꽂힙니다
(Composite 패턴). 내부에 [Retry](#retry)와 [Circuit Breaker](#circuit-breaker)를 결합해
[Graceful Degradation](#graceful-degradation)을 실현합니다.

**예시:** Anthropic 장애 시: claude 호출 실패 → [Exponential Backoff](#exponential-backoff) 재시도 →
계속 실패하면 서킷 열고 다음 순번인 OpenAI로 폴백 → 사용자는 답을 계속 받습니다.

- **하위 개념(기반·전제):** [Provider Base](#provider-base),
  [Model Routing](08_ai_llm_concepts.md#model-routing), [Graceful Degradation](#graceful-degradation)
- **상위 개념(이를 기반으로 파생):** [Circuit Breaker](#circuit-breaker), [Retry](#retry)

### Graceful Degradation
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 우아한 성능 저하

일부 구성요소가 실패해도 시스템 전체가 죽지 않고 **품질을 낮춰서라도 계속 동작**하게 하는 신뢰성
원칙. "최고의 답" 대신 "차선의 답"을, "차선"도 안 되면 "정직한 오류 메시지"를 반환합니다.

**예시:** [FallbackProvider](#fallbackprovider)가 1순위 모델 장애 시 2순위 모델로 답하는 것.

- **상위 개념(이를 기반으로 파생):** [FallbackProvider](#fallbackprovider)
- **관련 용어:** [Defense in Depth](07_security_isolation.md#defense-in-depth)

### Circuit Breaker
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 서킷 브레이커

연속 실패한 대상을 일정 시간 **차단(open)** 해 불필요한 재시도와 연쇄 장애를 막는 신뢰성 패턴
(전기 차단기의 비유; Michael Nygard, *Release It!*). 상태는 Closed(정상) → Open(차단) →
Half-open(시험 복귀)으로 도는 [State Machine](01_core_architecture.md#state-machine)입니다.

**예시:** 어떤 프로바이더가 5번 연속 실패하면 60초간 아예 호출하지 않고 다음 후보로 직행 —
죽은 서버를 계속 두드리며 시간을 낭비하지 않습니다.

- **하위 개념(기반·전제):** [FallbackProvider](#fallbackprovider),
  [State Machine](01_core_architecture.md#state-machine)
- **관련 용어:** [Transient Error](#transient-error)

### Retry
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 재시도

[Transient Error](#transient-error)에 한해 같은 요청을 다시 보내는 것. 4xx 같은 영구 오류를
재시도하는 것은 낭비이므로, "무엇이 일시적인가"의 판별이 핵심입니다.

- **하위 개념(기반·전제):** [FallbackProvider](#fallbackprovider)
- **상위 개념(이를 기반으로 파생):** [Exponential Backoff](#exponential-backoff)
- **관련 용어:** [Rate Limit](#rate-limit)

### Exponential Backoff
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 지수 백오프

재시도 간격을 1초 → 2초 → 4초 → 8초처럼 지수적으로 늘리는 [Retry](#retry) 전략. 과부하 서버에
일제히 재돌진해 장애를 악화시키는 "재시도 폭풍(retry storm)"을 막습니다. 실제 구현은 여기에 무작위
지터(jitter)를 더해 클라이언트들의 재시도 시점을 흩뜨립니다.

- **하위 개념(기반·전제):** [Retry](#retry)

### Transient Error
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 일시적 오류

시간이 지나면 스스로 해소될 수 있는 오류 — 재시도할 가치가 있는 것들.

**예시:** 재시도 대상: 429([Rate Limit](#rate-limit)), 500/502/503, 네트워크 타임아웃.
재시도 무의미: 401(인증 오류), 400(요청 자체가 잘못됨).

- **관련 용어:** [Retry](#retry), [Circuit Breaker](#circuit-breaker)

### Rate Limit
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 요청 한도

API 제공자가 정한 시간당 요청/토큰 상한. 초과 시 HTTP 429가 반환되며, 응답의 `retry-after`를
존중해 기다렸다 재시도하는 것이 예의이자 정석입니다.

- **관련 용어:** [Transient Error](#transient-error),
  [Exponential Backoff](#exponential-backoff)

### Streaming
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 스트리밍

응답이 완성되기를 기다리지 않고 [Delta](#delta)(조각) 단위로 받는 방식. 첫 글자까지의 체감 지연을
크게 줄입니다 — 30초 걸릴 답변도 1초 만에 "쓰기 시작"하는 것처럼 보입니다. 전송 계층으로는 주로
[SSE](08_ai_llm_concepts.md#sse)가 쓰입니다.

- **상위 개념(이를 기반으로 파생):** [Delta](#delta)
- **관련 용어:** [WebSocket Channel](05_channels_gateway_ui.md#websocket-channel)

### Delta
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 델타(증분)

[Streaming](#streaming)에서 도착하는 응답의 증분 조각. 텍스트 델타, 도구 호출 인자 델타 등이 있고,
[AgentRunner](01_core_architecture.md#agentrunner)가 이들을 모아 완전한 메시지로 조립합니다.

- **하위 개념(기반·전제):** [Streaming](#streaming)

### Reasoning Blocks
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 추론 블록

일부 모델이 최종 답변과 별도로 출력하는 "생각 과정" 콘텐츠(Claude extended thinking 등).
프로바이더가 이를 인식해 표시/보존 여부를 처리해야 합니다.

- **관련 용어:** [Streaming](#streaming),
  [Chain-of-Thought](08_ai_llm_concepts.md#chain-of-thought)

### Sampling
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 샘플링

[LLM](08_ai_llm_concepts.md#llm)이 다음 [Token](08_ai_llm_concepts.md#token)을 고를 때 확률분포에서
**추첨하는** 과정. 같은 질문에 다른 답이 나오는 이유가 이것입니다. 추첨의 성격을 조절하는 손잡이가
[Temperature](#temperature), top-p(누적 확률 상위만 후보로 남김) 등입니다.

- **상위 개념(이를 기반으로 파생):** [Temperature](#temperature)

### Temperature
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 온도

[Sampling](#sampling) 무작위성 조절 파라미터. 0에 가까우면 가장 확률 높은 토큰만 골라 결정적이고,
높을수록(1~2) 다양하고 창의적이지만 불안정합니다.

**예시:** 코드 생성·사실 답변은 0~0.3, 브레인스토밍·창작은 0.8~1.2가 관례적 선택입니다.
nanobot에서는 [Model Preset](01_core_architecture.md#model-preset)으로 용도별 지정이 가능합니다.

- **하위 개념(기반·전제):** [Sampling](#sampling)

### max_tokens
**클래스:** [Concept](00_content_classes.md#concept)

한 응답이 생성할 수 있는 최대 [Token](08_ai_llm_concepts.md#token) 수. 이 예약분만큼
[Input Budget](03_memory_context_session.md#input-budget)이 줄어듭니다 — 출력 자리를 미리 비워 두는
좌석 예약 개념입니다.

- **관련 용어:** [Context Window](08_ai_llm_concepts.md#context-window)

### Prompt Caching
**클래스:** [Mechanism](00_content_classes.md#mechanism) · **한글:** 프롬프트 캐싱

요청 간 **동일한 프롬프트 앞부분(prefix)** 의 처리 결과를 API 서버가 재사용해 비용·지연을 줄이는
기능(Anthropic 기준 캐시 적중분 비용 ~1/10). "앞부분이 완전히 같아야" 적중하므로, nanobot은 매 턴
바뀌는 정보([Runtime Context](03_memory_context_session.md#runtime-context))를 프롬프트 뒤쪽에
배치합니다.

- **관련 용어:** [System Prompt](03_memory_context_session.md#system-prompt)

### Anthropic Provider
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/providers/anthropic_provider.py`

Claude 모델용 프로바이더. Anthropic Messages API 특유의 형식(별도 system 파라미터, content block
배열)을 공통 인터페이스로 변환합니다.

- **하위 개념(기반·전제):** [Provider Base](#provider-base)

### OpenAI-Compatible Provider
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/providers/openai_compat_provider.py`

[OpenAI-Compatible API](05_channels_gateway_ui.md#openai-compatible-api)(Chat Completions 규격)를
말하는 모든 백엔드용 프로바이더 — OpenAI 본가는 물론 OpenRouter, Ollama(로컬), vLLM 등
"사실상 표준"을 따르는 서버 전부에 재사용됩니다. base URL만 바꾸면 됩니다.

- **하위 개념(기반·전제):** [Provider Base](#provider-base)

### OpenAI Responses Provider
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/providers/openai_responses/`

OpenAI의 신형 Responses API(Chat Completions의 후속 규격)용 프로바이더.

- **하위 개념(기반·전제):** [Provider Base](#provider-base)

### Azure OpenAI Provider
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/providers/azure_openai_provider.py`

Azure에 배포된 OpenAI 모델용 프로바이더(배포 이름, API 버전 등 Azure 특유 설정 처리).
`azure` [Optional Dependencies](09_dev_stack.md#optional-dependencies)로 설치됩니다.

- **하위 개념(기반·전제):** [Provider Base](#provider-base)

### Bedrock Provider
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/providers/bedrock_provider.py`

AWS Bedrock을 통해 모델을 호출하는 프로바이더 — API 키 대신 AWS 자격증명(IAM) 체계를 씁니다.

- **하위 개념(기반·전제):** [Provider Base](#provider-base)

### GitHub Copilot Provider
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/providers/github_copilot_provider.py`

GitHub Copilot 구독의 모델 접근권을 사용하는 프로바이더. 디바이스 플로우 OAuth 로그인을 지원합니다.

- **하위 개념(기반·전제):** [Provider Base](#provider-base)

### OpenAI Codex Provider
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/providers/openai_codex_provider.py`

ChatGPT 구독(Codex) 백엔드를 사용하는 프로바이더.

- **하위 개념(기반·전제):** [Provider Base](#provider-base)

### Image Generation Provider
**클래스:** [Component](00_content_classes.md#component) · **코드:** `nanobot/providers/image_generation.py`

텍스트→이미지 생성 백엔드의 추상화.
[Image Generation Tool](02_tools_and_skills.md#image-generation-tool)이 사용합니다.

- **하위 개념(기반·전제):** [Provider](01_core_architecture.md#provider)

### Transcription
**클래스:** [Component](00_content_classes.md#component) · **한글:** 음성 전사 · **코드:** `nanobot/providers/transcription.py`, `nanobot/audio/`

음성 메시지를 텍스트로 변환(STT)하는 계층. 음성 채널 메시지가 텍스트 파이프라인에 합류할 수 있게
합니다.

- **하위 개념(기반·전제):** [Provider](01_core_architecture.md#provider)
