import os
import sys
import tempfile
import traceback
import requests
import typer
from supabase import create_client, Client
from codex_engine.extractor import stream_text_with_metadata
from codex_engine.heuristics import calculate_base_size, cluster_spans_by_y, classify_block
from codex_engine.models import CodexManifest, CodexMeta, CodexSEO

app = typer.Typer()

def download_pdf(url: str, dest_path: str):
    """Downloads a PDF from a URL to a local destination."""
    response = requests.get(url, stream=True, timeout=30)
    response.raise_for_status()
    with open(dest_path, "wb") as f:
        for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)

@app.command()
def main(
    input_url: str = typer.Argument(..., help="Public URL of the PDF to parse."),
    book_id: str = typer.Argument(..., help="UUID of the book in the database.")
):
    """
    Backend Parser Entry Point.
    Downloads PDF, extracts semantic blocks, and updates Supabase.
    """
    supabase_url = os.environ.get("NEXT_PUBLIC_SUPABASE_URL")
    supabase_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")

    if not supabase_url or not supabase_key:
        typer.echo("Error: NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set.", err=True)
        raise typer.Exit(code=1)

    supabase: Client = create_client(supabase_url, supabase_key)

    # 1. Update status to processing
    try:
        supabase.table("books").update({"status": "processing", "error_log": None}).eq("id", book_id).execute()
    except Exception as e:
        typer.echo(f"Failed to update book status to processing: {e}", err=True)
        # We continue anyway, or exit? Better exit if we can't even talk to DB.
        raise typer.Exit(code=1)

    # Use delete=False for cross-platform compatibility with functions that open the file by path
    fd, temp_path = tempfile.mkstemp(suffix=".pdf")
    os.close(fd)

    try:
        # 2. Download PDF
        typer.echo(f"Downloading PDF from {input_url}...")
        download_pdf(input_url, temp_path)

        # 3. Parse PDF (Two-Pass)
        typer.echo("Parsing PDF...")

        # Pass 1: BaseSize
        stream = stream_text_with_metadata(temp_path)
        try:
            first_chunk = next(stream)
        except StopIteration:
            typer.echo("Error: PDF stream is empty or could not be read.", err=True)
            raise typer.Exit(code=1)
        doc_meta = first_chunk["data"]

        span_generator = (chunk["data"] for chunk in stream if chunk["type"] == "span")
        base_size = calculate_base_size(span_generator)

        # Pass 2: Blocks
        blocks = []
        current_page_spans = []
        stream = stream_text_with_metadata(temp_path)
        try:
            next(stream) # Skip metadata
        except StopIteration:
            typer.echo("Error: PDF stream is empty on second pass.", err=True)
            raise typer.Exit(code=1)

        for chunk in stream:
            if chunk["type"] == "span":
                current_page_spans.append(chunk["data"])
            elif chunk["type"] == "page_break":
                if current_page_spans:
                    page_lines = cluster_spans_by_y(current_page_spans)
                    for line in page_lines:
                        blocks.append(classify_block(line, base_size))
                    current_page_spans = []

        if current_page_spans:
            page_lines = cluster_spans_by_y(current_page_spans)
            for line in page_lines:
                blocks.append(classify_block(line, base_size))

        # 4. Construct Manifest
        manifest = CodexManifest(
            meta=CodexMeta(
                title=doc_meta.get("title") or "Untitled",
                author=doc_meta.get("author") or "Unknown",
                base_size=base_size,
                seo=CodexSEO(title=doc_meta.get("title"))
            ),
            blocks=blocks
        )

        # 5. Upsert Manifest and Update Status
        typer.echo("Saving manifest to database...")
        manifest_dict = manifest.model_dump(mode="json")

        supabase.table("codex_manifests").upsert({
            "book_id": book_id,
            "manifest_data": manifest_dict,
            "parser_version": "0.1.0"
        }).execute()

        supabase.table("books").update({
            "status": "completed"
        }).eq("id", book_id).execute()

        typer.echo("Parsing completed successfully.")

    except Exception as e:
        error_msg = f"Error during parsing: {e}\n{traceback.format_exc()}"
        typer.echo(error_msg, err=True)
        try:
            supabase.table("books").update({
                "status": "failed",
                "error_log": error_msg
            }).eq("id", book_id).execute()
        except Exception as db_e:
            typer.echo(f"Failed to log error to database: {db_e}", err=True)
        raise typer.Exit(code=1)
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)

if __name__ == "__main__":
    app()
