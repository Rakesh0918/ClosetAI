# ClosetAI Project Spec

## 1. Vision

ClosetAI is an AI-powered virtual try-on platform that helps users visualize how clothing will look on them before they buy. The product gives users a realistic, fast, and trustworthy way to see themselves wearing a garment from a product image, catalog photo, saved image, or camera capture.

The long-term vision is to become the visual decision layer for fashion commerce. Before a user purchases clothing online, they should be able to answer the most important question: "How will this look on me?" ClosetAI should reduce uncertainty, increase buying confidence, decrease returns, and make online fashion shopping feel more personal and less speculative.

The MVP is intentionally focused. ClosetAI is not starting as a wardrobe organizer, fashion social network, or full styling assistant. The first product promise is simple: upload a photo of yourself, choose a clothing image, generate a realistic AI try-on, then view, compare, save, and share the result.

## 2. Problem Statement

Online clothing purchases are high-friction because users cannot confidently visualize fit, silhouette, color, texture, and overall appearance on their own body before purchasing. Product photos usually show professional models with different body shapes, poses, lighting, and styling. Size charts and reviews help, but they do not solve the core visual uncertainty.

This uncertainty creates measurable user pain:

- Users abandon purchases because they cannot tell whether an item will suit them.
- Users buy multiple sizes or variants to compensate for uncertainty.
- Retailers absorb expensive returns caused by expectation mismatch.
- Users spend time switching between product pages, screenshots, wishlists, and mental comparisons.
- Existing try-on experiences are often limited to partner catalogs, produce unrealistic outputs, or require complex setup.

ClosetAI should make virtual try-on accessible, realistic, and repeatable from a mobile-first experience. The product must earn trust through output quality, privacy, reliability, and clear handling of user images.

## 3. Goals

- Let users generate a realistic AI try-on from one personal photo and one clothing image.
- Keep the MVP flow simple enough that a new user can complete a try-on in minutes.
- Produce outputs that preserve user identity, body structure, pose plausibility, garment characteristics, and visual coherence.
- Provide comparison tools so users can evaluate multiple garments or multiple generated outputs.
- Let users save and share try-on results while maintaining privacy controls.
- Build an architecture that can scale to millions of users, high image throughput, and GPU-backed AI workloads.
- Establish a clean separation between iOS client experience, backend orchestration, storage, billing, and AI inference.
- Design the system for App Store release, privacy review, subscription monetization, abuse prevention, and operational observability from the beginning.
- Keep future product expansions possible without turning the MVP data model into a closet-management system prematurely.

## 4. Non Goals

- ClosetAI is not a digital wardrobe management application in the MVP.
- ClosetAI is not a personal closet inventory system in the MVP.
- ClosetAI is not an AI stylist or outfit recommendation engine in the MVP.
- ClosetAI is not a marketplace, checkout system, or affiliate shopping product in the MVP.
- ClosetAI is not a retailer integration platform in the MVP.
- ClosetAI is not a social network in the MVP.
- ClosetAI is not a body scanning, sizing guarantee, or medical body measurement product.
- ClosetAI will not promise perfect fit prediction. The MVP focuses on visual try-on, not garment sizing certainty.
- ClosetAI will not support every garment category equally at launch. MVP quality should focus on a constrained set of supported clothing types.

## 5. User Personas

### Online Fashion Shopper

This user shops from mobile commerce apps, websites, screenshots, and social links. They want to know whether a garment will look good on them before buying.

Key needs:

- Fast try-on from a product image.
- Realistic output that preserves their appearance.
- Easy comparison between similar garments.
- Confidence before purchase.

### Occasion Buyer

This user is buying clothing for an event such as a wedding, vacation, interview, date, party, or formal dinner. The purchase has emotional stakes and a deadline.

Key needs:

- High-quality visual preview.
- Ability to compare multiple options.
- Save and share results for feedback.
- Clear history of generated try-ons.

