CREATE OR REPLACE FUNCTION public.create_post_report(
  p_post_id uuid,
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

  INSERT INTO public.reports (reporter_id, target_post_id, category)
  VALUES (auth.uid(), p_post_id, p_category::report_category_enum);
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_post_report(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_post_report(uuid, text) TO service_role;
