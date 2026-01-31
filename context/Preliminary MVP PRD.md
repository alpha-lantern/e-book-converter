# **Preliminary MVP PRD: Project Codex**

**Status:** Finalized MVP Draft

**Role:** Product Manager (Gemini PM)

**Target:** Conversion Engine for SEO-Optimized, Interactive Web-App eBooks

## **1\. Project Overview**

**Project Codex** is a "PDF-to-Web-App" translation engine. It converts static PDF designs into responsive, reflowable, and interactive HTML5 packages. These packages function as **Progressive Web Apps (PWAs)** that can be either hosted online for maximum SEO and search indexing or downloaded as standalone assets for private distribution and sales.

**Primary Business Goal:** To replace the static PDF with a "Web-Native" asset that is readable on any device, indexable by search engines, and capable of hosting interactive logic (widgets).

## **2\. Problem Statement**

Editorial designers create high-value content in tools like InDesign or Canva, but the final output (PDF) is a "digital dead-end":

1. **Invisible to SEO:** Text and structure are hard for crawlers to parse.  
2. **Poor Mobile Experience:** Requires pinch-to-zoom on small screens.  
3. **Static:** Cannot support native video, calculators, or interactive elements.  
4. **Rigid Distribution:** Publishers have no middle ground between a simple file download and an expensive custom mobile app.

## **3\. Vision & Goals**

* **Vision:** To create a new industry standard for digital editorial assets where "The Book is the App."  
* **Goal 1:** Provide 100% text reflow to ensure mobile readability.  
* **Goal 2:** Maintain high SEO fidelity (Lighthouse score \>90).  
* **Goal 3:** Enable "One-Click" packaging into a downloadable, offline-capable PWA.

## **4\. Target Audience**

* **Independent Authors & Publishers:** Who want to sell premium, interactive eBooks as downloadable apps.  
* **B2B Marketers:** Who need whitepapers to rank on Google and capture leads via interactive widgets.  
* **Editorial Designers:** Who want to offer "Digital Web Versions" of their print designs without learning code.

## **5\. Scope (The "Elastic" MVP)**

### **In-Scope**

* **Semantic Reflow Engine:** A parser that translates PDF styles (fonts/hierarchy) into a responsive CSS/HTML stack.  
* **The Widget Registry:**  
  * **Video Widget:** Support for YouTube/Vimeo embeds.  
  * **Text Editor:** Inline editing for minor typo corrections.  
  * **Anchor Point Detection:** Support for "placeholder boxes" in the PDF to indicate widget placement.  
* **Dual-Path Distribution:**  
  * **SaaS Mode:** Publicly hosted URL for SEO indexing.  
  * **PWA Export:** A .zip package containing all assets for local/private hosting.  
* **Offline Support:** Basic Service Worker implementation for offline reading.

### **Out-of-Scope**

* Visual design tools (no moving elements or changing layouts).  
* Advanced user auth/paywalls (assumed to be handled by the publisher’s storefront).  
* OCR for scanned (image-only) PDFs.

## **6\. User Stories**

| User Role | Story | Benefit |
| :---- | :---- | :---- |
| **Publisher** | As a publisher, I want to download my converted eBook as a PWA zip... | ...so I can sell it as a premium file on my own website. |
| **Marketer** | As a marketer, I want my PDF headers to be converted to \<h1\> tags... | ...so that my whitepaper appears in Google search results. |
| **Reader** | As a reader, I want to "install" the downloaded eBook to my home screen... | ...so I can read it like a native app even when I'm offline. |
| **Designer** | As a designer, I want to place a "video placeholder" box in my PDF... | ...so the Codex engine knows exactly where to embed my interview video. |

## **7\. Functional Requirements**

### **7.1. The Conversion Pipeline (The "Engine")**

* **Extraction:** Extract text strings, font metadata, and images.  
* **Reflow Logic:** Map absolute PDF positions to a logical reading order in a single-column responsive layout.  
* **Asset Optimization:** Convert all PDF images to WebP format for fast web delivery.

### **7.2. Interactive Overlay Editor**

* **Placeholder Mapping:** Detect specific hex-coded boxes or labeled objects in the PDF to serve as widget containers.  
* **Inline Editing:** Allow raw text modification within the web view to fix typos without re-uploading the PDF.

### **7.3. Distribution Engine**

* **JSON-First Architecture:** The engine must output a JSON manifest of the book's content, which the "Renderer" reads.  
* **PWA Wrapper:** The export must include a manifest, service worker, and an index.html that can run on any standard web server.

## **8\. Future Enhancements (Roadmap)**

* **Interactive Widgets:** Recipe calculators, interactive quizzes, and data charts.  
* **Direct InDesign Plugin:** Skip the PDF and export directly from the design tool.  
* **Analytics Layer:** Privacy-compliant tracking of which pages/widgets users interact with most.  
* **Pay-per-view Tokens:** Encrypted access for the downloadable PWA packages.

## **9\. Implementation Guidance for Team Roles**

### **To the Software Architect:**

* **Decouple the Parser from the Renderer.** The parser should output a "Codex JSON" schema. The Renderer should be a standalone React/Vue/Svelte component that consumes this JSON. This ensures "elasticity"—we can update the look of all books by just updating the Renderer.  
* **Focus on the JSON Schema.** Define how text blocks, styles, and widget placeholders are represented early.

### **To the UX/UI Designer:**

* **Keep the Editor Minimal.** The user isn't "designing" here; they are "enhancing." Focus on a sidebar that lists detected placeholders and allows widget assignment.  
* **The Reading Experience is the Product.** Prioritize typography, line-height, and smooth transitions in the PWA view. It must feel more like a premium app than a website.

### **To the DevOps Engineer:**

* **Zero-Cost Goal:** Use Vercel or Netlify for the editor frontend. Use serverless functions (Lambda/Vercel Functions) for the conversion process to minimize "idle" costs.  
* **Build the "Export" Pipeline.** Automate the process of bundling the Renderer and the generated JSON into a downloadable .zip.

### **To the QA Engineer:**

* **SEO Validation:** Every conversion must be tested against Lighthouse SEO audits.  
* **Cross-Browser PWA:** Test the "Install to Home Screen" flow across both iOS Safari and Android Chrome, as service worker behavior varies significantly.  
* **Reflow Accuracy:** Verify that complex PDF hierarchies (nested lists/bold text) don't break the logical reading flow in HTML.

## **10. Implementation Status (Updated Jan 31, 2026)**

### **✅ Completed**
1.  **Database Layer (Milestone 1)**
    *   **Core Schema:** `profiles`, `books`, `codex_manifests`, `widgets`, `analytics_logs` tables implemented.
    *   **Security (RLS):** Policies verified for public/private access and data isolation.
    *   **Storage:** `raw_pdfs` (Private) and `book_assets` (Public) buckets configured with folder-based RLS.
    *   **Environment:** Local development synchronized with Production (Supabase Cloud).

### **🚧 In Progress**
1.  **Semantic Parser Engine**
    *   Python text extraction (PyMuPDF).
    *   Codex JSON generation logic.

### **📅 Planned**
1.  **Frontend Dashboard (Flutter/React)**
2.  **PWA Renderer (Next.js)**

**End of Document**