
-- Create holidays table
CREATE TABLE public.holidays (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  date date NOT NULL,
  region text NOT NULL DEFAULT 'India',
  year integer NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.holidays ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to holidays" ON public.holidays FOR SELECT USING (true);
CREATE POLICY "Allow insert access to holidays" ON public.holidays FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to holidays" ON public.holidays FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to holidays" ON public.holidays FOR DELETE USING (true);

-- Seed 2026 data
INSERT INTO public.holidays (name, date, region, year) VALUES
  ('Bhogi', '2026-01-15', 'India', 2026),
  ('Sankranthi', '2026-01-16', 'India', 2026),
  ('Family Day', '2026-02-16', 'Canada', 2026),
  ('Sri Rama Navami', '2026-03-27', 'India', 2026),
  ('Victoria Day', '2026-05-18', 'Canada', 2026),
  ('Canada Day', '2026-07-01', 'Canada', 2026),
  ('Civic Holiday', '2026-08-03', 'Canada', 2026),
  ('Labour Day', '2026-09-07', 'Canada', 2026),
  ('Vinayaka Chavithi', '2026-09-14', 'India', 2026),
  ('Thanksgiving Day', '2026-10-12', 'Canada', 2026),
  ('Dussehra', '2026-10-20', 'India', 2026),
  ('Christmas', '2026-12-25', 'India', 2026);
