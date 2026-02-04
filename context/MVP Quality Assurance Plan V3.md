# **MVP Quality Assurance Plan: Project Codex**

**Role:** Gemini QA Engineer

**Objective:** To ensure the "The Book is the App" vision is realized through a high-performance, Astro-powered, and SEO-optimized user experience.

## **1\. Scope & Critical User Flows**

The QA scope focuses on the **Decoupled Pipeline**. We must verify that the semantic data extracted by the Python Parser is accurately rendered by the **Astro Renderer** with a focus on partial hydration (Islands Architecture).

### **Critical User Flows for Rigorous Testing:**

* **The Conversion Path:** PDF Upload ![][image1] Python Parsing ![][image1] Codex JSON ![][image1] Astro Static Generation.  
* **The Enhancement Path:** Manual "Pinning" of React widgets (YouTube, Calculators) to detected anchor IDs.  
* **The Distribution Path:** Public SaaS URL rendering and the "One-Click" PWA ZIP export from the dist/ directory.

## **2\. Test Data & "Gold Standard" Definitions**

To ensure reliable regression testing, the following directory structure and reference assets must be maintained.

### **Directory Structure**

/project-codex  
├── parser/                \# Python Parser Source  
└── tests/  
    └── fixtures/  
        ├── pdfs/          \# Input: Reference PDFs  
        └── expected\_json/ \# Output: "Gold Standard" JSONs

### **Reference Asset Registry**

| Input Filename (tests/fixtures/pdfs/) | Expected Output (tests/fixtures/expected\_json/) | Critical Test Surface |
| :---- | :---- | :---- |
| ref\_basic\_text.pdf | ref\_basic\_text.json | **Heuristic Scoring:** Verifies H1/H2/P detection. |
| ref\_multi\_column.pdf | ref\_multi\_column.json | **Reading Order:** Verifies flow in 2-column layouts. |
| ref\_widget\_anchors.pdf | ref\_widget\_anchors.json | **Astro Hydration:** Verifies client:visible triggers for anchors. |
| ref\_graphic\_heavy.pdf | ref\_graphic\_heavy.json | **Canvas Blocks:** Verifies alt\_text extraction. |

## **3\. Test Strategy**

### **Types of Testing**

| Testing Type | Rationale for Astro MVP |
| :---- | :---- |
| **Hydration Testing** | **NEW:** Verify that React widgets only "awaken" (JS loads) when visible in viewport via client:visible. |
| **Functional Testing** | Validating that .astro components render the correct static HTML tags (H1, P, Quote). |
| **SEO & Accessibility** | Lighthouse CI targets: **FCP \< 1.0s** and **SEO/A11y \> 90**. Astro ensures a Zero-JS baseline. |
| **Compatibility** | Testing @vite-pwa/astro plugin behavior on iOS Safari vs. Android Chrome. |
| **Regression Testing** | Automated via Pytest comparing parser output against Gold Standard JSONs. |

### **Test Environments**

* **Desktop:** Chrome, Safari, Firefox, Edge.  
* **Mobile:** iPhone (Safari), Android (Chrome).  
* **Performance:** Lighthouse CI in the GitHub Actions pipeline.

## **4\. MVP Test Plan: Critical Test Cases**

#### **TC-01: Semantic Reflow (Zero-JS Verification)**

* **Objective:** Ensure text renders as pure HTML without requiring JavaScript.  
* **Steps:** 1\. Disable JavaScript in the browser.  
  2\. Load a rendered book page.  
* **Expected Outcome:** All text (H1, P, Quotes) is fully visible and styled correctly.

#### **TC-02: Lazy Hydration (Astro Islands)**

* **Objective:** Verify client:visible functionality for interactive widgets.  
* **Steps:** 1\. Open a long book with a YouTube widget at the bottom.  
  2\. Check the Network tab in DevTools; verify the widget's React bundle has *not* loaded.  
  3\. Scroll to the widget.  
* **Expected Outcome:** The widget's JS bundle loads and the component hydrates only upon entering the viewport.

#### **TC-03: PWA Offline Export (Vite-PWA)**

* **Objective:** Validate that the dist/ export contains a functional offline manifest.  
* **Steps:** 1\. Build using npm run build.  
  2\. Serve the dist/ folder and test offline functionality.  
* **Expected Outcome:** Service worker correctly caches the data/book.json and static assets for offline reading.

## **5\. Quality Risks & Mitigations**

| Quality Risk | Impact | Mitigation Strategy |
| :---- | :---- | :---- |
| **Cumulative Layout Shift (CLS)** | High | Ensure Astro "Skeleton" components match exact React widget dimensions to prevent shifts during hydration. |
| **Build Directory Mismatch** | Medium | Update CI/CD to target dist/ instead of out/ for PWA packaging. |
| **Nano Store Desync** | Low | Verify that theme/progress state persists across different Astro islands. |

## **6\. Definition of Done (Quality Gate)**

