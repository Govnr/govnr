# API

Delivery layer for Govnr.

This directory owns HTTP/API concerns and client-facing contracts. It may use NestJS for controllers, modules, guards, validation, dependency injection, and OpenAPI generation.

Rules:

- Translate external requests into application use cases.
- Keep civic rules out of controllers and framework services.
- Keep generated or shared client contracts under `contracts`.

