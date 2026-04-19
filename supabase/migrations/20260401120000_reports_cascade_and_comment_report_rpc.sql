-- 1) SET NULL on reports FKs breaks reports_target_check when the referenced row is deleted
--    (both target_post_id and target_comment_id become NULL).
-- 2) Direct INSERT into reports from PostgREST sometimes omitted target_comment_id; RPC fixes that.

ALTER TABLE public.reports DROP CONSTRAINT IF EXISTS reports_target_comment_id_fkey;
ALTER TABLE public.reports
  ADD CONSTRAINT reports_target_comment_id_fkey
  FOREIGN KEY (target_comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;

ALTER TABLE public.reports DROP CONSTRAINT IF EXISTS reports_target_post_id_fkey;
ALTER TABLE public.reports
  ADD CONSTRAINT reports_target_post_id_fkey
  FOREIGN KEY (target_post_id) REFERENCES public.posts(id) ON DELETE CASCADE;

CREATE OR REPLACE FUNCTION public.create_comment_report(
  p_comment_id uuid,
  p_category text
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  INSERT INTO public.reports (reporter_id, target_comment_id, category)
  VALUES (auth.uid(), p_comment_id, p_category::report_category_enum);
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_comment_report(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_comment_report(uuid, text) TO service_role;
