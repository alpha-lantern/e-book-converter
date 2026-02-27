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
    assert calculate_base_size(spans) == 12

def test_calculate_base_size_rounding():
    spans = [
        {"size": 11.6, "text": "Text"},
        {"size": 11.6, "text": "More text"},
        {"size": 14.0, "text": "Title"},
    ]
    assert calculate_base_size(spans) == 12

def test_calculate_base_size_empty():
    assert calculate_base_size([]) == 12

def test_calculate_base_size_no_size_key():
    spans = [{"text": "No size"}]
    assert calculate_base_size(spans) == 12

def test_calculate_base_size_single_span():
    spans = [{"size": 14.0, "text": "Title"}]
    assert calculate_base_size(spans) == 14
