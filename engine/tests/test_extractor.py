import os
import pytest
import fitz
from codex_engine.extractor import extract_text_with_metadata, stream_text_with_metadata

@pytest.fixture(scope="module")
def sample_pdf(tmp_path_factory):
    """Creates a sample PDF for testing and returns its path."""
    tmp_dir = tmp_path_factory.mktemp("data")
    pdf_path = tmp_dir / "sample.pdf"

    doc = fitz.open()
    page = doc.new_page()

    p1 = fitz.Point(50, 50)
    page.insert_text(p1, "Hello World", fontname="helv", fontsize=12)

    p2 = fitz.Point(50, 100)
    page.insert_text(p2, "This is a Test", fontname="times-bold", fontsize=18)

    # Add metadata
    doc.set_metadata({
        "title": "Sample PDF Title",
        "author": "Alpha Lantern"
    })

    doc.save(str(pdf_path))
    doc.close()

    return str(pdf_path)

def test_extract_text_with_metadata(sample_pdf):
    result = extract_text_with_metadata(sample_pdf)

    # Verify metadata
    assert result["metadata"]["title"] == "Sample PDF Title"
    assert result["metadata"]["author"] == "Alpha Lantern"

    # Verify spans
    spans = result["spans"]
    assert len(spans) >= 2

    # Find specific spans
    hello_world_span = next((s for s in spans if "Hello World" in s["text"]), None)
    assert hello_world_span is not None
    assert "helv" in hello_world_span["font"].lower()
    assert hello_world_span["size"] == 12.0
    assert len(hello_world_span["bbox"]) == 4

    test_span = next((s for s in spans if "This is a Test" in s["text"]), None)
    assert test_span is not None
    assert "times" in test_span["font"].lower()
    assert test_span["size"] == 18.0
    assert len(test_span["bbox"]) == 4

def test_extract_text_filter_whitespace(sample_pdf):
    result = extract_text_with_metadata(sample_pdf)

    for span in result["spans"]:
        assert span["text"].strip() != ""

def test_stream_text_with_metadata(sample_pdf):
    stream = stream_text_with_metadata(sample_pdf)
    
    # Check metadata chunk
    meta_chunk = next(stream)
    assert meta_chunk["type"] == "metadata"
    assert meta_chunk["data"]["title"] == "Sample PDF Title"
    
    # Check span chunks
    span_chunks = list(stream)
    assert len(span_chunks) >= 2
    for chunk in span_chunks:
        assert chunk["type"] in ["span", "page_break"]
        if chunk["type"] == "span":
            assert "text" in chunk["data"]
        else:
            assert "page" in chunk["data"]

def test_stream_text_page_breaks(sample_pdf):
    # Update sample_pdf to have two pages
    pdf_path = sample_pdf
    doc = fitz.open(pdf_path)
    page = doc.new_page()
    page.insert_text(fitz.Point(50, 50), "Page 2 Text", fontsize=12)
    doc.save(pdf_path, incremental=True, encryption=fitz.PDF_ENCRYPT_KEEP)
    doc.close()

    stream = stream_text_with_metadata(pdf_path)
    next(stream) # metadata

    chunks = list(stream)

    # Assert we have page_break chunks and they follow spans
    page_breaks = [i for i, chunk in enumerate(chunks) if chunk["type"] == "page_break"]
    assert len(page_breaks) == 2

    # Assert each page_break has a page number
    assert chunks[page_breaks[0]]["data"]["page"] == 0
    assert chunks[page_breaks[1]]["data"]["page"] == 1

    # Assert first page_break is after some spans
    assert page_breaks[0] > 0
    assert chunks[page_breaks[0] - 1]["type"] == "span"
