CREATE TABLE public.leave_bonus_logs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  employee_id UUID NOT NULL REFERENCES public.nexus_team_members(id),
  year INTEGER NOT NULL,
  bonus_days INTEGER NOT NULL,
  reason TEXT,
  added_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.leave_bonus_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to leave_bonus_logs" ON public.leave_bonus_logs FOR SELECT USING (true);
CREATE POLICY "Allow insert access to leave_bonus_logs" ON public.leave_bonus_logs FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete access to leave_bonus_logs" ON public.leave_bonus_logs FOR DELETE USING (true);