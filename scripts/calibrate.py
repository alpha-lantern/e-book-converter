import typer
from typing import Annotated
from codex_engine.extractor import stream_text_with_metadata
from codex_engine.heuristics import calculate_base_size, cluster_spans_by_y, classify_block

def main(
    filename: Annotated[str, typer.Argument(help="Path to the PDF file to calibrate.")]
):
    """
    Debug utility to calibrate PDF extraction.
    Calculates BaseSize and identifies the first 10 semantic blocks.
    """
    # Pass 1: Memory-efficient BaseSize calculation
    # We use a generator expression to feed only the span data to the heuristic
    stream = stream_text_with_metadata(filename)

    # Skip metadata
    try:
        next(stream)
    except StopIteration:
        print("Error: PDF appears to be empty or unreadable.")
        return

    span_generator = (chunk["data"] for chunk in stream if chunk["type"] == "span")
    base_size = calculate_base_size(span_generator)

    print(f"\nDetected BaseSize: {base_size}")
    print("=" * 50)

    # Pass 2: Identify the first 10 blocks using the public streaming API
    # Memory-efficient: Processes spans page-by-page and exits once 10 blocks are found.
    blocks_found = []
    current_page_spans = []

    # Restart the stream for the second pass
    stream = stream_text_with_metadata(filename)
    try:
        next(stream) # Skip metadata again
    except StopIteration:
        return

    for chunk in stream:
        if chunk["type"] == "span":
            current_page_spans.append(chunk["data"])
        elif chunk["type"] == "page_break":
            if current_page_spans:
                # Clustering is done page-by-page to prevent massive memory usage
                page_lines = cluster_spans_by_y(current_page_spans)
                for line in page_lines:
                    block = classify_block(line, base_size)
                    blocks_found.append(block)
                    if len(blocks_found) >= 10:
                        break
                # Discard processed spans to free memory
                current_page_spans = []

            if len(blocks_found) >= 10:
                break

    # Flush remaining spans if the stream ends without a final page_break
    if current_page_spans and len(blocks_found) < 10:
        remaining_lines = cluster_spans_by_y(current_page_spans)
        for line in remaining_lines:
            block = classify_block(line, base_size)
            blocks_found.append(block)
            if len(blocks_found) >= 10:
                break

    print(f"First {len(blocks_found)} identified blocks:\n")
    for i, block in enumerate(blocks_found[:10], 1):
        content_snippet = block.content[:50].replace("\n", " ")
        if len(block.content) > 50:
            content_snippet += "..."

        print(f"{i}. [{block.type.value.upper()}] {content_snippet}")
        print(f"   BBox: [{block.bbox.x0:.2f}, {block.bbox.y0:.2f}, {block.bbox.x1:.2f}, {block.bbox.y1:.2f}]")
        print(f"   Style: {block.style}")
        print("-" * 30)

if __name__ == "__main__":
    typer.run(main)
