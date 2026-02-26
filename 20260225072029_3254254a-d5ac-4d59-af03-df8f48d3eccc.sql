
CREATE TABLE public.employee_role_history (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  employee_id UUID NOT NULL REFERENCES public.nexus_team_members(id) ON DELETE CASCADE,
  role TEXT NOT NULL,
  from_date DATE NOT NULL DEFAULT CURRENT_DATE,
  to_date DATE,
  reason TEXT,
  remarks TEXT,
  is_current BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS
ALTER TABLE public.employee_role_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to employee_role_history" ON public.employee_role_history FOR SELECT USING (true);
CREATE POLICY "Allow insert access to employee_role_history" ON public.employee_role_history FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to employee_role_history" ON public.employee_role_history FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to employee_role_history" ON public.employee_role_history FOR DELETE USING (true);
