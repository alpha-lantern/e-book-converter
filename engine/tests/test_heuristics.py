import pytest
from codex_engine.heuristics import calculate_base_size, cluster_spans_by_y, classify_block
from codex_engine.models import CodexBlockType

def test_classify_block_h1():
    base_size = 12.0
    # Size > 2.0 * 12.0 = 24.0
    line = [{"text": "Title", "size": 25.0, "bbox": [0, 0, 100, 30]}]
    block = classify_block(line, base_size)
    assert block.type == CodexBlockType.H1
    assert block.content == "Title"
    assert block.style.font_size == 25.0

def test_classify_block_h2():
    base_size = 12.0
    # Size > 1.5 * 12.0 = 18.0
    line = [{"text": "Subtitle", "size": 19.0, "bbox": [0, 0, 100, 20]}]
    block = classify_block(line, base_size)
    assert block.type == CodexBlockType.H2
    assert block.content == "Subtitle"
    assert block.style.font_size == 19.0

def test_classify_block_p():
    base_size = 12.0
    # Size <= 1.5 * 12.0 = 18.0
    line = [{"text": "Paragraph", "size": 12.0, "bbox": [0, 0, 100, 15]}]
    block = classify_block(line, base_size)
    assert block.type == CodexBlockType.P
    assert block.content == "Paragraph"
    assert block.style.font_size == 12.0

def test_classify_block_multi_span():
    base_size = 12.0
    line = [
        {"text": "Part 1 ", "size": 12.0, "bbox": [0, 10, 50, 25]},
        {"text": "Part 2", "size": 14.0, "bbox": [60, 10, 110, 25]}
    ]
    block = classify_block(line, base_size)
    # max_size = 14.0, which is <= 18.0 (1.5 * 12.0)
    assert block.type == CodexBlockType.P
    assert block.content == "Part 1 Part 2"
    assert block.bbox.x0 == 0
    assert block.bbox.y0 == 10
    assert block.bbox.x1 == 110
    assert block.bbox.y1 == 25
    assert block.style.font_size == 14.0

def test_classify_block_spacing_preservation():
    base_size = 12.0
    # Spans with native spacing
    line = [
        {"text": "Hello ", "size": 12.0, "bbox": [0, 0, 50, 20]},
        {"text": "World", "size": 12.0, "bbox": [55, 0, 105, 20]}
    ]
    block = classify_block(line, base_size)
    assert block.content == "Hello World" # Single space preserved from Span 1

    # Spans with no spacing (should not add any)
    line = [
        {"text": "No", "size": 12.0, "bbox": [0, 0, 20, 20]},
        {"text": "Space", "size": 12.0, "bbox": [21, 0, 50, 20]}
    ]
    block = classify_block(line, base_size)
    assert block.content == "NoSpace"

def test_classify_block_invalid_base_size():
    # Test zero
    with pytest.raises(ValueError, match="base_size must be positive, got 0.0"):
        classify_block([{"text": "T", "size": 12.0, "bbox": [0,0,0,0]}], 0.0)
    # Test negative
    with pytest.raises(ValueError, match="base_size must be positive, got -1.0"):
        classify_block([{"text": "T", "size": 12.0, "bbox": [0,0,0,0]}], -1.0)
    # Test small positive that rounds to zero
    with pytest.raises(ValueError, match="base_size must be positive, got 0.0"):
        classify_block([{"text": "T", "size": 12.0, "bbox": [0,0,0,0]}], 0.04)

def test_classify_block_thresholds():
    base_size = 10.0
    # H1 threshold: 20.0
    # H2 threshold: 15.0

    # Exactly 20.0 -> H2 (since logic is > 2.0 * base)
    assert classify_block([{"text": "T", "size": 20.0, "bbox": [0,0,0,0]}], base_size).type == CodexBlockType.H2

    # Exactly 15.0 -> P (since logic is > 1.5 * base)
    assert classify_block([{"text": "T", "size": 15.0, "bbox": [0,0,0,0]}], base_size).type == CodexBlockType.P

    # Just above
    assert classify_block([{"text": "T", "size": 20.1, "bbox": [0,0,0,0]}], base_size).type == CodexBlockType.H1
    assert classify_block([{"text": "T", "size": 15.1, "bbox": [0,0,0,0]}], base_size).type == CodexBlockType.H2

def test_classify_block_empty():
    with pytest.raises(ValueError, match="Cannot classify an empty line"):
        classify_block([], 12.0)

