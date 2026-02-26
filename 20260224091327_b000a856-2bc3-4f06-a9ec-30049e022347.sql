
-- Auto-recalculate probation_completed when joined_at changes on nexus_team_members
CREATE OR REPLACE FUNCTION public.recalculate_probation_on_join_date()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  _probation_completed BOOLEAN;
  _probation_completed_at TIMESTAMPTZ;
BEGIN
  -- Only act if joined_at is set
  IF NEW.joined_at IS NOT NULL THEN
    -- 6 months from join date
    _probation_completed := (NEW.joined_at <= (now() - INTERVAL '6 months'));
    
    IF _probation_completed THEN
      _probation_completed_at := NEW.joined_at + INTERVAL '6 months';
    ELSE
      _probation_completed_at := NULL;
    END IF;

    -- Upsert into employee_local_details
    INSERT INTO public.employee_local_details (employee_id, probation_completed, probation_completed_at)
    VALUES (NEW.id, _probation_completed, _probation_completed_at)
    ON CONFLICT (employee_id)
    DO UPDATE SET
      probation_completed = EXCLUDED.probation_completed,
      probation_completed_at = EXCLUDED.probation_completed_at,
      updated_at = now();
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_recalculate_probation ON public.nexus_team_members;
CREATE TRIGGER trg_recalculate_probation
  AFTER INSERT OR UPDATE OF joined_at ON public.nexus_team_members
  FOR EACH ROW
  EXECUTE FUNCTION public.recalculate_probation_on_join_date();
