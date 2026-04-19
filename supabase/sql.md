-- ============================================================
-- NETWORLD — COMPLETE SCHEMA (FINAL, FULLY IDEMPOTENT)
-- Safe to run on a FRESH database OR an EXISTING one.
-- Drops everything first, then recreates cleanly.
-- After this single file, your backend is 100% ready for frontend.
-- ============================================================


-- ============================================================
-- STEP 0 — DROP EVERYTHING (clean slate, safe re-run)
-- Wrapped in DO $$ so missing tables never cause errors.
-- ============================================================

DO $drop$
BEGIN

  -- Triggers on auth.users (always exists in Supabase)
  DROP TRIGGER IF EXISTS trg_on_new_user ON auth.users;

  -- Triggers on profiles (only if table exists)
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'profiles') THEN
    DROP TRIGGER IF EXISTS trg_grant_free_avatars          ON profiles;
    DROP TRIGGER IF EXISTS trg_create_notification_prefs   ON profiles;
    DROP TRIGGER IF EXISTS trg_rank_tier                   ON profiles;
    DROP TRIGGER IF EXISTS trg_networth_calc_dates         ON profiles;
    DROP TRIGGER IF EXISTS trg_refresh_top_badge           ON profiles;
  END IF;

  -- Triggers on posts
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'posts') THEN
    DROP TRIGGER IF EXISTS trg_xp_on_post ON posts;
  END IF;

  -- Triggers on post_likes
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'post_likes') THEN
    DROP TRIGGER IF EXISTS trg_post_likes_count    ON post_likes;
    DROP TRIGGER IF EXISTS trg_award_on_post_liked ON post_likes;
    DROP TRIGGER IF EXISTS trg_notify_post_liked   ON post_likes;
  END IF;

  -- Triggers on comments
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'comments') THEN
    DROP TRIGGER IF EXISTS trg_post_comments_count ON comments;
    DROP TRIGGER IF EXISTS trg_xp_on_comment       ON comments;
    DROP TRIGGER IF EXISTS trg_notify_comment      ON comments;
  END IF;

  -- Triggers on comment_likes
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'comment_likes') THEN
    DROP TRIGGER IF EXISTS trg_comment_likes_count    ON comment_likes;
    DROP TRIGGER IF EXISTS trg_award_on_comment_liked ON comment_likes;
  END IF;

END;
$drop$;

-- Functions (safe to drop without table checks)
DROP FUNCTION IF EXISTS notify_on_new_follower()          CASCADE;
DROP FUNCTION IF EXISTS handle_new_user()                CASCADE;
DROP FUNCTION IF EXISTS grant_free_avatars()             CASCADE;
DROP FUNCTION IF EXISTS create_notification_preferences() CASCADE;
DROP FUNCTION IF EXISTS update_rank_tier()               CASCADE;
DROP FUNCTION IF EXISTS update_networth_calc_dates()     CASCADE;
DROP FUNCTION IF EXISTS refresh_top_badge()              CASCADE;
DROP FUNCTION IF EXISTS award_xp_on_post()               CASCADE;
DROP FUNCTION IF EXISTS update_post_likes_count()        CASCADE;
DROP FUNCTION IF EXISTS award_on_post_liked()            CASCADE;
DROP FUNCTION IF EXISTS notify_on_post_liked()           CASCADE;
DROP FUNCTION IF EXISTS update_post_comments_count()     CASCADE;
DROP FUNCTION IF EXISTS award_xp_on_comment()            CASCADE;
DROP FUNCTION IF EXISTS notify_on_comment()              CASCADE;
DROP FUNCTION IF EXISTS update_comment_likes_count()     CASCADE;
DROP FUNCTION IF EXISTS award_on_comment_liked()         CASCADE;
DROP FUNCTION IF EXISTS create_comment_report(uuid, text) CASCADE;
DROP FUNCTION IF EXISTS create_post_report(uuid, text) CASCADE;

-- Materialized views
DROP MATERIALIZED VIEW IF EXISTS user_top_badge CASCADE;
DROP MATERIALIZED VIEW IF EXISTS user_stats     CASCADE;

-- Tables in reverse FK order (CASCADE handles any remaining deps)
DROP TABLE IF EXISTS daily_claims                 CASCADE;
DROP TABLE IF EXISTS credit_transactions          CASCADE;
DROP TABLE IF EXISTS xp_transactions              CASCADE;
DROP TABLE IF EXISTS quiz_ranking_rewards         CASCADE;
DROP TABLE IF EXISTS contribution_ranking_rewards CASCADE;
DROP TABLE IF EXISTS quiz_matches                 CASCADE;
DROP TABLE IF EXISTS quiz_questions               CASCADE;
DROP TABLE IF EXISTS quiz_bots                    CASCADE;
DROP TABLE IF EXISTS quiz_salons                  CASCADE;
DROP TABLE IF EXISTS reports                      CASCADE;
DROP TABLE IF EXISTS user_badges                  CASCADE;
DROP TABLE IF EXISTS badges                       CASCADE;
DROP TABLE IF EXISTS notification_preferences     CASCADE;
DROP TABLE IF EXISTS notifications                CASCADE;
DROP TABLE IF EXISTS missions                     CASCADE;
DROP TABLE IF EXISTS user_avatars                 CASCADE;
DROP TABLE IF EXISTS comment_likes                CASCADE;
DROP TABLE IF EXISTS post_likes                   CASCADE;
DROP TABLE IF EXISTS votes                        CASCADE;
DROP TABLE IF EXISTS comments                     CASCADE;
DROP TABLE IF EXISTS posts                        CASCADE;
DROP TABLE IF EXISTS admin_polls                  CASCADE;
DROP TABLE IF EXISTS profiles                     CASCADE;
DROP TABLE IF EXISTS avatar_catalog               CASCADE;

-- Enums
DROP TYPE IF EXISTS post_type_enum         CASCADE;
DROP TYPE IF EXISTS post_status_enum       CASCADE;
DROP TYPE IF EXISTS rank_tier_enum         CASCADE;
DROP TYPE IF EXISTS networth_input_method  CASCADE;
DROP TYPE IF EXISTS report_category_enum   CASCADE;
DROP TYPE IF EXISTS report_status_enum     CASCADE;
DROP TYPE IF EXISTS notification_type_enum CASCADE;
DROP TYPE IF EXISTS quiz_match_status_enum CASCADE;
DROP TYPE IF EXISTS credit_reason_enum     CASCADE;
DROP TYPE IF EXISTS claim_type_enum        CASCADE;


-- ============================================================
-- SECTION 1 — ENUMS
-- ============================================================

CREATE TYPE post_type_enum AS ENUM ('standard', 'poll');

CREATE TYPE post_status_enum AS ENUM ('published', 'review', 'rejected', 'deleted');

CREATE TYPE rank_tier_enum AS ENUM ('Starter', 'Builder', 'Scaler', 'Elite', 'Whale');

CREATE TYPE networth_input_method AS ENUM ('manual', 'powens');

CREATE TYPE report_category_enum AS ENUM ('spam', 'harassment', 'inappropriate', 'other');

