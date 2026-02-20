# Database Rules

> Standards for all SQL/database work. Referenced by: database-developer, data-architect, dbt-developer

---

## Schema Design

### Star Schema (Analytics / BI)

| Element | Convention | Example |
|---------|-----------|---------|
| Dimension table | `dim_[entity]` | `dim_hotel` |
| Fact table | `fact_[subject]_[type]` | `fact_os_actual` |
| Surrogate key | `[entity]_key` (INT IDENTITY) | `hotel_key` |
| Natural key | `[entity]_id_nat` or `[entity]_id` | `hotel_id_nat` |
| Date key | `date_key` (INT, YYYYMMDD format) | `20250115` |
| Measure columns | Descriptive names with units implied | `metric_value`, `row_count` |

### Normalized Models (Transactional / API)

| Element | Convention |
|---------|-----------|
| Primary key | `id` or `[entity]_id` |
| Foreign key | `[referenced_entity]_id` |
| Timestamps | `created_at`, `updated_at` |
| Soft delete | `deleted_at` (NULL = active) |
| Status | `status` (enum/varchar) |

---

## SQL Standards

### Naming

| Element | Convention | Example |
|---------|-----------|---------|
| Tables | `snake_case`, singular or plural (be consistent) | `dim_hotel` |
| Columns | `snake_case` | `hotel_name` |
| Views | Same as tables, or `vw_` prefix | `hotel_status_vw` |
| Indexes | `idx_[table]_[columns]` | `idx_hotel_name` |
| Constraints | `pk_[table]`, `fk_[table]_[ref]`, `uq_[table]_[col]` | `pk_dim_hotel` |

### Query Style

```sql
-- GOOD: readable, formatted
SELECT
    h.hotel_key,
    h.hotel_name,
    f.metric_value
FROM mart.fact_os_actual f
JOIN mart.dim_hotel h ON h.hotel_key = f.hotel_key
WHERE f.statement_date_key >= 20250101
ORDER BY h.hotel_name;

-- BAD: cramped, hard to read
SELECT h.hotel_key, h.hotel_name, f.metric_value FROM mart.fact_os_actual f JOIN mart.dim_hotel h ON h.hotel_key = f.hotel_key WHERE f.statement_date_key >= 20250101 ORDER BY h.hotel_name;
```

---

## Safety Rules

| Rule | Description |
|------|-------------|
| **ASK before DELETE** | Always confirm with user before DELETE/TRUNCATE/DROP |
| **Backup before bulk** | Export affected rows before bulk UPDATE/DELETE (>100 rows) |
| **Row count validation** | Record counts before AND after every bulk operation |
| **DEV first** | All changes in DEV, then copy to other environments |
| **Mart = PRODUCTION** | Even DEV mart changes need explicit approval |
| **Additive first** | Prefer ADD COLUMN over ALTER/DROP COLUMN |

---

## Migration Patterns

### Safe Column Add
```sql
ALTER TABLE [schema].[table] ADD new_column [TYPE] NULL;
-- Then backfill, then add NOT NULL if needed
```

### Safe Column Rename (Two-Step)
```sql
-- Step 1: Add new column
ALTER TABLE [schema].[table] ADD new_name [TYPE];
UPDATE [schema].[table] SET new_name = old_name;
-- Step 2: Update all consumers to use new_name
-- Step 3: DROP old column (only after all consumers updated)
```

### Safe Table Migration
```sql
-- 1. Create new table
-- 2. Copy data
-- 3. Create view with old name pointing to new table
-- 4. Update consumers
-- 5. Drop view and old table
```

---

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| DROP COLUMN without checking consumers | Check all references first |
| DELETE without WHERE | Always have a WHERE clause |
| TRUNCATE on production tables | DELETE with WHERE + approval |
| SELECT * in production queries | Explicit column list |
| Implicit type conversions | Explicit CAST/CONVERT |
| Correlated subqueries in WHERE | JOIN or CTE |
| Functions on indexed columns in WHERE | Restructure to use index |
| Missing indexes on FK columns | Add index on every FK |
