import React from 'react';
import { useStore } from '@nanostores/react';
import { $currentPage } from '../stores/codexStore';
import { ChevronLeft, ChevronRight } from 'lucide-react';

interface NavigationControlsProps {
  totalPages: number;
}

/**
 * NavigationControls component.
 * Provides previous/next page buttons and displays current progress.
 * Synchronized via the $currentPage Nano Store.
 */
export const NavigationControls: React.FC<NavigationControlsProps> = ({ totalPages }) => {
  const currentPage = useStore($currentPage);

  const goToPrev = () => {
    if (currentPage > 1) {
      $currentPage.set(currentPage - 1);
    }
  };

  const goToNext = () => {
    if (currentPage < totalPages) {
      $currentPage.set(currentPage + 1);
    }
  };

  return (
    <div className="flex items-center gap-2 sm:gap-4 bg-white dark:bg-gray-900 px-2 py-1 sm:px-4 sm:py-2 rounded-lg border border-gray-200 dark:border-gray-800 shadow-sm">
      <button
        onClick={goToPrev}
        disabled={currentPage <= 1}
        className="p-1 rounded-md hover:bg-gray-100 dark:hover:bg-gray-800 disabled:opacity-30 disabled:cursor-not-allowed transition-colors cursor-pointer"
        aria-label="Previous page"
      >
        <ChevronLeft className="w-5 h-5" />
      </button>

      <div className="text-xs sm:text-sm font-medium min-w-[4rem] sm:min-w-[5rem] text-center">
        <span className="hidden sm:inline">Page </span>
        <span className="text-blue-600 dark:text-blue-400">{currentPage}</span>
        <span className="mx-1">/</span>
        <span>{totalPages}</span>
      </div>

      <button
        onClick={goToNext}
        disabled={currentPage >= totalPages}
        className="p-1 rounded-md hover:bg-gray-100 dark:hover:bg-gray-800 disabled:opacity-30 disabled:cursor-not-allowed transition-colors cursor-pointer"
        aria-label="Next page"
      >
        <ChevronRight className="w-5 h-5" />
      </button>
    </div>
  );
};

export default NavigationControls;
