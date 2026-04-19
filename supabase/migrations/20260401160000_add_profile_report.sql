-- Add target_user_id column for profile reports
ALTER TABLE public.reports ADD COLUMN IF NOT EXISTS target_user_id uuid REFERENCES profiles(id) ON DELETE CASCADE;

-- Replace the old check: exactly one of (post, comment, user) must be set
ALTER TABLE public.reports DROP CONSTRAINT IF EXISTS reports_target_check;
ALTER TABLE public.reports ADD CONSTRAINT reports_target_check CHECK (
  (
    (target_post_id    IS NOT NULL)::int +
    (target_comment_id IS NOT NULL)::int +
    (target_user_id    IS NOT NULL)::int
  ) = 1
);

CREATE INDEX IF NOT EXISTS idx_reports_target_user ON public.reports(target_user_id) WHERE target_user_id IS NOT NULL;

CREATE OR REPLACE FUNCTION public.create_profile_report(
  p_user_id uuid,
  p_category text
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'unauthorized' USING ERRCODE = 'P0001';
  END IF;

  IF auth.uid() = p_user_id THEN
    RAISE EXCEPTION 'cannot_report_self' USING ERRCODE = 'P0001';
  END IF;

  INSERT INTO public.reports (reporter_id, target_user_id, category)
  VALUES (auth.uid(), p_user_id, p_category::report_category_enum);
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_profile_report(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_profile_report(uuid, text) TO service_role;
