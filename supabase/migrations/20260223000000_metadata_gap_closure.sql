-- Migration: Metadata Gap Closure
-- Target: Supabase (PostgreSQL)

-- 1. Add new metadata columns to 'books' table
ALTER TABLE books 
ADD COLUMN IF NOT EXISTS author TEXT,
ADD COLUMN IF NOT EXISTS seo_title TEXT,
ADD COLUMN IF NOT EXISTS seo_description TEXT,
ADD COLUMN IF NOT EXISTS seo_tags TEXT[] DEFAULT '{}';

-- 2. Create Hybrid Metadata Synchronization Trigger Function
CREATE OR REPLACE FUNCTION sync_books_to_manifest()
RETURNS TRIGGER AS $$
BEGIN
    -- Update codex_manifests.manifest_data->'meta' object
    -- We use jsonb_set to update individual fields while preserving others like base_size
    UPDATE codex_manifests
    SET manifest_data = jsonb_set(
        jsonb_set(
            jsonb_set(
                jsonb_set(
                    jsonb_set(
                        manifest_data,
                        '{meta,title}', to_jsonb(NEW.title)
                    ),
                    '{meta,description}', to_jsonb(NEW.description)
                ),
                '{meta,author}', to_jsonb(NEW.author)
            ),
            '{meta,seo}', jsonb_build_object(
                'title', COALESCE(NEW.seo_title, NEW.title),
                'description', COALESCE(NEW.seo_description, NEW.description),
                'keywords', NEW.seo_tags,
                -- Preserve existing canonical_url and og_image if they exist in the manifest
                'canonical_url', (manifest_data->'meta'->'seo'->>'canonical_url'),
                'og_image', (manifest_data->'meta'->'seo'->>'og_image')
            )
        ),
        '{last_updated}', to_jsonb(NOW()::text)
    )
    WHERE book_id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Create the Trigger
DROP TRIGGER IF EXISTS trg_sync_books_to_manifest ON books;
CREATE TRIGGER trg_sync_books_to_manifest
AFTER UPDATE OF title, description, author, seo_title, seo_description, seo_tags
ON books
FOR EACH ROW
EXECUTE FUNCTION sync_books_to_manifest();

-- 4. Add indexes for new columns to optimize dashboard lookups
CREATE INDEX IF NOT EXISTS idx_books_author ON books(author);
