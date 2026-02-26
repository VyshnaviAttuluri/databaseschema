
-- Table to store synced team members from NEXUS
CREATE TABLE public.nexus_team_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nexus_user_id uuid NOT NULL UNIQUE,
  email text NOT NULL,
  first_name text,
  last_name text,
  phone text,
  employee_code text,
  department text,
  primary_role text,
  nexus_role_hint text,
  is_active boolean DEFAULT true,
  joined_at timestamptz,
  synced_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.nexus_team_members ENABLE ROW LEVEL SECURITY;

-- Since auth is handled by NEXUS (not Supabase Auth), allow anon access
-- App-level authorization is enforced in the frontend via NEXUS tokens
CREATE POLICY "Allow read access to nexus_team_members"
  ON public.nexus_team_members FOR SELECT
  USING (true);

CREATE POLICY "Allow insert access to nexus_team_members"
  ON public.nexus_team_members FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow update access to nexus_team_members"
  ON public.nexus_team_members FOR UPDATE
  USING (true);

CREATE POLICY "Allow delete access to nexus_team_members"
  ON public.nexus_team_members FOR DELETE
  USING (true);

-- Sync log table
CREATE TABLE public.nexus_sync_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  records_synced integer DEFAULT 0,
  status text NOT NULL DEFAULT 'success',
  error_message text,
  synced_at timestamptz DEFAULT now()
);

ALTER TABLE public.nexus_sync_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to nexus_sync_log"
  ON public.nexus_sync_log FOR SELECT
  USING (true);

CREATE POLICY "Allow insert access to nexus_sync_log"
  ON public.nexus_sync_log FOR INSERT
  WITH CHECK (true);
