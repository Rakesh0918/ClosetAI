# ClosetAI API Specification

## 1. Purpose

This document defines the public API contract for ClosetAI. It is the source of truth for how the iOS app communicates with the Backend API for authentication, users, assets, try-on jobs, results, entitlements, usage, and health.

The API is product-oriented and implementation-independent. It exposes virtual try-on resources and lifecycle state, not AI model names, queue internals, GPU details, storage keys, or inference pipeline configuration. The Backend owns orchestration and calls the Inference Service through internal contracts that are outside this public API.

## 2. API Design Principles

- Use RESTful resource design with stable nouns and predictable state transitions.
- Version all public endpoints under `/v1`.
- Treat the Backend as canonical for identity, authorization, assets, jobs, results, entitlements, usage, and deletion.
- Keep the iOS app independent of inference implementation details.
- Never expose AI model names, model parameters, GPU topology, queue names, or internal pipeline stages.
- Never expose S3 object keys, bucket names, or durable storage paths.
- Use opaque server-generated identifiers.
- Use JSON request and response bodies except for direct asset upload to authorized upload URLs.
- Use idempotency keys for retryable creation requests.
- Use standard error responses for all failures.
- Prefer explicit lifecycle state over implicit behavior.
- Design for App Store release, privacy, observability, and large-scale production usage from the start.

## 3. Authentication

The MVP uses Sign in with Apple. The iOS app obtains Apple identity credentials and exchanges them with the Backend for a ClosetAI session.

Authentication resources:

- Auth Session: Backend-issued session credentials for authenticated API access.
- Apple Identity: The Sign in with Apple identity token and authorization data provided by iOS.

Authentication requirements:

- All user-specific endpoints require an authenticated session.
- The Backend validates Apple identity tokens server-side.
- The Backend maps Apple subject identifiers to internal user records.
- The API never trusts client-provided user IDs for authorization.
- Session expiration and refresh behavior must be explicit in API responses.

## 4. Authorization

Authorization is enforced by the Backend on every resource access.

Rules:

- A user can only access their own assets, try-on jobs, results, entitlements, usage records, and deletion workflows.
- Resource IDs are opaque identifiers, not authorization grants.
- Pre-signed upload or download instructions are issued only after resource ownership checks.
- Generation requests require server-side entitlement validation.
- Deleted resources must not be returned in normal list responses unless an endpoint explicitly documents deletion history.
- Authorization failures must return standard error responses without revealing whether another user's resource exists.

## 5. Versioning

All public endpoints are versioned with a major version in the URL path.

Current version:

```text
/v1
```

Versioning policy:

- Backward-compatible additions may be added to `/v1`.
- Breaking changes require a new major version such as `/v2`.
- Clients must tolerate unknown JSON fields.
- Clients must tolerate new enum values by falling back to safe default handling.
- Deprecation windows must be documented before removing supported behavior.

## 6. Request Headers

Common request headers:

```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
X-Request-ID: req_client_generated_optional
Idempotency-Key: idem_client_generated_for_retryable_creates
```

Header rules:

- `Authorization` is required for authenticated endpoints.
- `Content-Type` is required for requests with JSON bodies.
- `Accept` should be `application/json`.
- `X-Request-ID` is optional but recommended for client correlation.
- `Idempotency-Key` is required on documented retryable creation endpoints.
- Server responses include a request identifier, either echoing `X-Request-ID` or generating one.

## 7. Response Format

Successful responses use JSON objects. Top-level response shape depends on the endpoint but should be predictable and resource-oriented.

Single-resource response:

