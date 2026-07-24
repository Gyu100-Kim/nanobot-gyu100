# 7. Channels (채널)

채널은 nanobot을 외부 메시징 플랫폼과 연결한다. 각 채널은 플랫폼에서 메시지를 받아 `InboundMessage`로 버스에 발행하고, `OutboundMessage`를 받아 플랫폼으로 전송한다. 구현은 `nanobot/channels/` 아래에 있다.

## 채널 베이스 (`base.py`)

모든 채널은 `BaseChannel`을 상속한다.

- 수명주기: `start()`, `stop()` — 연결 열기/닫기.
- 인바운드: 플랫폼 이벤트를 `InboundMessage`로 만들어 버스에 발행.
- 아웃바운드: `send_message(...)`, 스트리밍/추론 훅(`send_stream`, `send_reasoning` 등).
- 접근 제어: `check_access(...)` — 페어링/허용 목록 검사(`nanobot/pairing/`의 DM 승인 스토어와 연동).
- 미디어: 첨부/이미지 처리, 오디오 전사(`transcribe_audio`, `TranscriptionConfig`, [5.2](05.2-anthropic-azure-bedrock-and-specialized-providers.md)).

## 채널 매니저 (`manager.py`)

`ChannelManager`는 채널을 발견·조율한다.

- 발견: `pkgutil` 스캔 + 엔트리포인트 플러그인(`registry.py`).
- 시작/종료: 활성화된 채널을 시작하고 정상 종료.
- 아웃바운드 디스패치: 버스의 `OutboundMessage`를 올바른 채널로 라우팅.
- 스트리밍 coalescing/재시도: 델타를 묶어 rate limit을 피하고 전송 실패를 재시도.
- 상태: 채널별 연결 상태 보고.

## 지원 채널

`nanobot/channels/`의 파일이 곧 지원 플랫폼이다.

| 파일 | 플랫폼 |
|---|---|
| `telegram.py` | Telegram |
| `discord.py` | Discord |
| `slack.py` | Slack |
| `feishu.py` | Feishu (Lark) |
| `matrix.py` | Matrix |
| `whatsapp.py` | WhatsApp |
| `qq.py`, `napcat.py` | QQ |
| `weixin.py` | WeChat |
| `wecom.py` | WeCom (기업 위챗) |
| `dingtalk.py` | DingTalk |
| `email.py` | Email |
| `mochat.py` | MoChat |
| `msteams.py` | MS Teams |
| `mattermost.py` | Mattermost |
| `signal.py` | Signal |
| `websocket.py` | WebSocket (WebUI) |

채널 활성화/설정은 `channels`(`ChannelsConfig`, `nanobot/config/schema.py`)에서 한다.

## 하위 문서

- [7.1 Telegram and Discord](07.1-telegram-and-discord.md)
- [7.2 Feishu, Matrix, and WeChat](07.2-feishu-matrix-and-wechat.md)
- [7.3 Slack, WhatsApp, and Other](07.3-slack-whatsapp-and-other.md)
- [7.4 WebSocket Channel and WebUI Protocol](07.4-websocket-channel-and-webui-protocol.md)

### 참조 파일

- `nanobot/channels/base.py`, `manager.py`, `registry.py`
- `nanobot/channels/*.py`
- `nanobot/pairing/`, `nanobot/config/schema.py` (`ChannelsConfig`)
