# **Project Codex: Bug Report Template**

**Reporter:** \[Your Name\]

**Date:** \[YYYY-MM-DD\]

**Severity:** \[S1 \- Critical / S2 \- Major / S3 \- Minor / S4 \- Cosmetic\]

**Component:** \[Python Parser / Flutter Editor / Next.js Renderer / Export Engine\]

## **1\. Summary**

*Provide a concise, descriptive title (e.g., "H1 tags demoted to P in multi-column layouts").*

## **2\. Environment**

* **Browser/Version:** (e.g., Chrome 120, iOS Safari 17\)  
* **Device:** (e.g., MacBook Pro, iPhone 15\)  
* **Source PDF:** \[Link to file in Supabase Storage or filename\]  
* **Book ID / Slug:** \[e.g., future-of-publishing-2024\]

## **3\. The Codex Context (Technical Details)**

*Crucial for the "Decoupled Pipeline" architecture.*

* **Affected Block ID:** \[Found in Codex JSON, e.g., block-042\]  
* **Anchor ID (if applicable):** \[e.g., video\_placeholder\_01\]  
* **Semantic Tag Conflict:**  
  * **Expected Tag:** (e.g., \<h1\>)  
  * **Actual Tag:** (e.g., \<p\>)

## **4\. Steps to Reproduce**

1. Upload \[Source PDF\] to the Admin Dashboard.  
2. Wait for Parsing to complete.  
3. Open the "Reader Preview" for the generated book.  
4. Scroll to page \[X\] or section \[Y\].

## **5\. Actual vs. Expected Result**

* **Actual Result:** \[Describe the behavior/visual glitch, e.g., "Text is overlapping the YouTube widget."\]  
* **Expected Result:** \[Describe the correct behavior, e.g., "The YouTube widget should push following text blocks down the flow."\]

## **6\. Lighthouse Impact (SEO/A11y)**

* \[ \] Breaks Semantic Structure (SEO Risk)  
* \[ \] Fails Color Contrast (A11y Risk)  
* \[ \] Increases Layout Shift (CLS / Performance Risk)

## **7\. JSON Snippet**

*Paste the relevant section of the codex\_manifest here if the error is data-driven:*

{  
  "id": "block-042",  
  "type": "text",  
  "semantic\_tag": "p",  
  "content": "This should have been a heading..."  
}

## **8\. Attachments**

*Add screenshots of the PDF source vs. the rendered PWA output.*