# **MVP Quality Assurance Plan: Project Codex**

**Role:** Gemini QA Engineer

**Objective:** To ensure the "The Book is the App" vision is realized through a flawless, high-performance, and SEO-optimized user experience.

## **1\. Scope & Critical User Flows**

The QA scope focuses on the **Decoupled Pipeline**. We must verify that the semantic data extracted by the Python Parser is accurately stored in Supabase and rendered by the Next.js frontend with high fidelity.

### **Critical User Flows for Rigorous Testing:**

* **The Conversion Path:** PDF Upload ![][image1] Python Parsing ![][image1] Codex JSON Generation ![][image1] Supabase Storage.  
* **The Enhancement Path:** Manual "Pinning" of interactive widgets (YouTube, Calculators) to detected anchor IDs within the Flutter Editor.  
* **The Distribution Path:** Public SaaS URL rendering and the "One-Click" PWA ZIP export.

## **2\. Test Data & "Gold Standard" Definitions**

To ensure reliable regression testing, the following directory structure and reference assets must be maintained within the repository.

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
| ref\_basic\_text.pdf | ref\_basic\_text.json | **Heuristic Scoring:** Verifies H1/H2/P detection based on font-size thresholds. |
| ref\_multi\_column.pdf | ref\_multi\_column.json | **Reading Order:** Verifies Y-Axis Clustering and correct flow in 2-column layouts. |
| ref\_widget\_anchors.pdf | ref\_widget\_anchors.json | **Anchor Detection:** Verifies that specific IDs (e.g., VIDEO\_BOX) are correctly identified. |
| ref\_graphic\_heavy.pdf | ref\_graphic\_heavy.json | **Canvas Blocks:** Verifies text extraction as alt\_text for highly graphical pages. |

## **3\. Test Strategy**

### **Types of Testing**

| Testing Type | Rationale for MVP |
| :---- | :---- |
| **Functional Testing** | Validating that every block in the Codex JSON (H1, P, Widgets) renders the correct HTML tag and content. |
| **SEO & Accessibility** | Using Lighthouse CI to ensure a score ![][image2]. Essential for the primary value proposition of "Discoverable Books." |
| **Compatibility** | Testing PWA "Install to Home Screen" flows. Service worker behavior varies between iOS Safari and Android Chrome. |
| **Regression Testing** | **Automated via Pytest:** Compares parser output against the "Gold Standard" JSON files in the fixtures directory. |

### **Test Environments**

* **Desktop Browsers:** Chrome (Latest), Safari (macOS), Firefox, Edge.  
* **Mobile Devices:**  
  * **iOS:** iPhone (Safari) \- Priority for high-end editorial consumers.  
  * **Android:** Pixel/Samsung (Chrome) \- Priority for PWA installation testing.  
* **Headless:** Lighthouse CI integrated into the deployment pipeline.

## **4\. MVP Test Plan**

### **Critical Test Cases**

#### **TC-01: Semantic Reflow Accuracy**

* **Objective:** Ensure PDF text hierarchy is preserved in the web view.  
* **Input:** tests/fixtures/pdfs/ref\_basic\_text.pdf  
* **Steps:**  
  1. Run the Python Parser on the input file.  
  2. Compare the output to tests/fixtures/expected\_json/ref\_basic\_text.json.  
  3. Load the generated JSON into the Next.js Renderer.  
* **Expected Outcome:** H1 is rendered as \<h1\>, body as \<p\>. No absolute positioning artifacts should be present.

#### **TC-02: Interactive Widget "Pinning"**

* **Objective:** Verify that a YouTube widget correctly replaces a PDF placeholder.  
* **Input:** tests/fixtures/pdfs/ref\_widget\_anchors.pdf  
* **Steps:**  
  1. In the Flutter Editor, assign a YouTube URL to the detected VIDEO\_BOX anchor.  
  2. Save and view the Renderer page.  
* **Expected Outcome:** The YouTube iframe renders within the natural text flow at the exact location of the original anchor.

#### **TC-03: PWA Offline Export**

* **Objective:** Validate that the downloaded ZIP contains a functional offline app.  
* **Steps:**  
  1. Click "Export PWA" in the dashboard and download the .zip.  
  2. Unzip and host locally on a simple HTTP server (e.g., npx serve).  
  3. Disconnect internet and refresh the page.  
* **Expected Outcome:** The book renders correctly without external network calls, utilizing pre-cached assets (fonts, images, JSON).

## **5\. Quality Risks & Mitigations**

