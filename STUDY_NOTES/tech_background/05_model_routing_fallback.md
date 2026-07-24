# 배경지식 05. 모델 라우팅과 폴백(Model Routing / Fallback)

> **이 문서에서 다루는 큰 맥락**
>
> 프로덕션 LLM 앱은 하나의 모델만 믿을 수 없습니다 — 특정 모델이 다운되거나 레이트리밋에 걸리면 서비스가 멈추기
> 때문입니다. **라우팅**은 상황에 맞는 모델을 고르는 것, **폴백**은 실패 시 다른 모델로 넘기는 것입니다. 근거는
> `nanobot/providers/registry.py`와 `fallback_provider.py`입니다.

## 소목차
1. [정의와 등장 배경](#정의와-등장-배경)
2. [최신 동향](#최신-동향)
3. [nanobot에서의 실제 구현](#nanobot에서의-실제-구현)

---

## 정의와 등장 배경

- **라우팅(routing)**: 요청 특성(작업 종류/비용/속도)이나 설정에 따라 어떤 프로바이더/모델을 쓸지 선택.
- **폴백(fallback)**: 선택한 모델이 실패하면 대체 모델로 자동 전환.

**왜 필요한가:** LLM API는 429(레이트리밋)·5xx(서버 오류)·타임아웃·용량 초과가 흔합니다. 단일 모델 의존은
가용성을 그 모델의 SLA에 묶어 버립니다. 여러 프로바이더에 걸쳐 폴백하면 **가용성과 회복력**이 크게 올라갑니다.

---

## 최신 동향

- LiteLLM/OpenRouter 같은 **라우터/게이트웨이**가 다중 프로바이더 추상화를 제공.
- **서킷 브레이커** 패턴으로 죽은 백엔드를 일시 우회.
- 비용/지연 기반 라우팅, 품질 기반 라우팅 등 정책 다양화.

---

## nanobot에서의 실제 구현

### 프로바이더 레지스트리 — `providers/registry.py`
[09](../09_providers.md) 참고. `ProviderSpec` 하나에 프로바이더의 특성(키워드/키/백엔드/기본 base 등)을 선언하고,
`find_by_name`/`create_dynamic_spec`으로 조회·동적 생성합니다. 새 프로바이더 추가는 "PROVIDERS에 Spec 추가 +
config 필드 추가"면 끝(파일 상단 주석) — **데이터 주도 라우팅**의 기반.

### 폴백 — `providers/fallback_provider.py`
`FallbackProvider`가 요청 범위 페일오버를 구현합니다([09](../09_providers.md)에서 상세). 핵심 정책:
- **폴백하는 오류**: `timeout`, `connection`, `server_error`, `rate_limit`, `overloaded`(일시적/용량 문제).
- **폴백하지 않는 오류**: `authentication`/`permission`/`content_filter`/`context_length`/`invalid_request`
  (넘겨도 소용없거나 넘기면 안 되는 것).
- **서킷 브레이커**: primary 연속 실패 임계치(`_PRIMARY_FAILURE_THRESHOLD = 3`)를 넘으면 일정 시간
  (`_PRIMARY_COOLDOWN_S = 60`) primary를 건너뛰고 fallback을 곧장 사용.
- **스트리밍 안전장치**: 이미 content가 사용자에게 스트리밍된 뒤에는 폴백하지 않음(중복 출력 방지). 단 타임아웃
  stall은 새 세그먼트에서 복구 가능.
- **재귀 방지**: fallback이 또 fallback을 부르는 연쇄 차단.

### 기반의 재시도 — `providers/base.py`
폴백 이전에, 각 프로바이더는 `base.py`의 재시도 로직으로 일시적 오류를 먼저 흡수합니다(`_CHAT_RETRY_DELAYS =
(1, 2, 4)`, `_TRANSIENT_ERROR_MARKERS`, 재시도 불가 429 토큰 구분). 즉 **재시도(같은 모델) → 폴백(다른 모델) →
서킷 브레이커(잠시 우회)** 의 다층 방어입니다.

**정리:** nanobot은 데이터 주도 레지스트리로 프로바이더를 라우팅하고, 오류 종류를 세밀히 분류한 폴백 +
서킷 브레이커로 가용성을 확보합니다. "아무 때나 폴백"이 아니라 "폴백해도 되는 오류만" 넘기는 절제가 특징입니다.
