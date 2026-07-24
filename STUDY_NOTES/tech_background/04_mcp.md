# 배경지식 04. MCP (Model Context Protocol)

> **이 문서에서 다루는 큰 맥락**
>
> MCP는 "LLM 애플리케이션이 외부 도구/데이터 소스를 표준 프로토콜로 연결"하기 위한 규격입니다. nanobot은 MCP
> 서버들을 도구로 편입해, 코어를 고치지 않고도 능력을 확장합니다. 근거는 `mcp` 의존성과 `agent/tools/mcp.py`입니다.

## 소목차
1. [정의와 등장 배경](#정의와-등장-배경)
2. [최신 동향](#최신-동향)
3. [nanobot에서의 실제 구현](#nanobot에서의-실제-구현)

---

## 정의와 등장 배경

**MCP(Model Context Protocol)**: Anthropic이 주도해 공개한, LLM 앱(호스트)과 도구/리소스 제공자(서버) 사이의
**표준 통신 프로토콜**(JSON-RPC 기반). 서버가 "이런 도구가 있다"를 노출하면, 어떤 MCP 호환 호스트든 그 도구를 쓸 수 있습니다.

**왜 등장했나:** tool-calling(→ [01](01_tool_calling_agents.md))이 표준화되면서, 도구를 앱마다 다시 구현하는 낭비가
생겼습니다. MCP는 "도구를 한 번 서버로 만들면 여러 호스트가 재사용"하게 해 **N×M 통합 문제**를 줄입니다(USB-C에 비유되곤 함).

전송(transport)은 보통 두 가지: **stdio**(로컬 프로세스 표준입출력)와 **HTTP/SSE**(원격 서버).

---

## 최신 동향

- 주요 IDE/에이전트(Claude Desktop, 여러 코딩 에이전트)가 MCP 클라이언트를 내장.
- 파일시스템·GitHub·DB 등 공식/커뮤니티 MCP 서버 생태계 확장.
- 원격 MCP(HTTP/SSE)와 인증/보안(토큰, DNS 고정 등) 논의 활발.

---

## nanobot에서의 실제 구현

### 의존성
`mcp` 패키지가 base 의존성에 포함됩니다([02](../02_modules_and_stack.md)) — MCP는 선택이 아니라 코어 기능입니다.

### 도구 래핑 — `agent/tools/mcp.py`
- `MCPToolWrapper`(L425-)와 `_MCPWrapperBase`(L338-): MCP 서버가 제공하는 각 원격 도구를 nanobot의 `Tool`
  인터페이스로 감쌉니다. `_set_mcp_connection(session, server_name)`(L343)로 연결 세션을 보관하고, 도구 이름은
  `mcp_<server>_...` 접두를 갖습니다([05](../05_tools.md) 레지스트리가 `mcp_` 도구를 내장 도구 뒤로 정렬).
- 전송: stdio와 HTTP/SSE 모두 지원. 포트가 닫혔을 때 `streamable_http_client`/`sse_client` 진입을 피하는 방어
  로직(L174-175 주석)과 Windows stdio 런처 정규화(`_normalize_windows_stdio_command` L246-251)가 있습니다.
- **보안**: 서버 URL에 담긴 비밀(`https://user:token@host/sse`, L207 주석)을 다루고, `_pinned_transport_kwargs()`(L223)가
  `PinnedDNSAsyncTransport`를 사용하며 `_validate_mcp_request_url`(L231)로 요청 URL을 검증 — [12](../12_security_and_sandbox.md)의
  SSRF/DNS 고정과 연결됩니다.
- **견고성**: 잘못된 progress 알림을 걸러내는 필터(`_MalformedProgressNotificationFilter` L84,
  `_filter_malformed_mcp_progress_notifications` L121) — 실제 서버들의 규격 위반에 대비한 방어적 코드.

### 발견/등록
MCP 도구는 [05](../05_tools.md)의 로더에서 특별 취급됩니다(`_SKIP_MODULES`에 `mcp` 포함 — 일반 pkgutil 자동발견
대상이 아니라 연결 후 동적으로 등록). 설정에 MCP 서버를 추가하면 런타임에 연결되어 도구 목록에 합류합니다.

**정리:** nanobot은 MCP를 1급 시민으로 취급해, 코어 코드 수정 없이 외부 도구 생태계를 편입합니다. 특히 원격 MCP의
보안(비밀 URL, DNS 고정, URL 검증)과 규격 위반 방어에 신경 쓴 구현이 특징입니다.
