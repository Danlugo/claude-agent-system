# Testing Rules

> Standards for all testing. Referenced by: test-engineer, qa-automation, data-quality-engineer

---

## Test Pyramid

```
     /  E2E  \        ← Few: critical user paths only
    / Integr.  \      ← Some: component interactions, DB, APIs
   / Unit Tests  \    ← Many: pure functions, transforms, validators
```

| Level | Speed | Scope | DB Required | Count |
|-------|-------|-------|-------------|-------|
| Unit | Fast | Single function | No | Many |
| Integration | Medium | Multiple components | Yes (DEV) | Some |
| E2E | Slow | Full workflow | Yes (DEV) | Few |

---

## Naming Conventions

| Framework | Pattern | Example |
|-----------|---------|---------|
| pytest | `test_[function]_[scenario]` | `test_load_hotel_empty_file` |
| pytest class | `Test[Class]` | `TestHotelLoader` |
| dbt (custom) | `assert_[what]_[condition]` | `assert_fact_no_null_keys` |
| dbt (schema) | Built-in names | `unique`, `not_null` |
| API test | `test_[endpoint]_[method]_[scenario]` | `test_hotels_post_invalid_returns_400` |

---

## Mandatory Practices

### Every Change Gets a Test

| Change Type | Required Test |
|-------------|---------------|
| New function | Unit test with happy path + edge cases |
| Bug fix | Regression test proving the bug is fixed |
| New dbt model | unique + not_null on PK, custom test if business logic |
| API endpoint | Happy path + error cases + auth |
| Schema change | Referential integrity + NULL checks |

### Test Data

| Do | Don't |
|----|-------|
| Use fixtures (`conftest.py`) | Hardcode data in test bodies |
| Use factories for complex objects | Copy production data |
| Use minimal data (only what test needs) | Load entire datasets |
| Parameterize for multiple cases | Write separate tests for each value |

### Test Independence

- Each test runs in isolation — no shared mutable state
- Tests can run in any order
- Running a test twice gives the same result
- Cleanup after each test (fixtures with teardown)

---

## Test Tags (dbt)

| Tag | When to Run | Runner |
|-----|-------------|--------|
| `regression` | After every change | CI / test agent |
| `post_load` | After data load | ETL agent |
| `monthly_qa` | Monthly quality review | QA agent |
| `pre_load` | Before data load (schema checks) | ETL agent |

---

## Coverage Targets

| Project Type | Minimum Coverage | Focus Areas |
|-------------|-----------------|-------------|
| Python ETL | 70% | Transform functions, error handling |
| Web API | 80% | Endpoints, auth, validation |
| Library | 90% | Public API, edge cases |
| dbt | Every model tested | PK unique + not_null minimum |

---

## When Tests Fail

1. **Investigate** — is it a code bug or a test bug?
2. **Fix** — don't skip or mark as xfail without justification
3. **Document** — if known issue, add comment explaining when it will be fixed
4. **Never deploy with failing tests** — fix first

---

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Test implementation details | Test behavior/outcomes |
| Skip flaky tests | Fix the flakiness |
| Use sleep/wait in tests | Use proper assertions/polling |
| Assert True/False only | Assert specific values |
| One giant test per function | Many small focused tests |
| Test private methods | Test through public interface |
| Ignore warnings in test output | Investigate and fix |
