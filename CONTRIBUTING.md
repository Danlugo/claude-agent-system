# Contributing

Thanks for your interest in improving the Claude Agent System! This guide covers how to add agents, rules, and project examples.

## Adding a New Agent

1. Copy `templates/agent-template.md` as your starting point
2. Place the file in the appropriate category directory:
   - `agents/leadership/` - Orchestration, management, coordination
   - `agents/architecture/` - System and data design
   - `agents/development/` - Code implementation
   - `agents/quality/` - Testing and review
   - `agents/operations/` - CI/CD, deployment, monitoring
   - `agents/specialist/` - Domain-specific expertise
3. Follow the 5-phase workflow structure (Understand, Plan, Execute, Test, Validate)
4. Include YAML frontmatter: `name`, `description`, `tools`, `model`
5. Keep the file under **350 lines**

### Agent Checklist

- [ ] YAML frontmatter with all required fields
- [ ] Prerequisites section with mandatory reading list
- [ ] Delegation table (when to hand off to other agents)
- [ ] 5-phase workflow
- [ ] Output template (structured report)
- [ ] Constraints section
- [ ] Under 350 lines

## Adding a New Rule

1. Copy `templates/rule-template.md` as your starting point
2. Place the file in `rules/`
3. Keep the file under **150 lines**
4. Document which agents reference this rule file

## Adding a Project Example

1. Create a directory in `examples/` named after your project type (e.g., `examples/saas-api/`)
2. Include only **override files** -- agents customized for your project's domain
3. **Sanitize all proprietary references** -- no company names, internal URLs, real credentials, or client data
4. Each override should demonstrate real-world customization of a global agent

## Submitting a Pull Request

1. Fork the repository
2. Create a feature branch: `feat/add-terraform-agent` or `fix/orchestrator-routing`
3. Make your changes following the guidelines above
4. Run `bash scripts/install-global.sh` to verify your changes don't break installation

### PR Checklist

- [ ] No hardcoded secrets, API keys, or credentials
- [ ] No company-specific or client-specific references (use generic examples)
- [ ] All agent files under 350 lines
- [ ] All rule files under 150 lines
- [ ] `install-global.sh` runs successfully with correct agent/rule counts
- [ ] Description explains what was added/changed and why

## Versioning

- **MAJOR** (2.0.0): Breaking changes to agent format, install scripts, or directory structure
- **MINOR** (1.1.0): New agents, new rules, significant improvements
- **PATCH** (1.0.1): Bug fixes, typos, minor clarifications

## Questions?

Open a Discussion on the repository -- we're happy to help!
