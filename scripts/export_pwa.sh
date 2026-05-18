#!/bin/bash

# Project Codex: PWA Export Orchestrator
# This script coordinates the Astro build and the PWA packaging process.

set -e

BOOK_JSON_PATH=$1

if [ -z "$BOOK_JSON_PATH" ]; then
    echo "Usage: ./scripts/export_pwa.sh <path_to_book_json>"
    exit 1
fi

echo "--- Starting PWA Export Orchestration ---"

# 1. Build the Astro Renderer
echo "[1/2] Building Astro Renderer..."
node scripts/build_export.js

# 2. Package into PWA Zip
echo "[2/2] Packaging PWA Zip with $BOOK_JSON_PATH..."
node scripts/zip_export.js "$BOOK_JSON_PATH"

echo "--- Export Orchestration Complete ---"
echo "Your PWA package is ready: book_export.zip"
