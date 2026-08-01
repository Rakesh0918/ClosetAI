# ClosetAI Coding Standards

## 1. Purpose

This document defines engineering standards for the ClosetAI codebase. It applies to the iOS app, Backend API, Inference Service, background workers, infrastructure, tests, and developer-authored documentation.

The standards exist to keep the codebase maintainable as the product grows from MVP to a production system serving millions of users. They favor Clean Architecture, SOLID design, explicit dependencies, strong boundaries, async-first workflows, structured logging, testable business logic, and security by default.

These standards are not optional preferences. New code should follow them unless an approved architectural decision records a deliberate exception.

## 2. Engineering Principles

### Product Boundaries First

Code should reflect the product and architecture boundaries defined in the approved docs: iOS, Backend API, workers, Inference Service, persistence, storage, entitlements, and observability. Features should remain isolated unless there is a clear shared domain contract.

### Clean Architecture

Core business rules should not depend on UI frameworks, web frameworks, database libraries, object storage clients, queue libraries, or AI model implementations. Outer layers may depend inward on domain abstractions; inner layers should not depend outward on infrastructure details.

### SOLID Design

Code should follow SOLID principles:

- Single Responsibility: modules and types should have one clear reason to change.
- Open/Closed: behavior should be extensible through protocols, adapters, or composition without broad rewrites.
- Liskov Substitution: protocol implementations should honor expected behavior.
- Interface Segregation: prefer focused protocols over broad service interfaces.
- Dependency Inversion: business logic depends on abstractions, not concrete infrastructure clients.

### Composition Over Inheritance

Prefer small composed types and functions over inheritance hierarchies. Inheritance should be rare and used only when required by a framework or when it is the clearest fit.

### Explicit Dependencies

Dependencies should be passed explicitly through initializers, constructors, environment objects, or dependency containers. Avoid hidden global state, implicit singletons, and service lookup that obscures behavior.

### Async by Default

Network, storage, database, queue, file, and inference workflows are asynchronous. Use async/await where available. Do not block threads waiting for asynchronous work.

### Testable Boundaries

Business logic should be testable without running the full app, web server, database, object storage, queue, or AI pipeline. Use protocols and adapters to replace external systems in tests.

## 3. Repository Organization

The repository should follow the approved architecture structure and keep deployable surfaces separated.

Expected organization:

```text
ClosetAI/
  apps/
    ios/
  backend/
    api/
    workers/
    shared/
  inference/
    service/
    models/
  infrastructure/
  docs/
  scripts/
```

Rules:

- `apps/ios` owns iOS application code, tests, assets, and StoreKit configuration.
- `backend/api` owns public API routing, authentication, authorization, entitlements, and product orchestration.
- `backend/workers` owns asynchronous job execution and lifecycle transitions.
- `backend/shared` owns stable domain contracts and intentionally shared utilities.
- `inference/service` owns inference contracts, pipeline routing, and model adapters.
- `infrastructure` owns Docker, deployment configuration, migrations, and environment definitions.
- `docs` owns approved product, architecture, API, database, and engineering standards.

Shared code must stabilize contracts. Do not place code in shared modules merely to avoid a small amount of duplication.

## 4. Naming Conventions

### General

Names should describe product concepts and responsibilities clearly. Avoid vague names such as `Manager`, `Helper`, `Util`, `Processor`, or `Data` unless the name has a precise local meaning.

Use consistent domain language:

- User
- Session
- Asset
- TryOnJob
- Result
- Entitlement
- UsageEvent
- ShareEvent
- DeletionRequest

### Swift

- Types use PascalCase.
- Properties, methods, enum cases, and local variables use camelCase.
- Protocols should describe capability or role, such as `AssetUploading` or `TryOnJobPolling`.
- Avoid `I` prefixes for protocols.
- Test doubles should be named by role, such as `MockAssetService` or `FakeTryOnJobRepository`.

### Python

- Modules, packages, functions, variables, and files use snake_case.
- Classes use PascalCase.
- Constants use UPPER_SNAKE_CASE.
- Pydantic schemas, domain entities, and service names should match API and database terminology.

### Infrastructure

- Environment names should be explicit: `local`, `staging`, `production`.
- Secret names should describe ownership and purpose without embedding secret values.
- Resource names should identify service, environment, and responsibility.