def test_cluster_spans_by_y_basic():
    spans = [
        {"text": "World", "bbox": [100, 10, 150, 20]},
        {"text": "Hello", "bbox": [10, 10, 60, 20]},
        {"text": "Line 2", "bbox": [10, 30, 60, 40]},
    ]
    clusters = cluster_spans_by_y(spans)

    assert len(clusters) == 2
    # First cluster (Line 1) should have Hello then World (sorted by x0)
    assert clusters[0][0]["text"] == "Hello"
    assert clusters[0][1]["text"] == "World"
    # Second cluster (Line 2)
    assert clusters[1][0]["text"] == "Line 2"

def test_cluster_spans_by_y_tolerance():
    spans = [
        {"text": "Span 1", "bbox": [10, 10, 60, 20]},
        {"text": "Span 2", "bbox": [70, 11.5, 120, 21.5]}, # Within 2.0 tolerance
        {"text": "Span 3", "bbox": [10, 12.0, 60, 22.0]}, # Within tolerance of Span 1 (ref) and Span 2 (sliding)
        {"text": "Span 4", "bbox": [10, 15.0, 60, 25.0]}, # Outside tolerance
    ]
    clusters = cluster_spans_by_y(spans, tolerance=2.0)

    assert len(clusters) == 2
    assert len(clusters[0]) == 3
    assert len(clusters[1]) == 1
    assert clusters[1][0]["text"] == "Span 4"

def test_cluster_spans_by_y_sliding_reference():
    # Demonstrates that sliding reference allows handling vertical drift
    # Span 1 (10) -> Span 2 (11.5) -> Span 3 (13.0) -> Span 4 (14.5)
    # Each is within 2.0 of its immediate predecessor, but Span 4 is 4.5 from Span 1.
    spans = [
        {"text": "1", "bbox": [0, 10.0, 0, 0]},
        {"text": "2", "bbox": [0, 11.5, 0, 0]},
        {"text": "3", "bbox": [0, 13.0, 0, 0]},
        {"text": "4", "bbox": [0, 14.5, 0, 0]},
    ]
    clusters = cluster_spans_by_y(spans, tolerance=2.0)
    assert len(clusters) == 1
    assert len(clusters[0]) == 4

def test_cluster_spans_by_y_malformed_input():
    # Missing bbox
    with pytest.raises(KeyError):
        cluster_spans_by_y([{"text": "no bbox"}])
    # Empty bbox (IndexError for bbox[1])
    with pytest.raises(IndexError):
        cluster_spans_by_y([{"bbox": []}])

def test_cluster_spans_by_y_negative_tolerance():
    with pytest.raises(ValueError, match="Tolerance must be non-negative"):
        cluster_spans_by_y([], tolerance=-1.0)

def test_cluster_spans_by_y_out_of_order():
    spans = [
        {"text": "Bottom", "bbox": [10, 50, 60, 60]},
        {"text": "Top", "bbox": [10, 10, 60, 20]},
    ]
    clusters = cluster_spans_by_y(spans)
    assert clusters[0][0]["text"] == "Top"
    assert clusters[1][0]["text"] == "Bottom"

def test_cluster_spans_by_y_empty():
    assert cluster_spans_by_y([]) == []

def test_cluster_spans_by_y_single():
    span = {"text": "Single", "bbox": [10, 10, 60, 20]}
    clusters = cluster_spans_by_y([span])
    assert len(clusters) == 1
    assert clusters[0][0]["text"] == "Single"

def test_calculate_base_size_mode():
    spans = [
        {"size": 12.0, "text": "Hello"},
        {"size": 12.0, "text": "World"},
        {"size": 18.0, "text": "Header"},
        {"size": 12.0, "text": "Body text"},
        {"size": 10.0, "text": "Footer"},
    ]
    result = calculate_base_size(spans)
    assert result == 12.0
    assert isinstance(result, float)

def test_calculate_base_size_precision_grouping():
    # These should group into 11.6
    spans = [
        {"size": 11.58, "text": "Text 1"},
        {"size": 11.62, "text": "Text 2"},
        {"size": 14.0, "text": "Title"},
    ]
    assert calculate_base_size(spans) == 11.6

def test_calculate_base_size_empty():
    assert calculate_base_size([]) == 12.0

def test_calculate_base_size_no_size_key():
    spans = [{"text": "No size"}]
    assert calculate_base_size(spans) == 12.0

def test_calculate_base_size_generator():
    def span_generator():
        yield {"size": 14.0, "text": "Title"}
        yield {"size": 12.0, "text": "Body"}
        yield {"size": 12.0, "text": "Text"}

    assert calculate_base_size(span_generator()) == 12.0
