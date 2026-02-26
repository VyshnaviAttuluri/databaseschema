
-- Add probation tracking columns to employee_local_details
ALTER TABLE public.employee_local_details
ADD COLUMN IF NOT EXISTS probation_completed boolean NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS probation_completed_at timestamp with time zone DEFAULT NULL;
