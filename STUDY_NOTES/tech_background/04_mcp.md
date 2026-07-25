# 배경지식 04. MCP (Model Context Protocol)

> **이 문서에서 다루는 큰 맥락**
>
> MCP는 "LLM[(용어사전)](../../dict/08_ai_llm_concepts.md#llm) 애플리케이션이 외부 도구/데이터 소스를 표준 프로토콜로 연결"하기 위한 규격입니다.
> 이 문서는 (1) MCP의 정의와 해결하는 문제(N×M 통합), (2) 하위 개념들(JSON-RPC[(용어사전)](../../dict/08_ai_llm_concepts.md#json-rpc), 호스트/클라이언트/서버,
> 도구·리소스·프롬프트 프리미티브, stdio/HTTP 전송, LSP와의 유사성), (3) 개념 간 관계, (4) 규격과 히스토리,
> (5) nanobot의 `agent/tools/mcp.py` 구현으로의 연결을 다룹니다.

## 소목차
1. [정의와 핵심 아이디어](#정의와-핵심-아이디어)
2. [하위 개념 상세](#하위-개념-상세)
3. [개념 간 관계](#개념-간-관계)
4. [역사와 근간 규격/기술 문서](#역사와-근간-규격기술-문서)
5. [최신 동향](#최신-동향)
6. [nanobot에서의 실제 구현](#nanobot에서의-실제-구현)

---

## 정의와 핵심 아이디어

**MCP[(용어사전)](../../dict/08_ai_llm_concepts.md#mcp)(Model Context Protocol)**: Anthropic이 2024년 11월 공개한, LLM 앱(호스트)과 도구/리소스 제공자(서버) 사이의
**표준 통신 프로토콜**(JSON-RPC 기반). 서버가 "이런 도구가 있다"를 노출하면, 어떤 MCP 호환 호스트든 그 도구를 쓸 수 있습니다.

**왜 등장했나 — N×M 통합 문제:** tool-calling(→ [01](01_tool_calling_agents.md))이 표준화되면서 도구 수요가 폭발했지만,
각 앱(N개)이 각 도구(M개)를 개별 구현하면 N×M개의 통합 코드가 필요합니다. MCP는 중간에 표준 프로토콜을 끼워
**N+M**으로 줄입니다 — 앱은 MCP 클라이언트 하나만, 도구는 MCP 서버 하나만 구현하면 됩니다.
"AI의 USB-C"라는 비유가 여기서 나옵니다.

이 발상 자체는 새롭지 않습니다. 에디터(N)와 언어(M)의 통합 폭발을 해결한 **LSP[(용어사전)](../../dict/08_ai_llm_concepts.md#lsp)(Language Server Protocol,
Microsoft 2016)** 가 같은 구조였고, MCP는 명시적으로 LSP에서 영감을 받았습니다(둘 다 JSON-RPC 기반).

---

## 하위 개념 상세

### (a) JSON-RPC 2.0 — 바닥의 통신 규약
**JSON-RPC**는 "JSON으로 원격 함수를 호출"하는 경량 규약입니다(2010년 2.0 규격).
요청은 `{"jsonrpc": "2.0", "method": "tools/call", "params": {...}, "id": 1}` 형태이고,
응답은 같은 `id`로 짝지어집니다. 전송 방식(파이프/HTTP)과 무관하게 메시지 형식만 정의하므로,
MCP처럼 여러 전송을 지원하는 프로토콜의 기반으로 적합합니다.

### (b) 3-역할 구조: 호스트(host) / 클라이언트(client) / 서버(server)
- **호스트**: LLM을 구동하는 애플리케이션(Claude Desktop, IDE, nanobot 같은 에이전트).
- **클라이언트**: 호스트 안에서 **서버 하나당 하나씩** 만들어지는 연결 관리자.
- **서버**: 도구/리소스를 노출하는 프로그램(파일시스템 서버, GitHub 서버, DB 서버 등).

연결 수립 시 **initialize 핸드셰이크**로 프로토콜 버전과 기능(capabilities)을 협상한 뒤,
클라이언트가 `tools/list`로 도구 목록을 받아 LLM에게 제시하고, 모델이 도구를 고르면 `tools/call`로 실행을 위임합니다.

### (c) 서버가 노출하는 3가지 프리미티브
1. **Tools(도구)** — 모델이 호출하는 함수(부작용 가능). tool-calling의 JSON Schema[(용어사전)](../../dict/08_ai_llm_concepts.md#json-schema) 계약과 동일한 방식으로 선언.
2. **Resources(리소스)** — URI로 식별되는 읽기 전용 데이터(파일, DB 레코드). 컨텍스트 주입용.
3. **Prompts(프롬프트)** — 서버가 제공하는 재사용 가능한 프롬프트 템플릿.

실무에서는 Tools가 압도적으로 많이 쓰이며, nanobot도 도구 편입에 집중합니다.

### (d) 전송(transport): stdio vs HTTP
- **stdio**: 호스트가 서버를 **자식 프로세스로 실행**하고 표준입출력으로 JSON-RPC를 주고받음.
  로컬 도구에 적합 — 설치만 하면 되고 네트워크 노출이 없습니다.
- **HTTP[(용어사전)](../../dict/05_channels_gateway_ui.md#http) 계열**: 원격 서버용. 초기 규격은 **HTTP+SSE[(용어사전)](../../dict/08_ai_llm_concepts.md#sse)**(Server-Sent Events로 서버→클라이언트 스트림),
  2025-03-26 규격부터 **Streamable HTTP[(용어사전)](../../dict/08_ai_llm_concepts.md#streamable-http)**로 개편(단일 엔드포인트, 세션 관리 개선). 인증(OAuth 2.1)도 이때 정비.

### (e) 원격 MCP의 보안 이슈
원격 서버 연결은 새로운 공격면을 만듭니다:
- **비밀이 담긴 URL** — `https://user:token@host/sse`처럼 URL에 자격증명이 들어가면 로그/오류 메시지로 샐 수 있음.
- **SSRF/DNS rebinding** — 서버 URL이 내부망 주소로 해석되거나, 연결 후 DNS가 내부 IP로 바뀌는 공격
  (→ [06](06_execution_isolation.md)의 네트워크 가드와 같은 문제).
- **도구 설명 주입(tool poisoning)** — 서버가 보내는 도구 설명 텍스트가 곧 모델 프롬프트에 들어가므로,
  악의적 서버가 설명에 지시문을 심을 수 있음. "신뢰할 수 있는 서버만 연결"이 기본 수칙입니다.

### (f) 규격 위반 서버에 대한 방어적 구현
생태계가 빠르게 크면서 규격을 어기는 서버(잘못된 알림 형식, 비표준 필드)가 흔합니다.
견고한 클라이언트는 "잘못된 메시지 하나에 전체 연결이 죽지 않게" 필터링/무시하는 방어 코드를 둡니다
— 인터넷 초기의 "받을 때는 관대하게(be liberal in what you accept)" 원칙(Postel's law)의 재현입니다.

---

## 개념 간 관계

```text
tool-calling (01 문서: 모델 ↔ 런타임의 도구 계약)
    │ 도구 공급을 표준화
    ▼
MCP (런타임 ↔ 외부 도구 서버의 프로토콜)
    ├─ JSON-RPC 2.0 (메시지 형식)      ←— LSP에서 물려받은 설계
    ├─ 호스트/클라이언트/서버 (역할 분리)
    ├─ Tools/Resources/Prompts (프리미티브)
    ├─ stdio (로컬) / Streamable HTTP (원격) (전송)
    └─ 보안: URL 비밀, SSRF/DNS 고정, 도구 설명 신뢰 (→ 06 문서)
```

- MCP 도구는 결국 [01](01_tool_calling_agents.md)의 tool-calling 루프에 "외부에서 온 도구"로 합류합니다 —
  모델 입장에서는 내장 도구와 구별되지 않습니다.
- 도구가 늘수록 스키마가 컨텍스트를 차지하므로 [02](02_context_compression.md)의 예산 문제와도 연결됩니다.

---

## 역사와 근간 규격/기술 문서

| 시기 | 이정표 | 내용 |
| --- | --- | --- |
| 2010 | **JSON-RPC 2.0** 규격 | 경량 원격 호출 규약 — MCP 메시지 형식의 기반. |
| 2016 | **LSP(Language Server Protocol)** (Microsoft) | 에디터×언어의 N×M 문제를 JSON-RPC 표준으로 해결 — MCP의 직접적 영감. |
| 2023.06 | OpenAI function calling | 도구 계약(JSON Schema)의 표준화 — MCP가 올라탈 토대(→ [01](01_tool_calling_agents.md)). |
| 2024.11 | **MCP 공개** (Anthropic) | 규격 + SDK(Python/TypeScript) + 참조 서버(파일시스템, GitHub 등) 동시 공개. |
| 2025.03 | 규격 개정(2025-03-26) | Streamable HTTP 전송, OAuth 2.1 인증 프레임워크 도입. |
| 2025 | 업계 채택 확산 | OpenAI(Agents SDK), Google 등 주요 벤더가 MCP 지원 발표 — 사실상 표준화. |

읽어볼 1차 자료:
- MCP 규격: https://modelcontextprotocol.io/specification
- MCP 소개(Anthropic 발표문): https://www.anthropic.com/news/model-context-protocol
- Python SDK: https://github.com/modelcontextprotocol/python-sdk
- JSON-RPC 2.0: https://www.jsonrpc.org/specification
- LSP: https://microsoft.github.io/language-server-protocol/

---

## 최신 동향

- 주요 IDE/에이전트(Claude Desktop, 여러 코딩 에이전트)가 MCP 클라이언트를 내장.
- 파일시스템·GitHub·DB 등 공식/커뮤니티 MCP 서버 생태계 확장, 서버 레지스트리/마켓플레이스 등장.
- 원격 MCP(Streamable HTTP)와 인증/보안(OAuth, 토큰, DNS 고정, 도구 설명 신뢰) 논의 활발.

---

## nanobot에서의 실제 구현

### 의존성
`mcp` 패키지가 base 의존성에 포함됩니다([02](../02_modules_and_stack.md)) — MCP는 선택이 아니라 코어 기능입니다.

### 도구 래핑 — `agent/tools/mcp.py`
- `MCPToolWrapper`(L425-)와 `_MCPWrapperBase`(L338-): MCP 서버가 제공하는 각 원격 도구를 nanobot의 `Tool`
  인터페이스로 감쌉니다. `_set_mcp_connection(session, server_name)`(L343)로 연결 세션을 보관하고, 도구 이름은
  `mcp_<server>_...` 접두를 갖습니다([05](../05_tools.md) 레지스트리가 `mcp_` 도구를 내장 도구 뒤로 정렬)
  — 위 (b)의 "클라이언트가 서버 도구를 받아 모델에 제시"하는 구조 그대로입니다.
- 전송: stdio와 HTTP/SSE 모두 지원 — 위 (d)의 두 전송. 포트가 닫혔을 때 `streamable_http_client`/`sse_client`
  진입을 피하는 방어 로직(L174-175 주석)과 Windows stdio 런처 정규화(`_normalize_windows_stdio_command` L246-251)가
  있습니다.
- **보안**: 서버 URL에 담긴 비밀(`https://user:token@host/sse`, L207 주석)을 다루고, `_pinned_transport_kwargs()`(L223)가
  `PinnedDNSAsyncTransport`를 사용하며 `_validate_mcp_request_url`(L231)로 요청 URL을 검증 — 위 (e)의 원격 MCP
  보안 이슈에 대한 대응이며 [12](../12_security_and_sandbox.md)의 SSRF/DNS 고정과 연결됩니다.
- **견고성**: 잘못된 progress 알림을 걸러내는 필터(`_MalformedProgressNotificationFilter` L84,
  `_filter_malformed_mcp_progress_notifications` L121) — 위 (f)의 방어적 구현(Postel's law) 사례.

### 발견/등록
MCP 도구는 [05](../05_tools.md)의 로더에서 특별 취급됩니다(`_SKIP_MODULES`에 `mcp` 포함 — 일반 pkgutil[(용어사전)](../../dict/09_dev_stack.md#pkgutil) 자동발견
대상이 아니라 연결 후 동적으로 등록). 설정에 MCP 서버를 추가하면 런타임에 연결되어 도구 목록에 합류합니다.

**정리:** nanobot은 MCP를 1급 시민으로 취급해, 코어 코드 수정 없이 외부 도구 생태계를 편입합니다
(`.agent/design.md`의 "코어는 작게, 확장은 가장자리에서" 원칙과 일치). 특히 원격 MCP의
보안(비밀 URL, DNS 고정, URL 검증)과 규격 위반 방어에 신경 쓴 구현이 특징입니다.
