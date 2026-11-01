-- ============================================
-- ISMAIL WALSH — DEMO DATA
-- Run in Supabase SQL Editor
-- Targets: i.walsh98@hotmail.co.uk
-- ============================================

DO $$
DECLARE
  v_uid      UUID;
  v_club_id  UUID;
BEGIN

  -- ── Resolve user ID from users table (may differ from auth.users id) ──
  SELECT id INTO v_uid FROM users WHERE email = 'i.walsh98@hotmail.co.uk' LIMIT 1;

  -- Fallback: try auth.users if not found in users table
  IF v_uid IS NULL THEN
    SELECT id INTO v_uid FROM auth.users WHERE email = 'i.walsh98@hotmail.co.uk' LIMIT 1;
  END IF;

  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'User i.walsh98@hotmail.co.uk not found';
  END IF;

  -- ── Resolve Wednesbury Marksmen ───────────
  SELECT id INTO v_club_id FROM clubs WHERE name ILIKE '%Wednesbury%' LIMIT 1;

  -- ──────────────────────────────────────────
  -- 1. USER PROFILE — match by email (safe regardless of id scheme)
  -- ──────────────────────────────────────────
  UPDATE users SET
    full_name            = 'Ismail Walsh',
    username             = 'ismail_walsh',
    bio                  = 'Competitive target shooter. Wednesbury Marksmen member. Chasing that perfect score.',
    preferred_discipline = 'target',
    level                = 8,
    total_xp             = 7850,
    profile_img          = 'https://images.unsplash.com/photo-1607746882042-944635dfe10e?w=400',
    cover_img            = 'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=800'
  WHERE email = 'i.walsh98@hotmail.co.uk';

  RAISE NOTICE 'Updated profile for user_id=%', v_uid;

  -- ──────────────────────────────────────────
  -- 2. SESSIONS — last 14 days
  -- ──────────────────────────────────────────
  INSERT INTO sessions (user_id, discipline, firearm, ammo_type, distance, accuracy, hits, total_shots, notes, created_at)
  VALUES
    (v_uid, 'target',        'Remington 700', '.308 Win',  300, 94.0, 47, 50, 'Solid morning session. Wind compensation improving.',          NOW()),
    (v_uid, 'target',        'Glock 17',      '9mm',        25, 88.0, 44, 50, 'Pistol practice at Wednesbury Marksmen indoor range.',         NOW() - INTERVAL '1 day'),
    (v_uid, 'target',        'Tikka T3x',     '.243 Win',  200, 96.0, 48, 50, 'Personal best at 200m. Scope dialled in perfectly.',           NOW() - INTERVAL '2 days'),
    (v_uid, 'target',        'Remington 700', '.308 Win',  400, 82.0, 41, 50, 'Pushed out to 400m. Wind tricky.',                             NOW() - INTERVAL '3 days'),
    (v_uid, 'clay',          'Beretta A400',  '12g',        20, 90.0, 45, 50, 'Clay pigeon session — great fun.',                             NOW() - INTERVAL '4 days'),
    (v_uid, 'target',        'Tikka T3x',     '.243 Win',  300, 91.0, 46, 50, 'Consistency drill at 300m.',                                   NOW() - INTERVAL '5 days'),
    (v_uid, 'target',        'SIG P226',      '9mm',        15, 86.0, 43, 50, 'Speed drills at 15m.',                                        NOW() - INTERVAL '6 days'),
    (v_uid, 'target',        'Remington 700', '.308 Win',  250, 89.0, 44, 50, 'Pre-comp warm-up session.',                                    NOW() - INTERVAL '8 days'),
    (v_uid, 'target',        'Tikka T3x',     '6.5 CM',    500, 78.0, 39, 50, 'First attempt at 500m. Lots to learn.',                       NOW() - INTERVAL '10 days'),
    (v_uid, 'clay',          'Browning B525', '20g',        20, 84.0, 42, 50, 'Trap shooting at the club.',                                   NOW() - INTERVAL '12 days'),
    (v_uid, 'deer_stalking', 'Remington 700', '.308 Win',  300, 92.0, 46, 50, 'Weekly club practice.',                                        NOW() - INTERVAL '14 days')
  ON CONFLICT DO NOTHING;

  -- ──────────────────────────────────────────
  -- 3. STREAK — 7-day active streak
  -- ──────────────────────────────────────────
  INSERT INTO user_streaks (user_id, current_streak, best_streak, last_session_date)
  VALUES (v_uid, 7, 12, CURRENT_DATE)
  ON CONFLICT (user_id) DO UPDATE
    SET current_streak    = 7,
        best_streak       = GREATEST(user_streaks.best_streak, 12),
        last_session_date = CURRENT_DATE;

  -- ──────────────────────────────────────────
  -- 4. WEDNESBURY MARKSMEN MEMBERSHIP
  -- ──────────────────────────────────────────
  IF v_club_id IS NULL THEN
    INSERT INTO clubs (name, location, discipline, ho_approved, description, profile_img, cover_img)
    VALUES (
      'Wednesbury Marksmen',
      'Wednesbury, West Midlands',
      'Rifle',
      true,
      'Established target shooting club based in the West Midlands. Competitive and social sessions every week.',
      'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=400',
      'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=800'
    )
    RETURNING id INTO v_club_id;
  END IF;

  IF v_club_id IS NOT NULL THEN
    INSERT INTO club_memberships (user_id, club_id, role, joined_at)
    VALUES (v_uid, v_club_id, 'member', NOW() - INTERVAL '6 months')
    ON CONFLICT DO NOTHING;
  END IF;

  -- ──────────────────────────────────────────
  -- 5. LEADERBOARD ENTRIES
  -- ──────────────────────────────────────────
  INSERT INTO leaderboard_entries (user_id, competition_name, rank, score, level, xp, display_name, scope, club_id, created_at)
  VALUES
    (v_uid, 'Wednesbury Marksmen Weekly',  3,  96.5, 8, 7850, 'Ismail Walsh', 'club',   v_club_id, NOW()),
    (v_uid, 'Wednesbury Monthly Shoot',    7, 312.0, 8, 7850, 'Ismail Walsh', 'club',   v_club_id, NOW() - INTERVAL '30 days'),
    (v_uid, 'National Open — Rifle',      14, 284.5, 8, 7850, 'Ismail Walsh', 'global', NULL,      NOW() - INTERVAL '45 days'),
    (v_uid, 'Regional Qualifier',          5, 301.0, 8, 7850, 'Ismail Walsh', 'global', NULL,      NOW() - INTERVAL '60 days')
  ON CONFLICT DO NOTHING;

  -- ──────────────────────────────────────────
  -- 6. USER CHALLENGES (link to existing weekly challenges)
  -- ──────────────────────────────────────────
  -- progress on "Shoot 3 sessions this week" — completed
  INSERT INTO user_challenges (user_id, challenge_id, progress, target, type, completed)
  SELECT v_uid, id, 3, target_count, 'sessions_this_week', TRUE
  FROM weekly_challenges
  WHERE title ILIKE '%session%'
  LIMIT 1
  ON CONFLICT (user_id, challenge_id) DO UPDATE
    SET progress = 3, completed = TRUE;

  -- progress on "Score 90%+ twice" — in progress (1/2)
  INSERT INTO user_challenges (user_id, challenge_id, progress, target, type, completed)
  SELECT v_uid, id, 1, target_count, 'accuracy_sessions', FALSE
  FROM weekly_challenges
  WHERE title ILIKE '%90%'
  LIMIT 1
  ON CONFLICT (user_id, challenge_id) DO UPDATE
    SET progress = 1, completed = FALSE;

  RAISE NOTICE 'Demo data populated for user % (%)', v_uid, 'i.walsh98@hotmail.co.uk';
END $$;

-- ── VERIFY ───────────────────────────────────
SELECT 'users'            AS tbl, COUNT(*) FROM users             WHERE id = (SELECT id FROM auth.users WHERE email = 'i.walsh98@hotmail.co.uk')
UNION ALL
SELECT 'sessions',                COUNT(*) FROM sessions           WHERE user_id = (SELECT id FROM auth.users WHERE email = 'i.walsh98@hotmail.co.uk')
UNION ALL
SELECT 'leaderboard',             COUNT(*) FROM leaderboard_entries WHERE user_id = (SELECT id FROM auth.users WHERE email = 'i.walsh98@hotmail.co.uk')
UNION ALL
SELECT 'club_memberships',        COUNT(*) FROM club_memberships    WHERE user_id = (SELECT id FROM auth.users WHERE email = 'i.walsh98@hotmail.co.uk')
UNION ALL
SELECT 'user_challenges',         COUNT(*) FROM user_challenges     WHERE user_id = (SELECT id FROM auth.users WHERE email = 'i.walsh98@hotmail.co.uk')
UNION ALL
SELECT 'streaks',                 COUNT(*) FROM user_streaks        WHERE user_id = (SELECT id FROM auth.users WHERE email = 'i.walsh98@hotmail.co.uk');
