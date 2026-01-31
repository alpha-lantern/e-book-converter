# **Project Codex: Next.js Renderer Specifications**

**Objective:** To build a high-performance, SEO-optimized, and responsive web interface that renders "Project Codex" JSON manifests into a premium reading experience.

## **1\. Core Rendering Architecture (App Router)**

The Renderer must strictly use the **Next.js App Router (14+)**. This allows for the use of **React Server Components (RSC)**, ensuring that the semantic content is pre-rendered on the server (or at build time) for maximum SEO.

### **1.1 The "Codex Component" Mapping**

The Renderer iterates through the structure array in the Codex JSON. It uses Server Components for static text and Client Components for interactive placeholders.

| JSON Type | React Component | Rendering Strategy | HTML Output |
| :---- | :---- | :---- | :---- |
| text (h1-h6) | \<Heading\> | Server Component | \<h1\> \- \<h6\> |
| text (p) | \<Paragraph\> | Server Component | \<p\> |
| placeholder | \<WidgetLoader\> | Client Component | \<div\> (Hydrated) |
| image | \<OptimizedImage\> | Server Component | \<next/image\> |

## **2\. Performance & SEO Requirements**

### **2.1 Lighthouse Targets**

* **SEO Score:** 100 (Leveraging Next.js generateMetadata for dynamic tags).  
* **Accessibility (A11y):** 90+ (Standardized HTML output from the semantic parser).  
* **Performance:** 90+ (Minimal client-side JS; CSS-in-JS is discouraged in favor of Tailwind).

### **2.2 Static Asset Handling**

* **Image Optimization:** Use next/image. For the PWA/Export version, ensure unoptimized: true is set in next.config.js if the target hosting doesn't support the Next.js image optimization API.  
* **Font Loading:** Use next/font/google but ensure fonts are pre-downloaded and bundled in the public/fonts directory for the **PWA Export** to ensure offline functionality.

## **3\. The Interactivity Layer (Hydration)**

* **Client Boundary:** Use the 'use client' directive only for components requiring interactivity (YouTube embeds, calculators).  
* **State Management:** Use **Zustand** for lightweight global state (e.g., current page, reader settings).  
* **Reading Progress:** Store the user's reading position in localStorage to allow for "resume reading" across sessions.

## **4\. PWA & Offline Capabilities**

The Renderer must support full offline access for the standalone .zip export.

* **PWA Plugin:** Use @ducanh2912/next-pwa for compatibility with the App Router.  
* **Service Worker:** Must be configured to cache the Codex JSON manifest and all associated assets stored in the assets object of the JSON.  
* **Metadata:** manifest.json must be dynamically generated.

## **5\. Technical Constraints for Developers**

1. **Tailwind CSS Only:** No external UI libraries (MUI, Shadcn) unless they are highly stripped down to keep the bundle small.  
2. **Typography System:** Use a prose class approach (Tailwind Typography) scaled by the BaseSize property found in the JSON metadata.  
3. **Container Queries:** Essential for the mobile-responsive flipbook view.

## **6\. Export Logic (Architectural Hook for DevOps)**

The "Export PWA" flow must be compatible with **Static Site Generation (SSG)**:

1. **Build Configuration:** next.config.js must be set to output: 'export'.  
2. **Command:** Run next build. This generates a static out/ directory.  
3. **Injection:** The DevOps script injects the specific book.json into out/data/book.json.  
4. **Standalone Portability:** The resulting out/ folder must be navigable via file:// or simple static hosting (GitHub Pages) without a Node.js server.