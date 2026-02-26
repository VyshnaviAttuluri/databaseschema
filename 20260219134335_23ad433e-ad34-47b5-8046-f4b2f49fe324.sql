
-- Global leave policy per year (admin-configurable)
CREATE TABLE public.leave_policies (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  year INTEGER NOT NULL UNIQUE,
  default_leaves INTEGER NOT NULL DEFAULT 9,
  carry_forward_enabled BOOLEAN NOT NULL DEFAULT true,
  max_carry_forward INTEGER DEFAULT NULL, -- NULL = unlimited
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.leave_policies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to leave_policies" ON public.leave_policies FOR SELECT USING (true);
CREATE POLICY "Allow insert access to leave_policies" ON public.leave_policies FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to leave_policies" ON public.leave_policies FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to leave_policies" ON public.leave_policies FOR DELETE USING (true);

-- Add carried_forward_leaves column to leave_allocations
ALTER TABLE public.leave_allocations ADD COLUMN carried_forward_leaves INTEGER NOT NULL DEFAULT 0;

-- Seed current year policy
INSERT INTO public.leave_policies (year, default_leaves, carry_forward_enabled)
VALUES (2026, 9, true)
ON CONFLICT (year) DO NOTHING;
