# Power BI Rules

> Standards for Power BI development. Referenced by: powerbi-developer

---

## Design Principles

| Principle | Description |
|-----------|-------------|
| Star schema first | No measures until the semantic model has a verified star schema |
| Measure over column | Calculated columns on dimension tables only — never on fact tables |
| Variable-first DAX | Always use VAR/RETURN blocks for any multi-step logic |
| Single direction | Relationships filter one direction unless cross-filter is explicitly required |
| Test before publish | Verify measures against SQL, test RLS with sample users before deploying |

---

## DAX Best Practices

### Variables

Always use `VAR`/`RETURN` for any measure with more than one logical step:

```dax
-- GOOD: readable, debuggable
RevenuePY =
VAR CurrentRevenue = [Revenue]
VAR PriorYearRevenue =
    CALCULATE(
        [Revenue],
        SAMEPERIODLASTYEAR('dim_date'[date])
    )
RETURN
    DIVIDE(CurrentRevenue - PriorYearRevenue, PriorYearRevenue)

-- BAD: nested, hard to debug
RevenuePY = DIVIDE([Revenue] - CALCULATE([Revenue], SAMEPERIODLASTYEAR('dim_date'[date])), CALCULATE([Revenue], SAMEPERIODLASTYEAR('dim_date'[date])))
```

### CALCULATE Rules

| Rule | Guidance |
|------|----------|
| One CALCULATE per measure | Avoid nested CALCULATE — use VAR to stage the context |
| Explicit filter arguments | `CALCULATE([Revenue], dim_hotel[region] = "US-East")` not implicit filters |
| Use REMOVEFILTERS over ALL | `REMOVEFILTERS` is clearer in intent for filter removal |
| Context transition awareness | Be explicit when using CALCULATE inside row context (iterators) |

### Iterator vs Aggregator Functions

| Situation | Use | Avoid |
|-----------|-----|-------|
| Simple column sum | `SUM(fact[amount])` | `SUMX(fact, fact[amount])` |
| Conditional aggregation | `SUMX(fact, IF(...))` | `CALCULATE(SUM(...), ...)` when SUMX is simpler |
| Row-level calculation | `SUMX(fact, fact[qty] * fact[price])` | Calculated column for this |
| Filtered aggregation | `CALCULATE(SUM(...), filter)` | `SUMX` with filter inside |

**Rule:** Use aggregators (`SUM`, `COUNT`, `AVERAGE`) when the expression maps directly to a column. Use iterators (`SUMX`, `COUNTX`, `AVERAGEX`) only when a row-by-row calculation is required.

---

## Semantic Model Conventions

### Star Schema Requirements

Before creating any measures, verify:

1. All fact tables connect to dimension tables — no fact-to-fact joins
2. Dimension tables have a single primary key column
3. Fact tables reference dimension keys as foreign keys
4. `dim_date` exists and is connected to every date key in every fact table

| Check | Query |
|-------|-------|
| Orphan fact keys | `COUNTROWS(FILTER(fact, ISBLANK(RELATED(dim[key]))))` |
| Many-to-many join | Review relationship cardinality — `*:*` should not exist |
| Missing date table | Confirm `dim_date` covers the full date range of facts |

### Relationship Directions

| Type | Direction | When |
|------|-----------|------|
| Dimension → Fact | Single (default) | Always — standard star schema |
| Bridge table | Both (cross-filter) | Only for many-to-many with explicit need |
| Role-playing dimension | Single + inactive | Use `USERELATIONSHIP` in measures |

### Cardinality

| Relationship | Cardinality |
|-------------|-------------|
| Dimension PK → Fact FK | One-to-many (`1:*`) |
| Fact → Fact (bridge) | Many-to-many — only with bridge table |
| Dimension → Dimension | Avoid — denormalize instead |

---

## Measure Naming Conventions

### Naming Pattern

```
[FactName] [MetricName] [Modifier]
```

| Element | Rule | Example |
|---------|------|---------|
| Fact prefix | Match the fact table name (`Revenue`, `Occupancy`, `Budget`) | `Revenue` |
| Metric name | PascalCase, descriptive | `ADR`, `RevPAR`, `OccupancyPct` |
| Modifier | Optional — `PY`, `YTD`, `Variance`, `Pct` | `PY`, `YTD` |

### Examples

| Measure Name | What it is |
|-------------|-----------|
| `Revenue` | Base revenue aggregate |
| `RevenuePY` | Revenue same period prior year |
| `RevenueYTD` | Revenue year-to-date |
| `RevenueVariancePct` | YoY revenue variance percentage |
| `OccupancyPct` | Occupancy percentage |
| `BudgetRevenue` | Budget revenue target |
| `BudgetVariance` | Actual vs budget variance |

### Formatting

