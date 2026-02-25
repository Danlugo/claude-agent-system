# Global Rules

> These rules apply to EVERY agent, EVERY task, EVERY project. No exceptions.

---

## Rule Categories

| Prefix | Category | Purpose |
|--------|----------|---------|
| **E** | Environment | Where you can operate |
| **D** | Data Safety | Protecting data integrity |
| **P** | Process | How to execute tasks |
| **V** | Validation | Verifying correctness |
| **R** | Recovery | Handling failures and rollbacks |
| **S** | Security | Protecting credentials and secrets |
| **X** | Documentation | Keeping docs current |

---

## E: Environment Rules

### E1: DEV Only by Default

| Environment | Access |
|-------------|--------|
| **DEV** | Default — no approval needed |
| **QA/Staging** | Requires explicit user approval |
| **PROD** | Requires explicit user approval |

### E2: PROD Access

| Operation | Allowed? |
|-----------|----------|
| SELECT / Read | Yes — read freely |
| INSERT/UPDATE/DELETE/DDL | Requires explicit approval |

### E3: Read-Only Sources

When a data source is designated read-only (e.g., third-party APIs, source systems, shared databases):
- NEVER INSERT/UPDATE/DELETE on read-only sources
- Verify source designation before writing

### E4: Production Data Stores

Any schema/database that feeds end-user applications, reports, or dashboards is PRODUCTION:
- **SELECT** → OK without approval
- **INSERT/UPDATE/DELETE/DDL** → Requires explicit user approval

---

## D: Data Safety Rules

### D1: Safe Deletion

Before ANY data removal (DELETE, TRUNCATE, DROP):
1. **ASK user** for confirmation first
2. **Check row counts** — compare what will be removed vs added
3. **STOP if removing > adding** — unless user confirms

### D2: Confirm Before Config Updates

Before UPDATE/INSERT on configuration tables:
1. Preview data with SELECT
2. Confirm with user: "I'm about to update X rows. Proceed?"

### D3: Destructive Operations REQUIRE Approval

Before triggering ANY destructive operation (pipeline runs, bulk operations, deployments):
1. **STOP** — Do NOT execute
2. **SHOW the user** what will happen
3. **GET explicit "yes"**

---

## P: Process Rules

### P1: Follow Documented Procedures

When a documented procedure exists:
1. **STOP** — Don't start immediately
2. **Read the ENTIRE procedure**
3. **Execute IN ORDER**
4. **Verify each step**

### P2: Incremental Development

For new features, test one component end-to-end before building the rest.

### P3: No Duplicate Work

> Before creating ANY new script, utility, or module:

1. Check existing tools and utilities in the project
2. Check existing patterns and services
3. If similar exists: **USE IT or extend it**, don't duplicate

### P4: Fix Errors Immediately

When scripts or code break, **FIX THE CODE** — don't leave broken artifacts.

### P5: Understand Before Modifying

Before modifying ANY code, data, or config:
- **WHAT** is this?
- **HOW** is it used?
- **WHO** consumes it?
- If unsure: **ASK.**

### P6: Orchestrator First

When a project has agents installed, **spawn the orchestrator for ALL software work.** Do NOT implement, plan, or research yourself.

- The orchestrator routes to the right specialist agents
- The orchestrator enforces the test → run → docs chain
- The orchestrator handles multi-agent coordination
- **Only handle directly:** pure questions and single-file lookups

### P7: Error & Resilience Planning

Every developer agent must plan for **failure scenarios**, not just the happy path. Before considering implementation complete:

1. **Identify failure points** — what external dependencies can fail? (database, APIs, file systems, network, queues)
2. **Handle each failure explicitly:**

| Failure Type | Required Handling |
|-------------|------------------|
| Database offline / connection refused | Retry with backoff, clear error message, graceful shutdown |
| Database locks / deadlocks | Retry with jitter, timeout configuration, log the lock |
| Network timeout / API unreachable | Retry with exponential backoff, circuit breaker for repeated failures |
| File not found / permission denied | Fail fast with actionable error message (path, permission needed) |
| Disk full / write failure | Check space before bulk writes, fail with clear message |
| Invalid/corrupt input data | Validate before processing, quarantine bad records, continue with good |
| Out of memory | Batch processing, streaming, chunked reads |
| Partial failure (N of M succeeded) | Track progress, support resume/restart from last checkpoint |
| Configuration missing | Fail immediately at startup, list all missing vars |
| Concurrent access / race conditions | Use locks, transactions, or idempotent operations |

3. **Never silently swallow errors** — every caught exception must be logged or re-raised
4. **Provide actionable error messages** — include what failed, why, and what the user can do

**A feature that only works when everything goes right is not production-ready.**

---

## V: Validation Rules

### V1: Test All Changes

After ANY code or data change:
1. Run applicable tests
2. Verify expected outputs
3. Check for regressions

**NEVER consider a task complete without validation.**

### V2: Row Count Validation

Before and after ANY bulk data operation:
1. Record row count BEFORE
2. Execute operation
3. Record row count AFTER
4. Verify delta matches expectation

### V3: Cross-Environment Validation

Before syncing data between environments:
- Source row count must be >= target
- If source has FEWER rows → **STOP and investigate**

### V4: Mandatory Run & Execute