### Style Explorer

This user experiments with new styles, colors, silhouettes, or trends. They may not be ready to purchase immediately but wants to explore possibilities on their own body.

Key needs:

- Low-friction generation.
- Multiple variations and comparisons.
- Saved inspiration gallery.
- Support for images from camera roll or web screenshots.

### Creator or Influencer

This user creates fashion content, outfit ideas, or shopping guides. They care about output quality, shareability, and speed.

Key needs:

- Polished generated images.
- Easy export and sharing.
- Consistent results across multiple garments.
- Clear ownership and privacy expectations.

## 6. Primary User Journey

The MVP user journey is the core product. Every major technical and product decision should support this flow.

1. User signs in with Apple.
2. User uploads or captures a photo of themselves.
3. App validates the user photo for supported pose, visibility, safety, and image quality.
4. User uploads, captures, or selects a clothing image.
5. App validates the clothing image for supported garment type, visibility, and image quality.
6. User confirms the try-on request.
7. Backend creates a try-on job and stores the source assets securely.
8. AI pipeline segments the person and garment, generates the virtual try-on, restores face/detail quality, and upscales the result when appropriate.
9. User receives job progress updates.
10. User views the generated try-on result.
11. User compares the result against source images or previous results.
12. User saves, deletes, regenerates, or shares the result.
13. Usage is metered for free limits, subscriptions, or paid credits.

The journey should feel deterministic even though AI generation is asynchronous. Users need clear states for upload, validation, queueing, processing, completion, failure, retry, and saved results.

## 7. Core Features (MVP)

### Authentication

Users sign in using Sign in with Apple. Authentication must support secure account identity, private relay email, account deletion, token validation, and future subscription entitlements.

### User Photo Capture and Upload

Users can capture a photo with the camera or choose an existing image through PhotosPicker. The app should guide users toward high-quality inputs without relying on long instructional text. Supported images should show a clearly visible person, acceptable pose, adequate lighting, and sufficient resolution.

### Clothing Image Upload and Selection

Users can upload or capture a clothing image. MVP support should focus on clearly visible single garments or product-style images. The system should reject or warn on unsupported images such as heavy occlusion, multiple dominant garments, poor resolution, or content that violates policy.

### Image Validation

The client and backend should perform validation before expensive AI work. Vision Framework can support local checks where appropriate, while backend validation remains authoritative. Validation should cover file type, size, resolution, person detection, garment visibility, content safety, and supported category constraints.

### Try-On Job Creation

The backend creates durable try-on jobs with explicit state transitions. Jobs must be idempotent where practical, recoverable after worker failure, and traceable through logs and metrics. The client should never depend on a long-lived synchronous request for generation.

### AI Try-On Generation

The Inference Service generates the try-on through model adapters for virtual try-on, segmentation, restoration, and enhancement. The initial implementation can use CatVTON, SAM2, CodeFormer, and RealESRGAN, but product logic must depend on the Inference Service contract rather than individual models.

### Progress and Status

Users can see processing status while generation runs. The MVP does not need precise percentage progress, but it must provide stable states such as queued, preparing images, generating try-on, enhancing result, complete, and failed.

### Result Viewer

Users can view the generated try-on result in a focused viewer. The viewer should support source/result comparison, zooming, saving, deletion, and sharing through native iOS share flows.

### Compare Results

Users can compare generated results against the original user photo, clothing image, and previous try-on results. MVP comparison can be simple but must support the buying decision: which garment looks better on me?

### Save and History

Users can save generated try-ons to their account. The app should maintain a history of completed generations with metadata, timestamps, source references, and billing usage. Deleting a result should remove it from the user experience and trigger backend deletion behavior according to the data retention policy.

### Share

Users can share generated results through the native iOS share sheet. Shared exports should avoid leaking internal job IDs, private metadata, or source asset URLs.

### Monetization Foundation

