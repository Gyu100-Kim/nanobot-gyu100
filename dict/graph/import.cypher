// dict/ 지식 그래프 임포트 (Neo4j / Memgraph 공용, 재실행 안전)
CREATE CONSTRAINT content_id IF NOT EXISTS FOR (n:Content) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT content_class_id IF NOT EXISTS FOR (n:ContentClass) REQUIRE n.id IS UNIQUE;

MERGE (n:Content {id: "content:_skip_modules"})
SET n.name = "_SKIP_MODULES",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "[Tool Discovery](#tool-discovery)에서 제외되는 모듈 이름 목록: `base`, `schema`, `registry`,";
MERGE (n:Content {id: "content:adapter-pattern"})
SET n.name = "Adapter Pattern",
    n.file = "dict/01_core_architecture.md",
    n.description = "호환되지 않는 인터페이스를 가진 외부 시스템을, 내가 원하는 표준 인터페이스로 **변환해 끼우는** 패턴";
MERGE (n:Content {id: "content:agent"})
SET n.name = "Agent",
    n.file = "dict/01_core_architecture.md",
    n.description = "[LLM](08_ai_llm_concepts.md#llm)이 [Tool](#tool)을 호출하며 목표를 향해 여러 단계를 스스로 수행하는";
MERGE (n:Content {id: "content:agent-loop-concept"})
SET n.name = "Agent Loop (concept)",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "\"모델 호출 → 행동 → 관찰 → 재호출\"을 목표 달성까지 반복하는 일반 패턴 —";
MERGE (n:Content {id: "content:agent-skills"})
SET n.name = "Agent Skills",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2025 (Anthropic)",
    n.description = "Anthropic이 정리한 스킬 규격 — 폴더 + [SKILL.md](02_tools_and_skills.md#skillmd)";
MERGE (n:Content {id: "content:agentloop"})
SET n.name = "AgentLoop",
    n.file = "dict/01_core_architecture.md",
    n.description = "메시지 단위의 **바깥 턴 [State Machine](#state-machine)**. [MessageBus](#messagebus)에서";
MERGE (n:Content {id: "content:agentrunner"})
SET n.name = "AgentRunner",
    n.file = "dict/01_core_architecture.md",
    n.description = "한 [Turn](#turn) 안에서 \"[Provider](#provider) 호출 → [Tool](#tool) 실행 → 결과 반영 → 재호출\"을";
MERGE (n:Content {id: "content:anthropic-provider"})
SET n.name = "Anthropic Provider",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "Claude 모델용 프로바이더. Anthropic Messages API 특유의 형식(별도 system 파라미터, content block";
MERGE (n:Content {id: "content:api-server"})
SET n.name = "API Server",
    n.file = "dict/05_channels_gateway_ui.md",
    n.description = "[OpenAI-Compatible API](#openai-compatible-api)(`/v1/chat/completions`, `/v1/models`)를 노출하는";
MERGE (n:Content {id: "content:append-only-log"})
SET n.name = "Append-only Log",
    n.file = "dict/03_memory_context_session.md",
    n.description = "기존 내용을 수정하지 않고 **끝에 덧붙이기만** 하는 저장 방식. 쓰기가 빠르고, 동시 접근 충돌이 적고,";
MERGE (n:Content {id: "content:apply_patch"})
SET n.name = "apply_patch",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "여러 파일 변경을 하나의 패치 텍스트로 기술해 원자적으로 적용하는 편집 도구.";
MERGE (n:Content {id: "content:apps"})
SET n.name = "Apps",
    n.file = "dict/05_channels_gateway_ui.md",
    n.description = "에이전트 위에 얹는 응용 기능 모음(캔버스 등). \"Core stays small\" 원칙에 따라 코어 밖 가장자리에";
MERGE (n:Content {id: "content:asyncio"})
SET n.name = "asyncio",
    n.file = "dict/09_dev_stack.md",
    n.first_appearance = "2014 (Python 3.4)",
    n.description = "파이썬 표준 비동기 프레임워크 — 먼저 존재하던 [Event Loop](#event-loop)와";
MERGE (n:Content {id: "content:asyncioqueue"})
SET n.name = "asyncio.Queue",
    n.file = "dict/09_dev_stack.md",
    n.description = "[Coroutine](#coroutine) 간 안전한 전달 통로가 되는 비동기 큐 — `await get()`은 항목이 올 때까지";
MERGE (n:Content {id: "content:atomic-write"})
SET n.name = "Atomic Write",
    n.file = "dict/03_memory_context_session.md",
    n.description = "파일 쓰기가 \"전부 반영\" 또는 \"전혀 반영 안 됨\" 둘 중 하나가 되도록 하는 기법 — 임시 파일에 쓰고";
MERGE (n:Content {id: "content:attention"})
SET n.name = "Attention",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2014-09 (Bahdanau et al.)",
    n.description = "신경망이 입력의 여러 부분 중 \"지금 중요한 곳\"에 가중치를 두고 주목하게 하는 메커니즘 —";
MERGE (n:Content {id: "content:autocompact"})
SET n.name = "AutoCompact",
    n.file = "dict/03_memory_context_session.md",
    n.description = "사용자가 대화 중일 때가 아니라 한가할 때 정리하므로 응답 지연이 없습니다.";
MERGE (n:Content {id: "content:automation-turns"})
SET n.name = "Automation Turns",
    n.file = "dict/06_scheduling_automation.md",
    n.description = "크론 외 자동화(트리거 등)로 시작된 턴의 공통 처리 — 표시 이름, 이력 규칙 등.";
MERGE (n:Content {id: "content:azure-openai-provider"})
SET n.name = "Azure OpenAI Provider",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "Azure에 배포된 OpenAI 모델용 프로바이더(배포 이름, API 버전 등 Azure 특유 설정 처리).";
MERGE (n:Content {id: "content:bedrock-provider"})
SET n.name = "Bedrock Provider",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "AWS Bedrock을 통해 모델을 호출하는 프로바이더 — API 키 대신 AWS 자격증명(IAM) 체계를 씁니다.";
MERGE (n:Content {id: "content:bert"})
SET n.name = "BERT",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2018-10 (Devlin et al.)",
    n.description = "[Transformer](#transformer)의 **인코더**를 활용해 만든 양방향 언어 이해 모델(Google).";
MERGE (n:Content {id: "content:bootstrap-templates"})
SET n.name = "Bootstrap Templates",
    n.file = "dict/03_memory_context_session.md",
    n.description = "새 [Workspace](01_core_architecture.md#workspace)를 초기화할 때 복사되는 시드 파일들";
MERGE (n:Content {id: "content:bound-runner"})
SET n.name = "Bound Runner",
    n.file = "dict/06_scheduling_automation.md",
    n.description = "크론 실행을 특정 세션/채널에 **바인딩된** 에이전트 턴으로 바꿔 주는 실행기.";
MERGE (n:Content {id: "content:bpe"})
SET n.name = "BPE",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "1994 (Gage; NLP 적용 2015 Sennrich et al.)",
    n.description = "자주 함께 등장하는 문자 쌍을 반복 병합해 어휘를 만드는 [Tokenizer](#tokenizer) 알고리즘";
MERGE (n:Content {id: "content:bubblewrap"})
SET n.name = "bubblewrap",
    n.file = "dict/07_security_isolation.md",
    n.first_appearance = "2016 (Flatpak 프로젝트)",
    n.description = "[Linux Namespaces](#linux-namespaces)를 이용하는 경량 샌드박스 도구(Flatpak 프로젝트 산하).";
MERGE (n:Content {id: "content:bun"})
SET n.name = "bun",
    n.file = "dict/09_dev_stack.md",
    n.first_appearance = "2022",
    n.description = "Node.js 호환의 고속 자바스크립트 런타임 겸 패키지 매니저 —";
MERGE (n:Content {id: "content:camelcase-alias"})
SET n.name = "camelCase Alias",
    n.file = "dict/09_dev_stack.md",
    n.description = "파이썬 필드는 `snake_case`, JSON 키는 `camelCase`를 쓰는 관행 차이를 [Pydantic](#pydantic)";
MERGE (n:Content {id: "content:chain-of-thought"})
SET n.name = "Chain-of-Thought",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2022-01 (Wei et al.)",
    n.description = "답만 내지 말고 **중간 추론 단계를 먼저 출력**하게 하면 복잡한 문제의 정답률이 크게 오른다는 발견";
MERGE (n:Content {id: "content:channel"})
SET n.name = "Channel",
    n.file = "dict/01_core_architecture.md",
    n.description = "외부 메시징 플랫폼과 nanobot을 잇는 [Adapter Pattern](#adapter-pattern) 구현. 플랫폼 메시지 ↔";
MERGE (n:Content {id: "content:channel-manager"})
SET n.name = "Channel Manager",
    n.file = "dict/05_channels_gateway_ui.md",
    n.description = "설정에 활성화된 [Channel](01_core_architecture.md#channel)들을 찾아 생성·시작·정지시키는 조율자.";
MERGE (n:Content {id: "content:channel-registry"})
SET n.name = "Channel Registry",
    n.file = "dict/05_channels_gateway_ui.md",
    n.description = "채널 이름 → 구현 클래스 매핑을 관리하는 [Registry Pattern](02_tools_and_skills.md#registry-pattern)";
MERGE (n:Content {id: "content:circuit-breaker"})
SET n.name = "Circuit Breaker",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "연속 실패한 대상을 일정 시간 **차단(open)** 해 불필요한 재시도와 연쇄 장애를 막는 신뢰성 패턴";
MERGE (n:Content {id: "content:command-router"})
SET n.name = "Command Router",
    n.file = "dict/01_core_architecture.md",
    n.description = "`/`로 시작하는 [Slash Command](#slash-command)를 LLM에 보내지 않고 직접 처리하는 라우터.";
MERGE (n:Content {id: "content:config"})
SET n.name = "Config",
    n.file = "dict/01_core_architecture.md",
    n.description = "`~/.nanobot/config.json`에서 로드되는 [Pydantic](09_dev_stack.md#pydantic) 기반 설정. JSON 관행을";
MERGE (n:Content {id: "content:consolidation"})
SET n.name = "Consolidation",
    n.file = "dict/03_memory_context_session.md",
    n.description = "오래된 대화 구간을 [LLM](08_ai_llm_concepts.md#llm)으로";
MERGE (n:Content {id: "content:container"})
SET n.name = "Container",
    n.file = "dict/07_security_isolation.md",
    n.first_appearance = "2013 (Docker; LXC 2008)",
    n.description = "[Linux Namespaces](#linux-namespaces) + cgroups(자원 제한) + 이미지 레이어로 프로세스를 패키징·";
MERGE (n:Content {id: "content:context"})
SET n.name = "Context",
    n.file = "dict/03_memory_context_session.md",
    n.description = "한 번의 [LLM](08_ai_llm_concepts.md#llm) 호출에 들어가는 모든 입력의 조립체.";
MERGE (n:Content {id: "content:context-compression"})
SET n.name = "Context Compression",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "유한한 [Context Window](#context-window) 안에 긴 이력을 담기 위해 정보를 줄이는 기법의 총칭.";
MERGE (n:Content {id: "content:context-governance"})
SET n.name = "Context Governance",
    n.file = "dict/03_memory_context_session.md",
    n.description = "모델에 보내기 직전의 메시지 목록을 검증·절단하는 규칙 모음: [Input Budget](#input-budget) 계산,";
MERGE (n:Content {id: "content:context-window"})
SET n.name = "Context Window",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "모델이 한 번에 볼 수 있는 [Token](#token) 수의 상한 — 모델의 \"작업 기억\" 크기.";
MERGE (n:Content {id: "content:contextvar"})
SET n.name = "ContextVar",
    n.file = "dict/09_dev_stack.md",
    n.description = "비동기 작업마다 **독립된 값**을 갖는 변수(표준 `contextvars`). 전역 변수는 동시 실행 중인 여러";
MERGE (n:Content {id: "content:coroutine"})
SET n.name = "Coroutine",
    n.file = "dict/09_dev_stack.md",
    n.first_appearance = "1963 (Conway)",
    n.description = "실행 도중 **스스로 양보하고 나중에 이어서 실행**할 수 있는 함수 — 1963년까지 거슬러 올라가는";
MERGE (n:Content {id: "content:cron"})
SET n.name = "Cron",
    n.file = "dict/06_scheduling_automation.md",
    n.description = "유닉스에서 유래한 시간 기반 작업 스케줄링 개념. [Cron Expression](#cron-expression)이라는 5필드";
MERGE (n:Content {id: "content:cron-expression"})
SET n.name = "Cron Expression",
    n.file = "dict/06_scheduling_automation.md",
    n.description = "`분 시 일 월 요일` 5개 필드로 스케줄을 표현하는 문자열 형식.";
MERGE (n:Content {id: "content:cron-job"})
SET n.name = "Cron Job",
    n.file = "dict/06_scheduling_automation.md",
    n.description = "등록된 예약 작업 하나 — 스케줄([Cron Expression](#cron-expression)), 실행할 메시지/프롬프트,";
MERGE (n:Content {id: "content:cron-store"})
SET n.name = "Cron Store",
    n.file = "dict/06_scheduling_automation.md",
    n.description = "[Cron Job](#cron-job) 목록이 저장되는 JSON 파일. 재시작해도 예약이 유지되고, 사람이 직접 열어";
MERGE (n:Content {id: "content:cron-tool"})
SET n.name = "Cron Tool",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "에이전트가 스스로 [Cron Job](06_scheduling_automation.md#cron-job)을 등록/삭제하는 도구.";
MERGE (n:Content {id: "content:cron-turns"})
SET n.name = "Cron Turns",
    n.file = "dict/06_scheduling_automation.md",
    n.description = "크론 발 턴의 이력 기록 방식을 다루는 모듈 — 시스템이 만든 턴을 사용자 대화와 구분해";
MERGE (n:Content {id: "content:croniter"})
SET n.name = "croniter",
    n.file = "dict/06_scheduling_automation.md",
    n.description = "[Cron Expression](#cron-expression)을 파싱해 \"다음 실행 시각\"을 계산해 주는 파이썬 라이브러리.";
MERGE (n:Content {id: "content:cronservice"})
SET n.name = "CronService",
    n.file = "dict/06_scheduling_automation.md",
    n.description = "[Cron Job](#cron-job) 목록을 로드해 시간이 되면 실행하는 스케줄러 서비스.";
MERGE (n:Content {id: "content:cursor"})
SET n.name = "Cursor",
    n.file = "dict/03_memory_context_session.md",
    n.description = "스트림/로그에서 \"여기까지 처리했다\"를 기록하는 위치 표식. 커서 이후만 처리하면 되므로";
