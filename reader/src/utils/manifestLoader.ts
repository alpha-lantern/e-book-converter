import type { CodexManifest, CodexBlockType } from '../types/codex';

const VALID_BLOCK_TYPES: CodexBlockType[] = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'image', 'widget'];

/**
 * Validates a manifest object at runtime.
 * Throws an error if the manifest is invalid.
 */
export function validateManifest(data: any): asserts data is CodexManifest {
  if (!data || typeof data !== 'object') {
    throw new Error('Manifest must be an object');
  }

  if (typeof data.version !== 'string') {
    throw new Error('Manifest must have a string version');
  }

  if (!data.meta || typeof data.meta !== 'object') {
    throw new Error('Manifest must have a meta object');
  }

  if (typeof data.meta.title !== 'string') {
    throw new Error('Manifest meta must have a string title');
  }

  if (data.meta.description !== undefined && data.meta.description !== null && typeof data.meta.description !== 'string') {
    throw new Error('Manifest meta description must be a string if provided');
  }

  if (!Array.isArray(data.meta.chapters)) {
    throw new Error('Manifest meta chapters must be an array');
  }

  if (!Array.isArray(data.blocks)) {
    throw new Error('Manifest blocks must be an array');
  }

  for (let i = 0; i < data.blocks.length; i++) {
    const block = data.blocks[i];
    if (!block || typeof block !== 'object') {
      throw new Error(`Block at index ${i} must be an object`);
    }
    if (typeof block.page !== 'number') {
      throw new Error(`Block at index ${i} must have a page number`);
    }
    if (!VALID_BLOCK_TYPES.includes(block.type)) {
      throw new Error(`Invalid block type at index ${i}: ${block.type}`);
    }
  }
}

/**
 * Loads a Codex manifest from a string URL, URL object, or an existing object.
 * Returns a fully-typed CodexManifest.
 */
export async function loadManifest(source: string | URL | object): Promise<CodexManifest> {
  let data: any;

  if (typeof source === 'string' || source instanceof URL) {
    const response = await fetch(source);
    if (!response.ok) {
      throw new Error(`Failed to load manifest from ${source.toString()}: ${response.statusText}`);
    }
    data = await response.json();
  } else {
    data = source;
  }

  validateManifest(data);
  return data as CodexManifest;
}
