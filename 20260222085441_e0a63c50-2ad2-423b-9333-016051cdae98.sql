
-- Child Bonus Policy (global settings)
CREATE TABLE public.child_bonus_policy (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  is_enabled boolean NOT NULL DEFAULT false,
  max_children integer NOT NULL DEFAULT 2,
  age_brackets jsonb NOT NULL DEFAULT '[{"min_years":0,"max_years":7,"max_days":0,"amount":1500},{"min_years":7,"min_days":1,"max_years":14,"max_days":0,"amount":1000}]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.child_bonus_policy ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read child_bonus_policy" ON public.child_bonus_policy FOR SELECT USING (true);
CREATE POLICY "Allow insert child_bonus_policy" ON public.child_bonus_policy FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update child_bonus_policy" ON public.child_bonus_policy FOR UPDATE USING (true);

-- Seed default policy row
INSERT INTO public.child_bonus_policy (is_enabled, max_children) VALUES (false, 2);

-- Employee Children
CREATE TABLE public.employee_children (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id uuid NOT NULL REFERENCES public.nexus_team_members(id) ON DELETE CASCADE,
  child_name text NOT NULL DEFAULT '',
  date_of_birth date,
  is_bonus_enabled boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.employee_children ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read employee_children" ON public.employee_children FOR SELECT USING (true);
CREATE POLICY "Allow insert employee_children" ON public.employee_children FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update employee_children" ON public.employee_children FOR UPDATE USING (true);
CREATE POLICY "Allow delete employee_children" ON public.employee_children FOR DELETE USING (true);

-- Child Documents
CREATE TABLE public.child_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id uuid NOT NULL REFERENCES public.employee_children(id) ON DELETE CASCADE,
  document_type text NOT NULL CHECK (document_type IN ('aadhar', 'dob_certificate')),
  file_path text NOT NULL,
  file_name text NOT NULL,
  uploaded_by uuid NOT NULL REFERENCES public.nexus_team_members(id),
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.child_documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read child_documents" ON public.child_documents FOR SELECT USING (true);
CREATE POLICY "Allow insert child_documents" ON public.child_documents FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete child_documents" ON public.child_documents FOR DELETE USING (true);

-- Audit Log
CREATE TABLE public.child_bonus_audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id uuid NOT NULL,
  changed_by uuid NOT NULL REFERENCES public.nexus_team_members(id),
  details jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.child_bonus_audit_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read child_bonus_audit_log" ON public.child_bonus_audit_log FOR SELECT USING (true);
CREATE POLICY "Allow insert child_bonus_audit_log" ON public.child_bonus_audit_log FOR INSERT WITH CHECK (true);

-- Storage bucket for child documents
INSERT INTO storage.buckets (id, name, public) VALUES ('child-documents', 'child-documents', true);

CREATE POLICY "Anyone can read child docs" ON storage.objects FOR SELECT USING (bucket_id = 'child-documents');
CREATE POLICY "Anyone can upload child docs" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'child-documents');
CREATE POLICY "Anyone can delete child docs" ON storage.objects FOR DELETE USING (bucket_id = 'child-documents');