After ANY code change, the code MUST be executed/run in DEV:
1. **Scripts/tools** → Run the script and verify output
2. **Features** → Execute end-to-end in DEV
3. **dbt models** → `dbt build --select model_name` (runs + tests)
4. **API endpoints** → Hit the endpoint and verify response
5. **ETL pipelines** → Run the pipeline on sample data

**A task is NOT complete if the code was only written but never executed.** Writing code without running it is a draft, not a deliverable.

---

## R: Recovery Rules

### R1: Rollback Strategy

Before ANY destructive operation:
1. Document how to UNDO the change
2. Know what data/code will be affected
3. Have a recovery plan BEFORE executing

### R2: Backup Before Bulk

Before bulk DELETE/UPDATE affecting >100 rows:
1. Export affected rows to CSV or temp table
2. Document the backup location
3. Only then proceed with operation

### R3: Incident Response

When data corruption or system failure is detected:
1. **STOP** — Don't try to fix immediately
2. **ASSESS** — Understand the scope
3. **DOCUMENT** — Record what happened
4. **PLAN** — Create recovery plan before acting
5. **EXECUTE** — Fix with user approval

---

## S: Security Rules

### S1: No Hardcoded Credentials

All secrets must be in environment variables, `.env` files, or secrets managers:
- Database connection strings
- API keys
- Service account passwords
- Tokens

**NEVER put credentials in code, even for "quick tests."**

### S2: No Secrets in Logs

Never print or log:
- Connection strings
- API keys
- Passwords
- Bearer tokens

### S3: No Secrets in Git

Never commit:
- `.env` files
- `credentials.json`
- Any file containing secrets

### S4: Input Validation

Validate all external input at system boundaries:
- User input
- API request bodies
- File uploads
- CSV imports
- URL parameters

### S5: Dependency Awareness

Before adding a new dependency:
- Check for known vulnerabilities
- Prefer well-maintained packages
- Pin versions in requirements/lock files

---

## X: Documentation Rules

### X1: Read Docs on Errors

> When encountering ANY error:

1. **Read project docs** — check if solution exists (TROUBLESHOOTING, README, etc.)
2. **Only then** attempt a fix
3. **If NOT documented:** Fix it, then **immediately** document the solution

### X2: Log Changes

After ANY significant change, document what changed and why.

### X3: Update Docs After Changes (MANDATORY)

After ANY task completion, update ALL affected documentation:
1. **List all files created or modified** in the task
2. **Search project docs** for references to those files, functions, or concepts
3. **Update every stale reference** — old names, missing tools, outdated counts, changed behavior
4. **Add new entries** — if a new tool/test/script was created, document it
5. **Never leave stale docs** — outdated documentation is worse than no documentation

**A task is NOT complete until documentation is updated.** This is the final step before reporting completion.

### X4: Client Confidentiality in Global Agents

When updating global agents or rules from project-specific learnings:
- **Strip ALL client-specific content** — company names, database names, schema names, table names, column names, file paths, domains, URLs, employee names
- Global agents must remain **generic and reusable**
- Project-specific patterns belong in **project overrides** (`.claude/agents/`), not global definitions
- If unsure whether something is client-specific, **redact it**

---

## T: Team Collaboration Rules

### T1: Completion Reporting (MANDATORY)

When operating as a teammate in a Claude Team (spawned via Task with `team_name`):

1. **Before going idle**, send a completion message via `SendMessage`:
   - `type: "message"`, `recipient: "<team-lead-name>"`
   - Include: what was completed, files created/modified, any issues encountered
   - Include: whether assigned task is fully done or partially complete
2. **If blocked**, send a message explaining the blocker — don't go silently idle
3. **Mark tasks completed** via `TaskUpdate` before sending the completion message

> **Why:** Without explicit completion reporting, the team lead cannot distinguish between "agent finished" and "agent stalled." Silent idle wastes team coordination time.

### T2: Team Lead Verification

When acting as a team lead (orchestrator):

1. **After spawning teammates**, track expected deliverables per agent
2. **If a teammate goes idle without a completion message**, check their output directly (read files, check task status)
3. **Don't assume idle = done** — verify by inspecting deliverables
4. **Shut down teammates** via `SendMessage` with `type: "shutdown_request"` when all work is complete

---

## Quick Reference

| When | Rule | Action |
|------|------|--------|
| Every task | E1 | Confirm environment |
| Every task | V1, V4 | Run tests AND execute code in DEV |
| Every task | P6 | Spawn orchestrator for all software work |
| Error occurs | X1 | Read docs first |
| Before DELETE | D1 | ASK user, check row counts |
| Before bulk op | R2 | Backup affected rows |
| Before bulk op | V2 | Record before/after counts |
| Before PROD change | E2, E4 | Get explicit approval |
| Before destructive op | D3 | Show user, get explicit yes |
| Before config change | D2 | Preview and confirm |
| Multi-step task | P1 | Follow procedure in order |
| New feature | P2 | Test one component first |
| New script | P3 | Check existing tools |
| Script breaks | P4 | Fix immediately |
| Before modifying | P5 | Understand first |
| Writing any feature | P7 | Plan for errors, not just happy path |
| Data corruption | R3 | STOP, assess, plan, then fix |
| Credentials | S1 | Only in env vars |
| Logging | S2 | Never log secrets |
| Git commits | S3 | Never commit secrets |
| After changes | X2 | Log what changed |
| After changes | X3 | Update ALL affected docs (MANDATORY) |
