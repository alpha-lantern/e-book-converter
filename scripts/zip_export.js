import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

/**
 * Project Codex: Zip Export Script
 * This script injects a book.json file into the build output and creates a zip archive.
 */

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const bookJsonPath = process.argv[2];

if (!bookJsonPath) {
  console.error('Usage: node scripts/zip_export.js <path_to_book_json>');
  process.exit(1);
}

const readerDir = path.join(__dirname, '..', 'reader');
const distDir = path.join(readerDir, 'dist');
const targetBookJsonPath = path.join(distDir, 'data', 'book.json');
const zipFilePath = path.resolve(path.join(__dirname, '..', 'book_export.zip'));

function run() {
  console.log('--- Starting Zip Export Process ---');

  try {
    // 1. Validate dist directory
    if (!fs.existsSync(distDir)) {
      throw new Error(`Error: dist directory not found at ${distDir}. Run build_export.js first.`);
    }

    // 2. Ensure data directory exists in dist
    const distDataDir = path.join(distDir, 'data');
    if (!fs.existsSync(distDataDir)) {
      console.log(`Creating directory: ${distDataDir}`);
      fs.mkdirSync(distDataDir, { recursive: true });
    }

    // 3. Inject book.json
    console.log(`Injecting ${bookJsonPath} into ${targetBookJsonPath}...`);
    if (!fs.existsSync(bookJsonPath)) {
        throw new Error(`Error: Source book.json not found at ${bookJsonPath}`);
    }
    fs.copyFileSync(bookJsonPath, targetBookJsonPath);

    // 4. Create zip archive
    console.log(`Creating archive: ${zipFilePath}...`);
    // Remove existing zip if it exists
    if (fs.existsSync(zipFilePath)) {
      fs.unlinkSync(zipFilePath);
    }

    // Zip contents of distDir.
    // -r: recursive
    // We use cd to distDir so paths in zip are relative to dist
    // We use path.resolve for zipFilePath to ensure it's absolute since we're changing CWD
    execSync(`cd "${distDir}" && zip -r "${zipFilePath}" .`, { stdio: 'inherit' });

    console.log('--- Zip Export Successful ---');
    console.log(`Archive created at: ${zipFilePath}`);
  } catch (error) {
    console.error('--- Zip Export Failed ---');
    console.error(error.message);
    process.exit(1);
  }
}

run();