MERGE (n:Content {id: "content:ddgs"})
SET n.name = "ddgs",
    n.file = "dict/09_dev_stack.md",
    n.description = "DuckDuckGo 검색 라이브러리 — API 키 없이 웹 검색을 제공하므로";
MERGE (n:Content {id: "content:decoupling"})
SET n.name = "Decoupling",
    n.file = "dict/01_core_architecture.md",
    n.description = "구성요소들이 서로의 내부 구현을 모르게 하여, 한쪽의 변경이 다른 쪽에 파급되지 않게 하는 설계 원칙.";
MERGE (n:Content {id: "content:defense-in-depth"})
SET n.name = "Defense in Depth",
    n.file = "dict/07_security_isolation.md",
    n.description = "한 겹의 방어에 의존하지 않고 **여러 겹**을 두는 원칙 — 한 겹이 뚫려도 다음 겹이 막습니다.";
MERGE (n:Content {id: "content:delta"})
SET n.name = "Delta",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "[Streaming](#streaming)에서 도착하는 응답의 증분 조각. 텍스트 델타, 도구 호출 인자 델타 등이 있고,";
MERGE (n:Content {id: "content:dns-pinning"})
SET n.name = "DNS Pinning",
    n.file = "dict/07_security_isolation.md",
    n.description = "[DNS Rebinding](#dns-rebinding) 방어 — 검사 시점에 해석한 IP를 **고정(pin)** 해 실제 연결도 반드시";
MERGE (n:Content {id: "content:dns-rebinding"})
SET n.name = "DNS Rebinding",
    n.file = "dict/07_security_isolation.md",
    n.description = "[SSRF](#ssrf) 차단을 우회하는 기법 — 검사 시점에는 공인 IP를, 실제 접속 시점에는 사설 IP를";
MERGE (n:Content {id: "content:dream"})
SET n.name = "Dream",
    n.file = "dict/03_memory_context_session.md",
    n.description = "[Cron](06_scheduling_automation.md#cron)으로 주기 실행되는 **기억 통합 작업** — 사람이 자면서";
MERGE (n:Content {id: "content:dream-cursor"})
SET n.name = "Dream Cursor",
    n.file = "dict/03_memory_context_session.md",
    n.description = "[Dream](#dream)이 [history.jsonl](#historyjsonl)의 어디까지 처리했는지 기록하는 위치 파일 —";
MERGE (n:Content {id: "content:dulwich"})
SET n.name = "dulwich",
    n.file = "dict/09_dev_stack.md",
    n.description = "순수 파이썬 [Git](#git) 구현 — git 바이너리 설치 없이 저장소를 다룰 수 있습니다.";
MERGE (n:Content {id: "content:durable-files"})
SET n.name = "Durable Files",
    n.file = "dict/03_memory_context_session.md",
    n.description = "에이전트의 정체성과 기억을 담는 마크다운 파일들. [Dream](#dream)이 갱신합니다.";
MERGE (n:Content {id: "content:embedding"})
SET n.name = "Embedding",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "텍스트를 **의미가 담긴 숫자 벡터**로 바꾼 것 — 의미가 비슷하면 벡터도 가깝습니다. 키워드가 아닌";
MERGE (n:Content {id: "content:entry-point-plugin"})
SET n.name = "Entry-point Plugin",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "파이썬 패키징의 [Entry Points](09_dev_stack.md#entry-points) 규격(`nanobot.tools`,";
MERGE (n:Content {id: "content:entry-points"})
SET n.name = "Entry Points",
    n.file = "dict/09_dev_stack.md",
    n.description = "파이썬 패키징 표준의 플러그인 선언 규격 — 패키지가 메타데이터에 \"나는 이 그룹에 이 객체를";
MERGE (n:Content {id: "content:event-loop"})
SET n.name = "Event Loop",
    n.file = "dict/09_dev_stack.md",
    n.first_appearance = "1980년대 (GUI/네트워크 프로그래밍)",
    n.description = "\"준비된 작업을 하나 꺼내 실행하고, I/O를 기다리는 작업은 재워 두는\" 것을 반복하는 스케줄러.";
MERGE (n:Content {id: "content:exact-pinning"})
SET n.name = "Exact Pinning",
    n.file = "dict/09_dev_stack.md",
    n.description = "의존성 버전에 상한·하한을 두어(`>=x,<y`) 예고 없는 호환성 파괴를 막는 정책. 재현성이 좋아지는";
MERGE (n:Content {id: "content:exec-session"})
SET n.name = "Exec Session",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "상태 유지형(interactive) 셸 세션 관리자(`ExecSessionManager`). 일회성 [ExecTool](#exectool)과 달리";
MERGE (n:Content {id: "content:exectool"})
SET n.name = "ExecTool",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "셸 명령을 실행하는 도구 — 에이전트에게 가장 강력하고 가장 위험한 능력.";
MERGE (n:Content {id: "content:exponential-backoff"})
SET n.name = "Exponential Backoff",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "재시도 간격을 1초 → 2초 → 4초 → 8초처럼 지수적으로 늘리는 [Retry](#retry) 전략. 과부하 서버에";
MERGE (n:Content {id: "content:facade-pattern"})
SET n.name = "Facade Pattern",
    n.file = "dict/01_core_architecture.md",
    n.description = "복잡한 내부 서브시스템을 **간단한 단일 진입 객체** 뒤에 숨기는 패턴(GoF). 사용자는 파사드의 몇 개";
MERGE (n:Content {id: "content:fallbackprovider"})
SET n.name = "FallbackProvider",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "여러 프로바이더를 순서대로 시도하는 합성 프로바이더 — 그 자체가";
MERGE (n:Content {id: "content:few-shot-learning"})
SET n.name = "Few-shot Learning",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2020-05 (GPT-3)",
    n.description = "[Prompt](#prompt)에 몇 개의 입력-출력 **예시**를 넣어 과제 수행 방식을 보여주는";
MERGE (n:Content {id: "content:file-state"})
SET n.name = "File State",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "파일 읽기 이력을 추적해 \"읽지 않고 편집\" 경고와 중복 읽기 감지를 제공하는 인프라 모듈";
MERGE (n:Content {id: "content:filelock"})
SET n.name = "filelock",
    n.file = "dict/09_dev_stack.md",
    n.description = "파일 기반 프로세스 간 잠금 라이브러리 — 여러 프로세스가 같은 세션/메모리 파일을 동시에 쓰는";
MERGE (n:Content {id: "content:filesystem-tools"})
SET n.name = "Filesystem Tools",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "파일 읽기/쓰기/편집/목록 도구 모음. 모든 경로는";
MERGE (n:Content {id: "content:fine-tuning"})
SET n.name = "Fine-tuning",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2018년경 (ULMFiT/GPT/BERT 전이학습 보급)",
    n.description = "사전학습된 모델의 **가중치를 추가 데이터로 더 훈련**해 특정 과제/스타일에 맞추는 것.";
MERGE (n:Content {id: "content:frontmatter"})
SET n.name = "Frontmatter",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "[Markdown](#markdown) 파일 맨 앞에 `---`로 구분해 넣는 구조화된 메타데이터 블록(YAML 형식).";
MERGE (n:Content {id: "content:fsync"})
SET n.name = "fsync",
    n.file = "dict/03_memory_context_session.md",
    n.description = "OS 버퍼에 있는 쓰기 내용을 **물리 디스크까지 강제로 내리는** 시스템 콜. `write()`만 하면 데이터가";
MERGE (n:Content {id: "content:gateway"})
SET n.name = "Gateway",
    n.file = "dict/01_core_architecture.md",
    n.description = "`nanobot gateway` 명령으로 뜨는 **장기 실행 오케스트레이터**. 모든 [Channel](#channel),";
MERGE (n:Content {id: "content:gateway-service"})
SET n.name = "Gateway Service",
    n.file = "dict/05_channels_gateway_ui.md",
    n.description = "[Gateway](01_core_architecture.md#gateway)의 실제 구현 — 채널, [AgentLoop](01_core_architecture.md#agentloop),";
MERGE (n:Content {id: "content:git"})
SET n.name = "Git",
    n.file = "dict/09_dev_stack.md",
    n.first_appearance = "2005 (Linus Torvalds)",
    n.description = "분산 버전 관리 시스템. nanobot에서는 코드 관리를 넘어 **메모리 변경의 감사 추적**으로도 쓰입니다 —";
MERGE (n:Content {id: "content:github-copilot-provider"})
SET n.name = "GitHub Copilot Provider",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "GitHub Copilot 구독의 모델 접근권을 사용하는 프로바이더. 디바이스 플로우 OAuth 로그인을 지원합니다.";
MERGE (n:Content {id: "content:goal-state"})
SET n.name = "Goal State",
    n.file = "dict/03_memory_context_session.md",
    n.description = "[Sustained Goal](#sustained-goal)의 등록/완료 상태를 세션 메타데이터로 관리하는 모듈.";
MERGE (n:Content {id: "content:graceful-degradation"})
SET n.name = "Graceful Degradation",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "일부 구성요소가 실패해도 시스템 전체가 죽지 않고 **품질을 낮춰서라도 계속 동작**하게 하는 신뢰성";
MERGE (n:Content {id: "content:grounding"})
SET n.name = "Grounding",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "모델의 출력을 **검증 가능한 외부 근거**(문서, 도구 실행 결과, DB)에 묶는 것 —";
MERGE (n:Content {id: "content:hallucination"})
SET n.name = "Hallucination",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "모델이 사실이 아닌 내용을 그럴듯하게 생성하는 현상. 모델은 \"가장 그럴듯한 다음";
MERGE (n:Content {id: "content:hatchling"})
SET n.name = "hatchling",
    n.file = "dict/09_dev_stack.md",
    n.description = "`pyproject.toml` 기반 파이썬 빌드 백엔드. [WebUI](05_channels_gateway_ui.md#webui) 빌드 산출물";
MERGE (n:Content {id: "content:health-endpoint"})
SET n.name = "Health Endpoint",
    n.file = "dict/05_channels_gateway_ui.md",
    n.description = "프로세스 생존/상태를 [HTTP](#http)로 알려주는 점검 창구. 컨테이너 오케스트레이터나 모니터링이";
MERGE (n:Content {id: "content:heartbeat"})
SET n.name = "Heartbeat",
    n.file = "dict/06_scheduling_automation.md",
    n.description = "주기적 [Cron Job](#cron-job)으로 [HEARTBEAT.md](#heartbeatmd)의 할 일 목록을 점검하는 메커니즘 —";
MERGE (n:Content {id: "content:heartbeatmd"})
SET n.name = "HEARTBEAT.md",
    n.file = "dict/06_scheduling_automation.md",
    n.description = "[Heartbeat](#heartbeat)가 점검하는 할 일 목록 파일. 사용자와 에이전트 모두 편집할 수 있는";
MERGE (n:Content {id: "content:hierarchical-memory"})
SET n.name = "Hierarchical Memory",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2023-10 (MemGPT, Packer et al.)",
    n.description = "기억을 컴퓨터의 메모리 계층처럼 **핵심(상시 로드) / 보관(필요 시 로드)** 층으로 나누는 아키텍처 —";
MERGE (n:Content {id: "content:history-visibility"})
SET n.name = "History Visibility",
    n.file = "dict/03_memory_context_session.md",
    n.description = "세션 이력 중 어떤 메시지를 모델/UI에 보일지 제어하는 규칙(내부 마커, 시스템 잡 이력 숨김 등).";
MERGE (n:Content {id: "content:historyjsonl"})
SET n.name = "history.jsonl",
    n.file = "dict/03_memory_context_session.md",
    n.description = "모든 대화 경험이 append되는 사건 로그 — 인지과학의 일화 기억(episodic memory)에 해당합니다.";
MERGE (n:Content {id: "content:hook"})
SET n.name = "Hook",
    n.file = "dict/01_core_architecture.md",
    n.description = "턴 진행의 특정 지점(시작/도구 실행/완료)에 끼어들 수 있는 확장점. \"프레임워크가 내 코드를 불러주는\"";
MERGE (n:Content {id: "content:http"})
SET n.name = "HTTP",
    n.file = "dict/05_channels_gateway_ui.md",
    n.first_appearance = "1991 (HTTP/0.9)",
    n.description = "웹의 기본 요청-응답 프로토콜. 클라이언트가 요청(메서드 + URL + 헤더 + 본문)을 보내면 서버가";
MERGE (n:Content {id: "content:httpx"})
SET n.name = "httpx",
    n.file = "dict/09_dev_stack.md",
    n.first_appearance = "2019",
    n.description = "[asyncio](#asyncio) 네이티브 HTTP 클라이언트. 커스텀 전송 계층을 끼울 수 있어";
MERGE (n:Content {id: "content:image-generation-provider"})
SET n.name = "Image Generation Provider",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "텍스트→이미지 생성 백엔드의 추상화.";
MERGE (n:Content {id: "content:image-generation-tool"})
SET n.name = "Image Generation Tool",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "텍스트 프롬프트로 이미지를 생성하는 도구.";
MERGE (n:Content {id: "content:in-context-learning"})
SET n.name = "In-Context Learning",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2020-05 (GPT-3, Brown et al.)",
    n.description = "가중치 갱신([Fine-tuning](#fine-tuning)) 없이 [Prompt](#prompt) 안의 정보만으로 모델이 새 지식과";
MERGE (n:Content {id: "content:inboundmessage"})
SET n.name = "InboundMessage",
    n.file = "dict/01_core_architecture.md",
    n.description = "외부 플랫폼에서 들어온 사용자 메시지를 표준화한 이벤트 객체(채널명, chat_id, sender_id, 본문, 미디어).";
MERGE (n:Content {id: "content:injection"})
SET n.name = "Injection",
    n.file = "dict/01_core_architecture.md",
    n.description = "에이전트가 아직 턴을 도는 **도중에** 도착한 사용자 메시지를 진행 중인 대화에 끼워 넣는 기능.";
MERGE (n:Content {id: "content:input-budget"})
SET n.name = "Input Budget",
    n.file = "dict/03_memory_context_session.md",
    n.description = "한 요청에서 입력이 쓸 수 있는 [Token](08_ai_llm_concepts.md#token) 상한:";
MERGE (n:Content {id: "content:jinja2"})
SET n.name = "Jinja2",
    n.file = "dict/09_dev_stack.md",
    n.description = "`{{ 변수 }}`, `{% if %}` 문법의 텍스트 템플릿 엔진.";
MERGE (n:Content {id: "content:json-rpc"})
SET n.name = "JSON-RPC",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2005 (2.0 규격 2010)",
    n.description = "JSON으로 원격 프로시저 호출(요청 `{method, params, id}` / 응답 `{result | error, id}`)을 표현하는";
