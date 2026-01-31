-- Storage Buckets Setup

-- 1. Create Buckets (Idempotent)
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('raw_pdfs', 'raw_pdfs', false),
  ('book_assets', 'book_assets', true)
ON CONFLICT (id) DO NOTHING;

-- 2. RLS Policies for 'raw_pdfs'

-- Policy: Users can upload their own PDFs
-- Constraint: File must be in a folder matching their User ID (e.g., "uid/file.pdf")
CREATE POLICY "Users can upload their own PDFs"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'raw_pdfs' AND 
  (storage.foldername(name))[1]::uuid = auth.uid()
);

-- Policy: Users can view/download their own PDFs
CREATE POLICY "Users can view their own PDFs"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'raw_pdfs' AND 
  (storage.foldername(name))[1]::uuid = auth.uid()
);

-- Policy: Users can delete their own PDFs
CREATE POLICY "Users can delete their own PDFs"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'raw_pdfs' AND 
  (storage.foldername(name))[1]::uuid = auth.uid()
);

-- 3. RLS Policies for 'book_assets'

-- Policy: Users can upload assets for their books
CREATE POLICY "Users can upload their own assets"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'book_assets' AND 
  (storage.foldername(name))[1]::uuid = auth.uid()
);

-- Policy: Users can manage their own assets (Update/Delete)
CREATE POLICY "Users can manage their own assets"
ON storage.objects FOR ALL
TO authenticated
USING (
  bucket_id = 'book_assets' AND 
  (storage.foldername(name))[1]::uuid = auth.uid()
);

-- Policy: Public Read Access for book_assets
-- Note: 'public' bucket setting handles direct URL access, but this enables API SELECTs
CREATE POLICY "Public Read Access for book_assets"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'book_assets');
