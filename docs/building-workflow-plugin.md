# Claude Code Workflow Plugin 만들기

> Spec → GitHub Issue → Git Worktree → Beads 워크플로우를 Claude Code Plugin으로 패키징하고, Ralph Loop을 통합하여 자율 태스크 실행까지 지원하는 플러그인을 만든 과정을 정리합니다.

---

## 왜 만들게 되었나?

### 문제: 반복되는 워크플로우 설정

Claude Code로 개발할 때마다 동일한 워크플로우를 프로젝트에 세팅하는 과정이 반복됩니다.

```
매번 새 프로젝트마다...
1. .claude/commands/ 에 슬래시 명령어 복사
2. .claude/rules/ 에 코딩 규칙 복사
3. .claude/hooks/ 에 브랜치 생성 차단 훅 설정
4. .claude/scripts/ 에 워크트리 관리 스크립트 복사
5. .claude/settings.json 에 훅 연결 설정
```

프로젝트가 하나둘 늘어나면서 이 설정 파일들을 관리하는 것 자체가 부담이 되었습니다. 어떤 프로젝트는 최신 버전이고, 어떤 프로젝트는 예전 버전의 명령어를 쓰고 있는 상황도 생겼습니다.

### 해결: Plugin으로 패키징

Claude Code는 **Plugin 시스템**을 제공합니다. 플러그인으로 패키징하면:

- **한 줄 설치**: `/plugin install workflow@raven-workflow`
- **버전 관리**: 마켓플레이스에서 업데이트 가능
- **네임스페이싱**: 명령어가 `/workflow:spec`, `/workflow:task` 형태로 충돌 없이 공존
- **팀 공유**: GitHub 저장소 하나로 팀 전체가 동일한 워크플로우를 사용

### 추가 목표: Ralph Loop 통합

기존 워크플로우는 태스크를 하나씩 수동으로 처리해야 했습니다. Ralph Loop(자율 반복 실행)을 통합하면 Claude가 모든 Beads 태스크를 자동으로 처리할 수 있습니다.

```
기존: /task → 하나씩 수동 처리
개선: /workflow:ralph → 전체 태스크 자율 처리
```

---

## 플러그인 만드는 과정

### 1단계: 리서치 — 플러그인 구조 파악

먼저 Claude Code Plugin 시스템이 어떻게 동작하는지 조사했습니다.

**핵심 발견사항:**

| 항목 | 내용 |
|------|------|
| 매니페스트 | `.claude-plugin/plugin.json` — 플러그인 이름, 버전, 설명 |
| 명령어 | `commands/*.md` — 슬래시 명령어 정의 |
| 스킬 | `skills/*/SKILL.md` — 자동 트리거 가이드 |
| 에이전트 | `agents/*.md` — 서브에이전트 정의 |
| 훅 | `hooks/hooks.json` — 도구 실행 전후 스크립트 |
| 규칙 제한 | **Rules는 플러그인에 포함 불가** → Skills에 통합해야 함 |
| 경로 참조 | `$CLAUDE_PROJECT_DIR` 대신 `$CLAUDE_PLUGIN_ROOT` 사용 |

**중요한 제약사항 발견**: 플러그인은 `rules/` 디렉토리를 포함할 수 없습니다. 기존 `.claude/rules/`에 있던 코딩 스타일, Git 규칙, 보안 규칙 등을 Skills의 SKILL.md에 통합해야 했습니다.

### 2단계: Ralph Loop 통합 방식 결정

Ralph Loop을 어떻게 통합할지 세 가지 옵션을 검토했습니다.

| 옵션 | 방식 | 장단점 |
|------|------|--------|
| A. 별도 설치 | 공식 `ralph-wiggum` 플러그인 별도 사용 | 단순하지만 2개 플러그인 관리 필요 |
| B. 내장 | Ralph 기능을 우리 플러그인에 완전 포함 | 올인원이지만 Ralph 업데이트 추적 필요 |
| **C. 하이브리드** | Beads 전용 Ralph 명령만 추가 | **Beads 최적화 + 독립성 유지** |

**C안(하이브리드)을 선택**: `/workflow:ralph` 명령을 추가하되, Beads 태스크 큐에 특화된 자율 루프로 구현했습니다.

### 3단계: 디렉토리 구조 설계

기존 `.claude/` 구조를 플러그인 형태로 재배치했습니다.

