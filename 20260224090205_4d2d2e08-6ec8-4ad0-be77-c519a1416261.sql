
-- 1. Add CHECK constraints for max amounts per item type via trigger
CREATE OR REPLACE FUNCTION public.validate_infrastructure_bonus()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  _probation BOOLEAN;
  _max_amount NUMERIC;
BEGIN
  -- Enforce probation eligibility on insert
  IF TG_OP = 'INSERT' THEN
    SELECT probation_completed INTO _probation
    FROM public.employee_local_details
    WHERE employee_id = NEW.employee_id;

    IF _probation IS NOT TRUE THEN
      RAISE EXCEPTION 'Employee has not completed probation period. Infrastructure bonus is available only after 6 months.';
    END IF;
  END IF;

  -- Enforce max amount limits when approved_amount is set
  IF NEW.approved_amount IS NOT NULL AND NEW.approved_amount > 0 THEN
    CASE NEW.item_type
      WHEN 'chair' THEN _max_amount := 3000;
      WHEN 'monitor' THEN _max_amount := 5000;
      WHEN 'table' THEN _max_amount := 2000;
      ELSE _max_amount := 0;
    END CASE;

    IF NEW.approved_amount > _max_amount THEN
      RAISE EXCEPTION 'Maximum allowed amount for % is ₹%. Got ₹%.', 
        initcap(NEW.item_type), _max_amount, NEW.approved_amount;
    END IF;
  END IF;

  -- Enforce file type restriction
  IF NEW.file_name IS NOT NULL THEN
    IF NOT (
      lower(NEW.file_name) LIKE '%.png' OR
      lower(NEW.file_name) LIKE '%.jpg' OR
      lower(NEW.file_name) LIKE '%.jpeg' OR
      lower(NEW.file_name) LIKE '%.pdf'
    ) THEN
      RAISE EXCEPTION 'Only PNG, JPG, and PDF formats are allowed.';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- Create trigger
DROP TRIGGER IF EXISTS trg_validate_infrastructure_bonus ON public.infrastructure_bonus_bills;
CREATE TRIGGER trg_validate_infrastructure_bonus
  BEFORE INSERT OR UPDATE ON public.infrastructure_bonus_bills
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_infrastructure_bonus();

-- 2. Auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_infra_bonus_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO 'public'
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_infra_bonus_updated_at ON public.infrastructure_bonus_bills;
CREATE TRIGGER trg_infra_bonus_updated_at
  BEFORE UPDATE ON public.infrastructure_bonus_bills
  FOR EACH ROW
  EXECUTE FUNCTION public.update_infra_bonus_updated_at();