MERGE (n:Content {id: "content:json-schema"})
SET n.name = "JSON Schema",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2009년경 (초안 표준)",
    n.description = "JSON 데이터의 구조(타입, 필수 필드, 허용값)를 JSON으로 기술하는 표준. [Tool Calling](#tool-calling)에서";
MERGE (n:Content {id: "content:jsonl"})
SET n.name = "JSONL",
    n.file = "dict/03_memory_context_session.md",
    n.first_appearance = "2013년경 (jsonlines 규약화)",
    n.description = "한 줄에 JSON 객체 하나씩 쌓는 [Append-only Log](#append-only-log) 파일 형식.";
MERGE (n:Content {id: "content:last_consolidated-cursor"})
SET n.name = "last_consolidated Cursor",
    n.file = "dict/03_memory_context_session.md",
    n.description = "세션 메타데이터에 저장되는 \"여기까지 요약 완료\" 위치 표시 — [Cursor](#cursor)의 한 사례입니다.";
MERGE (n:Content {id: "content:least-privilege"})
SET n.name = "Least Privilege",
    n.file = "dict/07_security_isolation.md",
    n.first_appearance = "1975 (Saltzer & Schroeder)",
    n.description = "각 주체에게 임무 수행에 **필요한 최소한의 권한만** 부여하는 보안 원칙(Saltzer & Schroeder, 1975).";
MERGE (n:Content {id: "content:linux-namespaces"})
SET n.name = "Linux Namespaces",
    n.file = "dict/07_security_isolation.md",
    n.first_appearance = "2002 (mount ns, Linux 2.4.19)",
    n.description = "프로세스가 보는 시스템 자원(마운트, PID, 네트워크, 사용자 등)을 **분리된 시야**로 바꾸는 커널";
MERGE (n:Content {id: "content:llm"})
SET n.name = "LLM",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2018~2020년경 (GPT/BERT→GPT-3)",
    n.description = "방대한 텍스트로 훈련되어 \"지금까지의 텍스트 다음에 올 [Token](#token)\"의 확률을 계산하는 신경망 —";
MERGE (n:Content {id: "content:loguru"})
SET n.name = "loguru",
    n.file = "dict/09_dev_stack.md",
    n.description = "설정이 거의 필요 없는 로깅 라이브러리 — nanobot 전반의 로그 출력을 담당합니다.";
MERGE (n:Content {id: "content:long-task-tool"})
SET n.name = "Long Task Tool",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "[Sustained Goal](03_memory_context_session.md#sustained-goal)을 세션 메타데이터에 등록하는";
MERGE (n:Content {id: "content:lora"})
SET n.name = "LoRA",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2021-06 (Hu et al.)",
    n.description = "[PEFT](#peft)의 특수한 기법(Hu et al., 2021) — 원래 가중치는 얼려 두고, 그 옆에 **저랭크(low-rank)";
MERGE (n:Content {id: "content:lost-in-the-middle"})
SET n.name = "Lost in the Middle",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2023-07 (Liu et al.)",
    n.description = "긴 컨텍스트에서 모델이 **중간에 놓인 정보**를 처음/끝보다 잘 놓친다는 실증 연구(Liu et al., 2023).";
MERGE (n:Content {id: "content:lsp"})
SET n.name = "LSP",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2016-06 (Microsoft)",
    n.description = "에디터와 언어 분석기를 분리한 Microsoft의 표준 — \"M개 에디터 × N개 언어\"를 M+N으로 줄인";
MERGE (n:Content {id: "content:markdown"})
SET n.name = "Markdown",
    n.file = "dict/02_tools_and_skills.md",
    n.first_appearance = "2004 (Gruber & Swartz)",
    n.description = "`#`, `-`, `**` 같은 간단한 기호로 서식을 표현하는 경량 마크업 언어. 사람이 읽고 쓰기 쉽고 LLM도 잘";
MERGE (n:Content {id: "content:max_tokens"})
SET n.name = "max_tokens",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "한 응답이 생성할 수 있는 최대 [Token](08_ai_llm_concepts.md#token) 수. 이 예약분만큼";
MERGE (n:Content {id: "content:mcp"})
SET n.name = "MCP",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2024-11 (Anthropic)",
    n.description = "Anthropic이 2024년 공개한 **도구/컨텍스트 연결 표준** — \"AI 도구의 USB-C\"라는 비유처럼, 도구";
MERGE (n:Content {id: "content:mcptoolwrapper"})
SET n.name = "MCPToolWrapper",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "[MCP](08_ai_llm_concepts.md#mcp) 서버가 제공하는 원격 도구를 nanobot";
MERGE (n:Content {id: "content:memory"})
SET n.name = "Memory",
    n.file = "dict/03_memory_context_session.md",
    n.description = "대화가 끝나도 유지되는 지식 저장소. [LLM](08_ai_llm_concepts.md#llm) 자체는 아무것도 기억하지";
MERGE (n:Content {id: "content:memorymd"})
SET n.name = "MEMORY.md",
    n.file = "dict/03_memory_context_session.md",
    n.description = "축적된 사실/선호를 담는 장기 기억 파일 — 인지과학의 의미 기억(semantic memory)에 해당합니다";
MERGE (n:Content {id: "content:messagebus"})
SET n.name = "MessageBus",
    n.file = "dict/01_core_architecture.md",
    n.description = "[Channel](#channel)과 에이전트 코어를 [Decoupling](#decoupling)하는 비동기 버스.";
MERGE (n:Content {id: "content:messagetool"})
SET n.name = "MessageTool",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "에이전트가 턴 도중 사용자에게 직접 메시지를 보내는 도구 — 긴 작업 중의 중간 보고에 쓰입니다.";
MERGE (n:Content {id: "content:model-preset"})
SET n.name = "Model Preset",
    n.file = "dict/01_core_architecture.md",
    n.description = "\"이 용도에는 이 프로바이더의 이 모델과 이 파라미터\"를 묶어 이름 붙인 설정 단위 — 수동";
MERGE (n:Content {id: "content:model-routing"})
SET n.name = "Model Routing",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "요청 성격에 따라 **다른 모델로 보내는** 전략 — 비용/품질/가용성의 균형이 목적입니다";
MERGE (n:Content {id: "content:mytool"})
SET n.name = "MyTool",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "에이전트가 자기 자신의 런타임 상태를 조회/조작하는 도구.";
MERGE (n:Content {id: "content:nanobot-sdk-facade"})
SET n.name = "Nanobot (SDK Facade)",
    n.file = "dict/01_core_architecture.md",
    n.description = "nanobot을 파이썬 라이브러리로 임베드하기 위한 진입점 클래스 — [Facade Pattern](#facade-pattern)의";
MERGE (n:Content {id: "content:openai-codex-provider"})
SET n.name = "OpenAI Codex Provider",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "ChatGPT 구독(Codex) 백엔드를 사용하는 프로바이더.";
MERGE (n:Content {id: "content:openai-compatible-api"})
SET n.name = "OpenAI-Compatible API",
    n.file = "dict/05_channels_gateway_ui.md",
    n.description = "OpenAI Chat Completions API의 요청/응답 형식(JSON 스키마, 엔드포인트 경로)을 그대로 따르는 것 —";
MERGE (n:Content {id: "content:openai-compatible-provider"})
SET n.name = "OpenAI-Compatible Provider",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "[OpenAI-Compatible API](05_channels_gateway_ui.md#openai-compatible-api)(Chat Completions 규격)를";
MERGE (n:Content {id: "content:openai-responses-provider"})
SET n.name = "OpenAI Responses Provider",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "OpenAI의 신형 Responses API(Chat Completions의 후속 규격)용 프로바이더.";
MERGE (n:Content {id: "content:optional-dependencies"})
SET n.name = "Optional Dependencies",
    n.file = "dict/09_dev_stack.md",
    n.description = "`pip install nanobot-ai[telegram]`처럼 **필요한 기능의 의존성만** 골라 설치하는 파이썬 패키징";
MERGE (n:Content {id: "content:orphan-tool-result"})
SET n.name = "Orphan Tool Result",
    n.file = "dict/03_memory_context_session.md",
    n.description = "짝이 되는 tool_call이 (절단 등으로) 사라진 tool result 메시지. 모든 tool result는 대응하는";
MERGE (n:Content {id: "content:outboundmessage"})
SET n.name = "OutboundMessage",
    n.file = "dict/01_core_architecture.md",
    n.description = "에이전트의 응답을 표준화한 이벤트 객체. [MessageBus](#messagebus)를 거쳐 원래 [Channel](#channel)이";
MERGE (n:Content {id: "content:pairing"})
SET n.name = "Pairing",
    n.file = "dict/01_core_architecture.md",
    n.description = "모르는 사람의 DM에 에이전트가 응답하지 않도록, 채널별 **페어링 코드**로 발신자를 승인하는 절차와";
MERGE (n:Content {id: "content:path-utils"})
SET n.name = "Path Utils",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "워크스페이스 스코프 도구들이 공유하는 경로 헬퍼.";
MERGE (n:Content {id: "content:peft"})
SET n.name = "PEFT",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2019 (Adapter, Houlsby et al.)",
    n.description = "[Fine-tuning](#fine-tuning)의 특수한 방법론 — 모델 전체가 아니라 **아주 작은 일부 파라미터만**";
MERGE (n:Content {id: "content:pinneddnsasynctransport"})
SET n.name = "PinnedDNSAsyncTransport",
    n.file = "dict/07_security_isolation.md",
    n.description = "[DNS Pinning](#dns-pinning)을 구현한 [httpx](09_dev_stack.md#httpx) 커스텀 전송 계층.";
MERGE (n:Content {id: "content:pkgutil"})
SET n.name = "pkgutil",
    n.file = "dict/09_dev_stack.md",
    n.description = "패키지 안의 모듈을 열거하는 파이썬 표준 라이브러리.";
MERGE (n:Content {id: "content:platform-channels"})
SET n.name = "Platform Channels",
    n.file = "dict/05_channels_gateway_ui.md",
    n.description = "Telegram, Discord, Slack, Feishu, Matrix, WhatsApp, Email 등 실제 메시징 플랫폼별";
MERGE (n:Content {id: "content:plugin-architecture"})
SET n.name = "Plugin Architecture",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "코어를 수정하지 않고 외부에서 기능을 **꽂아 넣을 수 있게** 확장점을 설계하는 방식.";
MERGE (n:Content {id: "content:producer-consumer"})
SET n.name = "Producer-Consumer",
    n.file = "dict/01_core_architecture.md",
    n.description = "생산자는 큐에 넣기만 하고 소비자는 큐에서 꺼내기만 하는 동시성 패턴. 양쪽이 서로를 기다리지 않아도";
MERGE (n:Content {id: "content:progress-hook"})
SET n.name = "Progress Hook",
    n.file = "dict/01_core_architecture.md",
    n.description = "턴 진행 상황(어떤 도구를 실행 중인지 등)을 실시간으로 밖에 알리는 [Hook](#hook)의 특수화.";
MERGE (n:Content {id: "content:progressive-disclosure"})
SET n.name = "Progressive Disclosure",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "스킬 **요약(이름+한 줄)만 상시 컨텍스트에 넣고**, 본문은 필요할 때 파일 읽기로 로드하는 2단계 구조.";
MERGE (n:Content {id: "content:prompt"})
SET n.name = "Prompt",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2018~2020년경 (GPT 계열 보급과 함께)",
    n.description = "[LLM](#llm)에 주는 입력 텍스트 전체. 모델의 행동을 바꾸는 유일한 손잡이가 프롬프트이므로,";
MERGE (n:Content {id: "content:prompt-caching"})
SET n.name = "Prompt Caching",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "요청 간 **동일한 프롬프트 앞부분(prefix)** 의 처리 결과를 API 서버가 재사용해 비용·지연을 줄이는";
MERGE (n:Content {id: "content:prompt-engineering"})
SET n.name = "Prompt Engineering",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "원하는 출력을 얻도록 [Prompt](#prompt)를 설계·개선하는 실무 기법. 역할 부여(\"너는 사서다\"),";
MERGE (n:Content {id: "content:prompt-injection"})
SET n.name = "Prompt Injection",
    n.file = "dict/07_security_isolation.md",
    n.description = "외부에서 온 **데이터 속에 숨은 지시문**이 모델의 원래 지시를 탈취하는 공격. LLM이 \"데이터\"와";
MERGE (n:Content {id: "content:prompt-toolkit"})
SET n.name = "prompt-toolkit",
    n.file = "dict/09_dev_stack.md",
    n.description = "고급 터미널 입력(멀티라인, 히스토리, 자동완성) 라이브러리 — CLI 대화 모드의 입력 담당.";
MERGE (n:Content {id: "content:provider"})
SET n.name = "Provider",
    n.file = "dict/01_core_architecture.md",
    n.description = "[LLM](08_ai_llm_concepts.md#llm) 백엔드의 공통 추상화 — \"메시지 목록과 도구 목록을 주면 응답/도구";
MERGE (n:Content {id: "content:provider-base"})
SET n.name = "Provider Base",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "모든 프로바이더가 상속하는 추상 클래스 — \"메시지 + 도구 목록 → 응답/도구 호출\"이라는 공통 계약을";
MERGE (n:Content {id: "content:provider-factory"})
SET n.name = "Provider Factory",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "[Config](01_core_architecture.md#config)를 읽어 실제 프로바이더 인스턴스를 조립하는 팩토리.";
MERGE (n:Content {id: "content:provider-registry"})
SET n.name = "Provider Registry",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "[ProviderSpec](#providerspec) 목록을 갖고 모델명/설정으로 프로바이더를 선택하는";
MERGE (n:Content {id: "content:providerspec"})
SET n.name = "ProviderSpec",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "프로바이더 하나의 명세(이름, 모델 접두 패턴, 팩토리, 필요 [Optional Dependencies](09_dev_stack.md#optional-dependencies)).";
MERGE (n:Content {id: "content:pth-file-guard"})
SET n.name = "PTH File Guard",
    n.file = "dict/07_security_isolation.md",
    n.description = "파이썬 `.pth` 파일(인터프리터 시작 시 자동 실행됨)을 통한 코드 주입을 CLI 진입 시점에 점검하는";
MERGE (n:Content {id: "content:pydantic"})
SET n.name = "Pydantic",
    n.file = "dict/09_dev_stack.md",
    n.first_appearance = "2017",
    n.description = "[Type Hint](#type-hint)를 **런타임 데이터 검증**으로 바꿔 주는 라이브러리 — 잘못된 데이터가";