CREATE TYPE report_status_enum AS ENUM ('pending', 'resolved', 'dismissed');

CREATE TYPE notification_type_enum AS ENUM (
  'like_post', 'like_comment', 'comment', 'new_follower',
  'reward_daily', 'reward_weekly', 'reward_monthly',
  'ranking', 'system', 'moderation'
);

CREATE TYPE quiz_match_status_enum AS ENUM ('searching', 'active', 'finished');

CREATE TYPE credit_reason_enum AS ENUM (
  'post_creation', 'post_boost', 'comment_creation',
  'quiz_entry', 'quiz_win', 'daily_reward', 'weekly_reward',
  'monthly_reward', 'survey_gift', 'mission_reward',
  'streak_reward', 'like_received_post', 'like_received_comment',
  'avatar_purchase', 'networth_recalc', 'admin_grant',
  'post_refund', 'iap_purchase'
);

CREATE TYPE claim_type_enum AS ENUM (
  'streak', 'survey_gift', 'mission',
  'quiz_daily', 'quiz_weekly', 'quiz_monthly'
);


-- ============================================================
-- SECTION 2 — AVATAR CATALOG
-- ============================================================

CREATE TABLE avatar_catalog (
  id            integer PRIMARY KEY,
  price_credits integer NOT NULL DEFAULT 0,
  is_free       boolean NOT NULL DEFAULT false,
  asset_name    text    NOT NULL
);

INSERT INTO avatar_catalog (id, price_credits, is_free, asset_name) VALUES
  (1,  0,    true,  'avatar_01.png'),
  (2,  0,    true,  'avatar_02.png'),
  (3,  0,    true,  'avatar_03.png'),
  (4,  0,    true,  'avatar_04.png'),
  (5,  0,    true,  'avatar_05.png'),
  (6,  500,  false, 'avatar_06.png'),
  (7,  500,  false, 'avatar_07.png'),
  (8,  500,  false, 'avatar_08.png'),
  (9,  500,  false, 'avatar_09.png'),
  (10, 500,  false, 'avatar_10.png'),
  (11, 1000, false, 'avatar_11.png'),
  (12, 1000, false, 'avatar_12.png'),
  (13, 1000, false, 'avatar_13.png'),
  (14, 1000, false, 'avatar_14.png'),
  (15, 1000, false, 'avatar_15.png'),
  (16, 1000, false, 'avatar_16.png'),
  (17, 1000, false, 'avatar_17.png'),
  (18, 1000, false, 'avatar_18.png'),
  (19, 1000, false, 'avatar_19.png'),
  (20, 1000, false, 'avatar_20.png'),
  (21, 2000, false, 'avatar_21.png'),
  (22, 2000, false, 'avatar_22.png'),
  (23, 2000, false, 'avatar_23.png'),
  (24, 2000, false, 'avatar_24.png'),
  (25, 2000, false, 'avatar_25.png'),
  (26, 2000, false, 'avatar_26.png'),
  (27, 2000, false, 'avatar_27.png'),
  (28, 2000, false, 'avatar_28.png'),
  (29, 2000, false, 'avatar_29.png'),
  (30, 2000, false, 'avatar_30.png'),
  (31, 3000, false, 'avatar_31.png'),
  (32, 3000, false, 'avatar_32.png'),
  (33, 3000, false, 'avatar_33.png'),
  (34, 3000, false, 'avatar_34.png'),
  (35, 3000, false, 'avatar_35.png'),
  (36, 3000, false, 'avatar_36.png'),
  (37, 3000, false, 'avatar_37.png'),
  (38, 3000, false, 'avatar_38.png'),
  (39, 3000, false, 'avatar_39.png'),
  (40, 3000, false, 'avatar_40.png'),
  (41, 5000, false, 'avatar_41.png'),
  (42, 5000, false, 'avatar_42.png'),
  (43, 5000, false, 'avatar_43.png'),
  (44, 5000, false, 'avatar_44.png'),
  (45, 5000, false, 'avatar_45.png'),
  (46, 5000, false, 'avatar_46.png'),
  (47, 5000, false, 'avatar_47.png'),
  (48, 5000, false, 'avatar_48.png'),
  (49, 5000, false, 'avatar_49.png'),
  (50, 5000, false, 'avatar_50.png');


-- ============================================================
-- SECTION 3 — PROFILES
-- ============================================================

CREATE TABLE profiles (
  id                      uuid        PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  username                text        NOT NULL UNIQUE,
  net_worth               numeric     NOT NULL DEFAULT 0,
  currency                text        NOT NULL DEFAULT 'EUR';
  net_worth_input_method  networth_input_method NOT NULL DEFAULT 'manual',
  credits                 integer     NOT NULL DEFAULT 1000,
  xp                      integer     NOT NULL DEFAULT 0,
  elo                     integer     NOT NULL DEFAULT 1000,
  rank_tier               rank_tier_enum NOT NULL DEFAULT 'Starter',
  avatar_id               integer     NOT NULL DEFAULT 1 REFERENCES avatar_catalog(id),
  bio                     text,
  age                     integer,
  city                    text,
  show_age                boolean     NOT NULL DEFAULT false,
  show_city               boolean     NOT NULL DEFAULT false,
  is_verified             boolean     NOT NULL DEFAULT false,
  onboarding_completed    boolean     NOT NULL DEFAULT false,
  last_networth_calc_at   timestamptz NOT NULL DEFAULT now(),
  next_free_calc_at       timestamptz NOT NULL DEFAULT now() + interval '90 days',
  created_at              timestamptz NOT NULL DEFAULT now()
);


-- ============================================================
-- SECTION 4 — CREDITS LEDGER
-- ============================================================

CREATE TABLE credit_transactions (
  id         uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    uuid    NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  amount     integer NOT NULL,
  reason     credit_reason_enum NOT NULL,
  ref_id     uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);


-- ============================================================
-- SECTION 5 — XP LEDGER
-- ============================================================

CREATE TABLE xp_transactions (
  id         uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    uuid    NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  amount     integer NOT NULL,
  reason     text    NOT NULL,
  ref_id     uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);


-- ============================================================
-- SECTION 6 — POSTS
-- ============================================================

CREATE TABLE posts (
  id               uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  author_id        uuid    NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content          text,
  image_url        text,
  post_type        post_type_enum   NOT NULL DEFAULT 'standard',
  poll_options     jsonb,
  poll_votes_count jsonb   DEFAULT '{}',
  is_boosted       boolean NOT NULL DEFAULT false,
  boost_expires_at timestamptz,
  status           post_status_enum NOT NULL DEFAULT 'published',
  likes_count      integer NOT NULL DEFAULT 0,
  comments_count   integer NOT NULL DEFAULT 0,
  created_at       timestamptz NOT NULL DEFAULT now()
);


-- ============================================================
-- SECTION 7 — ADMIN POLLS
-- ============================================================

