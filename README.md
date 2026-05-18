# Govnr Core

Govnr core contains the API, domain model, application use cases, infrastructure adapters, ledger subsystem, workers, and contracts for the Govnr civic platform.

The old Rails application has been preserved as a reference implementation under `legacy/rails-reference`.

## Architecture

The core repo follows a clean architecture shape:

```text
api -> application -> domain
       infrastructure -> application/domain ports
```

- `domain`: pure civic rules, entities, value objects, policies, and domain events.
- `application`: use cases and orchestration, expressed in terms of domain objects and ports.
- `infrastructure`: adapters for databases, queues, workers, AI providers, object storage, email, auth providers, and ledger persistence.
- `api`: HTTP/API delivery layer and client-facing contracts. NestJS is the preferred framework candidate, but framework details should not leak into the domain.

## Workspace

```text
api/
  contracts/
  http/
application/
  ports/
  use-cases/
domain/
  entities/
  events/
  policies/
  value-objects/
  README.md
infrastructure/
  ai/
  auth/
  ledger/
  persistence/
  queue/
  workers/
config/
documentation/
  specifications/
  security/
legacy/
  rails-reference/
```

Deployment and operational infrastructure lives in the separate `govnr-ops` repository. The `infrastructure` directory in this repo is the clean-architecture adapter layer, not deployment infrastructure.

## Development Status

This repository is being rebuilt from the legacy Rails codebase. The first implementation milestone is to model the civic lifecycle:

```text
Group -> Membership -> Petition -> Motion -> Vote -> Ledger Record -> Verified Result -> Decision
```

