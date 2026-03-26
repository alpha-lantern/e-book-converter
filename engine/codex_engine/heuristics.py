from collections import Counter
from typing import Iterable, Dict, Any, List

def cluster_spans_by_y(spans: List[Dict[str, Any]], tolerance: float = 2.0) -> List[List[Dict[str, Any]]]:
    """
    Groups spans into horizontal lines based on their Y-coordinate.

    Args:
        spans: A list of span dictionaries, each containing a "bbox" key [x0, y0, x1, y1].
        tolerance: The maximum vertical distance (in points) to consider spans on the same line.

    Returns:
        A list of clusters, where each cluster is a list of spans sorted by X-coordinate.
    """
    if not spans:
        return []

    # Sort spans by y0 (top coordinate)
    sorted_spans = sorted(spans, key=lambda s: s["bbox"][1])

    clusters = []
    current_cluster = [sorted_spans[0]]
    reference_y = sorted_spans[0]["bbox"][1]

    for i in range(1, len(sorted_spans)):
        span = sorted_spans[i]
        if abs(span["bbox"][1] - reference_y) <= tolerance:
            current_cluster.append(span)
        else:
            # Sort the completed cluster by x0
            current_cluster.sort(key=lambda s: s["bbox"][0])
            clusters.append(current_cluster)
            # Start new cluster
            current_cluster = [span]
            reference_y = span["bbox"][1]

    # Sort and add the last cluster
    current_cluster.sort(key=lambda s: s["bbox"][0])
    clusters.append(current_cluster)

    return clusters

def calculate_base_size(spans: Iterable[Dict[str, Any]]) -> float:
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