## 5. File Organization

### General

Files should be small, cohesive, and named after the primary type, feature, or responsibility they contain. Avoid large files that mix routing, validation, business logic, persistence, and external service calls.

### iOS

Organize by feature and layer. A feature may contain views, observable models, services, and local tests, but domain contracts should remain stable and reusable.

Recommended boundaries:

- Feature views.
- Observable feature models.
- Domain models.
- Client services.
- API DTOs.
- Persistence adapters.
- Test fixtures.

SwiftUI views should stay focused on rendering and user intent. Business rules belong in feature models or domain services.

### Backend

Separate API routes, request/response schemas, domain services, repositories, authorization, and infrastructure clients.

Rules:

- Route handlers should be thin.
- Domain services own business rules.
- Repositories own persistence access.
- Infrastructure adapters own external system integration.
- API schemas should not be reused as database models.

### Inference Service

Separate inference request contracts, pipeline orchestration, model adapters, quality evaluation, and artifact persistence.

Rules:

- Model-specific code stays inside adapters.
- Pipeline orchestration depends on adapter protocols.
- Public Backend API contracts must not import inference-specific types.

## 6. Dependency Injection

Dependencies should be explicit and replaceable.

Standards:

- Inject services, repositories, API clients, clocks, ID generators, loggers, and configuration.
- Prefer protocols or abstract interfaces at business boundaries.
- Avoid constructing infrastructure clients inside domain logic.
- Avoid hard-coded environment values outside configuration layers.
- Make test doubles easy to provide without runtime patching.

SwiftUI guidance:

- Use Observation for state management.
- Inject feature dependencies into observable models or feature factories.
- Avoid global mutable singletons for API clients, entitlement state, or storage coordination.

Backend guidance:

- Use dependency providers for request-scoped services where framework integration requires it.
- Keep domain services framework-independent where practical.
- Treat database sessions, current user, and request IDs as explicit dependencies.

Inference guidance:

- Inject adapter implementations through configuration or pipeline construction.
- Do not hard-code a specific AI model into worker or API logic.

## 7. Error Handling

Errors should be explicit, typed where practical, and safe to expose only through approved response formats.

General rules:

- Do not swallow errors silently.
- Do not expose raw infrastructure errors to users.
- Do not expose model names, storage keys, tokens, secrets, or internal paths in errors.
- Preserve request IDs and correlation metadata for debugging.
- Convert internal errors to stable domain errors at service boundaries.

Swift rules:

- Avoid force unwraps and forced casts.
- Use throwing functions, typed result values, or explicit state for recoverable failures.
- UI should display user-safe messages derived from API error codes or local validation errors.
- Handle unknown API errors gracefully.

Backend rules:

- Use the standard API error response contract.
- Use stable machine-readable error codes.
- Validate ownership before returning resource-specific details.
- Keep validation errors field-specific where useful.

Inference rules:

- Return structured failure codes to workers.
- Keep model-specific exceptions inside the Inference Service.
- Do not leak model stack traces outside internal logs.

## 8. Logging

ClosetAI requires structured logging across all services.

Log requirements:

- Include request ID or job ID where available.
- Include user ID only when necessary and safe for operational debugging.
- Include service name, environment, operation, and outcome.
- Use structured fields rather than unparseable string blobs.
- Do not log raw image data, access tokens, refresh tokens, StoreKit payloads, secrets, pre-signed URLs, or storage keys.
- Do not log sensitive personal information unless explicitly required and approved.

Log levels:

- Debug: local and temporary diagnostic detail.
- Info: successful lifecycle transitions and high-level operational events.
- Warning: recoverable anomalies and expected-but-unusual failures.
- Error: failed operations requiring investigation or user-visible impact.
- Critical: incidents, data integrity risk, or security-critical failure.

Each production path should emit enough context to diagnose failures without exposing sensitive data.

## 9. Concurrency

### General

Concurrency must preserve correctness under retries, app restarts, worker crashes, and partial failures.

Rules:

- Use async/await where available.
- Avoid blocking calls inside async contexts.
- Keep long-running work out of request handlers.
- Use explicit lifecycle state transitions for asynchronous workflows.
- Use idempotency keys for retryable create operations.
- Avoid shared mutable state unless protected by a clear synchronization mechanism.

