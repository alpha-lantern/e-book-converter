# Codex Specification

This document defines the semantic data structure of a **Codex Manifest**, the core output of the Project Codex Semantic Parser.

## 1. Overview

A Codex Manifest is a JSON-serializable structure that represents the structured content of a book. It is designed for high-performance rendering and efficient synthesis in the frontend.

## 2. Core Models

### `CodexManifest`
The root container for a document.

| Property | Type | Description |
| :--- | :--- | :--- |
| `meta` | `CodexMeta` | Document metadata (title, author, etc). |
| `blocks` | `List[CodexBlock]` | Ordered sequence of content blocks. |
| `assets` | `Dict` | Mapping of asset names to their optimized URLs or identifiers. |
| `block_map` | `Dict[UUID, CodexBlock]` | **(Optimization)** Computed mapping of block IDs for O(1) lookups. |

### `CodexMeta`
The document-level metadata container.

| Property | Type | Description |
| :--- | :--- | :--- |
| `title` | `str` | The display title of the book. |
| `author` | `str` | The credited author. |
| `description`| `str` | Internal/Technical summary. |
| `base_size` | `int` | Reference font size for heuristic scoring. |
| `seo` | `CodexSEO` | Nested SEO optimization fields. |

### `CodexSEO`
Crawler-specific metadata.

| Property | Type | Description |
| :--- | :--- | :--- |
| `title` | `str` | SEO Title (max 60 chars). |
| `description`| `str` | Meta description (max 160 chars). |
| `keywords` | `List[str]` | Semantic tags for indexing. |

### `CodexBlock`
The atomic unit of content.

| Property | Type | Description |
| :--- | :--- | :--- |
| `id` | `UUID` | Unique identifier (V4). |
| `type` | `CodexBlockType` | Enum: `h1`, `h2`, `p`, `image`, `widget`. |
| `content` | `str` | The raw text or asset reference. |
| `style` | `CodexStyle` | Specialized style model. |
| `bbox` | `CodexBBox` | Physical coordinates `(x0, y0, x1, y1)`. |

### `CodexStyle`
A specialized model for CSS-like attributes to minimize memory footprint.

- `font_size`: float (points/pixels)
- `font_weight`: string (e.g., "bold", "normal")
- `line_height`: float
- `color`: string (hex/rgba)
- `text_align`: string ("left", "center", "right", "justify")
- `margin_top` / `margin_bottom`: float
- `font_family`: string
- `text_decoration`: string
- `font_style`: string

## 3. Data Extraction Pipeline

### Streaming Extraction
To handle large PDF files without memory exhaustion, the engine uses a **generator-based extraction layer** (`extractor.py`).

1. **Metadata Yield**: The stream starts by yielding the PDF's internal metadata (Title, Author).
2. **Span Yielding**: Individual text spans are transformed into the internal Codex format and yielded page-by-page.
3. **Lazy Processing**: This allows the semantic parser to begin processing the first pages before the entire document is loaded into memory.

## 4. Performance Optimizations

### O(1) Block Lookups
The `CodexManifest` includes a `block_map` property (implemented via Pydantic `@computed_field`). This avoids O(N) list traversals when the renderer needs to access a specific block by its UUID (e.g., when resolving widget anchors).

### Memory Efficiency
Styles are enforced via the `CodexStyle` model rather than arbitrary dictionaries. This provides:
1. **Type Safety**: Validation happens at the parser level.
2. **Reduced Footprint**: Pre-defined slots in the model are more memory-efficient than dynamic hash maps for thousands of blocks.
