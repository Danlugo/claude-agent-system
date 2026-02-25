# Agent System Audit Checklist

> **Used by:** system-admin agent (Phase 1: Audit)
> **Purpose:** Structured checks with pass/fail criteria to catch real gaps — not surface-level counts.

---

## Category 1: File Integrity

| # | Check | Command | Pass If |
|---|-------|---------|---------|
| 1.1 | Agent count | `ls ~/.claude/agents/*.md \| wc -l` | = 27 |
| 1.2 | Rule count | `ls ~/.claude/rules/*.md \| wc -l` | = 13 |
| 1.3 | Template count | `ls templates/*.md \| wc -l` | = 3 |
| 1.4 | Script count | `ls scripts/*.sh \| wc -l` | = 3 |
| 1.5 | Agent line limits | `wc -l agents/**/*.md` | All < 350 lines |
| 1.6 | Rule line limits | `wc -l rules/*.md` | All < 150 lines |
| 1.7 | No empty files | `find agents/ rules/ -name '*.md' -empty` | No results |
| 1.8 | Install script runs | `bash scripts/install-global.sh` | Exit code 0, correct counts |

## Category 2: Structure Compliance

| # | Check | What to Look For | Pass If |
|---|-------|-----------------|---------|
| 2.1 | YAML frontmatter | All 4 fields: `name`, `description`, `tools`, `model` | Every agent has all 4 |
| 2.2 | Applicable Project Types | `## Applicable Project Types` section | Present in every agent |
| 2.3 | Prerequisites section | `## Prerequisites` heading | Present in every agent |
| 2.4 | Before ANY Action | `### Before ANY Action` with 3 mandatory reads: (1) global-rules.md, (2) project CLAUDE.md or system context, (3) task-specific docs or memory | Present with all 3 reads |
| 2.5 | On Error section | `### On Error` with 4-step pattern: (1) check docs/memory, (2) if known → apply, (3) if NOT known → fix + document, (4) escalation/boundary rule | All 4 steps present |
| 2.6 | Workflow section | `## Task:` with phased workflow | Present in every agent |
| 2.7 | Output section | `## Output` with structured report template including metrics table | Template present with metrics |
| 2.8 | Constraints section | `## Constraints` heading | Present in every agent |
| 2.9 | Delegation table | At least one `### Delegation` table for agents that delegate | Present for leadership agents, architects |
| 2.10 | No duplicate sections | No repeated `##` headings within same file | No duplicates |

## Category 3: Cross-Reference Integrity

| # | Check | How to Verify | Pass If |
|---|-------|--------------|---------|
| 3.1 | Rule references exist | For every rule path in agent `Required Reading` or `Before ANY Action`, check `rules/` | All referenced files exist |
| 3.2 | Agent references exist | For every agent name in `Delegation` tables, check `agents/` | All referenced agents exist |
| 3.3 | Orchestrator routing complete | Every agent in orchestrator's routing table exists in `agents/` | No phantom agents |
| 3.4 | CLAUDE.md agent references | Every agent referenced in `CLAUDE.md` exists | All exist |
| 3.5 | Rule bidirectional refs | Every rule's `Referenced by:` header lists agents that actually reference it | Bidirectional — no phantom rule codes in agents, no phantom agent names in rules |
| 3.6 | Install script directories | Category dirs in `install-global.sh` match actual directory structure | All dirs exist |
| 3.7 | All rule categories referenced | Every rule in `rules/` is referenced by at least one agent | No orphan rules |
| 3.8 | Tech rules match specializations | `python-rules.md` → python-developer, `dbt-rules.md` → dbt-developer, etc. | Each tech rule referenced by its specialist |

## Category 4: YAML Frontmatter Consistency

