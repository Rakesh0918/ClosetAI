# ClosetAI iOS Engineering Guidelines

**Document Version:** 1.0  
**Status:** Approved  
**Owner:** Engineering  
**Last Updated:** 2026-08-06

---

# 1. Purpose

This document defines the engineering standards for the ClosetAI iOS application.

Its purpose is to ensure that every engineer builds features consistently without making architectural decisions independently.

This document is the authoritative reference for:

- SwiftUI architecture
- Navigation
- State management
- Dependency Injection
- Networking
- Authentication
- Persistence
- Design System
- Performance
- Testing
- Security

All iOS development must comply with this document together with:

- PROJECT_SPEC.md
- ARCHITECTURE.md
- API_SPEC.md
- DATABASE.md
- CODING_STANDARDS.md

---

# 2. Platform Requirements

| Item | Value |
|------|-------|
| Platform | iOS |
| Minimum Version | iOS 18 |
| Language | Swift 6 |
| UI Framework | SwiftUI |
| Architecture | MVVM + Use Cases + Repository |
| Networking | URLSession |
| Persistence | SwiftData |
| State Management | Observation |
| Authentication | Sign in with Apple |
| Payments | StoreKit 2 |
| Image Selection | PhotosPicker |
| Concurrency | Swift Concurrency |
| Dependency Management | Swift Package Manager |

UIKit should only be used when SwiftUI cannot provide the required functionality.

---

# 3. Engineering Philosophy

ClosetAI is a SwiftUI-first application.

The application should:

- Feel native to iOS.
- Follow Apple's Human Interface Guidelines.
- Prioritize readability over cleverness.
- Favor explicit dependencies.
- Minimize shared mutable state.
- Keep business logic independent of UI.
- Be testable without rendering views.

The codebase should remain maintainable for many years.

---

# 4. Architecture

The iOS application follows Clean Architecture.

```

                   SwiftUI Views
                         │
                         ▼
                  Feature ViewModel
                         │
                         ▼
                      Use Cases
                         │
                         ▼
                    Repository Layer
                         │
                         ▼
                      API Client
                         │
                         ▼
                     URLSession

```

## Responsibilities

### View

Responsible only for:

- Rendering UI
- Handling user interaction
- Displaying state

Views must never:

- Call APIs
- Parse JSON
- Store business rules
- Access persistence directly

---

### ViewModel

Responsible for:

- UI state
- User intent
- Calling Use Cases
- Mapping domain models to UI models

ViewModels must not:

- Know HTTP
- Parse responses
- Manage authentication tokens
- Access URLSession

---

### Use Cases

A Use Case represents one business action.

Examples:

- LoginUser
- UploadAsset
- CreateTryOnJob
- FetchResult
- DeleteHistoryItem

Every Use Case should perform exactly one business operation.

---

### Repository

Repositories abstract the data source.

Examples:

- AuthenticationRepository
- AssetRepository
- TryOnRepository

Repositories decide where data comes from:

- API
- Cache
- SwiftData

Views never know.

---

### API Client

Responsible only for:

- Building requests
- Sending requests
- Parsing responses
- Mapping errors

No business logic belongs here.

---

# 5. Project Structure

The iOS project should use a feature-first architecture.

```

apps/
└── ios/
└── ClosetAI/
├── App/
├── Core/
├── DesignSystem/
├── Features/
├── Shared/
├── Resources/

```

---

## App

Contains:

- App Entry
- Dependency Container
- App Environment
- App Router

---

## Core

Contains reusable infrastructure.

```

Core/

Networking/

Persistence/

Authentication/

Storage/

Logging/

Utilities/

Extensions/

```

Core must never contain feature-specific logic.

---

## DesignSystem

Contains reusable UI.

```

DesignSystem/

Colors/

Typography/

Buttons/

Cards/

Icons/

Spacing/

Animations/

Components/

```

Every feature must use the Design System.

Do not create custom buttons inside features.

---

## Features

Each feature owns itself.

```

Features/

Authentication/

Home/

Upload/

TryOn/

History/

Profile/

Settings/

Subscription/

```

Every feature contains:

```

Feature/

Views/

ViewModels/

UseCases/

Repositories/

Models/

Components/

Services/

```

---

## Shared

Contains reusable domain models.

Example:

- User
- Asset
- Result
- Entitlement

Shared should remain small.

---

# 6. State Management

ClosetAI uses Apple's Observation framework.

Never mix multiple state management approaches.

| Situation | Use |
|-----------|-----|
| Local View State | @State |
| Shared Feature State | @Observable |
| Two-way Binding | @Bindable |
| Global Dependencies | @Environment |

