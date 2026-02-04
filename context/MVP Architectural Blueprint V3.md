# **MVP Architectural Blueprint: Project Codex**

**Version:** 1.1 (MVP \- Astro Transition)

**Architect:** Gemini SA

**Concept:** "The Book is the App" — Decoupled PDF-to-PWA Engine.

## **1\. Executive Summary**

Project Codex transforms static PDFs into high-performance, SEO-optimized Progressive Web Apps (PWAs). The architecture follows a **Decoupled Pipeline**: a Python-based Parser extracts semantic data into a "Codex JSON" manifest, which is then consumed by an **Astro-based Renderer** to provide a premium, reflowable reading experience with zero unnecessary JavaScript.

## **2\. Technology Stack (Zero-Cost Focus)**

| Layer | Technology | Rationale |
| :---- | :---- | :---- |
| **Admin Editor** | Flutter (Web) | Rapid UI development for the "Widget Registry" and sidebar interaction. |
| **Parsing Engine** | Python (Standalone Script) | **DevOps Note:** Decoupled from HTTP; built as a CLI/Library for ephemeral environments (GitHub Actions/local). |
| **Reader / PWA** | **Astro (React for Widgets)** | **Astro Islands:** Zero-JS by default for text; React only for interactive components. |
| **Database/Auth** | Supabase | Free tier PostgreSQL and Auth; stores the JSON manifests and widget metadata. |
| **Hosting** | Vercel / GitHub Pages | $0 cost for static assets; Edge CDN ensures global speed for the "eBooks." |
| **Packaging** | GitHub Actions | Automates the "Zip-to-Download" pipeline for standalone PWA distribution. |

## **3\. System Architecture & Data Flow**

### **3.1 Component Diagram**

1. **Source:** User uploads PDF via **Flutter Admin Dashboard** to Supabase Storage.  
2. **Trigger (DevOps Note):** A **Supabase Edge Function** monitors the bucket and triggers the Parser via a repository\_dispatch to a **GitHub Action** (Worker).  
3. **Parsing:** The **Python Script** downloads the PDF, converts it to **Codex JSON**, and updates the DB status (processing \-\> success/failed).  
4. **Storage:** JSON manifest and extracted images are stored in **Supabase**.  
5. **Enhancement:** User uses the Editor to "Pin" interactive widgets (Video, Calculators) to JSON anchor IDs.  
6. **Distribution:**  
   * **Web View:** **Astro** fetches JSON from Supabase and renders the SEO-friendly book using static site generation.  
   * **PWA Export:** A script bundles the **Astro static build** \+ JSON into a .zip for offline sales.

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

* **Astro SSG:** Each block in the JSON is mapped to a native HTML tag (\<h1\>, \<p\>, \<blockquote\>) with zero client-side JS overhead.  
* **Dynamic Meta Tags:** Managed via Astro's standard metadata patterns.  
* **Sitemap.xml:** Automatically updated in the registry upon publication.

### **5.2 The "Export" Pipeline**

1. Trigger: User clicks "Export PWA."  
2. Backend pulls the latest **Astro static build** (Pure HTML/JS/CSS).  
3. Injects the specific book's Codex JSON into the dist/data folder.  
4. Generates a manifest.json and service worker via @vite-pwa/astro.  
5. Compresses into a .zip for the user.

## **6\. Technical Risks & Mitigations**

* **Complex PDF Extraction:** Fallback to image background with invisible text-layer.  
* **Cloud Computing Costs:** Use GitHub Actions as primary runners (2,000 free mins/mo).  
* **Mobile Reflow Issues:** Use CSS Flexbox/Grid mapping in the Astro components; avoid absolute positioning.

## **7\. Implementation Roadmap**

* **Phase 1: The Semantic Engine (Weeks 1-2):** Python script for Codex JSON output.  
* **Phase 2: The Core Renderer (Weeks 3-4):** Build the **Astro** site with React-based widget support.  
* **Phase 3: The Interaction Editor (Weeks 5-6):** Flutter Dashboard for widget tagging.  
* **Phase 4: PWA & Packaging (Weeks 7-8):** Offline support and ZIP packaging logic.