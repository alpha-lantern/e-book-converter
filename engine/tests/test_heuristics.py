import pytest
from codex_engine.heuristics import calculate_base_size

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
