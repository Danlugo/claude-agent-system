# dbt Rules

> Standards for all dbt projects. Referenced by: dbt-developer

---

## Layered Architecture

| Layer | Prefix | Materialization | Purpose |
|-------|--------|----------------|---------|
| Staging | `stg_` | view | 1:1 with source, clean and rename |
| Intermediate | `int_` | view or table | Joins, business logic, aggregation |
| Mart | `dim_` / `fact_` / `mart_` | table | Consumer-facing, optimized |

---

## Naming Conventions

| Element | Pattern | Example |
|---------|---------|---------|
| Staging model | `stg_[source]_[entity]` | `stg_raw_hotels` |
| Intermediate | `int_[entity]_[verb]` | `int_hotels_enriched` |
| Dimension | `dim_[entity]` | `dim_hotel` |
| Fact | `fact_[subject]_[type]` | `fact_os_actual` |
| Snapshot | `snap_[entity]` | `snap_hotel_history` |
| Custom test | `assert_[what]_[condition]` | `assert_hotel_pk_unique` |
| Macro | `[verb]_[noun]` | `generate_schema_name` |
| Source YAML | `_[source_name].yml` | `_raw.yml` |
| Model YAML | `_[layer].yml` or `_[entity].yml` | `_staging.yml` |

---

## Mandatory Practices

### Always Use ref() and source()

```sql
-- REQUIRED
SELECT * FROM {{ ref('stg_hotels') }}
SELECT * FROM {{ source('raw', 'hotels') }}

-- NEVER
SELECT * FROM raw.hotels
SELECT * FROM wrk.stg_hotels
```

### CTEs Over Subqueries

```sql
WITH source_data AS (
    SELECT * FROM {{ source('raw', 'entity') }}
),
transformed AS (
    SELECT
        id,
        TRIM(name) AS name,
        CAST(amount AS DECIMAL(18,2)) AS amount
    FROM source_data
    WHERE is_active = 1
)
SELECT * FROM transformed
```

### Test Every Model

**Minimum tests per model:**
- `unique` on primary key
- `not_null` on primary key
- `not_null` on required business columns

**Additional tests:**
- `relationships` for foreign keys
- `accepted_values` for enums/flags
- Custom tests for business rules

### Document Every Model

```yaml
models:
  - name: model_name
    description: "Clear description of what this model does"
    columns:
      - name: pk_column
        description: "Primary key"
        tests:
          - unique
          - not_null
```

---

## Dependency Management

Before modifying ANY model:
```bash
# Check what depends on it
dbt ls --select model_name+

# Check what it depends on
dbt ls --select +model_name

# Full lineage
dbt ls --select +model_name+
```

---

## Running dbt

```bash
# Always source .env first
cd transforms  # or dbt project root
set -a && source ../.env && set +a

# Build (run + test)
dbt build --target dev --select model_name

# Run only
dbt run --target dev --select model_name

# Test only
dbt test --target dev --select model_name

# Test by tag
dbt test --target dev --select tag:post_load
```

**NEVER:** `dbt run --target prod` or `dbt run --target qa`

---

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Hardcode table names | Use `ref()` and `source()` |
| Subqueries | CTEs |
| SELECT * in marts | Explicit column list |
| Business logic in staging | Move to intermediate layer |
| Untested models | Add schema tests at minimum |
| Undocumented models | Add YAML descriptions |
| `dbt run --full-refresh` without checking | Check model materialization first |
| Skip dependency check | Always run `dbt ls --select +model+` first |
