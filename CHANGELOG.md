# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-20

### Added

**Agents (27):**
- Leadership (6): orchestrator, product-manager, project-manager, tech-lead, setup-project, system-admin
- Architecture (3): solution-architect, data-architect, integration-architect
- Development (7): python-developer, api-developer, frontend-developer, dbt-developer, database-developer, data-engineer, powerbi-developer
- Quality (4): test-engineer, code-reviewer, data-quality-engineer, qa-automation
- Operations (3): devops-engineer, sre-engineer, release-manager
- Specialist (4): security-engineer, performance-engineer, doc-writer, data-analyst

**Rules (13):**
- global-rules, workflow, python-rules, dbt-rules, database-rules, frontend-rules, api-rules, powerbi-rules, security-rules, testing-rules, devops-rules, documentation-rules, onboarding-rules

**Scripts (3):**
- install-global.sh (symlink agents + rules to ~/.claude/)
- install-project.sh (install selected agents into a project)
- migrate-cursor-agents.sh (convert Cursor agents to Claude Code format)

**Templates (3):**
- agent-template.md, rule-template.md, project-setup.md

**Features:**
- Orchestrator with 6-phase workflow (onboarding, classify, task board, execute, conflict resolution, report)
- Automatic test pairing after every developer agent
- Scope detection on all developer agents (fix/enhancement/feature classification)
- First-run scaffolding for 7 developer roles
- System-admin agent with persistent memory for preference learning
- Project setup with Cursor migration support
- Project-level agent overrides
- Example project overrides (hotel-etl)
