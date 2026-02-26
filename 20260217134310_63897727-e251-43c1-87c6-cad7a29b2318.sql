
CREATE TABLE public.employee_local_details (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  employee_id UUID NOT NULL UNIQUE REFERENCES public.nexus_team_members(id) ON DELETE CASCADE,
  dob_certificate DATE,
  dob_real DATE,
  location TEXT,
  seniority TEXT,
  supervisor TEXT,
  employee_type TEXT DEFAULT 'Full-Time',
  person_type TEXT DEFAULT 'NCPL Team',
  phone_code TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.employee_local_details ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to employee_local_details" ON public.employee_local_details FOR SELECT USING (true);
CREATE POLICY "Allow insert access to employee_local_details" ON public.employee_local_details FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to employee_local_details" ON public.employee_local_details FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to employee_local_details" ON public.employee_local_details FOR DELETE USING (true);
