# Infrastructure

Concrete adapters and runtime mechanisms for Govnr.

This layer implements application ports using PostgreSQL, queues, workers, ledger storage, AI providers, auth providers, object storage, email, and other external systems.

Rules:

- Implement ports defined by `application`.
- Keep provider-specific details out of `domain`.
- Keep ledger behaviour auditable and isolated so it can become a separate service later if needed.