| Quality Risk | Impact | Mitigation Strategy |
| :---- | :---- | :---- |
| **Parsing Layout Failure** | High | Implement a "Validation Layer" that flags low-confidence sections for manual review in the Editor. |
| **PWA Service Worker Desync** | Medium | Use strict versioning in the assets object; Service Worker must invalidate old caches on JSON updates. |
| **Mobile Reflow "Jank"** | Medium | Use CSS Container Queries for widgets to ensure they adapt to the viewport without layout shifts. |

## **6\. Definition of Done (Quality Gate)**

A feature or book conversion is considered **Done** only when:

1. **Lighthouse Audit:** Automated SEO and Accessibility scores are ![][image3].  
2. **Gold Standard Pass:** Regression tests against the fixture directory pass with 0% semantic deviation.  
3. **Installation Verified:** The "Add to Home Screen" prompt is functional on both iOS and Android.  
4. **Zero Critical Bugs:** No "P0" or "P1" bugs are open.

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAAXCAYAAADpwXTaAAAAt0lEQVR4XmNgGAWjgDpAQUGBQ05OLk1UVJQHXY4cwCgvL98KNNAYXYIsADIIaGAvkMmCLkcOYAR6twBoaByIjSIDlBAA2iRJClZSUgKaJTcfyJ6soqLCBzZIXFycGyhQDcSzSMVAw3YA6a9A3Aw0kB3FhaQAWVlZE6Ahq6WlpWXQ5UgCQAOEgQYtVlRUlEeXIxkADcoChnMEujjJAJRogYZNlZGRkUaXIwcwqqur84JodIlRMMAAAJV7J+RoCL8jAAAAAElFTkSuQmCC>

[image2]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACMAAAAUCAYAAAAHpoRMAAAAq0lEQVR4Xu2UvQpCMQxG2839TpdCf1zcXH0Gn+zirtxBfAJXwcFBEB/ME+iUWZoOPfBBSQL9SNI6NxgM/kjOeSPScRNijNuU0gtDpxDCpPMW+FLKHlNPdENFF5iAqR1m7iI567wJ0h3pEuP7oAMhr2uag6EZXboxJYvNoq+Y+mIo63wTalfO6G3WlbovV/SQV+YMTHTxvL2MQEZRRzLrgmZw+ZHlXHr5fQeaH7TUIZbQ1MTnAAAAAElFTkSuQmCC>

[image3]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAXCAYAAAB50g0VAAACdUlEQVR4Xu2VO2hUQQBF3xJFg6L4WVf3N/tDsdHAKoKgoNgI/lALMRZiKkHQTpGQJthEbEQQ0oiCWFuIYIT10wQUsYmBdIqfyiZoY2E8150xk2Hf7mZXG9kLl3nvzp2Z++b3oqiHHv5jFIvFLcaYMTgOTyD1hZ5sNttP3WnrGVOb0BNRsQ9OFgqFU9VqdWlY3wES9HUWzuRyuT0MSvfmPrynQM5UKpVWo03A0WQyuRL/AM/v7McshP2Sc/AtHEqlUitCT7vI5/NV+vgOL3haiffPmgRPu4z2inKN03gfhNN8VMppC6AZVCeYXsPhSqWyKvS0Au1uwjkGPuw0zRDaM/iI/pcrlMLxfNdvy4zvRP9GecTXG6EP4374El7PZDLrQkMcNGiTgO/hJrgVfg0DerN/zdebQftpFw1q8JY6Dw0hWgScZfm2uyBxAUO9JVjqZTQeofFH9mslrPdht8gcPO40uwe/aHCFUHh5wiCLDugfHhpfbOfw2NP5FP8deytoFa6g/XQBKQ92FVBBFAjzG83IYq8fPmytqV8tn2g/A8/DF8buwbggcfof6NRiGDb1e/Fo1OBy7QTpdHo9fU6Z+VP8e8nDIC4gvOrruhp0snQIanB31EUwTnyWgZ4z+CVeE9LswLNaDb2H145ri+8A2g+VTpN4CNNDTte2yHbYDbxZeMDrEm0PnscZ44mCeb4z8AN1RSsleB6Fk9rHzvfXYWfnsULBQQWjnKDc6PsUnIC3qatRd8yGm+J5wPf9E2hw/gY7CHCS2dgcxa9MQvXysYJ7Gx5Gifr3mfo+bMpyubwh6mJ/dgRNqV2OdnhDQcM+euihQ/wCbG/HAfYEuy8AAAAASUVORK5CYII=>