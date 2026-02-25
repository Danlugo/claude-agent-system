# Agent System — Claude Code Instructions

> For human readers: see [README.md](README.md). This file is read automatically by Claude Code at session start.

> **Version:** 3.0
> **Last Updated:** February 20, 2026

---

## Requirements

| Requirement | Details |
|-------------|---------|
| Claude Code | **v1.0.60+** (subagent support) |
| Agent Teams (optional) | Add to `settings.json`: `{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }` |
| CLAUDE.md | Auto-read by Claude Code at session start — no manual step needed |

---

## First-Time Setup (for Claude)

> **When a user opens this folder in Claude Code for the first time, follow these steps.**

### Step 1: Install Globally

Run the install script to symlink all agents and rules:

```bash
bash scripts/install-global.sh
```

This symlinks all agents and rule files into `~/.claude/agents/` and `~/.claude/rules/`, making them available in every Claude Code session on this machine.

### Step 2: Confirm to User

Tell the user what was installed:
- How many agents were symlinked
- How many rules were symlinked
- That these are now available globally in all projects

### Step 3: Ask About Project Setup

Ask the user:

> "Would you like to set up agents for a specific project? I can help with:
> 1. **New project** — I'll ask about your tech stack and recommend the right agents
> 2. **Existing project** — I'll read your codebase and recommend agents based on what I find
> 3. **Skip for now** — You can set up projects later by asking me in any project"

### Step 4: Run Project Setup

If the user wants to set up a project, use the **setup-project** agent. It handles:
- New projects (asks about stack, recommends agents)
- Existing projects (reads code, auto-detects stack, recommends agents)
- Cursor migration (detects `.cursor/agents/`, offers migration options)

### Step 5: First Session in a Project

After setup-project installs agents, the **orchestrator** becomes the main entry point. On first use in a project (detected by absence of `.claude/onboarding-complete`), the orchestrator runs **Phase 0: Project Onboarding**:

- **New projects** → chains tech-lead (standards) → developer agent (scaffolding) → test-engineer (test infra)
- **Existing projects** → chains code-reviewer (quality audit) → test-engineer (coverage) → security-engineer (scan) → presents health report
- **Skip** → user can always bypass onboarding and go straight to their task

After onboarding, all development work automatically pairs with test-engineer — every code change gets tests.

---

## What This Repo Contains

| Directory | Count | Purpose |
|-----------|-------|---------|
| `agents/leadership/` | 6 | Orchestrator, Product Manager, Project Manager, Tech Lead, Setup Project, System Admin |
| `agents/architecture/` | 3 | Solution Architect, Data Architect, Integration Architect |
| `agents/development/` | 7 | Python, dbt, Database, Frontend, API, Power BI, Data Engineer |
| `agents/quality/` | 4 | Test Engineer, Data Quality, Code Reviewer, QA Automation |
| `agents/operations/` | 3 | DevOps, SRE, Release Manager |
| `agents/specialist/` | 4 | Security, Performance, Doc Writer, Data Analyst |
| `rules/` | 13 | Shared standards (global, workflow, python, dbt, database, frontend, api, powerbi, security, testing, devops, documentation, onboarding) |
| `templates/` | 3 | Agent template, rule template, project setup flow reference |
| `scripts/` | 3 | install-global, install-project, migrate-cursor-agents |
| `docs/` | 1 | Audit checklist for system-admin agent |
| `examples/` | 2 | Hotel ETL project override examples |

---

## How It Works

1. **Global agents** — Symlinked to `~/.claude/agents/` (available everywhere)
2. **Global rules** — Symlinked to `~/.claude/rules/` (referenced by agents)
3. **Project overrides** — A project can override any agent by placing a same-named `.md` in `.claude/agents/`
4. **Orchestrator** — Main entry point that routes tasks to the right specialist agent

---

## Mandatory Agent Routing (CRITICAL)

**This agent system operates as a full technology team.** When agents are installed, Claude is the **team coordinator** — not a solo developer. It does NOT write code, plan implementations, or enter plan mode itself. Instead, it delegates every task to the right specialist agent.

### The Rule: Orchestrator First

**When a project has agents installed (`.claude/agents/` or `.cursor/agents/` or `~/.claude/agents/`), the orchestrator is the FIRST AND ONLY entry point for any software work.**