### iOS

- Use Swift Concurrency for network, upload, polling, StoreKit, and local persistence workflows.
- Keep UI updates on the main actor where required.
- Make cancellation explicit for user-driven flows.
- Resume pending uploads and job polling after app relaunch or foregrounding.

### Backend

- API handlers should return quickly and enqueue expensive work.
- Use database transactions for state transitions and billing-sensitive changes.
- Do not hold database transactions while calling external systems.
- Workers must re-read durable state before acting on queued work.

### Inference

- Inference work should be isolated from API request threads.
- GPU capacity should be treated as bounded and observable.
- Retries must be bounded to control cost.

## 10. Testing

Testing is required for business logic and critical integration boundaries.

Testing standards:

- Unit tests are required for business logic.
- Unit tests should cover state transitions, authorization decisions, entitlement logic, idempotency behavior, validation rules, and error mapping.
- Integration tests should cover API contracts, persistence behavior, worker state transitions, and storage authorization flows.
- UI tests should cover critical iOS user journeys where practical.
- Contract tests should protect public API request and response schemas.
- Inference pipeline tests should validate adapter contracts without requiring every test to run full model inference.

Swift testing:

- Use the Testing framework for unit tests.
- Use XCUIAutomation for UI tests.
- Test observable models and services separately from SwiftUI rendering where possible.

Backend testing:

- Test domain services without FastAPI when possible.
- Test route behavior with API fixtures and standard error responses.
- Test authorization on every user-owned resource path.

AI service testing:

- Test adapter selection, pipeline orchestration, failure mapping, and artifact contracts.
- Use representative fixtures and lightweight doubles for routine tests.
- Reserve expensive model execution for targeted validation suites.

Test quality rules:

- Tests should be deterministic.
- Tests should avoid real external services unless explicitly marked as integration tests.
- Tests should not rely on execution order.
- Tests should not store real user images or secrets.

## 11. Code Documentation

Documentation should clarify decisions and non-obvious behavior. It should not narrate obvious code.

Required documentation:

- Public protocols and domain services with non-obvious contracts.
- Security-sensitive flows.
- State machines and valid transitions.
- Idempotency behavior.
- External integration assumptions.
- Inference adapter contracts and rollout behavior.
- Migration decisions that affect lifecycle, billing, or privacy.

Avoid:

- Comments that repeat the code.
- Stale diagrams or copied API examples not tied to source-of-truth docs.
- Documentation that exposes secrets, storage internals, or model implementation details in public-facing contexts.

## 12. Security Rules

Security is required at every layer because ClosetAI processes sensitive user images.

General rules:

- Treat the client as untrusted for authorization and entitlements.
- Validate authorization on every user-owned resource.
- Never expose storage keys, bucket names, durable storage paths, secrets, raw tokens, or model internals in public APIs.
- Store token hashes, not raw tokens.
- Use short-lived access URLs for asset upload and download.
- Validate inputs before expensive processing.
- Rate-limit authentication, upload, job creation, polling, and sharing paths.
- Keep personal data out of logs unless explicitly approved.
- Implement account deletion and data deletion behavior as first-class workflows.

Swift rules:

- Do not persist access tokens in insecure storage.
- Do not cache sensitive images beyond documented product behavior.
- Respect system privacy permissions and App Store requirements.

Backend rules:

- Enforce server-side entitlement checks for generation.
- Use standard error responses that do not reveal cross-user resource existence.
- Keep secrets in managed secret storage, not source control.

Inference rules:

- The Inference Service must not bypass Backend ownership rules for user-visible outputs.
- Model metadata must remain internal unless explicitly approved for public exposure.

Infrastructure rules:

- Use least-privilege access policies.
- Separate staging and production environments.
- Encrypt data in transit and at rest.
- Rotate credentials according to operational policy.

## 13. Git Workflow

Git history should make changes reviewable and traceable.

Rules:

- Keep commits focused on one logical change.
- Use clear commit messages that describe intent.
- Do not mix unrelated refactors with feature work.
- Do not commit secrets, credentials, raw user images, model weights, generated build artifacts, or local environment files.
- Prefer small pull requests over large, high-risk batches.
- Keep documentation changes close to the code or architecture changes they describe.

Branch naming should be concise and descriptive, using the affected area and purpose when possible.

