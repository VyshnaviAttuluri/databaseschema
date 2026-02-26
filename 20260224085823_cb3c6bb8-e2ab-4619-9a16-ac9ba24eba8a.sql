
-- Infrastructure bonus bills table
CREATE TABLE public.infrastructure_bonus_bills (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  employee_id UUID NOT NULL REFERENCES public.nexus_team_members(id),
  item_type TEXT NOT NULL CHECK (item_type IN ('chair', 'monitor', 'table')),
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  approved_amount NUMERIC DEFAULT 0,
  admin_remarks TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(employee_id, item_type)
);

-- Enable RLS
ALTER TABLE public.infrastructure_bonus_bills ENABLE ROW LEVEL SECURITY;

-- RLS policies
CREATE POLICY "Allow read access to infrastructure_bonus_bills" ON public.infrastructure_bonus_bills FOR SELECT USING (true);
CREATE POLICY "Allow insert access to infrastructure_bonus_bills" ON public.infrastructure_bonus_bills FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to infrastructure_bonus_bills" ON public.infrastructure_bonus_bills FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to infrastructure_bonus_bills" ON public.infrastructure_bonus_bills FOR DELETE USING (true);

-- Index for performance
CREATE INDEX idx_infra_bonus_employee ON public.infrastructure_bonus_bills(employee_id);

-- Storage bucket for infrastructure bills
INSERT INTO storage.buckets (id, name, public) VALUES ('infrastructure-bills', 'infrastructure-bills', true);

-- Storage RLS policies
CREATE POLICY "Allow public read infra bills" ON storage.objects FOR SELECT USING (bucket_id = 'infrastructure-bills');
CREATE POLICY "Allow upload infra bills" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'infrastructure-bills');
CREATE POLICY "Allow delete infra bills" ON storage.objects FOR DELETE USING (bucket_id = 'infrastructure-bills');
