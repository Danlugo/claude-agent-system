# Project Setup — Reference Guide

> This document describes how the `setup-project` agent onboards projects.
> Users don't need to read this — Claude handles everything conversationally.

---

## How It Works

1. User opens the agents repo in Claude Code
2. Claude reads `CLAUDE.md` and runs `scripts/install-global.sh` (one-time global install)
3. User says "set up agents for my project at ~/my-project"
4. Claude invokes the `setup-project` agent, which:
   - Scans the project for config files and code patterns
   - Auto-detects the tech stack
   - Recommends a set of agents
   - Handles Cursor agent migration if applicable
   - Installs the approved agents
   - Scaffolds a project `CLAUDE.md` if none exists

---

## Agent Recommendations by Project Type

### Python ETL / Data Pipeline
| Agent | Why |
|-------|-----|
| orchestrator | Core routing |
| code-reviewer | Code quality |
| python-developer | Python code |
| dbt-developer | dbt transforms |
| database-developer | SQL/schema |
| data-engineer | Pipeline orchestration |
| test-engineer | Test strategy |
| data-quality-engineer | Data validation |
| doc-writer | Documentation |

### Web Application (Full Stack)
| Agent | Why |
|-------|-----|
| orchestrator | Core routing |
| code-reviewer | Code quality |
| frontend-developer | UI components |
| api-developer | Backend API |
| database-developer | Data layer |
| test-engineer | Test strategy |
| qa-automation | E2E tests |
| security-engineer | App security |
| devops-engineer | CI/CD |

### API Service
| Agent | Why |
|-------|-----|
| orchestrator | Core routing |
| code-reviewer | Code quality |
| api-developer | Endpoints |
| database-developer | Data layer |
| test-engineer | Test strategy |
| security-engineer | Auth/security |
| devops-engineer | CI/CD |

### Data Analytics / BI
| Agent | Why |
|-------|-----|
| orchestrator | Core routing |
| code-reviewer | Code quality |
| database-developer | SQL queries |
| data-analyst | Analysis |
| powerbi-developer | Reports/dashboards |
| data-quality-engineer | Data validation |
| data-architect | Data modeling |

### Minimal (any project)
| Agent | Why |
|-------|-----|
| orchestrator | Core routing |
| code-reviewer | Code quality |
| test-engineer | Test strategy |

---

## Detection Heuristics

| File Found | Stack Detected |
|------------|---------------|
| `pyproject.toml`, `requirements.txt` | Python |
| `dbt_project.yml` | dbt |
| `package.json` with react/vue/angular | Frontend |
| `package.json` with express/fastify | Node API |
| FastAPI/Flask/Django in requirements | Python API |
| `Dockerfile`, `.github/workflows/` | CI/CD |
| `*.pbix`, `model.bim` | Power BI |
| `*.sql`, `migrations/` | Database |
| `.cursor/agents/` | Cursor project |

---

## Cursor Migration Options

| Option | What Happens | When to Use |
|--------|-------------|-------------|
| **Migrate (hybrid)** | Converts `.cursor/agents/` to `.claude/agents/` format, keeps originals | Still using Cursor sometimes |
| **Replace** | Installs global agents only, ignores Cursor agents | Fully switching to Claude Code |
| **Skip** | Installs global agents alongside, leaves Cursor untouched | Just trying Claude Code |

---

## Project CLAUDE.md Scaffold

The setup-project agent creates this template if no CLAUDE.md exists:

```markdown
# [Project Name] — Claude Code Instructions

## What This Project Does
[Description]

## Tech Stack
| Technology | Details |
|-----------|---------|
| Language | [value] |
| Framework | [value] |
| Database | [value] |

## Key Directories
| Directory | Purpose |
|-----------|---------|
| src/ | Source code |
| tests/ | Test files |

## Environment
| Environment | Access |
|-------------|--------|
| DEV | Default |
| PROD | Requires approval |
```

---

## Manual Alternative

If you prefer to run scripts directly instead of the conversational flow:

```bash
# Global install (one-time)
bash path/to/scripts/install-global.sh

# Project install (specific agents)
bash path/to/scripts/install-project.sh ~/my-project orchestrator python-developer test-engineer

# Cursor migration
bash path/to/scripts/migrate-cursor-agents.sh ~/my-project
```
