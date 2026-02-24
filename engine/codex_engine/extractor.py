import fitz
from typing import List, Dict, Any

def extract_text_with_metadata(pdf_path: str) -> Dict[str, Any]:
    """
    Extracts text spans and metadata from a PDF file.

    Args:
        pdf_path: Path to the PDF file.

    Returns:
        A dictionary containing:
        - "metadata": A dictionary with "title" and "author".
        - "spans": A list of dictionaries, each representing a text span with:
            - "text": The text content.
            - "font": The font name.
            - "size": The font size.
            - "bbox": A list [x0, y0, x1, y1].
            - "color": The text color (sRGB integer).
    """
    doc = fitz.open(pdf_path)

    # Extract metadata
    meta = doc.metadata
    extracted_meta = {
        "title": meta.get("title", ""),
        "author": meta.get("author", "")
    }

    spans = []

    for page in doc:
        text_dict = page.get_text("dict")
        for block in text_dict.get("blocks", []):
            if block.get("type") != 0:  # 0 is text, 1 is image
                continue
            for line in block.get("lines", []):
                for span in line.get("spans", []):
                    # Filter out empty/whitespace-only spans
                    text = span.get("text", "")
                    if text.strip():
                        spans.append({
                            "text": text,
                            "font": span.get("font", ""),
                            "size": span.get("size", 0),
                            "bbox": list(span.get("bbox", [])),
                            "color": span.get("color", 0)
                        })

    doc.close()

    return {
        "metadata": extracted_meta,
        "spans": spans
    }
