# Testing Guide: Project Codex Pipeline

This guide provides step-by-step instructions to test the different components of the PDF-to-PWA pipeline. The commands are formatted for easy copy-pasting.

## 1. The Semantic Parser (Python Engine)
To test the conversion of a raw PDF into the Codex JSON manifest, you need to set up the environment and run the parser orchestration.

**Step 1: Set up the Python virtual environment and install dependencies**
```bash
python3 -m venv venv && source venv/bin/activate && pip install -r engine/requirements.txt
```

**Step 2: Run the parser orchestration against a test PDF**
*(Replace `<path_to_your_pdf>` with the actual path to a PDF file)*
```bash
export PYTHONPATH=$PYTHONPATH:$(pwd)/engine && python3 -m codex_engine.main <path_to_your_pdf> --output manifest.json --pretty
```

## 2. The Reader Renderer (Astro)
To view how the generated manifest renders in the "Islands Architecture" reader, you need to copy the generated manifest into the reader's fixtures directory and start the dev server.

**Step 1: Install Node.js dependencies for the reader**
*(Note: We use --legacy-peer-deps because Astro 6 is newer than the current @vite-pwa/astro peer dependency range)*
```bash
cd reader && npm install --legacy-peer-deps
```

**Step 2: Copy your generated manifest and start the development server**
```bash
cp ../manifest.json src/fixtures/mock_manifest.json && npm run dev
```
*Once running, open `http://localhost:4321` in your browser.*

## 3. The Admin Dashboard (Flutter)
To launch the management interface for uploading and editing books. You will need Flutter installed on your machine.

**Step 1: Install dependencies and generate required code**
*(The admin app uses Riverpod, which requires code generation for its providers. This must be run before starting the app).*
```bash
cd admin && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 2: Load environment variables and run the Flutter app**
*(This command reads your `.env` file to pass the required keys to Flutter)*
```bash
export $(grep -v '^#' ../.env | xargs) && flutter run -d chrome --dart-define=NEXT_PUBLIC_SUPABASE_URL=$NEXT_PUBLIC_SUPABASE_URL --dart-define=NEXT_PUBLIC_SUPABASE_ANON_KEY=$NEXT_PUBLIC_SUPABASE_ANON_KEY
```

## 4. End-to-End PWA Export
To verify the full distribution pipeline which builds the Astro site, injects the specified JSON manifest, and zips the output into a downloadable PWA package.

**Step 1: Make the orchestrator script executable and run the export process**
```bash
chmod +x scripts/export_pwa.sh && ./scripts/export_pwa.sh manifest.json
```
*This will generate a `book_export.zip` file in the project root directory.*

---

## 5. Streamlined Dev CLI Orchestrator (`./dev`)

For a faster workflow without manual venv activations or complex command flags, you can use the unified `./dev` CLI script at the project root:

| Command | Description |
| :--- | :--- |
| `./dev parse <pdf_path> [output.json]` | Parses a PDF into a Codex JSON manifest automatically. |
| `./dev reader` | Launches the Astro Reader preview dev server. |
| `./dev admin` | Launches Flutter Admin Web in fast release mode with `.env` keys. |
| `./dev export <manifest.json>` | Packages the reader and manifest into a zip bundle. |
| `./dev test` | Runs unit test suites across Python & Flutter. |
| `./dev help` | Displays available commands and options. |

