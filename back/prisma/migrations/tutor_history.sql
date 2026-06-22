ALTER TABLE tutor_sessions ADD COLUMN IF NOT EXISTS title text;
CREATE INDEX IF NOT EXISTS tutor_sessions_user_id_created_at_idx
  ON tutor_sessions (user_id, created_at DESC);
