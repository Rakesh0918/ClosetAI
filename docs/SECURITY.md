
# ClosetAI Security Guidelines

**Document Version:** 1.0  
**Status:** Approved  
**Owner:** Engineering  
**Last Updated:** 2026-08-06

---

# 1. Purpose

This document defines the security standards for the ClosetAI platform.

It applies to:

- iOS Application
- Backend Services
- AI Inference Service
- Infrastructure
- Storage
- Authentication
- Database
- CI/CD

Security is a shared responsibility.

Every engineer is responsible for protecting user data and maintaining the integrity of the platform.

---

# 2. Security Principles

ClosetAI follows these core principles:

- Least Privilege
- Zero Trust
- Defense in Depth
- Secure by Default
- Privacy by Design
- Principle of Minimal Data Collection
- Fail Securely
- Explicit Authorization

Every component should assume that incoming data is untrusted.

---

# 3. Authentication

Authentication identifies the user.

ClosetAI supports:

- Sign in with Apple

The backend is the source of truth.

The iOS application never makes authorization decisions independently.

---

## Rules

- Access Tokens must be short-lived.
- Refresh Tokens must rotate.
- Tokens must be revocable.
- Authentication failures must not expose implementation details.

---

# 4. Authorization

Authorization determines what a user can access.

Every protected resource must verify:

- Identity
- Ownership
- Permission

Never trust resource identifiers provided by the client.

Example:

```
GET /results/{id}
```

The backend must verify that the authenticated user owns the result.

---

# 5. Token Management

Access Tokens

- Stored in Keychain
- Sent using Authorization header
- Never logged

Refresh Tokens

- Stored in Keychain
- Never exposed to SwiftUI
- Never persisted in UserDefaults

---

# 6. Secure Storage

Sensitive data belongs only in secure storage.

## Keychain

Store:

- Access Token
- Refresh Token
- User Identifier

Never store:

- Passwords
- AI Results
- Session JSON

---

## SwiftData

Store only:

- User preferences
- Cached metadata
- History metadata

Never store:

- Secrets
- Tokens
- Internal URLs

---

# 7. Network Security

All communication must use HTTPS.

Requirements:

- TLS 1.3
- Certificate validation
- ATS enabled
- Reject insecure HTTP

Future consideration:

- Certificate pinning

---

# 8. API Security

Every API request must validate:

- Authentication
- Authorization
- Input
- Ownership

Never trust:

- User IDs
- File names
- MIME types
- File sizes
- Client timestamps

Validate everything on the server.

---

# 9. Input Validation

Validate:

- Strings
- Images
- JSON
- Headers
- Query parameters
- Path parameters

Reject invalid input immediately.

---

# 10. File Upload Security

Before processing:

- Verify MIME type
- Verify image format
- Verify file size
- Verify image dimensions
- Reject corrupted files

Never trust client-provided metadata.

---

# 11. AI Security

The AI pipeline must:

- Process only validated assets
- Reject unsupported formats
- Isolate inference workers
- Prevent arbitrary file execution

Never expose:

- Model checkpoints
- GPU details
- Internal prompts
- File system paths

---

# 12. Object Storage

Use pre-signed URLs.

The backend issues temporary upload URLs.

Clients upload directly to object storage.

Never expose:

- Bucket names
- Storage keys
- Internal paths

Pre-signed URLs should expire quickly.

---

# 13. Database Security

Database access occurs only through repositories.

Rules:

- Parameterized queries
- Principle of least privilege
- Encrypted connections
- No raw SQL in business logic

Database credentials must never be hardcoded.

---

# 14. Secrets Management

Secrets include:

- JWT signing keys
- API keys
- Database passwords
- AWS credentials
- Encryption keys

Secrets must never be:

- Committed to Git
- Logged
- Hardcoded
- Shared in documentation

Use environment variables or a dedicated secret manager.

---

# 15. Logging Security

Logs must never contain:

- Access Tokens
- Refresh Tokens
- Passwords
- Images
- Email addresses
- Payment information
- Storage keys

Sensitive values should be redacted.

---

# 16. Privacy

ClosetAI processes personal photographs.

Requirements:

- Minimize collected data
- Explain permission usage
- Support account deletion
- Support data export
- Support data retention policies

Users own their uploaded content.

---

# 17. Rate Limiting

Protect endpoints against abuse.

Examples:

- Login
- Upload
- Try-On creation
- Password reset (future)

Rate limiting should be enforced server-side.

---

# 18. Monitoring

Security monitoring includes:

- Failed logins
- Excessive uploads
- Suspicious API activity
- Invalid tokens
- Repeated authorization failures

Security events should be logged separately from application logs.

---

# 19. Incident Response

If a security issue occurs:

1. Detect
2. Contain
3. Investigate
4. Mitigate
5. Recover
6. Document
7. Review

Every incident should produce a postmortem.

---

# 20. Third-Party Dependencies

Every dependency should be:

- Actively maintained
- Security reviewed
- Version pinned
- Regularly updated

Avoid unnecessary dependencies.

Prefer Apple frameworks when possible on iOS.

---

# 21. CI/CD Security

CI/CD pipelines must:

- Never expose secrets
- Validate pull requests
- Run automated tests
- Scan dependencies
- Scan containers (backend)

Only approved workflows may deploy to production.

---

# 22. Security Checklist

Before release verify:

✓ HTTPS only

✓ ATS enabled

✓ Tokens stored in Keychain

✓ No secrets in Git

✓ Input validation complete

✓ Authorization verified

✓ Logging reviewed

✓ Dependencies updated

✓ Images validated

✓ Security testing completed

---

# 23. Definition of Done

A feature is secure only when:

- Authentication is implemented correctly.
- Authorization is verified.
- Input validation is complete.
- Secrets are protected.
- Logs contain no sensitive information.
- Storage access follows least privilege.
- Documentation is updated.
- Security review passes.

---

# Guiding Principle

Security is not a feature added at the end of development.

Security is a requirement that influences every architectural decision, every API, every screen, and every deployment.

ClosetAI is committed to protecting user identity, personal images, and account data through secure engineering practices at every layer of the platform.