| Setting | Standard |
|---------|----------|
| Currency measures | Format string `$#,0.00` |
| Percentage measures | Format string `0.0%` |
| Count measures | Format string `#,0` |
| Display folder | Group by fact name (`Revenue`, `Occupancy`, `Budget`) |

---

## Report Design Standards

### Page Layout

| Constraint | Limit |
|-----------|-------|
| Visuals per report page | Max 8 |
| Slicers per page | Max 4 (consolidate to filter pane where possible) |
| Cards per page | Max 6 |
| Tables/matrices per page | Max 2 |

### Drill-Through Patterns

1. Define a dedicated drill-through page per entity (hotel detail, account detail)
2. Add the entity key field to the drill-through filter well
3. Add a back button — always use the default Power BI back button action
4. Drill-through pages must include: entity name, date context, and key metrics

### Bookmarks

| Use Case | Pattern |
|---------|---------|
| Toggle views (table vs chart) | Paired bookmarks — one per visual, grouped |
| Show/hide slicers | Bookmark captures slicer panel visibility |
| Reset filters | Bookmark captures cleared slicer state |

**Rule:** All bookmarks must be named descriptively (not "Bookmark 1"). Group related bookmarks.

### Visual Selection

| Data Type | Preferred Visual |
|-----------|----------------|
| Time series trend | Line chart |
| Category comparison | Bar or column chart |
| Part-to-whole | Donut or stacked bar (not pie for > 5 categories) |
| KPI status | Card or KPI visual |
| Detailed breakdown | Matrix (not table, unless flat data) |
| Geographic distribution | Map visual (if lat/long or region available) |

---

## Row-Level Security (RLS)

### Requirements

- Every semantic model published to shared workspaces must have RLS defined
- Test RLS with at least 2 sample user accounts before publishing
- Document the RLS logic in a comment inside the role definition

### Implementation Pattern

```dax
-- Role: hotel_manager
-- Filters dim_hotel to only the hotels managed by the current user
[manager_email] = USERPRINCIPALNAME()
```

### RLS Testing Checklist

| Test | How |
|------|-----|
| User sees their data | View As → select test user → verify correct subset |
| User cannot see others | Confirm records outside scope are hidden |
| Slicers respect RLS | Slicers should only show values the user can see |
| Totals respect RLS | Aggregates should match user-scoped row count |
| Admin role bypasses RLS | Confirm admin/service account is excluded from RLS |

### RLS Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| RLS on fact tables | Apply RLS on dimension tables — filter propagates to facts |
| Username hardcoded in role | Use `USERPRINCIPALNAME()` dynamically |
| Skip RLS testing | Always test with View As before publishing |
| Single "all-access" role | Define roles per access tier |

---

## Data Refresh Patterns

### Incremental Refresh

Use incremental refresh when the fact table exceeds 1M rows or refresh time exceeds 30 minutes.

| Parameter | Standard |
|-----------|---------|
| `RangeStart` | Defined as `DateTime` parameter, named exactly `RangeStart` |
| `RangeEnd` | Defined as `DateTime` parameter, named exactly `RangeEnd` |
| Archive period | Keep full history (e.g., 3 years) |
| Refresh period | Refresh only recent data (e.g., last 30 days) |
| Detect data changes | Enable if source table has a `modified_at` column |

### Partition Strategy

| Scenario | Partition By |
|---------|-------------|
| Daily transactional fact | Month (YYYY-MM) |
| Monthly summary fact | Year (YYYY) |
| Slowly changing dimension | No partitioning — full refresh |

### Refresh Failure Protocol

1. Check refresh history in the Power BI service for error detail
2. Verify source database connectivity (firewall, credentials)
3. Check for schema changes in the source — Power BI schema must match
4. For incremental refresh failures — check `RangeStart`/`RangeEnd` filter pushdown in query diagnostics
5. Document the cause and resolution in the project troubleshooting log

---

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Calculated columns on fact tables | Use DAX measures for aggregations |
| Nested CALCULATE | Use `VAR` to stage filter context |
| `ALL()` to remove filters | Use `REMOVEFILTERS()` — explicit and clear |
| SUMX where SUM is sufficient | Use aggregators when no row-level calc is needed |
| Many-to-many relationships without bridge | Create a bridge table or denormalize |
| Measures without display folders | Organize all measures into named display folders |
| Hardcoded dates in DAX | Use `dim_date` relationships + time intelligence functions |
| Publishing without RLS test | Always test RLS via View As before publish |
| More than 8 visuals per page | Split into multiple focused pages |
| Implicit measures (auto-sum) | Define all measures explicitly in the model |
| Cross-filter direction = Both by default | Use single direction; enable Both only when required |
| Role-playing dimension as duplicate table | Use inactive relationship + `USERELATIONSHIP` |