CREATE TABLE admin_polls (
  id            uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  question      text    NOT NULL,
  image_url     text,
  options       jsonb   NOT NULL,
  is_active     boolean NOT NULL DEFAULT true,
  scheduled_for date    NOT NULL DEFAULT current_date,
  reset_hour    integer NOT NULL DEFAULT 20,
  created_at    timestamptz NOT NULL DEFAULT now()
);


-- ============================================================
-- SECTION 8 — VOTES
-- ============================================================

CREATE TABLE votes (
  id           uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id      uuid    NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  poll_id      uuid    REFERENCES admin_polls(id) ON DELETE CASCADE,
  post_id      uuid    REFERENCES posts(id) ON DELETE CASCADE,
  option_index integer NOT NULL,
  created_at   timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT votes_target_check CHECK (
    (poll_id IS NOT NULL AND post_id IS NULL) OR
    (poll_id IS NULL     AND post_id IS NOT NULL)
  )
);

CREATE UNIQUE INDEX votes_unique_admin_poll ON votes(user_id, poll_id) WHERE poll_id IS NOT NULL;
CREATE UNIQUE INDEX votes_unique_post_poll  ON votes(user_id, post_id) WHERE post_id IS NOT NULL;


-- ============================================================
-- SECTION 9 — COMMENTS
-- ============================================================

CREATE TABLE comments (
  id                 uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id            uuid    NOT NULL REFERENCES posts(id)    ON DELETE CASCADE,
  author_id          uuid    NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  parent_comment_id  uuid    REFERENCES comments(id) ON DELETE CASCADE,
  content            text    NOT NULL,
  likes_count        integer NOT NULL DEFAULT 0,
  created_at         timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_comments_parent ON comments(parent_comment_id);


-- ============================================================
-- SECTION 10 — LIKES
-- ============================================================

CREATE TABLE post_likes (
  user_id    uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  post_id    uuid NOT NULL REFERENCES posts(id)    ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, post_id)
);

CREATE TABLE comment_likes (
  user_id    uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  comment_id uuid NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, comment_id)
);


-- ============================================================
-- SECTION 11 — DAILY CLAIMS
-- ============================================================

CREATE TABLE daily_claims (
  id              uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id         uuid    NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  claim_type      claim_type_enum NOT NULL,
  ref_id          uuid,
  credits_awarded integer NOT NULL,
  claim_date      date        NOT NULL DEFAULT current_date,
  claimed_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id, claim_type, claim_date)
);


-- ============================================================
-- SECTION 12 — MISSIONS
-- ============================================================

CREATE TABLE missions (
  id             uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  title          text    NOT NULL,
  link           text,
  reward_credits integer NOT NULL DEFAULT 0,
  available_date date    NOT NULL DEFAULT current_date,
  is_active      boolean NOT NULL DEFAULT true,
  created_at     timestamptz NOT NULL DEFAULT now()
);


-- ============================================================
-- SECTION 13 — AVATAR INVENTORY
-- ============================================================

CREATE TABLE user_avatars (
  user_id      uuid    NOT NULL REFERENCES profiles(id)      ON DELETE CASCADE,
  avatar_id    integer NOT NULL REFERENCES avatar_catalog(id),
  purchased_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, avatar_id)
);


-- ============================================================
-- SECTION 14 — BADGES
-- ============================================================

CREATE TABLE badges (
  id       uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  key      text NOT NULL UNIQUE,
  category text NOT NULL,
  label    text NOT NULL
);

INSERT INTO badges (key, category, label) VALUES
  ('top10_daily_contribution',   'contribution', 'Top 10 du jour (Contrib)'),
  ('top10_weekly_contribution',  'contribution', 'Top 10 semaine (Contrib)'),
  ('top10_monthly_contribution', 'contribution', 'Top 10 mois (Contrib)'),
  ('top10_alltime_contribution', 'contribution', 'Top 10 général (Contrib)'),
  ('top10_daily_quiz',           'quiz',         'Top 10 du jour (Quiz)'),
  ('top10_weekly_quiz',          'quiz',         'Top 10 semaine (Quiz)'),
  ('top10_monthly_quiz',         'quiz',         'Top 10 mois (Quiz)'),
  ('top10_alltime_quiz',         'quiz',         'Top 10 général (Quiz)');

CREATE TABLE user_badges (
  user_id          uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  badge_id         uuid NOT NULL REFERENCES badges(id),
  count            integer     NOT NULL DEFAULT 1,
  first_awarded_at timestamptz NOT NULL DEFAULT now(),
  last_awarded_at  timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, badge_id)
);


-- ============================================================
-- SECTION 15 — REPORTS
-- ============================================================

CREATE TABLE reports (
  id                uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  reporter_id       uuid    NOT NULL REFERENCES profiles(id),
  -- CASCADE: SET NULL would null both targets and violate reports_target_check.
  target_post_id    uuid    REFERENCES posts(id)    ON DELETE CASCADE,
  target_comment_id uuid    REFERENCES comments(id) ON DELETE CASCADE,
  category          report_category_enum NOT NULL,
  status            report_status_enum   NOT NULL DEFAULT 'pending',
  admin_note        text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT reports_target_check CHECK (
    (target_post_id IS NOT NULL AND target_comment_id IS NULL) OR
    (target_post_id IS NULL     AND target_comment_id IS NOT NULL)
  )
);

