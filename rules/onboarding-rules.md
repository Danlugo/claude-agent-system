# Onboarding Rules — First-Run Scaffolding

> Referenced by all developer agents. Provides scaffolding menus when a role is invoked on a project for the first time.

---

## Detection Protocol

Before Phase 1 of any developer workflow, check if scaffolding has already been done for this role:

| Role | Already Scaffolded If | Not Scaffolded If |
|------|----------------------|-------------------|
| python-developer | `src/` exists with `.py` files | No `src/` or only empty dirs |
| api-developer | Route/endpoint files exist (`routes/`, `api/`, `app.py` with endpoints) | No route handlers found |
| frontend-developer | `src/components/` or framework entry point exists | No component structure |
| dbt-developer | `models/staging/` exists with `.sql` files | No dbt model directories |
| database-developer | `migrations/` exists or schema docs present | No migration or schema files |
| data-engineer | DAG/pipeline files exist (`dags/`, `pipelines/`, orchestration config) | No orchestration files |
| powerbi-developer | `.pbix` files exist or measure inventory doc present | No BI artifacts |

**If not scaffolded**, present the scaffolding menu below for the role. **If already scaffolded**, skip to Phase 1.

---

## Scaffolding Menus

### python-developer

```
This looks like a new Python project. I can set up a standard structure:

1. **Full scaffold**
   - src/[package]/ with __init__.py
   - src/[package]/services/ (database, storage, API clients)
   - src/[package]/utils/ (helpers, validators)
   - tests/ with conftest.py and sample test
   - .env.example with common vars
   - Logging config (structured, leveled)
   - pyproject.toml or setup.cfg

2. **Minimal** — src/[package]/, tests/, .env.example only

3. **Skip** — proceed without scaffolding
```

### api-developer

```
This looks like a new API project. I can set up a standard structure:

1. **Full scaffold**
   - routes/ (versioned: v1/)
   - middleware/ (auth, error handling, logging)
   - schemas/ (Pydantic models or JSON Schema)
   - services/ (business logic layer)
   - OpenAPI config stub
   - Health check endpoint (/health)
   - Error response format template

2. **Minimal** — routes/v1/, schemas/, health endpoint only

3. **Skip** — proceed without scaffolding
```

### frontend-developer

```
This looks like a new frontend project. I can set up a standard structure:

1. **Full scaffold**
   - src/components/ (shared UI components)
   - src/features/ (feature-specific components)
   - src/hooks/ (custom React/Vue hooks)
   - src/services/ (API client, auth service)
   - src/types/ (shared TypeScript types)
   - Theme/design token setup
   - Base layout component

2. **Minimal** — src/components/, src/services/, src/types/ only

3. **Skip** — proceed without scaffolding
```

### dbt-developer

```
This looks like a new dbt project. I can set up a standard structure:

1. **Full scaffold**
   - models/staging/ with _sources.yml
   - models/intermediate/
   - models/marts/
   - tests/ (custom test directory)
   - macros/ with generate_schema_name.sql
   - Example staging model + YAML doc
   - dbt_project.yml config (if missing)

2. **Minimal** — models/staging/ with _sources.yml, models/marts/ only

3. **Skip** — proceed without scaffolding
```

### database-developer

```
This looks like a new database project. I can set up a standard structure:

1. **Full scaffold**
   - migrations/ (numbered migration files)
   - schemas/ (DDL reference scripts per schema)
   - docs/schema-map.md (ERD or table inventory)
   - Naming conventions doc
   - Index strategy doc

2. **Minimal** — migrations/, docs/schema-map.md only

3. **Skip** — proceed without scaffolding
```

### data-engineer

```
This looks like a new pipeline project. I can set up a standard structure:

1. **Full scaffold**
   - dags/ or pipelines/ (DAG definitions)
   - tasks/ (individual task/op implementations)
   - config/ (connection configs, retry policies)
   - monitoring/ (alert templates, SLA configs)
   - Default retry/backoff template
   - Health check task template

2. **Minimal** — dags/, tasks/, default retry config only

3. **Skip** — proceed without scaffolding
```

### powerbi-developer

```
This looks like a new Power BI project. I can set up a standard structure:

1. **Full scaffold**
   - docs/measure-inventory.md (measure catalog)
   - docs/relationship-map.md (model relationships)
   - docs/rls-plan.md (RLS roles and filters)
   - docs/refresh-config.md (refresh strategy)
   - DAX naming conventions reference
   - Star schema verification checklist

2. **Minimal** — docs/measure-inventory.md, docs/relationship-map.md only

3. **Skip** — proceed without scaffolding
```

---

## After Scaffolding

1. **Confirm with user** — show what was created
2. **Delegate to test-engineer** — "Setting up test infrastructure for the scaffolded structure"
3. **Create marker** — the scaffolded directories themselves serve as the marker for future detection
4. **Log** — record scaffolding in project change log if one exists