Avoid ObservableObject for new code.

---

## Rules

Local UI state:

- Toggle
- Sheet
- Alert

→ @State

Feature state:

- Home Screen
- Upload
- Try On

→ @Observable

Never store business logic inside @State.

---

# 7. Navigation

ClosetAI uses NavigationStack.

Navigation should be centralized.

```

NavigationStack

↓

App Router

↓

Feature Router

↓

Destination

```

Rules:

- No NavigationLink scattered across the app.
- Navigation decisions belong to routers.
- Deep linking should reuse the same navigation system.
- Navigation must be testable.

Navigation types:

| Type | API |
|------|-----|
| Push | NavigationStack |
| Sheet | .sheet |
| Full Screen | .fullScreenCover |
| Alert | .alert |
| Confirmation | .confirmationDialog |

# 8. Dependency Injection

ClosetAI uses explicit Dependency Injection throughout the application.

Dependencies should always be visible and replaceable.

Hidden dependencies make testing difficult and tightly couple features.

The application uses an application-level dependency container that constructs feature dependencies.

```
                AppContainer
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
 Authentication   TryOn        Subscription
  Container      Container      Container
        │             │             │
        ▼             ▼             ▼
   ViewModel     ViewModel     ViewModel
```

## Rules

- Views never create services.
- ViewModels never create repositories.
- Repositories never create API clients.
- Dependencies are injected through initializers.
- No global mutable singletons.
- Configuration should be injected.
- Mock implementations should be easy to substitute.

---

# 9. Design System

ClosetAI must have a single Design System shared by every feature.

The Design System guarantees consistency across the application.

Every screen must use reusable components.

Never recreate UI controls inside features.

---

## Structure

```
DesignSystem/

Colors/

Typography/

Buttons/

Cards/

Spacing/

Corners/

Icons/

Animations/

Components/

Loading/

Skeletons/
```

---

## Colors

Colors are semantic.

Never reference colors by implementation names.

Correct:

- Primary
- Secondary
- Surface
- Background
- Error
- Success
- Warning

Incorrect:

- BlueColor
- GreenButton
- DarkGray

---

## Typography

Typography should be centralized.

Define:

- Large Title
- Title
- Headline
- Body
- Caption
- Label

Avoid arbitrary font sizes.

---

## Spacing

Spacing should use predefined tokens.

Example

```
4
8
12
16
20
24
32
40
48
64
```

Avoid magic numbers.

---

## Components

Reusable components include:

- Primary Button
- Secondary Button
- Progress Button
- Async Image
- Avatar
- Card
- Loading Indicator
- Empty State
- Error View
- Navigation Header
- Premium Badge

Features should compose these components rather than creating new ones.

---

## Animations

Animations should be subtle.

Use Apple's default timing unless a feature requires a custom animation.

Avoid excessive motion.

Support Reduce Motion accessibility.

---

# 10. Networking

Networking follows the Repository pattern.

```
View

↓

ViewModel

↓

Use Case

↓

Repository

↓

API Client

↓

URLSession
```

Views must never perform networking.

---

## API Client

Responsibilities

- Build requests
- Send requests
- Decode responses
- Map errors
- Refresh authentication
- Retry safe requests

The API Client must remain generic.

Business rules belong inside repositories.

---

## Repository

Repositories decide where data originates.

Possible sources:

- API
- SwiftData
- Memory Cache

Repositories hide implementation details.

---

## Request Lifecycle

```
View

↓

ViewModel

↓

Use Case

↓

Repository

↓

API Client

↓

Backend

↓

Repository

↓

ViewModel

↓

View
```

---

## Response Models

Separate API DTOs from Domain Models.

```
DTO

↓

Mapper

↓

Domain Model

↓

UI Model
```

Never expose DTOs directly to SwiftUI.

---

## Authentication

Every authenticated request automatically attaches:

```
Bearer Token
```

Authentication refresh is automatic.

Views should never know authentication details.

---

## Retry Policy

Automatically retry only:

- Network interruption
- Temporary server failure
- Token refresh

Do not retry:

- Validation failures
- Authorization failures
- Business rule violations

---

# 11. Image Upload

Image upload is a core product feature.

The upload pipeline is standardized.

```
PhotosPicker

↓

Validation

↓

Compression

↓

Metadata

↓

Presigned Upload URL

↓

S3 Upload

↓

Backend Confirmation

↓

Asset Ready
```

---

## Validation

Validate before upload.

Check:

- Supported format
- File size
- Resolution
- Orientation

