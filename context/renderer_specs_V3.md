# **Project Codex: Astro Renderer Specifications**

**Objective:** To build an ultra-lightweight, SEO-perfect, and "Zero-JS by default" web interface that transforms Codex JSON manifests into a premium reading experience using the Astro Islands architecture.

## **1\. Core Rendering Architecture (Astro Islands)**

The Renderer utilizes **Astro (4.x+)** to achieve maximum performance. The "Reading Experience" is rendered as static HTML, with JavaScript only "hydrated" for specific interactive widgets.

### **1.1 The "Codex Island" Mapping**

The Renderer iterates through the structure array in the Codex JSON. Unlike Next.js, Astro ships zero JavaScript for text blocks.

| JSON Type | Astro Component | Hydration Strategy | Output |
| :---- | :---- | :---- | :---- |
| text (h1-h6) | Heading.astro | **None** (Static) | \<h1\> \- \<h6\> |
| text (p) | Paragraph.astro | **None** (Static) | \<p\> |
| placeholder | Widget.jsx (React) | client:visible | \<div\> \+ Hydrated JS |
| image | Image.astro | **None** (Static) | Optimized \<img\> |

## **2\. Performance & SEO Requirements**

### **2.1 Lighthouse Targets**

* **SEO Score:** 100 (Astro provides native metadata support via standard HTML tags).  
* **First Contentful Paint (FCP):** \< 0.8s (due to zero-JS for the initial text render).  
* **Accessibility:** 90+ (Standard semantic output).

### **2.2 Static Asset Handling**

* **Image Optimization:** Use the built-in astro:assets module. For standalone exports, set the service to passthrough to ensure portability without a Node.js runtime.  
* **Font Loading:** Bundle .woff2 files in /public/fonts and reference them via standard @font-face in a global CSS file.

## **3\. The Interactivity Layer (Partial Hydration)**

* **React Integration:** Astro will host the React components (Widgets) developed for the interactive layer.  
* **Client Directives:** Use client:visible for widgets (YouTube, Calculators) to ensure they only load when the user scrolls to them.  
* **State Management:** Use **Nano Stores** for shared state between islands (e.g., synchronized scrolling or global theme settings). It is significantly smaller than Zustand.

## **4\. PWA & Offline Capabilities**

* **PWA Plugin:** Use @vite-pwa/astro.  
* **Service Worker:** Configure the workbox strategy to cache the manifest.json, the codex.json, and the images extracted by the parser.  
* **Standalone Mode:** The PWA must function entirely from the dist/ directory without any external API calls once exported.

## **5\. Technical Constraints for Developers**

1. **Tailwind CSS:** Use Tailwind for all styling.  
2. **Standardized Layout:** Use the slot pattern in Astro for the "Flipbook Shell" to allow for easy UI skinning.  
3. **No Dynamic Runtime:** Avoid any feature that requires output: 'server'. The project must strictly remain output: 'static'.

## **6\. Export Logic (Architectural Hook for DevOps)**

1. **Build Command:** npm run build (Generates the dist/ folder).  
2. **Injection:** The DevOps script injects the specific book.json into dist/data/book.json.  
3. **Validation:** The final build must be viewable via a local preview (e.g., npx serve dist) to confirm portability before zipping.