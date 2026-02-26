
CREATE TABLE public.referral_bonuses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id UUID NOT NULL REFERENCES public.nexus_team_members(id),
  referred_employee_name TEXT NOT NULL,
  bonus_amount NUMERIC NOT NULL DEFAULT 5000,
  year INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.referral_bonuses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to referral_bonuses" ON public.referral_bonuses FOR SELECT USING (true);
CREATE POLICY "Allow insert access to referral_bonuses" ON public.referral_bonuses FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow delete access to referral_bonuses" ON public.referral_bonuses FOR DELETE USING (true);
