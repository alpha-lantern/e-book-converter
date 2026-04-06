import { atom } from 'nanostores';

/**
 * Global UI state for the Reader application.
 * Using Nano Stores for lightweight, framework-agnostic state management.
 */

// Theme state: 'light' or 'dark'
export const $theme = atom<'light' | 'dark'>('light');

// Reading progress: 0 to 100 representing percentage
export const $readingProgress = atom<number>(0);

// Current page number (if applicable)
export const $currentPage = atom<number>(1);

// Sidebar visibility state
export const $isSidebarOpen = atom<boolean>(false);
