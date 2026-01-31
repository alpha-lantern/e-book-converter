# **Project Codex: MVP UX/UI Design Plan**

## **1\. Analysis & Understanding**

* **Core Problem:** Static PDFs are "dead-ends" for SEO and mobile usability.  
* **MVP Goal:** Convert PDF designs into responsive, interactive PWAs with minimal manual effort.  
* **Platform Constraint:** The Editor Tool will be built using **Flutter**. This allows for a consistent layout engine across web/desktop environments. Design decisions will favor high-performance rendering and custom layout management.

## **2\. Critical User Flow: "The One-Click Conversion"**

This flow maps the journey from a static file to a live, interactive web app.

1. **Ingestion:** User logs in and drops a PDF into the "Project Codex" upload zone.  
   * *Goal:* Quick, frictionless file handoff.  
2. **Conversion Processing:** System parses text, styles, and images.  
   * *Goal:* Transparent progress feedback to build trust during the "black box" phase.  
3. **Enhancement (The Editor):** User enters the split-view editor.  
   * *Goal:* Review the reflowed text and map detected "Anchor Points" to widgets (Video/Text Editor).  
4. **Finalization & Export:** User toggles between "Public URL" (SaaS) or "Download ZIP" (PWA).  
   * *Goal:* Easy distribution and confirmation of SEO readiness.

## **3\. Key Screen Concepts**

### **Screen A: The Conversion Dashboard (Upload & Status)**

A clean, centralized hub for managing "Books."

\+-------------------------------------------------------------+  
| \[ Codex Logo \]                     \[ Projects \] \[ Profile \] |  
\+-------------------------------------------------------------+  
|                                                             |  
|   \+-----------------------------------------------------+   |  
|   |                  UPLOAD NEW PROJECT                 |   |  
|   |        \[ Icon: File Upload \] Drag & Drop PDF        |   |  
|   |           (Supports .pdf up to 100MB)               |   |  
|   \+-----------------------------------------------------+   |  
|                                                             |  
|   RECENT PROJECTS                                           |  
|   \+-------------------+  \+-------------------+              |  
|   | \[Book Cover\]      |  | \[Book Cover\]      |              |  
|   | Annual Report '24 |  | Field Guide V1    |              |  
|   | (Status: Live)    |  | (Status: Draft)   |              |  
|   \+-------------------+  \+-------------------+              |  
|                                                             |  
\+-------------------------------------------------------------+

### **Screen B: The Interactive Overlay Editor**

A dual-pane interface optimized for "Enhancement" rather than "Layout Design."

\+-------------------------------------------------------------+  
| \[ \< Back \]   Project: Annual Report '24      \[ Export/ZIP \] |  
\+-------------------------------------------------------------+  
| MAIN VIEW (REFRACTED HTML)     | WIDGET SIDEBAR             |  
|                                |                            |  
| \[ Title: The Future of... \]    | \[?\] DETECTED ANCHORS (3)   |  
|                                |                            |  
| \[ Image: Chart.webp \]          | 1\. Box\_44 (Page 2\)         |  
|                                |    \[ Select Widget v \]     |  
| \[ Placeholder: Video\_Box \] \<---|    \[ YouTube Embed  \]      |  
|                                |    \[ URL: \_\_\_\_\_\_\_\_\_ \]      |  
| \[ Body: "This year we saw..." \]|                            |  
| (Double click text to edit)    | 2\. Box\_89 (Page 5\)         |  
|                                |    \[ Text Editor    \]      |  
|                                |                            |  
\+-------------------------------------------------------------+

### **Screen C: The Reader View (Mobile PWA)**

The final output, optimized for the "The Book is the App" vision.

\+------------------+  
| \[ Menu \] \[Title\] |  
\+------------------+  
|                  |  
|  \[ Header 1 \]    |  
|                  |  
|  The landscape   |  
|  is changing...  |  
|                  |  
|  \+------------+  |  
|  | \[ VIDEO \]  |  | \<--- Smoothly integrated widget  
|  \+------------+  |  
|                  |  
|  Large, readable |  
|  body text.      |  
|                  |  
\+------------------+

## **4\. Design Language**

### **Color Palette**

* **Primary Action:** \#2563EB (Deep Cobalt) – Used for "Convert" and "Export" buttons.  
* **Secondary/Neutral:** \#64748B (Slate) – Used for UI borders and secondary text.  
* **Accent/Status:** \#10B981 (Emerald) – Used for "Live" status and successful conversions.  
* **Workspace Background:** \#F8FAFC (Ghost White) – High contrast for the editor area.

### **Typography**

* **Editor Interface:** Inter or Noto Sans (Clean, functional, high legibility in Flutter).  
* **Reader Content (The App):**  
  * *Headings:* Playfair Display or Georgia (Editorial/Premium feel).  
  * *Body:* Source Serif 4 or Noto Sans (Optimized for long-form reading).

### **UI Components**

* **Buttons:** Rounded corners (8px radius), subtle drop shadow on hover.  
* **Input Fields:** Ghost style with deep slate borders to keep the focus on content.  
* **Widget Cards:** Distinctive border style (dashed) to separate system-generated placeholders from content.

## **5\. Potential Usability Issues & Solutions**

| Potential Friction Point | Proposed UI/UX Solution |
| :---- | :---- |
| **Parsing Errors:** The engine might misinterpret a layout, causing text to jumble. | **Visual Check Flag:** If the parser confidence is low, highlight the section in the editor sidebar with a "Check Flow" warning icon. |
| **Anchor Confusion:** Designers might not know where "Box\_44" is located. | **Auto-Scroll & Highlight:** Clicking an anchor in the sidebar should automatically scroll the preview pane to that element and flash a subtle highlight. |
| **Mobile Navigation:** Long books can be tedious to scroll on mobile. | **Progressive Progress Bar:** Implement a thin, non-intrusive progress bar at the top of the PWA that updates as the reader scrolls. |
| **PWA Installation:** Users often don't know they *can* install a web app. | **In-App Prompt:** On the first open, display a small, elegant "Add to Home Screen" tooltip explaining the benefit (Offline Reading). |