MERGE (n:Content {id: "content:pydantic-settings"})
SET n.name = "pydantic-settings",
    n.file = "dict/09_dev_stack.md",
    n.description = "[Pydantic](#pydantic) 모델로 환경변수/설정 파일을 로드하는 확장 —";
MERGE (n:Content {id: "content:pypi"})
SET n.name = "PyPI",
    n.file = "dict/09_dev_stack.md",
    n.description = "파이썬 패키지의 공식 저장소 — `pip install`이 내려받는 곳. nanobot은 `nanobot-ai`라는 이름으로";
MERGE (n:Content {id: "content:pytest"})
SET n.name = "pytest",
    n.file = "dict/09_dev_stack.md",
    n.description = "파이썬 테스트 프레임워크. 이 저장소는 `asyncio_mode = \"auto\"`로 async 테스트를 데코레이터 없이";
MERGE (n:Content {id: "content:python-311"})
SET n.name = "Python 3.11+",
    n.file = "dict/09_dev_stack.md",
    n.first_appearance = "2022-10 (Python 자체는 1991)",
    n.description = "nanobot의 구현 언어와 최소 버전(`pyproject.toml`의 `requires-python`). 3.11은";
MERGE (n:Content {id: "content:questionary"})
SET n.name = "questionary",
    n.file = "dict/09_dev_stack.md",
    n.description = "대화형 선택 프롬프트(화살표로 고르기) 라이브러리 — `nanobot onboard` 마법사에 쓰입니다.";
MERGE (n:Content {id: "content:rag"})
SET n.name = "RAG",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2020-05 (Lewis et al.)",
    n.description = "질문과 관련된 문서를 [Embedding](#embedding) 검색으로 찾아 [Prompt](#prompt)에 붙여 주고 답하게";
MERGE (n:Content {id: "content:rate-limit"})
SET n.name = "Rate Limit",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "API 제공자가 정한 시간당 요청/토큰 상한. 초과 시 HTTP 429가 반환되며, 응답의 `retry-after`를";
MERGE (n:Content {id: "content:react"})
SET n.name = "ReAct",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2022-10 (Yao et al.)",
    n.description = "*ReAct: Synergizing Reasoning and Acting in Language Models*(Yao et al., 2022) — 추론(Reasoning)과";
MERGE (n:Content {id: "content:react-js"})
SET n.name = "React (JS)",
    n.file = "dict/09_dev_stack.md",
    n.first_appearance = "2013 (Meta)",
    n.description = "컴포넌트 기반 UI 자바스크립트 라이브러리 — [WebUI](05_channels_gateway_ui.md#webui)의 화면 계층.";
MERGE (n:Content {id: "content:reasoning-blocks"})
SET n.name = "Reasoning Blocks",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "일부 모델이 최종 답변과 별도로 출력하는 \"생각 과정\" 콘텐츠(Claude extended thinking 등).";
MERGE (n:Content {id: "content:reflection"})
SET n.name = "Reflection",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2023-03 (Reflexion, Shinn et al.)",
    n.description = "에이전트가 자기 경험/출력을 되돌아보고 교훈을 추출해 다음 행동을 개선하는 패턴(Reflexion,";
MERGE (n:Content {id: "content:registry-pattern"})
SET n.name = "Registry Pattern",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "\"이름 → 객체\" 매핑을 중앙 등록소 하나에 모아, 이름만 알면 어떤 구현이든 찾아 쓸 수 있게 하는 패턴.";
MERGE (n:Content {id: "content:retry"})
SET n.name = "Retry",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "[Transient Error](#transient-error)에 한해 같은 요청을 다시 보내는 것. 4xx 같은 영구 오류를";
MERGE (n:Content {id: "content:rich"})
SET n.name = "Rich",
    n.file = "dict/09_dev_stack.md",
    n.description = "터미널에 색·표·마크다운을 렌더링하는 라이브러리. CLI 대화 모드의 출력 품질을 담당합니다.";
MERGE (n:Content {id: "content:ruff"})
SET n.name = "ruff",
    n.file = "dict/09_dev_stack.md",
    n.description = "Rust로 만든 초고속 파이썬 린터/포매터. 이 저장소의 규칙: `E, F, I, N, W`(E501 제외), 라인 길이 100.";
MERGE (n:Content {id: "content:runtime-checkpoint"})
SET n.name = "Runtime Checkpoint",
    n.file = "dict/01_core_architecture.md",
    n.description = "턴 도중 상태를 저장해 크래시 후 복구할 수 있게 하는 영속화 장치. [TurnState](#turnstate)의 단계";
MERGE (n:Content {id: "content:runtime-context"})
SET n.name = "Runtime Context",
    n.file = "dict/03_memory_context_session.md",
    n.description = "매 턴 갱신되는 실행 정보 블록 — 현재 시각, 활성 [Sustained Goal](#sustained-goal) 등.";
MERGE (n:Content {id: "content:runtime-state-protocol"})
SET n.name = "Runtime State Protocol",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "[AgentLoop](01_core_architecture.md#agentloop) 상태를 [MyTool](#mytool)에 노출하는 파이썬 Protocol";
MERGE (n:Content {id: "content:sampling"})
SET n.name = "Sampling",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "[LLM](08_ai_llm_concepts.md#llm)이 다음 [Token](08_ai_llm_concepts.md#token)을 고를 때 확률분포에서";
MERGE (n:Content {id: "content:sandbox"})
SET n.name = "Sandbox",
    n.file = "dict/07_security_isolation.md",
    n.description = "프로그램을 제한된 환경(\"모래 놀이터\") 안에서 실행해, 잘못되어도 피해가 그 안에 갇히게 하는 격리";
MERGE (n:Content {id: "content:sandbox-backend"})
SET n.name = "Sandbox Backend",
    n.file = "dict/07_security_isolation.md",
    n.description = "셸 명령을 감싸는 격리 구현의 추상화 — 환경에 따라 [bubblewrap](#bubblewrap),";
MERGE (n:Content {id: "content:sdk-clients"})
SET n.name = "SDK Clients",
    n.file = "dict/05_channels_gateway_ui.md",
    n.description = "게이트웨이에 원격 접속하는 파이썬 클라이언트. 인프로세스 임베드인";
MERGE (n:Content {id: "content:seccomp"})
SET n.name = "seccomp",
    n.file = "dict/07_security_isolation.md",
    n.first_appearance = "2005 (Linux 2.6.12)",
    n.description = "프로세스가 호출할 수 있는 시스템 콜을 화이트리스트로 제한하는 리눅스 커널 기능.";
MERGE (n:Content {id: "content:self-attention"})
SET n.name = "Self-Attention",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2016~2017 (intra-attention → Transformer)",
    n.description = "[Attention](#attention)의 파생 — 입력이 **자기 자신에게** 어텐션을 적용해, 각";
MERGE (n:Content {id: "content:session"})
SET n.name = "Session",
    n.file = "dict/01_core_architecture.md",
    n.description = "하나의 대화 맥락과 그 이력. \"어제 하던 이야기\"를 이어가려면 어딘가에 대화가 저장되어 있어야 하는데,";
MERGE (n:Content {id: "content:session-delivery"})
SET n.name = "Session Delivery",
    n.file = "dict/06_scheduling_automation.md",
    n.description = "크론 실행 결과를 어느 세션/채널로 전달할지 결정하는 계층.";
MERGE (n:Content {id: "content:session-key"})
SET n.name = "Session Key",
    n.file = "dict/01_core_architecture.md",
    n.description = "세션을 식별하는 문자열. 채널·chat_id 조합으로 결정되며, 같은 키의 메시지는 같은 대화 이력을 공유합니다.";
MERGE (n:Content {id: "content:session-manager"})
SET n.name = "Session Manager",
    n.file = "dict/03_memory_context_session.md",
    n.description = "[Session](01_core_architecture.md#session)의 [JSONL](#jsonl) 저장/로드/압축을 담당.";
MERGE (n:Content {id: "content:skill"})
SET n.name = "Skill",
    n.file = "dict/01_core_architecture.md",
    n.description = "코드가 아니라 **마크다운([SKILL.md](02_tools_and_skills.md#skillmd))** 로 기술된 작업 절차/지식.";
MERGE (n:Content {id: "content:skill-creator"})
SET n.name = "skill-creator",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "\"새 스킬을 만드는 방법\"을 기술한 내장 스킬 — 에이전트가 **스스로 능력을 확장**할 수 있게 하는";
MERGE (n:Content {id: "content:skill-library"})
SET n.name = "Skill Library",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "에이전트가 획득한 능력을 **재사용 가능한 형태로 축적**하는 저장소 개념 — [Voyager](#voyager)가";
MERGE (n:Content {id: "content:skillmd"})
SET n.name = "SKILL.md",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "스킬 하나를 기술하는 마크다운 파일 형식 — [Frontmatter](#frontmatter) 메타데이터(이름, 한 줄 설명)";
MERGE (n:Content {id: "content:skillsloader"})
SET n.name = "SkillsLoader",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "내장(`nanobot/skills/`)과 워크스페이스의 [Skill](01_core_architecture.md#skill)을 찾아 읽는 로더.";
MERGE (n:Content {id: "content:slash-command"})
SET n.name = "Slash Command",
    n.file = "dict/01_core_architecture.md",
    n.description = "`/new`, `/help`처럼 채팅에서 바로 실행되는 내장 명령. [LLM](08_ai_llm_concepts.md#llm) 호출 없이";
MERGE (n:Content {id: "content:sliding-window"})
SET n.name = "Sliding Window",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "항상 **최근 N개만** 유지하고 오래된 것부터 버리는/접는 기법 — 대화에서는 최근 문맥이 가장 중요하다는";
MERGE (n:Content {id: "content:soulmd"})
SET n.name = "SOUL.md",
    n.file = "dict/03_memory_context_session.md",
    n.description = "에이전트의 성격/정체성을 정의하는 파일. [System Prompt](#system-prompt)에 주입되며,";
MERGE (n:Content {id: "content:spa"})
SET n.name = "SPA",
    n.file = "dict/05_channels_gateway_ui.md",
    n.description = "페이지 이동 없이 자바스크립트가 화면을 갈아끼우는 웹앱 형태. 첫 로드 후에는 서버와 데이터만";
MERGE (n:Content {id: "content:spawntool"})
SET n.name = "SpawnTool",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "[Subagent](01_core_architecture.md#subagent)를 띄워 작업을 위임하는 도구.";
MERGE (n:Content {id: "content:sse"})
SET n.name = "SSE",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2009년경 (HTML5 표준화)",
    n.description = "[HTTP](05_channels_gateway_ui.md#http) 연결을 열어 두고 서버가 텍스트 이벤트를 단방향으로 흘려";
MERGE (n:Content {id: "content:ssrf"})
SET n.name = "SSRF",
    n.file = "dict/07_security_isolation.md",
    n.description = "서버(여기서는 에이전트)를 속여 **공격자가 직접 접근할 수 없는 내부 자원**에 대신 요청하게 하는";
MERGE (n:Content {id: "content:state-machine"})
SET n.name = "State Machine",
    n.file = "dict/01_core_architecture.md",
    n.description = "시스템이 가질 수 있는 **상태(state)의 유한한 집합**과 상태 간 **전이(transition) 규칙**으로 동작을";
MERGE (n:Content {id: "content:stdio-transport"})
SET n.name = "stdio Transport",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "로컬 자식 프로세스와 stdin/stdout 파이프로 [JSON-RPC](#json-rpc)를 주고받는 [MCP](#mcp) 전송";
MERGE (n:Content {id: "content:streamable-http"})
SET n.name = "Streamable HTTP",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2025-03 (MCP 규격 개정)",
    n.description = "[MCP](#mcp)의 신형 원격 전송 — 단일 HTTP 엔드포인트로 요청하고 응답을 스트리밍할 수 있어";
MERGE (n:Content {id: "content:streaming"})
SET n.name = "Streaming",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "응답이 완성되기를 기다리지 않고 [Delta](#delta)(조각) 단위로 받는 방식. 첫 글자까지의 체감 지연을";
MERGE (n:Content {id: "content:subagent"})
SET n.name = "Subagent",
    n.file = "dict/01_core_architecture.md",
    n.description = "메인 에이전트가 [SpawnTool](02_tools_and_skills.md#spawntool)로 띄우는 **격리된 배경 작업자**.";
MERGE (n:Content {id: "content:summarization"})
SET n.name = "Summarization",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "긴 텍스트를 짧게 줄이되 핵심을 보존하는 것 — [LLM](#llm) 스스로가 훌륭한 요약기라는 점을 이용해,";
MERGE (n:Content {id: "content:sustained-goal"})
SET n.name = "Sustained Goal",
    n.file = "dict/03_memory_context_session.md",
    n.description = "한 [Turn](01_core_architecture.md#turn)을 넘어 계속 추적되는 목표.";
MERGE (n:Content {id: "content:system-prompt"})
SET n.name = "System Prompt",
    n.file = "dict/03_memory_context_session.md",
    n.description = "모델에게 정체성·규칙·환경을 알려주는 최상단 지시문 — [Prompt](08_ai_llm_concepts.md#prompt)의 특수한";
MERGE (n:Content {id: "content:temperature"})
SET n.name = "Temperature",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "[Sampling](#sampling) 무작위성 조절 파라미터. 0에 가까우면 가장 확률 높은 토큰만 골라 결정적이고,";
MERGE (n:Content {id: "content:tiktoken"})
SET n.name = "tiktoken",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2022-12",
    n.description = "OpenAI의 [BPE](#bpe) 토크나이저 구현(Rust 코어라 빠름). nanobot은";
MERGE (n:Content {id: "content:timeout"})
SET n.name = "Timeout",
    n.file = "dict/07_security_isolation.md",
    n.description = "작업에 시간 상한을 걸어 초과 시 강제 종료하는 장치. 무한 루프, 응답 없는 네트워크로부터";
MERGE (n:Content {id: "content:toctou"})
SET n.name = "TOCTOU",
    n.file = "dict/07_security_isolation.md",
    n.description = "\"검사한 시점\"과 \"사용한 시점\" 사이에 상태가 바뀌어 검사가 무효가 되는 경쟁 조건(race condition)";
MERGE (n:Content {id: "content:token"})
SET n.name = "Token",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "[LLM](#llm)이 텍스트를 처리하는 최소 단위 — 단어보다 작을 수 있는 조각입니다. 비용, 속도,";
MERGE (n:Content {id: "content:tokenizer"})
SET n.name = "Tokenizer",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "텍스트 ↔ [Token](#token) 열 변환기. 모델마다 어휘와 분절 규칙이 달라, 같은 문장도 모델에 따라";
MERGE (n:Content {id: "content:tool"})
SET n.name = "Tool",
    n.file = "dict/01_core_architecture.md",
    n.description = "[LLM](08_ai_llm_concepts.md#llm)이 호출할 수 있는 능력 단위. 이름·설명·파라미터";
