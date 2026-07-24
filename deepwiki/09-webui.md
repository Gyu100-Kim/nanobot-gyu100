# 9. WebUI (웹 UI)

WebUI는 nanobot의 브라우저 워크벤치다. Vite 기반 React SPA(`webui/`)가 프론트엔드를, `nanobot/webui/`의 파이썬 모듈이 게이트웨이 백엔드 로직을 담당한다. 둘은 WebSocket 멀티플렉스 프로토콜로 통신한다([7.4](07.4-websocket-channel-and-webui-protocol.md)).

## 아키텍처

```
브라우저 (React SPA, webui/src)
   <-- WebSocket 멀티플렉스 (:8765) -->
WebSocketChannel (nanobot/channels/websocket.py)
   + WebUI 백엔드 모듈 (nanobot/webui/*)
   -> AgentLoop / SessionManager / 워크스페이스
```

- 개발 서버(`bun run dev`)는 `/api`, `/webui`, `/auth`, WebSocket 트래픽을 게이트웨이(`:8765`)로 프록시한다(`webui/vite.config.ts`, `AGENTS.md`).
- 프로덕션 빌드(`bun run build`)는 `../nanobot/web/dist`로 출력되어 파이썬 휠에 번들된다.

## 실행

`nanobot webui`가 config/workspace를 준비하고, 프로바이더 설정을 점검하고, 로컬 WebSocket 채널을 켠 뒤 게이트웨이를 시작하고 브라우저를 연다(`docs/webui.md`).

## 기능(개요)

- 다중 세션 채팅과 사이드바.
- 스트리밍 응답, 추론(reasoning) 표시, 도구 실행 타임라인.
- 세션 관리: 이름 변경, 검색, 포크, 삭제.
- 워크스페이스/접근 제어, Full Access 모드.
- Apps, Skills, Automations, 설정 패널.
- 음성 입력(전사), 이미지/파일 첨부, 파일 미리보기.
- LAN 접근과 원격 패키지 설치 정책.

## 하위 문서

- [9.1 Frontend Components and State](09.1-frontend-components-and-state.md)
- [9.2 Backend WebUI APIs](09.2-backend-webui-apis.md)

### 참조 파일

- `webui/` (React SPA), `webui/vite.config.ts`, `webui/package.json`
- `nanobot/webui/` (백엔드 모듈)
- `nanobot/channels/websocket.py`
- `docs/webui.md`