StoreKit 2 should support subscriptions, paid credits, or usage limits. The MVP may launch with a simple entitlement model, but the architecture must support metered AI usage and server-side entitlement validation.

### Safety, Privacy, and Account Controls

Users must be able to understand and control how their images are used. The MVP must include account deletion support, image deletion behavior, secure storage, authenticated access, and safeguards against misuse.

## 8. Future Features

Future phases should build on the try-on foundation after the MVP proves generation quality, retention, and willingness to pay.

- AI Stylist for personalized styling advice and outfit composition.
- Personal Wardrobe for saving owned clothing and reusing it in try-ons.
- Outfit Recommendations based on user preferences, event context, and saved items.
- Shopping Assistant for product comparison, purchase planning, and value guidance.
- Fashion Search for finding similar garments from images or generated looks.
- Closet Management for inventory, usage tracking, decluttering, and wardrobe planning.
- Retailer integrations for product feeds and deep links.
- Browser or share extension for importing clothing images from shopping sites.
- Multi-garment try-on for complete outfits.
- Pose and background controls.
- FLUX-based image generation or refinement when quality, latency, and cost are production-ready.
- Collaborative sharing for private feedback from friends, stylists, or partners.
- Web client for broader acquisition and cross-platform access.

## 9. Technology Stack

### iOS

- SwiftUI for declarative UI.
- Observation for app state and model observation.
- Swift Concurrency for asynchronous workflows, uploads, polling, and entitlement refresh.
- SwiftData for local persistence of drafts, cached results, user preferences, and offline-visible history.
- PhotosPicker for photo library selection.
- Vision Framework for local image checks such as person detection, saliency, and quality guidance.
- StoreKit 2 for subscriptions, purchases, transaction updates, and entitlement state.
- Sign in with Apple for authentication.

### Backend

- FastAPI for the public API service.
- PostgreSQL for canonical relational data.
- Redis for queues, rate limiting, short-lived state, and caching.
- Celery for asynchronous job orchestration.
- Docker for reproducible service packaging and deployment.
- AWS S3 for secure object storage of source images, generated outputs, and derived artifacts.

### AI

- Inference Service as the backend-owned abstraction for virtual try-on generation and image enhancement.
- CatVTON as the initial model implementation behind the Inference Service, not a client-facing or API-facing dependency.
- SAM2 for person and garment segmentation support inside the inference pipeline.
- CodeFormer for face restoration and identity-preserving enhancement where appropriate.
- RealESRGAN for result upscaling and detail enhancement.
- FLUX as a future option for generative refinement, image editing, or higher-level fashion visualization once validated for quality, safety, latency, and cost.

## 10. High Level Architecture

ClosetAI should use a service architecture that separates client interaction, API responsibilities, durable data, object storage, asynchronous orchestration, and GPU inference. The architecture must support App Store release quality from the beginning, including privacy controls, entitlement validation, observability, rate limiting, and operational recovery.

### iOS Client

The iOS app owns user interaction, local draft state, image selection, upload preparation, lightweight validation, job submission, result viewing, comparison, save/share actions, and purchase flows. The client should be responsive and resilient to app backgrounding, network interruption, and job completion after the user leaves the generation screen.

SwiftData should store local records for pending uploads, job references, cached history, and user-facing metadata. The client must treat backend state as canonical for authentication, entitlements, try-on jobs, storage URLs, and billing usage.

### API Service

FastAPI exposes authenticated endpoints for user profile, upload initiation, try-on job creation, job status, result retrieval, deletion, sharing metadata, entitlement sync, and account deletion. The API should validate ownership on every resource access and should never expose raw internal storage paths.

The API should issue pre-signed S3 upload and download URLs when appropriate, with short expirations and strict object ownership checks. Business logic should be domain-oriented: users, assets, try-on jobs, results, entitlements, and audit events.

