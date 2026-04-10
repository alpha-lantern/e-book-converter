import React, { useEffect } from 'react';
import { useStore } from '@nanostores/react';
import { $isSidebarOpen, $currentPage } from '../stores/codexStore';
import { X } from 'lucide-react';

interface Chapter {
  title: string;
  page: number;
}

interface SidebarProps {
  chapters: Chapter[];
}

/**
 * Sidebar component.
 * Displays a table of contents and subscribes to $isSidebarOpen.
 * Closes automatically when $currentPage changes.
 */
export const Sidebar: React.FC<SidebarProps> = ({ chapters }) => {
  const isOpen = useStore($isSidebarOpen);
  const currentPage = useStore($currentPage);

  // Close sidebar when page changes
  useEffect(() => {
    $isSidebarOpen.set(false);
  }, [currentPage]);

  return (
    <>
      {/* Overlay */}
      <div
        className={`fixed inset-0 bg-black/50 z-40 transition-opacity duration-300 ${
          isOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'
        }`}
        onClick={() => $isSidebarOpen.set(false)}
      />

      {/* Sidebar Panel */}
      <aside
        className={`fixed inset-y-0 left-0 w-64 bg-white dark:bg-gray-900 shadow-xl z-50 transform transition-transform duration-300 ease-in-out p-4 border-r border-gray-200 dark:border-gray-800 ${
          isOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-bold">Table of Contents</h2>
          <button
            onClick={() => $isSidebarOpen.set(false)}
            className="p-1 rounded-md hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors cursor-pointer"
            aria-label="Close sidebar"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
        <nav>
          <ul className="space-y-1">
            {chapters.map((chapter, index) => (
              <li key={index}>
                <button
                  onClick={() => {
                    $currentPage.set(chapter.page);
                  }}
                  className={`w-full text-left px-3 py-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded transition-colors flex justify-between items-center ${
                    currentPage === chapter.page ? 'font-bold bg-gray-50 dark:bg-gray-800 text-blue-600 dark:text-blue-400' : ''
                  }`}
                >
                  <span className="truncate mr-2">{chapter.title}</span>
                  <span className="text-gray-500 text-xs flex-shrink-0">p. {chapter.page}</span>
                </button>
              </li>
            ))}
          </ul>
        </nav>
      </aside>
    </>
  );
};

export default Sidebar;
