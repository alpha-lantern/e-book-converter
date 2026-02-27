from collections import Counter
from typing import List, Dict, Any

def calculate_base_size(spans: List[Dict[str, Any]]) -> int:
    """
    Calculates the BaseSize (most frequent font size) from a list of PDF spans.

    Args:
        spans: A list of dictionaries representing text spans,
               each containing at least a "size" key.

    Returns:
        The mode of the font sizes, rounded to the nearest integer.
        Returns 12 as a default if no spans are provided.
    """
    if not spans:
        return 12  # Default fallback

    sizes = [span["size"] for span in spans if "size" in span]

    if not sizes:
        return 12

    frequency = Counter(sizes)
    # most_common(1) returns a list of one tuple: [(value, count)]
    base_size = frequency.most_common(1)[0][0]

    return int(round(base_size))