The public API must not expose model names, pipeline internals, GPU topology, storage keys, or implementation-specific worker details. Clients submit product-level try-on requests and receive product-level job and result resources. Model selection, fallback behavior, and pipeline configuration remain backend concerns.

### API Versioning Conventions

The public API should use explicit major versioning in the URL path, starting with `/v1`. Backward-compatible additions can be introduced within the same major version. Breaking changes require a new major version such as `/v2` and a defined deprecation window for the previous version.

API contracts should follow these conventions:

- Resource-oriented paths such as `/v1/assets`, `/v1/try-on-jobs`, `/v1/results`, and `/v1/entitlements`.
- Stable request and response schemas for each API version.
- Server-generated opaque identifiers rather than semantic IDs.
- Idempotency keys for creation endpoints that may be retried by the client.
- Cursor-based pagination for list endpoints.
- ISO 8601 timestamps in UTC.
- Additive enum changes treated as possible by clients.
- API changelog maintained for every externally observable behavior change.

### Standard Error Response Format

All API errors should use a consistent JSON response shape so the iOS client can handle failures predictably without parsing free-form messages.

```json
{
  "error": {
    "code": "TRY_ON_UNSUPPORTED_GARMENT",
    "message": "This clothing image is not supported for virtual try-on.",
    "requestId": "req_01J4Z8K9M2Q7",
    "details": {
      "field": "clothingAssetId",
      "reason": "multiple_garments_detected"
    }
  }
}
```

Error conventions:

- `code` is stable, machine-readable, and documented.
- `message` is safe to show to users when appropriate.
- `requestId` links client-visible failures to backend logs and traces.
- `details` is optional and must not contain sensitive internal information.
- Validation errors should return field-level details.
- Authentication, authorization, entitlement, validation, rate limit, generation, and storage errors should use distinct code families.

### Data Store

PostgreSQL is the source of truth for users, auth identities, assets, try-on jobs, generated results, entitlement records, usage counters, safety decisions, deletion requests, and audit events. The schema should explicitly model lifecycle state rather than relying on nullable fields or implicit conventions.

Core entities should include:

- User
- AuthIdentity
- Asset
- TryOnJob
- TryOnResult
- Entitlement
- UsageLedger
- SafetyReview
- DeletionRequest
- AuditEvent

### Object Storage

AWS S3 stores original user photos, clothing images, normalized inputs, segmentation masks, intermediate artifacts when retained, and generated outputs. Objects should be encrypted, private by default, lifecycle-managed, and organized by environment, user ownership, and asset type.

The system should avoid permanent retention of unnecessary intermediate artifacts unless they are required for debugging, user-facing history, or model quality analysis with explicit policy support.

### Queue and Worker Layer

Redis and Celery coordinate asynchronous generation. Try-on jobs move through explicit states: created, assets_uploaded, validation_pending, queued, processing, enhancing, completed, failed, canceled, deleted.

Workers should be idempotent at each stage where possible. Failed jobs should record structured error codes that the product can translate into user-safe messages. Retries must be bounded to avoid runaway GPU cost.

### Inference Service

The Inference Service is the only system boundary that knows which virtual try-on model is being used. The API service and iOS client interact with try-on jobs and results, not CatVTON, SAM2, CodeFormer, RealESRGAN, FLUX, or any future model directly.

Product services should call the Inference Service with normalized input asset references, requested output profile, safety context, and job metadata. The Inference Service returns result asset references, quality signals, model version metadata, processing duration, and structured failure codes.

The initial implementation behind this abstraction can use the following pipeline:

1. Normalize and validate input images.
2. Segment person and garment with the configured segmentation adapter, initially SAM2 where needed.
3. Generate virtual try-on with the configured try-on adapter, initially CatVTON.
4. Restore facial/detail quality with the configured restoration adapter, initially CodeFormer when quality gates allow it.
5. Upscale or enhance with the configured enhancement adapter, initially RealESRGAN when useful.
6. Store outputs and quality metadata.
7. Return a stable inference result payload to the job worker.

