
-- Create employee_documents table
CREATE TABLE public.employee_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID NOT NULL REFERENCES public.nexus_team_members(id) ON DELETE CASCADE,
  document_name TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  uploaded_by TEXT NOT NULL DEFAULT 'hr', -- 'hr' or 'employee'
  resend_requested BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.employee_documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to employee_documents" ON public.employee_documents FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow insert access to employee_documents" ON public.employee_documents FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Allow update access to employee_documents" ON public.employee_documents FOR UPDATE TO anon, authenticated USING (true);
CREATE POLICY "Allow delete access to employee_documents" ON public.employee_documents FOR DELETE TO anon, authenticated USING (true);

-- Create storage bucket for employee documents
INSERT INTO storage.buckets (id, name, public) VALUES ('employee-documents', 'employee-documents', true);

-- Storage RLS policies
CREATE POLICY "Allow public read employee-documents" ON storage.objects FOR SELECT TO anon, authenticated USING (bucket_id = 'employee-documents');
CREATE POLICY "Allow upload employee-documents" ON storage.objects FOR INSERT TO anon, authenticated WITH CHECK (bucket_id = 'employee-documents');
CREATE POLICY "Allow delete employee-documents" ON storage.objects FOR DELETE TO anon, authenticated USING (bucket_id = 'employee-documents');
