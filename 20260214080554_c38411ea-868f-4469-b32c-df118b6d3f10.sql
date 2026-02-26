
-- Create notifications table
CREATE TABLE public.notifications (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  employee_id UUID NOT NULL REFERENCES public.nexus_team_members(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'info', -- 'leave_approved', 'leave_rejected', 'appraisal_reminder', 'info'
  link TEXT, -- route to navigate to, e.g. '/employee/my-leaves'
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Open policies (app uses custom Nexus auth, not Supabase auth)
CREATE POLICY "Allow read access to notifications" ON public.notifications FOR SELECT USING (true);
CREATE POLICY "Allow insert access to notifications" ON public.notifications FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update access to notifications" ON public.notifications FOR UPDATE USING (true);
CREATE POLICY "Allow delete access to notifications" ON public.notifications FOR DELETE USING (true);

-- Enable realtime for notifications
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
