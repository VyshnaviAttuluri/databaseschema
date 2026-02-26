
-- Create attendance_records table
CREATE TABLE public.attendance_records (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  employee_id UUID NOT NULL REFERENCES public.nexus_team_members(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  login_time TIME WITHOUT TIME ZONE,
  logout_time TIME WITHOUT TIME ZONE,
  hours_worked NUMERIC(5,2) GENERATED ALWAYS AS (
    CASE 
      WHEN login_time IS NOT NULL AND logout_time IS NOT NULL 
      THEN ROUND(EXTRACT(EPOCH FROM (logout_time - login_time)) / 3600.0, 2)
      ELSE NULL 
    END
  ) STORED,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(employee_id, date)
);

-- Enable RLS
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to attendance_records" ON public.attendance_records FOR SELECT USING (true);
CREATE POLICY "Allow insert access to attendance_records" ON public.attendance_records FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to attendance_records" ON public.attendance_records FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to attendance_records" ON public.attendance_records FOR DELETE USING (true);
