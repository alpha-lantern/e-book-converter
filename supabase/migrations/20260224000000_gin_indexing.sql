-- Migration: Advanced GIN Indexing for Codex Manifests
-- Target: Supabase (PostgreSQL)
-- Purpose: Optimize block-level existence and path lookups within the JSONB manifest.

-- Using jsonb_path_ops for the GIN index is generally faster and smaller 
-- than the default jsonb_ops when we only use the @> operator or jsonpath queries.
CREATE INDEX IF NOT EXISTS idx_manifest_data_path_ops 
ON codex_manifests USING GIN (manifest_data jsonb_path_ops);

-- Analyze to update statistics for the new index
ANALYZE codex_manifests;