```
기존 (.claude/)              →  플러그인 (plugins/workflow/)
─────────────────────────────────────────────────────────────
.claude/commands/spec.md     →  commands/spec.md
.claude/commands/task.md     →  commands/task.md
.claude/hooks/enforce-*.sh   →  scripts/enforce-worktree.sh
.claude/settings.json        →  hooks/hooks.json
.claude/scripts/*.sh         →  scripts/*.sh
.claude/rules/*.md           →  skills/workflow/SKILL.md (통합)
(없음)                        →  commands/ralph.md (신규)
(없음)                        →  commands/install.md (신규)
(없음)                        →  .claude-plugin/plugin.json (신규)
```

### 4단계: 파일 마이그레이션 + 경로 수정

기존 파일들을 복사하면서 경로 참조를 모두 변경했습니다.

**Before** (기존 `.claude/` 방식):
```bash
# worktree.md 에서
.claude/scripts/create-worktree.sh <issue-number>
```

**After** (플러그인 방식):
```bash
# worktree.md 에서
bash "${CLAUDE_PLUGIN_ROOT}/scripts/create-worktree.sh" <issue-number>
```

**Before** (기존 settings.json):
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/enforce-worktree.sh"
      }]
    }]
  }
}
```

**After** (플러그인 hooks.json):
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "bash \"${CLAUDE_PLUGIN_ROOT}/scripts/enforce-worktree.sh\""
      }]
    }]
  }
}
```

### 5단계: 신규 명령어 작성

#### `/workflow:ralph` — 자율 태스크 루프

Beads 태스크를 자동으로 처리하는 Ralph Loop 명령어를 새로 작성했습니다.

```
동작 흐름:
1. Pre-flight: bd 설치 확인, worktree 확인, 태스크 큐 확인
2. Loop (최대 N회 반복):
   bd ready → claim → implement → test → commit → close
3. Summary: 완료/실패/잔여 태스크 보고
```

안전장치:
- `--max-iterations N` (기본값: 20)으로 무한 루프 방지
- 테스트 통과 필수 (3회까지 재시도)
- 모호한 태스크는 건너뛰고 보고

#### `/workflow:install` — 프로젝트 초기 설정

새 프로젝트에서 워크플로우를 세팅하는 명령어도 추가했습니다.

```
동작:
1. specs/ 디렉토리 생성
2. Beads(bd) 설치
3. Serena MCP 서버 설정 (.mcp.json 생성)
4. (선택) Rules 파일 복사
5. .gitignore 업데이트
```

### 6단계: Serena MCP 통합

코드 인텔리전스를 위한 Serena MCP 서버를 `/workflow:install` 과정에서 자동 설정하도록 추가했습니다.

설치 시 프로젝트 루트에 `.mcp.json`을 생성합니다:

```json
{
  "mcpServers": {
    "serena": {
      "type": "stdio",
      "command": "uvx",
      "args": [
        "--from", "git+https://github.com/oraios/serena",
        "serena", "start-mcp-server",
        "--context=claude-code", "--project-from-cwd"
      ]
    }
  }
}
```

이렇게 하면 프로젝트 수준에서 Serena가 설정되어 팀원들도 동일한 환경을 사용할 수 있습니다.

### 7단계: Skills에 Rules 통합

플러그인은 `rules/` 디렉토리를 지원하지 않으므로, 기존 5개 규칙 파일의 핵심 내용을 `skills/workflow/SKILL.md`에 통합했습니다.

```
통합된 규칙:
- coding-style.md → Python 코딩 스타일 (PEP 8, ruff, type hints)
- git-workflow.md → Conventional Commits, Worktree 규칙
- workflow.md     → 개발 워크플로우 순서
- testing.md      → pytest 테스트 표준
- security.md     → 보안 규칙
```

### 8단계: 마켓플레이스 구조로 재배치

플러그인을 만든 후, GitHub를 통해 배포할 수 있도록 마켓플레이스 구조로 재배치했습니다.

```
Before:                       After:
plugin/                       .claude-plugin/
├── .claude-plugin/             └── marketplace.json  ← 카탈로그
│   └── plugin.json           plugins/
├── commands/                   └── workflow/          ← 플러그인
└── ...                             ├── .claude-plugin/
                                    │   └── plugin.json
                                    ├── commands/
                                    └── ...
```

마켓플레이스 카탈로그 (`.claude-plugin/marketplace.json`):

