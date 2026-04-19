-- ============================================
-- SAMPLE DATA FOR SHOOTERX APP
-- Run this in Supabase SQL Editor after setting up tables
-- ============================================

-- Note: You'll need to replace 'YOUR_USER_ID' with your actual user ID from auth.users

-- ============================================
-- 1. SAMPLE CLUBS
-- ============================================

INSERT INTO clubs (name, location, discipline, ho_approved, description, profile_img, cover_img) VALUES
  (
    'Double Deuce Firing Range',
    'Birmingham, UK',
    'Rifle',
    true,
    'Premier rifle shooting club in Birmingham with state-of-the-art facilities. Open to all skill levels.',
    'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=400',
    'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=800'
  ),
  (
    'Lee Mansion Shooting Club',
    'London, UK',
    'Pistol',
    true,
    'Historic pistol shooting club with expert instructors and competitive programs.',
    'https://images.unsplash.com/photo-1594993542200-6a5d1fc94542?w=400',
    'https://images.unsplash.com/photo-1594993542200-6a5d1fc94542?w=800'
  ),
  (
    'Risley Press Gun Club',
    'Manchester, UK',
    'Shotgun',
    true,
    'Family-friendly shotgun club specializing in clay pigeon shooting and hunting preparation.',
    'https://images.unsplash.com/photo-1624498604122-0fda845bee1f?w=400',
    'https://images.unsplash.com/photo-1624498604122-0fda845bee1f?w=800'
  ),
  (
    'Blockbastly Marksman Club',
    'Edinburgh, Scotland',
    'Rifle',
    true,
    'Precision rifle club for long-range shooting enthusiasts. Regular competitions held.',
    'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=400',
    'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=800'
  ),
  (
    'Grey Emerald Shooting Academy',
    'Cardiff, Wales',
    'Pistol',
    true,
    'Professional shooting academy offering courses from beginner to expert level.',
    'https://images.unsplash.com/photo-1594993542200-6a5d1fc94542?w=400',
    'https://images.unsplash.com/photo-1594993542200-6a5d1fc94542?w=800'
  ),
  (
    'Silverstone Shooting Centre',
    'Northamptonshire, UK',
    'Shotgun',
    true,
    'Premium shooting centre with Olympic-standard facilities and coaching.',
    'https://images.unsplash.com/photo-1624498604122-0fda845bee1f?w=400',
    'https://images.unsplash.com/photo-1624498604122-0fda845bee1f?w=800'
  )
ON CONFLICT DO NOTHING;

-- ============================================
-- 2. SAMPLE EVENTS
-- ============================================

INSERT INTO events (name, date, location, discipline, description, club_id) VALUES
  (
    'Schmelsser Steel Challenge',
    '2026-03-15 10:00:00+00',
    'Double Deuce Firing Range, Birmingham',
    'Rifle',
    'Annual steel challenge competition. Open to all levels. Register by March 1st.',
    (SELECT id FROM clubs WHERE name = 'Double Deuce Firing Range' LIMIT 1)
  ),
  (
    'Tactical Shoot Night',
    '2026-03-22 18:00:00+00',
    'Lee Mansion, London',
    'Pistol',
    'Evening tactical shooting event under lights. Advanced shooters only.',
    (SELECT id FROM clubs WHERE name = 'Lee Mansion Shooting Club' LIMIT 1)
  ),
  (
    'Clay Pigeon Championship',
    '2026-04-05 09:00:00+00',
    'Risley Press, Manchester',
    'Shotgun',
    'Regional clay pigeon shooting championship. All skill levels welcome.',
    (SELECT id FROM clubs WHERE name = 'Risley Press Gun Club' LIMIT 1)
  )
ON CONFLICT DO NOTHING;

-- ============================================
-- 3. SAMPLE POSTS (Community)
-- ============================================

-- First, create a few sample users if they don't exist
-- Note: In production, these would be real authenticated users

-- Get your current user ID
DO $$
DECLARE
  current_user_id UUID;
BEGIN
  -- Get the first user from auth (likely you)
  SELECT id INTO current_user_id FROM auth.users LIMIT 1;

  -- Insert sample posts with that user ID
  IF current_user_id IS NOT NULL THEN
    INSERT INTO posts (user_id, content, media_url, likes, created_at) VALUES
      (
        current_user_id,
        'Just completed my first deer stalking certification! The DSC1 course was challenging but incredibly rewarding. Can''t wait to put these skills to use.',
        'https://images.unsplash.com/photo-1551731409-43eb3e517a1a?w=800',
        12,
        NOW() - INTERVAL '2 hours'
      ),
      (
        current_user_id,
        'Amazing session at the range today. Finally hit that 96% accuracy I''ve been working towards. Practice makes perfect!',
        'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=800',
        24,
        NOW() - INTERVAL '5 hours'
      ),
      (
        current_user_id,
        'First live buck! What an incredible experience. Thanks to everyone at the club for the support and training.',
        'https://images.unsplash.com/photo-1551731409-43eb3e517a1a?w=800',
        45,
        NOW() - INTERVAL '1 day'
      ),
      (
        current_user_id,
        'New personal best at the competition today! The training with Coach Williams really paid off. Grateful for this amazing community.',
        NULL,
        18,
        NOW() - INTERVAL '2 days'
      )
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- ============================================
-- 4. SAMPLE TRAINING MODULES (if not already added)
-- ============================================

