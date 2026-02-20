# API Rules

> Standards for REST/GraphQL APIs. Referenced by: api-developer, integration-architect

---

## Design Principles

| Principle | Description |
|-----------|-------------|
| API-first | Define spec (OpenAPI) before implementation |
| Consistency | Same patterns across all endpoints |
| Versioning | URL versioning (`/v1/`, `/v2/`) or header-based |
| Pagination | All list endpoints must paginate |
| Auth everywhere | No unprotected endpoints (except health/docs) |

---

## URL Conventions

| Pattern | Example |
|---------|---------|
| Collection | `GET /api/v1/hotels` |
| Single resource | `GET /api/v1/hotels/{id}` |
| Sub-resource | `GET /api/v1/hotels/{id}/rooms` |
| Action | `POST /api/v1/hotels/{id}/activate` |
| Search/filter | `GET /api/v1/hotels?status=active&region=US` |

---

## Request/Response Standards

### Success Response
```json
{
  "data": { ... },
  "meta": { "page": 1, "total": 100 }
}
```

### Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable message",
    "details": [
      { "field": "email", "issue": "Invalid format" }
    ]
  }
}
```

---

## Pagination

All list endpoints must support:
- `page` (1-indexed) + `page_size` (default 25, max 100)
- Or `cursor` + `limit` for cursor-based pagination
- Response must include total count and next page indicator

---

## Rate Limiting

| Endpoint Type | Default Limit |
|--------------|---------------|
| Public | 60 requests/minute |
| Authenticated | 300 requests/minute |
| Admin | 1000 requests/minute |
| Login/auth | 5 attempts/minute |

---

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Verbs in URLs | Use HTTP methods (`POST /hotels` not `POST /create-hotel`) |
| Return 200 for errors | Use proper HTTP status codes |
| Expose internal errors | Return generic error with correlation ID |
| Unbounded list endpoints | Always paginate |
| Accept unvalidated input | Schema validation on all inputs |
| Different error formats | One consistent error structure |