Inference implementation rules:

- Model adapters must implement stable internal request and response contracts.
- Model names and parameters must never be required by the iOS client or public API.
- The backend can switch CatVTON to another virtual try-on model through configuration, rollout flags, or model routing without changing public API schemas.
- Result records should store model family, model version, adapter version, configuration hash, runtime, GPU type, and quality signals for debugging and regression analysis.
- Model rollout should support shadow evaluation, percentage rollout, canary cohorts, and rollback.
- The Inference Service should expose health, capacity, and model-version metadata to internal observability systems, not to end users.

### Entitlements and Billing

StoreKit 2 handles purchase UX on iOS. The backend validates transactions and maintains server-side entitlement and usage state. AI generation must be gated server-side so client manipulation cannot bypass usage limits.

The usage ledger should record generation attempts, successful outputs, failed jobs, refunds or credits, and admin adjustments. This is required for trust, support, fraud analysis, and monetization correctness.

### Observability

The system must expose structured logs, metrics, traces, and product analytics. Key operational dimensions include upload success, validation failures, queue latency, GPU processing time, generation failure rates, model versions, S3 errors, API latency, entitlement errors, and cost per completed generation.

## 11. Architecture Principles

### Product Flow First

The architecture should optimize for the primary try-on journey. Every major abstraction should map to a real product concept: asset, job, result, entitlement, usage, deletion, audit.

### Backend Canonical State

The backend is the source of truth for ownership, job lifecycle, billing usage, entitlements, and stored results. The iOS app can cache and render local state, but it must reconcile with backend state.

### Asynchronous by Default

AI generation is expensive, variable-latency work. The system must use durable job orchestration rather than synchronous request handling. Users should be able to leave and return without losing job state.

### Privacy by Design

User photos and generated images are sensitive data. Access should be private by default, storage should be encrypted, URLs should be short-lived, and deletion paths should be explicit. The system should collect only data required for the product, safety, billing, and operational reliability.

### Inference Abstraction

AI models will change. The platform must isolate model-specific behavior inside the Inference Service and model adapters so CatVTON, SAM2, CodeFormer, RealESRGAN, FLUX, or future replacements can change without client updates, public API changes, or broad backend rewrites.

### Cost-Aware Scaling

GPU inference is a major cost center. The platform should validate inputs before generation, rate-limit abuse, bound retries, track cost per job, and design for capacity management across free, paid, and high-volume users.

### Secure Multi-Tenant Design

Every API, job, asset, and object must enforce user ownership. Resource identifiers should not grant access by themselves. Authorization checks should be explicit and tested.

### Maintainable Domain Boundaries

The codebase should avoid mixing UI state, billing logic, storage concerns, and AI orchestration. Clear boundaries make the system easier to test, scale, and evolve as the product expands beyond the MVP.

### App Store Readiness

The product must be designed for App Store review, including Sign in with Apple, account deletion, subscription transparency, privacy disclosures, content handling, and clear user control over uploaded images.

## 12. Design Principles

### Trust Through Realism

The interface should set clear expectations and avoid overstating certainty. Users should understand when an image is being validated, generated, enhanced, saved, shared, or deleted. The product should prioritize believable outputs and honest failure states over theatrical AI presentation.

### Minimal Friction for First Try-On

The first successful try-on is the activation moment. The product should reduce unnecessary setup, avoid premature preference collection, and keep the flow focused on one user photo, one clothing image, and one generated result.

### Visual Comparison as Core UX

The buying decision depends on comparison. Result viewing should make it easy to compare source photo, clothing image, current result, saved results, and alternative garments without losing context.

### Privacy Visible in the Experience

Privacy should be reflected in product behavior, not only policy text. Users should have clear controls for deleting images, understanding saved history, and deciding what leaves the app through sharing.

