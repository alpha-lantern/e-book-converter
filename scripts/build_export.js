import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

/**
 * Project Codex: Build Export Script
 * This script automates the Astro build process and validates the output.
 */

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function run() {
  const readerDir = path.join(__dirname, '..', 'reader');
  const distDir = path.join(readerDir, 'dist');

  console.log('--- Starting Build Export Process ---');

  try {
    // 1. Run npm install
    console.log('Executing: npm install in reader/ directory...');
    // Using --legacy-peer-deps due to Astro 6 vs @vite-pwa/astro conflict
    execSync('npm install --legacy-peer-deps', { cwd: readerDir, stdio: 'inherit' });

    // 2. Run npm run build (Astro)
    console.log('Executing: npm run build...');
    execSync('npm run build', { cwd: readerDir, stdio: 'inherit' });

    // 3. Validate dist/ directory existence and key files
    console.log('Validating build artifacts...');
    if (!fs.existsSync(distDir)) {
      throw new Error(`Validation Failed: dist/ directory not found at ${distDir}`);
    }

    const indexFile = path.join(distDir, 'index.html');
    if (!fs.existsSync(indexFile)) {
      throw new Error(`Validation Failed: index.html not found at ${indexFile}`);
    }

    console.log('--- Build Export Successful ---');
    console.log(`Artifacts available in: ${distDir}`);
  } catch (error) {
    console.error('--- Build Export Failed ---');
    console.error(error);
    process.exit(1);
  }
}

run();
