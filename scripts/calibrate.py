import typer
import fitz
from codex_engine.extractor import stream_text_with_metadata, _extract_spans_from_page
from codex_engine.heuristics import calculate_base_size, cluster_spans_by_y, classify_block

def main(filename: str):
    """
    Debug utility to calibrate PDF extraction.
    Calculates BaseSize and identifies the first 10 semantic blocks.
    """
    # Pass 1: Memory-efficient BaseSize calculation
    # We use a generator expression to feed only the span data to the heuristic
    stream = stream_text_with_metadata(filename)
    # The first chunk is always metadata
    try:
        next(stream)
    except StopIteration:
        print("Error: PDF appears to be empty or unreadable.")
        return

    span_generator = (chunk["data"] for chunk in stream if chunk["type"] == "span")
    base_size = calculate_base_size(span_generator)

    print(f"\nDetected BaseSize: {base_size}")
    print("=" * 50)

    # Pass 2: Identify the first 10 blocks
    doc = fitz.open(filename)
    blocks_found = []

    try:
        for page in doc:
            # We cluster spans per page
            page_spans = list(_extract_spans_from_page(page))
            if not page_spans:
                continue

            lines = cluster_spans_by_y(page_spans)
            for line in lines:
                block = classify_block(line, base_size)
                blocks_found.append(block)
                if len(blocks_found) >= 10:
                    break

            if len(blocks_found) >= 10:
                break
    finally:
        doc.close()

    print(f"First {len(blocks_found)} identified blocks:\n")
    for i, block in enumerate(blocks_found, 1):
        content_snippet = block.content[:50].replace("\n", " ")
        if len(block.content) > 50:
            content_snippet += "..."

        print(f"{i}. [{block.type.value.upper()}] {content_snippet}")
        print(f"   BBox: [{block.bbox.x0:.2f}, {block.bbox.y0:.2f}, {block.bbox.x1:.2f}, {block.bbox.y1:.2f}]")
        print(f"   Style: {block.style}")
        print("-" * 30)

if __name__ == "__main__":
    typer.run(main)
