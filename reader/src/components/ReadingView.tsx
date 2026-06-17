import React, { useMemo, useEffect } from 'react';
import { useStore } from '@nanostores/react';
import { $currentPage } from '../stores/codexStore';
import type { CodexBlock, CodexChapter } from '../types/codex';

interface ReadingViewProps {
  blocks: CodexBlock[];
  chapters: CodexChapter[];
}

const parseMarkdown = (text: string | undefined) => {
  if (!text) return { __html: '' };
  
  let html = text.replace(/\*\*\*(.+?)\*\*\*/g, '<strong><em>$1</em></strong>');
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
  html = html.replace(/\*(.+?)\*/g, '<em>$1</em>');
  
  return { __html: html };
};

/**
 * ReadingView Component
 * Implements "Logical Sectioning" by grouping blocks into unified chapters.
 * This prevents headers from being separated from their content across PDF pages.
 */
export const ReadingView: React.FC<ReadingViewProps> = ({ blocks, chapters }) => {
  const currentPage = useStore($currentPage);

  // 1. Group blocks into logical sections based on the Table of Contents
  const sections = useMemo(() => {
    if (chapters.length === 0) return [blocks];

    const groups: CodexBlock[][] = [];
    let currentGroup: CodexBlock[] = [];
    
    // Create a set of chapter start markers (Title + Type)
    const chapterMarkers = new Set(chapters.map(c => `${c.title.trim()}`));

    blocks.forEach((block) => {
      const isChapterStart = (block.type === 'h1' || block.type === 'h2') && 
                             chapterMarkers.has(block.content?.trim() || '');

      if (isChapterStart && currentGroup.length > 0) {
        groups.push(currentGroup);
        currentGroup = [block];
      } else {
        currentGroup.push(block);
      }
    });

    if (currentGroup.length > 0) groups.push(currentGroup);
    return groups;
  }, [blocks, chapters]);

  // Ensure we don't overflow
  const activeIndex = Math.max(0, Math.min(currentPage - 1, sections.length - 1));
  const activeBlocks = sections[activeIndex] || [];

  // Scroll to top on section change
  useEffect(() => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }, [currentPage]);

  return (
    <div className="codex-reading-view min-h-[70vh] animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="space-y-10">
        {activeBlocks.map((block) => (
          <div key={block.id} className="block-content">
             {block.type === 'h1' && (
               <h1 
                 className="text-4xl font-bold tracking-tight text-text-main leading-tight"
                 dangerouslySetInnerHTML={parseMarkdown(block.content)}
               />
             )}
             {block.type === 'h2' && (
               <h2 
                 className="text-2xl font-bold tracking-tight text-text-main border-b border-border-main pb-2"
                 dangerouslySetInnerHTML={parseMarkdown(block.content)}
               />
             )}
             {(block.type === 'h3' || block.type === 'h4' || block.type === 'h5' || block.type === 'h6') && (
               <h3 
                 className="text-xl font-semibold text-text-main"
                 dangerouslySetInnerHTML={parseMarkdown(block.content)}
               />
             )}
             {block.type === 'p' && (
               <p 
                 className="text-lg leading-relaxed text-text-muted whitespace-pre-wrap"
                 dangerouslySetInnerHTML={parseMarkdown(block.content)}
               />
             )}
             {block.type === 'image' && (
               <figure className="my-8">
                 <img 
                   src={typeof block.src === 'string' ? block.src : (block.src as any)?.src} 
                   alt={block.alt || 'Book image'} 
                   className="rounded-2xl shadow-2xl w-full border border-border-main"
                 />
                 {block.alt && (
                   <figcaption className="mt-3 text-center text-sm text-text-muted italic">
                     {block.alt}
                   </figcaption>
                 )}
               </figure>
             )}
          </div>
        ))}
      </div>
      
      {activeBlocks.length === 0 && (
        <div className="py-20 text-center text-gray-500">
          No content found for this section.
        </div>
      )}
    </div>
  );
};

export default ReadingView;
