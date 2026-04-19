-- Fix hot feed: boosted block sorted by created_at (newest first), not by popularity / expiry;
-- active boost if boost_expires_at is null or still in the future.

CREATE OR REPLACE FUNCTION public.get_hot_feed_post_ids(
  p_now timestamptz,
  p_offset integer,
  p_limit integer
)
RETURNS TABLE (post_id uuid)
LANGUAGE sql
STABLE
AS $$
  WITH vote_counts AS (
    SELECT v.post_id AS pid, COUNT(*)::int AS vote_n
    FROM votes v
    WHERE v.post_id IS NOT NULL
    GROUP BY v.post_id
  ),
  base AS (
    SELECT
      p.id,
      p.created_at,
      (p.likes_count + p.comments_count + COALESCE(vc.vote_n, 0))::bigint AS pop_score,
      CASE
        WHEN p.is_boosted
          AND (p.boost_expires_at IS NULL OR p.boost_expires_at > p_now)
        THEN 0
        ELSE 1
      END AS segment
    FROM posts p
    LEFT JOIN vote_counts vc ON vc.pid = p.id
    WHERE p.status = 'published'
  ),
  ranked AS (
    SELECT
      b.id,
      ROW_NUMBER() OVER (
        ORDER BY
          b.segment ASC,
          CASE WHEN b.segment = 0 THEN b.created_at END DESC NULLS LAST,
          CASE WHEN b.segment = 1 THEN b.pop_score END DESC NULLS LAST,
          CASE WHEN b.segment = 1 THEN b.created_at END DESC NULLS LAST
      ) AS rn
    FROM base b
  )
  SELECT r.id AS post_id
  FROM ranked r
  WHERE r.rn > p_offset
    AND r.rn <= p_offset + p_limit
    AND r.rn <= 100
  ORDER BY r.rn;
$$;