| # | Check | Validation | Pass If |
|---|-------|-----------|---------|
| 4.1 | Name matches filename | `name` field = filename without `.md` | All match |
| 4.2 | Description non-empty | `description` field present and < 200 chars | All valid |
| 4.3 | Valid tool names | `tools` contains only valid Claude Code tools (Read, Write, Edit, Bash, Glob, Grep, Task, TodoWrite, WebSearch, WebFetch, NotebookEdit) | No invalid tools |
| 4.4 | Valid model | `model` is one of: `opus`, `sonnet`, `haiku` | All valid |
| 4.5 | No duplicate names | `name` field unique across all agents | No duplicates |
| 4.6 | Description is quoted | `description` value in YAML is quoted (prevents parsing issues) | All quoted |
| 4.7 | Memory field valid | If `memory` field exists, value is `user` or `project` | No invalid values |

## Category 5: Orchestrator Routing Coverage

| # | Check | How to Verify | Pass If |
|---|-------|--------------|---------|
| 5.1 | All agents routable | Every agent (except orchestrator, setup-project) has >= 1 route in orchestrator's classification table | All routable |
| 5.2 | No phantom routes | Every agent name in routing table exists in `agents/` | No phantom agents |
| 5.3 | Bug fix chain includes test-engineer | Bug fix agent chain includes test-engineer | Present |
| 5.4 | Feature chain includes test-engineer | New feature chain includes test-engineer | Present |
| 5.5 | All dev agents in tech routing | All 7 developer agents listed in technology routing table | All 7 present |
| 5.6 | Issue-to-spec chain complete | Issue-to-spec chain includes: product-manager → solution-architect → test-engineer → doc-writer | Full chain present |

## Category 6: Rule Consistency

| # | Check | How to Verify | Pass If |
|---|-------|--------------|---------|
| 6.1 | Referenced by header | Every rule file has a `Referenced by:` line | All present |
| 6.2 | Global rule codes | E, D, P, V, R, S, X prefixes consistent in `global-rules.md` | All 7 categories present |
| 6.3 | Rule codes defined | No rule code referenced in agents but undefined in `global-rules.md` | All codes defined |
| 6.4 | Workflow step count | `workflow.md` step count matches references in agents | Consistent ("10 Steps" or "10-step") |
| 6.5 | Onboarding rules complete | `onboarding-rules.md` lists all 7 developer roles | All 7 present |
| 6.6 | Rule codes sequential | Within each category (E, D, P, V, R, S, X), codes are sequential with no gaps | No gaps |

## Category 7: Content Freshness

| # | Check | How to Verify | Pass If |
|---|-------|--------------|---------|
| 7.1 | No placeholder text | Search for `[TODO]`, `[TBD]`, `<!-- TODO -->`, `FIXME`, hidden HTML comments | None found |
| 7.2 | No hardcoded stale dates | Dates in examples/templates not > 6 months old | None stale |
| 7.3 | No leaked project refs | No project-specific references (except in `examples/hotel-etl/`) | None found outside examples |
| 7.4 | CHANGELOG version | `CHANGELOG.md` latest version matches git tag | Matches |
| 7.5 | No deprecated tool refs | No references to removed/deprecated Claude Code tools or APIs | None found |
| 7.6 | Agent counts consistent | Count in CLAUDE.md "What This Repo Contains" matches actual agent count per category | All match |

## Category 8: Symlink Health

| # | Check | How to Verify | Pass If |
|---|-------|--------------|---------|
| 8.1 | Agent symlinks valid | All symlinks in `~/.claude/agents/` resolve to existing files | No broken symlinks |
| 8.2 | Rule symlinks valid | All symlinks in `~/.claude/rules/` resolve to existing files | No broken symlinks |
| 8.3 | No orphan symlinks | No symlinks pointing to deleted/renamed files | None found |
| 8.4 | No duplicate agents | Same file not symlinked from multiple category directories | No duplicates |

## Category 9: Enforcement Chain Integrity

> Ensures every agent has the three-layer enforcement chain: rules read → errors handled → boundaries enforced.

| # | Check | How to Verify | Pass If |
|---|-------|--------------|---------|
| 9.1 | Before ANY Action present | `### Before ANY Action` exists in every agent | All present |
| 9.2 | Three mandatory reads | Before ANY Action contains reads for: (1) global-rules, (2) project context, (3) domain docs/memory | All 3 in every agent |
| 9.3 | On Error present | `### On Error` exists in every agent | All present |
| 9.4 | On Error has escalation boundary | On Error section includes "NEVER" boundary (what the agent must NOT do when error occurs) | All have boundary |
| 9.5 | Required Reading section | `### Required Reading` listing the specific rule/doc files the agent reads | Present in agents that reference rules |
| 9.6 | Environment declaration | `### Environment` subsection declares default environment | Present in every agent |
| 9.7 | Constraints are actionable | `## Constraints` contains specific "NEVER" and "ALWAYS" statements, not vague guidance | All have specific constraints |

