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

### Step 3: Spawn the Orchestrator (MANDATORY — P6)

> **This is not optional. If the project has agents installed, STOP HERE and spawn the orchestrator. Do NOT continue to Steps 4-10 yourself.**

**For ANY software work** (code, data, infrastructure, testing, architecture, security, performance):

```
Task(subagent_type: "orchestrator", prompt: "User request: [their request]. Read CLAUDE.md first.")
```

The orchestrator handles Steps 4-10 internally — it plans, routes to specialists, tests, runs, and updates docs.

**Handle directly ONLY if:**
- Pure question with zero actions ("what is a staging table?")
- Single-file lookup ("show me file X")
- Simple git operation the user explicitly asked for

**If `orchestrator` is not a built-in subagent_type**, use `"general-purpose"` and include the orchestrator's `.md` file content in the prompt.

> **Why the orchestrator and not individual agents?** The orchestrator knows the full agent roster, enforces the test→run→docs chain, handles multi-agent coordination, and ensures nothing is skipped. Spawning individual agents directly risks missing tests, skipping docs, or choosing the wrong specialist.

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
| Code change | E1 | — | P3, P5 | V1, V4 | — | S1, S3 | X1, X2, X3 |
| Database change | E1, E2, E4 | D1, D2 | P5 | V1, V2, V4 | R1, R2 | — | X2, X3 |
| Data operation | E1 | D1, D3 | P1 | V1, V2, V4 | R1, R2 | — | X2, X3 |
| Deployment | E1 | D3 | P1 | V1, V4 | R1 | S1 | X2, X3 |
| Bulk DELETE/UPDATE | E1, E4 | D1 | P5 | V2, V4 | R1, R2 | — | X2, X3 |

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

## Post-Execution Chain (MANDATORY — every task, no exceptions)

> **A task is NOT complete until all three steps pass. Do NOT report completion until this chain finishes.**

### Step A: Test & Run (V1, V4)

1. **Write tests** for every change — unit tests minimum, integration tests for multi-component changes
2. **Run the full test suite** — not just new tests, ALL applicable tests
3. **Execute the code in DEV** — run the script, pipeline, feature, or endpoint to verify it works end-to-end
4. **If tests fail or execution fails → STOP and fix** — do not proceed to Step B

| Change Type | Must Test | Must Run |
|-------------|-----------|----------|
| New script/tool | Unit + integration tests | Execute the script |
| New feature | Unit + feature tests | Run end-to-end |
| Bug fix | Regression test | Run affected workflow |
| dbt model | Schema + custom tests | `dbt build --select model` |
| API endpoint | Request/response tests | Hit the endpoint |
| ETL pipeline | Data quality tests | Run the pipeline |

### Step B: Update Documentation (X2, X3)

1. **List all files created or modified** in this task
2. **Search project docs** for references to modified files, functions, or concepts
3. **Update every stale reference** — old names, missing tools, outdated counts
4. **Add new entries** — if a new tool/test/script was created, add it to the relevant doc
5. **Log the change** (X2) — what changed, why, and when

### Step C: Report Results

Produce structured output per agent template:
- Files changed, tests added, tests passing
- Execution status (ran successfully in DEV: yes/no)
- Documentation updated (yes/no)
- Final verdict: PASS / PASS WITH WARNINGS / FAIL
