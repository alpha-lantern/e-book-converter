import os
import json
import sys
import httpx
from typing import Dict, Any

def sync_manifest(book_id: str, manifest_path: str):
    """
    Syncs the local Codex JSON manifest to the Supabase database.
    """
    supabase_url = os.environ.get("NEXT_PUBLIC_SUPABASE_URL")
    supabase_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")

    if not supabase_url or not supabase_key:
        print("Error: NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set.")
        sys.exit(1)

    if not os.path.exists(manifest_path):
        print(f"Error: Manifest file not found at {manifest_path}")
        sys.exit(1)

    with open(manifest_path, "r", encoding="utf-8") as f:
        manifest_data = json.load(f)

    # PostgREST URL for upserting into codex_manifests
    url = f"{supabase_url}/rest/v1/codex_manifests"
    
    headers = {
        "apikey": supabase_key,
        "Authorization": f"Bearer {supabase_key}",
        "Content-Type": "application/json",
        "Prefer": "resolution=merge-duplicates"
    }

    payload = {
        "book_id": book_id,
        "manifest_data": manifest_data,
        "parser_version": "0.1.0"
    }

    print(f"Syncing manifest for book {book_id} to {url}...")
    
    try:
        with httpx.Client(timeout=30.0) as client:
            # 1. Update status to 'completed' in books table
            status_url = f"{supabase_url}/rest/v1/books?id=eq.{book_id}"
            client.patch(status_url, headers=headers, json={"status": "completed"})

            # 2. Upsert the manifest
            response = client.post(url, headers=headers, json=payload)
            response.raise_for_status()
            
            print("Sync successful.")
    except httpx.HTTPStatusError as e:
        print(f"HTTP Error: {e.response.status_code} - {e.response.text}")
        # Update status to 'failed' if possible
        try:
            with httpx.Client() as client:
                client.patch(status_url, headers=headers, json={"status": "failed", "error_log": e.response.text})
        except Exception:
            pass
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python scripts/sync_manifest.py <book_id> <manifest_path>")
        sys.exit(1)
    
    sync_manifest(sys.argv[1], sys.argv[2])
