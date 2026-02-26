
-- Table to store per-employee leave allocations per year
CREATE TABLE public.leave_allocations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  employee_id UUID NOT NULL REFERENCES public.nexus_team_members(id) ON DELETE CASCADE,
  year INTEGER NOT NULL,
  base_leaves INTEGER NOT NULL DEFAULT 9,
  bonus_leaves INTEGER NOT NULL DEFAULT 0,
  bonus_reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE (employee_id, year)
);

-- Enable RLS
ALTER TABLE public.leave_allocations ENABLE ROW LEVEL SECURITY;

-- Policies - allow all operations (matching existing pattern)
CREATE POLICY "Allow read access to leave_allocations" ON public.leave_allocations FOR SELECT USING (true);
CREATE POLICY "Allow insert access to leave_allocations" ON public.leave_allocations FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to leave_allocations" ON public.leave_allocations FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to leave_allocations" ON public.leave_allocations FOR DELETE USING (true);

-- Trigger for updated_at
CREATE TRIGGER update_leave_allocations_updated_at
BEFORE UPDATE ON public.leave_allocations
FOR EACH ROW
EXECUTE FUNCTION public.update_appraisal_updated_at();