## Category 10: Single Source of Truth

> Prevents content duplication that causes drift.

| # | Check | How to Verify | Pass If |
|---|-------|--------------|---------|
| 10.1 | No duplicated rule content | Agent files don't copy-paste rule content — they reference rule files instead | No inline rule copies > 5 lines |
| 10.2 | No duplicated agent lists | Agent inventories appear in exactly one place (CLAUDE.md or install script), not both with different counts | Counts consistent |
| 10.3 | No duplicated workflow steps | Workflow steps defined once in `workflow.md`, referenced (not copied) by agents | No full workflow copies in agents |
| 10.4 | Cross-reference instead of copy | Agents use "See [rule]" or "Read [file]" instead of repeating content | References, not copies |

## Category 11: Agent Quality Scoring

> Weighted scoring (0-100) per agent. Adapted from Senior Software Engineer Code Review Checklist.

| # | Dimension | Weight | Score 0 | Score 1 | Score 2 |
|---|-----------|--------|---------|---------|---------|
| 11.1 | Structure completeness | 20% | Missing 3+ sections | Missing 1-2 sections | All required sections present |
| 11.2 | Enforcement chain | 25% | No Before ANY Action or On Error | Partial (missing reads or steps) | Full chain with 3 reads + 4-step error handling |
| 11.3 | Cross-references valid | 15% | Broken references found | All references valid but incomplete coverage | All references valid and bidirectional |
| 11.4 | Output quality | 15% | No output template | Template without metrics | Full template with metrics table |
| 11.5 | Constraint specificity | 15% | No constraints or vague | Some specific, some vague | All constraints have "NEVER"/"ALWAYS" + reason |
| 11.6 | Documentation freshness | 10% | Stale dates/placeholders/leaked refs | Minor issues | Clean — no staleness indicators |

**Scoring formula:** `Total = sum(dimension_weight * dimension_score) / 2 * 100`

**Quality tiers:**
| Score | Tier | Action |
|-------|------|--------|
| 90-100 | Excellent | No action needed |
| 70-89 | Good | Minor improvements recommended |
| 50-69 | Needs Work | Schedule improvements |
| < 50 | Critical | Fix immediately |

---

## Audit Report Template

```markdown
# Agent System Audit Report
> Date: [YYYY-MM-DD] | Auditor: system-admin

## Summary
| Category | Checks | Pass | Fail | Skip |
|----------|--------|------|------|------|
| 1. File Integrity | 8 | | | |
| 2. Structure Compliance | 10 | | | |
| 3. Cross-Reference Integrity | 8 | | | |
| 4. YAML Frontmatter | 7 | | | |
| 5. Orchestrator Routing | 6 | | | |
| 6. Rule Consistency | 6 | | | |
| 7. Content Freshness | 6 | | | |
| 8. Symlink Health | 4 | | | |
| 9. Enforcement Chain | 7 | | | |
| 10. Single Source of Truth | 4 | | | |
| 11. Quality Scoring | 6 | | | |
| **TOTAL** | **72** | | | |

## Agent Quality Scores
| Agent | Structure | Enforcement | Cross-Refs | Output | Constraints | Freshness | Total | Tier |
|-------|-----------|-------------|------------|--------|-------------|-----------|-------|------|
| [agent] | /2 | /2 | /2 | /2 | /2 | /2 | /100 | [tier] |

## Failures
| # | Check | Expected | Actual | Severity |
|---|-------|----------|--------|----------|
| [id] | [check] | [expected] | [found] | high/medium/low |

## Recommendations
| # | Action | Priority | Affected Files |
|---|--------|----------|---------------|
| 1 | [action] | high/medium/low | [files] |
```
