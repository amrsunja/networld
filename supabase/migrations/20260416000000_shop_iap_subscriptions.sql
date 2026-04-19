-- Shop IAP: subscription tiers, consumable idempotency, weekly grants, RLS hardening.
-- Run after existing schema; safe to apply on DBs that already have profiles/credit_transactions.

-- ---------------------------------------------------------------------------
-- 1) Subscription tier (premium) — server-written only (trigger blocks client)
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type WHERE typname = 'subscription_tier_enum'
  ) THEN
    CREATE TYPE subscription_tier_enum AS ENUM ('none', 'silver', 'gold', 'diamond');
  END IF;
END$$;

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS subscription_tier subscription_tier_enum NOT NULL DEFAULT 'none';

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS subscription_expires_at timestamptz NULL;

COMMENT ON COLUMN profiles.subscription_tier IS 'Premium tier from validated IAP; clients cannot set directly.';
COMMENT ON COLUMN profiles.subscription_expires_at IS 'When the auto-renewing subscription ends (UTC); null if none.';

-- ---------------------------------------------------------------------------
-- 2) Consumable IAP idempotency (Apple/Google transaction ids are text, not uuid)
-- ---------------------------------------------------------------------------
ALTER TABLE credit_transactions
  ADD COLUMN IF NOT EXISTS iap_transaction_id text NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_credit_tx_iap_transaction_id
  ON credit_transactions (iap_transaction_id)
  WHERE iap_transaction_id IS NOT NULL;

COMMENT ON COLUMN credit_transactions.iap_transaction_id IS 'Store transaction id for consumable IAP; unique to prevent double credit.';

-- ---------------------------------------------------------------------------
-- 3) credit_reason_enum: weekly subscription credits
-- ---------------------------------------------------------------------------
ALTER TYPE credit_reason_enum ADD VALUE IF NOT EXISTS 'subscription_weekly_grant';

-- ---------------------------------------------------------------------------
-- 4) Weekly grant idempotency (one row per user per ISO week start)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS subscription_weekly_grants (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  week_start date NOT NULL,
  credits    integer NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, week_start)
);

CREATE INDEX IF NOT EXISTS idx_sub_weekly_grants_user
  ON subscription_weekly_grants (user_id, week_start DESC);

ALTER TABLE subscription_weekly_grants ENABLE ROW LEVEL SECURITY;

CREATE POLICY subscription_weekly_grants_own_read
  ON subscription_weekly_grants
  FOR SELECT
  USING (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 5) Audit trail for subscription verifications (optional analytics / support)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS iap_subscription_events (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  platform          text NOT NULL CHECK (platform IN ('ios', 'android')),
  store_transaction text NOT NULL,
  product_id        text NOT NULL,
  tier              subscription_tier_enum NOT NULL,
  expires_at        timestamptz NOT NULL,
  created_at        timestamptz NOT NULL DEFAULT now(),
  UNIQUE (platform, store_transaction)
);

CREATE INDEX IF NOT EXISTS idx_iap_sub_events_user
  ON iap_subscription_events (user_id, created_at DESC);

ALTER TABLE iap_subscription_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY iap_subscription_events_own_read
  ON iap_subscription_events
  FOR SELECT
  USING (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 6) Block clients from forging subscription fields on profiles
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.trg_profiles_block_subscription_spoof()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'UPDATE'
     AND auth.uid() IS NOT NULL
     AND auth.uid() = NEW.id
  THEN
    IF NEW.subscription_tier IS DISTINCT FROM OLD.subscription_tier
       OR NEW.subscription_expires_at IS DISTINCT FROM OLD.subscription_expires_at
    THEN
      RAISE EXCEPTION 'subscription fields are server-managed';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_profiles_block_subscription_spoof ON profiles;

CREATE TRIGGER trg_profiles_block_subscription_spoof
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE PROCEDURE public.trg_profiles_block_subscription_spoof();

-- ---------------------------------------------------------------------------
-- 7) Weekly credits job — call via pg_cron or Edge Function on a schedule
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.grant_subscription_weekly_credits()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_week_start date := date_trunc('week', timezone('UTC', now()))::date;
  v_user         RECORD;
  v_weekly       integer;
  v_count        integer := 0;
BEGIN
  FOR v_user IN
    SELECT id, subscription_tier, subscription_expires_at
    FROM profiles
    WHERE subscription_expires_at IS NOT NULL
      AND subscription_expires_at > timezone('UTC', now())
      AND subscription_tier <> 'none'::subscription_tier_enum
  LOOP
    v_weekly := CASE v_user.subscription_tier
      WHEN 'silver' THEN 500
      WHEN 'gold' THEN 1500
      WHEN 'diamond' THEN 5000
      ELSE 0
    END;

    IF v_weekly <= 0 THEN
      CONTINUE;
    END IF;

    IF EXISTS (
      SELECT 1
      FROM subscription_weekly_grants g
      WHERE g.user_id = v_user.id
        AND g.week_start = v_week_start
    ) THEN
      CONTINUE;
    END IF;

    UPDATE profiles
    SET credits = credits + v_weekly
    WHERE id = v_user.id;

    INSERT INTO credit_transactions (user_id, amount, reason, ref_id, iap_transaction_id)
    VALUES (
      v_user.id,
      v_weekly,
      'subscription_weekly_grant',
      gen_random_uuid(),
      NULL
    );

    INSERT INTO subscription_weekly_grants (user_id, week_start, credits)
    VALUES (v_user.id, v_week_start, v_weekly);

    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$;

COMMENT ON FUNCTION public.grant_subscription_weekly_credits() IS
  'Idempotent weekly credits for active subscribers; run weekly via cron. Returns rows processed.';
