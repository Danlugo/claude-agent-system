# Standard Task Execution Workflow

> **MANDATORY:** Every agent follows this workflow before taking any action.

---

## When to Apply

Apply for:
- Code changes (any language)
- Database changes (DDL, DML)
- Infrastructure changes
- Multi-step investigations
- Data operations
- Deployments
- Follow-up prompts that trigger ANY action ("check status", "verify", "proceed")

Skip ONLY for:
- Pure knowledge questions with zero actions (e.g., "what is a staging table?")

---

## The 10 Steps

### Step 1: Read Rules

Read `rules/global-rules.md` + any tech-specific rules for the task.

### Step 2: Read Project Context

Read project `CLAUDE.md` and any relevant project docs.

| Task Type | Read These |
|-----------|-----------|
| Python code | Project README, CONTRIBUTING, architecture docs |
| Database changes | Schema docs, data model docs |
| API changes | API docs, OpenAPI spec |
| Frontend changes | Component docs, style guide |
| dbt changes | dbt project config, model docs |
| Data operations | ETL docs, data flow docs |
| Deployments | Runbooks, deployment docs |

### Step 3: Delegate to Agent (MANDATORY — P6)

If an agent exists for this task, **spawn it via the Task tool. Do NOT plan or implement the task yourself.**

| Task Scope | Action |
|-----------|--------|
| Multi-step / multi-domain | **Spawn orchestrator** — it routes to specialists |
| Single-domain coding | **Spawn the specialist** directly (see table below) |
| Simple lookup / question | Handle directly — no agent needed |

| Task Type | Spawn Agent |
|-----------|-------------|
| Full feature | **orchestrator** → routes to specialists |
| Architecture | solution-architect, data-architect, integration-architect |
| Python code | python-developer |
| dbt models | dbt-developer |
| SQL/schema | database-developer |
| Frontend/UI | frontend-developer |
| API | api-developer |
| Power BI | powerbi-developer |
| Pipelines | data-engineer |
| Testing | test-engineer, data-quality-engineer, qa-automation |
| Code review | code-reviewer |
| Deployment | devops-engineer, release-manager |
| Monitoring | sre-engineer |
| Security | security-engineer |
| Performance | performance-engineer |
| Documentation | doc-writer |
| Analysis | data-analyst |

**How to spawn:** `Task(subagent_type: "[agent-name]", prompt: "...")`. If not a built-in type, use `"general-purpose"` and include the agent's `.md` content in the prompt.

### Step 4: Test & Validation Plan

Before executing, define how you'll validate:
- What tests will you run?
- What are the expected outcomes?
- What are the rollback criteria?

### Step 5: Confirm Rule Compliance

State: **"Following all rules: YES"** or list which rules cannot be followed and why.

### Step 6: Confirm Environment

State: **"Environment: DEV"** — or QA/PROD only with explicit user approval (E1).

### Step 7: Show Validation Plan

Display the specific checks/tests/commands that will verify correctness.

### Step 8: List Applicable Rules

List every rule that applies by category:

| Task Type | E | D | P | V | R | S | X |
|-----------|---|---|---|---|---|---|---|
| Code change | E1 | — | P3, P5 | V1 | — | S1, S3 | X1, X2 |
| Database change | E1, E2, E4 | D1, D2 | P5 | V1, V2 | R1, R2 | — | X2 |
| Data operation | E1 | D1, D3 | P1 | V1, V2 | R1, R2 | — | X2 |
| Deployment | E1 | D3 | P1 | V1 | R1 | S1 | X2 |
| Bulk DELETE/UPDATE | E1, E4 | D1 | P5 | V2 | R1, R2 | — | X2 |

### Step 9: List Steps & Wait for Approval

Show the numbered step-by-step plan. **STOP and wait for user approval before executing.**

```
Waiting for approval...
| # | Option |
|---|--------|
| 1 | Proceed with plan |
| 2 | Modify plan |
| 3 | Cancel |
```

**DO NOT execute until user responds.**

### Step 10: Execute with Validation

Execute the plan, validating at each step:
- If a step fails → STOP and report (don't continue blindly)
- After all steps → run the validation plan from Step 4
- Report results

---

## Post-Execution (MANDATORY)

| Action | When | What |
|--------|------|------|
| Log changes | After ANY change | Document what changed and why |
| Update docs | After behavior changes | Update relevant documentation |
| Run tests | After ANY code/data change | Verify no regressions |
| Report results | Always | Structured output per agent template |
