# **Guide: Crafting Gold Standard PDFs for Project Codex**

To ensure our QA Plan is effective, the reference PDFs must be created with strict adherence to typographic and structural rules. This guide ensures the source files are "digitally clean" for the Python Parser and the Astro Renderer.

## **1\. Universal Requirements (All PDFs)**

* **Vector Text Only:** Do not "flatten" or "rasterize" text.  
* **Standard Font Set:** Use **Inter** or **Roboto** to keep the "Mode Font Size" calculation predictable.  
* **Tailwind Alignment:** Use standard font weights (400 for regular, 700 for bold) to ensure the Astro Renderer maps them correctly to Tailwind classes.

## **2\. Asset-Specific Requirements**

### **Asset: ref\_basic\_text.pdf (Font Hierarchy)**

* **Base Body:** Exactly **12pt**.  
* **H1 Header:** Exactly **24pt**, Bold.  
* **H2 Header:** Exactly **18pt**, Bold.  
* **Goal:** Verify that the Astro Renderer correctly generates \<h1\>, \<h2\>, and \<p\> tags with zero layout shift.

### **Asset: ref\_multi\_column.pdf (Reading Order)**

* **Layout:** 2-column layout.  
* **Requirement:** Ensure Column A and Column B have slightly offset Y-axis baselines to test clustering logic.  
* **Goal:** Verify the .astro template preserves the vertical reading flow in a single-column mobile view.

### **Asset: ref\_widget\_anchors.pdf (Hydration Testing)**

* **The Anchor Box:** Draw a rectangular box with the label VIDEO\_BOX\_01.  
* **Goal:** This PDF serves as the basis for testing the client:visible directive. The anchor must be far enough down the page to require scrolling.

### **Asset: ref\_graphic\_heavy.pdf (Canvas Blocks)**

* **The Image:** High-contrast infographic with selectable text overlays.  
* **Goal:** Verify that text is extracted as alt\_text for the Astro OptimizedImage component.

## **3\. Canva Workflow & Export**

1. **Use Styles:** Fix your sizes (12pt, 18pt, 24pt) in Canva's Brand Kit.  
2. **A4 Canvas:** Use standard A4 for consistent coordinate mapping.  
3. **Export Settings:**  
   * **Download** ![][image1] **PDF Print**.  
   * **CRITICAL:** Ensure "Flatten PDF" is **UNCHECKED**.  
   * **CRITICAL:** Ensure "Include notes" is **UNCHECKED**.

## **4\. Layout Shift (CLS) Warning for Designers**

Because the Astro Renderer hydrates interactive widgets asynchronously:

* **Requirement:** For the ref\_widget\_anchors.pdf, note the exact aspect ratio (e.g., 16:9) of the anchor box.  
* **Why:** The Astro template will use this ratio to reserve space, preventing the text from "jumping" when the React widget loads.

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAAXCAYAAADpwXTaAAAAt0lEQVR4XmNgGAWjgDpAQUGBQ05OLk1UVJQHXY4cwCgvL98KNNAYXYIsADIIaGAvkMmCLkcOYAR6twBoaByIjSIDlBAA2iRJClZSUgKaJTcfyJ6soqLCBzZIXFycGyhQDcSzSMVAw3YA6a9A3Aw0kB3FhaQAWVlZE6Ahq6WlpWXQ5UgCQAOEgQYtVlRUlEeXIxkADcoChnMEujjJAJRogYZNlZGRkUaXIwcwqqur84JodIlRMMAAAJV7J+RoCL8jAAAAAElFTkSuQmCC>