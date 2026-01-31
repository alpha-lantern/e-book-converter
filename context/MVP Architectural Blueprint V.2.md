# **MVP Architectural Blueprint: Project Codex**

**Version:** 1.0 (MVP)

**Architect:** Gemini SA

**Concept:** "The Book is the App" — Decoupled PDF-to-PWA Engine.

## **1\. Executive Summary**

Project Codex transforms static PDFs into high-performance, SEO-optimized Progressive Web Apps (PWAs). The architecture follows a **Decoupled Pipeline**: a Python-based Parser extracts semantic data into a "Codex JSON" manifest, which is then consumed by a React-based Renderer to provide a premium, reflowable reading experience.

## **2\. Technology Stack (Zero-Cost Focus)**

| Layer | Technology | Rationale |
| :---- | :---- | :---- |
| **Admin Editor** | Flutter (Web) | Rapid UI development for the "Widget Registry" and sidebar interaction. |
| **Parsing Engine** | Python (Standalone Script) | **DevOps Note:** Decoupled from HTTP; should be built as a CLI/Library to run in ephemeral environments (GitHub Actions or local runners) to maintain zero-cost. |
| **Reader / PWA** | Next.js (React) | Static Site Generation (SSG) for SEO scores \>90 and PWA service worker support. |
| **Database/Auth** | Supabase | Free tier PostgreSQL and Auth; stores the JSON manifests and widget metadata. |
| **Hosting** | Vercel / GitHub Pages | $0 cost for static assets; Edge CDN ensures global speed for the "eBooks." |
| **Packaging** | GitHub Actions | Automates the "Zip-to-Download" pipeline for standalone PWA distribution. |

## **3\. System Architecture & Data Flow**

### **3.1 Component Diagram**

1. **Source:** User uploads PDF via **Flutter Admin Dashboard** to Supabase Storage.  
2. **Trigger (DevOps Note):** A **Supabase Edge Function** monitors the bucket and triggers the Parser. For MVP, use a repository\_dispatch to a **GitHub Action** (Worker) to process the file for free.  
3. **Parsing:** The **Python Script** (running in the Worker) downloads the PDF, converts it to **Codex JSON**, and uploads the result back to Supabase.  
   * *Status Management:* The script must update a status field in the DB (processing \-\> success/failed) so the Flutter UI can reflect progress via real-time listeners.  
4. **Storage:** JSON manifest and extracted images are stored in **Supabase**.  
5. **Enhancement:** User uses the Editor to "Pin" interactive widgets (Video, Calculators) to JSON anchor IDs.  
6. **Distribution:**  
   * **Web View:** Next.js fetches JSON from Supabase and renders the SEO-friendly book.  
   * **PWA Export:** A script bundles the Renderer \+ JSON into a .zip for offline sales.

## **4\. The "Codex JSON" Schema (Single Source of Truth)**

This schema is the critical bridge between the static PDF and the interactive web experience.

{  
  "book\_id": "codex\_v1\_unique\_id",  
  "metadata": {  
    "title": "Strategy 2024",  
    "description": "Annual Strategic Roadmap",  
    "seo\_tags": \["strategy", "finance", "growth"\]  
  },  
  "structure": \[  
    {  
      "id": "block\_001",  
      "type": "text",  
      "semantic\_tag": "h1",  
      "content": "Executive Summary",  
      "styles": { "weight": "bold", "size": "24px", "color": "\#1A1A1A" }  
    },  
    {  
      "id": "block\_002",  
      "type": "placeholder",  
      "label": "Interaction Zone 1",  
      "widget": {  
        "type": "youtube\_embed",  
        "url": "\[https://youtube.com/watch?v=\](https://youtube.com/watch?v=)...",  
        "autoplay": false  
      }  
    }  
  \],  
  "assets": {  
    "fonts": \["\[https://fonts.gstatic.com/\](https://fonts.gstatic.com/)..."\],  
    "images": { "page\_1\_bg": "supabase\_bucket\_url/img1.webp" }  
  }  
}

## **5\. Deployment & PWA Strategy**

### **5.1 SEO Infrastructure**

* **Next.js SSG:** Each block in the JSON is mapped to a native HTML tag (\<h1\>, \<p\>, \<blockquote\>).  
* **Dynamic Meta Tags:** OpenGraph and Twitter cards are auto-generated from the metadata object.  
* **Sitemap.xml:** Automatically updated in the Supabase registry upon new publication.

### **5.2 The "Export" Pipeline**

To fulfill the goal of "Standalone Assets," the system utilizes a **Template Injection** pattern:

1. Trigger: User clicks "Export PWA."  
2. Backend pulls the latest "Renderer" build (HTML/JS/CSS).  
3. Injects the specific book's Codex JSON into the root folder.  
4. Generates a manifest.json and service-worker.js.  
5. Compresses into a .zip and serves the download link.

## **6\. Technical Risks & Mitigations**

| Risk | Impact | Mitigation |
| :---- | :---- | :---- |
| **Complex PDF Extraction** | High | Use "Anchor IDs." If text extraction fails to capture a complex layout, the system falls back to an image background with an invisible text-layer for SEO. |
| **Cloud Computing Costs** | Medium | **DevOps Strategy:** Use **GitHub Actions** as the primary runner for the Python Script. They offer 2,000 free minutes/month, which is ample for several hundred PDF conversions in an MVP. |
| **Mobile Reflow Issues** | Medium | Use **CSS Flexbox/Grid** mapping in the Renderer. Do not use absolute positioning from the PDF; use the "Reading Order" extracted by the parser. |

## **7\. Implementation Roadmap**

### **Phase 1: The Semantic Engine (Weeks 1-2)**

* Develop Python script to identify H1, H2, and Body Text based on font-metadata.  
* Output the first version of the Codex JSON.

### **Phase 2: The Core Renderer (Weeks 3-4)**

* Build the Next.js site that consumes JSON.  
* Implement "Sticky Navigation" and "Premium Typography" (Mobile-First).

### **Phase 3: The Interaction Editor (Weeks 5-6)**

* Flutter Dashboard: List documents, edit metadata, and assign URLs to JSON placeholders.

### **Phase 4: PWA & Packaging (Weeks 7-8)**

* Implement Service Worker for offline support.  
* Build the ZIP packaging logic for standalone distribution.