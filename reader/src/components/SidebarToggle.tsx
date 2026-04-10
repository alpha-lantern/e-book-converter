import React from 'react';
import { useStore } from '@nanostores/react';
import { $isSidebarOpen } from '../stores/codexStore';
import { Menu } from 'lucide-react';

/**
 * SidebarToggle component.
 * Toggles the visibility of the sidebar using the $isSidebarOpen Nano Store.
 * This is an Astro island hydrated with React.
 */
export const SidebarToggle: React.FC = () => {
  const isOpen = useStore($isSidebarOpen);

  return (
    <button
      onClick={() => $isSidebarOpen.set(!isOpen)}
      className="p-2 rounded-md hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors cursor-pointer"
      aria-label={isOpen ? 'Close sidebar' : 'Open sidebar'}
    >
      <Menu className="w-6 h-6" />
    </button>
  );
};

export default SidebarToggle;