```json
{
  "data": {
    "id": "job_01J4Z8K9M2Q7",
    "type": "try_on_job",
    "createdAt": "2026-08-01T10:30:00Z",
    "updatedAt": "2026-08-01T10:31:12Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

List response:

```json
{
  "data": [],
  "pagination": {
    "nextCursor": "cur_01J4Z8K9M2Q7",
    "hasMore": true
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Response rules:

- Timestamps use ISO 8601 UTC.
- Resource IDs are opaque strings.
- Sensitive internal metadata is excluded.
- Public responses do not include model names or S3 object keys.

## 8. Error Format

All errors use the standard error response shape.

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

Fields:

- `code`: stable machine-readable error code.
- `message`: user-safe or developer-safe explanation.
- `requestId`: request correlation identifier.
- `details`: optional structured details, never containing sensitive internal implementation data.

Error rules:

- Error responses must not expose AI model names.
- Error responses must not expose storage keys or bucket names.
- Authorization errors must not confirm ownership or existence of another user's resource.
- Validation errors should include field-level details where useful.

## 9. Idempotency

Idempotency protects retryable client operations from duplicate side effects.

Idempotency requirements:

- Required for session exchange, asset registration, try-on job creation, and purchase sync endpoints where retries can duplicate effects.
- Recommended for account deletion requests.
- The client generates a unique `Idempotency-Key` per logical operation.
- Retrying the same operation with the same key should return the original result or a compatible current representation.
- Reusing the same key with a different request body should return an idempotency conflict error.

## 10. Pagination

List endpoints use cursor-based pagination.

Query parameters:

- `limit`: optional number of resources to return.
- `cursor`: optional cursor from the previous response.

Pagination response:

```json
{
  "data": [],
  "pagination": {
    "nextCursor": null,
    "hasMore": false
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Rules:

- Default and maximum limits are endpoint-specific.
- Cursors are opaque.
- Clients must not parse cursor structure.
- List ordering must be documented per endpoint.

## 11. Rate Limiting

The API applies rate limits to protect users, infrastructure, and inference capacity.

Rate-limited operations:

- Authentication attempts.
- Asset registration.
- Asset upload confirmation.
- Try-on job creation.
- Job status polling.
- Result download URL creation.
- Share export preparation.

Rate limit response headers:

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 42
X-RateLimit-Reset: 2026-08-01T10:35:00Z
Retry-After: 30
```

Rules:

- Rate limits may vary by endpoint, entitlement, abuse signals, and operational load.
- `429 Too Many Requests` should include `Retry-After` when applicable.
- Rate limit responses use standard error format.

## 12. Resource Definitions

### Authentication Resource

Represents a user session created from Sign in with Apple credentials.

Fields:

```json
{
  "accessToken": "opaque_access_token",
  "refreshToken": "opaque_refresh_token",
  "expiresAt": "2026-08-01T11:30:00Z",
  "user": {
    "id": "usr_01J4Z8K9M2Q7",
    "type": "user"
  }
}
```

### User Resource

Represents the authenticated ClosetAI account.

Fields:

```json
{
  "id": "usr_01J4Z8K9M2Q7",
  "type": "user",
  "email": "user@example.com",
  "displayName": "Alex",
  "accountState": "active",
  "createdAt": "2026-08-01T10:30:00Z",
  "updatedAt": "2026-08-01T10:30:00Z"
}
```

Allowed `accountState` values:

- `active`
- `deletion_requested`
- `deleted`

### Asset Resource

Represents a user-owned image asset used as try-on input or generated output support.

Fields:

```json
{
  "id": "ast_01J4Z8K9M2Q7",
  "type": "asset",
  "assetKind": "user_photo",
  "state": "upload_authorized",
  "contentType": "image/jpeg",
  "fileSizeBytes": 2481024,
  "width": 1600,
  "height": 2200,
  "createdAt": "2026-08-01T10:30:00Z",
  "updatedAt": "2026-08-01T10:30:00Z"
}
```

Allowed `assetKind` values:

- `user_photo`
- `clothing_image`
- `generated_result`

Allowed `state` values:

- `registered`
- `upload_authorized`
- `uploaded`
- `validation_pending`
- `valid`
- `invalid`
- `retained`
- `deletion_requested`
- `deleted`

### Try-On Job Resource

Represents an asynchronous virtual try-on request.

Fields:

```json
{
  "id": "job_01J4Z8K9M2Q7",
  "type": "try_on_job",
  "state": "queued",
  "userPhotoAssetId": "ast_user_01J4Z8K9M2Q7",
  "clothingAssetId": "ast_cloth_01J4Z8K9M2Q7",
  "resultId": null,
  "failure": null,
  "createdAt": "2026-08-01T10:30:00Z",
  "updatedAt": "2026-08-01T10:30:10Z"
}
```

Allowed `state` values:

- `created`
- `assets_uploaded`
- `validation_pending`
- `queued`
- `processing`
- `enhancing`
- `completed`
- `failed`
- `canceled`
- `deleted`

### Result Resource

Represents a generated virtual try-on result.

Fields:

```json
{
  "id": "res_01J4Z8K9M2Q7",
  "type": "result",
  "state": "saved",
  "tryOnJobId": "job_01J4Z8K9M2Q7",
  "resultAssetId": "ast_result_01J4Z8K9M2Q7",
  "createdAt": "2026-08-01T10:32:00Z",
  "updatedAt": "2026-08-01T10:33:00Z"
}
```

Allowed `state` values:

- `generated`
- `saved`
- `shared`
- `deleted`

### Entitlement Resource

Represents the authenticated user's generation access.

Fields:

```json
{
  "id": "ent_01J4Z8K9M2Q7",
  "type": "entitlement",
  "plan": "free",
  "state": "active",
  "remainingGenerations": 3,
  "renewsAt": null,
  "updatedAt": "2026-08-01T10:30:00Z"
}
```

Allowed `plan` values:

- `free`
- `subscription`
- `credits`

Allowed `state` values:

- `active`
- `expired`
- `grace_period`
- `revoked`

### Usage Resource

Represents usage accounting for generation attempts and completed outputs.

Fields:

```json
{
  "id": "use_01J4Z8K9M2Q7",
  "type": "usage_event",
  "eventKind": "generation_completed",
  "tryOnJobId": "job_01J4Z8K9M2Q7",
  "createdAt": "2026-08-01T10:32:00Z"
}
```

Allowed `eventKind` values:

- `generation_reserved`
- `generation_completed`
- `generation_failed`
- `generation_refunded`
- `credit_adjusted`

### Health Resource

Represents public service health.

Fields:

```json
{
  "status": "ok",
  "version": "v1",
  "timestamp": "2026-08-01T10:30:00Z"
}
```

Health responses must not expose internal infrastructure topology.

## 13. Endpoint Specifications

### Authentication

#### Exchange Apple Identity for Session

Purpose: Create or refresh a ClosetAI authenticated session from Sign in with Apple credentials.

HTTP Method: `POST`

URL: `/v1/auth/apple/session`

Authentication Requirement: None.

Request Headers:

```http
Content-Type: application/json
Accept: application/json
Idempotency-Key: idem_01J4Z8K9M2Q7
```

Path Parameters: None.

Query Parameters: None.

Request Body:

```json
{
  "identityToken": "apple_identity_token",
  "authorizationCode": "apple_authorization_code",
  "fullName": {
    "givenName": "Alex",
    "familyName": "Chen"
  }
}
```

Success Response: `200 OK`

```json
{
  "data": {
    "accessToken": "opaque_access_token",
    "refreshToken": "opaque_refresh_token",
    "expiresAt": "2026-08-01T11:30:00Z",
    "user": {
      "id": "usr_01J4Z8K9M2Q7",
      "type": "user"
    }
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `400 VALIDATION_INVALID_REQUEST`
- `401 AUTH_INVALID_APPLE_CREDENTIAL`
- `409 IDEMPOTENCY_CONFLICT`
- `429 RATE_LIMIT_EXCEEDED`

Notes:

- The Backend validates Apple credentials server-side.
- The API does not accept client-selected user IDs.

#### Refresh Session

Purpose: Refresh an authenticated session.

HTTP Method: `POST`

URL: `/v1/auth/session/refresh`

Authentication Requirement: Refresh token required in request body.

Request Headers:

```http
Content-Type: application/json
Accept: application/json
```

Path Parameters: None.

Query Parameters: None.

Request Body:

```json
{
  "refreshToken": "opaque_refresh_token"
}
```

Success Response: `200 OK`

```json
{
  "data": {
    "accessToken": "opaque_access_token",
    "refreshToken": "opaque_refresh_token",
    "expiresAt": "2026-08-01T12:30:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `400 VALIDATION_INVALID_REQUEST`
- `401 AUTH_INVALID_REFRESH_TOKEN`
- `429 RATE_LIMIT_EXCEEDED`

Notes:

- Refresh tokens are opaque to the client.

#### Revoke Session

Purpose: Revoke the current authenticated session.

HTTP Method: `POST`

URL: `/v1/auth/session/revoke`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

Path Parameters: None.

Query Parameters: None.

Request Body:

```json
{}
```

Success Response: `204 No Content`

Error Responses:

- `401 AUTH_SESSION_INVALID`
- `429 RATE_LIMIT_EXCEEDED`

Notes:

- Revoking a session does not delete the account.

### Users

#### Get Current User

Purpose: Retrieve the authenticated user's account record.

HTTP Method: `GET`

URL: `/v1/users/me`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Path Parameters: None.

Query Parameters: None.

Request Body: None.

Success Response: `200 OK`

```json
{
  "data": {
    "id": "usr_01J4Z8K9M2Q7",
    "type": "user",
    "email": "user@example.com",
    "displayName": "Alex",
    "accountState": "active",
    "createdAt": "2026-08-01T10:30:00Z",
    "updatedAt": "2026-08-01T10:30:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `401 AUTH_SESSION_INVALID`
- `404 USER_NOT_FOUND`

Notes:

- Private relay email may be returned when provided by Apple.

#### Update Current User

Purpose: Update mutable profile fields for the authenticated user.

HTTP Method: `PATCH`

URL: `/v1/users/me`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

Path Parameters: None.

Query Parameters: None.

Request Body:

```json
{
  "displayName": "Alex"
}
```

Success Response: `200 OK`

```json
{
  "data": {
    "id": "usr_01J4Z8K9M2Q7",
    "type": "user",
    "email": "user@example.com",
    "displayName": "Alex",
    "accountState": "active",
    "createdAt": "2026-08-01T10:30:00Z",
    "updatedAt": "2026-08-01T10:35:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `400 VALIDATION_INVALID_REQUEST`
- `401 AUTH_SESSION_INVALID`
- `404 USER_NOT_FOUND`

Notes:

- Email is not client-editable in the MVP.

#### Request Account Deletion

Purpose: Start account deletion and associated data deletion workflows.

HTTP Method: `DELETE`

URL: `/v1/users/me`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Accept: application/json
Idempotency-Key: idem_01J4Z8K9M2Q7
```

Path Parameters: None.

Query Parameters: None.

Request Body: None.

Success Response: `202 Accepted`

```json
{
  "data": {
    "id": "del_01J4Z8K9M2Q7",
    "type": "deletion_request",
    "state": "accepted",
    "createdAt": "2026-08-01T10:30:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `401 AUTH_SESSION_INVALID`
- `409 IDEMPOTENCY_CONFLICT`
- `429 RATE_LIMIT_EXCEEDED`

Notes:

- Account deletion may be asynchronous because assets and generated results require lifecycle cleanup.

### Assets

#### Register Asset

Purpose: Create an asset record and receive authorized upload instructions.

HTTP Method: `POST`

URL: `/v1/assets`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
Idempotency-Key: idem_01J4Z8K9M2Q7
```

Path Parameters: None.

Query Parameters: None.

Request Body:

```json
{
  "assetKind": "user_photo",
  "contentType": "image/jpeg",
  "fileSizeBytes": 2481024,
  "width": 1600,
  "height": 2200,
  "checksumSha256": "9f86d081884c7d659a2feaa0c55ad015"
}
```

Success Response: `201 Created`

```json
{
  "data": {
    "asset": {
      "id": "ast_01J4Z8K9M2Q7",
      "type": "asset",
      "assetKind": "user_photo",
      "state": "upload_authorized",
      "contentType": "image/jpeg",
      "fileSizeBytes": 2481024,
      "width": 1600,
      "height": 2200,
      "createdAt": "2026-08-01T10:30:00Z",
      "updatedAt": "2026-08-01T10:30:00Z"
    },
    "upload": {
      "method": "PUT",
      "url": "https://storage-upload.example.com/presigned-upload",
      "expiresAt": "2026-08-01T10:40:00Z",
      "headers": {
        "Content-Type": "image/jpeg"
      }
    }
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `400 VALIDATION_INVALID_REQUEST`
- `401 AUTH_SESSION_INVALID`
- `409 IDEMPOTENCY_CONFLICT`
- `413 ASSET_TOO_LARGE`
- `415 ASSET_UNSUPPORTED_MEDIA_TYPE`
- `429 RATE_LIMIT_EXCEEDED`

Notes:

- Upload instructions must not expose S3 object keys.
- `assetKind` must be `user_photo` or `clothing_image` for client-created MVP inputs.

#### Confirm Asset Upload

Purpose: Confirm that a previously registered asset has been uploaded.

HTTP Method: `POST`

URL: `/v1/assets/{assetId}/upload-confirmation`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

Path Parameters:

- `assetId`: asset identifier.

Query Parameters: None.

Request Body:

```json
{
  "checksumSha256": "9f86d081884c7d659a2feaa0c55ad015"
}
```

Success Response: `200 OK`

```json
{
  "data": {
    "id": "ast_01J4Z8K9M2Q7",
    "type": "asset",
    "assetKind": "user_photo",
    "state": "uploaded",
    "contentType": "image/jpeg",
    "fileSizeBytes": 2481024,
    "width": 1600,
    "height": 2200,
    "createdAt": "2026-08-01T10:30:00Z",
    "updatedAt": "2026-08-01T10:31:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `400 VALIDATION_INVALID_REQUEST`
- `401 AUTH_SESSION_INVALID`
- `403 AUTH_RESOURCE_FORBIDDEN`
- `404 ASSET_NOT_FOUND`
- `409 ASSET_INVALID_STATE`
- `429 RATE_LIMIT_EXCEEDED`

Notes:

- Confirmation does not guarantee the asset is valid for try-on generation.
- Backend validation remains authoritative.

#### Get Asset

Purpose: Retrieve metadata for a user-owned asset.

HTTP Method: `GET`

URL: `/v1/assets/{assetId}`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Path Parameters:

- `assetId`: asset identifier.

Query Parameters: None.

Request Body: None.

Success Response: `200 OK`

```json
{
  "data": {
    "id": "ast_01J4Z8K9M2Q7",
    "type": "asset",
    "assetKind": "user_photo",
    "state": "valid",
    "contentType": "image/jpeg",
    "fileSizeBytes": 2481024,
    "width": 1600,
    "height": 2200,
    "createdAt": "2026-08-01T10:30:00Z",
    "updatedAt": "2026-08-01T10:31:30Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `401 AUTH_SESSION_INVALID`
- `403 AUTH_RESOURCE_FORBIDDEN`
- `404 ASSET_NOT_FOUND`

Notes:

- Metadata responses do not include storage keys or raw internal paths.

#### Create Asset Download URL

Purpose: Receive a short-lived authorized download URL for a user-owned asset.

HTTP Method: `POST`

URL: `/v1/assets/{assetId}/download-url`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

Path Parameters:

- `assetId`: asset identifier.

Query Parameters: None.

Request Body:

```json
{}
```

Success Response: `200 OK`

```json
{
  "data": {
    "url": "https://storage-download.example.com/presigned-download",
    "expiresAt": "2026-08-01T10:40:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `401 AUTH_SESSION_INVALID`
- `403 AUTH_RESOURCE_FORBIDDEN`
- `404 ASSET_NOT_FOUND`
- `409 ASSET_INVALID_STATE`
- `429 RATE_LIMIT_EXCEEDED`

Notes:

- The URL is short-lived and must not be stored as durable state by the client.
- The URL must not reveal S3 object keys.

#### Delete Asset

Purpose: Request deletion of a user-owned asset.

HTTP Method: `DELETE`

URL: `/v1/assets/{assetId}`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Path Parameters:

- `assetId`: asset identifier.

Query Parameters: None.

Request Body: None.

Success Response: `202 Accepted`

```json
{
  "data": {
    "id": "ast_01J4Z8K9M2Q7",
    "type": "asset",
    "state": "deletion_requested",
    "updatedAt": "2026-08-01T10:35:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `401 AUTH_SESSION_INVALID`
- `403 AUTH_RESOURCE_FORBIDDEN`
- `404 ASSET_NOT_FOUND`
- `409 ASSET_INVALID_STATE`

Notes:

- Physical deletion may complete asynchronously.

### Try-On Jobs

#### Create Try-On Job

Purpose: Create an asynchronous virtual try-on job from a valid user photo asset and clothing image asset.

HTTP Method: `POST`

URL: `/v1/try-on-jobs`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
Idempotency-Key: idem_01J4Z8K9M2Q7
```

Path Parameters: None.

Query Parameters: None.

Request Body:

```json
{
  "userPhotoAssetId": "ast_user_01J4Z8K9M2Q7",
  "clothingAssetId": "ast_cloth_01J4Z8K9M2Q7",
  "outputProfile": "standard"
}
```

Success Response: `202 Accepted`

```json
{
  "data": {
    "id": "job_01J4Z8K9M2Q7",
    "type": "try_on_job",
    "state": "queued",
    "userPhotoAssetId": "ast_user_01J4Z8K9M2Q7",
    "clothingAssetId": "ast_cloth_01J4Z8K9M2Q7",
    "resultId": null,
    "failure": null,
    "createdAt": "2026-08-01T10:30:00Z",
    "updatedAt": "2026-08-01T10:30:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `400 VALIDATION_INVALID_REQUEST`
- `401 AUTH_SESSION_INVALID`
- `402 ENTITLEMENT_REQUIRED`
- `403 AUTH_RESOURCE_FORBIDDEN`
- `404 ASSET_NOT_FOUND`
- `409 ASSET_INVALID_STATE`
- `409 IDEMPOTENCY_CONFLICT`
- `422 TRY_ON_UNSUPPORTED_INPUT`
- `429 RATE_LIMIT_EXCEEDED`

Notes:

- The API accepts product-level output profiles only.
- The request does not accept model names or model parameters.
- Generation is asynchronous.

#### Get Try-On Job

Purpose: Retrieve try-on job status and result linkage.

HTTP Method: `GET`

URL: `/v1/try-on-jobs/{jobId}`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Path Parameters:

- `jobId`: try-on job identifier.

Query Parameters: None.

Request Body: None.

Success Response: `200 OK`

```json
{
  "data": {
    "id": "job_01J4Z8K9M2Q7",
    "type": "try_on_job",
    "state": "completed",
    "userPhotoAssetId": "ast_user_01J4Z8K9M2Q7",
    "clothingAssetId": "ast_cloth_01J4Z8K9M2Q7",
    "resultId": "res_01J4Z8K9M2Q7",
    "failure": null,
    "createdAt": "2026-08-01T10:30:00Z",
    "updatedAt": "2026-08-01T10:32:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Failure state response example:

```json
{
  "data": {
    "id": "job_01J4Z8K9M2Q7",
    "type": "try_on_job",
    "state": "failed",
    "resultId": null,
    "failure": {
      "code": "TRY_ON_UNSUPPORTED_INPUT",
      "message": "This photo cannot be used for virtual try-on. Please choose a clearer image."
    },
    "createdAt": "2026-08-01T10:30:00Z",
    "updatedAt": "2026-08-01T10:32:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `401 AUTH_SESSION_INVALID`
- `403 AUTH_RESOURCE_FORBIDDEN`
- `404 TRY_ON_JOB_NOT_FOUND`
- `429 RATE_LIMIT_EXCEEDED`

Notes:

- Job state responses do not reveal model names or internal inference stages.

#### List Try-On Jobs

Purpose: List try-on jobs for the authenticated user.

HTTP Method: `GET`

URL: `/v1/try-on-jobs`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Path Parameters: None.

Query Parameters:

- `limit`: optional page size.
- `cursor`: optional pagination cursor.
- `state`: optional job state filter.

Request Body: None.

Success Response: `200 OK`

```json
{
  "data": [
    {
      "id": "job_01J4Z8K9M2Q7",
      "type": "try_on_job",
      "state": "completed",
      "resultId": "res_01J4Z8K9M2Q7",
      "createdAt": "2026-08-01T10:30:00Z",
      "updatedAt": "2026-08-01T10:32:00Z"
    }
  ],
  "pagination": {
    "nextCursor": null,
    "hasMore": false
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `400 VALIDATION_INVALID_REQUEST`
- `401 AUTH_SESSION_INVALID`
- `429 RATE_LIMIT_EXCEEDED`

Notes:

- Default ordering is newest first.

#### Cancel Try-On Job

Purpose: Request cancellation of a queued or processing try-on job when cancellation is still possible.

HTTP Method: `POST`

URL: `/v1/try-on-jobs/{jobId}/cancel`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

Path Parameters:

- `jobId`: try-on job identifier.

Query Parameters: None.

Request Body:

```json
{}
```

Success Response: `200 OK`

```json
{
  "data": {
    "id": "job_01J4Z8K9M2Q7",
    "type": "try_on_job",
    "state": "canceled",
    "updatedAt": "2026-08-01T10:31:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `401 AUTH_SESSION_INVALID`
- `403 AUTH_RESOURCE_FORBIDDEN`
- `404 TRY_ON_JOB_NOT_FOUND`
- `409 TRY_ON_JOB_INVALID_STATE`

Notes:

- Cancellation is best-effort once processing has started.

### Results

#### Get Result

Purpose: Retrieve generated result metadata.

HTTP Method: `GET`

URL: `/v1/results/{resultId}`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Path Parameters:

- `resultId`: result identifier.

Query Parameters: None.

Request Body: None.

Success Response: `200 OK`

```json
{
  "data": {
    "id": "res_01J4Z8K9M2Q7",
    "type": "result",
    "state": "generated",
    "tryOnJobId": "job_01J4Z8K9M2Q7",
    "resultAssetId": "ast_result_01J4Z8K9M2Q7",
    "createdAt": "2026-08-01T10:32:00Z",
    "updatedAt": "2026-08-01T10:32:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `401 AUTH_SESSION_INVALID`
- `403 AUTH_RESOURCE_FORBIDDEN`
- `404 RESULT_NOT_FOUND`

Notes:

- Result metadata does not include direct storage keys.

#### List Results

Purpose: List generated results for the authenticated user.

HTTP Method: `GET`

URL: `/v1/results`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Path Parameters: None.

Query Parameters:

- `limit`: optional page size.
- `cursor`: optional pagination cursor.
- `state`: optional result state filter.

Request Body: None.

Success Response: `200 OK`

```json
{
  "data": [
    {
      "id": "res_01J4Z8K9M2Q7",
      "type": "result",
      "state": "saved",
      "tryOnJobId": "job_01J4Z8K9M2Q7",
      "resultAssetId": "ast_result_01J4Z8K9M2Q7",
      "createdAt": "2026-08-01T10:32:00Z",
      "updatedAt": "2026-08-01T10:33:00Z"
    }
  ],
  "pagination": {
    "nextCursor": null,
    "hasMore": false
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `400 VALIDATION_INVALID_REQUEST`
- `401 AUTH_SESSION_INVALID`
- `429 RATE_LIMIT_EXCEEDED`

Notes:

- Default ordering is newest first.

#### Save Result

Purpose: Mark a generated result as saved in the user's history.

HTTP Method: `POST`

URL: `/v1/results/{resultId}/save`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

Path Parameters:

- `resultId`: result identifier.

Query Parameters: None.

Request Body:

```json
{}
```

Success Response: `200 OK`

```json
{
  "data": {
    "id": "res_01J4Z8K9M2Q7",
    "type": "result",
    "state": "saved",
    "tryOnJobId": "job_01J4Z8K9M2Q7",
    "resultAssetId": "ast_result_01J4Z8K9M2Q7",
    "createdAt": "2026-08-01T10:32:00Z",
    "updatedAt": "2026-08-01T10:33:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `401 AUTH_SESSION_INVALID`
- `403 AUTH_RESOURCE_FORBIDDEN`
- `404 RESULT_NOT_FOUND`
- `409 RESULT_INVALID_STATE`

Notes:

- Saving does not change the underlying generated image.

#### Create Result Download URL

Purpose: Receive a short-lived download URL for a generated result asset.

HTTP Method: `POST`

URL: `/v1/results/{resultId}/download-url`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

Path Parameters:

- `resultId`: result identifier.

Query Parameters: None.

Request Body:

```json
{}
```

Success Response: `200 OK`

```json
{
  "data": {
    "url": "https://storage-download.example.com/presigned-result-download",
    "expiresAt": "2026-08-01T10:40:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `401 AUTH_SESSION_INVALID`
- `403 AUTH_RESOURCE_FORBIDDEN`
- `404 RESULT_NOT_FOUND`
- `409 RESULT_INVALID_STATE`
- `429 RATE_LIMIT_EXCEEDED`

Notes:

- The URL is short-lived and authorized for the current user.
- The URL must not reveal S3 object keys.

#### Mark Result Shared

Purpose: Record that a user shared a result through an app-controlled share flow.

HTTP Method: `POST`

URL: `/v1/results/{resultId}/share-events`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

Path Parameters:

- `resultId`: result identifier.

Query Parameters: None.

Request Body:

```json
{
  "shareSurface": "ios_share_sheet"
}
```

Success Response: `201 Created`

```json
{
  "data": {
    "id": "shr_01J4Z8K9M2Q7",
    "type": "share_event",
    "resultId": "res_01J4Z8K9M2Q7",
    "shareSurface": "ios_share_sheet",
    "createdAt": "2026-08-01T10:34:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `400 VALIDATION_INVALID_REQUEST`
- `401 AUTH_SESSION_INVALID`
- `403 AUTH_RESOURCE_FORBIDDEN`
- `404 RESULT_NOT_FOUND`
- `409 RESULT_INVALID_STATE`

Notes:

- The API records sharing metadata; actual native sharing is performed by iOS.

#### Delete Result

Purpose: Request deletion of a generated result.

HTTP Method: `DELETE`

URL: `/v1/results/{resultId}`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Path Parameters:

- `resultId`: result identifier.

Query Parameters: None.

Request Body: None.

Success Response: `202 Accepted`

```json
{
  "data": {
    "id": "res_01J4Z8K9M2Q7",
    "type": "result",
    "state": "deleted",
    "updatedAt": "2026-08-01T10:35:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `401 AUTH_SESSION_INVALID`
- `403 AUTH_RESOURCE_FORBIDDEN`
- `404 RESULT_NOT_FOUND`
- `409 RESULT_INVALID_STATE`

Notes:

- Physical artifact deletion may complete asynchronously.

### Entitlements

#### Get Current Entitlement

Purpose: Retrieve the authenticated user's generation entitlement.

HTTP Method: `GET`

URL: `/v1/entitlements/current`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Path Parameters: None.

Query Parameters: None.

Request Body: None.

Success Response: `200 OK`

```json
{
  "data": {
    "id": "ent_01J4Z8K9M2Q7",
    "type": "entitlement",
    "plan": "free",
    "state": "active",
    "remainingGenerations": 3,
    "renewsAt": null,
    "updatedAt": "2026-08-01T10:30:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `401 AUTH_SESSION_INVALID`
- `404 ENTITLEMENT_NOT_FOUND`

Notes:

- The Backend is canonical for generation eligibility.

#### Sync StoreKit Transaction

Purpose: Submit StoreKit 2 transaction information for server-side entitlement reconciliation.

HTTP Method: `POST`

URL: `/v1/entitlements/storekit/sync`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
Idempotency-Key: idem_01J4Z8K9M2Q7
```

Path Parameters: None.

Query Parameters: None.

Request Body:

```json
{
  "signedTransactionInfo": "storekit_signed_transaction_info",
  "signedRenewalInfo": "storekit_signed_renewal_info"
}
```

Success Response: `200 OK`

```json
{
  "data": {
    "id": "ent_01J4Z8K9M2Q7",
    "type": "entitlement",
    "plan": "subscription",
    "state": "active",
    "remainingGenerations": null,
    "renewsAt": "2026-09-01T10:30:00Z",
    "updatedAt": "2026-08-01T10:35:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `400 VALIDATION_INVALID_REQUEST`
- `401 AUTH_SESSION_INVALID`
- `402 ENTITLEMENT_TRANSACTION_INVALID`
- `409 IDEMPOTENCY_CONFLICT`
- `429 RATE_LIMIT_EXCEEDED`

Notes:

- StoreKit transaction payloads are validated server-side.
- The client cannot grant itself entitlement by local purchase state alone.

### Usage

#### Get Usage Summary

Purpose: Retrieve current usage summary for the authenticated user.

HTTP Method: `GET`

URL: `/v1/usage/summary`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Path Parameters: None.

Query Parameters: None.

Request Body: None.

Success Response: `200 OK`

```json
{
  "data": {
    "type": "usage_summary",
    "periodStart": "2026-08-01T00:00:00Z",
    "periodEnd": "2026-09-01T00:00:00Z",
    "generationsReserved": 1,
    "generationsCompleted": 1,
    "generationsFailed": 0,
    "remainingGenerations": 3
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `401 AUTH_SESSION_INVALID`
- `404 USAGE_NOT_FOUND`

Notes:

- Usage summary is derived from server-side ledger state.

#### List Usage Events

Purpose: List usage ledger events for the authenticated user.

HTTP Method: `GET`

URL: `/v1/usage/events`

Authentication Requirement: Required.

Request Headers:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Path Parameters: None.

Query Parameters:

- `limit`: optional page size.
- `cursor`: optional pagination cursor.
- `eventKind`: optional usage event filter.

Request Body: None.

Success Response: `200 OK`

```json
{
  "data": [
    {
      "id": "use_01J4Z8K9M2Q7",
      "type": "usage_event",
      "eventKind": "generation_completed",
      "tryOnJobId": "job_01J4Z8K9M2Q7",
      "createdAt": "2026-08-01T10:32:00Z"
    }
  ],
  "pagination": {
    "nextCursor": null,
    "hasMore": false
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `400 VALIDATION_INVALID_REQUEST`
- `401 AUTH_SESSION_INVALID`
- `429 RATE_LIMIT_EXCEEDED`

Notes:

- Usage events are immutable accounting records.

### Health

#### Get Public Health

Purpose: Check public API availability.

HTTP Method: `GET`

URL: `/v1/health`

Authentication Requirement: None.

Request Headers:

```http
Accept: application/json
```

Path Parameters: None.

Query Parameters: None.

Request Body: None.

Success Response: `200 OK`

```json
{
  "data": {
    "status": "ok",
    "version": "v1",
    "timestamp": "2026-08-01T10:30:00Z"
  },
  "requestId": "req_01J4Z8K9M2Q7"
}
```

Error Responses:

- `503 SERVICE_UNAVAILABLE`

Notes:

- Public health must not expose database state, queue state, model state, GPU capacity, storage topology, or internal dependency names.

## 14. Polling Strategy

The MVP uses polling for try-on job status.

Polling endpoint:

```text
GET /v1/try-on-jobs/{jobId}
```

Client guidance:

- Poll immediately after job creation.
- Use a short interval while the job is `queued`, `processing`, or `enhancing`.
- Back off gradually during longer processing windows.
- Stop polling when the job reaches `completed`, `failed`, `canceled`, or `deleted`.
- Respect `429 Too Many Requests` and `Retry-After` headers.
- Resume polling when the app returns to foreground if a job is still active.

Server guidance:

- Return stable job states.
- Include `updatedAt` so clients can avoid unnecessary UI churn.
- Use standard errors for authorization, missing jobs, and rate limits.
- Do not expose internal worker or inference stage names.

## 15. Future Push Notification Strategy

Push notifications are not required for MVP completion but should be compatible with the API model.

Future strategy:

- Add device registration endpoints under `/v1/devices` or a future API version.
- Notify users when long-running jobs complete or fail.
- Never include sensitive image URLs or generated image content in notification payloads.
- Use notifications as hints to refresh job state from the API.
- Continue treating the Backend API as canonical for final job and result state.

Potential future endpoints:

- `POST /v1/devices`
- `DELETE /v1/devices/{deviceId}`
- `PATCH /v1/devices/{deviceId}`

## 16. HTTP Status Codes

Standard status code usage:

- `200 OK`: Successful read or state-changing operation returning a resource.
- `201 Created`: Resource created synchronously.
- `202 Accepted`: Request accepted for asynchronous processing.
- `204 No Content`: Successful operation with no response body.
- `400 Bad Request`: Invalid request syntax or validation failure.
- `401 Unauthorized`: Missing or invalid authentication.
- `402 Payment Required`: Entitlement or payment required for generation.
- `403 Forbidden`: Authenticated user is not authorized for the resource.
- `404 Not Found`: Resource not found or not visible to the user.
- `409 Conflict`: Invalid state transition, duplicate effect, or idempotency conflict.
- `413 Payload Too Large`: Asset exceeds allowed size.
- `415 Unsupported Media Type`: Unsupported asset content type.
- `422 Unprocessable Entity`: Valid JSON request cannot be processed for product reasons.
- `429 Too Many Requests`: Rate limit exceeded.
- `500 Internal Server Error`: Unexpected server error.
- `503 Service Unavailable`: Service temporarily unavailable.

## 17. Standard Error Codes

Authentication:

- `AUTH_MISSING_TOKEN`
- `AUTH_SESSION_INVALID`
- `AUTH_SESSION_EXPIRED`
- `AUTH_INVALID_APPLE_CREDENTIAL`
- `AUTH_INVALID_REFRESH_TOKEN`

Authorization:

- `AUTH_RESOURCE_FORBIDDEN`
- `AUTH_ACCOUNT_DELETION_PENDING`

Validation:

- `VALIDATION_INVALID_REQUEST`
- `VALIDATION_REQUIRED_FIELD_MISSING`
- `VALIDATION_INVALID_FIELD_VALUE`
- `VALIDATION_UNSUPPORTED_ENUM_VALUE`

Idempotency:

- `IDEMPOTENCY_KEY_REQUIRED`
- `IDEMPOTENCY_CONFLICT`

Assets:

- `ASSET_NOT_FOUND`
- `ASSET_INVALID_STATE`
- `ASSET_TOO_LARGE`
- `ASSET_UNSUPPORTED_MEDIA_TYPE`
- `ASSET_UPLOAD_NOT_CONFIRMED`
- `ASSET_VALIDATION_FAILED`

Try-on jobs:

- `TRY_ON_JOB_NOT_FOUND`
- `TRY_ON_JOB_INVALID_STATE`
- `TRY_ON_UNSUPPORTED_INPUT`
- `TRY_ON_UNSUPPORTED_USER_PHOTO`
- `TRY_ON_UNSUPPORTED_GARMENT`
- `TRY_ON_GENERATION_FAILED`
- `TRY_ON_CAPACITY_UNAVAILABLE`

Results:

- `RESULT_NOT_FOUND`
- `RESULT_INVALID_STATE`
- `RESULT_DOWNLOAD_UNAVAILABLE`

Entitlements:

- `ENTITLEMENT_NOT_FOUND`
- `ENTITLEMENT_REQUIRED`
- `ENTITLEMENT_LIMIT_EXCEEDED`
- `ENTITLEMENT_TRANSACTION_INVALID`
- `ENTITLEMENT_SYNC_FAILED`

Usage:

- `USAGE_NOT_FOUND`
- `USAGE_LEDGER_CONFLICT`

Rate limiting and service health:

- `RATE_LIMIT_EXCEEDED`
- `SERVICE_UNAVAILABLE`
- `INTERNAL_SERVER_ERROR`

## 18. Validation Rules

General validation:

- JSON bodies must match documented schemas.
- Unknown fields may be ignored unless an endpoint documents strict validation.
- Required fields must be present and non-null.
- IDs must be opaque server-generated identifiers.
- Timestamps must use ISO 8601 UTC when provided by the client.

Asset validation:

- Supported MVP content types: `image/jpeg`, `image/png`, and `image/heic` where platform support is available.
- Asset file size must be below the configured maximum.
- Asset dimensions must be within configured minimum and maximum bounds.
- `user_photo` assets must contain a supported visible person photo.
- `clothing_image` assets must contain a supported visible garment image.
- The Backend is authoritative even when the iOS app performs local Vision checks.

Try-on validation:

- `userPhotoAssetId` must reference a user-owned valid `user_photo` asset.
- `clothingAssetId` must reference a user-owned valid `clothing_image` asset.
- The user must have entitlement for generation.
- `outputProfile` must be a documented product-level value such as `standard`.
- Requests must not include model names or inference parameters.

Result validation:

- Results must belong to the authenticated user.
- Deleted results cannot be downloaded or shared.
- Download URLs are created only for result states that allow viewing.

## 19. API Evolution Policy

Backward-compatible changes allowed in `/v1`:

- Add optional request fields.
- Add response fields.
- Add new enum values when clients can safely handle unknown values.
- Add new endpoints.
- Add new error codes within existing error families.

Breaking changes requiring a new major version:

- Remove or rename response fields used by clients.
- Change field type or meaning.
- Require a new field on an existing request.
- Change authentication semantics.
- Change resource ownership rules.
- Change status code semantics in a way that breaks clients.

Evolution rules:

- Public contracts should evolve independently from inference implementation.
- Model swaps must not require public API changes.
- API deprecations require documentation, migration guidance, and a defined support window.
- The OpenAPI document must be updated before or alongside contract changes.

## 20. OpenAPI Guidelines

The Backend API should maintain an OpenAPI specification for all public endpoints.

Guidelines:

- OpenAPI must describe `/v1` endpoints, request bodies, response bodies, headers, path parameters, query parameters, status codes, and error schemas.
- Resource schemas should be reusable components.
- Error response schema should be a shared component used by all endpoints.
- Security schemes should document bearer authentication.
- Examples should avoid real tokens, real user data, raw storage keys, or internal infrastructure names.
- OpenAPI descriptions should document product-level behavior and avoid implementation details.
- Generated clients may be used only if they preserve the app's error handling, retry, and observability requirements.
- OpenAPI changes should be reviewed as API contract changes, not incidental backend edits.

Required component groups:

- Authentication schemas.
- User schemas.
- Asset schemas.
- Try-on job schemas.
- Result schemas.
- Entitlement schemas.
- Usage schemas.
- Health schemas.
- Standard error schema.
- Pagination schema.
- Rate limit headers.
