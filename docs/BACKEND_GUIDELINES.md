
# 1. Purpose

This document defines the engineering standards for the ClosetAI backend platform.

It applies to:

- FastAPI
- Worker Services
- Inference Gateway
- Background Jobs
- Authentication
- Storage
- Database
- Infrastructure Integrations

The purpose of this document is to ensure every backend feature follows the same architecture, coding style, security principles, and operational standards.

This document complements:

- PROJECT_SPEC.md
- ARCHITECTURE.md
- API_SPEC.md
- DATABASE.md
- CODING_STANDARDS.md

---

# 2. Technology Stack

| Component | Technology |
|------------|------------|
| Language | Python 3.13 |
| Framework | FastAPI |
| ORM | SQLAlchemy 2.x |
| Validation | Pydantic v2 |
| Database | PostgreSQL |
| Queue | Redis |
| Worker | Celery |
| Storage | AWS S3 |
| Authentication | JWT |
| Dependency Management | Poetry |
| Containerization | Docker |
| Migrations | Alembic |
| Testing | Pytest |

---

# 3. Engineering Philosophy

The backend exists to orchestrate product workflows.

The backend should:

- Be stateless.
- Scale horizontally.
- Be asynchronous.
- Remain independent from AI implementation.
- Expose stable public contracts.
- Protect user data.
- Fail safely.

Business logic should never depend directly on infrastructure.

---

# 4. Architecture

The backend follows Clean Architecture.

```

API Routes

↓

Application Services

↓

Use Cases

↓

Repositories

↓

Infrastructure

↓

External Systems

```

---

## API Routes

Responsibilities:

- Authentication
- Authorization
- Validation
- Response Mapping

Routes should never:

- Access the database directly.
- Execute business logic.
- Call AI models.
- Perform storage operations.

---

## Use Cases

Every use case performs exactly one business action.

Examples:

- LoginUser
- CreateAsset
- ConfirmUpload
- CreateTryOnJob
- CancelTryOnJob
- DeleteAccount

---

## Repositories

Repositories abstract persistence.

Repositories never:

- Call external APIs
- Perform authentication
- Know HTTP

---

## Infrastructure

Infrastructure owns:

- PostgreSQL
- Redis
- S3
- Email
- Push Notifications

No business logic belongs here.

---

# 5. Folder Structure

```

backend/

api/

routes/

schemas/

dependencies/

middleware/

application/

use_cases/

services/

repositories/

domain/

entities/

value_objects/

events/

infrastructure/

database/

storage/

queue/

logging/

config/

workers/

tests/

```

Every folder owns one responsibility.

---

# 6. API Layer

The API layer is thin.

Responsibilities:

- Parse requests
- Validate input
- Authenticate
- Call Use Case
- Return Response

Nothing else.

---

# 7. Dependency Injection

FastAPI dependency injection should only provide:

- Database Session
- Current User
- Configuration
- Logger
- Request ID

Business dependencies should be injected through constructors.

Avoid service locators.

---

# 8. Authentication

Authentication uses JWT.

Access Token:

- Short-lived

Refresh Token:

- Rotating
- Revocable

The backend is always the source of truth.

---

## Authorization

Every user-owned resource must validate ownership.

Never trust IDs supplied by clients.

---

# 9. Background Jobs

Long-running work belongs in workers.

Examples:

- AI Generation
- Cleanup
- Thumbnail Generation
- Notifications

Workers should never expose public APIs.

---

## Job Lifecycle

Queued

↓

Processing

↓

Completed

↓

Failed

↓

Cancelled

Workers own lifecycle transitions.

---

# 10. Inference Gateway

The backend never imports AI models.

Instead:

```

Backend

↓

Inference Gateway

↓

Inference Service

↓

Model Adapter

```

This abstraction allows model replacement without changing backend code.

---

# 11. Database Access

Repositories own persistence.

Rules:

- Short transactions
- Explicit commits
- Explicit rollbacks
- Optimistic concurrency where appropriate

Never keep database transactions open during external API calls.

---

# 12. Storage

Assets are stored in object storage.

The backend stores only:

- Storage Key
- Metadata
- Validation State

Never expose storage internals through public APIs.

---

# 13. Error Handling

Errors are mapped to domain errors.

```

Infrastructure Error

↓

Domain Error

↓

API Error

↓

JSON Response

```

Never expose:

- SQL errors
- Stack traces
- Storage paths
- AI implementation details

---

# 14. Logging

Use structured logging.

Every request includes:

- Request ID
- User ID (if authenticated)
- Operation
- Duration
- Status

Never log:

- Tokens
- Images
- Passwords
- Storage Keys

---

# 15. Performance

Guidelines:

- Short API requests
- Pagination
- Efficient indexes
- Background processing
- Async I/O
- Bounded retries

Never block request threads.

---

# 16. Security

Every endpoint validates:

- Authentication
- Authorization
- Input
- Ownership

Always:

- HTTPS
- Least privilege
- Secret management
- Rate limiting

---

# 17. Testing

Required tests:

- Unit
- Integration
- Contract
- Worker
- Repository

Business logic should be testable without FastAPI.

---

# 18. Observability

Every service exposes:

- Health endpoint
- Readiness endpoint
- Metrics
- Structured logs

Track:

- Latency
- Errors
- Queue depth
- Active jobs

---

# 19. Definition of Done

A backend feature is complete only when:

✓ API contract unchanged or documented

✓ Tests pass

✓ Logging added

✓ Authorization verified

✓ Performance acceptable

✓ Security reviewed

✓ Documentation updated

✓ Database migration reviewed

✓ Background jobs tested

✓ Error mapping implemented