MERGE (n:Content {id: "content:tool-calling"})
SET n.name = "Tool Calling",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2023-06 (OpenAI function calling API)",
    n.description = "[LLM](#llm)이 자연어 대신 **구조화된 호출 요청**(함수명 + [JSON Schema](#json-schema) 인자)을";
MERGE (n:Content {id: "content:tool-discovery"})
SET n.name = "Tool Discovery",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "`tools/` 패키지를 [pkgutil](09_dev_stack.md#pkgutil)로 스캔해 도구 모듈을 자동 등록하는 메커니즘.";
MERGE (n:Content {id: "content:tool-hint"})
SET n.name = "Tool Hint",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "\"지금 어떤 도구가 실행 중인지\"를 UI에 실시간 표시하는 진행 신호.";
MERGE (n:Content {id: "content:tool-schema"})
SET n.name = "Tool Schema",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "도구 파라미터를 [JSON Schema](08_ai_llm_concepts.md#json-schema)로 선언하기 위한 타입 클래스들";
MERGE (n:Content {id: "content:tool-scope"})
SET n.name = "Tool Scope",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "각 도구가 쓰일 수 있는 문맥(`core`, `subagent`)을 제한하는 속성(`_scopes`).";
MERGE (n:Content {id: "content:toolregistry"})
SET n.name = "ToolRegistry",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "등록된 모든 [Tool](01_core_architecture.md#tool)의 목록을 관리하고 이름으로 실행을 디스패치하는";
MERGE (n:Content {id: "content:toolresult"})
SET n.name = "ToolResult",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "도구 실행의 표준 반환 객체(성공 내용 또는 `error`). 핵심 설계는 **오류도 삼키지 않고 모델에게";
MERGE (n:Content {id: "content:transcription"})
SET n.name = "Transcription",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "음성 메시지를 텍스트로 변환(STT)하는 계층. 음성 채널 메시지가 텍스트 파이프라인에 합류할 수 있게";
MERGE (n:Content {id: "content:transformer"})
SET n.name = "Transformer",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2017-06 (Vaswani et al.)",
    n.description = "논문 *Attention Is All You Need*(Vaswani et al., 2017)가 제안한 신경망 구조로, 현대";
MERGE (n:Content {id: "content:transient-error"})
SET n.name = "Transient Error",
    n.file = "dict/04_providers_and_llm.md",
    n.description = "시간이 지나면 스스로 해소될 수 있는 오류 — 재시도할 가치가 있는 것들.";
MERGE (n:Content {id: "content:trigger"})
SET n.name = "Trigger",
    n.file = "dict/06_scheduling_automation.md",
    n.description = "시간이 아닌 **사건**으로 에이전트 턴을 시작시키는 확장점. [Cron](#cron)이 \"몇 시에\"라면 트리거는";
MERGE (n:Content {id: "content:ttl"})
SET n.name = "TTL",
    n.file = "dict/03_memory_context_session.md",
    n.description = "데이터나 상태가 \"얼마나 오래 유효한가\"를 정하는 만료 시간. 캐시 만료, DNS 레코드 수명 등에 두루";
MERGE (n:Content {id: "content:turn"})
SET n.name = "Turn",
    n.file = "dict/01_core_architecture.md",
    n.description = "사용자 메시지 하나에 대한 요청-응답 한 사이클. 한 턴 안에서 [AgentRunner](#agentrunner)가 여러 번의";
MERGE (n:Content {id: "content:turn-continuation"})
SET n.name = "Turn Continuation",
    n.file = "dict/01_core_architecture.md",
    n.description = "반복 상한 등으로 중단된 턴을 다음 요청에서 이어서 진행할 수 있게 하는 메커니즘. 긴 작업이 상한에";
MERGE (n:Content {id: "content:turnstate"})
SET n.name = "TurnState",
    n.file = "dict/01_core_architecture.md",
    n.description = "한 [Turn](#turn)의 진행 단계를 나타내는 [State Machine](#state-machine) 국면:";
MERGE (n:Content {id: "content:type-hint"})
SET n.name = "Type Hint",
    n.file = "dict/09_dev_stack.md",
    n.description = "파이썬 코드에 변수/인자/반환의 타입을 표기하는 문법(`def f(x: int) -> str:`). 실행에는 영향이";
MERGE (n:Content {id: "content:typer"})
SET n.name = "Typer",
    n.file = "dict/09_dev_stack.md",
    n.first_appearance = "2019",
    n.description = "[Type Hint](#type-hint) 기반 CLI 프레임워크 — 함수 시그니처가 곧 명령 인터페이스가 됩니다.";
MERGE (n:Content {id: "content:typescript"})
SET n.name = "TypeScript",
    n.file = "dict/09_dev_stack.md",
    n.first_appearance = "2012 (Microsoft)",
    n.description = "자바스크립트에 정적 타입을 더한 언어 — 파이썬 쪽 [Type Hint](#type-hint)+[Pydantic](#pydantic)과";
MERGE (n:Content {id: "content:unified-session"})
SET n.name = "Unified Session",
    n.file = "dict/01_core_architecture.md",
    n.description = "여러 [Channel](#channel)이 **하나의 세션 키를 공유**해 대화 이력을 이어가는 기능.";
MERGE (n:Content {id: "content:usermd"})
SET n.name = "USER.md",
    n.file = "dict/03_memory_context_session.md",
    n.description = "사용자에 대해 알게 된 정보(선호, 습관, 맥락)를 담는 파일.";
MERGE (n:Content {id: "content:vector-database"})
SET n.name = "Vector Database",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "[Embedding](#embedding) 벡터를 저장하고 \"가장 가까운 이웃\"을 빠르게 찾는 특화 DB";
MERGE (n:Content {id: "content:vite"})
SET n.name = "Vite",
    n.file = "dict/09_dev_stack.md",
    n.first_appearance = "2020",
    n.description = "프런트엔드 빌드 도구 — 개발 서버(HMR)와 프로덕션 번들링을 담당합니다.";
MERGE (n:Content {id: "content:voyager"})
SET n.name = "Voyager",
    n.file = "dict/08_ai_llm_concepts.md",
    n.first_appearance = "2023-05 (Wang et al.)",
    n.description = "*Voyager: An Open-Ended Embodied Agent with LLMs*(Wang et al., 2023) — 마인크래프트에서";
MERGE (n:Content {id: "content:web-tools"})
SET n.name = "Web Tools",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "URL 가져오기(fetch)와 웹 검색 도구. 검색은 [ddgs](09_dev_stack.md#ddgs)(API 키 불필요)를 쓰고,";
MERGE (n:Content {id: "content:websocket"})
SET n.name = "WebSocket",
    n.file = "dict/05_channels_gateway_ui.md",
    n.first_appearance = "2011-12 (RFC 6455)",
    n.description = "[HTTP](#http)로 시작해 업그레이드되는 **양방향 상시 연결** 프로토콜(RFC 6455). 요청-응답만 가능한";
MERGE (n:Content {id: "content:websocket-channel"})
SET n.name = "WebSocket Channel",
    n.file = "dict/05_channels_gateway_ui.md",
    n.description = "[WebUI](#webui)가 접속하는 [WebSocket](#websocket) 기반 채널. 다른 채널과 달리 외부 플랫폼이 아니라";
MERGE (n:Content {id: "content:websocket-multiplex-protocol"})
SET n.name = "WebSocket Multiplex Protocol",
    n.file = "dict/05_channels_gateway_ui.md",
    n.description = "하나의 [WebSocket](#websocket) 연결 위에 여러 논리 스트림(대화 메시지, 진행 이벤트, 세션 제어)을";
MERGE (n:Content {id: "content:websockets"})
SET n.name = "websockets",
    n.file = "dict/09_dev_stack.md",
    n.description = "파이썬 [WebSocket](05_channels_gateway_ui.md#websocket) 서버/클라이언트 라이브러리 —";
MERGE (n:Content {id: "content:webui"})
SET n.name = "WebUI",
    n.file = "dict/05_channels_gateway_ui.md",
    n.description = "[React (JS)](09_dev_stack.md#react-js) + [TypeScript](09_dev_stack.md#typescript) +";
MERGE (n:Content {id: "content:webui-turn-coordinator"})
SET n.name = "WebUI Turn Coordinator",
    n.file = "dict/03_memory_context_session.md",
    n.description = "[WebUI](05_channels_gateway_ui.md#webui)에 필요한 턴 이벤트(`_turn_end`, `_goal_status`, 제목 갱신)를";
MERGE (n:Content {id: "content:workspace"})
SET n.name = "Workspace",
    n.file = "dict/01_core_architecture.md",
    n.description = "에이전트의 홈 디렉토리. 세션([JSONL](03_memory_context_session.md#jsonl)),";
MERGE (n:Content {id: "content:workspace-access"})
SET n.name = "Workspace Access",
    n.file = "dict/07_security_isolation.md",
    n.description = "[Workspace Policy](#workspace-policy)의 접근 검사 구현부(경로 정규화, 경계 판정 함수).";
MERGE (n:Content {id: "content:workspace-policy"})
SET n.name = "Workspace Policy",
    n.file = "dict/07_security_isolation.md",
    n.description = "파일 접근을 [Workspace](01_core_architecture.md#workspace) 경계 안으로 제한하는 정책 계층.";
MERGE (n:Content {id: "content:writestdintool"})
SET n.name = "WriteStdinTool",
    n.file = "dict/02_tools_and_skills.md",
    n.description = "살아 있는 [Exec Session](#exec-session) 프로세스의 표준입력에 텍스트/특수키를 쓰는 도구.";
MERGE (n:Content {id: "content:zero-shot"})
SET n.name = "Zero-shot",
    n.file = "dict/08_ai_llm_concepts.md",
    n.description = "예시 없이 지시만으로 과제를 수행하게 하는 것 — [Few-shot Learning](#few-shot-learning)의 반대";
MERGE (n:ContentClass {id: "class:artifact"})
SET n.name = "Artifact",
    n.file = "dict/00_content_classes.md";
MERGE (n:ContentClass {id: "class:component"})
SET n.name = "Component",
    n.file = "dict/00_content_classes.md";
MERGE (n:ContentClass {id: "class:concept"})
SET n.name = "Concept",
    n.file = "dict/00_content_classes.md";
MERGE (n:ContentClass {id: "class:mechanism"})
SET n.name = "Mechanism",
    n.file = "dict/00_content_classes.md";
MERGE (n:ContentClass {id: "class:principle"})
SET n.name = "Principle",
    n.file = "dict/00_content_classes.md";
MERGE (n:ContentClass {id: "class:protocol"})
SET n.name = "Protocol",
    n.file = "dict/00_content_classes.md";
MERGE (n:ContentClass {id: "class:research"})
SET n.name = "Research",
    n.file = "dict/00_content_classes.md";
MERGE (n:ContentClass {id: "class:technology"})
SET n.name = "Technology",
    n.file = "dict/00_content_classes.md";
MERGE (n:ContentClass {id: "class:threat"})
SET n.name = "Threat",
    n.file = "dict/00_content_classes.md";

