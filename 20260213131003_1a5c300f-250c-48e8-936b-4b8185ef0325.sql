
-- Appraisal Cycles table
CREATE TABLE public.appraisal_cycles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.appraisal_cycles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to appraisal_cycles" ON public.appraisal_cycles FOR SELECT USING (true);
CREATE POLICY "Allow insert access to appraisal_cycles" ON public.appraisal_cycles FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to appraisal_cycles" ON public.appraisal_cycles FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to appraisal_cycles" ON public.appraisal_cycles FOR DELETE USING (true);

-- Appraisal Reviews table
CREATE TABLE public.appraisal_reviews (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  cycle_id UUID NOT NULL REFERENCES public.appraisal_cycles(id) ON DELETE CASCADE,
  employee_id UUID NOT NULL REFERENCES public.nexus_team_members(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'NOT_STARTED' CHECK (status IN ('NOT_STARTED', 'DRAFT', 'SUBMITTED', 'REVIEWED', 'PENDING_SIGN_OFF', 'COMPLETED')),
  achievements TEXT,
  challenges TEXT,
  self_rating INTEGER CHECK (self_rating BETWEEN 1 AND 5),
  admin_rating INTEGER CHECK (admin_rating BETWEEN 1 AND 5),
  admin_feedback TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(cycle_id, employee_id)
);

ALTER TABLE public.appraisal_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to appraisal_reviews" ON public.appraisal_reviews FOR SELECT USING (true);
CREATE POLICY "Allow insert access to appraisal_reviews" ON public.appraisal_reviews FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to appraisal_reviews" ON public.appraisal_reviews FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to appraisal_reviews" ON public.appraisal_reviews FOR DELETE USING (true);

-- Appraisal Goals table
CREATE TABLE public.appraisal_goals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  review_id UUID NOT NULL REFERENCES public.appraisal_reviews(id) ON DELETE CASCADE,
  goal_text TEXT NOT NULL,
  is_achieved BOOLEAN NOT NULL DEFAULT false,
  goal_type TEXT NOT NULL DEFAULT 'CURRENT' CHECK (goal_type IN ('CURRENT', 'FUTURE')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.appraisal_goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to appraisal_goals" ON public.appraisal_goals FOR SELECT USING (true);
CREATE POLICY "Allow insert access to appraisal_goals" ON public.appraisal_goals FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to appraisal_goals" ON public.appraisal_goals FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to appraisal_goals" ON public.appraisal_goals FOR DELETE USING (true);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION public.update_appraisal_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

CREATE TRIGGER update_appraisal_cycles_updated_at
  BEFORE UPDATE ON public.appraisal_cycles
  FOR EACH ROW EXECUTE FUNCTION public.update_appraisal_updated_at();

CREATE TRIGGER update_appraisal_reviews_updated_at
  BEFORE UPDATE ON public.appraisal_reviews
  FOR EACH ROW EXECUTE FUNCTION public.update_appraisal_updated_at();