The moment the user asks for ANY of these, **immediately spawn the orchestrator** — do not think, plan, or research first:
- Code changes (write, fix, refactor, add, remove, update)
- Bug fixes
- New features
- Data operations
- Database changes
- Architecture decisions
- Testing or validation
- Performance optimization
- Security review
- Any multi-step task

**The ONLY things Claude handles directly (without the orchestrator):**
- Pure questions ("what is X?", "explain Y")
- Single-file lookups ("show me file Z")
- Simple git operations the user explicitly asks for

### How to Spawn

```
Task(subagent_type: "orchestrator", prompt: "User request: [their exact request]. Read CLAUDE.md first.")
```
If `orchestrator` is not a recognized `subagent_type`, use `"general-purpose"` and include the orchestrator's `.md` file content in the prompt.

### The Mandatory Development Cycle

Every code change follows this cycle — enforced by the orchestrator:
1. **Developer agent** writes the code (python-developer, dbt-developer, etc.)
2. **Test-engineer** writes AND runs tests (V1)
3. **Execute in DEV** — the code/feature/pipeline must actually run (V4)
4. **Update documentation** — all affected docs are updated (X3)
5. **Report results** — structured completion report

### What Claude Must NEVER Do

- **NEVER enter plan mode** when agents are installed — the orchestrator plans
- **NEVER implement code directly** — developer agents implement
- **NEVER skip the orchestrator** for multi-step or multi-domain work
- **NEVER consider a task complete** without tests, execution, and doc updates
- **NEVER research or explore before delegating** — the orchestrator does its own research

---

## Agent Routing — Quick Reference

| User Says | Route To |
|-----------|----------|
| "build [feature]" | **orchestrator** (multi-agent chain) |
| "fix [bug]" | **orchestrator** (bug fix chain) |
| "is this secure?" | security-engineer |
| "is this well-tested?" | test-engineer |
| "review this code" | code-reviewer |
| "is this codebase healthy?" | orchestrator (health check) |
| "how should we build X?" | orchestrator → solution-architect |
| "optimize performance" | performance-engineer |
| "audit the agent system" | **system-admin** |
| Multi-domain question | **orchestrator** (it handles multi-agent coordination) |

---

## Setting Up a Project (After Global Install)

### Trigger Keywords

Any of these phrases should trigger the setup-project agent. **These keywords take priority over orchestrator-first (P6)** — even if the project already has agents in `.claude/agents/` or `.cursor/agents/`, these keywords mean the user wants to install/configure the agent system, not do software work.

| User Says | Action |
|-----------|--------|
| "set up agents" / "setup agents" / "install agents" | Spawn **setup-project** agent |
| "onboard this project" / "onboard" | Spawn **setup-project** agent |
| "initialize agents" / "init agents" | Spawn **setup-project** agent |

**If the project already has agents**, setup-project will detect them and ask how to handle them (keep, replace, or migrate). It will never blindly overwrite existing agents.

### The Setup → Orchestrator Handoff

1. **User triggers setup** (keyword above) → spawn `setup-project`
2. **setup-project** detects stack, recommends agents, installs them, creates CLAUDE.md
3. **After setup completes** → spawn `orchestrator` to ask the user what to work on next
4. **Orchestrator Phase 0** runs on first use (health check for existing projects, scaffolding for new)
5. **After onboarding** → orchestrator is the permanent entry point

This handoff is automatic. After setup-project finishes, ALWAYS spawn the orchestrator to continue.

### Manual Install

```bash
bash path/to/scripts/install-project.sh ~/my-project agent1 agent2
```

---

## Creating New Agents

Use `templates/agent-template.md` as the starting point. Every agent must have:
1. YAML frontmatter (`name`, `description`, `tools`, `model`)
2. Prerequisites section (mandatory checklist, on-error, environment)
3. 6-phase workflow (understand → plan → execute → test & run → update docs → final validation)
4. Output template (structured report)
5. Constraints (clear boundaries)

---

## Override Examples

See `examples/hotel-etl/` for real-world project overrides:
- `python-developer.md` — ETL-specific services, schemas, domain context
- `dbt-developer.md` — Fabric adapter, schema layout, model naming