Prevent invalid uploads early.

---

## Compression

Images should be compressed before upload.

Goals

- Preserve quality
- Reduce bandwidth
- Minimize upload time

Compression should be configurable.

---

## Metadata

Extract:

- Width
- Height
- Orientation
- File size
- MIME type

before upload.

---

## Upload Progress

Uploads must expose progress.

UI should display:

- Progress
- Remaining time (optional)
- Cancel action

---

## Cancellation

Uploads must support cancellation.

Cancellation should immediately stop:

- Network
- Local processing
- Progress updates

---

## Resume

If the application returns to foreground:

Resume:

- Upload
- Polling
- Download

when possible.

---

# 12. Image Caching

Image caching improves perceived performance.

Caching layers:

```
Memory

↓

Disk

↓

Network
```

---

## Cache Policy

Cache:

- User avatar
- Result images
- History thumbnails

Do not cache:

- Authentication
- Temporary upload URLs

---

## Cache Invalidation

Invalidate when:

- Asset deleted
- Result regenerated
- User logs out

---

# 13. Local Persistence

SwiftData is the persistence framework.

Persist only product-relevant information.

Examples:

- User Profile
- Recent Results
- Upload Draft
- Preferences

Do not persist:

- Access Token
- Refresh Token
- Temporary URLs

---

## Sync Strategy

The backend remains the source of truth.

SwiftData provides:

- Offline access
- Faster startup
- Better user experience

# 14. Authentication

Authentication is managed centrally.

The application uses **Sign in with Apple** as the primary authentication provider.

The backend remains the source of truth for user identity and session validity.

```
App Launch
      │
      ▼
SessionManager
      │
      ▼
Access Token Valid?
      │
 ┌────┴────┐
 │         │
Yes       No
 │         │
 ▼         ▼
Continue  Refresh Token
             │
      ┌──────┴──────┐
      │             │
    Success       Failure
      │             │
      ▼             ▼
 Continue        Login Screen
```

---

## SessionManager

A single SessionManager owns authentication state.

Responsibilities:

- Current user
- Authentication state
- Access token lifecycle
- Refresh token lifecycle
- Logout
- Session expiration

Views never access Keychain directly.

---

## Authentication States

```
Unknown

↓

Unauthenticated

↓

Authenticating

↓

Authenticated

↓

Refreshing

↓

Expired

↓

Logged Out
```

State transitions must be explicit.

---

## Keychain

Sensitive information must be stored in Keychain.

Store:

- Access Token
- Refresh Token
- User Identifier

Never store:

- Passwords
- Session JSON
- Personal images

---

## Logout

Logout should:

- Revoke session (if supported)
- Clear Keychain
- Clear SwiftData
- Clear image cache
- Return to authentication flow

---

# 15. StoreKit 2

StoreKit 2 is used for subscriptions and purchases.

The backend is always the source of truth.

```
Purchase

↓

Apple

↓

Verification

↓

Backend

↓

Entitlement

↓

UI
```

---

## Rules

The app must never unlock premium features solely because StoreKit reports a purchase.

Always validate purchases with the backend.

---

## Subscription State

Possible states:

- Unknown
- Free
- Trial
- Active
- Expired
- Grace Period
- Billing Retry

Views observe entitlement state.

---

## Purchases

Supported purchases:

- Weekly Subscription
- Monthly Subscription
- Yearly Subscription
- Credit Packs (Future)

---

## Restore Purchases

Restore should:

- Sync with Apple
- Notify backend
- Refresh entitlement state

---

# 16. Background Tasks

ClosetAI supports long-running uploads and processing.

Background work should continue whenever iOS permits.

Supported background operations:

- Upload
- Download
- Polling
- Cache cleanup

---

## Rules

Never start AI inference on device.

Background tasks must:

- Resume safely
- Be cancellable
- Update progress

---

# 17. Notifications

Push Notifications are optional for MVP.

Architecture must support future notifications.

Possible notifications:

- Try-On Complete
- Subscription Expiring
- New Feature
- System Announcement

Notification routing should use App Router.

---

# 18. Error Handling

Errors must be predictable.

```
Backend Error

↓

Repository

↓

Domain Error

↓

ViewModel

↓

View
```

Views never inspect HTTP status codes.

---

## Error Categories

Network

Examples:

- Offline
- Timeout
- Connection Lost

Validation

Examples:

- Invalid Image
- File Too Large

Authentication

Examples:

- Session Expired
- Unauthorized

Business

Examples:

- Credits Exhausted
- Subscription Required

Unknown

