from collections import Counter
from typing import Iterable, Any
from .models import CodexBlock, CodexBlockType, CodexBBox, CodexStyle

def classify_block(line: list[dict[str, Any]], base_size: float) -> CodexBlock:
    """
    Classifies a line of spans into a CodexBlock (H1, H2, or P) based on font size.

    Args:
        line: A list of span dictionaries. Expected schema:
              {"text": str, "size": float, "bbox": [x0, y0, x1, y1]}
        base_size: The document's base font size (rounded to 1 decimal place).

    Returns:
        A CodexBlock object with assigned semantic type.
    """
    if not line:
        raise ValueError("Cannot classify an empty line.")

    if base_size <= 0:
        raise ValueError("base_size must be positive.")

    # Round base_size internally for stable float comparison
    base_size = round(float(base_size), 1)

    # Determine the maximum font size in the line to represent the block's style
    max_size = round(max(float(span["size"]) for span in line), 1)

    # Concatenate text from all spans. Use empty join to preserve PDF-native spacing.
    content = "".join(span["text"] for span in line)

    # Calculate the union bounding box
    x0 = min(span["bbox"][0] for span in line)
    y0 = min(span["bbox"][1] for span in line)
    x1 = max(span["bbox"][2] for span in line)
    y1 = max(span["bbox"][3] for span in line)
    bbox = CodexBBox(x0=x0, y0=y0, x1=x1, y1=y1)

    # Assign semantic type based on size thresholds
    if max_size > 2.0 * base_size:
        block_type = CodexBlockType.H1
    elif max_size > 1.5 * base_size:
        block_type = CodexBlockType.H2
    else:
        block_type = CodexBlockType.P

    # TODO: Enrich CodexStyle with weight and alignment metrics once OCR layer is ready.
    return CodexBlock(
        type=block_type,
        content=content,
        bbox=bbox,
        style=CodexStyle(font_size=max_size)
    )

def cluster_spans_by_y(spans: list[dict[str, Any]], tolerance: float = 2.0) -> list[list[dict[str, Any]]]:
    """
    Groups spans into horizontal lines based on their Y-coordinate using a sliding reference.

    Args:
        spans: A list of span dictionaries, each containing a "bbox" key [x0, y0, x1, y1].
        tolerance: The maximum vertical distance (in points) to consider spans on the same line.

    Returns:
        A list of clusters, where each cluster is a list of spans sorted by X-coordinate.

    Raises:
        ValueError: If tolerance is negative.
        KeyError: If a span is missing the "bbox" key.
        IndexError: If a bbox has fewer than 2 elements.
    """
    if tolerance < 0:
        raise ValueError("Tolerance must be non-negative.")

    if not spans:
        return []

    # Sort spans by y0 (top coordinate)
    # This also serves as initial validation: each span must have bbox[1]
    try:
        sorted_spans = sorted(spans, key=lambda s: s["bbox"][1])
    except (KeyError, IndexError) as e:
        raise type(e)(f"Malformed span: {e}") from e

    clusters = []
    current_cluster = [sorted_spans[0]]

    for i in range(1, len(sorted_spans)):
        span = sorted_spans[i]
        # Sliding reference: compare to the last span added to the cluster
        last_span = current_cluster[-1]

        if abs(span["bbox"][1] - last_span["bbox"][1]) <= tolerance:
            current_cluster.append(span)
        else:
            # Sort the completed cluster by x0
            current_cluster.sort(key=lambda s: s["bbox"][0])
            clusters.append(current_cluster)
            # Start new cluster
            current_cluster = [span]

    # Sort and add the last cluster
    current_cluster.sort(key=lambda s: s["bbox"][0])
    clusters.append(current_cluster)

    return clusters

def calculate_base_size(spans: Iterable[dict[str, Any]]) -> float:
    """
    Calculates the BaseSize (most frequent font size) from a stream of PDF spans.

    Memory-efficient: processes the spans iteratively without materializing a list.
    Handles float precision by rounding to 1 decimal place before counting.

    Args:
        spans: An iterable of dictionaries representing text spans,
               each containing at least a "size" key.

    Returns:
        The mode of the font sizes as a float.
        Returns 12.0 as a default if no spans are provided.
    """
    frequency = Counter()
    has_spans = False

    for span in spans:
        if "size" in span:
            has_spans = True
            # Round to 1 decimal place to prevent precision fragmentation
            size = round(float(span["size"]), 1)
            frequency[size] += 1

    if not has_spans:
        return 12.0

    # most_common(1) returns a list of one tuple: [(value, count)]
    base_size = frequency.most_common(1)[0][0]

    return float(base_size)