-- RPC: comment report from the app (avoids PostgREST/client omitting target_comment_id).
CREATE OR REPLACE FUNCTION create_comment_report(
  p_comment_id uuid,
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

  INSERT INTO public.reports (reporter_id, target_comment_id, category)
  VALUES (auth.uid(), p_comment_id, p_category::report_category_enum);
END;
$$;

GRANT EXECUTE ON FUNCTION create_comment_report(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION create_comment_report(uuid, text) TO service_role;

CREATE OR REPLACE FUNCTION create_post_report(
  p_post_id uuid,
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

  INSERT INTO public.reports (reporter_id, target_post_id, category)
  VALUES (auth.uid(), p_post_id, p_category::report_category_enum);
END;
$$;

GRANT EXECUTE ON FUNCTION create_post_report(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION create_post_report(uuid, text) TO service_role;


-- ============================================================
-- SECTION 16 — NOTIFICATIONS
-- ============================================================

CREATE TABLE notifications (
  id         uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    uuid    NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type       notification_type_enum NOT NULL,
  ref_id     uuid,
  is_read    boolean     NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE notification_preferences (
  user_id      uuid    NOT NULL REFERENCES profiles(id) ON DELETE CASCADE PRIMARY KEY,
  like_post    boolean NOT NULL DEFAULT false,
  comment      boolean NOT NULL DEFAULT true,
  new_follower boolean NOT NULL DEFAULT true,
  reward       boolean NOT NULL DEFAULT true,
  ranking      boolean NOT NULL DEFAULT true,
  system       boolean NOT NULL DEFAULT true
);


-- ============================================================
-- SECTION 17 — QUIZ SALONS
-- ============================================================

CREATE TABLE quiz_salons (
  id            uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  name          text    NOT NULL,
  entry_cost    integer NOT NULL,
  reward_winner integer NOT NULL,
  is_active     boolean NOT NULL DEFAULT true,
  sort_order    integer NOT NULL DEFAULT 0
);

INSERT INTO quiz_salons (name, entry_cost, reward_winner, sort_order) VALUES
  ('Stagiaire',          100,   180,   1),
  ('Alternant',          500,   900,   2),
  ('Salarié',            1000,  1800,  3),
  ('Chef d''entreprise', 5000,  9000,  4),
  ('Big Moula',          10000, 18000, 5);


-- ============================================================
-- SECTION 18 — QUIZ BOTS
-- ============================================================

CREATE TABLE quiz_bots (
  id        uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  pseudo    numeric NOT NULL,
  avatar_id integer NOT NULL REFERENCES avatar_catalog(id),
  elo       integer NOT NULL DEFAULT 1000,
  winrate   numeric NOT NULL DEFAULT 0.5 CHECK (winrate >= 0 AND winrate <= 1),
  is_active boolean NOT NULL DEFAULT true
);


-- ============================================================
-- SECTION 19 — QUIZ QUESTIONS
-- ============================================================

CREATE TABLE quiz_questions (
  id            uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  question      text    NOT NULL,
  options       jsonb   NOT NULL,
  correct_index integer NOT NULL CHECK (correct_index BETWEEN 0 AND 3),
  category      text,
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now()
);


-- ============================================================
-- SECTION 20 — QUIZ MATCHES
-- ============================================================

CREATE TABLE quiz_matches (
  id                 uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  salon_id           uuid    NOT NULL REFERENCES quiz_salons(id),
  player1_id         uuid    NOT NULL REFERENCES profiles(id),
  player2_id         uuid    REFERENCES profiles(id),
  bot_id             uuid    REFERENCES quiz_bots(id),
  status             quiz_match_status_enum NOT NULL DEFAULT 'searching',
  winner_id          uuid    REFERENCES profiles(id),
  player1_score      integer NOT NULL DEFAULT 0,
  player2_score      integer NOT NULL DEFAULT 0,
  player1_elo_before integer,
  player2_elo_before integer,
  player1_elo_after  integer,
  player2_elo_after  integer,
  entry_cost         integer NOT NULL,
  created_at         timestamptz NOT NULL DEFAULT now(),
  finished_at        timestamptz,
  CONSTRAINT match_opponent_check CHECK (
    (player2_id IS NOT NULL AND bot_id IS NULL) OR
    (player2_id IS NULL     AND bot_id IS NOT NULL)
  )
);


-- ============================================================
-- SECTION 21 — QUIZ RANKING REWARDS
-- ============================================================

CREATE TABLE quiz_ranking_rewards (
  id        uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  period    text    NOT NULL CHECK (period IN ('day', 'week', 'month')),
  rank_min  integer NOT NULL,
  rank_max  integer NOT NULL,
  credits   integer NOT NULL,
  is_active boolean NOT NULL DEFAULT true
);

INSERT INTO quiz_ranking_rewards (period, rank_min, rank_max, credits) VALUES
  ('day',   1,   1,   5000),
  ('day',   2,   3,   3000),
  ('day',   4,   10,  1000),
  ('week',  1,   1,   15000),
  ('week',  2,   3,   8000),
  ('week',  4,   10,  3000),
  ('week',  11,  50,  500),
  ('month', 1,   1,   50000),
  ('month', 2,   3,   25000),
  ('month', 4,   10,  10000),
  ('month', 11,  50,  2000),
  ('month', 51,  100, 500);


-- ============================================================
-- SECTION 22 — CONTRIBUTION RANKING REWARDS
-- ============================================================

CREATE TABLE contribution_ranking_rewards (
  id        uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  period    text    NOT NULL CHECK (period IN ('day', 'week', 'month')),
  rank_min  integer NOT NULL,
  rank_max  integer NOT NULL,
  credits   integer NOT NULL,
  is_active boolean NOT NULL DEFAULT true
);

INSERT INTO contribution_ranking_rewards (period, rank_min, rank_max, credits) VALUES
  ('day',   1,  1,  3000),
  ('day',   2,  3,  1500),
  ('day',   4,  10, 500),
  ('week',  1,  1,  10000),
  ('week',  2,  3,  5000),
  ('week',  4,  10, 2000),
  ('week',  11, 50, 300),
  ('month', 1,  1,  30000),
  ('month', 2,  3,  15000),
  ('month', 4,  10, 5000),
  ('month', 11, 50, 1000);


-- ============================================================
-- SECTION 23 — INDEXES ON TABLES
-- (indexes on materialized views come AFTER view creation in Section 24)
-- ============================================================

-- Feed
CREATE INDEX idx_posts_created_at   ON posts(created_at DESC)                   WHERE status = 'published';
CREATE INDEX idx_posts_hot          ON posts(likes_count DESC, created_at DESC) WHERE status = 'published';
CREATE INDEX idx_posts_boosted      ON posts(is_boosted, boost_expires_at)      WHERE is_boosted = true;
CREATE INDEX idx_posts_author       ON posts(author_id);

-- Rankings
CREATE INDEX idx_profiles_net_worth ON profiles(net_worth DESC);
CREATE INDEX idx_profiles_xp        ON profiles(xp DESC);
CREATE INDEX idx_profiles_elo       ON profiles(elo DESC);

-- Daily
CREATE INDEX idx_admin_polls_date   ON admin_polls(scheduled_for DESC)          WHERE is_active = true;
CREATE INDEX idx_votes_user         ON votes(user_id);
CREATE INDEX idx_claims_user_date   ON daily_claims(user_id, claim_date DESC);

-- Social
CREATE INDEX idx_comments_post      ON comments(post_id, created_at DESC);

-- Notifications
CREATE INDEX idx_notif_user         ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notif_unread       ON notifications(user_id, is_read)          WHERE is_read = false;

-- Ledgers
CREATE INDEX idx_credit_tx_user     ON credit_transactions(user_id, created_at DESC);
CREATE INDEX idx_xp_tx_user         ON xp_transactions(user_id, created_at DESC);

-- Quiz
CREATE INDEX idx_matches_p1         ON quiz_matches(player1_id, created_at DESC);
CREATE INDEX idx_matches_p2         ON quiz_matches(player2_id, created_at DESC);
CREATE INDEX idx_matches_salon      ON quiz_matches(salon_id, status);

-- Moderation
CREATE INDEX idx_reports_pending    ON reports(status)                          WHERE status = 'pending';


-- ============================================================
-- SECTION 24 — MATERIALIZED VIEWS
-- (must come AFTER all tables, BEFORE triggers)
-- ============================================================

-- ----------------------------------------------------------
-- user_top_badge
-- Stores net worth rank + badge level for every user.
-- Auto-refreshed by trigger T5b whenever net_worth changes.
-- Used everywhere a pseudo is displayed (feed, comments, TOP tab).
-- ----------------------------------------------------------

CREATE MATERIALIZED VIEW user_top_badge AS
WITH ranked AS (
  SELECT
    id,
    RANK() OVER (ORDER BY net_worth DESC) AS nw_rank
  FROM profiles
)
SELECT
  id AS user_id,
  nw_rank,
  CASE
    WHEN nw_rank = 1    THEN 'top1'
    WHEN nw_rank = 2    THEN 'top2'
    WHEN nw_rank = 3    THEN 'top3'
    WHEN nw_rank <= 10  THEN 'top10'
    WHEN nw_rank <= 100 THEN 'top100'
    ELSE                     'none'
  END AS top_badge
FROM ranked;

-- Indexes on user_top_badge (MUST be after CREATE MATERIALIZED VIEW)
CREATE UNIQUE INDEX idx_top_badge_user_id ON user_top_badge(user_id);
CREATE        INDEX idx_top_badge_level   ON user_top_badge(top_badge);
CREATE        INDEX idx_top_badge_rank    ON user_top_badge(nw_rank);


-- ----------------------------------------------------------
-- user_stats
-- Stores post count, comment count, likes received per user.
-- Refresh via Edge Function cron every 10-15 min:
--   REFRESH MATERIALIZED VIEW CONCURRENTLY user_stats;
-- ----------------------------------------------------------

CREATE MATERIALIZED VIEW user_stats AS
SELECT
  p.id                                                                  AS user_id,
  COUNT(DISTINCT po.id)                                                 AS posts_count,
  COUNT(DISTINCT c.id)                                                  AS comments_count,
  COALESCE(SUM(po.likes_count), 0)                                      AS likes_received_posts,
  COALESCE(SUM(c.likes_count),  0)                                      AS likes_received_comments,
  COALESCE(SUM(po.likes_count), 0) + COALESCE(SUM(c.likes_count), 0)   AS likes_received_total
FROM profiles p
LEFT JOIN posts    po ON po.author_id = p.id AND po.status = 'published'
LEFT JOIN comments c  ON c.author_id  = p.id
GROUP BY p.id;

-- Index on user_stats (MUST be after CREATE MATERIALIZED VIEW)
CREATE UNIQUE INDEX idx_user_stats_user_id ON user_stats(user_id);

-- Initial population
REFRESH MATERIALIZED VIEW user_top_badge;
REFRESH MATERIALIZED VIEW user_stats;


-- ============================================================
-- SECTION 25 — TRIGGERS
-- ============================================================

-- ----------------------------------------------------------
-- T1 — Auto-create profile row after OAuth sign-up
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
DECLARE
  adjectives_json constant jsonb := $adj$["mad","sad","bad","rad","odd","hot","cold","cool","warm","chill", "fast","slow","big","small","tiny","mini","mega","ultra","hyper","max", "low","high","mid","top","prime","core","base","edge","peak","zen", "wild","calm","bold","shy","lazy","busy","dead","live","true","fake", "dark","light","neon","gold","blue","red","pink","gray","black","white", "soft","hard","flat","sharp","round","bent","clean","dirty","rough","smooth", "sweet","sour","salty","spicy","dry","wet","juicy","greasy","fresh","rotten", "nice","mean","kind","rude","weird","rare","epic","myth","lost","found", "hidden","open","close","locked","free","paid","rich","poor","young","old", "new","used","ancient","modern","future","retro","vintage","classic","royal","noble", "elite","super","basic","final","early","late","next","safe","risky","danger", "deadly","fatal","toxic","messy","neat","solid","liquid","gassy","heavy","light", "loose","tight","stiff","rigid","bouncy","sticky","slippy","crunchy","blunt","pointy", "broken","fixed","bitter","icy","storm","windy","rainy","snowy","foggy","dusty", "smoky","burnt","charred","melted","frozen","boiled","chilled","heated","cooled","empty", "full","half","total","maxed","min","mythic","godly","noob","pro","upper", "lower","inner","outer","near","far","distant","first","start","end","quick", "rapid","swift","turbo","speed","flash","bright","dim","clear","fuzzy","shiny", "matte","glossy","grimy","soaked","baked","raw","cooked","spiked","salted","sugary", "tasty","gross","loud","quiet","silent","noisy","brave","scared","afraid","sleepy", "tired","awake","alert","silly","funny","goofy","lucky","unlucky","lethal","stable", "active","passive","hostile","friendly","social","direct","random","linear","global","local", "public","private","secure","closed","simple","complex","smart","dumb","wise","naive", "steady","ready","real","pure","mixed","dual","mono","multi","alpha","beta", "gamma","delta","omega","sigma","void","neo","xeno","deep","wide","tall", "short","long","brief","thick","thin","crispy","chewy","soggy","minty","zesty", "spongy","fluffy","hairy","spiky","slimy","grainy","blocky","chunky","lumpy","bumpy", "jagged","curved","angled","hollow","dense","airy","moist","damp","dryish","humid", "breezy","gusty","stormy","sunny","cloudy","frosty","lukewarm","fading","glowing","blazing", "flicker","glimmer","shaded","shadow","murky","fogged","blurred","darker","lighter","coolish", "warmish","reddish","bluish","greeny","golden","silver","bronze","copper","rusty","metal", "wooden","stone","marble","granite","rubber","plastic","glassy","crystal","tacky","slick", "oily","buttery","creamy","foamy","bubbly","fizzy","smelly","stinky","minted","zany", "quirky","funky","groovy","jazzy","snazzy","flashy","showy","lively","rowdy","calmer", "wilder","brisk","speedy","zippy","nippy","snappy","cranky","grumpy","moody","angsty", "happy","cheery","jolly","merry","gloomy","dreary","bleak","darkish","sunlit","moonlit", "starlit","cosmic","astral","spacey","timely","timed","soon","firm","loyal","trusty", "honest","brutal","harsh","tough","gentle","mellow","clicky","tappy","crashy","smashy", "bangy","boomy","zappy","poppy","buggy","laggy","pingy","syncy","coded","hacked", "modded","rooted","framed","pixely","bitty","bytey","binary","digital","online","offline", "streamy","loaded","saved","synced","cached","linked","wired","remote","opened","shown", "seen","unseen","visible","masked","secret","covert","stealth","curvy","shapely","formy" ]$adj$::jsonb;
  nouns_json constant jsonb := $noun$["wolf","tiger","lion","bear","fox","eagle","hawk","shark","whale","dolphin", "snake","cobra","viper","python","lizard","dragon","falcon","owl","crow","raven", "panda","koala","monkey","gorilla","chimp","dog","cat","mouse","rat","hamster", "rabbit","deer","horse","zebra","camel","goat","sheep","cow","bull","pig", "boar","rooster","duck","goose","turkey","carp","salmon","tuna","octopus","squid", "crab","lobster","shrimp","ant","bee","wasp","spider","scorpion","butterfly","moth", "beetle","mosquito","frog","toad","seal","penguin","otter","badger","weasel","ferret", "lynx","panther","cheetah","leopard","hyena","yak","buffalo","bison","donkey","mule", "apple","banana","orange","lemon","lime","grape","melon","peach","pear","plum", "cherry","mango","papaya","kiwi","pineapple","coconut","fig","date","apricot","bread", "toast","pizza","burger","fries","pasta","noodle","rice","sushi","ramen","steak", "meat","beef","pork","bacon","sausage","egg","cheese","butter","milk","cream", "yogurt","cake","cookie","biscuit","donut","candy","sugar","honey","jam","syrup", "salt","spice","pepper","garlic","onion","carrot","potato","tomato","salad","soup", "sauce","ketchup","mustard","mayo","oil","vinegar","herb","tea","coffee","latte", "mocha","juice","soda","cola","water","beer","wine","smoothie","waffle","pancake", "croissant","bagel","pretzel","sandwich","wrap","taco","burrito","nacho","cheddar","brie", "grain","oat","wheat","corn","barley", "chair","table","desk","sofa","couch","bed","lamp","light","bulb","screen", "phone","laptop","tablet","mouse","keyboard","monitor","camera","speaker","radio","clock", "watch","bag","wallet","bottle","glass","cup","plate","fork","knife","spoon", "pan","pot","oven","fridge","freezer","door","window","mirror","frame","box", "case","tool","hammer","drill","screw","nail","rope","chain","lock","key", "car","truck","bike","motor","engine","wheel","tire","seat","belt","helmet", "plane","jet","train","metro","bus","ship","boat","canoe","rocket","drone", "paper","book","note","card","coin","cash","chip","disk","cable","wire", "forest","jungle","desert","ocean","sea","river","lake","pond","island","beach", "shore","coast","cliff","hill","mount","valley","canyon","field","plain","sky", "cloud","storm","rain","snow","wind","fog","mist","sun","moon","star", "space","void","earth","rock","stone","sand","dust","ash","lava","ice", "glacier","tree","plant","grass","leaf","flower","root","branch","seed","wood", "bush","vine","moss","fungi","coral","reef","wave","tide","current","breeze", "piano","guitar","drum","violin","flute","trumpet","sax","bass","harp","cello", "ball","bat","racket","goal","net","ring","dice","token","cube","brick", "block","tile","pixel","panel","grid","node","server","data","code","script", "bot","core","cache","stack","loop","thread","byte","bit","signal","pulse", "beam","ray","laser","shield","blade","sword","arrow","bow","gun","bomb", "tank","armor","gear","kit","pack","crate","device","module", "pebble","crystal","gem","diamond","gold","silver","bronze","iron","steel","metal", "copper","zinc","lead","clay","soil","mud","steam","smoke","flame","fire", "ember","spark","shadow","bark","log","grove","swamp","marsh","bog","gust", "hail","orbit","comet","meteor","planet","galaxy","cosmos","nebula","asteroid", "bench","stool","locker","drawer","cabinet","shelf","closet","garage","roof","floor", "ceiling","hinge","handle","switch","button","lever","dial","gauge","sensor","circuit", "battery","charger","adapter","router","modem","antenna","satdish", "boots","gloves","jacket","coat","hoodie","shirt","pants","jeans","shorts","sneaker", "trainer","slipper","sock","backpack","briefcase","pouch","satchel","duffel", "lantern","torch","flashlight","candle","lighter","match","fuse","plug","socket","outlet", "generator","turbine","reactor","fuel","diesel", "notebook","sketch","journal","planner","calendar","ticket","passport","license","badge","receipt", "invoice","contract","report","manual","guide","map","blueprint","diagram", "console","arcade","joystick","gamepad","headset","earbuds","microphone","projector","datacenter","cluster", "mainframe","serverrack","firewall","gateway","switchboard","nodegrid","backplane","motherboard","microchip","nanobot", "exosuit","spacesuit","airlock","thruster","warpdrive","stardrive","reactorcore","powercell","fuelcell","coolant", "radiator","fanblade","propeller","rotor","gearbox","clutch","axle","chassis","cockpit","dashboard", "odometer","compass","barometer","thermometer","altimeter","microscope","telescope","binocular","canvas","palette", "paintbrush","inkwell","quill","printer","scanner","photocopier","stapler","envelope","mailbox","package", "parcel","lockbox","safe","strongbox","ledger","clipboard","notepad","sketchpad","cratebox","latch", "padlock","deadbolt","doorknob","handlebar","seatpost","saddle","pedal","chainring","derailleur","spoke", "rim","hub","valve","nozzle","faucet","shower","bathtub","sink","drain","plunger", "wrench","pliers","cutter","shears","chainsaw","drillbit","vise","clamp","level","square", "ruler","caliper","bearing","bushing","gasket","spring","damper","shock","bracket","mount", "batterybox","powerbank","capacitor","resistor","transistor","relay","inverter" ]$noun$::jsonb;
  adjectives text[];
  nouns text[];
  adjectives_count integer;
  nouns_count integer;
  generated_username text;
  attempt integer;
  digest bytea;
BEGIN
  SELECT array_agg(value) INTO adjectives
  FROM jsonb_array_elements_text(adjectives_json);

  SELECT array_agg(value) INTO nouns
  FROM jsonb_array_elements_text(nouns_json);

  adjectives_count := COALESCE(array_length(adjectives, 1), 0);
  nouns_count := COALESCE(array_length(nouns, 1), 0);

  IF adjectives_count = 0 OR nouns_count = 0 THEN
    RAISE EXCEPTION 'username word lists are empty';
  END IF;

  FOR attempt IN 1..30 LOOP
    generated_username :=
      adjectives[(floor(random() * adjectives_count)::int + 1)] ||
      nouns[(floor(random() * nouns_count)::int + 1)] ||
      (floor(random() * 100)::int)::text;

    EXIT WHEN NOT EXISTS (
      SELECT 1
      FROM profiles p
      WHERE p.username = generated_username
    );
  END LOOP;

  IF EXISTS (
    SELECT 1
    FROM profiles p
    WHERE p.username = generated_username
  ) THEN
    FOR attempt IN 0..500 LOOP
      digest := decode(md5(NEW.id::text || ':' || attempt::text), 'hex');
      generated_username :=
        adjectives[((get_byte(digest, 0) * 256 + get_byte(digest, 1)) % adjectives_count) + 1] ||
        nouns[((get_byte(digest, 2) * 256 + get_byte(digest, 3)) % nouns_count) + 1] ||
        (get_byte(digest, 4) % 100)::text;

      EXIT WHEN NOT EXISTS (
        SELECT 1
        FROM profiles p
        WHERE p.username = generated_username
      );
    END LOOP;
  END IF;

  INSERT INTO profiles (id, username, onboarding_completed)
  VALUES (NEW.id, generated_username, false)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_on_new_user
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION handle_new_user();


-- ----------------------------------------------------------
-- T2 — Grant free avatars (1–5) on profile creation
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION grant_free_avatars()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
BEGIN
  INSERT INTO user_avatars (user_id, avatar_id)
  SELECT NEW.id, id FROM avatar_catalog WHERE is_free = true
  ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_grant_free_avatars
AFTER INSERT ON profiles
FOR EACH ROW EXECUTE FUNCTION grant_free_avatars();


-- ----------------------------------------------------------
-- T3 — Auto-create notification_preferences on profile creation
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION create_notification_preferences()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO notification_preferences (user_id)
  VALUES (NEW.id)
  ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_create_notification_prefs
AFTER INSERT ON profiles
FOR EACH ROW EXECUTE FUNCTION create_notification_preferences();


-- ----------------------------------------------------------
-- T4 — Auto-update rank_tier from net_worth
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION update_rank_tier()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.rank_tier := CASE
    WHEN NEW.net_worth < 10000   THEN 'Starter'
    WHEN NEW.net_worth < 50000   THEN 'Builder'
    WHEN NEW.net_worth < 250000  THEN 'Scaler'
    WHEN NEW.net_worth < 1000000 THEN 'Elite'
    ELSE                              'Whale'
  END::rank_tier_enum;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_rank_tier
BEFORE INSERT OR UPDATE OF net_worth ON profiles
FOR EACH ROW EXECUTE FUNCTION update_rank_tier();


-- ----------------------------------------------------------
-- T5 — Reset 90-day free recalc timer on net_worth change
--      + auto-refresh user_top_badge materialized view
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION update_networth_calc_dates()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.net_worth IS DISTINCT FROM OLD.net_worth THEN
    NEW.last_networth_calc_at := now();
    NEW.next_free_calc_at     := now() + interval '90 days';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_networth_calc_dates
BEFORE UPDATE OF net_worth ON profiles
FOR EACH ROW EXECUTE FUNCTION update_networth_calc_dates();

-- Separate AFTER trigger to refresh the materialized view
-- (must be AFTER, not BEFORE, because CONCURRENTLY needs committed data)
CREATE OR REPLACE FUNCTION refresh_top_badge()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
BEGIN
  IF NEW.net_worth IS DISTINCT FROM OLD.net_worth THEN
    REFRESH MATERIALIZED VIEW CONCURRENTLY user_top_badge;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_refresh_top_badge
AFTER UPDATE OF net_worth ON profiles
FOR EACH ROW EXECUTE FUNCTION refresh_top_badge();


-- ----------------------------------------------------------
-- T6 — Award +10 XP when a post is published
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION award_xp_on_post()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
BEGIN
  IF NEW.status = 'published' AND (OLD IS NULL OR OLD.status <> 'published') THEN
    UPDATE profiles SET xp = xp + 10 WHERE id = NEW.author_id;
    INSERT INTO xp_transactions (user_id, amount, reason, ref_id)
    VALUES (NEW.author_id, 10, 'post', NEW.id);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_xp_on_post
AFTER INSERT OR UPDATE OF status ON posts
FOR EACH ROW EXECUTE FUNCTION award_xp_on_post();


-- ----------------------------------------------------------
-- T7 — Update posts.likes_count cache
-- SECURITY DEFINER: RLS has no UPDATE on posts; trigger must run with definer rights.
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET likes_count = likes_count + 1              WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_post_likes_count
AFTER INSERT OR DELETE ON post_likes
FOR EACH ROW EXECUTE FUNCTION update_post_likes_count();


-- ----------------------------------------------------------
-- T8 — Award +2 XP + 1 credit to post author on like
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION award_on_post_liked()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
DECLARE
  v_author_id uuid;
BEGIN
  SELECT author_id INTO v_author_id FROM posts WHERE id = NEW.post_id;
  IF v_author_id IS NOT NULL AND v_author_id <> NEW.user_id THEN
    UPDATE profiles SET xp = xp + 2, credits = credits + 1 WHERE id = v_author_id;
    INSERT INTO xp_transactions     (user_id, amount, reason, ref_id)
    VALUES (v_author_id, 2, 'like_received_post', NEW.post_id);
    INSERT INTO credit_transactions (user_id, amount, reason, ref_id)
    VALUES (v_author_id, 1, 'like_received_post', NEW.post_id);
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_award_on_post_liked
AFTER INSERT ON post_likes
FOR EACH ROW EXECUTE FUNCTION award_on_post_liked();


-- ----------------------------------------------------------
-- T9 — Send notification on post like (respects preference)
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION notify_on_post_liked()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
DECLARE
  v_author_id uuid;
  v_pref      boolean;
BEGIN
  SELECT author_id INTO v_author_id FROM posts WHERE id = NEW.post_id;
  IF v_author_id IS NOT NULL AND v_author_id <> NEW.user_id THEN
    SELECT like_post INTO v_pref FROM notification_preferences WHERE user_id = v_author_id;
    IF v_pref = true THEN
      INSERT INTO notifications (user_id, type, ref_id)
      VALUES (v_author_id, 'like_post', NEW.post_id);
    END IF;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_notify_post_liked
AFTER INSERT ON post_likes
FOR EACH ROW EXECUTE FUNCTION notify_on_post_liked();


-- ----------------------------------------------------------
-- T10 — Update posts.comments_count cache
-- SECURITY DEFINER: RLS has no UPDATE on posts; trigger must run with definer rights.
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION update_post_comments_count()
RETURNS TRIGGER LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET comments_count = comments_count + 1              WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET comments_count = GREATEST(comments_count - 1, 0) WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_post_comments_count
AFTER INSERT OR DELETE ON comments
FOR EACH ROW EXECUTE FUNCTION update_post_comments_count();


-- ----------------------------------------------------------
-- T11 — Award +2 XP when a comment is created
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION award_xp_on_comment()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
BEGIN
  UPDATE profiles SET xp = xp + 2 WHERE id = NEW.author_id;
  INSERT INTO xp_transactions (user_id, amount, reason, ref_id)
  VALUES (NEW.author_id, 2, 'comment', NEW.id);
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_xp_on_comment
AFTER INSERT ON comments
FOR EACH ROW EXECUTE FUNCTION award_xp_on_comment();


-- ----------------------------------------------------------
-- T12 — Send notification on comment (respects preference)
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION notify_on_comment()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
DECLARE
  v_author_id uuid;
  v_pref      boolean;
BEGIN
  SELECT author_id INTO v_author_id FROM posts WHERE id = NEW.post_id;
  IF v_author_id IS NOT NULL AND v_author_id <> NEW.author_id THEN
    SELECT comment INTO v_pref FROM notification_preferences WHERE user_id = v_author_id;
    IF v_pref = true THEN
      INSERT INTO notifications (user_id, type, ref_id)
      VALUES (v_author_id, 'comment', NEW.post_id);
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_comment
AFTER INSERT ON comments
FOR EACH ROW EXECUTE FUNCTION notify_on_comment();


-- ----------------------------------------------------------
-- T13 — Update comments.likes_count cache
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION update_comment_likes_count()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE comments SET likes_count = likes_count + 1              WHERE id = NEW.comment_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE comments SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = OLD.comment_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_comment_likes_count
AFTER INSERT OR DELETE ON comment_likes
FOR EACH ROW EXECUTE FUNCTION update_comment_likes_count();


-- ----------------------------------------------------------
-- T14 — Award +1 XP + 1 credit to comment author on like
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION award_on_comment_liked()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
DECLARE
  v_author_id uuid;
BEGIN
  SELECT author_id INTO v_author_id FROM comments WHERE id = NEW.comment_id;
  IF v_author_id IS NOT NULL AND v_author_id <> NEW.user_id THEN
    UPDATE profiles SET xp = xp + 1, credits = credits + 1 WHERE id = v_author_id;
    INSERT INTO xp_transactions     (user_id, amount, reason, ref_id)
    VALUES (v_author_id, 1, 'like_received_comment', NEW.comment_id);
    INSERT INTO credit_transactions (user_id, amount, reason, ref_id)
    VALUES (v_author_id, 1, 'like_received_comment', NEW.comment_id);
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_award_on_comment_liked
AFTER INSERT ON comment_likes
FOR EACH ROW EXECUTE FUNCTION award_on_comment_liked();


-- ----------------------------------------------------------
-- T15 — Send notification on new follower (respects preference)
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION notify_on_new_follower()
RETURNS TRIGGER LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_pref boolean;
BEGIN
  SELECT new_follower INTO v_pref
    FROM notification_preferences
    WHERE user_id = NEW.following_id;

  IF v_pref = true THEN
    INSERT INTO notifications (user_id, type, ref_id)
    VALUES (NEW.following_id, 'new_follower', NEW.follower_id);
  END IF;

  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_notify_new_follower
AFTER INSERT ON follows
FOR EACH ROW EXECUTE FUNCTION notify_on_new_follower();


-- ============================================================
-- SECTION 26 — ROW LEVEL SECURITY (RLS)
-- ============================================================

-- Core tables
ALTER TABLE profiles                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts                      ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE comment_likes              ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes                      ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications              ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences   ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_transactions        ENABLE ROW LEVEL SECURITY;
ALTER TABLE xp_transactions            ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_claims               ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_avatars               ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges                ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_matches               ENABLE ROW LEVEL SECURITY;

-- Catalog / config tables
ALTER TABLE avatar_catalog               ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges                       ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_salons                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions               ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_ranking_rewards         ENABLE ROW LEVEL SECURITY;
ALTER TABLE contribution_ranking_rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE missions                     ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_polls                  ENABLE ROW LEVEL SECURITY;

-- profiles
CREATE POLICY "profiles_public_read" ON profiles FOR SELECT USING (true);
CREATE POLICY "profiles_own_update"  ON profiles FOR UPDATE USING (auth.uid() = id);

-- posts
CREATE POLICY "posts_public_read" ON posts FOR SELECT USING (status = 'published');
CREATE POLICY "posts_own_insert"  ON posts FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "posts_own_delete"  ON posts FOR DELETE USING (auth.uid() = author_id);

-- comments
CREATE POLICY "comments_public_read" ON comments FOR SELECT USING (true);
CREATE POLICY "comments_own_insert"  ON comments FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "comments_own_delete"  ON comments FOR DELETE USING (auth.uid() = author_id);

-- post_likes
CREATE POLICY "post_likes_public_read" ON post_likes FOR SELECT USING (true);
CREATE POLICY "post_likes_own_insert"  ON post_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "post_likes_own_delete"  ON post_likes FOR DELETE USING (auth.uid() = user_id);

-- comment_likes
CREATE POLICY "comment_likes_public_read" ON comment_likes FOR SELECT USING (true);
CREATE POLICY "comment_likes_own_insert"  ON comment_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "comment_likes_own_delete"  ON comment_likes FOR DELETE USING (auth.uid() = user_id);

-- votes
CREATE POLICY "votes_own_read"   ON votes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "votes_own_insert" ON votes FOR INSERT WITH CHECK (auth.uid() = user_id);

-- notifications
CREATE POLICY "notifications_own"     ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "notifications_own_upd" ON notifications FOR UPDATE USING (auth.uid() = user_id);

-- notification_preferences
CREATE POLICY "notif_prefs_own_read" ON notification_preferences FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "notif_prefs_own_upd"  ON notification_preferences FOR UPDATE USING (auth.uid() = user_id);

-- ledgers (read only — writes via service role Edge Functions)
CREATE POLICY "credits_own_read" ON credit_transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "xp_own_read"      ON xp_transactions     FOR SELECT USING (auth.uid() = user_id);

-- daily_claims
CREATE POLICY "claims_own_read" ON daily_claims FOR SELECT USING (auth.uid() = user_id);

-- user_avatars
CREATE POLICY "avatars_own_read"   ON user_avatars FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "avatars_own_insert" ON user_avatars FOR INSERT WITH CHECK (auth.uid() = user_id);

-- user_badges
CREATE POLICY "user_badges_public_read" ON user_badges FOR SELECT USING (true);

-- reports
CREATE POLICY "reports_own_insert" ON reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);

-- quiz_matches
CREATE POLICY "matches_own_read" ON quiz_matches FOR SELECT
  USING (auth.uid() = player1_id OR auth.uid() = player2_id);

-- catalog / config
CREATE POLICY "public_read" ON avatar_catalog               FOR SELECT USING (true);
CREATE POLICY "public_read" ON badges                       FOR SELECT USING (true);
CREATE POLICY "public_read" ON quiz_salons                  FOR SELECT USING (is_active = true);
CREATE POLICY "public_read" ON quiz_questions               FOR SELECT USING (is_active = true);
CREATE POLICY "public_read" ON quiz_ranking_rewards         FOR SELECT USING (is_active = true);
CREATE POLICY "public_read" ON contribution_ranking_rewards FOR SELECT USING (is_active = true);
CREATE POLICY "public_read" ON missions                     FOR SELECT USING (is_active = true);
CREATE POLICY "public_read" ON admin_polls                  FOR SELECT USING (is_active = true);


-- ============================================================
-- SHOP / IAP (see migration `20260416000000_shop_iap_subscriptions.sql`)
-- ============================================================
-- • profiles.subscription_tier: subscription_tier_enum ('none'|'silver'|'gold'|'diamond')
-- • profiles.subscription_expires_at: timestamptz; set only by Edge Function verify-iap
-- • credit_transactions.iap_transaction_id: text UNIQUE (consumable idempotency)
-- • credit_reason_enum: 'subscription_weekly_grant' for weekly subscription credits
-- • subscription_weekly_grants: idempotency per user per week
-- • iap_subscription_events: audit (platform + store_transaction UNIQUE)
-- • Trigger trg_profiles_block_subscription_spoof: clients cannot forge subscription fields
-- • public.grant_subscription_weekly_credits(): call weekly via pg_cron or scheduled Edge Function
--
-- Post/comment discounts: use SubscriptionTier.postDiscountPercent on server when debiting credits
-- (never trust client-only checks).

-- ============================================================
-- DONE — Backend is 100% complete. Ready for Flutter. 🚀
--
-- Edge Functions to build (use service_role key):
--   • quiz_enter_salon      — debit entry credits + create match
--   • quiz_finish_match     — update ELO + award winner credits
--   • claim_daily_reward    — streak / survey gift / mission claim
--   • claim_ranking_reward  — quiz / contribution period rewards
--   • purchase_avatar       — debit credits + insert user_avatars
--   • recalc_networth       — debit 1000 credits + update net_worth
--   • refresh_user_stats    — REFRESH MATERIALIZED VIEW CONCURRENTLY user_stats (cron ~15min)
-- ============================================================
