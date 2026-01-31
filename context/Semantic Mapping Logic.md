# **Project Codex: Semantic Mapping Logic**

**Objective:** To translate unstructured PDF font metadata into a structured "Codex JSON" with correct HTML semantic tags (H1, H2, P, etc.) for maximum SEO fidelity.

## **1\. The Normalization Process**

PDFs do not store "paragraphs"; they store "text strings" at specific X/Y coordinates. Our engine must first normalize these into **Logical Lines**.

1. **Y-Axis Clustering:** Group text strings that share the same (or nearly the same) Y-coordinate into a single line.  
2. **X-Axis Sorting:** Sort strings within a cluster by their X-coordinate to maintain natural reading order.  
3. **Style Extraction:** For every string, extract: Font-Family, Font-Size, Font-Weight, and Hex-Color.

## **2\. The Heuristic Scoring Model**

The parser uses a weighted scoring system to "guess" the semantic tag of a text block.

### **2.1 Rule A: Font Size Hierarchy (Primary)**

The system calculates the **Mode Font Size** (the most common size) for the entire document and labels it as the BaseSize.

* **H1:** If Size \>= BaseSize \* 2.0 AND Weight \== Bold.  
* **H2:** If Size \>= BaseSize \* 1.5 AND Weight \== Bold.  
* **H3:** If Size \> BaseSize AND Weight \== Bold.  
* **P (Body):** If Size \== BaseSize.

### **2.2 Rule B: Sequence Detection**

Context matters. A single line sitting between two large image blocks is often a **Caption**, regardless of font size.

* **Blockquote:** If a paragraph has a significantly wider left-margin than the BaseMargin.  
* **List Item:** If the line starts with a glyph (•, \-, 1.) or a specific bullet-font character.

## **3\. The "Codex JSON" Construction**

Once the tags are identified, the engine groups lines into "Blocks."

\# Pseudo-code for Block Construction  
if current\_line.tag \== previous\_line.tag:  
    append\_to\_current\_block(current\_line.text)  
else:  
    create\_new\_block(tag=current\_line.tag, content=current\_line.text)

## **4\. Semantic Fallback Strategy**

Because PDFs can be "messy," we implement a **Validation Layer** before finalizing the JSON.

1. **The H1 Constraint:** A document should ideally have only one \<h1\>. If the parser detects multiple, the second occurrence is automatically demoted to \<h2\> unless it appears on a new "Page" object (indicating a multi-part book).  
2. **Invisible Text Layer:** If a page is highly graphical (e.g., a complex infographic), the parser creates a type: "canvas\_block". It stores the image of the section but overlays the extracted text as **aria-label** or **alt-text** in the JSON to ensure search engines can still "read" the infographic.

## **5\. Visual-to-Semantic Mapping Table**

| PDF Characteristic | Mapping Logic | HTML Output |
| :---- | :---- | :---- |
| **All Caps \+ Large Size** | Uppercase detection \+ Size \> 18pt | \<h1\> |
| **Bold \+ Moderate Size** | Weight \> 600 \+ Size \> 12pt | \<h2\> |
| **Italic \+ Under Image** | FontStyle: Italic \+ Proximity to Image | \<figcaption\> |
| **Standard Weight/Size** | Mode Font Size | \<p\> |
| **Monospaced Font** | Font-Family contains "Courier/Mono" | \<code\> |

## **6\. Next Steps for Development**

1. **Calibration Script:** Create a small Python utility that prints the unique (font\_name, size, weight) tuples found in a sample PDF to help the user "tune" the thresholds before the full conversion.  
2. **Style Dictionary:** Store these mappings in the metadata section of the Codex JSON so the **Next.js Renderer** knows exactly which CSS classes to apply to which semantic tags.