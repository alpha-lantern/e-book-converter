# **Project Codex: Semantic Mapping Logic**

**Objective:** To translate unstructured PDF font metadata into a structured "Codex JSON" with correct HTML semantic tags (H1, H2, P, etc.) for maximum SEO fidelity.

## **1\. The Normalization Process**

1. **Y-Axis Clustering:** Group text strings into **Logical Lines**.  
2. **X-Axis Sorting:** Sort strings within a cluster by their X-coordinate.  
3. **Style Extraction:** Extract Font-Family, Font-Size, Font-Weight, and Hex-Color.

## **2\. The Heuristic Scoring Model**

### **2.1 Rule A: Font Size Hierarchy**

* **H1:** Size \>= BaseSize \* 2.0 AND Weight \== Bold.  
* **H2:** Size \>= BaseSize \* 1.5 AND Weight \== Bold.  
* **H3:** Size \> BaseSize AND Weight \== Bold.  
* **P (Body):** Size \== BaseSize.

### **2.2 Rule B: Sequence Detection**

* **Blockquote:** Significant left-margin indentation.  
* **List Item:** Line starts with a bullet glyph or list character.

## **3\. The "Codex JSON" Construction**

Once the tags are identified, the engine groups lines into "Blocks."

\# Pseudo-code for Block Construction  
if current\_line.tag \== previous\_line.tag:  
    append\_to\_current\_block(current\_line.text)  
else:  
    create\_new\_block(tag=current\_line.tag, content=current\_line.text)

## **4\. Semantic Fallback Strategy**

1. **The H1 Constraint:** Ensure a single \<h1\> per logical page.  
2. **Invisible Text Layer:** Use for highly graphical pages to maintain SEO without breaking visual layout.

## **5\. Visual-to-Semantic Mapping Table**

| PDF Characteristic | Mapping Logic | HTML Output |
| :---- | :---- | :---- |
| **All Caps \+ Large Size** | Uppercase detection \+ Size \> 18pt | \<h1\> |
| **Bold \+ Moderate Size** | Weight \> 600 \+ Size \> 12pt | \<h2\> |
| **Italic \+ Under Image** | FontStyle: Italic \+ Proximity to Image | \<figcaption\> |
| **Standard Weight/Size** | Mode Font Size | \<p\> |
| **Monospaced Font** | Font-Family contains "Courier/Mono" | \<code\> |

## **6\. Next Steps for Development**

1. **Calibration Script:** Print unique font tuples to tune thresholds.  
2. **Style Dictionary:** Store mappings in Codex JSON metadata so the **Astro Renderer** knows which classes to apply (mapping JSON styles to Tailwind utility classes).