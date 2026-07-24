# 3. Agent Core (에이전트 코어)

에이전트 코어는 nanobot의 심장이다. 채널에서 온 메시지를 받아 한 번의 "턴"으로 처리하고, 그 안에서 LLM 프로바이더와 도구를 반복 호출한다. 코어는 두 개의 협력 클래스로 나뉜다.

- `AgentLoop`(`nanobot/agent/loop.py`) — 채널을 마주하는 턴 조율.
- `AgentRunner`(`nanobot/agent/runner.py`) — 모델을 마주하는 반복 루프.

## 왜 둘로 나뉘는가

`docs/architecture.md`가 강조하듯, 이 분리는 디버깅의 기준선이다.

- 채널 라우팅·세션 키·워크스페이스 선택·아웃바운드 전달 문제 → `loop.py`.
- 프로바이더 호출·도구 호출·스트리밍·반복 한계 문제 → `runner.py`.

## 턴의 구성 요소

`AgentLoop`가 한 인바운드 메시지를 처리하는 동안 다음을 조립·배선한다.

1. **세션과 워크스페이스 스코프 결정** — `_effective_session_key`, 워크스페이스 스코프 리졸버([11.2](11.2-workspace-policy-and-sandboxing.md)).
2. **컨텍스트 빌드** — `ContextBuilder`(`nanobot/agent/context.py`)로 시스템 프롬프트, 메모리, 스킬, 최근 히스토리, 런타임 컨텍스트를 조립([3.3](03.3-context-builder-and-system-prompts.md)).
3. **도구 등록과 MCP 연결** — `_register_default_tools`, `_connect_mcp`([6. Tools](06-tools.md)).
4. **훅·진행 콜백 배선** — `CompositeHook`, `_build_bus_progress_callback` 등([3.1](03.1-agent-loop-and-turn-state-machine.md)).
5. **러너 실행** — `AgentRunner.run(AgentRunSpec)`가 실제 LLM/도구 루프를 돈다([3.2](03.2-agent-runner-and-llm-provider-interface.md)).
6. **저장·응답** — 세션에 최종 메시지 저장, `OutboundMessage` 조립·발행.

## 서브에이전트

메인 러너와 별개로, 복잡한 작업을 격리된 백그라운드 러너로 위임할 수 있다. `SubagentManager`(`nanobot/agent/subagent.py`)가 이를 관리하고, `spawn` 도구가 진입점이다. 자세한 내용은 [3.4 Sub-agents and Parallel Execution](03.4-sub-agents-and-parallel-execution.md).

## 하위 문서

- [3.1 Agent Loop and Turn State Machine](03.1-agent-loop-and-turn-state-machine.md)
- [3.2 Agent Runner and LLM Provider Interface](03.2-agent-runner-and-llm-provider-interface.md)
- [3.3 Context Builder and System Prompts](03.3-context-builder-and-system-prompts.md)
- [3.4 Sub-agents and Parallel Execution](03.4-sub-agents-and-parallel-execution.md)

### 참조 파일

- `nanobot/agent/loop.py`, `nanobot/agent/runner.py`
- `nanobot/agent/context.py`, `nanobot/agent/subagent.py`
- `nanobot/agent/hook.py`, `nanobot/agent/skills.py`
