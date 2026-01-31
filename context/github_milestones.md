# Proposed Project Milestones

These milestones represent the high-level phases of the E-Book Converter (Project Codex) development. Please create these in the GitHub repository UI and provide the generated numbers.

## Milestone 1: Core Engine & Data Foundation
**Description:** Initialize the data layer and the core PDF-to-Semantic-JSON conversion engine.
- **Key Tasks:** Supabase schema & RLS, Python Semantic Parser (PyMuPDF), Codex JSON manifest logic, and Calibration Tool.

## Milestone 2: Next.js Renderer (The Reader)
**Description:** Build the high-performance, SEO-optimized web reader application.
- **Key Tasks:** Next.js project setup, Component Mapping (JSON to React), SSG & SEO configuration, and PWA/Offline support.

## Milestone 3: Flutter Admin Dashboard
**Description:** Develop the management interface for book conversion and editing.
- **Key Tasks:** Conversion Hub UI, Interactive Split-View Editor, and Supabase integration (Auth/Storage).

## Milestone 4: Widget System & Enhancement Logic
**Description:** Implement interactive components and the system to manage them.
- **Key Tasks:** Widget Registry (Backend), Client-side hydration layer, and specific widget implementations (YouTube, etc.).

## Milestone 5: DevOps & Automation
**Description:** Establish automated testing and deployment pipelines.
- **Key Tasks:** GitHub Actions (Pytest, Lighthouse CI) and Automated ZIP Export Pipeline.

## Milestone 6: QA & Launch Readiness
**Description:** Final validation, performance tuning, and cross-platform testing.
- **Key Tasks:** Semantic Validation vs. Gold Standard, PWA testing, and Lighthouse audit (>90 scores).
