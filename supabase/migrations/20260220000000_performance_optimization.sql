-- Performance Optimization Migration
-- Target: Foreign Key Indexes and RLS Optimization

-- 1. Add missing indexes for Foreign Keys used in RLS and Joins
CREATE INDEX IF NOT EXISTS idx_widgets_book_id ON widgets(book_id);
CREATE INDEX IF NOT EXISTS idx_analytics_logs_book_id ON analytics_logs(book_id);

-- 2. Optimize Codex Manifest JSONB Search
-- If we frequently search by title or author in the manifest metadata:
CREATE INDEX IF NOT EXISTS idx_manifest_meta_title ON codex_manifests ((manifest_data->'meta'->>'title'));
CREATE INDEX IF NOT EXISTS idx_manifest_meta_author ON codex_manifests ((manifest_data->'meta'->>'author'));

-- 3. Optimization for RLS (Optional but recommended for high scale)
-- Ensure books table has a combined index for ownership checks if needed
-- Currently idx_books_owner handles this well.