Fallback category.

---

## User Messages

Users should receive actionable messages.

Bad:

```
HTTP 500
```

Good:

```
Something went wrong.

Please try again.
```

---

# 19. Loading States

Every asynchronous operation should expose loading state.

```
Idle

↓

Loading

↓

Success

↓

Failure
```

Never show blank screens.

---

## Long Operations

Try-On generation may require several seconds.

UI should display:

- Progress indicator
- Current status
- Cancel option (when applicable)

---

## Skeleton Loading

Prefer skeletons over spinners.

Use:

- Placeholder cards
- Placeholder images
- Placeholder text

Avoid blocking the interface.

---

# 20. Empty States

Every list should define an empty state.

Examples:

History

```
No Try-Ons Yet

Create your first virtual try-on.
```

Uploads

```
No uploads available.
```

Favorites

```
Nothing saved yet.
```

Empty states should encourage user action.

---

# 21. Analytics

Analytics measure product usage.

Never include sensitive data.

Track events such as:

- App Opened
- Login
- Upload Started
- Upload Completed
- Try-On Started
- Try-On Completed
- Try-On Failed
- Result Shared
- Subscription Purchased

---

## Rules

Never log:

- Images
- Tokens
- Personal information
- Payment details

Analytics should respect user privacy settings.

---

# 22. Logging

Use Apple's Logger (OSLog).

Never use:

```
print()
```

Production logs should be structured.

Every log should include when appropriate:

- Request ID
- Job ID
- User ID (only if necessary)
- Operation
- Result

---

## Log Levels

Debug

Development only.

Info

Normal application flow.

Warning

Recoverable issues.

Error

Unexpected failures.

Fault

Critical failures requiring investigation.

---

## Privacy

Logs must never contain:

- Tokens
- Images
- Email addresses
- Personal information
- Pre-signed URLs

Sensitive values should be redacted.

# 23. Performance

Performance is a product feature.

Every implementation should prioritize responsiveness, smooth animations, and efficient resource usage.

---

## Performance Goals

| Metric | Target |
|----------|---------|
| Cold Launch | < 2 seconds |
| Warm Launch | < 1 second |
| Navigation | Instant |
| Scroll FPS | 60 FPS |
| Image Upload Start | < 500 ms |
| API Response Rendering | < 200 ms after response |
| Try-On Result Display | Immediately after download |

---

## Memory Management

Guidelines:

- Avoid retaining large images in memory.
- Release temporary resources as soon as possible.
- Prefer lazy loading.
- Use pagination for large datasets.
- Cache only what improves user experience.
- Avoid unnecessary copies of image data.

---

## SwiftUI Performance

Views should remain lightweight.

Avoid:

- Large computed properties in `body`
- Expensive synchronous work
- Nested `GeometryReader`
- Deeply nested view hierarchies

Prefer:

- Small reusable components
- Lazy stacks
- Memoized derived values where appropriate
- Background processing for expensive operations

---

## Image Performance

Images are the most expensive resource in ClosetAI.

Rules:

- Compress before upload.
- Generate thumbnails for lists.
- Display progressively when possible.
- Avoid repeatedly decoding the same image.
- Use disk cache for generated results.

---

# 24. Accessibility

Accessibility is a required feature.

ClosetAI must be usable by all users.

---

## Dynamic Type

Support Dynamic Type throughout the application.

Never truncate important information because of font scaling.

---

## VoiceOver

Provide meaningful accessibility labels for:

- Buttons
- Images
- Upload progress
- Generation progress
- Result comparison
- Navigation controls

Avoid generic labels such as:

```
Button
```

Prefer:

```
Generate Try-On
```

---

## Color

Do not rely solely on color to communicate state.

Always provide icons or descriptive text.

Examples:

✅ Success

❌ Failed

⚠ Warning

---

## Touch Targets

Interactive controls should have comfortable touch areas.

Avoid tiny tappable elements.

---

## Motion

Support:

Reduce Motion

Reduce Transparency

Increase Contrast

Dynamic Type

---

## Accessibility Checklist

Every feature should verify:

- VoiceOver
- Dynamic Type
- Dark Mode
- Light Mode
- High Contrast
- Landscape (where supported)

---

# 25. Testing

Testing is mandatory for business logic.

---

## Test Pyramid

```
          UI Tests
        ------------
     Integration Tests
   ----------------------
       Unit Tests
```

Most tests should be unit tests.

---

## Unit Testing

Test:

- ViewModels
- Use Cases
- Repositories
- Mappers
- Validators

Do not unit test SwiftUI rendering.

