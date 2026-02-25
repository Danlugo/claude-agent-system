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

**When a project has agents installed, Claude MUST delegate — not implement directly.**

| Task Scope | What To Do |
|-----------|------------|
| Multi-step, multi-domain, features, bug fixes | **Spawn the orchestrator** — it routes to specialists |
| Single-domain coding (one file, one language) | **Spawn the specialist** directly (python-developer, dbt-developer, etc.) |
| Simple question, single-file lookup | Handle directly — no agent needed |

**Do NOT:**
- Enter plan mode yourself when an agent covers the task
- Implement code changes without spawning the relevant agent
- Skip the orchestrator for multi-domain work

**How to spawn an agent:**
```
Task(subagent_type: "orchestrator", prompt: "User request: [their request]. Read CLAUDE.md first.")
```
If the agent name is not a recognized `subagent_type`, use `"general-purpose"` and include the agent's `.md` file content in the prompt.

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

From any project directory, ask Claude:
- "Set up agents for this project" — triggers the setup-project agent
- Or manually: `bash path/to/scripts/install-project.sh ~/my-project agent1 agent2`

---

## Creating New Agents

Use `templates/agent-template.md` as the starting point. Every agent must have:
1. YAML frontmatter (`name`, `description`, `tools`, `model`)
2. Prerequisites section (mandatory checklist, on-error, environment)
3. Phased workflow (understand → plan → execute → test → validate)
4. Output template (structured report)
5. Constraints (clear boundaries)

---

## Override Examples

See `examples/hotel-etl/` for real-world project overrides:
- `python-developer.md` — ETL-specific services, schemas, domain context
- `dbt-developer.md` — Fabric adapter, schema layout, model naming
