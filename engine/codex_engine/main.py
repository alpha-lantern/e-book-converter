import json
from pathlib import Path
from typing import Optional
import typer
from rich.console import Console

from .extractor import stream_text_with_metadata
from .heuristics import calculate_base_size, cluster_spans_by_y, classify_block
from .models import CodexManifest, CodexMeta, CodexSEO

app = typer.Typer(help="Project Codex: PDF to JSON Semantic Parser")
console = Console()

@app.command()
def parse(
    pdf_path: Path = typer.Argument(..., help="Path to the source PDF file", exists=True, dir_okay=False, readable=True),
    output: Optional[Path] = typer.Option(None, "--output", "-o", help="Path to save the generated JSON manifest"),
    pretty: bool = typer.Option(False, "--pretty", help="Pretty-print the JSON output"),
):
    """
    Parses a PDF file and generates a semantic Codex JSON manifest.
    """
    if not pdf_path.exists():
        console.print(f"[red]Error:[/red] File {pdf_path} does not exist.")
        raise typer.Exit(code=1)

    console.print(f"[blue]Processing:[/blue] {pdf_path.name}")

    # 1. First pass: Calculate Base Size for the document
    # We consume the generator to collect all spans for base_size calculation
    # and subsequent clustering. 
    # NOTE: For extremely large documents, we might want to do this per-page,
    # but base_size is usually document-wide for consistency.
    all_spans = []
    metadata = {"title": "", "author": ""}
    
    with console.status("[bold green]Extracting text and calculating base font size..."):
        for chunk in stream_text_with_metadata(str(pdf_path)):
            if chunk["type"] == "metadata":
                metadata = chunk["data"]
            elif chunk["type"] == "span":
                all_spans.append(chunk["data"])

    if not all_spans:
        console.print("[yellow]Warning:[/yellow] No text content found in PDF.")
        base_size = 12.0
    else:
        base_size = calculate_base_size(all_spans)
    
    console.print(f"[green]Base font size detected:[/green] {base_size}pt")

    # 2. Second pass: Cluster spans and classify blocks
    blocks = []
    with console.status("[bold green]Classifying semantic blocks..."):
        # We cluster all spans together for simplicity in MVP, 
        # though clustering per page is more robust for complex layouts.
        lines = cluster_spans_by_y(all_spans)
        for line in lines:
            try:
                block = classify_block(line, base_size)
                blocks.append(block)
            except ValueError as e:
                # Skip empty lines or malformed content
                continue

    # 3. Assemble the Manifest
    manifest = CodexManifest(
        meta=CodexMeta(
            title=metadata.get("title") or pdf_path.stem.replace("_", " ").title(),
            author=metadata.get("author") or "Unknown Author",
            base_size=base_size,
            seo=CodexSEO(
                title=metadata.get("title"),
                description=f"Digitized version of {pdf_path.name}"
            )
        ),
        blocks=blocks,
        assets={}
    )

    # 4. Export
    json_data = manifest.model_dump(mode='json')
    
    if output:
        with open(output, "w", encoding="utf-8") as f:
            json.dump(json_data, f, indent=4 if pretty else None)
        console.print(f"[bold green]Success![/bold green] Manifest saved to {output}")
    else:
        # Print to stdout
        console.print_json(data=json_data)

if __name__ == "__main__":
    app()