### Progressive Disclosure

Advanced controls should not block the default flow. Validation guidance, regeneration options, sharing controls, and future styling features should appear when useful, not as mandatory setup.

### Mobile-First Performance

The app should feel responsive even though generation is asynchronous. Upload, queue, processing, and completion states should be clear, recoverable, and resilient to backgrounding or network changes.

## 13. Engineering Principles

### Explicit Domain Modeling

Core concepts should be represented directly in code and schema: user, asset, try-on job, result, entitlement, usage ledger, deletion request, safety review, and audit event. Avoid generic records that hide lifecycle and ownership rules.

### Stable Contracts Over Shared Internals

The iOS app, API service, workers, and Inference Service should communicate through versioned contracts. Internal implementation details such as model names, queue internals, storage keys, or database structure should not leak across boundaries.

### Testable Boundaries

Business logic should be testable without running the full AI stack. The API should be testable with mocked inference responses, workers should be testable with fake storage and model adapters, and the iOS app should be testable with deterministic API fixtures.

### Idempotency and Recovery

Uploads, job creation, entitlement sync, deletion, and worker stages should tolerate retries. Systems should prefer explicit state transitions and resumable workflows over hidden side effects.

### Security by Default

All user assets are private by default. Services should enforce authorization at resource boundaries, avoid long-lived public URLs, validate inputs before processing, and record security-relevant actions in audit logs.

### Observability as a Feature

Every production path should emit enough structured telemetry to debug user-visible failures, cost spikes, queue delays, model regressions, and entitlement issues. If the team cannot observe it, the system is not production-ready.

### Controlled Evolution

The architecture should support model swaps, schema migrations, API versioning, and feature rollout without coordinated client releases for backend-only changes. Feature flags and versioned contracts should be standard tools, not emergency patches.

## 14. Repository Structure

The repository should be organized around deployable surfaces and stable domain boundaries. Exact names can evolve, but the structure should keep iOS, backend, inference, infrastructure, and documentation concerns separate.

```text
ClosetAI/
  apps/
    ios/
      ClosetAIApp/
      ClosetAIAppTests/
      ClosetAIAppUITests/
  backend/
    api/
      app/
      tests/
    workers/
      app/
      tests/
    shared/
      domain/
      contracts/
      observability/
  inference/
    service/
      app/
      adapters/
      pipelines/
      tests/
    models/
      README.md
  infrastructure/
    docker/
    deployment/
    migrations/
  docs/
    PROJECT_SPEC.md
    api/
    architecture/
    security/
  scripts/
```

Repository conventions:

- `apps/ios` owns all iOS application code, tests, assets, and StoreKit configuration.
- `backend/api` owns public API routing, authentication, authorization, entitlements, and product-facing orchestration.
- `backend/workers` owns asynchronous job execution and lifecycle transitions.
- `backend/shared` owns domain types, API contracts, common validation, and cross-service utilities that are intentionally shared.
- `inference/service` owns the Inference Service, model adapters, pipeline routing, and model-specific execution.
- `inference/models` documents model setup, versioning, weights handling, licensing, and deployment requirements without committing large model weights to source control.
- `infrastructure` owns Docker, deployment configuration, database migrations, and environment-specific runtime definitions.
- `docs` remains the source of truth for product, architecture, API, security, and operational decisions.
- Cross-boundary imports should be limited and intentional. Shared code should exist only when it stabilizes contracts rather than creating tight coupling.

## 15. Success Metrics

### Activation

- Percentage of new users who complete sign-in.
- Percentage of new users who upload a valid personal photo.
- Percentage of new users who upload a valid clothing image.
- Percentage of new users who complete their first try-on.
- Median time from app install to first completed try-on.

### Generation Quality

- Try-on completion rate.
- Generation failure rate by error category.
- User save rate for completed try-ons.
- Share rate for completed try-ons.
- Regeneration rate after completed output.
- User-reported quality score.
- Refund or credit request rate related to output quality.

