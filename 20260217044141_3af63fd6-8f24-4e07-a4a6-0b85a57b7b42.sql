
-- Employee salary configuration
CREATE TABLE public.employee_salary_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID NOT NULL REFERENCES public.nexus_team_members(id) ON DELETE CASCADE,
  base_pay NUMERIC NOT NULL DEFAULT 0,
  hra NUMERIC NOT NULL DEFAULT 0,
  transport_allowance NUMERIC NOT NULL DEFAULT 0,
  medical_allowance NUMERIC NOT NULL DEFAULT 0,
  special_allowance NUMERIC NOT NULL DEFAULT 0,
  pf_percentage NUMERIC NOT NULL DEFAULT 12,
  tax_percentage NUMERIC NOT NULL DEFAULT 10,
  bank_account_number TEXT,
  ifsc_code TEXT,
  bank_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(employee_id)
);

-- Monthly payroll records
CREATE TABLE public.payroll_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID NOT NULL REFERENCES public.nexus_team_members(id) ON DELETE CASCADE,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INTEGER NOT NULL CHECK (year >= 2020),
  working_days INTEGER NOT NULL DEFAULT 30,
  lop_days INTEGER NOT NULL DEFAULT 0,
  base_pay NUMERIC NOT NULL DEFAULT 0,
  hra NUMERIC NOT NULL DEFAULT 0,
  allowances NUMERIC NOT NULL DEFAULT 0,
  gross_pay NUMERIC NOT NULL DEFAULT 0,
  pf_deduction NUMERIC NOT NULL DEFAULT 0,
  tax_deduction NUMERIC NOT NULL DEFAULT 0,
  lop_deduction NUMERIC NOT NULL DEFAULT 0,
  other_deductions NUMERIC NOT NULL DEFAULT 0,
  bonuses NUMERIC NOT NULL DEFAULT 0,
  net_pay NUMERIC NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'draft',
  remarks TEXT,
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(employee_id, month, year)
);

-- Payroll adjustments
CREATE TABLE public.payroll_adjustments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payroll_record_id UUID NOT NULL REFERENCES public.payroll_records(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  description TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.employee_salary_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payroll_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payroll_adjustments ENABLE ROW LEVEL SECURITY;

-- RLS policies (permissive as per project architecture - auth enforced at app layer)
CREATE POLICY "Allow read access to employee_salary_config" ON public.employee_salary_config FOR SELECT USING (true);
CREATE POLICY "Allow insert access to employee_salary_config" ON public.employee_salary_config FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to employee_salary_config" ON public.employee_salary_config FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to employee_salary_config" ON public.employee_salary_config FOR DELETE USING (true);

CREATE POLICY "Allow read access to payroll_records" ON public.payroll_records FOR SELECT USING (true);
CREATE POLICY "Allow insert access to payroll_records" ON public.payroll_records FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to payroll_records" ON public.payroll_records FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to payroll_records" ON public.payroll_records FOR DELETE USING (true);

CREATE POLICY "Allow read access to payroll_adjustments" ON public.payroll_adjustments FOR SELECT USING (true);
CREATE POLICY "Allow insert access to payroll_adjustments" ON public.payroll_adjustments FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to payroll_adjustments" ON public.payroll_adjustments FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to payroll_adjustments" ON public.payroll_adjustments FOR DELETE USING (true);

-- Trigger for updated_at
CREATE TRIGGER update_salary_config_updated_at
  BEFORE UPDATE ON public.employee_salary_config
  FOR EACH ROW EXECUTE FUNCTION public.update_appraisal_updated_at();

CREATE TRIGGER update_payroll_records_updated_at
  BEFORE UPDATE ON public.payroll_records
  FOR EACH ROW EXECUTE FUNCTION public.update_appraisal_updated_at();
