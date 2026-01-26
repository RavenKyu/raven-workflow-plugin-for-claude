# Claude Code Workflow Configuration

Claude Code 환경에서 **Spec → GitHub Issue → Git Worktree → Beads** 워크플로우를 강제하는 설정 저장소입니다.

모든 기능 개발은 반드시 아래 워크플로우를 따라야 하며, Hook을 통한 하드 블록과 Rules/Skills를 통한 소프트 가이드로 이를 강제합니다.

---

## Plugin Marketplace

이 저장소는 Claude Code Plugin Marketplace로도 배포됩니다.

### 설치

```bash
# 마켓플레이스 추가
/plugin marketplace add <owner>/my-cluade-settings

# 플러그인 설치
/plugin install workflow@raven-workflow
```

### 플러그인으로 사용 시 명령어

모든 명령어에 `workflow:` 접두사가 붙습니다:

| 명령어 | 설명 |
|--------|------|
| `/workflow:install` | 프로젝트 초기 설정 (디렉토리, Beads, Serena MCP) |
| `/workflow:spec <name>` | 기능 스펙 작성 |
| `/workflow:create-issues <spec>` | GitHub Epic + Task 이슈 생성 |
| `/workflow:worktree <issue-#>` | 이슈 기반 Worktree 생성 |
| `/workflow:task [id]` | Beads 태스크 작업 (대화형) |
| `/workflow:ralph [--max-iterations N]` | 자율 태스크 루프 (Ralph Loop) |
| `/workflow:pr` | Pull Request 생성 |

자세한 플러그인 문서는 [`plugins/workflow/README.md`](plugins/workflow/README.md)를 참조하세요.

---

## 목차