1. **Lighthouse Audit:** SEO/A11y ![][image2]; Performance ![][image3].  
2. **Hydration Check:** All widgets use client:visible or client:load as specified.  
3. **Gold Standard Pass:** 0% semantic deviation in parser regression tests.  
4. **Zero-JS Baseline:** Core text content is readable with JavaScript disabled.

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAAXCAYAAADpwXTaAAAAt0lEQVR4XmNgGAWjgDpAQUGBQ05OLk1UVJQHXY4cwCgvL98KNNAYXYIsADIIaGAvkMmCLkcOYAR6twBoaByIjSIDlBAA2iRJClZSUgKaJTcfyJ6soqLCBzZIXFycGyhQDcSzSMVAw3YA6a9A3Aw0kB3FhaQAWVlZE6Ahq6WlpWXQ5UgCQAOEgQYtVlRUlEeXIxkADcoChnMEujjJAJRogYZNlZGRkUaXIwcwqqur84JodIlRMMAAAJV7J+RoCL8jAAAAAElFTkSuQmCC>

[image2]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAXCAYAAAB50g0VAAACdUlEQVR4Xu2VO2hUQQBF3xJFg6L4WVf3N/tDsdHAKoKgoNgI/lALMRZiKkHQTpGQJthEbEQQ0oiCWFuIYIT10wQUsYmBdIqfyiZoY2E8150xk2Hf7mZXG9kLl3nvzp2Z++b3oqiHHv5jFIvFLcaYMTgOTyD1hZ5sNttP3WnrGVOb0BNRsQ9OFgqFU9VqdWlY3wES9HUWzuRyuT0MSvfmPrynQM5UKpVWo03A0WQyuRL/AM/v7McshP2Sc/AtHEqlUitCT7vI5/NV+vgOL3haiffPmgRPu4z2inKN03gfhNN8VMppC6AZVCeYXsPhSqWyKvS0Au1uwjkGPuw0zRDaM/iI/pcrlMLxfNdvy4zvRP9GecTXG6EP4374El7PZDLrQkMcNGiTgO/hJrgVfg0DerN/zdebQftpFw1q8JY6Dw0hWgScZfm2uyBxAUO9JVjqZTQeofFH9mslrPdht8gcPO40uwe/aHCFUHh5wiCLDugfHhpfbOfw2NP5FP8deytoFa6g/XQBKQ92FVBBFAjzG83IYq8fPmytqV8tn2g/A8/DF8buwbggcfof6NRiGDb1e/Fo1OBy7QTpdHo9fU6Z+VP8e8nDIC4gvOrruhp0snQIanB31EUwTnyWgZ4z+CVeE9LswLNaDb2H145ri+8A2g+VTpN4CNNDTte2yHbYDbxZeMDrEm0PnscZ44mCeb4z8AN1RSsleB6Fk9rHzvfXYWfnsULBQQWjnKDc6PsUnIC3qatRd8yGm+J5wPf9E2hw/gY7CHCS2dgcxa9MQvXysYJ7Gx5Gifr3mfo+bMpyubwh6mJ/dgRNqV2OdnhDQcM+euihQ/wCbG/HAfYEuy8AAAAASUVORK5CYII=>

[image3]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAXCAYAAAB50g0VAAACiUlEQVR4Xu2VO2gUURSGJySioiio65p9XfeBYqPCBIIBBW19gVqINmJAEISIjSJBsVVsNIVsIwbEUixE0EB8gPhCLVREbJRE+0AKG9fvz9xrrpPNZtw1jewPPzP33HPOPXMed4KgjTb+YxSLxfXGmIuwCvcj6vT31wLkh7LZbE57LBdhs6lQKBzT+29FlLbDZwgPhmG4YNpF0+jA1xH4KZ/Pb+VQ3JubcDiXyy12Sqz74A9Y8zgJd3q+IsiQjaPwLexPp9NL4jpJQQZCe9AJT1Zi/U1JiOl9gB91LnsXeHa7/bpQBuUExVdwsFKpLIvrzAXsrsAaAex2slQqtRTZQ3jXlc8GeHXa8u/QifEO+AReok9WxhVmAwHcaBDgF5elVgN0UD/14mgUDjnnjTBHgBMaBMlsgLfhMPzM+is87/dpYlDqhRifw9EYDirxfR+2RWpwn5PZHvwOJxWYlYXwufOnKmH7Ap1q4mH1hwdnA0mGp1QqLUd/BP3r9iBV4Qyyn36A2ov7Y/+siSZ7iy+fARkqIBRfKyOJv8iCD1thoqtlXNcNPA4fG68H64EzT5so+6fie1PQ1LI5aKJ7cW8Qu1ybRSaTWYXP98ZOscrJ+0v4rlwur3Z6LkA9fXultttEQzAK+4IWAtOfgQMeEchJlh2S2YGYUDW0tucpm38EaKIS17jg9ziZjHdheIfp2hhYh63ABqOL+hbLLrUH71XOuK9ptmpd6F1D1uvs1Lu2DUb07uT/HPZKuaeg4GEFxvMBzzW+nv0FTt2zsB++gU/tv3l+oaxRph6ydIBsrAtmqYz0CHSb9AhuQ1CvtaxS2kR90ZC2X2Y6mU+Q+s0mKkcSXlagcR9ttNEkfgGj879prPlrJAAAAABJRU5ErkJggg==>