# 사전 08. AI/LLM 일반 개념 (General AI/LLM Concepts)

> nanobot의 배경이 되는 AI/LLM 일반 개념. nanobot에 직접 구현되지 않은 개념은 본문에 그렇게
> 명시합니다. 심화 내용은 [STUDY_NOTES/tech_background/](../STUDY_NOTES/tech_background/)를 보세요.
> 전체 색인은 [README](README.md), 노드 클래스 정의는 [00_content_classes.md](00_content_classes.md)를 보세요.
>
> 표기 규약: **상위 개념 = 이 개념을 기반(전제)으로 만들어진 파생 개념**, **하위 개념 = 이 개념을 규정하기 위해 필요한 기반/전제 개념**.

---

### LLM
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 대형 언어 모델 (Large Language Model) · **등장:** 2018~2020년경 (GPT/BERT→GPT-3)

방대한 텍스트로 훈련되어 "지금까지의 텍스트 다음에 올 [Token](#token)"의 확률을 계산하는 신경망 —
현대 모델은 대부분 [Transformer](#transformer) 구조입니다. 이 단순한 능력(다음 토큰 예측)에서
대화, 코딩, 추론이 창발합니다. nanobot에서는 [Provider](01_core_architecture.md#provider) 뒤의
두뇌입니다.

**예시:** GPT-4o, Claude(Anthropic), Gemini, Llama — 모두 LLM이라는 일반 개념의 특수한 사례입니다.

- **상위 개념(이를 기반으로 파생):** [Tool Calling](#tool-calling)
- **하위 개념(기반·전제):** [Transformer](#transformer)
- **관련 용어:** [Prompt](#prompt), [Sampling](04_providers_and_llm.md#sampling)

### Transformer
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 트랜스포머 · **등장:** 2017-06 (Vaswani et al.)

논문 *Attention Is All You Need*(Vaswani et al., 2017)가 제안한 신경망 구조로, 현대
[LLM](#llm)의 사실상 유일한 토대. 먼저 존재하던 [Attention](#attention) /
[Self-Attention](#self-attention) 개념을 **기반으로 활용해** 만들어진 파생 개념입니다 —
논문 제목부터가 "Attention is all you need". 문장 안의 모든 단어 쌍의 관련도를 병렬로 계산해,
순서대로만 읽던 이전 구조(RNN)의 한계를 넘었습니다.
(nanobot은 모델을 API로 쓰므로 트랜스포머를 직접 구현하지 않습니다.)

**예시:** Transformer를 활용한 파생 모델로 [BERT](#bert)(인코더 활용), GPT(디코더 활용)가
있습니다 — 이 예시들이 Transformer의 상위 개념입니다.

- **상위 개념(이를 기반으로 파생):** [LLM](#llm), [BERT](#bert)
- **하위 개념(기반·전제):** [Attention](#attention), [Self-Attention](#self-attention)

### Attention
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 어텐션 · **등장:** 2014-09 (Bahdanau et al.)

신경망이 입력의 여러 부분 중 "지금 중요한 곳"에 가중치를 두고 주목하게 하는 메커니즘 —
신경망 번역에서 긴 문장 성능을 올리기 위해 처음 제안되었습니다(Bahdanau et al., 2014).
[Transformer](#transformer)보다 **먼저 등장한 기반 개념**이며, Transformer는 이를 활용해
만들어진 파생(상위) 개념입니다.

- **상위 개념(이를 기반으로 파생):** [Self-Attention](#self-attention),
  [Transformer](#transformer)

### Self-Attention
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 셀프 어텐션 · **등장:** 2016~2017 (intra-attention → Transformer)

[Attention](#attention)의 파생 — 입력이 **자기 자신에게** 어텐션을 적용해, 각
[Token](#token)이 같은 문장의 다른 모든 토큰을 "얼마나 주목할지" 계산합니다.
[Transformer](#transformer)는 이 연산을 핵심 재료로 사용합니다. 계산량이 토큰 수의 제곱에
비례하기 때문에 [Context Window](#context-window)에 상한이 생기고, 그래서
[Context Compression](#context-compression)이 필요해집니다.

- **상위 개념(이를 기반으로 파생):** [Transformer](#transformer)
- **하위 개념(기반·전제):** [Attention](#attention)
- **관련 용어:** [Lost in the Middle](#lost-in-the-middle)

### BERT
**클래스:** [Research](00_content_classes.md#research) · **등장:** 2018-10 (Devlin et al.)

[Transformer](#transformer)의 **인코더**를 활용해 만든 양방향 언어 이해 모델(Google).
"Transformer를 활용한 예시"의 대표 — 즉 Transformer라는 기반 개념 위에 세워진 상위(파생)
개념입니다. 문장 분류·검색 임베딩 등 이해(understanding) 계열 과제의 표준이 되었고, 생성 계열의
GPT(디코더 활용)와 함께 [LLM](#llm) 시대를 열었습니다.
(nanobot과 직접 관련은 없는 일반 개념입니다.)

- **하위 개념(기반·전제):** [Transformer](#transformer)
- **관련 용어:** [Embedding](#embedding), [LLM](#llm)

### Prompt
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 프롬프트 · **등장:** 2018~2020년경 (GPT 계열 보급과 함께)

[LLM](#llm)에 주는 입력 텍스트 전체. 모델의 행동을 바꾸는 유일한 손잡이가 프롬프트이므로,
"무엇을 어떻게 써 넣을까"가 하나의 기술([Prompt Engineering](#prompt-engineering))이 됩니다.

**예시:** 같은 질문도 "간결하게 답해줘"를 앞에 붙이면 답이 짧아집니다 — 프롬프트가 곧
프로그래밍인 셈입니다. [System Prompt](03_memory_context_session.md#system-prompt)는 프롬프트의
더 특수한 형태(최상단 규칙 지시문)입니다.

- **상위 개념(이를 기반으로 파생):** [System Prompt](03_memory_context_session.md#system-prompt),
  [Context](03_memory_context_session.md#context), [Few-shot Learning](#few-shot-learning),
  [Chain-of-Thought](#chain-of-thought)
- **관련 용어:** [Prompt Engineering](#prompt-engineering), [Token](#token)

### Prompt Engineering
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 프롬프트 엔지니어링

원하는 출력을 얻도록 [Prompt](#prompt)를 설계·개선하는 실무 기법. 역할 부여("너는 사서다"),
형식 지정("JSON으로"), 예시 제공([Few-shot Learning](#few-shot-learning)), 단계적 사고 유도
([Chain-of-Thought](#chain-of-thought))가 대표 기법입니다. nanobot의
`nanobot/templates/`가 프롬프트 엔지니어링의 산물입니다.

- **상위 개념(이를 기반으로 파생):** [Few-shot Learning](#few-shot-learning),
  [Chain-of-Thought](#chain-of-thought)
- **관련 용어:** [System Prompt](03_memory_context_session.md#system-prompt)

### Token
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 토큰

[LLM](#llm)이 텍스트를 처리하는 최소 단위 — 단어보다 작을 수 있는 조각입니다. 비용, 속도,
[Context Window](#context-window)가 모두 토큰 단위로 계산되므로 에이전트 설계의 "화폐"입니다.

**예시:** "internationalization"은 [BPE](#bpe) 기준 5~6개 토큰, 한국어는 영어보다 글자당 토큰이
많이 드는 경향이 있습니다.

- **상위 개념(이를 기반으로 파생):** [BPE](#bpe), [Tokenizer](#tokenizer)
- **관련 용어:** [Input Budget](03_memory_context_session.md#input-budget)

### Tokenizer
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 토크나이저

텍스트 ↔ [Token](#token) 열 변환기. 모델마다 어휘와 분절 규칙이 달라, 같은 문장도 모델에 따라
토큰 수가 다릅니다.

**예시:** [tiktoken](#tiktoken)은 OpenAI 계열 토크나이저의 구현이며, nanobot이 토큰 수 추정에
사용합니다.

- **하위 개념(기반·전제):** [Token](#token)
- **상위 개념(이를 기반으로 파생):** [tiktoken](#tiktoken), [BPE](#bpe)

### BPE
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 바이트 쌍 인코딩 (Byte Pair Encoding) · **등장:** 1994 (Gage; NLP 적용 2015 Sennrich et al.)

자주 함께 등장하는 문자 쌍을 반복 병합해 어휘를 만드는 [Tokenizer](#tokenizer) 알고리즘
(Sennrich et al., 2016에서 신경망 번역에 도입). 희귀 단어도 조각으로 분해해 표현할 수 있어
"모르는 단어" 문제가 사라집니다.

- **하위 개념(기반·전제):** [Tokenizer](#tokenizer), [Token](#token)
- **상위 개념(이를 기반으로 파생):** [tiktoken](#tiktoken)

### tiktoken
**클래스:** [Technology](00_content_classes.md#technology) · **PyPI:** `tiktoken` · **등장:** 2022-12

OpenAI의 [BPE](#bpe) 토크나이저 구현(Rust 코어라 빠름). nanobot은
[Input Budget](03_memory_context_session.md#input-budget) 계산과
[AutoCompact](03_memory_context_session.md#autocompact) 임계 판정 등 토큰 수 추정에 사용합니다.

- **하위 개념(기반·전제):** [BPE](#bpe), [Tokenizer](#tokenizer)

### Context Window
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 컨텍스트 윈도우

모델이 한 번에 볼 수 있는 [Token](#token) 수의 상한 — 모델의 "작업 기억" 크기.
[Self-Attention](#self-attention)의 제곱 비용이 근본 원인입니다. 이 유한함이
[Context Compression](#context-compression), [Memory](03_memory_context_session.md#memory),
[Progressive Disclosure](02_tools_and_skills.md#progressive-disclosure) 등 이 사전의 많은 장치를
낳았습니다.

**예시:** 창이 200K 토큰이면 대략 소설 한 권 분량 — 그 너머의 대화는 요약하거나 버려야 합니다.

- **관련 용어:** [Input Budget](03_memory_context_session.md#input-budget),
  [max_tokens](04_providers_and_llm.md#max_tokens)

### Hallucination
**클래스:** [Threat](00_content_classes.md#threat) · **한글:** 환각

모델이 사실이 아닌 내용을 그럴듯하게 생성하는 현상. 모델은 "가장 그럴듯한 다음
[Token](#token)"을 고를 뿐 진위를 검증하지 않기 때문에 구조적으로 발생합니다.

**예시:** 존재하지 않는 논문 제목을 지어내거나, "파일을 정리했다"고 말만 하는 경우.
nanobot의 [Dream](03_memory_context_session.md#dream)이 [Git](09_dev_stack.md#git) diff 검증으로
커서를 전진시키는 것이 후자에 대한 방어입니다.

- **관련 용어:** [Grounding](#grounding), [RAG](#rag)

### Grounding
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 근거 기반화

모델의 출력을 **검증 가능한 외부 근거**(문서, 도구 실행 결과, DB)에 묶는 것 —
[Hallucination](#hallucination)의 해독제입니다.

**예시:** [Tool Calling](#tool-calling)으로 실제 파일을 읽고 답하게 하는 것(nanobot의 방식),
[RAG](#rag)로 검색된 문서를 근거로 붙이는 것.

- **상위 개념(이를 기반으로 파생):** [RAG](#rag), [Tool Calling](#tool-calling)

### In-Context Learning
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 문맥 내 학습 · **등장:** 2020-05 (GPT-3, Brown et al.)

가중치 갱신([Fine-tuning](#fine-tuning)) 없이 [Prompt](#prompt) 안의 정보만으로 모델이 새 지식과
과제를 다루는 능력(GPT-3 논문, Brown et al., 2020에서 부각). nanobot의
[Memory](03_memory_context_session.md#memory)와 [Skill](01_core_architecture.md#skill)이
모델을 재훈련하지 않고도 "학습"처럼 작동하는 근거가 이것입니다.

- **상위 개념(이를 기반으로 파생):** [Few-shot Learning](#few-shot-learning), [Zero-shot](#zero-shot)
- **관련 용어:** [Fine-tuning](#fine-tuning)

### Few-shot Learning
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 퓨샷 학습 · **등장:** 2020-05 (GPT-3)

[Prompt](#prompt)에 몇 개의 입력-출력 **예시**를 넣어 과제 수행 방식을 보여주는
[In-Context Learning](#in-context-learning) 기법.

**예시:** "great → 긍정, terrible → 부정, decent → ?"처럼 두 예시만으로 감성 분류 방식을 전달.

- **하위 개념(기반·전제):** [In-Context Learning](#in-context-learning),
  [Prompt](#prompt), [Prompt Engineering](#prompt-engineering)

### Zero-shot
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 제로샷

예시 없이 지시만으로 과제를 수행하게 하는 것 — [Few-shot Learning](#few-shot-learning)의 반대
극단. 현대 LLM은 지시 튜닝 덕에 제로샷 성능이 높아, nanobot의 도구 사용도 대부분 예시 없이
[Tool Schema](02_tools_and_skills.md#tool-schema) 설명만으로 이뤄집니다.

- **하위 개념(기반·전제):** [In-Context Learning](#in-context-learning)

### Fine-tuning
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 파인튜닝(미세 조정) · **등장:** 2018년경 (ULMFiT/GPT/BERT 전이학습 보급)

사전학습된 모델의 **가중치를 추가 데이터로 더 훈련**해 특정 과제/스타일에 맞추는 것.
[In-Context Learning](#in-context-learning)과 달리 모델 자체가 바뀝니다. 전체 가중치를 다
갱신하는 full fine-tuning은 비용이 커서, 일부만 갱신하는 [PEFT](#peft)가 실무 표준이 되었습니다.
(nanobot은 파인튜닝을 쓰지 않고 프롬프트/메모리로 적응합니다.)

- **상위 개념(이를 기반으로 파생):** [PEFT](#peft)
- **관련 용어:** [In-Context Learning](#in-context-learning)

### PEFT
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 파라미터 효율적 파인튜닝 (Parameter-Efficient Fine-Tuning) · **등장:** 2019 (Adapter, Houlsby et al.)

[Fine-tuning](#fine-tuning)의 특수한 방법론 — 모델 전체가 아니라 **아주 작은 일부 파라미터만**
훈련해 비슷한 효과를 얻습니다. 수천억 파라미터 모델도 소비자 GPU에서 튜닝할 수 있게 한 실용적
돌파구입니다. [LoRA](#lora)가 가장 널리 쓰이는 PEFT 기법입니다.
(nanobot에는 직접 구현되지 않은 일반 개념입니다.)

- **하위 개념(기반·전제):** [Fine-tuning](#fine-tuning)
- **상위 개념(이를 기반으로 파생):** [LoRA](#lora)

### LoRA
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 로라 (Low-Rank Adaptation) · **등장:** 2021-06 (Hu et al.)

[PEFT](#peft)의 특수한 기법(Hu et al., 2021) — 원래 가중치는 얼려 두고, 그 옆에 **저랭크(low-rank)
행렬 한 쌍**만 학습해 더합니다. 훈련 파라미터가 1/1000 수준으로 줄고, 학습된 어댑터만 따로
배포/교체할 수 있습니다.

**예시:** 이미지 생성 커뮤니티에서 "특정 화풍 LoRA 파일"을 내려받아 기본 모델에 꽂아 쓰는 것 —
어댑터의 탈착식 배포라는 LoRA의 장점을 보여주는 사례입니다.
(nanobot에는 직접 구현되지 않은 일반 개념입니다.)

- **하위 개념(기반·전제):** [PEFT](#peft)

### RAG
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 검색 증강 생성 (Retrieval-Augmented Generation) · **등장:** 2020-05 (Lewis et al.)

질문과 관련된 문서를 [Embedding](#embedding) 검색으로 찾아 [Prompt](#prompt)에 붙여 주고 답하게
하는 [Grounding](#grounding) 기법(Lewis et al., 2020). nanobot은 벡터 검색 RAG 대신 파일 기반
[Memory](03_memory_context_session.md#memory)와 도구 실행이라는 다른 노선을 택했습니다 —
직접 구현되지 않은 일반 개념입니다.

- **하위 개념(기반·전제):** [Grounding](#grounding), [In-Context Learning](#in-context-learning)
- **관련 용어:** [Embedding](#embedding), [Vector Database](#vector-database)

### Embedding
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 임베딩

텍스트를 **의미가 담긴 숫자 벡터**로 바꾼 것 — 의미가 비슷하면 벡터도 가깝습니다. 키워드가 아닌
"뜻"으로 검색할 수 있게 하는 토대입니다. (nanobot 미사용 — 일반 개념.)

**예시:** "강아지"와 "반려견"은 단어는 다르지만 임베딩 공간에서는 이웃입니다.

- **상위 개념(이를 기반으로 파생):** [Vector Database](#vector-database)
- **관련 용어:** [RAG](#rag)

### Vector Database
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 벡터 데이터베이스

[Embedding](#embedding) 벡터를 저장하고 "가장 가까운 이웃"을 빠르게 찾는 특화 DB
(Pinecone, Qdrant, pgvector 등). [RAG](#rag)의 저장 계층입니다. nanobot은 이 대신 사람이 읽을 수
있는 마크다운 파일을 기억 저장소로 씁니다 — 투명성을 택한 트레이드오프입니다.

- **하위 개념(기반·전제):** [Embedding](#embedding)
- **관련 용어:** [Memory](03_memory_context_session.md#memory)

### Agent Loop (concept)
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 에이전트 루프(개념)

"모델 호출 → 행동 → 관찰 → 재호출"을 목표 달성까지 반복하는 일반 패턴 —
[ReAct](#react)가 이 패턴의 이론적 뿌리입니다. nanobot의
[AgentLoop](01_core_architecture.md#agentloop)/[AgentRunner](01_core_architecture.md#agentrunner)는
이 일반 개념의 구현(더 특수한 형태)입니다.

- **상위 개념(이를 기반으로 파생):** [AgentLoop](01_core_architecture.md#agentloop),
  [AgentRunner](01_core_architecture.md#agentrunner), [ReAct](#react)
- **하위 개념(기반·전제):** [Agent](01_core_architecture.md#agent)

### Tool Calling
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 도구 호출 (function calling) · **등장:** 2023-06 (OpenAI function calling API)

[LLM](#llm)이 자연어 대신 **구조화된 호출 요청**(함수명 + [JSON Schema](#json-schema) 인자)을
출력하고, 런타임이 실행 후 결과를 되돌려주는 상호작용 규약. 2023년 OpenAI function calling으로
API 표준이 되었습니다. 모델은 실행하지 않고 "요청"만 한다는 것이 핵심 — 실행과 그 안전은 전적으로
런타임(nanobot) 몫입니다.

- **하위 개념(기반·전제):** [LLM](#llm), [Grounding](#grounding)
- **상위 개념(이를 기반으로 파생):** [Tool](01_core_architecture.md#tool), [MCP](#mcp)
- **관련 용어:** [ReAct](#react), [ToolResult](02_tools_and_skills.md#toolresult)

### JSON Schema
**클래스:** [Protocol](00_content_classes.md#protocol) · **등장:** 2009년경 (초안 표준)

JSON 데이터의 구조(타입, 필수 필드, 허용값)를 JSON으로 기술하는 표준. [Tool Calling](#tool-calling)에서
도구 파라미터의 "계약서" 역할을 합니다 — 모델이 이를 읽고 올바른 형태의 인자를 생성합니다.

**예시:** `{"type": "object", "properties": {"path": {"type": "string"}}, "required": ["path"]}` —
"path라는 문자열 필드가 반드시 필요하다"는 선언입니다.

- **상위 개념(이를 기반으로 파생):** [Tool Schema](02_tools_and_skills.md#tool-schema)
- **관련 용어:** [Pydantic](09_dev_stack.md#pydantic)

### ReAct
**클래스:** [Research](00_content_classes.md#research) · **등장:** 2022-10 (Yao et al.)

*ReAct: Synergizing Reasoning and Acting in Language Models*(Yao et al., 2022) — 추론(Reasoning)과
행동(Acting)을 **교대로** 수행하면 각각 단독보다 훨씬 낫다는 것을 보인 논문. 현대
[Agent Loop (concept)](#agent-loop-concept)의 이론적 기원입니다.

**예시:** Thought("파일 개수를 세려면 셸이 필요") → Action(`exec: find ... | wc -l`) →
Observation(`42`) → Thought("이제 답할 수 있다") → 답변.

- **하위 개념(기반·전제):** [Agent Loop (concept)](#agent-loop-concept)
- **관련 용어:** [Chain-of-Thought](#chain-of-thought), [Tool Calling](#tool-calling)

### Chain-of-Thought
**클래스:** [Research](00_content_classes.md#research) · **한글:** 사고 사슬 (CoT) · **등장:** 2022-01 (Wei et al.)

답만 내지 말고 **중간 추론 단계를 먼저 출력**하게 하면 복잡한 문제의 정답률이 크게 오른다는 발견
(Wei et al., 2022). "step by step으로 생각해 보자" 한 줄이 대표적 트리거입니다.
[ReAct](#react)의 Thought 단계, 최신 모델의 내장 추론
([Reasoning Blocks](04_providers_and_llm.md#reasoning-blocks))으로 이어졌습니다.

- **하위 개념(기반·전제):** [Prompt Engineering](#prompt-engineering), [Prompt](#prompt)
- **관련 용어:** [ReAct](#react)

### Context Compression
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 컨텍스트 압축

유한한 [Context Window](#context-window) 안에 긴 이력을 담기 위해 정보를 줄이는 기법의 총칭.

**예시:** nanobot의 구현들 — [Summarization](#summarization)/[Consolidation](03_memory_context_session.md#consolidation)
(요약), [Sliding Window](#sliding-window)(최근만 원문 유지),
[Context Governance](03_memory_context_session.md#context-governance)(예산 초과분 절단).

- **상위 개념(이를 기반으로 파생):** [Summarization](#summarization), [Sliding Window](#sliding-window),
  [AutoCompact](03_memory_context_session.md#autocompact),
  [Context Governance](03_memory_context_session.md#context-governance)
- **관련 용어:** [Lost in the Middle](#lost-in-the-middle)

### Summarization
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 요약

긴 텍스트를 짧게 줄이되 핵심을 보존하는 것 — [LLM](#llm) 스스로가 훌륭한 요약기라는 점을 이용해,
"모델의 기억을 모델이 요약"하는 재귀적 구조가 가능합니다
([Consolidation](03_memory_context_session.md#consolidation)이 그 구현).

- **하위 개념(기반·전제):** [Context Compression](#context-compression)
- **상위 개념(이를 기반으로 파생):** [Consolidation](03_memory_context_session.md#consolidation)

### Sliding Window
**클래스:** [Principle](00_content_classes.md#principle) · **한글:** 슬라이딩 윈도우

항상 **최근 N개만** 유지하고 오래된 것부터 버리는/접는 기법 — 대화에서는 최근 문맥이 가장 중요하다는
관찰에 기반합니다. nanobot [AutoCompact](03_memory_context_session.md#autocompact)의
"최근 8개 메시지 원문 유지"가 이 원리입니다.

- **하위 개념(기반·전제):** [Context Compression](#context-compression)

### Lost in the Middle
**클래스:** [Research](00_content_classes.md#research) · **등장:** 2023-07 (Liu et al.)

긴 컨텍스트에서 모델이 **중간에 놓인 정보**를 처음/끝보다 잘 놓친다는 실증 연구(Liu et al., 2023).
"창이 크니 다 넣으면 된다"가 틀렸음을 보여, 중요한 정보를 앞/뒤에 배치하고 중간을 압축하는 설계
(예: [Runtime Context](03_memory_context_session.md#runtime-context)를 끝에 배치)의 근거가 됩니다.

- **관련 용어:** [Context Window](#context-window), [Context Compression](#context-compression)

### Hierarchical Memory
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 계층적 메모리 · **등장:** 2023-10 (MemGPT, Packer et al.)

기억을 컴퓨터의 메모리 계층처럼 **핵심(상시 로드) / 보관(필요 시 로드)** 층으로 나누는 아키텍처 —
MemGPT(Packer et al., 2023)가 대표 연구입니다. nanobot의 대응:
[MEMORY.md](03_memory_context_session.md#memorymd)(상시) vs
[history.jsonl](03_memory_context_session.md#historyjsonl)(보관), 그리고 인지과학의
의미 기억/일화 기억 구분과 평행합니다.

- **상위 개념(이를 기반으로 파생):** [Memory](03_memory_context_session.md#memory)
- **관련 용어:** [Dream](03_memory_context_session.md#dream)

### Reflection
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 반성(자기 성찰) · **등장:** 2023-03 (Reflexion, Shinn et al.)

에이전트가 자기 경험/출력을 되돌아보고 교훈을 추출해 다음 행동을 개선하는 패턴(Reflexion,
Shinn et al., 2023; Generative Agents, Park et al., 2023). nanobot의
[Dream](03_memory_context_session.md#dream)은 반성의 보수적 구현 — 교훈을 파일 diff라는 검증
가능한 형태로만 인정합니다.

- **상위 개념(이를 기반으로 파생):** [Dream](03_memory_context_session.md#dream)
- **관련 용어:** [Skill Library](#skill-library)

### Skill Library
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 스킬 라이브러리

에이전트가 획득한 능력을 **재사용 가능한 형태로 축적**하는 저장소 개념 — [Voyager](#voyager)가
게임 환경에서 실증했습니다. nanobot의 [Skill](01_core_architecture.md#skill) 디렉토리 +
[skill-creator](02_tools_and_skills.md#skill-creator)가 이 개념의 마크다운 구현입니다.

- **상위 개념(이를 기반으로 파생):** [Skill](01_core_architecture.md#skill), [Voyager](#voyager),
  [Agent Skills](#agent-skills)
- **관련 용어:** [Reflection](#reflection)

### Voyager
**클래스:** [Research](00_content_classes.md#research) · **등장:** 2023-05 (Wang et al.)

*Voyager: An Open-Ended Embodied Agent with LLMs*(Wang et al., 2023) — 마인크래프트에서
에이전트가 **스스로 스킬 코드를 작성·저장·재사용**하며 성장함을 보인 논문.
[Skill Library](#skill-library) 개념의 대표 실증입니다.

- **하위 개념(기반·전제):** [Skill Library](#skill-library)

### Agent Skills
**클래스:** [Protocol](00_content_classes.md#protocol) · **등장:** 2025 (Anthropic)

Anthropic이 정리한 스킬 규격 — 폴더 + [SKILL.md](02_tools_and_skills.md#skillmd)
([Frontmatter](02_tools_and_skills.md#frontmatter) 메타데이터 + 본문 절차)로 에이전트 노하우를
패키징합니다. nanobot의 스킬 형식이 이 계열입니다.

- **하위 개념(기반·전제):** [Skill Library](#skill-library)
- **상위 개념(이를 기반으로 파생):** [SKILL.md](02_tools_and_skills.md#skillmd)

### MCP
**클래스:** [Protocol](00_content_classes.md#protocol) · **한글:** 모델 컨텍스트 프로토콜 (Model Context Protocol) · **등장:** 2024-11 (Anthropic)

Anthropic이 2024년 공개한 **도구/컨텍스트 연결 표준** — "AI 도구의 USB-C"라는 비유처럼, 도구
제공자(서버)와 에이전트(클라이언트)가 서로를 몰라도 [JSON-RPC](#json-rpc) 규약만 지키면
연결됩니다. M개 에이전트 × N개 도구의 조합 문제를 M+N으로 줄입니다.

**예시:** 누군가 만든 GitHub MCP 서버를 nanobot, Claude Desktop, 다른 에이전트가 모두 같은 방식으로
사용합니다. nanobot 쪽 구현은 [MCPToolWrapper](02_tools_and_skills.md#mcptoolwrapper)입니다.

- **하위 개념(기반·전제):** [Tool Calling](#tool-calling), [JSON-RPC](#json-rpc)
- **상위 개념(이를 기반으로 파생):** [MCPToolWrapper](02_tools_and_skills.md#mcptoolwrapper),
  [stdio Transport](#stdio-transport), [Streamable HTTP](#streamable-http)
- **관련 용어:** [LSP](#lsp)

### JSON-RPC
**클래스:** [Protocol](00_content_classes.md#protocol) · **등장:** 2005 (2.0 규격 2010)

JSON으로 원격 프로시저 호출(요청 `{method, params, id}` / 응답 `{result | error, id}`)을 표현하는
경량 프로토콜. 전송 수단을 규정하지 않아 [stdio Transport](#stdio-transport), HTTP 등 어디에나
실립니다. [MCP](#mcp)와 [LSP](#lsp)의 공통 기반입니다.

- **상위 개념(이를 기반으로 파생):** [MCP](#mcp), [LSP](#lsp)

### stdio Transport
**클래스:** [Protocol](00_content_classes.md#protocol) · **한글:** 표준입출력 전송

로컬 자식 프로세스와 stdin/stdout 파이프로 [JSON-RPC](#json-rpc)를 주고받는 [MCP](#mcp) 전송
방식. 네트워크 포트가 필요 없어 로컬 도구 서버에 가장 간단한 선택입니다.

- **하위 개념(기반·전제):** [MCP](#mcp)

### SSE
**클래스:** [Protocol](00_content_classes.md#protocol) · **한글:** 서버 전송 이벤트 (Server-Sent Events) · **등장:** 2009년경 (HTML5 표준화)

[HTTP](05_channels_gateway_ui.md#http) 연결을 열어 두고 서버가 텍스트 이벤트를 단방향으로 흘려
보내는 표준. LLM API [Streaming](04_providers_and_llm.md#streaming)의 사실상 표준 전송이며,
[MCP](#mcp)의 원격 전송에도 쓰였습니다(현재는 [Streamable HTTP](#streamable-http)로 대체 중).

- **하위 개념(기반·전제):** [HTTP](05_channels_gateway_ui.md#http)
- **관련 용어:** [WebSocket](05_channels_gateway_ui.md#websocket)

### Streamable HTTP
**클래스:** [Protocol](00_content_classes.md#protocol) · **등장:** 2025-03 (MCP 규격 개정)

[MCP](#mcp)의 신형 원격 전송 — 단일 HTTP 엔드포인트로 요청하고 응답을 스트리밍할 수 있어
[SSE](#sse) 방식보다 인프라(로드밸런서 등) 친화적입니다.

- **하위 개념(기반·전제):** [MCP](#mcp), [HTTP](05_channels_gateway_ui.md#http)

### LSP
**클래스:** [Protocol](00_content_classes.md#protocol) · **한글:** 언어 서버 프로토콜 (Language Server Protocol) · **등장:** 2016-06 (Microsoft)

에디터와 언어 분석기를 분리한 Microsoft의 표준 — "M개 에디터 × N개 언어"를 M+N으로 줄인
선례로, [MCP](#mcp) 설계의 직접적 영감입니다. [JSON-RPC](#json-rpc) 기반이라는 점도 같습니다.

- **하위 개념(기반·전제):** [JSON-RPC](#json-rpc)
- **관련 용어:** [MCP](#mcp)

### Model Routing
**클래스:** [Concept](00_content_classes.md#concept) · **한글:** 모델 라우팅

요청 성격에 따라 **다른 모델로 보내는** 전략 — 비용/품질/가용성의 균형이 목적입니다
(FrugalGPT, Chen et al., 2023 계열 연구).

**예시:** nanobot의 구현들 — [Model Preset](01_core_architecture.md#model-preset)(용도별 수동 지정),
[FallbackProvider](04_providers_and_llm.md#fallbackprovider)(장애 시 자동 전환).

- **상위 개념(이를 기반으로 파생):** [Model Preset](01_core_architecture.md#model-preset),
  [FallbackProvider](04_providers_and_llm.md#fallbackprovider)
- **관련 용어:** [Provider Registry](04_providers_and_llm.md#provider-registry)
