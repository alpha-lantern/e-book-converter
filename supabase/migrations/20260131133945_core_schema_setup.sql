-- Create status_enum
DO $$ BEGIN
    CREATE TYPE status_enum AS ENUM ('processing', 'completed', 'failed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 1. PROFILES (Extends Supabase Auth)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    organization_name TEXT,
    avatar_url TEXT,
    plan_level TEXT DEFAULT 'free',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. BOOKS
CREATE TABLE IF NOT EXISTS books (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    original_pdf_url TEXT,
    status status_enum DEFAULT 'processing',
    error_log TEXT,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. CODEX_MANIFESTS
CREATE TABLE IF NOT EXISTS codex_manifests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    book_id UUID REFERENCES books(id) ON DELETE CASCADE UNIQUE NOT NULL,
    manifest_data JSONB NOT NULL,
    parser_version TEXT,
    last_updated TIMESTAMPTZ DEFAULT NOW()
);

-- 4. WIDGETS
CREATE TABLE IF NOT EXISTS widgets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    book_id UUID REFERENCES books(id) ON DELETE CASCADE NOT NULL,
    block_id TEXT NOT NULL,
    type TEXT NOT NULL,
    config JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. ANALYTICS_LOGS
CREATE TABLE IF NOT EXISTS analytics_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    book_id UUID REFERENCES books(id) ON DELETE CASCADE,
    event_type TEXT,
    user_agent TEXT,
    geo_country TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_books_owner ON books(owner_id);
CREATE INDEX IF NOT EXISTS idx_books_slug ON books(slug);
CREATE INDEX IF NOT EXISTS idx_books_status ON books(status);
CREATE INDEX IF NOT EXISTS idx_manifest_data ON codex_manifests USING GIN (manifest_data);

-- ENABLE RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
ALTER TABLE codex_manifests ENABLE ROW LEVEL SECURITY;
ALTER TABLE widgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_logs ENABLE ROW LEVEL SECURITY;

-- POLICIES
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Users can manage their own profiles') THEN
        CREATE POLICY "Users can manage their own profiles" ON profiles
            FOR ALL USING (auth.uid() = id);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Users can manage their own books') THEN
        CREATE POLICY "Users can manage their own books" ON books
            FOR ALL USING (auth.uid() = owner_id);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Public can view published books') THEN
        CREATE POLICY "Public can view published books" ON books
            FOR SELECT USING (is_published = TRUE);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Users can manage manifests for their books') THEN
        CREATE POLICY "Users can manage manifests for their books" ON codex_manifests
            FOR ALL USING (EXISTS (SELECT 1 FROM books WHERE books.id = codex_manifests.book_id AND books.owner_id = auth.uid()));
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Public can view manifests for published books') THEN
        CREATE POLICY "Public can view manifests for published books" ON codex_manifests
            FOR SELECT USING (EXISTS (SELECT 1 FROM books WHERE books.id = codex_manifests.book_id AND books.is_published = TRUE));
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Users can manage widgets for their books') THEN
        CREATE POLICY "Users can manage widgets for their books" ON widgets
            FOR ALL USING (EXISTS (SELECT 1 FROM books WHERE books.id = widgets.book_id AND books.owner_id = auth.uid()));
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Public can view widgets for published books') THEN
        CREATE POLICY "Public can view widgets for published books" ON widgets
            FOR SELECT USING (EXISTS (SELECT 1 FROM books WHERE books.id = widgets.book_id AND books.is_published = TRUE));
    END IF;
END $$;

-- Function to handle updated_at
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for profiles and books
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_profiles_updated_at') THEN
        CREATE TRIGGER set_profiles_updated_at
        BEFORE UPDATE ON profiles
        FOR EACH ROW
        EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_books_updated_at') THEN
        CREATE TRIGGER set_books_updated_at
        BEFORE UPDATE ON books
        FOR EACH ROW
        EXECUTE FUNCTION handle_updated_at();
    END IF;
END $$;
