-- ============================================
-- SCHEMA MIGRATIONS — align tables with app
-- Run in Supabase SQL Editor
-- ============================================

-- leaderboard_entries: add level + event_id
ALTER TABLE leaderboard_entries
  ADD COLUMN IF NOT EXISTS level    INTEGER DEFAULT 1,
  ADD COLUMN IF NOT EXISTS event_id UUID REFERENCES events(id) ON DELETE SET NULL;

-- user_challenges: add missing columns
ALTER TABLE user_challenges
  ADD COLUMN IF NOT EXISTS target     INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS type       TEXT,
  ADD COLUMN IF NOT EXISTS completed  BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- user_streaks: add timestamp columns
ALTER TABLE user_streaks
  ADD COLUMN IF NOT EXISTS updated_at  TIMESTAMPTZ DEFAULT NOW(),
  ADD COLUMN IF NOT EXISTS created_at  TIMESTAMPTZ DEFAULT NOW();
