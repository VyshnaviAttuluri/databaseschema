
-- =====================================================
-- APPRAISAL V2: Multi-Level Hierarchy Workflow
-- =====================================================

-- Main submission record (one per employee per cycle)
CREATE TABLE IF NOT EXISTS public.appraisal_submissions (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  cycle_id uuid NOT NULL REFERENCES public.appraisal_cycles(id) ON DELETE CASCADE,
  employee_id uuid NOT NULL REFERENCES public.nexus_team_members(id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'DRAFT',
  -- DRAFT → SUBMITTED → MANAGER_REVIEW → HEAD_REVIEW → COMPLETED
  achievements text,
  challenges text,
  -- Self-ratings on 5 factors stored as JSON: {"Quality of Work": 4, ...}
  self_ratings jsonb DEFAULT '{}',
  -- Final calculated rating (weighted average)
  final_rating numeric,
  -- Digital sign-off
  acknowledged_at timestamptz,
  acknowledgment_note text,
  submitted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(cycle_id, employee_id)
);

-- Goals per submission
CREATE TABLE IF NOT EXISTS public.appraisal_submission_goals (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  submission_id uuid NOT NULL REFERENCES public.appraisal_submissions(id) ON DELETE CASCADE,
  goal_text text NOT NULL,
  is_achieved boolean NOT NULL DEFAULT false,
  goal_type text NOT NULL DEFAULT 'NEXT', -- CURRENT (previous cycle) or NEXT (future)
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Reviewers hierarchy per submission (employee selects during submission)
CREATE TABLE IF NOT EXISTS public.appraisal_reviewers (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  submission_id uuid NOT NULL REFERENCES public.appraisal_submissions(id) ON DELETE CASCADE,
  reviewer_id uuid NOT NULL REFERENCES public.nexus_team_members(id) ON DELETE CASCADE,
  reviewer_type text NOT NULL, -- 'MANAGER' or 'HEAD'
  hierarchy_order integer NOT NULL DEFAULT 1, -- ordering among managers
  status text NOT NULL DEFAULT 'PENDING', -- PENDING, COMPLETED
  -- Ratings on 5 factors stored as JSON
  ratings jsonb DEFAULT '{}',
  feedback text,
  reviewed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- RLS: appraisal_submissions
ALTER TABLE public.appraisal_submissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read access to appraisal_submissions" ON public.appraisal_submissions FOR SELECT USING (true);
CREATE POLICY "Allow insert access to appraisal_submissions" ON public.appraisal_submissions FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to appraisal_submissions" ON public.appraisal_submissions FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to appraisal_submissions" ON public.appraisal_submissions FOR DELETE USING (true);

-- RLS: appraisal_submission_goals
ALTER TABLE public.appraisal_submission_goals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read access to appraisal_submission_goals" ON public.appraisal_submission_goals FOR SELECT USING (true);
CREATE POLICY "Allow insert access to appraisal_submission_goals" ON public.appraisal_submission_goals FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to appraisal_submission_goals" ON public.appraisal_submission_goals FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to appraisal_submission_goals" ON public.appraisal_submission_goals FOR DELETE USING (true);

-- RLS: appraisal_reviewers
ALTER TABLE public.appraisal_reviewers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read access to appraisal_reviewers" ON public.appraisal_reviewers FOR SELECT USING (true);
CREATE POLICY "Allow insert access to appraisal_reviewers" ON public.appraisal_reviewers FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to appraisal_reviewers" ON public.appraisal_reviewers FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to appraisal_reviewers" ON public.appraisal_reviewers FOR DELETE USING (true);

-- Auto-update updated_at trigger for appraisal_submissions
CREATE OR REPLACE FUNCTION public.update_appraisal_submission_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_appraisal_submissions_updated_at
  BEFORE UPDATE ON public.appraisal_submissions
  FOR EACH ROW EXECUTE FUNCTION public.update_appraisal_submission_updated_at();
