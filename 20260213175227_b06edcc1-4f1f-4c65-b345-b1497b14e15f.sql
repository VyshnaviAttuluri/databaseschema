
-- Create leave_requests table
CREATE TABLE public.leave_requests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  employee_id UUID NOT NULL REFERENCES public.nexus_team_members(id),
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  leave_type TEXT NOT NULL,
  days INTEGER NOT NULL,
  reason TEXT NOT NULL,
  proof_path TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.leave_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to leave_requests" ON public.leave_requests FOR SELECT USING (true);
CREATE POLICY "Allow insert access to leave_requests" ON public.leave_requests FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to leave_requests" ON public.leave_requests FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to leave_requests" ON public.leave_requests FOR DELETE USING (true);

-- Trigger for updated_at
CREATE TRIGGER update_leave_requests_updated_at
BEFORE UPDATE ON public.leave_requests
FOR EACH ROW
EXECUTE FUNCTION public.update_appraisal_updated_at();

-- Storage bucket for leave proofs
INSERT INTO storage.buckets (id, name, public) VALUES ('leave-proofs', 'leave-proofs', true);

CREATE POLICY "Allow public read access to leave-proofs" ON storage.objects FOR SELECT USING (bucket_id = 'leave-proofs');
CREATE POLICY "Allow upload to leave-proofs" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'leave-proofs');
CREATE POLICY "Allow delete from leave-proofs" ON storage.objects FOR DELETE USING (bucket_id = 'leave-proofs');
