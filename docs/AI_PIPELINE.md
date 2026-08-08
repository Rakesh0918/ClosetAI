
# ClosetAI AI Pipeline

**Document Version:** 1.0  
**Status:** Approved  
**Owner:** Engineering  
**Last Updated:** 2026-08-06

---

# 1. Purpose

This document defines the AI inference pipeline for ClosetAI.

The AI pipeline is responsible for transforming a user image and a garment image into a high-quality virtual try-on result.

The pipeline must be:

- Modular
- Replaceable
- Scalable
- Observable
- Fault tolerant
- Asynchronous

This document intentionally avoids coupling the system to any specific AI model.

The backend communicates only with the Inference Service.

The backend never communicates directly with AI models.

---

# 2. Goals

The AI pipeline should:

- Generate realistic virtual try-on images.
- Preserve the user's identity.
- Preserve garment details.
- Scale horizontally.
- Support multiple AI models.
- Support future image generation features.
- Produce deterministic and reproducible outputs where possible.

---

# 3. Non Goals

The AI pipeline is not responsible for:

- User authentication
- Billing
- Subscription validation
- Image upload
- API request validation
- Database management
- Business logic

These responsibilities belong to other system components.

---

# 4. High-Level Pipeline

```
User Image
      │
Garment Image
      │
      ▼
Image Validation
      │
      ▼
Preprocessing
      │
      ▼
Segmentation
      │
      ▼
Inference Adapter
      │
      ▼
Virtual Try-On Engine
      │
      ▼
Post Processing
      │
      ▼
Quality Validation
      │
      ▼
Storage
      │
      ▼
Result Ready
```

---

# 5. Pipeline Architecture

```
FastAPI Backend
        │
        ▼
Inference Gateway
        │
        ▼
Pipeline Coordinator
        │
 ┌──────┼─────────┐
 ▼      ▼         ▼
Validation
Preprocessing
Inference
Post Processing
        │
        ▼
Storage
        │
        ▼
Result Metadata
```

Each stage owns exactly one responsibility.

---

# 6. Request Lifecycle

1. Backend creates a Try-On Job.
2. Worker receives the job.
3. Assets are downloaded securely.
4. Images are validated.
5. Images are preprocessed.
6. Segmentation is performed.
7. The Inference Adapter invokes the configured model.
8. Generated output is post-processed.
9. Result quality is validated.
10. Images are uploaded to storage.
11. Metadata is persisted.
12. Job is marked as completed.

---

# 7. Image Validation

Every uploaded image must pass validation before entering the pipeline.

Validation includes:

- Supported format
- File integrity
- Resolution
- Aspect ratio
- Orientation
- Corrupted image detection
- Maximum size
- Minimum size

Invalid assets are rejected immediately.

---

# 8. Preprocessing

Preprocessing standardizes input images.

Operations include:

- Correct orientation
- Remove EXIF metadata
- Convert to RGB
- Normalize dimensions
- Resize within supported limits
- Generate internal thumbnails
- Normalize color profile

The original upload is never modified.

---

# 9. Segmentation

Segmentation identifies important regions.

Outputs may include:

- Person Mask
- Garment Mask
- Body Mask
- Background Mask

Segmentation implementation is replaceable.

The rest of the pipeline must not depend on a specific segmentation model.

---

# 10. Inference Layer

Inference is performed through an abstraction layer.

```
Pipeline Coordinator
        │
        ▼
Inference Adapter
        │
        ▼
Current Model
```

Possible implementations:

- CatVTON
- IDM-VTON
- Future OpenAI models
- Future Apple models
- Internal models

The rest of the application never knows which implementation is active.

---

# 11. Identity Preservation

Identity preservation has higher priority than creativity.

The generated result should preserve:

- Face
- Hairstyle
- Skin tone
- Body proportions
- Pose

The objective is to visualize clothing, not generate a new person.

---

# 12. Post Processing

After inference:

```
Generated Image
      │
      ▼
Upscaling
      │
      ▼
Noise Reduction
      │
      ▼
Sharpening
      │
      ▼
Color Correction
      │
      ▼
Compression
      │
      ▼
Thumbnail Generation
```

Future versions may include:

