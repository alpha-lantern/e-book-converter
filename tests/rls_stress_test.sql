-- RLS Stress Test Script
-- Usage: psql -f tests/rls_stress_test.sql

BEGIN;

-- 1. Setup Test Data
DO $$
DECLARE
    user_a_id UUID := gen_random_uuid();
    user_b_id UUID := gen_random_uuid();
    book_a_private_id UUID;
    book_a_public_id UUID;
BEGIN
    -- Insert Mock Users into auth.users (Minimal fields required)
    INSERT INTO auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at)
    VALUES 
        (user_a_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'user_a@test.com', 'crypt', NOW(), NOW(), NOW()),
        (user_b_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'user_b@test.com', 'crypt', NOW(), NOW(), NOW());

    -- Insert Profiles (Trigger handles created_at/updated_at)
    INSERT INTO public.profiles (id, full_name) VALUES (user_a_id, 'User A'), (user_b_id, 'User B');

    -- Insert Books & Capture IDs
    INSERT INTO public.books (owner_id, title, slug, is_published) VALUES
        (user_a_id, 'A Private Book', 'a-private', FALSE) RETURNING id INTO book_a_private_id;
    
    INSERT INTO public.books (owner_id, title, slug, is_published) VALUES
        (user_a_id, 'A Public Book', 'a-public', TRUE) RETURNING id INTO book_a_public_id;
        
    INSERT INTO public.books (owner_id, title, slug, is_published) VALUES
        (user_b_id, 'B Private Book', 'b-private', FALSE);
    
    -- Insert Manifests (One private, One public)
    INSERT INTO public.codex_manifests (book_id, manifest_data) VALUES 
        (book_a_private_id, '{"content": "Top Secret"}'::jsonb),
        (book_a_public_id, '{"content": "Hello World"}'::jsonb);

    -- Insert Widgets
    INSERT INTO public.widgets (book_id, block_id, type) VALUES
        (book_a_private_id, 'block_1', 'video'),
        (book_a_public_id, 'block_2', 'quiz');

    -- Store IDs in temp table for easy access in SQL assertions
    CREATE TABLE test_ids AS 
    SELECT user_a_id AS u_a, user_b_id AS u_b, book_a_private_id AS b_priv, book_a_public_id AS b_pub;

    -- GRANT ACCESS TO TEST TABLE
    GRANT SELECT ON test_ids TO anon, authenticated;
END $$;

-- 2. Define Helper for Assertions
CREATE OR REPLACE FUNCTION assert_count(query_text text, expected_count int, test_name text) RETURNS void AS $$
DECLARE
    cnt int;
BEGIN
    EXECUTE query_text INTO cnt;
    IF cnt <> expected_count THEN
        RAISE EXCEPTION 'FAIL: % (Expected %, Got %)', test_name, expected_count, cnt;
    ELSE
        RAISE NOTICE 'PASS: %', test_name;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 3. Run Tests

--------------------------------------------------------------------------------
-- TEST CASE: ANONYMOUS USER
--------------------------------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testing ANONYMOUS Role ---'; END $$;
SET ROLE anon;

-- Books
SELECT assert_count('SELECT count(*) FROM public.books WHERE slug = ''a-private''', 0, 'Anon cannot see private book');
SELECT assert_count('SELECT count(*) FROM public.books WHERE slug = ''a-public''', 1, 'Anon can see public book');

-- Manifests
SELECT assert_count('SELECT count(*) FROM public.codex_manifests WHERE manifest_data->>''content'' = ''Top Secret''', 0, 'Anon cannot see private manifest');
SELECT assert_count('SELECT count(*) FROM public.codex_manifests WHERE manifest_data->>''content'' = ''Hello World''', 1, 'Anon can see public manifest');

-- Widgets
SELECT assert_count('SELECT count(*) FROM public.widgets WHERE type = ''video''', 0, 'Anon cannot see private widget');
SELECT assert_count('SELECT count(*) FROM public.widgets WHERE type = ''quiz''', 1, 'Anon can see public widget');

-- Analytics Logs (Expect 0 access as no policy exists for Anon)
DO $$
BEGIN
    INSERT INTO public.analytics_logs (event_type) VALUES ('hack_attempt');
    RAISE EXCEPTION 'FAIL: Anon should not be able to insert analytics';
EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'PASS: Anon cannot insert analytics';
END $$;


--------------------------------------------------------------------------------
-- TEST CASE: AUTHENTICATED USER A (Owner)
--------------------------------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testing AUTHENTICATED Role (User A) ---'; END $$;
SET ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', u_a::text, true) FROM test_ids;

-- Manifests
SELECT assert_count('SELECT count(*) FROM public.codex_manifests WHERE manifest_data->>''content'' = ''Top Secret''', 1, 'User A sees own private manifest');
SELECT assert_count('SELECT count(*) FROM public.codex_manifests WHERE manifest_data->>''content'' = ''Hello World''', 1, 'User A sees own public manifest');

-- Update Manifest (Own)
DO $$
DECLARE
    b_id uuid;
BEGIN
    SELECT b_priv INTO b_id FROM test_ids;
    UPDATE public.codex_manifests SET parser_version = 'v2' WHERE book_id = b_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'FAIL: User A should update own manifest'; END IF;
    RAISE NOTICE 'PASS: User A updated own manifest';
END $$;


--------------------------------------------------------------------------------
-- TEST CASE: AUTHENTICATED USER B (Non-Owner)
--------------------------------------------------------------------------------
DO $$ BEGIN RAISE NOTICE '--- Testing AUTHENTICATED Role (User B) ---'; END $$;
SELECT set_config('request.jwt.claim.sub', u_b::text, true) FROM test_ids;

-- Manifests
SELECT assert_count('SELECT count(*) FROM public.codex_manifests WHERE manifest_data->>''content'' = ''Top Secret''', 0, 'User B CANNOT see User A private manifest');
SELECT assert_count('SELECT count(*) FROM public.codex_manifests WHERE manifest_data->>''content'' = ''Hello World''', 1, 'User B can see User A public manifest');

-- Try to Update User A's Manifest
DO $$
DECLARE
    b_id uuid;
BEGIN
    SELECT b_priv INTO b_id FROM test_ids;
    UPDATE public.codex_manifests SET parser_version = 'hacked' WHERE book_id = b_id;
    IF FOUND THEN RAISE EXCEPTION 'FAIL: User B should NOT update User A manifest'; END IF;
    RAISE NOTICE 'PASS: User B cannot update User A private manifest';
END $$;

-- Analytics Logs (Verify Deny All)
DO $$
BEGIN
    INSERT INTO public.analytics_logs (event_type) VALUES ('user_tracking');
    RAISE EXCEPTION 'FAIL: User B should not be able to insert analytics (Policy Missing)';
EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'PASS: User B cannot insert analytics (Default Deny)';
END $$;


DO $$ BEGIN RAISE NOTICE '--- ALL TESTS PASSED ---'; END $$;

ROLLBACK;
