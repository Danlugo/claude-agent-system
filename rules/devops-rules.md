# DevOps Rules

> Standards for CI/CD and deployment. Referenced by: devops-engineer, release-manager

---

## CI/CD Pipeline Principles

| Principle | Description |
|-----------|-------------|
| Fast feedback | Fail early — lint and unit tests run first, before expensive steps |
| Repeatable builds | Same inputs always produce same outputs; no environment-dependent behavior |
| Immutable artifacts | Built artifacts are never modified after creation; redeploy by rebuilding |
| Pipeline as code | All pipeline definitions live in version control alongside the codebase |
| Single source of truth | One pipeline definition per environment; no manual overrides |
| Minimal blast radius | Changes deploy to dev/staging before production; gated by environment protection |

---

## Branching Strategy

| Branch | Purpose | Rules |
|--------|---------|-------|
| `main` | Production-ready code | Protected; merges only via PR with passing CI |
| `feature/*` | New features or fixes | Branch from `main`; short-lived; PR back to `main` |
| `release/*` | Release candidates | Cut from `main`; only bugfixes allowed; merge back to `main` with tag |
| `hotfix/*` | Emergency production fixes | Branch from `main`; bypass staging only with explicit approval |

**Rules:**
- Feature branches are deleted after merge
- No direct commits to `main`
- Every merge to `main` triggers the full CI pipeline
- Release tags follow semantic versioning (`v1.2.3`)

---

## Docker Best Practices

### Multi-Stage Builds

```dockerfile
# GOOD: multi-stage — small final image, secrets not persisted
FROM python:3.12-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --prefix=/install -r requirements.txt

FROM python:3.12-slim AS runtime
COPY --from=builder /install /usr/local
COPY src/ /app/src/
WORKDIR /app

# BAD: single stage — includes build tools, large image
FROM python:3.12
RUN apt-get install -y build-essential
COPY . .
RUN pip install -r requirements.txt
```

### Non-Root User

```dockerfile
# GOOD: run as non-root
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

# BAD: running as root
# (no USER directive — container runs as root by default)
```

### Layer Caching

```dockerfile
# GOOD: dependencies before source code (rarely changed first)
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY src/ ./src/

# BAD: source code before dependencies (invalidates cache on every change)
COPY . .
RUN pip install -r requirements.txt
```

### Additional Rules

| Rule | Description |
|------|-------------|
| `.dockerignore` | Always include — exclude `.git`, `.env`, `__pycache__`, test files |
| Pin base image | Use exact digest or version tag, never `latest` in production |
| No secrets in layers | Never `COPY .env` or `ENV SECRET=...` — use runtime injection |
| Health checks | Always define `HEALTHCHECK` for long-running services |
| Minimize layers | Chain `RUN` commands with `&&` where logical |

---

## GitHub Actions Conventions

### Workflow Structure

```yaml
# GOOD: reusable workflow called from main pipeline
name: CI
on:
  push:
    branches: [main]
  pull_request:

jobs:
  lint:
    uses: ./.github/workflows/_lint.yml

  test:
    needs: lint
    uses: ./.github/workflows/_test.yml

  build:
    needs: test
    uses: ./.github/workflows/_build.yml
    with:
      image-tag: ${{ github.sha }}

  deploy-staging:
    needs: build
    uses: ./.github/workflows/_deploy.yml
    with:
      environment: staging
    secrets: inherit

  deploy-prod:
    needs: deploy-staging
    uses: ./.github/workflows/_deploy.yml
    with:
      environment: production
    secrets: inherit
```

### Secrets Management in Actions

| Rule | Description |
|------|-------------|
| Use `secrets` context | All credentials via `${{ secrets.MY_SECRET }}` |
| Never echo secrets | `run: echo ${{ secrets.TOKEN }}` exposes secrets in logs |
| Repository secrets | For credentials used across workflows |
| Environment secrets | For environment-specific credentials (staging vs prod) |
| No secrets in `env:` at job level | Prefer step-level to minimize exposure scope |

