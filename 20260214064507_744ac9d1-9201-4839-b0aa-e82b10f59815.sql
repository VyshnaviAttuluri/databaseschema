
-- Centralized settings table for dropdown/filter categories
CREATE TABLE public.setting_categories (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT NOT NULL,  -- e.g. 'role', 'location', 'department', 'leave_type'
  label TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.setting_categories ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read
CREATE POLICY "Anyone can read categories"
  ON public.setting_categories FOR SELECT
  USING (true);

-- Only authenticated users can manage (admin check can be added later)
CREATE POLICY "Authenticated users can insert categories"
  ON public.setting_categories FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update categories"
  ON public.setting_categories FOR UPDATE
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete categories"
  ON public.setting_categories FOR DELETE
  USING (auth.uid() IS NOT NULL);

-- Seed default values from existing data
INSERT INTO public.setting_categories (category, label, sort_order) VALUES
  -- Roles
  ('role', 'Admin', 1),
  ('role', 'Developer', 2),
  ('role', 'Designer', 3),
  ('role', 'Manager', 4),
  ('role', 'HR', 5),
  ('role', 'Intern', 6),
  -- Departments
  ('department', 'Engineering', 1),
  ('department', 'Design', 2),
  ('department', 'Human Resources', 3),
  ('department', 'Finance', 4),
  ('department', 'Marketing', 5),
  ('department', 'Operations', 6),
  -- Locations
  ('location', 'Mumbai', 1),
  ('location', 'Pune', 2),
  ('location', 'Delhi', 3),
  ('location', 'Bangalore', 4),
  ('location', 'Remote', 5),
  -- Leave Types
  ('leave_type', 'Casual Leave', 1),
  ('leave_type', 'Sick Leave', 2),
  ('leave_type', 'Earned Leave', 3),
  ('leave_type', 'Maternity Leave', 4),
  ('leave_type', 'Paternity Leave', 5),
  ('leave_type', 'Comp Off', 6);
