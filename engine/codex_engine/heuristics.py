from collections import Counter
from typing import Iterable, Dict, Any

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
