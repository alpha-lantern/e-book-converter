import React, { useEffect, useState } from 'react';
import type { CodexManifest } from '../types/codex';
import { SidebarToggle } from './SidebarToggle';
import { Sidebar } from './Sidebar';
import { NavigationControls } from './NavigationControls';
import ReadingView from './ReadingView';
import { Loader2, AlertCircle, BookOpen } from 'lucide-react';

interface DynamicReaderProps {
  initialManifest?: CodexManifest;
  supabaseUrl?: string;
  supabaseAnonKey?: string;
}

export const DynamicReader: React.FC<DynamicReaderProps> = ({
  initialManifest,
  supabaseUrl = 'https://nlucbgajcftcnzjqcavn.supabase.co',
  supabaseAnonKey = 'sb_publishable_ONmVzK26KPvSfs8pAny2cQ_RyT6rofG',
}) => {
  const [manifest, setManifest] = useState<CodexManifest | null>(initialManifest || null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [isDynamicPreview, setIsDynamicPreview] = useState<boolean>(false);

  useEffect(() => {
    if (typeof window === 'undefined') return;

    const params = new URLSearchParams(window.location.search);
    const bookId = params.get('book_id') || params.get('id');

    if (!bookId) {
      if (!initialManifest) {
        setError('No book ID specified. Please access this preview from the Admin Dashboard.');
      }
      return;
    }

    setIsDynamicPreview(true);
    setLoading(true);
    setError(null);

    const fetchManifest = async () => {
      try {
        const endpoint = `${supabaseUrl}/rest/v1/codex_manifests?book_id=eq.${bookId}&select=manifest_data`;
        const res = await fetch(endpoint, {
          headers: {
            apikey: supabaseAnonKey,
            Authorization: `Bearer ${supabaseAnonKey}`,
          },
        });

        if (!res.ok) {
          throw new Error(`Failed to fetch manifest: ${res.statusText} (${res.status})`);
        }

        const data = await res.json();
        if (!data || data.length === 0 || !data[0].manifest_data) {
          throw new Error('Manifest not found for this book ID. It may still be processing.');
        }

        setManifest(data[0].manifest_data as CodexManifest);
      } catch (err: any) {
        setError(err.message || 'Error loading manifest from Supabase');
      } finally {
        setLoading(false);
      }
    };

    fetchManifest();
  }, [supabaseUrl, supabaseAnonKey]);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] gap-4">
        <Loader2 className="w-10 h-10 animate-spin text-blue-600" />
        <p className="text-gray-600 dark:text-gray-400 font-medium">Loading book preview...</p>
      </div>
    );
  }

  if (error || !manifest) {
    return (
      <div className="max-w-xl mx-auto my-16 p-6 bg-white dark:bg-gray-900 border border-red-200 dark:border-red-900 rounded-xl shadow-md">
        <div className="flex items-center gap-3 text-red-600 mb-4">
          <AlertCircle className="w-6 h-6 flex-shrink-0" />
          <h2 className="text-lg font-bold">Unable to Load Preview</h2>
        </div>
        <p className="text-gray-600 dark:text-gray-400 mb-6">{error || 'No manifest available.'}</p>
        <div className="bg-gray-50 dark:bg-gray-800 p-4 rounded-lg text-sm text-gray-700 dark:text-gray-300 mb-4">
          <p className="font-semibold mb-1">Troubleshooting Tips:</p>
          <ul className="list-disc list-inside space-y-1 text-xs">
            <li>Ensure the PDF conversion has finished (status is <code>completed</code> in Admin).</li>
            <li>Verify you opened this link from the Flutter Admin <strong>Preview in Reader</strong> button.</li>
          </ul>
        </div>
      </div>
    );
  }

  const { meta, blocks } = manifest;
  const chapters = meta.chapters || [];
  const totalPages = chapters.length || 1;

  return (
    <div>
      {isDynamicPreview && (
        <div className="bg-blue-600 text-white text-xs py-1.5 px-4 text-center font-medium flex items-center justify-center gap-2">
          <BookOpen className="w-4 h-4" />
          <span>Author Preview Mode (Private) — Standalone PWA can be exported from Admin Dashboard</span>
        </div>
      )}

      <header className="sticky top-0 z-30 bg-bg-main/80 backdrop-blur-md border-b border-border-main px-4 h-16 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <SidebarToggle />
          <div className="flex flex-col">
            <h1 className="text-base sm:text-lg font-bold tracking-tight truncate max-w-[200px] sm:max-w-md">
              {meta.title || 'Codex'}
            </h1>
            {meta.author && <span className="text-xs text-text-muted hidden sm:block">by {meta.author}</span>}
          </div>
        </div>

        <NavigationControls totalPages={totalPages} />

        <div className="w-10 sm:hidden"></div>
      </header>

      <Sidebar chapters={chapters} />

      <main className="max-w-3xl mx-auto py-12 px-6">
        <ReadingView blocks={blocks} chapters={chapters} />
      </main>
    </div>
  );
};

export default DynamicReader;
