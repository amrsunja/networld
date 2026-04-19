-- ============================================================
-- Add 'new_follower' to notification_type_enum
-- + new_follower column in notification_preferences
-- + trigger to notify on follow (respects preference)
-- ============================================================

ALTER TYPE notification_type_enum ADD VALUE IF NOT EXISTS 'new_follower';

ALTER TABLE notification_preferences
  ADD COLUMN IF NOT EXISTS new_follower boolean NOT NULL DEFAULT true;

-- Trigger function: create notification when user is followed
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