---

## UI Testing

Critical user journeys:

- Login
- Upload
- Generate Try-On
- History
- Subscription
- Settings

---

## Snapshot Testing

Snapshot tests are recommended for:

- Design System
- Reusable Components
- Critical Screens

---

## Mocking

Never call production APIs during tests.

Use:

- Mock Repository
- Mock API Client
- Mock Storage
- Mock Authentication

---

## Continuous Integration

Every Pull Request should execute:

- Unit Tests
- UI Tests (critical flows)
- SwiftLint (future)
- Build Verification

No failing tests may be merged.

---

# 26. SwiftUI Best Practices

SwiftUI code should remain simple and declarative.

---

## Views

Views should:

- Render state
- Send user intent
- Compose reusable components

Views should never:

- Perform networking
- Parse JSON
- Access persistence
- Perform authentication
- Execute business logic

---

## ViewModels

Every screen has exactly one primary ViewModel.

Responsibilities:

- Load data
- Manage state
- Call Use Cases
- Expose UI models

---

## Components

Extract reusable UI early.

Examples:

- PrimaryButton
- AsyncImageView
- LoadingOverlay
- EmptyStateView
- ErrorCard
- PremiumBadge

Avoid duplicated UI.

---

## Modifiers

Prefer reusable ViewModifiers.

Avoid copying long modifier chains.

---

## Preview Support

Every reusable component should include previews where practical.

Use mock data.

Never call live APIs.

---

# 27. Security

Security is everyone's responsibility.

---

## Authentication

Never trust local authentication state.

The backend owns authorization.

---

## Keychain

Sensitive credentials belong only in Keychain.

Never store:

- Tokens
- Secrets
- Session cookies

inside SwiftData or UserDefaults.

---

## User Data

Never expose:

- Internal IDs
- Storage paths
- Pre-signed URLs
- Internal API details

outside approved layers.

---

## Privacy

ClosetAI processes personal images.

Requirements:

- Minimize data collection.
- Request only necessary permissions.
- Explain permission usage clearly.
- Respect App Tracking Transparency.
- Respect user deletion requests.

---

## Network

All communication must use HTTPS.

Reject insecure connections.

---

# 28. Feature Development Workflow

Every feature follows the same lifecycle.

```
Requirement

↓

Architecture

↓

UI Design

↓

Implementation

↓

Testing

↓

Review

↓

Merge
```

Never skip architecture.

---

## Before Writing Code

Verify:

- PROJECT_SPEC.md
- ARCHITECTURE.md
- API_SPEC.md
- DATABASE.md
- CODING_STANDARDS.md
- IOS_GUIDELINES.md

---

## During Development

Engineers should:

- Keep commits small.
- Keep features isolated.
- Avoid unrelated refactoring.
- Update documentation when contracts change.

---

# 29. Code Review Checklist

Every Pull Request should answer:

Architecture

☐ Does this follow MVVM?

☐ Are dependencies injected?

☐ Is business logic outside Views?

Networking

☐ Uses Repository?

☐ No direct URLSession?

State

☐ Correct Observation usage?

☐ No duplicated state?

UI

☐ Uses Design System?

☐ Supports Dark Mode?

☐ Supports Dynamic Type?

Testing

☐ Unit Tests?

☐ Mock Dependencies?

Security

☐ No secrets?

☐ Uses Keychain?

Performance

☐ No unnecessary work?

☐ Images optimized?

Accessibility

☐ VoiceOver?

☐ Labels?

Documentation

☐ Documentation updated?

---

# 30. Definition of Done

A feature is complete only when all of the following are true.

## Engineering

✓ Builds successfully

✓ Passes tests

✓ Reviewed

✓ No compiler warnings

✓ Uses Design System

✓ Follows MVVM

✓ Uses Dependency Injection

✓ Async/Await only

---

## Product

✓ Matches PROJECT_SPEC.md

✓ Matches UI requirements

✓ Handles empty states

✓ Handles loading states

✓ Handles error states

---

## Quality

✓ Accessible

✓ Secure

✓ Performant

✓ Localized where applicable

✓ Analytics implemented

✓ Logging implemented

---

## Documentation

✓ Public APIs documented

✓ Architecture unchanged or documented

✓ Screens updated

✓ README updated when needed

---

## Final Principle

Every engineer contributing to ClosetAI should be able to work on any feature with confidence because the architecture, engineering standards, and coding guidelines are consistent across the entire application.

The goal is not only to build a working application, but to build a codebase that remains maintainable, scalable, secure, and enjoyable to evolve for many years.