### Environment Protection

- Configure required reviewers for `production` environment in GitHub settings
- Set wait timers between staging and production deploys
- Enable deployment branch policy — only `main` and `release/*` can deploy to production
- Use OIDC token federation instead of long-lived credentials where possible

---

## Deployment Strategies

| Strategy | When to Use | Rollback Speed | Risk |
|----------|-------------|---------------|------|
| **Rolling** | Stateless services, tolerate brief mixed versions | Medium (re-deploy previous) | Low |
| **Blue-Green** | Zero-downtime requirement, easy rollback needed, DB migrations done separately | Instant (switch traffic back) | Low-Medium |
| **Canary** | High-traffic services, want gradual validation, good observability in place | Fast (route traffic back to stable) | Low (blast radius limited) |
| **Recreate** | Dev/staging only, downtime acceptable, stateful single-instance apps | N/A (must redeploy) | High (downtime) |

**Decision guide:**
- Default to **rolling** for standard web services
- Use **blue-green** when a failed deploy is unacceptable and infra cost is acceptable
- Use **canary** when changing high-risk code paths with measurable SLOs
- Never use **recreate** in production

---

## Infrastructure-as-Code Principles

| Principle | Description |
|-----------|-------------|
| Declarative | Describe desired state, not imperative steps |
| Version controlled | All IaC lives in git alongside the application |
| No manual changes | If you touch it in the console, put it in code immediately |
| Idempotent | Applying the same config multiple times produces the same result |
| Modular | Reuse modules for common patterns (VPC, ECS service, S3 bucket) |
| State management | Remote state with locking (e.g., S3 + DynamoDB for Terraform) |
| Drift detection | Run `plan` in CI to catch manual changes before they cause incidents |

```bash
# GOOD: review plan before apply
terraform plan -out=tfplan
# [review output with human]
terraform apply tfplan

# BAD: apply without review
terraform apply -auto-approve
```

---

## Secret Management

| Rule | Implementation |
|------|---------------|
| Never in code | No secrets in `.py`, `.yml`, `.json`, `.tf` files |
| Never in git | `.env` in `.gitignore`; use git-secrets or pre-commit hooks to enforce |
| Use a secrets store | GitHub Secrets for CI; environment secrets for runtime (AWS SSM, Azure Key Vault, HashiCorp Vault) |
| Least privilege | Each service gets only the secrets it needs |
| Rotate regularly | Rotate secrets on schedule and immediately on any suspected exposure |
| Audit access | Enable access logging on secrets stores; review quarterly |
| Short-lived credentials | Prefer OIDC / federated identity over long-lived API keys |

```bash
# GOOD: inject at runtime from secrets store
export DATABASE_URL=$(aws ssm get-parameter --name /myapp/prod/db-url --with-decryption --query Parameter.Value --output text)

# BAD: hardcoded in script
DATABASE_URL="postgresql://user:password@host/db"
```

---

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Store secrets in environment variables checked into git | Use `.env.example` with dummy values; real `.env` in `.gitignore` |
| Build different artifacts per environment | Build once; inject environment config at runtime |
| Use `latest` tag for production images | Pin to exact image digest or versioned tag |
| Run containers as root | Create and use a dedicated non-root user |
| Apply IaC without reviewing `plan` | Always review `plan` output before `apply` |
| SSH into servers to "quick fix" | All changes go through git and the pipeline |
| Skip staging and deploy straight to production | Every change must pass staging first |
| Store secrets in CI environment variables at org level unnecessarily | Scope secrets to the minimum required environment/repo |
| Use long-lived credentials for CI | Prefer OIDC token federation where the provider supports it |
| Ignore flaky tests in CI | Fix or quarantine flaky tests immediately; flaky CI erodes trust |
| Use `if: always()` to skip failures | Understand the failure; fix it; don't mask it |
| Hard-delete pipeline history or logs | Retain logs for the audit period required by your organization |
