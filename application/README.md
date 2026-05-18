# Application

Govnr use cases and orchestration.

This layer coordinates domain behaviour through explicit use cases such as creating petitions, promoting motions, casting votes, finalising results, and generating verification bundles.

Rules:

- Depend inward on `domain`.
- Define ports for infrastructure concerns such as persistence, queues, ledger writes, AI, notifications, and auth.
- Do not depend directly on HTTP controllers or concrete provider SDKs.

