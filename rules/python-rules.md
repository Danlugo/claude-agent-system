# Python Rules

> Standards for all Python code. Referenced by: python-developer, data-engineer, test-engineer

---

## Code Style

| Rule | Standard |
|------|----------|
| Formatting | Black (default settings) or project formatter |
| Imports | isort (stdlib → third-party → local) |
| Line length | 88 (Black default) or project setting |
| Quotes | Double quotes (Black default) |
| Type hints | Required on all public functions |
| Docstrings | Required on all public classes and functions |

---

## Architecture Patterns

### Service Pattern

All external interactions go through service classes:

```python
# GOOD: service abstraction
from services.database import DatabaseConnection
db = DatabaseConnection()
df = db.execute_select_query("SELECT ...")

# BAD: raw connections
conn = pyodbc.connect(connection_string)
cursor = conn.cursor()
```

### Configuration Pattern

Externalize all configuration:

```python
# GOOD: env vars with defaults
BATCH_SIZE = int(os.getenv("BATCH_SIZE", "1000"))
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

# BAD: magic numbers
for chunk in pd.read_csv(path, chunksize=1000):
```

### Schema-First Data Processing

Always declare expected schemas explicitly:

```python
# GOOD: explicit dtypes
SCHEMA = {
    "hotel_id": "Int64",
    "amount": "float64",
    "period": "str",
}
df = pd.read_csv(path, dtype=SCHEMA)

# BAD: let pandas guess
df = pd.read_csv(path)
```

---

## Error Handling

| Context | Strategy | Example |
|---------|----------|---------|
| Missing required input | Fail fast | `raise ValueError(f"Missing column: {col}")` |
| Per-record processing | Log and continue | `logger.warning(f"Skipped: {e}")` |
| External service failure | Retry with backoff | `@retry(max_attempts=3)` |
| Data quality issue | Quarantine | Write bad rows to separate table |
| Configuration error | Fail immediately | `raise EnvironmentError(f"Missing: {var}")` |

---

## Logging

| Level | When |
|-------|------|
| `DEBUG` | Detailed diagnostic information |
| `INFO` | Stage transitions, row counts, file processing |
| `WARNING` | Skipped records, degraded operation, non-critical issues |
| `ERROR` | Operation failed but process continues |
| `CRITICAL` | Process cannot continue |

**Mandatory log points:**
1. Start of processing: `logger.info(f"Processing {source}: {count} records")`
2. After each transform: `logger.info(f"After {step}: {count} rows")`
3. Completion: `logger.info(f"Loaded {count} rows into {target}")`
4. Skipped records: `logger.warning(f"Skipped {count} records: {reason}")`

---

## Data Operations

### Idempotency

Every data operation must be safe to re-run:

| Strategy | When to Use |
|----------|-------------|
| DELETE-then-INSERT | Simple loads, partitioned data |
| UPSERT (MERGE) | Incremental loads with natural keys |
| Soft deletes (is_active flag) | When history matters |

### Row Count Validation

Before and after every bulk operation:

```python
before_count = db.execute_select_query(f"SELECT COUNT(*) FROM {table}").iloc[0, 0]
# ... operation ...
after_count = db.execute_select_query(f"SELECT COUNT(*) FROM {table}").iloc[0, 0]
logger.info(f"{table}: {before_count} → {after_count} (delta: {after_count - before_count})")
```

---

## Testing

| Test Type | Scope | DB Required |
|-----------|-------|-------------|
| Unit | Transform functions, utilities | No |
| Integration | Full pipeline, service interactions | Yes (DEV) |
| Data quality | Post-load validation | Yes (DEV) |

**Test file naming:** `tests/test_[module_name].py`
**Test function naming:** `test_[function]_[scenario]`
**Fixtures:** Use `conftest.py` for shared fixtures

---

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Raw DB connections | Use service classes |
| Hardcoded file paths | Use config/env vars |
| Implicit dtypes | Declare schemas explicitly |
| Print statements for debugging | Use logging module |
| Bare except clauses | Catch specific exceptions |
| Mutable default arguments | Use `None` with conditional |
| Global state | Dependency injection or config objects |
| `import *` | Explicit imports |