- Watermarking
- Background enhancement
- Style enhancement

---

# 13. Quality Validation

Every generated image should pass automated quality checks.

Checks may include:

- Image dimensions
- File integrity
- Empty image detection
- Artifact detection
- Confidence thresholds
- Processing success

Invalid outputs should not be delivered to users.

---

# 14. Storage

Generated assets include:

- Original User Image
- Original Garment Image
- Generated Result
- Thumbnail
- Metadata

Original uploads are immutable.

Generated outputs are stored independently.

---

# 15. Metadata

Every generation stores metadata such as:

- Result ID
- Job ID
- User ID
- Processing duration
- Pipeline Version
- Inference Adapter Version
- Post Processing Version
- Output resolution
- File size
- Status

Model implementation details are not exposed outside the inference service.

---

# 16. Retry Strategy

Automatically retry:

- Temporary GPU failures
- Storage timeouts
- Network interruptions
- Temporary infrastructure failures

Do not retry:

- Invalid images
- User cancellation
- Validation failures
- Authorization failures

Retries should use exponential backoff.

---

# 17. Error Handling

Errors should be mapped into stable domain errors.

Examples:

| Internal Error | Public Error |
|---------------|--------------|
| Low Resolution | IMAGE_TOO_SMALL |
| Invalid Garment | GARMENT_NOT_DETECTED |
| GPU Timeout | PROCESSING_TIMEOUT |
| Unsupported Format | INVALID_IMAGE_FORMAT |

Never expose:

- CUDA errors
- PyTorch errors
- Stack traces
- File paths
- Checkpoint names

---

# 18. Performance Targets

Target processing times:

| Stage | Target |
|---------|--------|
| Validation | < 100 ms |
| Preprocessing | < 300 ms |
| Segmentation | < 2 s |
| Inference | 10–20 s (MVP) |
| Post Processing | < 2 s |
| Upload Result | < 1 s |

Performance should improve as the platform evolves.

---

# 19. Scalability

The AI pipeline must support horizontal scaling.

Guidelines:

- Stateless workers
- Distributed queues
- Independent inference nodes
- Load balancing
- Auto-scaling GPU workers
- Queue-based processing

The backend should not require changes when inference capacity increases.

---

# 20. Security

The AI service must never trust client input.

Requirements:

- Validate all images
- Reject unsupported formats
- Scan uploads before processing
- Restrict storage access
- Encrypt communication
- Use signed URLs
- Never expose internal infrastructure

---

# 21. Monitoring & Observability

The inference service should publish metrics including:

- Queue depth
- Active workers
- GPU utilization
- Success rate
- Failure rate
- Retry count
- Processing duration
- Average inference time

Logs should contain:

- Request ID
- Job ID
- Pipeline Version
- Processing duration
- Final status

No personal image data should appear in logs.

---

# 22. Pipeline Versioning

Every generated result should record:

- Pipeline Version
- Inference Adapter Version
- Post Processing Version
- Segmentation Version

This allows results to remain reproducible even after pipeline upgrades.

Example:

```
Pipeline Version: 1.0
Inference Adapter: 1.0
Post Processing: 1.0
Segmentation: 1.0
```

---

# 23. Future Evolution

The architecture should support future capabilities without redesigning the pipeline.

Possible future enhancements:

- AI Stylist
- Outfit Recommendations
- Background Generation
- Multi-Garment Try-On
- Video Try-On
- 3D Avatar Generation
- AI Fashion Assistant
- Batch Processing

The modular architecture ensures these capabilities can be introduced with minimal impact on existing systems.

---

# 24. Definition of Done

A pipeline change is complete only when:

- All stages are independently testable.
- Existing API contracts remain unchanged.
- Monitoring has been updated.
- Performance benchmarks are met.
- Security review is completed.
- Documentation is updated.
- Backward compatibility is maintained where applicable.
- No implementation details leak outside the inference service.

---

# Guiding Principle

The AI pipeline exists to provide a stable, secure, and scalable inference platform.

The rest of the ClosetAI system should depend only on the pipeline contract—not on any individual AI model or implementation.

This separation allows the platform to evolve rapidly while maintaining a consistent experience for the mobile application and backend services.