### Engagement

- Try-ons generated per active user per week.
- Results viewed per active user per week.
- Comparisons performed per active user per week.
- Saved results per active user.
- Repeat try-on usage within 7 and 30 days.

### Retention

- D1, D7, D30, and D90 retention.
- Percentage of users who generate another try-on after the first session.
- Percentage of paying users who consume entitlement or credit allowance.

### Monetization

- Free-to-paid conversion rate.
- Subscription conversion rate.
- Credit purchase conversion rate if credits are offered.
- Revenue per completed generation.
- Gross margin per completed generation after AI and storage costs.

### Operational Health

- API latency and error rate.
- Upload success rate.
- Queue wait time.
- GPU processing time.
- S3 read/write error rate.
- Cost per completed generation.
- Worker failure and retry rates.

## 16. MVP Scope

The MVP exists to validate one thing: users will upload themselves and a garment, wait for AI generation, and find the result useful enough to save, share, repeat, or pay for.

Included in MVP:

- iOS app released through the App Store.
- Sign in with Apple.
- User photo capture or upload.
- Clothing image capture or upload.
- Local and backend image validation.
- Secure asset upload to S3.
- Try-on job creation and status tracking.
- Inference Service-backed virtual try-on generation, with CatVTON as the initial try-on adapter.
- SAM2-assisted segmentation inside the Inference Service where required.
- CodeFormer and RealESRGAN enhancement inside the Inference Service where quality gates justify use.
- Result viewer with source/result comparison.
- Saved try-on history.
- Native sharing.
- Result deletion.
- StoreKit 2 monetization foundation.
- Server-side entitlement and usage enforcement.
- Basic analytics, logging, metrics, and failure tracking.
- Account deletion and privacy-aligned data deletion behavior.

The MVP should support a constrained set of garment categories where quality is credible. It is better to reject unsupported inputs clearly than to produce low-trust outputs.

## 17. Out of Scope

- AI Stylist.
- Personal Wardrobe.
- Outfit Recommendations.
- Shopping Assistant.
- Fashion Search.
- Closet Management.
- Social feed, followers, likes, or public profiles.
- Retailer catalog integrations.
- Checkout, affiliate links, or marketplace behavior.
- Multi-garment full outfit generation.
- Precise fit, size, or measurement guarantees.
- Android app.
- Web app.
- Browser extension.
- Real-time video try-on.
- Manual photo editing suite.
- Enterprise retailer dashboard.

## 18. Risks

### Output Quality

The product depends on visual trust. If generated images distort identity, body shape, garment details, hands, face, or pose, users will not rely on the product. MVP scope must be constrained to image types and garment categories where the pipeline can produce credible results.

### AI Latency and Cost

Virtual try-on generation is computationally expensive and may require GPU capacity planning. Long waits reduce conversion, while unbounded generation can destroy margins. The system needs queue visibility, cost tracking, rate limits, and usage-based monetization from the start.

### Privacy and User Trust

User photos are highly sensitive. Weak privacy handling, unclear retention, or accidental exposure would create severe user and business risk. Access control, encryption, deletion workflows, and clear data policies are core requirements, not later hardening tasks.

### App Store Review

The app touches subscriptions, user-generated images, AI outputs, privacy, account deletion, and Sign in with Apple. App Store rejection risk is material if flows are unclear or policy compliance is incomplete.

### Model Licensing and Commercial Use

CatVTON, SAM2, CodeFormer, RealESRGAN, FLUX, and any dependencies must be reviewed for license compatibility, commercial usage rights, attribution requirements, and deployment restrictions before production release.

### Abuse and Unsafe Content

Image upload products can be abused. The platform needs content safety checks, rate limiting, account controls, and auditability. The MVP should not defer all safety concerns to manual review.

### Scaling GPU Workloads

