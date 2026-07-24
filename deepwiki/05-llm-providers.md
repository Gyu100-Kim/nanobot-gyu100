# 5. LLM Providers (LLM 프로바이더)

프로바이더는 nanobot이 다양한 LLM 백엔드와 통신하는 추상화 계층이다. `nanobot/providers/` 아래에 구현되며, 공통 베이스 `LLMProvider`(`base.py`)를 따른다.

## 계층 구조

```
LLMProvider (ABC)                nanobot/providers/base.py
├── OpenAICompatProvider         openai_compat_provider.py  (대부분의 호스팅/로컬)
├── AnthropicProvider            anthropic_provider.py
├── AzureOpenAIProvider          azure_openai_provider.py
├── BedrockProvider              bedrock_provider.py
├── OpenAICodexProvider          openai_codex_provider.py   (OAuth)
├── GithubCopilotProvider        github_copilot_provider.py (OAuth)
└── FallbackProvider             fallback_provider.py       (다른 프로바이더를 감쌈)
```

`base.py`의 responses API 지원 코드는 `openai_responses/` 서브패키지에 있다.

## 인스턴스화

- 메타데이터 단일 출처: `nanobot/providers/registry.py`의 `PROVIDERS`([2.2](02.2-providers-and-model-presets.md)).
- 팩토리: `nanobot/providers/factory.py`의 `make_provider(...)`가 설정과 프리셋으로 적절한 백엔드를 고른다. `ProviderSpec.backend`가 `openai_compat|anthropic|azure_openai|openai_codex|github_copilot|bedrock` 중 어느 구현을 쓸지 결정한다.
- 스냅샷/시그니처: `build_provider_snapshot`, `provider_signature`로 설정 변경 시 재생성 여부를 판단.

## 공통 계약 (`base.py`)

`LLMProvider`는 [3.2](03.2-agent-runner-and-llm-provider-interface.md)에서 다룬 대로 `chat`, `chat_stream`, `chat_with_retry`, `chat_stream_with_retry`, `get_default_model`을 정의한다. 재시도/백오프, 429·일시 오류 처리, `Retry-After` 파싱, role 교대 강제, 이미지 콘텐츠 스트립 등이 베이스에 공통 구현되어 있다.

## 부가 프로바이더

- **이미지 생성**: `nanobot/providers/image_generation.py` — `ImageGenerationProvider(ABC)`와 OpenRouter/AiHubMix/Ollama/Gemini/MiniMax 클라이언트([6.3](06.3-cron-image-generation-and-other-tools.md)).
- **음성 전사**: `nanobot/providers/transcription.py` — AssemblyAI/OpenAI/Groq/OpenRouter/Xiaomi MiMo/StepFun 전사 프로바이더([7](07-channels.md), 채널의 `transcribe_audio`).

## 하위 문서

- [5.1 OpenAI-Compatible Provider](05.1-openai-compatible-provider.md)
- [5.2 Anthropic, Azure, Bedrock, and Specialized Providers](05.2-anthropic-azure-bedrock-and-specialized-providers.md)

### 참조 파일

- `nanobot/providers/base.py`, `factory.py`, `registry.py`
- `nanobot/providers/openai_compat_provider.py`, `anthropic_provider.py`
- `nanobot/providers/image_generation.py`, `transcription.py`
- `docs/providers.md`, `docs/provider-cookbook.md`
