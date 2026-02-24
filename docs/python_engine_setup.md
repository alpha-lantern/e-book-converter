# Python Engine Setup & Development Guide

This document outlines the setup, testing, and development workflows for the **Project Codex Semantic Parser Engine**.

## 1. Prerequisites

- **Python**: Version 3.12 or higher.
- **Poetry**: Dependency management and packaging tool.
  - Install via pipx: `pipx install poetry`
  - Or see [official docs](https://python-poetry.org/docs/#installation).

## 2. Installation

Navigate to the `engine/` directory and install dependencies:

```bash
cd engine
poetry install
```

This command installs both runtime dependencies (like `pymupdf`, `pdfplumber`, `typer`) and development dependencies (like `pytest`, `black`, `pylint`) into a virtual environment.

## 3. Project Structure

```
engine/
├── codex_engine/       # Source code for the parser
│   ├── __init__.py     # Exports public models/functions
│   ├── extractor.py    # PDF text extraction layer (PyMuPDF-based)
│   └── models.py       # Pydantic data models (CodexBlock, CodexStyle, CodexManifest)
├── tests/              # Test suite
│   ├── __init__.py
│   ├── test_extractor.py # Tests for the PDF extraction layer
│   ├── test_models.py  # Unit tests for data models
│   └── test_setup.py   # Basic environment verification
├── pyproject.toml      # Poetry configuration & dependency definitions
├── poetry.lock         # Locked dependency versions
└── requirements.txt    # Exported dependencies for non-Poetry environments
```

## 4. Development Workflow

### Running Tests

Execute the test suite using `pytest`:

```bash
cd engine
poetry run pytest
```

### Linting & Formatting

We use **Black** for code formatting and **Pylint** for linting.

**Check Formatting:**
```bash
poetry run black codex_engine tests
```

**Apply Formatting:**
```bash
poetry run black codex_engine tests
```

**Run Linter:**
```bash
poetry run pylint codex_engine tests
```

### Dependency Management

- **Add a library:** `poetry add <library-name>`
- **Add a dev tool:** `poetry add --group dev <tool-name>`
- **Export requirements.txt:**
  ```bash
  poetry export -f requirements.txt --output requirements.txt --without-hashes
  ```