Millions of users imply variable traffic spikes, expensive inference queues, and complex capacity management. The architecture must support horizontal API scaling, isolated worker pools, backpressure, and graceful degradation.

### Entitlement Correctness

If client-side purchase state diverges from backend usage enforcement, users may be incorrectly charged, blocked, or granted free generations. StoreKit 2 transaction handling must be reconciled server-side.

### Data Lifecycle Complexity

Generated outputs, source images, masks, enhanced files, and intermediate artifacts have different retention needs. Without explicit lifecycle rules, storage costs and privacy risk will grow quickly.

### Future Product Drift

Future features such as wardrobe management and styling are attractive, but adding them too early would dilute the MVP. The team must protect the primary try-on journey until quality, retention, and monetization are proven.

## 19. Milestones

### Milestone 1: Product and Architecture Definition

- Finalize supported MVP garment categories and input constraints.
- Define end-to-end try-on journey and failure states.
- Define privacy, retention, deletion, and sharing requirements.
- Define domain model for users, assets, jobs, results, entitlements, usage, and audit events.
- Review AI model licenses and commercial deployment constraints.
- Define success metrics and analytics event taxonomy.

### Milestone 2: AI Pipeline Validation

- Stand up reproducible Docker environment for AI pipeline execution.
- Validate initial Inference Service try-on adapter output quality on target garment categories, with CatVTON as the first candidate implementation.
- Validate initial segmentation adapter integration, with SAM2 as the first candidate implementation.
- Validate restoration and enhancement adapter impact, with CodeFormer and RealESRGAN as first candidate implementations.
- Measure baseline latency, GPU memory, cost per generation, and failure modes.
- Define quality gates for MVP-supported inputs.

### Milestone 3: Backend Foundation

- Implement FastAPI service structure and authentication integration.
- Implement PostgreSQL schema and migrations for core domain entities.
- Implement S3 asset storage with private objects and pre-signed URL flow.
- Implement Redis and Celery job orchestration.
- Implement try-on job lifecycle and worker state transitions.
- Implement server-side entitlement and usage ledger foundation.
- Add structured logging, metrics, tracing hooks, and operational dashboards.

### Milestone 4: iOS Foundation

- Implement SwiftUI app shell with Observation-based state management.
- Implement Sign in with Apple.
- Implement PhotosPicker and camera-based source image flows.
- Implement local validation with Vision Framework where appropriate.
- Implement SwiftData persistence for drafts, job references, cached history, and user state.
- Implement authenticated API client using Swift Concurrency.

### Milestone 5: End-to-End Try-On MVP

- Connect iOS uploads to backend asset creation.
- Submit try-on jobs from the app.
- Display job status and completion states.
- Render generated results in the app.
- Support source/result comparison.
- Support save, delete, and native share flows.
- Handle failures with actionable user-safe messages.

### Milestone 6: Monetization and Policy Readiness

- Implement StoreKit 2 purchase and subscription flows.
- Implement server-side transaction validation and entitlement sync.
- Enforce generation limits on the backend.
- Implement account deletion and data deletion workflows.
- Complete privacy labels, terms, policy copy, and App Store review requirements.
- Add safety checks and abuse throttling.

### Milestone 7: Private Beta

- Release to a controlled TestFlight cohort.
- Measure first try-on completion, generation quality, latency, save/share behavior, and retention.
- Collect structured user feedback on realism, trust, and purchasing confidence.
- Tune validation thresholds, supported categories, queue behavior, and model configuration.
- Review cost per generation against monetization assumptions.

### Milestone 8: App Store MVP Launch

- Harden production infrastructure and deployment process.
- Establish incident response, monitoring, and support workflows.
- Finalize launch pricing or credit model.
- Submit App Store build and resolve review feedback.
- Launch with constrained garment support and explicit quality boundaries.
- Monitor activation, quality, retention, cost, and subscription conversion daily after release.