MATCH (a:Content {id: "content:_skip_modules"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:adapter-pattern"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:agent"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:agent-loop-concept"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:agent-skills"}), (b:ContentClass {id: "class:protocol"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:agentloop"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:agentrunner"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:anthropic-provider"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:api-server"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:append-only-log"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:apply_patch"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:apps"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:asyncio"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:asyncioqueue"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:atomic-write"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:attention"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:autocompact"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:automation-turns"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:azure-openai-provider"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:bedrock-provider"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:bert"}), (b:ContentClass {id: "class:research"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:bootstrap-templates"}), (b:ContentClass {id: "class:artifact"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:bound-runner"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:bpe"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:bubblewrap"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:bun"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:camelcase-alias"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:chain-of-thought"}), (b:ContentClass {id: "class:research"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:channel"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:channel-manager"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:channel-registry"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:circuit-breaker"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:command-router"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:config"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:consolidation"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:container"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:context"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:context-compression"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:context-governance"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:context-window"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:contextvar"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:coroutine"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:cron"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:cron-expression"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:cron-job"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:cron-store"}), (b:ContentClass {id: "class:artifact"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:cron-tool"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:cron-turns"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:croniter"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:cronservice"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:cursor"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:ddgs"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:decoupling"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:defense-in-depth"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:delta"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:dns-pinning"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:dns-rebinding"}), (b:ContentClass {id: "class:threat"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:dream"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:dream-cursor"}), (b:ContentClass {id: "class:artifact"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:dulwich"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:durable-files"}), (b:ContentClass {id: "class:artifact"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:embedding"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:entry-point-plugin"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:entry-points"}), (b:ContentClass {id: "class:protocol"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:event-loop"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:exact-pinning"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:exec-session"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:exectool"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:exponential-backoff"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:facade-pattern"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:fallbackprovider"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:few-shot-learning"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:file-state"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:filelock"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:filesystem-tools"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:fine-tuning"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:frontmatter"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:fsync"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:gateway"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:gateway-service"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:git"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:github-copilot-provider"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:goal-state"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:graceful-degradation"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:grounding"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:hallucination"}), (b:ContentClass {id: "class:threat"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:hatchling"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:health-endpoint"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:heartbeat"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:heartbeatmd"}), (b:ContentClass {id: "class:artifact"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:hierarchical-memory"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:history-visibility"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:historyjsonl"}), (b:ContentClass {id: "class:artifact"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:hook"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:http"}), (b:ContentClass {id: "class:protocol"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:httpx"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:image-generation-provider"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:image-generation-tool"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:in-context-learning"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:inboundmessage"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:injection"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:input-budget"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:jinja2"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:json-rpc"}), (b:ContentClass {id: "class:protocol"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:json-schema"}), (b:ContentClass {id: "class:protocol"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:jsonl"}), (b:ContentClass {id: "class:artifact"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:last_consolidated-cursor"}), (b:ContentClass {id: "class:artifact"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:least-privilege"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:linux-namespaces"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:llm"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:loguru"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:long-task-tool"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:lora"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:lost-in-the-middle"}), (b:ContentClass {id: "class:research"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:lsp"}), (b:ContentClass {id: "class:protocol"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:markdown"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:max_tokens"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:mcp"}), (b:ContentClass {id: "class:protocol"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:mcptoolwrapper"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:memory"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:memorymd"}), (b:ContentClass {id: "class:artifact"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:messagebus"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:messagetool"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:model-preset"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:model-routing"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:mytool"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:nanobot-sdk-facade"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:openai-codex-provider"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:openai-compatible-api"}), (b:ContentClass {id: "class:protocol"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:openai-compatible-provider"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:openai-responses-provider"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:optional-dependencies"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:orphan-tool-result"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:outboundmessage"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:pairing"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:path-utils"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:peft"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:pinneddnsasynctransport"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:pkgutil"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:platform-channels"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:plugin-architecture"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:producer-consumer"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:progress-hook"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:progressive-disclosure"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:prompt"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:prompt-caching"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:prompt-engineering"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:prompt-injection"}), (b:ContentClass {id: "class:threat"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:prompt-toolkit"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:provider"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:provider-base"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:provider-factory"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:provider-registry"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:providerspec"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:pth-file-guard"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:pydantic"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:pydantic-settings"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:pypi"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:pytest"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:python-311"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:questionary"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:rag"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:rate-limit"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:react"}), (b:ContentClass {id: "class:research"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:react-js"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:reasoning-blocks"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:reflection"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:registry-pattern"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:retry"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:rich"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:ruff"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:runtime-checkpoint"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:runtime-context"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:runtime-state-protocol"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:sampling"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:sandbox"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:sandbox-backend"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:sdk-clients"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:seccomp"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:self-attention"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:session"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:session-delivery"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:session-key"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:session-manager"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:skill"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:skill-creator"}), (b:ContentClass {id: "class:artifact"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:skill-library"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:skillmd"}), (b:ContentClass {id: "class:artifact"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:skillsloader"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:slash-command"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:sliding-window"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:soulmd"}), (b:ContentClass {id: "class:artifact"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:spa"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:spawntool"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:sse"}), (b:ContentClass {id: "class:protocol"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:ssrf"}), (b:ContentClass {id: "class:threat"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:state-machine"}), (b:ContentClass {id: "class:principle"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:stdio-transport"}), (b:ContentClass {id: "class:protocol"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:streamable-http"}), (b:ContentClass {id: "class:protocol"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:streaming"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:subagent"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:summarization"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:sustained-goal"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:system-prompt"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:temperature"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:tiktoken"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:timeout"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:toctou"}), (b:ContentClass {id: "class:threat"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:token"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:tokenizer"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:tool"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:tool-calling"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:tool-discovery"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:tool-hint"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:tool-schema"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:tool-scope"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:toolregistry"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:toolresult"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:transcription"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:transformer"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:transient-error"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:trigger"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:ttl"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:turn"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:turn-continuation"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:turnstate"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:type-hint"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:typer"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:typescript"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:unified-session"}), (b:ContentClass {id: "class:mechanism"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:usermd"}), (b:ContentClass {id: "class:artifact"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:vector-database"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:vite"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:voyager"}), (b:ContentClass {id: "class:research"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:web-tools"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:websocket"}), (b:ContentClass {id: "class:protocol"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:websocket-channel"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:websocket-multiplex-protocol"}), (b:ContentClass {id: "class:protocol"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:websockets"}), (b:ContentClass {id: "class:technology"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:webui"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:webui-turn-coordinator"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:workspace"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:workspace-access"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:workspace-policy"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:writestdintool"}), (b:ContentClass {id: "class:component"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:zero-shot"}), (b:ContentClass {id: "class:concept"}) MERGE (a)-[:BELONGS_TO]->(b);
MATCH (a:Content {id: "content:_skip_modules"}), (b:Content {id: "content:mcptoolwrapper"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:_skip_modules"}), (b:Content {id: "content:sandbox"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:adapter-pattern"}), (b:Content {id: "content:inboundmessage"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agent"}), (b:Content {id: "content:agent-loop-concept"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agent"}), (b:Content {id: "content:llm"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agent"}), (b:Content {id: "content:tool"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agent-skills"}), (b:Content {id: "content:frontmatter"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agentloop"}), (b:Content {id: "content:context"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agentloop"}), (b:Content {id: "content:inboundmessage"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agentloop"}), (b:Content {id: "content:outboundmessage"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agentloop"}), (b:Content {id: "content:session-key"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agentloop"}), (b:Content {id: "content:turn"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agentrunner"}), (b:Content {id: "content:agentloop"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agentrunner"}), (b:Content {id: "content:provider"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agentrunner"}), (b:Content {id: "content:streaming"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agentrunner"}), (b:Content {id: "content:tool"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agentrunner"}), (b:Content {id: "content:toolregistry"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agentrunner"}), (b:Content {id: "content:turn"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:append-only-log"}), (b:Content {id: "content:historyjsonl"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:asyncioqueue"}), (b:Content {id: "content:coroutine"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:asyncioqueue"}), (b:Content {id: "content:messagebus"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:autocompact"}), (b:Content {id: "content:sliding-window"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:azure-openai-provider"}), (b:Content {id: "content:optional-dependencies"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:bootstrap-templates"}), (b:Content {id: "content:heartbeatmd"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:bootstrap-templates"}), (b:Content {id: "content:soulmd"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:bootstrap-templates"}), (b:Content {id: "content:workspace"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:bound-runner"}), (b:Content {id: "content:turn"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:bun"}), (b:Content {id: "content:webui"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:chain-of-thought"}), (b:Content {id: "content:reasoning-blocks"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:channel"}), (b:Content {id: "content:entry-point-plugin"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:channel"}), (b:Content {id: "content:inboundmessage"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:channel"}), (b:Content {id: "content:outboundmessage"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:channel"}), (b:Content {id: "content:pkgutil"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:channel"}), (b:Content {id: "content:tool-discovery"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:channel-registry"}), (b:Content {id: "content:entry-point-plugin"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:channel-registry"}), (b:Content {id: "content:pkgutil"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:channel-registry"}), (b:Content {id: "content:tool-discovery"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:config"}), (b:Content {id: "content:camelcase-alias"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:consolidation"}), (b:Content {id: "content:last_consolidated-cursor"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:consolidation"}), (b:Content {id: "content:llm"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:container"}), (b:Content {id: "content:bubblewrap"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:context"}), (b:Content {id: "content:llm"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:context"}), (b:Content {id: "content:memory"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:context"}), (b:Content {id: "content:skill"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:context-compression"}), (b:Content {id: "content:consolidation"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:context-compression"}), (b:Content {id: "content:context-window"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:context-window"}), (b:Content {id: "content:context-compression"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:context-window"}), (b:Content {id: "content:memory"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:context-window"}), (b:Content {id: "content:progressive-disclosure"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:context-window"}), (b:Content {id: "content:self-attention"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:context-window"}), (b:Content {id: "content:token"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:cron"}), (b:Content {id: "content:gateway"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:cron-job"}), (b:Content {id: "content:cron-expression"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:cron-job"}), (b:Content {id: "content:cron-tool"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:cron-store"}), (b:Content {id: "content:cron-job"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:cron-tool"}), (b:Content {id: "content:cron-job"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:cron-turns"}), (b:Content {id: "content:history-visibility"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:croniter"}), (b:Content {id: "content:cron-expression"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:croniter"}), (b:Content {id: "content:cronservice"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:cronservice"}), (b:Content {id: "content:cron-job"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:cronservice"}), (b:Content {id: "content:gateway"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:ddgs"}), (b:Content {id: "content:web-tools"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:decoupling"}), (b:Content {id: "content:channel"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:defense-in-depth"}), (b:Content {id: "content:dns-pinning"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:defense-in-depth"}), (b:Content {id: "content:sandbox-backend"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:defense-in-depth"}), (b:Content {id: "content:ssrf"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:defense-in-depth"}), (b:Content {id: "content:timeout"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:defense-in-depth"}), (b:Content {id: "content:workspace-policy"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:delta"}), (b:Content {id: "content:agentrunner"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:dns-pinning"}), (b:Content {id: "content:dns-rebinding"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:dream"}), (b:Content {id: "content:cron"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:dream"}), (b:Content {id: "content:durable-files"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:dream"}), (b:Content {id: "content:git"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:dream"}), (b:Content {id: "content:hallucination"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:dream"}), (b:Content {id: "content:historyjsonl"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:dream-cursor"}), (b:Content {id: "content:historyjsonl"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:dulwich"}), (b:Content {id: "content:dream"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:durable-files"}), (b:Content {id: "content:dream"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:exectool"}), (b:Content {id: "content:sandbox-backend"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:exectool"}), (b:Content {id: "content:timeout"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:facade-pattern"}), (b:Content {id: "content:agentloop"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:facade-pattern"}), (b:Content {id: "content:provider"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:fallbackprovider"}), (b:Content {id: "content:exponential-backoff"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:file-state"}), (b:Content {id: "content:_skip_modules"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:filesystem-tools"}), (b:Content {id: "content:workspace-policy"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:gateway"}), (b:Content {id: "content:agentloop"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:gateway"}), (b:Content {id: "content:cronservice"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:gateway"}), (b:Content {id: "content:webui"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:gateway-service"}), (b:Content {id: "content:agentloop"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:gateway-service"}), (b:Content {id: "content:autocompact"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:gateway-service"}), (b:Content {id: "content:cronservice"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:git"}), (b:Content {id: "content:dream"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:grounding"}), (b:Content {id: "content:hallucination"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:hallucination"}), (b:Content {id: "content:dream"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:hallucination"}), (b:Content {id: "content:git"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:hallucination"}), (b:Content {id: "content:token"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:hatchling"}), (b:Content {id: "content:webui"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:health-endpoint"}), (b:Content {id: "content:http"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:heartbeat"}), (b:Content {id: "content:cron-job"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:heartbeat"}), (b:Content {id: "content:messagetool"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:heartbeatmd"}), (b:Content {id: "content:markdown"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:hierarchical-memory"}), (b:Content {id: "content:historyjsonl"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:hierarchical-memory"}), (b:Content {id: "content:memorymd"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:historyjsonl"}), (b:Content {id: "content:dream"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:historyjsonl"}), (b:Content {id: "content:durable-files"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:hook"}), (b:Content {id: "content:sdk-clients"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:http"}), (b:Content {id: "content:api-server"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:http"}), (b:Content {id: "content:httpx"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:httpx"}), (b:Content {id: "content:asyncio"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:image-generation-provider"}), (b:Content {id: "content:image-generation-tool"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:image-generation-tool"}), (b:Content {id: "content:image-generation-provider"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:in-context-learning"}), (b:Content {id: "content:memory"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:in-context-learning"}), (b:Content {id: "content:prompt"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:in-context-learning"}), (b:Content {id: "content:skill"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:inboundmessage"}), (b:Content {id: "content:channel"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:inboundmessage"}), (b:Content {id: "content:pydantic"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:injection"}), (b:Content {id: "content:prompt-injection"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:input-budget"}), (b:Content {id: "content:token"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:jinja2"}), (b:Content {id: "content:system-prompt"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:json-rpc"}), (b:Content {id: "content:stdio-transport"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:json-schema"}), (b:Content {id: "content:tool-calling"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:least-privilege"}), (b:Content {id: "content:dream"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:least-privilege"}), (b:Content {id: "content:spawntool"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:least-privilege"}), (b:Content {id: "content:subagent"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:llm"}), (b:Content {id: "content:provider"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:llm"}), (b:Content {id: "content:token"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:long-task-tool"}), (b:Content {id: "content:runtime-context"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:long-task-tool"}), (b:Content {id: "content:sustained-goal"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:lost-in-the-middle"}), (b:Content {id: "content:runtime-context"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:markdown"}), (b:Content {id: "content:memorymd"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:max_tokens"}), (b:Content {id: "content:input-budget"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:max_tokens"}), (b:Content {id: "content:token"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:mcptoolwrapper"}), (b:Content {id: "content:pinneddnsasynctransport"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:mcptoolwrapper"}), (b:Content {id: "content:sse"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:mcptoolwrapper"}), (b:Content {id: "content:stdio-transport"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:memory"}), (b:Content {id: "content:git"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:memory"}), (b:Content {id: "content:llm"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:memory"}), (b:Content {id: "content:markdown"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:memorymd"}), (b:Content {id: "content:hierarchical-memory"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:messagebus"}), (b:Content {id: "content:agentloop"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:messagebus"}), (b:Content {id: "content:asyncioqueue"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:messagebus"}), (b:Content {id: "content:channel"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:messagetool"}), (b:Content {id: "content:heartbeat"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:model-preset"}), (b:Content {id: "content:dream"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:mytool"}), (b:Content {id: "content:agentloop"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:openai-compatible-api"}), (b:Content {id: "content:api-server"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:openai-compatible-api"}), (b:Content {id: "content:openai-compatible-provider"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:openai-compatible-provider"}), (b:Content {id: "content:openai-compatible-api"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:orphan-tool-result"}), (b:Content {id: "content:provider"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:outboundmessage"}), (b:Content {id: "content:channel"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:path-utils"}), (b:Content {id: "content:workspace-policy"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:pinneddnsasynctransport"}), (b:Content {id: "content:mcptoolwrapper"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:pinneddnsasynctransport"}), (b:Content {id: "content:web-tools"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:pkgutil"}), (b:Content {id: "content:channel-registry"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:pkgutil"}), (b:Content {id: "content:tool-discovery"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:platform-channels"}), (b:Content {id: "content:optional-dependencies"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:plugin-architecture"}), (b:Content {id: "content:mcp"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:producer-consumer"}), (b:Content {id: "content:agentloop"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:progress-hook"}), (b:Content {id: "content:tool-hint"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:progress-hook"}), (b:Content {id: "content:webui"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:progressive-disclosure"}), (b:Content {id: "content:context-window"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:prompt"}), (b:Content {id: "content:llm"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:prompt-caching"}), (b:Content {id: "content:runtime-context"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:prompt-engineering"}), (b:Content {id: "content:prompt"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:prompt-injection"}), (b:Content {id: "content:least-privilege"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:prompt-injection"}), (b:Content {id: "content:sandbox"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:provider"}), (b:Content {id: "content:anthropic-provider"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:provider"}), (b:Content {id: "content:llm"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:provider"}), (b:Content {id: "content:openai-compatible-provider"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:provider-factory"}), (b:Content {id: "content:config"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:provider-factory"}), (b:Content {id: "content:fallbackprovider"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:providerspec"}), (b:Content {id: "content:optional-dependencies"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:pydantic"}), (b:Content {id: "content:config"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:pydantic-settings"}), (b:Content {id: "content:config"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:pypi"}), (b:Content {id: "content:hatchling"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:rag"}), (b:Content {id: "content:memory"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:rag"}), (b:Content {id: "content:prompt"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:react-js"}), (b:Content {id: "content:react"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:react-js"}), (b:Content {id: "content:webui"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:registry-pattern"}), (b:Content {id: "content:plugin-architecture"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:retry"}), (b:Content {id: "content:transient-error"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:runtime-context"}), (b:Content {id: "content:sustained-goal"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:runtime-state-protocol"}), (b:Content {id: "content:agentloop"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:sampling"}), (b:Content {id: "content:llm"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:sampling"}), (b:Content {id: "content:token"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:sandbox"}), (b:Content {id: "content:exectool"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:sandbox"}), (b:Content {id: "content:workspace"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:sdk-clients"}), (b:Content {id: "content:nanobot-sdk-facade"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:seccomp"}), (b:Content {id: "content:linux-namespaces"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:self-attention"}), (b:Content {id: "content:context-compression"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:self-attention"}), (b:Content {id: "content:context-window"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:self-attention"}), (b:Content {id: "content:token"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:session"}), (b:Content {id: "content:jsonl"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:session-key"}), (b:Content {id: "content:heartbeat"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:session-manager"}), (b:Content {id: "content:atomic-write"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:session-manager"}), (b:Content {id: "content:jsonl"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:skill"}), (b:Content {id: "content:exectool"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:skill"}), (b:Content {id: "content:tool"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:skill-creator"}), (b:Content {id: "content:reflection"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:skill-creator"}), (b:Content {id: "content:voyager"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:skill-library"}), (b:Content {id: "content:skill-creator"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:skillmd"}), (b:Content {id: "content:agent-skills"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:skillsloader"}), (b:Content {id: "content:progressive-disclosure"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:slash-command"}), (b:Content {id: "content:llm"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:sliding-window"}), (b:Content {id: "content:autocompact"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:soulmd"}), (b:Content {id: "content:dream"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:soulmd"}), (b:Content {id: "content:system-prompt"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:spa"}), (b:Content {id: "content:react-js"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:sse"}), (b:Content {id: "content:mcp"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:sse"}), (b:Content {id: "content:streamable-http"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:sse"}), (b:Content {id: "content:streaming"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:ssrf"}), (b:Content {id: "content:web-tools"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:state-machine"}), (b:Content {id: "content:agentloop"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:stdio-transport"}), (b:Content {id: "content:json-rpc"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:streamable-http"}), (b:Content {id: "content:sse"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:streaming"}), (b:Content {id: "content:sse"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:subagent"}), (b:Content {id: "content:tool-scope"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:summarization"}), (b:Content {id: "content:llm"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:sustained-goal"}), (b:Content {id: "content:long-task-tool"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:sustained-goal"}), (b:Content {id: "content:runtime-context"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:sustained-goal"}), (b:Content {id: "content:turn"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:temperature"}), (b:Content {id: "content:model-preset"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:tiktoken"}), (b:Content {id: "content:autocompact"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:tiktoken"}), (b:Content {id: "content:input-budget"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:timeout"}), (b:Content {id: "content:exectool"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:toctou"}), (b:Content {id: "content:dns-pinning"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:token"}), (b:Content {id: "content:context-window"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:token"}), (b:Content {id: "content:llm"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:tool"}), (b:Content {id: "content:llm"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:tool"}), (b:Content {id: "content:tool-schema"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:tool"}), (b:Content {id: "content:web-tools"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:tool-calling"}), (b:Content {id: "content:json-schema"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:tool-discovery"}), (b:Content {id: "content:pkgutil"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:tool-hint"}), (b:Content {id: "content:webui"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:tool-schema"}), (b:Content {id: "content:provider"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:tool-scope"}), (b:Content {id: "content:spawntool"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:tool-scope"}), (b:Content {id: "content:subagent"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:toolregistry"}), (b:Content {id: "content:mcptoolwrapper"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:transient-error"}), (b:Content {id: "content:rate-limit"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:trigger"}), (b:Content {id: "content:cron"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:turn"}), (b:Content {id: "content:agentrunner"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:turn"}), (b:Content {id: "content:llm"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:turn"}), (b:Content {id: "content:tool"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:typescript"}), (b:Content {id: "content:pydantic"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:typescript"}), (b:Content {id: "content:type-hint"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:typescript"}), (b:Content {id: "content:webui"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:unified-session"}), (b:Content {id: "content:webui"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:vector-database"}), (b:Content {id: "content:rag"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:web-tools"}), (b:Content {id: "content:ddgs"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:web-tools"}), (b:Content {id: "content:dns-pinning"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:web-tools"}), (b:Content {id: "content:ssrf"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:websocket"}), (b:Content {id: "content:delta"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:websocket"}), (b:Content {id: "content:streaming"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:websocket"}), (b:Content {id: "content:webui"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:websocket-channel"}), (b:Content {id: "content:webui"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:websocket-multiplex-protocol"}), (b:Content {id: "content:websocket"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:websockets"}), (b:Content {id: "content:websocket"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:websockets"}), (b:Content {id: "content:websocket-channel"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:webui"}), (b:Content {id: "content:bun"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:webui"}), (b:Content {id: "content:react-js"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:webui"}), (b:Content {id: "content:typescript"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:webui"}), (b:Content {id: "content:vite"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:webui-turn-coordinator"}), (b:Content {id: "content:agentloop"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:webui-turn-coordinator"}), (b:Content {id: "content:webui"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:workspace"}), (b:Content {id: "content:cron-store"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:workspace"}), (b:Content {id: "content:jsonl"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:workspace"}), (b:Content {id: "content:memory"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:workspace"}), (b:Content {id: "content:sandbox"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:workspace"}), (b:Content {id: "content:skill"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:workspace-policy"}), (b:Content {id: "content:workspace"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:zero-shot"}), (b:Content {id: "content:few-shot-learning"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:zero-shot"}), (b:Content {id: "content:tool-schema"}) MERGE (a)-[:MENTIONS]->(b);
MATCH (a:Content {id: "content:agent"}), (b:Content {id: "content:react"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:agent"}), (b:Content {id: "content:session"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:agent"}), (b:Content {id: "content:tool-calling"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:agentloop"}), (b:Content {id: "content:agentrunner"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:agentloop"}), (b:Content {id: "content:messagebus"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:agentloop"}), (b:Content {id: "content:nanobot-sdk-facade"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:agentloop"}), (b:Content {id: "content:runtime-checkpoint"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:agentrunner"}), (b:Content {id: "content:delta"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:agentrunner"}), (b:Content {id: "content:tool-calling"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:agentrunner"}), (b:Content {id: "content:toolregistry"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:append-only-log"}), (b:Content {id: "content:atomic-write"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:append-only-log"}), (b:Content {id: "content:cursor"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:apply_patch"}), (b:Content {id: "content:atomic-write"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:apps"}), (b:Content {id: "content:plugin-architecture"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:asyncio"}), (b:Content {id: "content:messagebus"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:asyncio"}), (b:Content {id: "content:pytest"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:asyncioqueue"}), (b:Content {id: "content:producer-consumer"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:atomic-write"}), (b:Content {id: "content:filelock"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:atomic-write"}), (b:Content {id: "content:runtime-checkpoint"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:autocompact"}), (b:Content {id: "content:consolidation"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:autocompact"}), (b:Content {id: "content:session"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:autocompact"}), (b:Content {id: "content:ttl"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:automation-turns"}), (b:Content {id: "content:trigger"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:bert"}), (b:Content {id: "content:embedding"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:bert"}), (b:Content {id: "content:llm"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:bootstrap-templates"}), (b:Content {id: "content:jinja2"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:bound-runner"}), (b:Content {id: "content:cron-turns"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:bubblewrap"}), (b:Content {id: "content:exectool"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:bun"}), (b:Content {id: "content:vite"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:chain-of-thought"}), (b:Content {id: "content:react"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:chain-of-thought"}), (b:Content {id: "content:reasoning-blocks"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:channel"}), (b:Content {id: "content:gateway"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:channel"}), (b:Content {id: "content:pairing"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:channel"}), (b:Content {id: "content:unified-session"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:channel-manager"}), (b:Content {id: "content:gateway"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:circuit-breaker"}), (b:Content {id: "content:transient-error"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:config"}), (b:Content {id: "content:pydantic"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:config"}), (b:Content {id: "content:workspace"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:consolidation"}), (b:Content {id: "content:dream"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:context"}), (b:Content {id: "content:context-window"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:context-compression"}), (b:Content {id: "content:lost-in-the-middle"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:context-compression"}), (b:Content {id: "content:progressive-disclosure"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:context-window"}), (b:Content {id: "content:input-budget"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:context-window"}), (b:Content {id: "content:lost-in-the-middle"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:context-window"}), (b:Content {id: "content:max_tokens"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:coroutine"}), (b:Content {id: "content:event-loop"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:cron"}), (b:Content {id: "content:croniter"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:cron"}), (b:Content {id: "content:gateway"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:cron-expression"}), (b:Content {id: "content:croniter"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:cron-job"}), (b:Content {id: "content:trigger"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:cron-store"}), (b:Content {id: "content:cronservice"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:decoupling"}), (b:Content {id: "content:plugin-architecture"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:decoupling"}), (b:Content {id: "content:producer-consumer"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:defense-in-depth"}), (b:Content {id: "content:graceful-degradation"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:defense-in-depth"}), (b:Content {id: "content:least-privilege"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:defense-in-depth"}), (b:Content {id: "content:prompt-injection"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:defense-in-depth"}), (b:Content {id: "content:pth-file-guard"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:defense-in-depth"}), (b:Content {id: "content:timeout"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:dns-pinning"}), (b:Content {id: "content:dns-rebinding"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:dns-pinning"}), (b:Content {id: "content:ssrf"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:dream"}), (b:Content {id: "content:hierarchical-memory"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:dream"}), (b:Content {id: "content:least-privilege"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:dream-cursor"}), (b:Content {id: "content:historyjsonl"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:durable-files"}), (b:Content {id: "content:workspace"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:embedding"}), (b:Content {id: "content:rag"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:entry-points"}), (b:Content {id: "content:pypi"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:exact-pinning"}), (b:Content {id: "content:optional-dependencies"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:exact-pinning"}), (b:Content {id: "content:pypi"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:exponential-backoff"}), (b:Content {id: "content:rate-limit"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:fine-tuning"}), (b:Content {id: "content:in-context-learning"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:frontmatter"}), (b:Content {id: "content:skillmd"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:gateway"}), (b:Content {id: "content:sdk-clients"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:goal-state"}), (b:Content {id: "content:long-task-tool"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:grounding"}), (b:Content {id: "content:hallucination"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:hallucination"}), (b:Content {id: "content:rag"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:hatchling"}), (b:Content {id: "content:pypi"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:heartbeat"}), (b:Content {id: "content:sustained-goal"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:hierarchical-memory"}), (b:Content {id: "content:memory"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:http"}), (b:Content {id: "content:httpx"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:httpx"}), (b:Content {id: "content:web-tools"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:inboundmessage"}), (b:Content {id: "content:outboundmessage"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:inboundmessage"}), (b:Content {id: "content:session-key"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:injection"}), (b:Content {id: "content:prompt-injection"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:input-budget"}), (b:Content {id: "content:max_tokens"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:input-budget"}), (b:Content {id: "content:token"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:jinja2"}), (b:Content {id: "content:system-prompt"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:json-schema"}), (b:Content {id: "content:pydantic"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:jsonl"}), (b:Content {id: "content:session-manager"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:least-privilege"}), (b:Content {id: "content:seccomp"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:least-privilege"}), (b:Content {id: "content:subagent"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:linux-namespaces"}), (b:Content {id: "content:seccomp"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:llm"}), (b:Content {id: "content:prompt"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:llm"}), (b:Content {id: "content:sampling"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:lost-in-the-middle"}), (b:Content {id: "content:self-attention"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:lsp"}), (b:Content {id: "content:mcp"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:memory"}), (b:Content {id: "content:vector-database"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:model-preset"}), (b:Content {id: "content:provider"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:model-preset"}), (b:Content {id: "content:temperature"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:model-routing"}), (b:Content {id: "content:provider"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:model-routing"}), (b:Content {id: "content:provider-registry"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:nanobot-sdk-facade"}), (b:Content {id: "content:sdk-clients"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:optional-dependencies"}), (b:Content {id: "content:platform-channels"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:optional-dependencies"}), (b:Content {id: "content:pypi"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:pkgutil"}), (b:Content {id: "content:plugin-architecture"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:plugin-architecture"}), (b:Content {id: "content:registry-pattern"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:progressive-disclosure"}), (b:Content {id: "content:skill"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:progressive-disclosure"}), (b:Content {id: "content:skillsloader"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:prompt"}), (b:Content {id: "content:prompt-engineering"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:prompt"}), (b:Content {id: "content:token"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:prompt-caching"}), (b:Content {id: "content:runtime-context"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:prompt-caching"}), (b:Content {id: "content:system-prompt"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:prompt-engineering"}), (b:Content {id: "content:system-prompt"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:prompt-toolkit"}), (b:Content {id: "content:questionary"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:prompt-toolkit"}), (b:Content {id: "content:rich"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:pydantic"}), (b:Content {id: "content:type-hint"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:pytest"}), (b:Content {id: "content:ruff"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:rag"}), (b:Content {id: "content:vector-database"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:rate-limit"}), (b:Content {id: "content:retry"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:rate-limit"}), (b:Content {id: "content:transient-error"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:react"}), (b:Content {id: "content:tool-calling"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:react-js"}), (b:Content {id: "content:spa"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:react-js"}), (b:Content {id: "content:typescript"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:react-js"}), (b:Content {id: "content:vite"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:reasoning-blocks"}), (b:Content {id: "content:streaming"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:reflection"}), (b:Content {id: "content:skill-library"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:retry"}), (b:Content {id: "content:transient-error"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:rich"}), (b:Content {id: "content:typer"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:runtime-checkpoint"}), (b:Content {id: "content:turn-continuation"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:runtime-checkpoint"}), (b:Content {id: "content:turnstate"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:sandbox"}), (b:Content {id: "content:seccomp"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:session"}), (b:Content {id: "content:turn"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:session"}), (b:Content {id: "content:workspace"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:session-key"}), (b:Content {id: "content:unified-session"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:spawntool"}), (b:Content {id: "content:subagent"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:sse"}), (b:Content {id: "content:websocket"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:streaming"}), (b:Content {id: "content:websocket-channel"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:tool"}), (b:Content {id: "content:tool-calling"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:tool"}), (b:Content {id: "content:toolregistry"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:tool-calling"}), (b:Content {id: "content:toolresult"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:tool-hint"}), (b:Content {id: "content:websocket-multiplex-protocol"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:websocket"}), (b:Content {id: "content:websockets"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:websocket-channel"}), (b:Content {id: "content:webui"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:websocket-channel"}), (b:Content {id: "content:webui-turn-coordinator"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:websockets"}), (b:Content {id: "content:webui"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:webui"}), (b:Content {id: "content:webui-turn-coordinator"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:workspace"}), (b:Content {id: "content:workspace-policy"}) MERGE (a)-[:RELATED_TO]->(b);
MATCH (a:Content {id: "content:_skip_modules"}), (b:Content {id: "content:tool-discovery"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:adapter-pattern"}), (b:Content {id: "content:decoupling"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:agent-loop-concept"}), (b:Content {id: "content:agent"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:agent-skills"}), (b:Content {id: "content:skill-library"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:agentloop"}), (b:Content {id: "content:agent"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:agentloop"}), (b:Content {id: "content:agent-loop-concept"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:agentloop"}), (b:Content {id: "content:state-machine"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:agentrunner"}), (b:Content {id: "content:agent-loop-concept"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:anthropic-provider"}), (b:Content {id: "content:provider-base"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:api-server"}), (b:Content {id: "content:http"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:apply_patch"}), (b:Content {id: "content:filesystem-tools"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:asyncio"}), (b:Content {id: "content:coroutine"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:asyncio"}), (b:Content {id: "content:event-loop"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:asyncio"}), (b:Content {id: "content:python-311"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:asyncioqueue"}), (b:Content {id: "content:asyncio"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:atomic-write"}), (b:Content {id: "content:fsync"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:autocompact"}), (b:Content {id: "content:context-compression"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:autocompact"}), (b:Content {id: "content:session"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:automation-turns"}), (b:Content {id: "content:turn"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:azure-openai-provider"}), (b:Content {id: "content:provider-base"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:bedrock-provider"}), (b:Content {id: "content:provider-base"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:bert"}), (b:Content {id: "content:transformer"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:bootstrap-templates"}), (b:Content {id: "content:markdown"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:bootstrap-templates"}), (b:Content {id: "content:system-prompt"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:bound-runner"}), (b:Content {id: "content:cronservice"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:bpe"}), (b:Content {id: "content:token"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:bpe"}), (b:Content {id: "content:tokenizer"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:bubblewrap"}), (b:Content {id: "content:linux-namespaces"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:bubblewrap"}), (b:Content {id: "content:sandbox"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:bubblewrap"}), (b:Content {id: "content:sandbox-backend"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:camelcase-alias"}), (b:Content {id: "content:config"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:camelcase-alias"}), (b:Content {id: "content:pydantic"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:chain-of-thought"}), (b:Content {id: "content:prompt"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:chain-of-thought"}), (b:Content {id: "content:prompt-engineering"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:channel"}), (b:Content {id: "content:adapter-pattern"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:channel-manager"}), (b:Content {id: "content:channel"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:channel-registry"}), (b:Content {id: "content:channel"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:channel-registry"}), (b:Content {id: "content:registry-pattern"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:circuit-breaker"}), (b:Content {id: "content:fallbackprovider"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:circuit-breaker"}), (b:Content {id: "content:state-machine"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:consolidation"}), (b:Content {id: "content:autocompact"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:consolidation"}), (b:Content {id: "content:summarization"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:container"}), (b:Content {id: "content:linux-namespaces"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:container"}), (b:Content {id: "content:sandbox"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:container"}), (b:Content {id: "content:sandbox-backend"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:context"}), (b:Content {id: "content:prompt"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:context-governance"}), (b:Content {id: "content:context"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:context-governance"}), (b:Content {id: "content:context-compression"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:contextvar"}), (b:Content {id: "content:python-311"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:cron-expression"}), (b:Content {id: "content:cron"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:cron-job"}), (b:Content {id: "content:cron"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:cron-store"}), (b:Content {id: "content:cronservice"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:cron-tool"}), (b:Content {id: "content:cron"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:cron-tool"}), (b:Content {id: "content:tool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:cron-turns"}), (b:Content {id: "content:bound-runner"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:cron-turns"}), (b:Content {id: "content:turn"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:cronservice"}), (b:Content {id: "content:cron"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:delta"}), (b:Content {id: "content:streaming"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:dns-rebinding"}), (b:Content {id: "content:ssrf"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:dns-rebinding"}), (b:Content {id: "content:toctou"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:dream"}), (b:Content {id: "content:memory"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:dream"}), (b:Content {id: "content:reflection"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:dream-cursor"}), (b:Content {id: "content:cursor"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:dream-cursor"}), (b:Content {id: "content:dream"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:dulwich"}), (b:Content {id: "content:git"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:durable-files"}), (b:Content {id: "content:markdown"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:durable-files"}), (b:Content {id: "content:memory"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:entry-point-plugin"}), (b:Content {id: "content:entry-points"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:entry-point-plugin"}), (b:Content {id: "content:plugin-architecture"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:entry-point-plugin"}), (b:Content {id: "content:tool-discovery"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:exec-session"}), (b:Content {id: "content:exectool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:exectool"}), (b:Content {id: "content:tool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:exponential-backoff"}), (b:Content {id: "content:retry"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:fallbackprovider"}), (b:Content {id: "content:graceful-degradation"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:fallbackprovider"}), (b:Content {id: "content:model-routing"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:fallbackprovider"}), (b:Content {id: "content:provider"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:fallbackprovider"}), (b:Content {id: "content:provider-base"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:few-shot-learning"}), (b:Content {id: "content:in-context-learning"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:few-shot-learning"}), (b:Content {id: "content:prompt"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:few-shot-learning"}), (b:Content {id: "content:prompt-engineering"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:file-state"}), (b:Content {id: "content:filesystem-tools"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:filesystem-tools"}), (b:Content {id: "content:tool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:frontmatter"}), (b:Content {id: "content:markdown"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:gateway-service"}), (b:Content {id: "content:gateway"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:github-copilot-provider"}), (b:Content {id: "content:provider-base"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:goal-state"}), (b:Content {id: "content:sustained-goal"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:health-endpoint"}), (b:Content {id: "content:gateway"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:health-endpoint"}), (b:Content {id: "content:gateway-service"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:heartbeat"}), (b:Content {id: "content:cron"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:heartbeatmd"}), (b:Content {id: "content:bootstrap-templates"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:heartbeatmd"}), (b:Content {id: "content:heartbeat"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:history-visibility"}), (b:Content {id: "content:session"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:historyjsonl"}), (b:Content {id: "content:jsonl"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:historyjsonl"}), (b:Content {id: "content:memory"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:hook"}), (b:Content {id: "content:agentloop"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:image-generation-provider"}), (b:Content {id: "content:provider"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:image-generation-tool"}), (b:Content {id: "content:tool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:inboundmessage"}), (b:Content {id: "content:messagebus"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:injection"}), (b:Content {id: "content:agentrunner"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:input-budget"}), (b:Content {id: "content:context-governance"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:input-budget"}), (b:Content {id: "content:context-window"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:jsonl"}), (b:Content {id: "content:append-only-log"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:last_consolidated-cursor"}), (b:Content {id: "content:consolidation"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:last_consolidated-cursor"}), (b:Content {id: "content:cursor"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:last_consolidated-cursor"}), (b:Content {id: "content:session-manager"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:llm"}), (b:Content {id: "content:transformer"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:long-task-tool"}), (b:Content {id: "content:tool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:lora"}), (b:Content {id: "content:peft"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:lsp"}), (b:Content {id: "content:json-rpc"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:mcp"}), (b:Content {id: "content:json-rpc"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:mcp"}), (b:Content {id: "content:tool-calling"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:mcptoolwrapper"}), (b:Content {id: "content:adapter-pattern"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:mcptoolwrapper"}), (b:Content {id: "content:mcp"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:mcptoolwrapper"}), (b:Content {id: "content:tool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:memory"}), (b:Content {id: "content:hierarchical-memory"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:memorymd"}), (b:Content {id: "content:durable-files"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:messagebus"}), (b:Content {id: "content:decoupling"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:messagebus"}), (b:Content {id: "content:producer-consumer"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:messagetool"}), (b:Content {id: "content:tool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:model-preset"}), (b:Content {id: "content:config"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:model-preset"}), (b:Content {id: "content:model-routing"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:mytool"}), (b:Content {id: "content:tool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:nanobot-sdk-facade"}), (b:Content {id: "content:agent"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:nanobot-sdk-facade"}), (b:Content {id: "content:facade-pattern"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:openai-codex-provider"}), (b:Content {id: "content:provider-base"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:openai-compatible-api"}), (b:Content {id: "content:api-server"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:openai-compatible-api"}), (b:Content {id: "content:http"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:openai-compatible-provider"}), (b:Content {id: "content:provider-base"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:openai-responses-provider"}), (b:Content {id: "content:provider-base"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:orphan-tool-result"}), (b:Content {id: "content:context-governance"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:orphan-tool-result"}), (b:Content {id: "content:tool-calling"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:outboundmessage"}), (b:Content {id: "content:messagebus"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:path-utils"}), (b:Content {id: "content:filesystem-tools"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:peft"}), (b:Content {id: "content:fine-tuning"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:pinneddnsasynctransport"}), (b:Content {id: "content:dns-pinning"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:pinneddnsasynctransport"}), (b:Content {id: "content:httpx"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:platform-channels"}), (b:Content {id: "content:channel"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:progress-hook"}), (b:Content {id: "content:hook"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:provider"}), (b:Content {id: "content:adapter-pattern"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:provider"}), (b:Content {id: "content:decoupling"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:provider-base"}), (b:Content {id: "content:provider"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:provider-factory"}), (b:Content {id: "content:provider"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:provider-registry"}), (b:Content {id: "content:provider"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:provider-registry"}), (b:Content {id: "content:registry-pattern"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:providerspec"}), (b:Content {id: "content:provider-registry"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:pydantic"}), (b:Content {id: "content:type-hint"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:pydantic-settings"}), (b:Content {id: "content:pydantic"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:rag"}), (b:Content {id: "content:grounding"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:rag"}), (b:Content {id: "content:in-context-learning"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:react"}), (b:Content {id: "content:agent-loop-concept"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:retry"}), (b:Content {id: "content:fallbackprovider"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:runtime-context"}), (b:Content {id: "content:context"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:runtime-state-protocol"}), (b:Content {id: "content:decoupling"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:runtime-state-protocol"}), (b:Content {id: "content:mytool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:sandbox"}), (b:Content {id: "content:least-privilege"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:sandbox-backend"}), (b:Content {id: "content:sandbox"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:self-attention"}), (b:Content {id: "content:attention"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:session-delivery"}), (b:Content {id: "content:cronservice"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:session-key"}), (b:Content {id: "content:session"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:session-manager"}), (b:Content {id: "content:session"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:skill"}), (b:Content {id: "content:skill-library"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:skill-creator"}), (b:Content {id: "content:skill"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:skill-creator"}), (b:Content {id: "content:skill-library"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:skillmd"}), (b:Content {id: "content:agent-skills"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:skillmd"}), (b:Content {id: "content:frontmatter"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:skillmd"}), (b:Content {id: "content:markdown"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:skillmd"}), (b:Content {id: "content:skill"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:skillsloader"}), (b:Content {id: "content:skill"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:slash-command"}), (b:Content {id: "content:command-router"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:sliding-window"}), (b:Content {id: "content:context-compression"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:soulmd"}), (b:Content {id: "content:durable-files"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:spawntool"}), (b:Content {id: "content:subagent"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:spawntool"}), (b:Content {id: "content:tool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:sse"}), (b:Content {id: "content:http"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:stdio-transport"}), (b:Content {id: "content:mcp"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:streamable-http"}), (b:Content {id: "content:http"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:streamable-http"}), (b:Content {id: "content:mcp"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:subagent"}), (b:Content {id: "content:agent"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:summarization"}), (b:Content {id: "content:context-compression"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:system-prompt"}), (b:Content {id: "content:context"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:system-prompt"}), (b:Content {id: "content:prompt"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:temperature"}), (b:Content {id: "content:sampling"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:tiktoken"}), (b:Content {id: "content:bpe"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:tiktoken"}), (b:Content {id: "content:tokenizer"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:tokenizer"}), (b:Content {id: "content:token"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:tool"}), (b:Content {id: "content:tool-calling"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:tool-calling"}), (b:Content {id: "content:grounding"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:tool-calling"}), (b:Content {id: "content:llm"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:tool-discovery"}), (b:Content {id: "content:plugin-architecture"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:tool-discovery"}), (b:Content {id: "content:toolregistry"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:tool-hint"}), (b:Content {id: "content:progress-hook"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:tool-schema"}), (b:Content {id: "content:json-schema"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:tool-schema"}), (b:Content {id: "content:tool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:tool-scope"}), (b:Content {id: "content:least-privilege"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:tool-scope"}), (b:Content {id: "content:toolregistry"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:toolregistry"}), (b:Content {id: "content:registry-pattern"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:toolregistry"}), (b:Content {id: "content:tool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:toolresult"}), (b:Content {id: "content:tool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:transcription"}), (b:Content {id: "content:provider"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:transformer"}), (b:Content {id: "content:attention"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:transformer"}), (b:Content {id: "content:self-attention"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:turn-continuation"}), (b:Content {id: "content:turn"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:turnstate"}), (b:Content {id: "content:agentloop"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:turnstate"}), (b:Content {id: "content:state-machine"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:turnstate"}), (b:Content {id: "content:turn"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:type-hint"}), (b:Content {id: "content:python-311"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:typer"}), (b:Content {id: "content:type-hint"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:unified-session"}), (b:Content {id: "content:session"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:usermd"}), (b:Content {id: "content:durable-files"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:vector-database"}), (b:Content {id: "content:embedding"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:voyager"}), (b:Content {id: "content:skill-library"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:web-tools"}), (b:Content {id: "content:tool"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:websocket"}), (b:Content {id: "content:http"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:websocket-channel"}), (b:Content {id: "content:channel"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:websocket-channel"}), (b:Content {id: "content:websocket"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:websocket-multiplex-protocol"}), (b:Content {id: "content:websocket-channel"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:webui"}), (b:Content {id: "content:spa"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:webui-turn-coordinator"}), (b:Content {id: "content:session"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:workspace-access"}), (b:Content {id: "content:workspace-policy"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:workspace-policy"}), (b:Content {id: "content:least-privilege"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:writestdintool"}), (b:Content {id: "content:exec-session"}) MERGE (a)-[:SPECIALIZES]->(b);
MATCH (a:Content {id: "content:zero-shot"}), (b:Content {id: "content:in-context-learning"}) MERGE (a)-[:SPECIALIZES]->(b);