INSERT INTO training_modules (title, description, category, discipline, duration, level, is_active, image_url) VALUES
  (
    'Deer Stalking Certificate 1',
    'The Deer Stalking Certificate Level 1 (DSC1) is a nationally recognised, entry-level qualification in the UK designed for deer stalkers and land managers.',
    'Deer Stalking',
    'Rifle',
    480,
    'beginner',
    true,
    'https://images.unsplash.com/photo-1551731409-43eb3e517a1a?w=400'
  ),
  (
    'Deer Stalking Certificate 2',
    'Advanced deer stalking techniques including habitat management, carcass preparation, and ethical hunting practices.',
    'Deer Stalking',
    'Rifle',
    600,
    'intermediate',
    true,
    'https://images.unsplash.com/photo-1551731409-43eb3e517a1a?w=400'
  ),
  (
    'Game Meat Hygiene Level 1',
    'Learn the essential skills for safe game meat handling, storage, and preparation. Required for commercial game suppliers.',
    'Game Shooting',
    'Rifle',
    180,
    'beginner',
    true,
    'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400'
  ),
  (
    'Game Meat Hygiene Level 2',
    'Advanced game meat processing techniques including butchery, aging, and commercial preparation standards.',
    'Game Shooting',
    'Rifle',
    240,
    'intermediate',
    true,
    'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400'
  ),
  (
    'Large Game Meat Hygiene (AHU)',
    'Approved Hunting Unit certification for processing large game in approved facilities. Commercial certification.',
    'Game Shooting',
    'Rifle',
    360,
    'advanced',
    true,
    'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400'
  ),
  (
    'Firearms Awareness & Safety',
    'Comprehensive firearms safety course covering handling, storage, legal responsibilities, and range etiquette.',
    'Safety',
    'All',
    120,
    'beginner',
    true,
    'https://images.unsplash.com/photo-1594993542200-6a5d1fc94542?w=400'
  )
ON CONFLICT (title) DO NOTHING;

-- ============================================
-- 5. SAMPLE SESSIONS
-- ============================================

DO $$
DECLARE
  current_user_id UUID;
BEGIN
  SELECT id INTO current_user_id FROM auth.users LIMIT 1;

  IF current_user_id IS NOT NULL THEN
    INSERT INTO sessions (user_id, discipline, firearm, ammo_type, distance, accuracy, hits, total_shots, created_at) VALUES
      (
        current_user_id,
        'Rifle',
        'Tikka T3x',
        '.308 Winchester',
        100,
        96.0,
        96,
        100,
        NOW() - INTERVAL '1 day'
      ),
      (
        current_user_id,
        'Pistol',
        'Glock 17',
        '9mm Luger',
        25,
        88.0,
        44,
        50,
        NOW() - INTERVAL '3 days'
      ),
      (
        current_user_id,
        'Shotgun',
        'Browning Citori',
        '12 Gauge',
        35,
        92.0,
        23,
        25,
        NOW() - INTERVAL '1 week'
      )
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- ============================================
-- 6. SAMPLE LEADERBOARD ENTRIES
-- ============================================

DO $$
DECLARE
  current_user_id UUID;
BEGIN
  SELECT id INTO current_user_id FROM auth.users LIMIT 1;

  IF current_user_id IS NOT NULL THEN
    INSERT INTO leaderboard_entries (user_id, competition_name, rank, score, level, xp, created_at) VALUES
      (
        current_user_id,
        'DD Tactical Shoot',
        12,
        95.5,
        256,
        10000,
        NOW()
      )
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Run these to verify data was inserted:

-- SELECT COUNT(*) as club_count FROM clubs WHERE ho_approved = true;
-- SELECT COUNT(*) as event_count FROM events;
-- SELECT COUNT(*) as post_count FROM posts;
-- SELECT COUNT(*) as training_count FROM training_modules WHERE is_active = true;
-- SELECT COUNT(*) as session_count FROM sessions;
-- SELECT COUNT(*) as leaderboard_count FROM leaderboard_entries;

-- ============================================
-- NOTES
-- ============================================

/*
After running this script:

1. Clubs page will show 6 clubs in "Discover new clubs"
2. Events page will show 3 upcoming events
3. Community page will show 4 posts
4. Training page will show 6 training modules
5. Home page will show sessions and leaderboard entry
6. All images use Unsplash URLs (free, no attribution required for testing)

For production:
- Replace Unsplash URLs with actual uploaded images
- Create real user accounts for posts/sessions
- Add real club data with actual locations
- Set up proper authentication flow
*/
