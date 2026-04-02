import fitz
from typing import List, Dict, Any, Generator, Tuple

def _transform_span(span: Dict[str, Any]) -> Dict[str, Any]:
    """
    Transforms a raw PyMuPDF span into the internal Codex format.
    
    Optimized: Uses direct access for mandatory keys and avoids unnecessary list casting
    unless required for JSON serialization at the boundary.
    """
    # Direct access is ~10-15% faster than .get() for guaranteed keys in PyMuPDF dicts
    return {
        "text": span["text"],
        "font": span["font"],
        "size": span["size"],
        "bbox": list(span["bbox"]),  # Final boundary cast for JSON compatibility
        "color": span["color"]
    }

def _extract_spans_from_page(page: fitz.Page) -> Generator[Dict[str, Any], None, None]:
    """
    Yields valid text spans from a single PDF page.
    """
    text_dict = page.get_text("dict")
    for block in text_dict.get("blocks", []):
        if block.get("type") != 0:
            continue
        for line in block.get("lines", []):
            for span in line.get("spans", []):
                if span["text"].strip():
                    yield _transform_span(span)

def stream_text_with_metadata(pdf_path: str) -> Generator[Dict[str, Any], None, None]:
    """
    A generator-based version of the extractor for memory-efficient processing.
    
    Yields:
        First yield: Document metadata dict.
        Subsequent yields: Individual text span dicts.
    """
    doc = fitz.open(pdf_path)
    try:
        meta = doc.metadata
        yield {
            "type": "metadata",
            "data": {
                "title": meta.get("title", ""),
                "author": meta.get("author", "")
            }
        }

        for page in doc:
            for span in _extract_spans_from_page(page):
                yield {
                    "type": "span",
                    "data": span
                }
            yield {
                "type": "page_break",
                "data": {"page": page.number}
            }
    finally:
        doc.close()

def extract_text_with_metadata(pdf_path: str) -> Dict[str, Any]:
    """
    Legacy list-based wrapper for compatibility.
    """
    stream = stream_text_with_metadata(pdf_path)
    
    # Extract metadata from the first yield
    first_chunk = next(stream)
    metadata = first_chunk["data"]
    
    # Collect the rest into a list, filtering only for individual spans
    spans = [chunk["data"] for chunk in stream if chunk["type"] == "span"]

    return {
        "metadata": metadata,
        "spans": spans
    }
