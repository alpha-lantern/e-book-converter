-- Migration: Refine Metadata Sync Trigger
-- Target: Supabase (PostgreSQL)
-- Purpose: Enhance security and robustness of the metadata synchronization logic.

-- 1. Create the refined sync function with security hardening
CREATE OR REPLACE FUNCTION public.sync_books_to_manifest()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Patch the manifest_data JSONB object
    -- 1. We merge the existing 'meta' object with new values
    -- 2. We preserve 'base_size' and other existing meta fields
    -- 3. We use COALESCE for SEO defaults
    UPDATE codex_manifests
    SET manifest_data = manifest_data || jsonb_build_object(
        'meta', (manifest_data->'meta') || jsonb_build_object(
            'title', NEW.title,
            'description', NEW.description,
            'author', NEW.author,
            'seo', jsonb_build_object(
                'title', COALESCE(NEW.seo_title, NEW.title),
                'description', COALESCE(NEW.seo_description, NEW.description),
                'keywords', NEW.seo_tags,
                -- Preserve existing canonical and og_image if they exist
                'canonical_url', (manifest_data->'meta'->'seo'->>'canonical_url'),
                'og_image', (manifest_data->'meta'->'seo'->>'og_image')
            )
        ),
        'last_updated', to_jsonb(NOW()::text)
    )
    WHERE book_id = NEW.id;

    RETURN NEW;
END;
$$;

-- 2. Re-attach the trigger
DROP TRIGGER IF EXISTS trg_sync_books_to_manifest ON books;
CREATE TRIGGER trg_sync_books_to_manifest
AFTER UPDATE OF title, description, author, seo_title, seo_description, seo_tags
ON books
FOR EACH ROW
EXECUTE FUNCTION sync_books_to_manifest();
