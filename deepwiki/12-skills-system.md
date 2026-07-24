# 12. Skills System (스킬 시스템)

스킬은 에이전트에게 특정 작업의 절차적 지식을 주입하는 마크다운 기반 확장이다. 내장 스킬은 `nanobot/skills/` 아래에 있고, 사용자는 워크스페이스에 자신의 스킬을 추가할 수 있다.

## 스킬 포맷

각 스킬은 `SKILL.md` 파일을 담은 디렉토리다(`nanobot/skills/README.md`).

- **YAML frontmatter** — `name`, `description`, 기타 메타데이터.
- **Markdown 본문** — 에이전트를 위한 지시문.

스킬 포맷과 메타데이터 구조는 OpenClaw의 스킬 시스템 규약을 따른다(호환성 유지).

## 로딩 (`nanobot/agent/skills.py`)

`SkillsLoader`가 스킬을 발견·로드해 시스템 프롬프트에 넣는다([3.3](03.3-context-builder-and-system-prompts.md)).

- 내장 스킬 디렉토리와 워크스페이스 스킬 디렉토리를 스캔.
- `disabledSkills`(`agents.defaults.disabledSkills`)에 나열된 스킬은 제외([2](02-configuration.md)).
- 항상 로드되는 스킬(`get_always_skills`, 예: `memory`, `my`)과 요청 관련 스킬을 구분.
- 각 스킬의 요약/메타데이터를 만들어 프롬프트에 삽입.

## 사용자 제어

- `/skill` 명령으로 로드된 스킬을 조회할 수 있다(`cmd_skill`, [8.1](08.1-cli-commands-reference.md)).
- WebUI의 Skills 패널(`skills_api.py`, `useSkills.ts`)에서도 조회한다([9](09-webui.md)).
- `skill-creator` 스킬로 새 스킬을 만들고, `clawhub` 스킬로 레지스트리에서 설치할 수 있다.

## 하위 문서

- [12.1 Built-in Skills Reference](12.1-built-in-skills-reference.md)

### 참조 파일

- `nanobot/agent/skills.py` (`SkillsLoader`)
- `nanobot/skills/` (내장 스킬)
- `nanobot/webui/skills_api.py`, `nanobot/command/builtin.py` (`cmd_skill`)