- [워크플로우 개요](#워크플로우-개요)
- [사전 준비](#사전-준비)
- [프로젝트 구조](#프로젝트-구조)
- [단계별 워크플로우](#단계별-워크플로우)
  - [Step 1: Spec 작성](#step-1-spec-작성)
  - [Step 2: GitHub Issue 생성](#step-2-github-issue-생성)
  - [Step 3: Git Worktree 생성](#step-3-git-worktree-생성)
  - [Step 4: Beads 태스크 작업](#step-4-beads-태스크-작업)
  - [Step 5: Pull Request](#step-5-pull-request)
  - [Step 6: Merge 및 정리](#step-6-merge-및-정리)
- [명령어 레퍼런스](#명령어-레퍼런스)
- [Shell 스크립트](#shell-스크립트)
- [강제 메커니즘](#강제-메커니즘)
- [컨벤션](#컨벤션)
- [Spec 템플릿](#spec-템플릿)
- [에이전트](#에이전트)
- [설정 파일 구조](#설정-파일-구조)

---

## 워크플로우 개요

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   /spec <feature>        → specs/<feature>.md 생성              │
│         │                                                       │
│         ▼                                                       │
│   /create-issues <spec>  → GitHub Epic #42 + Task #43, #44 생성 │
│         │                  (Milestone, Label 자동 생성)          │
│         ▼                                                       │
│   /worktree <issue-#>    → ../worktrees/42-<desc>/ 생성         │
│         │                  feat/42-<desc> 브랜치 생성            │
│         │                  bd init (Beads 초기화)                │
│         ▼                                                       │
│   /task                  → bd ready → 태스크 선택               │
│         │                  코딩 → 테스트 → 커밋                  │
│         │                  bd close                              │
│         ▼                                                       │
│   /pr                    → Pull Request 생성                    │
│         │                                                       │
│         ▼                                                       │
│   merge-worktree.sh      → main 머지 + worktree 정리           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 사전 준비

| 도구 | 용도 | 설치 |
|------|------|------|
| **GitHub CLI** (`gh`) | 이슈/PR 생성 | `brew install gh` |
| **jq** | Hook에서 JSON 파싱 | `brew install jq` |
| **Beads** (`bd`) | 태스크 관리 | `.claude/scripts/setup-beads.sh` 실행 |
| **Claude Code** | 워크플로우 실행 환경 | [claude.com/claude-code](https://claude.com/claude-code) |

Beads가 설치되어 있지 않으면 setup 스크립트로 자동 설치할 수 있습니다:

```bash
.claude/scripts/setup-beads.sh
```

---

## 프로젝트 구조

```
.
├── CLAUDE.md                          # 프로젝트 메타 설정
├── README.md                          # 이 문서
├── specs/                             # 기능 스펙 문서 저장소
│   └── <feature-name>.md
│
├── .claude-plugin/
│   └── marketplace.json               # 플러그인 마켓플레이스 카탈로그
│
├── plugins/
│   └── workflow/                      # Claude Code Plugin 패키지
│       ├── .claude-plugin/plugin.json
│       ├── commands/                  # /workflow:* 명령어
│       ├── skills/workflow/SKILL.md
│       ├── agents/task-worker.md
│       ├── hooks/hooks.json
│       ├── scripts/
│       ├── templates/
│       └── README.md
│
└── .claude/
    ├── settings.json                  # Hook 설정
    ├── config.json                    # Claude Code 설정
    │
    ├── commands/                      # 슬래시 명령어
    │   ├── spec.md                    # /spec — 스펙 작성
    │   ├── create-issues.md           # /create-issues — 이슈 생성
    │   ├── worktree.md                # /worktree — 워크트리 관리
    │   ├── task.md                    # /task — 태스크 작업
    │   ├── pr.md                      # /pr — PR 생성
    │   └── ...                        # 기타 명령어
    │
    ├── scripts/                       # 워크플로우 셸 스크립트
    │   ├── create-worktree.sh         # 워크트리 생성
    │   ├── merge-worktree.sh          # 워크트리 머지 + 정리
    │   ├── delete-worktree.sh         # 워크트리 삭제 (머지 없이)
    │   └── setup-beads.sh             # Beads 설치 + 초기화
    │
    ├── hooks/                         # 강제 훅 스크립트
    │   └── enforce-worktree.sh        # 직접 브랜치 생성 차단
    │
    ├── templates/                     # 템플릿
    │   └── spec-template.md           # 스펙 마크다운 템플릿
    │
    ├── rules/                         # 항상 적용되는 규칙
    │   ├── workflow.md                # 워크플로우 강제 규칙
    │   ├── git-workflow.md            # Git/Worktree 규칙
    │   ├── coding-style.md            # Python 코딩 스타일
    │   ├── testing.md                 # 테스트 표준
    │   └── security.md               # 보안 규칙
    │
    ├── skills/                        # 자동 트리거 스킬
    │   └── workflow/SKILL.md          # 워크플로우 가이드 스킬
    │
    └── agents/                        # 서브에이전트
        ├── task-worker.md             # Beads 태스크 자동 처리
        └── ...                        # 기타 에이전트
```

---

## 단계별 워크플로우

### Step 1: Spec 작성

> 명령어: `/spec <feature-name>`

기능 개발 전에 반드시 구조화된 스펙 문서를 작성합니다.

```
/spec user-auth
```

**동작**:
1. `.claude/templates/spec-template.md` 템플릿을 로드합니다.
2. 대화형으로 각 섹션을 채웁니다:
   - **Overview** — 기능 한 줄 요약
   - **Background** — 필요 이유, 현재 상태
   - **Functional Requirements** (FR-001, FR-002, ...) — 시스템이 해야 할 것
   - **Non-Functional Requirements** (NFR-001, ...) — 성능, 보안, 확장성 제약
   - **Acceptance Criteria** (AC-001, ...) — 검증 가능한 완료 기준
   - **Out of Scope** — 명시적 제외 항목
   - **Technical Notes** — 구현 힌트, 제약사항
3. `specs/<feature-name>.md` 파일로 저장합니다.

**출력 예시**:
```
specs/user-auth.md 생성 완료.
다음 단계: /create-issues specs/user-auth.md
```

**규칙**:
- 파일명은 kebab-case (`user-auth.md`)
- 모든 FR/NFR/AC 항목은 고유 ID를 가져야 함
- 섹션은 생략 불가 (해당 없으면 "N/A" 기재)

---

### Step 2: GitHub Issue 생성

> 명령어: `/create-issues <spec-file>`

스펙 문서를 파싱하여 GitHub에 Epic + Task 이슈를 생성합니다.

```
/create-issues specs/user-auth.md
```

**동작**:
1. 스펙 파일을 읽고 요구사항을 파싱합니다.
2. **이슈 계획**을 사용자에게 보여주고 확인을 받습니다.
3. **Milestone** 생성 (없으면 자동 생성).
4. **Epic 이슈** 생성:
   - 제목: `[Epic] <Feature Name>`
   - 본문: 개요 + 태스크 체크리스트
   - 라벨: `epic`
   - 마일스톤: 기능명과 동일
5. **Task 이슈** 생성 (각 FR/NFR 당 1개):
   - 제목: 요구사항 설명
   - 본문: 상세 요구사항 + AC + Epic 참조
   - 라벨: `task`
6. Epic 본문을 실제 이슈 번호로 업데이트합니다.

**출력 예시**:
```
생성된 이슈:
  Epic:  #42 [Epic] User Authentication
  Task:  #43 Implement login endpoint
  Task:  #44 Add JWT token validation
  Task:  #45 Create user session management

다음 단계: /worktree 42
```

**규칙**:
- 이슈 생성 전에 반드시 사용자 확인을 받음
- `epic`, `task` 라벨이 없으면 자동 생성
- 모든 Task는 Epic 번호를 본문에서 참조

---

### Step 3: Git Worktree 생성

> 명령어: `/worktree <issue-number>`

GitHub 이슈에 연결된 격리된 워크트리를 생성합니다.

```
/worktree 42
```

**동작**:
1. `gh issue view 42`로 이슈 존재를 확인합니다.
2. 이슈 제목에서 description을 자동 추출합니다.
3. 워크트리를 생성합니다:
   - 경로: `../worktrees/42-user-authentication/`
   - 브랜치: `feat/42-user-authentication`
   - 베이스: `origin/main`
4. Beads가 설치되어 있으면 `bd init`을 실행합니다.

**디렉토리 레이아웃**:
```
parent/
├── my-project/              ← 메인 저장소 (여기서 작업 중)
└── worktrees/
    ├── 42-user-authentication/  ← worktree
    ├── 55-payment-flow/         ← worktree
    └── 61-dashboard-redesign/   ← worktree
```

**서브커맨드**:

| 커맨드 | 설명 |
|--------|------|
| `/worktree 42` | 이슈 #42에 대한 worktree 생성 |
| `/worktree list` | 모든 worktree 목록 표시 |
| `/worktree remove <path>` | worktree 삭제 (머지 여부 선택) |

**규칙**:
- 직접 브랜치 생성(`git checkout -b`, `git switch -c`)은 Hook에 의해 **차단**됨
- 반드시 GitHub 이슈가 먼저 존재해야 함
- description을 직접 지정할 수도 있음: `/worktree 42 user-auth`

---

### Step 4: Beads 태스크 작업

> 명령어: `/task`

워크트리 내에서 Beads 태스크를 관리하고 작업합니다.

```
/task
```

**Beads 태스크 라이프사이클**:
```
bd ready           → 작업 가능한 태스크 목록
bd update <id> --status in_progress  → 태스크 클레임
(코딩, 테스트)
bd close <id>      → 태스크 완료
```

**동작**:
1. `bd ready`로 작업 가능한 태스크를 확인합니다.
2. 태스크를 선택하고 `in_progress`로 상태를 변경합니다.
3. 태스크 내용을 분석하고 작업 계획을 제시합니다.
4. 코드를 작성하고 테스트를 실행합니다 (`uv run pytest -x -v`).
5. Conventional Commits 형식으로 커밋합니다.
6. 태스크를 `close` 처리합니다.

**서브커맨드**:

| 커맨드 | 설명 |
|--------|------|
| `/task` 또는 `/task ready` | 작업 가능한 태스크 표시 |
| `/task <id>` | 특정 태스크 클레임 및 작업 시작 |
| `/task list` | 모든 태스크 상태 표시 |
| `/task create` | 새 태스크 생성 |

**규칙**:
- 한 번에 하나의 태스크만 작업 (현재 태스크를 닫은 후 다음 진행)
- 태스크를 닫기 전에 반드시 테스트 통과 확인
- 커밋 메시지에 이슈 번호 참조 포함

---

### Step 5: Pull Request

> 명령어: `/pr`

모든 태스크가 완료되면 Pull Request를 생성합니다.

```
/pr
```

**동작**:
1. 미커밋 변경사항, 브랜치 커밋 히스토리, 변경 파일을 분석합니다.
2. Conventional Commits 스타일의 제목을 작성합니다.
3. Summary, Changes, Test Plan을 포함한 PR 본문을 생성합니다.
4. `gh pr create`로 PR을 생성합니다.

---

### Step 6: Merge 및 정리

PR이 승인/머지된 후 워크트리를 정리합니다.

```bash
.claude/scripts/merge-worktree.sh ../worktrees/42-user-authentication
```

**동작**:
1. 메인 저장소로 이동합니다.
2. `git checkout main && git merge feat/42-user-authentication`
3. `git worktree remove <path>`
4. `git branch -d feat/42-user-authentication`

머지 없이 삭제하려면:
```bash
.claude/scripts/delete-worktree.sh ../worktrees/42-user-authentication
```

---

## 명령어 레퍼런스

| 명령어 | 인자 | 설명 |
|--------|------|------|
| `/spec` | `<feature-name>` | 기능 스펙 문서 작성 |
| `/create-issues` | `<spec-file-path>` | 스펙에서 GitHub Epic + Task 이슈 생성 |
| `/worktree` | `<issue-number>` \| `list` \| `remove <path>` | Git Worktree 생성/관리 |
| `/task` | `[task-id]` \| `ready` \| `list` \| `create` | Beads 태스크 작업 |
| `/pr` | _(없음)_ | Pull Request 생성 |

---

## Shell 스크립트

스크립트는 `.claude/scripts/` 디렉토리에 위치하며, 명령어에서 내부적으로 호출되거나 직접 실행할 수 있습니다.

### `create-worktree.sh`

```bash
.claude/scripts/create-worktree.sh <issue-number> [description]
```

- GitHub 이슈 존재 여부를 확인합니다.
- `../worktrees/<number>-<description>/` 경로에 워크트리를 생성합니다.
- `feat/<number>-<description>` 브랜치를 `origin/main` 기준으로 생성합니다.
- Beads가 설치되어 있으면 `bd init`을 자동 실행합니다.
- description을 생략하면 이슈 제목에서 자동 추출합니다.

### `merge-worktree.sh`

```bash
.claude/scripts/merge-worktree.sh [worktree-path]
```

- 워크트리 브랜치를 main에 머지합니다.
- 워크트리와 브랜치를 삭제합니다.
- 인자를 생략하면 현재 디렉토리를 워크트리로 간주합니다.

### `delete-worktree.sh`

```bash
.claude/scripts/delete-worktree.sh <worktree-path>
```

- 머지 없이 워크트리와 브랜치를 강제 삭제합니다.
- 삭제 전 확인 프롬프트를 표시합니다.

### `setup-beads.sh`

```bash
.claude/scripts/setup-beads.sh
```

- `bd` 명령어가 설치되어 있는지 확인합니다.
- 미설치 시: macOS에서는 Homebrew(`brew install steveyegge/beads/bd`), 그 외에는 npm으로 설치합니다.
- 현재 디렉토리에서 `bd init`을 실행합니다.

---

## 강제 메커니즘

이 워크플로우는 4개 레이어로 강제됩니다:

| 레이어 | 파일 | 강제 수준 | 설명 |
|--------|------|-----------|------|
| **Hook** | `.claude/hooks/enforce-worktree.sh` | 하드 블록 (`exit 2`) | 직접 브랜치 생성 명령을 차단 |
| **Rule** | `.claude/rules/workflow.md` | 소프트 (`IMPORTANT` 강조) | 매 세션마다 로드되는 워크플로우 규칙 |
| **Skill** | `.claude/skills/workflow/SKILL.md` | 소프트 (자동 트리거) | 기능 개발 시작 시 워크플로우 안내 |
| **CLAUDE.md** | `CLAUDE.md` | 소프트 (매 세션 로드) | 프로젝트 수준 워크플로우 명시 |

### Hook 상세: `enforce-worktree.sh`

Claude Code의 `PreToolUse` 이벤트에서 Bash 명령을 감시합니다.

**차단되는 명령**:
```bash
git checkout -b <branch>    # 차단
git switch -c <branch>      # 차단
git branch <new-name>       # 차단
```

**허용되는 명령**:
```bash
git branch -d <branch>      # 허용 (삭제)
git branch -D <branch>      # 허용 (강제 삭제)
git branch --list            # 허용 (목록)
git branch -v                # 허용 (상세 목록)
git branch -a                # 허용 (전체 목록)
git branch --show-current    # 허용 (현재 브랜치)
```

차단 시 출력:
```
BLOCKED: 직접 브랜치 생성이 차단되었습니다.
Use /worktree <issue-number> to create a worktree-based branch.
```

Hook 설정은 `.claude/settings.json`에 정의되어 있습니다:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/enforce-worktree.sh"
          }
        ]
      }
    ]
  }
}
```

---

## 컨벤션

### Worktree 경로

```
../worktrees/<issue-number>-<description>/
```

예: `../worktrees/42-user-authentication/`

### 브랜치 네이밍

```
feat/<issue-number>-<description>
```

예: `feat/42-user-authentication`

### 커밋 메시지

Conventional Commits 형식을 따릅니다:

```
<type>(<scope>): <description>

<body — WHAT and WHY>

Refs: #<issue-number>
```

예:
```
feat(auth): add JWT token validation

Implement token verification middleware that validates
JWT tokens on protected routes.

Refs: #44
```

### Spec 파일명

```
specs/<kebab-case-feature-name>.md
```

예: `specs/user-auth.md`, `specs/payment-flow.md`

---

## Spec 템플릿

`.claude/templates/spec-template.md`에 정의된 템플릿:

```markdown
# <Feature Name>

## Overview
<!-- 한 문단으로 요약 -->

## Background
<!-- 왜 필요한지, 현재 상태는 -->

## Functional Requirements
- [ ] FR-001: <requirement>
- [ ] FR-002: <requirement>

## Non-Functional Requirements
- [ ] NFR-001: <requirement (performance, security, etc.)>

## Acceptance Criteria
- [ ] AC-001: <testable criterion>

## Out of Scope
- <명시적 제외 항목>

## Technical Notes
<!-- 구현 힌트, 제약사항 -->
```

### 섹션 설명

| 섹션 | 설명 | 예시 |
|------|------|------|
| **Overview** | 기능을 한 문단으로 설명 | "사용자가 이메일/비밀번호로 로그인할 수 있는 인증 시스템" |
| **Background** | 필요성과 현재 상태 | "현재 인증이 없어 모든 API가 공개 상태" |
| **Functional Requirements** | 시스템이 반드시 수행해야 하는 것 | "FR-001: 이메일/비밀번호 로그인 엔드포인트 제공" |
| **Non-Functional Requirements** | 성능, 보안, 확장성 제약 | "NFR-001: 로그인 응답 시간 200ms 이하" |
| **Acceptance Criteria** | 검증 가능한 완료 조건 | "AC-001: 올바른 자격증명으로 JWT 토큰 발급 확인" |
| **Out of Scope** | 이번에 하지 않는 것 | "소셜 로그인 (Google, GitHub)은 다음 스프린트" |
| **Technical Notes** | 구현 힌트 | "PyJWT 라이브러리 사용, 토큰 만료 1시간" |

---

## 에이전트

### task-worker

Beads 태스크를 자동으로 처리하는 에이전트입니다.

**동작 순서**:
1. `bd ready`로 작업 가능한 태스크를 찾습니다.
2. 태스크를 클레임합니다 (`bd update <id> --status in_progress`).
3. 태스크 내용을 분석하고 코드를 수정합니다.
4. 테스트를 실행합니다 (`uv run pytest -x -v`).
5. Conventional Commits로 커밋합니다.
6. 태스크를 닫습니다 (`bd close <id>`).

**사용 가능한 도구**: Read, Write, Edit, Bash, Grep, Glob

---

## 설정 파일 구조

### `.claude/settings.json`

Hook 설정을 관리합니다. `PreToolUse` 이벤트에서 Bash 명령 실행 전에 `enforce-worktree.sh`를 호출합니다.

### `.claude/rules/`

매 세션마다 자동으로 로드되는 규칙 파일입니다:

| 파일 | 내용 |
|------|------|
| `workflow.md` | Spec → Issue → Worktree → Beads 워크플로우 강제 |
| `git-workflow.md` | Conventional Commits, Worktree 규칙 |
| `coding-style.md` | Python 코딩 스타일 (PEP 8, ruff, type hints) |
| `testing.md` | pytest 기반 테스트 표준 |
| `security.md` | 보안 규칙 (시크릿 관리, 입력 검증) |

### `.claude/skills/workflow/SKILL.md`

기능 개발 관련 요청을 감지하면 자동으로 워크플로우를 안내합니다. 다음 상황에서 트리거됩니다:

- 새로운 기능이나 태스크를 시작할 때
- "어떻게 시작하나요?" 같은 질문을 할 때
- 브랜치, 이슈, 스펙을 언급할 때
- 워크플로우를 건너뛰려고 할 때
