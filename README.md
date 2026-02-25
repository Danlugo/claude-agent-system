# Claude Agent System

27 specialized AI agents for Claude Code that cover the full software development lifecycle -- from requirements to deployment.

## Quick Start

```bash
# 1. Clone
git clone https://github.com/Danlugo/claude-agent-system.git

# 2. Install globally (symlinks agents + rules to ~/.claude/)
bash claude-agent-system/scripts/install-global.sh

# 3. Use in any project
# Ask Claude: "setup CAS" or "install CAS agents"
```

**Requirements:** Claude Code v1.0.60+ | macOS or Linux (WSL on Windows)

## What's Inside

### Agents (27)

| Category | Agents | Purpose |
|----------|--------|---------|
| **Leadership** (6) | orchestrator, product-manager, project-manager, tech-lead, setup-project, system-admin | Route tasks, define requirements, track progress, enforce standards |
| **Architecture** (3) | solution-architect, data-architect, integration-architect | Design systems, data models, API contracts |
| **Development** (7) | python-developer, api-developer, frontend-developer, dbt-developer, database-developer, data-engineer, powerbi-developer | Write and maintain code across all stacks |
| **Quality** (4) | test-engineer, code-reviewer, data-quality-engineer, qa-automation | Test, review, and validate everything |
| **Operations** (3) | devops-engineer, sre-engineer, release-manager | CI/CD, monitoring, releases |
| **Specialist** (4) | security-engineer, performance-engineer, doc-writer, data-analyst | Domain expertise on demand |

### Rules (13)

Shared standards that agents reference: global, workflow, Python, dbt, database, frontend, API, Power BI, security, testing, DevOps, documentation, onboarding.

### Scripts (3)

| Script | Purpose |
|--------|---------|
| `install-global.sh` | Symlink all agents + rules to `~/.claude/` (makes them available everywhere) |
| `install-project.sh` | Install selected agents into a specific project |
| `migrate-cursor-agents.sh` | Convert Cursor AI agents to Claude Code format |

## How It Works

```
~/.claude/agents/          <-- Global agents (symlinked from this repo)
~/.claude/rules/           <-- Global rules (symlinked from this repo)
your-project/.claude/agents/  <-- Project overrides (optional, takes priority)
```

1. **Global agents** are available in every Claude Code session after running `install-global.sh`
2. **The orchestrator** is the main entry point -- it routes tasks to the right specialist
3. **Project overrides** let you customize any agent for a specific project by placing a same-named `.md` file in your project's `.claude/agents/` directory

### Agent Coordination

When you ask for a **feature**, the orchestrator chains agents through a full pipeline:

```
product-manager --> solution-architect --> developer --> test-engineer --> code-reviewer
```

When you ask for a **bug fix**, it runs a shorter chain:

```
developer --> test-engineer --> code-reviewer
```

Every developer agent automatically pairs with `test-engineer` after completing its work.

## Setting Up a Project

After the global install, go to any project and tell Claude:

> "setup CAS" or "install CAS agents"

**CAS = Claude Agent System.** Using "CAS" in the keyword avoids confusion with other agent systems or existing project agents. These keywords trigger the **setup-project** agent, which:
1. Detects your tech stack (Python, dbt, React, FastAPI, etc.)
2. Checks for existing agents (`.claude/agents/`, `.cursor/agents/`) and offers to keep, replace, or migrate them
3. Recommends agents based on what it finds
4. Installs them with your approval
5. Creates a project `CLAUDE.md` if one doesn't exist
6. Hands off to the **orchestrator** for project onboarding

**If the project already has agents**, setup-project detects them and asks how to handle them — it won't blindly overwrite anything.

On the first session, the **orchestrator** runs a project onboarding:
- **New projects** -- sets up standards, scaffolds structure, initializes test infrastructure
- **Existing projects** -- runs a health check (code quality, test coverage, security scan)

## Creating Custom Agents

Use `templates/agent-template.md` as your starting point. Every agent has:

1. **YAML frontmatter** -- name, description, tools, model
2. **Prerequisites** -- mandatory reading, error handling, environment rules
3. **6-phase workflow** -- Understand, Plan, Execute, Test & Run, Update Docs, Final Validation
4. **Output template** -- structured report format
5. **Constraints** -- clear boundaries and delegation rules

See `examples/hotel-etl/` for real-world project overrides that customize global agents for a specific domain.

## Agent Teams (Experimental)

For parallel inter-agent communication, Claude Code supports Agent Teams. Add to your `settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

This enables agents to communicate directly and work on shared task lists. It's optional -- all standard workflows use sequential agent chaining, which works without this flag.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add agents, rules, and project examples.

## License

[MIT](LICENSE)
