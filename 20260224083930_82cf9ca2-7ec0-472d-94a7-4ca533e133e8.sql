
-- 1. Index for performance on common queries
CREATE INDEX idx_referral_bonuses_referrer_year ON public.referral_bonuses (referrer_id, year);

-- 2. Enforce fixed ₹5,000 bonus at DB level via trigger (CHECK with static value)
ALTER TABLE public.referral_bonuses ADD CONSTRAINT chk_bonus_amount CHECK (bonus_amount = 5000);

-- 3. Unique constraint: no duplicate referral (same referrer + same referred name + same year)
ALTER TABLE public.referral_bonuses ADD CONSTRAINT uq_referral_per_year UNIQUE (referrer_id, referred_employee_name, year);

-- 4. Validation trigger: enforce max 5 referrals/year and 6-month probation
CREATE OR REPLACE FUNCTION public.validate_referral_bonus()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _count INTEGER;
  _probation BOOLEAN;
BEGIN
  -- Check probation completed
  SELECT probation_completed INTO _probation
  FROM public.employee_local_details
  WHERE employee_id = NEW.referrer_id;

  IF _probation IS NOT TRUE THEN
    RAISE EXCEPTION 'Employee has not completed probation period';
  END IF;

  -- Check max 5 referrals per year
  SELECT COUNT(*) INTO _count
  FROM public.referral_bonuses
  WHERE referrer_id = NEW.referrer_id AND year = NEW.year;

  IF _count >= 5 THEN
    RAISE EXCEPTION 'Referral limit of 5 reached for this year';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validate_referral_bonus
  BEFORE INSERT ON public.referral_bonuses
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_referral_bonus();
