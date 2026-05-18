# Ledger

Tamper-evident voting and civic event ledger implementation.

The ledger stays inside the core repo for now, but should be treated as a hard internal boundary:

- Version event schemas.
- Keep append-only behaviour explicit.
- Produce independently verifiable proof bundles.
- Avoid coupling ledger internals to API controllers.
- Design for a possible future `govnr-ledger` split.

