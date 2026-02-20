# Documentation Rules

> Standards for all documentation. Referenced by: doc-writer, all agents (output reports)

---

## Principles

| Principle | Description |
|-----------|-------------|
| Single Source of Truth | Each topic in ONE doc only |
| Reference, Don't Duplicate | Link to source, don't copy content |
| Code in Agents/Tools | Not in docs (keep docs < size limits) |
| Dynamic over Static | SQL queries, not hardcoded tables |
| Update, Don't Create | Prefer updating existing docs over new files |

---

## Size Limits

| Doc Type | Max Lines |
|----------|----------|
| README | 200 |
| ETL doc | 250 |
| API doc | 500 |
| Troubleshooting | 500 |
| Architecture | 300 |
| Runbook | 200 |
| Agent definition | 350 |
| Skill/rule file | 150 |

## Code Block Limits

| Language | Max Lines | If Exceeded |
|----------|----------|-------------|
| SQL | 15 | Move to agent or tool |
| Python | 20 | Move to tool |
| Bash | 10 | Move to script |

---

## Required Sections

### Project README
1. Title + description
2. Quick Start (3-4 commands)
3. Architecture overview
4. Key commands
5. Contributing guide reference

### ETL Doc
1. Header (title, date, purpose)
2. Quick Facts table
3. Data Sources table
4. Quick Start commands
5. Data Flow diagram
6. Configuration
7. Troubleshooting
8. Validation
9. Key Tables
10. Related links

### API Doc
1. Overview + base URL
2. Authentication
3. Endpoints (method, path, params, response)
4. Error codes
5. Rate limits
6. Examples

---

## Cross-References

| Instead Of | Use |
|------------|-----|
| Copying content | `See [doc-name](path/to/doc.md)` |
| Duplicating SQL | `Run agent-name for validation` |
| Re-explaining rules | `See Rule X1 in global-rules.md` |
