import { atom } from 'nanostores';
import type { ReadableAtom } from 'nanostores';

/**
 * Global UI state for the Reader application.
 * Using Nano Stores for lightweight, framework-agnostic state management.
 */

// --- Theme ---

const prefersDark =
  typeof window !== 'undefined' &&
  window.matchMedia('(prefers-color-scheme: dark)').matches;

/** Theme state: 'light' or 'dark'. Initialized from system preference if available. */
export const $theme = atom<'light' | 'dark'>(prefersDark ? 'dark' : 'light');

// --- Reading Progress ---

// Private — not exported
const _readingProgress = atom<number>(0);

/** Reading progress percentage (0–100). Read-only externally; write via setReadingProgress(). */
export const $readingProgress: ReadableAtom<number> = _readingProgress;

/**
 * Sets the reading progress, clamping the value to the range [0, 100].
 * @param value - The new progress value. Values outside [0, 100] are clamped.
 */
export function setReadingProgress(value: number): void {
  _readingProgress.set(Math.max(0, Math.min(100, value)));
}

// --- Navigation & Layout ---

/**
 * Current page number (1-indexed).
 * Shared across separate Astro islands (reading view and navigation controls)
 * that cannot share state via useState across React root boundaries.
 * @see Issue #44 — Reader: Build Page Navigation Island
 */
export const $currentPage = atom<number>(1);

/**
 * Sidebar open/closed state.
 * Shared between the SidebarToggle island (header) and the Sidebar island (content area),
 * which are separate React roots and cannot share state via useState.
 * @see Issue #45 — Reader: Build Sidebar Island
 */
export const $isSidebarOpen = atom<boolean>(false);

// --- PWA ---

/**
 * PWA registration state.
 */
export const $pwaStatus = atom<'registered' | 'unregistered' | 'error'>('unregistered');