## 14. Pull Request Standards

Every pull request should make review efficient and risk visible.

Required PR content:

- Summary of the change.
- Motivation or linked issue.
- Scope and non-scope.
- Testing performed.
- Screenshots or recordings for user-facing UI changes.
- API, database, security, or architecture impact when applicable.
- Migration or rollout notes when applicable.

Review expectations:

- Review for correctness, security, maintainability, test coverage, and product alignment.
- Verify that feature boundaries remain isolated.
- Verify that public APIs do not expose inference or storage internals.
- Verify that business logic has unit tests.
- Verify that user-visible error states are handled.

A PR should not be merged with unresolved critical review comments, failing required checks, missing tests for changed business logic, or undocumented contract changes.

## 15. Performance Standards

Performance should be designed into product-critical paths.

General standards:

- Keep API handlers short-lived.
- Move expensive work to background jobs.
- Avoid redundant network calls and duplicate uploads.
- Avoid loading large binary assets into memory unnecessarily.
- Use pagination for list endpoints.
- Use indexes aligned to documented query patterns.
- Measure before optimizing speculative paths.

SwiftUI standards:

- Keep views lightweight.
- Avoid unnecessary re-rendering from overly broad observed state.
- Perform image processing and network work off the main actor.
- Keep upload, polling, and result viewing responsive during poor network conditions.

Backend standards:

- Avoid N+1 data access patterns.
- Keep database transactions short.
- Use bounded retries.
- Protect hot polling endpoints with efficient queries and rate limits.

Inference standards:

- Track latency, throughput, failure rate, and cost per completed generation.
- Gate expensive retries.
- Preserve capacity for paid or high-priority workloads when policy requires it.

## 16. Accessibility Standards

The iOS app must be usable by people with different visual, motor, and cognitive needs.

Standards:

- Support Dynamic Type where practical.
- Provide meaningful accessibility labels for controls, images, progress states, and result actions.
- Do not rely on color alone to communicate state.
- Maintain sufficient contrast.
- Ensure touch targets are comfortably tappable.
- Make loading, queued, processing, failed, completed, saved, and deleted states understandable with assistive technologies.
- Ensure share, delete, save, and compare actions are accessible.
- Avoid motion or animation that blocks task completion.

Accessibility should be part of feature implementation, not a final cleanup pass.

## 17. AI Assisted Development Rules

AI tools may assist engineering work, but engineers remain responsible for correctness, security, and maintainability.

Rules:

- Do not paste secrets, raw user images, private keys, production logs with sensitive data, or proprietary model weights into AI tools.
- Treat AI-generated code as untrusted until reviewed and tested.
- Verify API contracts, database lifecycle rules, and security-sensitive changes against approved docs.
- Do not allow AI suggestions to introduce public exposure of model names, storage keys, tokens, or internal infrastructure details.
- Do not accept large generated abstractions unless they reduce real complexity and match the architecture.
- Prefer small, reviewable changes.
- Require tests for AI-assisted changes to business logic.
- Update documentation when AI-assisted work changes public contracts, architecture, persistence, or operational behavior.

AI assistance is acceptable for drafting tests, refactoring local code, explaining unfamiliar APIs, and generating documentation, provided the result is reviewed to the same standard as hand-written work.

## 18. Definition of Done

A change is done only when it is correct, reviewed, tested, observable, and aligned with the architecture.

Definition of Done checklist:

- The change matches `PROJECT_SPEC.md`, `ARCHITECTURE.md`, `API_SPEC.md`, and `DATABASE.md` where applicable.
- Feature boundaries are isolated and dependencies are explicit.
- Business logic has unit tests.
- API behavior has contract or integration coverage when public endpoints change.
- Database changes include migration and rollback planning when applicable.
- Security-sensitive paths validate authorization and avoid leaking sensitive details.
- Errors map to stable user-safe or developer-safe responses.
- Logs are structured and do not contain secrets or sensitive user data.
- Async workflows handle cancellation, retries, and failure states.
- User-facing changes consider accessibility.
- Performance impact is acceptable or measured.
- Documentation is updated when contracts, architecture, data lifecycle, or operational behavior changes.
- The PR summary explains testing and residual risk.

Work that merely compiles is not done. Production readiness requires maintainability, observability, security, and a clear path for review and operation.