```json
{
  "name": "raven-workflow",
  "owner": { "name": "Raven" },
  "plugins": [
    {
      "name": "workflow",
      "source": "./plugins/workflow",
      "description": "Enforced Spec → Issue → Worktree → Beads workflow with Ralph loop",
      "version": "1.0.0",
      "category": "productivity"
    }
  ]
}
```

---

## 설치 방법

### 사전 요구사항

| 도구 | 용도 | 설치 |
|------|------|------|
| [Claude Code](https://claude.com/claude-code) | 워크플로우 실행 환경 | 공식 사이트 |
| [GitHub CLI](https://cli.github.com/) (`gh`) | 이슈/PR 관리 | `brew install gh` |
| [jq](https://jqlang.github.io/jq/) | Hook JSON 파싱 | `brew install jq` |
| [uv](https://docs.astral.sh/uv/) (`uvx`) | Serena MCP 실행 | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |

### 플러그인 설치

```bash
# 1. 마켓플레이스 추가 (최초 1회)
/plugin marketplace add RavenKyu/raven-workflow-plugin-for-claude

# 2. 플러그인 설치
/plugin install workflow@raven-workflow
```

### 프로젝트 초기 설정

플러그인 설치 후, 프로젝트에서 초기 설정을 실행합니다:

```bash
/workflow:install
```

이 명령이 수행하는 작업:
- `specs/` 디렉토리 생성
- Beads(`bd`) 설치
- Serena MCP 설정 (`.mcp.json`)
- `.gitignore` 업데이트

---

## 사용 방법

### 전체 워크플로우

```
┌──────────────────┐
│ /workflow:spec    │ ← 기능 스펙 작성
│ user-auth         │
└────────┬─────────┘
         ▼
┌──────────────────┐
│ /workflow:create- │ ← GitHub Epic + Task 이슈 생성
│ issues specs/...  │
└────────┬─────────┘
         ▼
┌──────────────────┐
│ /workflow:worktree│ ← 격리된 작업 환경 생성
│ 42                │
└────────┬─────────┘
         ▼
┌──────────────────┐
│ /workflow:task    │ ← 수동 태스크 작업 (하나씩)
│   또는            │
│ /workflow:ralph   │ ← 자율 태스크 루프 (전체 자동)
└────────┬─────────┘
         ▼
┌──────────────────┐
│ /workflow:pr      │ ← Pull Request 생성
└──────────────────┘
```

### Step 1: 스펙 작성

```bash
/workflow:spec user-auth
```

대화형으로 기능 요구사항을 정리하여 `specs/user-auth.md`를 생성합니다.

### Step 2: GitHub 이슈 생성

```bash
/workflow:create-issues specs/user-auth.md
```

스펙을 파싱하여 Epic 이슈 1개 + 각 요구사항별 Task 이슈를 자동 생성합니다.

### Step 3: Worktree 생성

```bash
/workflow:worktree 42
```

이슈 #42에 연결된 격리된 작업 환경을 생성합니다:
- 경로: `../worktrees/42-user-authentication/`
- 브랜치: `feat/42-user-authentication`

### Step 4: 태스크 작업

**수동 모드** — 태스크를 하나씩 대화형으로 처리:

```bash
/workflow:task
```

**자율 모드** — 모든 태스크를 Claude가 자동 처리:

```bash
/workflow:ralph --max-iterations 30
```

### Step 5: PR 생성

```bash
/workflow:pr
```

---

## 이 플러그인의 장점

### 1. 한 줄 설치, 즉시 사용

```bash
/plugin install workflow@raven-workflow
```

기존에는 10개 이상의 파일을 수동으로 복사하고 경로를 조정해야 했습니다. 이제는 한 줄이면 됩니다. 팀원이 합류해도 동일한 명령 한 줄로 같은 환경을 갖출 수 있습니다.

### 2. 워크플로우 강제 — 실수 방지

직접 브랜치를 만들려고 하면 Hook이 차단합니다:

```
$ git checkout -b my-feature
BLOCKED: Direct branch creation is not allowed.
Use /workflow:worktree <issue-number> to create a worktree-based branch.
```

스펙 없이 코딩을 시작하려 하면 Skill이 워크플로우를 안내합니다. 이 "강제"는 코드 품질과 프로젝트 추적성을 보장합니다.

### 3. Ralph Loop — 자율 태스크 실행

가장 큰 차별점입니다. `/workflow:ralph`를 실행하면 Claude가 자율적으로:

```
bd ready → claim → implement → test → commit → close → repeat
```

모든 Beads 태스크를 순차적으로 처리합니다. 사람이 개입하지 않아도 됩니다.

**안전장치가 내장되어 있어** 무한 루프, 테스트 실패, 모호한 태스크 등의 상황을 자동으로 처리합니다.

### 4. Serena MCP 자동 설정

`/workflow:install`만 실행하면 Serena 코드 인텔리전스 MCP 서버가 프로젝트에 자동 설정됩니다. 심볼 검색, 참조 추적, 리네임 리팩토링 등 고급 코드 분석 기능을 바로 사용할 수 있습니다.

### 5. Worktree 기반 격리

Git Worktree를 사용하여 각 이슈를 완전히 격리된 환경에서 작업합니다.

```
parent/
├── my-project/                  ← 메인 저장소 (항상 깨끗)
└── worktrees/
    ├── 42-user-authentication/  ← 이슈 #42 작업
    ├── 55-payment-flow/         ← 이슈 #55 작업
    └── 61-dashboard-redesign/   ← 이슈 #61 작업
```

- 여러 이슈를 동시에 작업할 수 있습니다
- 메인 브랜치가 항상 깨끗하게 유지됩니다
- 브랜치 전환 없이 컨텍스트 스위칭이 가능합니다

### 6. 네임스페이싱 — 충돌 없는 공존

플러그인의 모든 명령어는 `workflow:` 접두사가 붙습니다. 다른 플러그인과 충돌하지 않고 공존할 수 있습니다.

```
/workflow:spec        ← 이 플러그인
/workflow:ralph       ← 이 플러그인
/review               ← 다른 플러그인
/deploy               ← 또 다른 플러그인
```

### 7. 구조화된 개발 프로세스

```
Spec(왜?) → Issue(무엇?) → Worktree(어디?) → Task(어떻게?) → PR(검증)
```

각 단계가 이전 단계의 산출물을 입력으로 받습니다. 스펙 없이 이슈를 만들 수 없고, 이슈 없이 워크트리를 만들 수 없습니다. 이 구조화된 프로세스가 "일단 코딩부터 시작하는" 안티패턴을 방지합니다.

---

## 저장소 구조

```
raven-workflow-plugin-for-claude/
│
├── .claude-plugin/
│   └── marketplace.json           # 마켓플레이스 카탈로그
│
├── plugins/
│   └── workflow/                  # 플러그인 본체
│       ├── .claude-plugin/
│       │   └── plugin.json        # 플러그인 매니페스트
│       ├── commands/              # 슬래시 명령어 (7개)
│       │   ├── spec.md
│       │   ├── create-issues.md
│       │   ├── worktree.md
│       │   ├── task.md
│       │   ├── ralph.md           # 자율 태스크 루프
│       │   ├── pr.md
│       │   └── install.md         # 프로젝트 초기 설정
│       ├── skills/
│       │   └── workflow/SKILL.md  # 워크플로우 가이드 + 규칙 통합
│       ├── agents/
│       │   └── task-worker.md     # 태스크 자동 처리 에이전트
│       ├── hooks/
│       │   └── hooks.json         # 브랜치 생성 차단 훅
│       ├── scripts/               # 셸 스크립트 (5개)
│       └── templates/
│           └── spec-template.md   # 스펙 템플릿
│
├── .claude/                       # 프로젝트 자체의 Claude 설정
│   ├── commands/
│   ├── rules/
│   ├── skills/
│   └── ...
│
├── CLAUDE.md
└── README.md
```

---

## 마무리

이 플러그인은 "Claude Code로 개발할 때의 모범 사례"를 코드화한 것입니다.

스펙부터 시작하여 이슈를 만들고, 격리된 환경에서 작업하고, 태스크 단위로 추적하고, PR로 마무리하는 전체 흐름을 — 한 줄 설치로 어떤 프로젝트에서든 사용할 수 있습니다.

Ralph Loop까지 활용하면, 사람은 "무엇을 만들지"만 결정하고 "어떻게 만들지"는 Claude에게 위임하는 자율 개발 워크플로우가 가능해집니다.

```bash
# 마켓플레이스 추가
/plugin marketplace add RavenKyu/raven-workflow-plugin-for-claude

# 플러그인 설치
/plugin install workflow@raven-workflow

# 프로젝트 설정
/workflow:install

# 자율 개발 시작
/workflow:spec my-feature
/workflow:create-issues specs/my-feature.md
/workflow:worktree 1
/workflow:ralph
```
