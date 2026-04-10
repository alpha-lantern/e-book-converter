import React from 'react';
import { useStore } from '@nanostores/react';
import { $currentPage } from '../stores/codexStore';

/**
 * ReadingContent component.
 * A temporary interactive island to verify $currentPage synchronization.
 * In a real application, this would render the actual Codex blocks for the current page.
 */
export const ReadingContent: React.FC = () => {
  const currentPage = useStore($currentPage);

  return (
    <div className="space-y-6">
      <h2 className="text-3xl font-extrabold tracking-tight lg:text-4xl">Sample Document</h2>
      <p className="text-lg text-gray-600 dark:text-gray-400 leading-relaxed">
        This is a sample page to demonstrate the Sidebar, SidebarToggle, and NavigationControls islands.
        Use the controls in the header or the sidebar to navigate.
      </p>
      <div className="p-12 border-2 border-dashed border-blue-200 dark:border-blue-900 rounded-xl text-center bg-blue-50/30 dark:bg-blue-950/10">
        <p className="text-blue-500 font-medium mb-2">Reading content area (Island)</p>
        <p className="text-4xl font-bold text-blue-600 dark:text-blue-400">Page {currentPage}</p>
      </div>
    </div>
  );
};

export default ReadingContent;
