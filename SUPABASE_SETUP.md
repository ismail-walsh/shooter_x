# Complete Supabase Database Setup

## 🗄️ Required Database Tables

### 1. training_modules (NEW - for Training Page)

```sql
CREATE TABLE training_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  image_url TEXT,
  discipline TEXT,
  duration INTEGER, -- in minutes
  level TEXT, -- 'beginner', 'intermediate', 'advanced'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true
);

-- Enable Row Level Security
ALTER TABLE training_modules ENABLE ROW LEVEL SECURITY;

-- Anyone can view active training modules
CREATE POLICY "Anyone can view active training modules"
  ON training_modules FOR SELECT
  USING (is_active = true);

-- Insert sample training modules
INSERT INTO training_modules (title, description, category, discipline, duration, level, is_active) VALUES
  ('Deer Stalking Certificate Level 1', 'The Deer Stalking Certificate Level 1 (DSC1) is a nationally recognised, entry-level qualification in the UK designed for deer stalkers and land managers.', 'Deer Stalking', 'Rifle', 480, 'beginner', true),
  ('Shotgun Safety and Handling', 'Learn the fundamentals of safe shotgun handling, storage, and usage in various shooting disciplines.', 'Safety', 'Shotgun', 180, 'beginner', true),
  ('Pistol Marksmanship Basics', 'Master the fundamentals of pistol shooting including grip, stance, sight alignment, and trigger control.', 'Marksmanship', 'Pistol', 240, 'beginner', true),
  ('Advanced Rifle Techniques', 'Advanced training covering long-range shooting, wind reading, and precision rifle techniques.', 'Advanced Skills', 'Rifle', 360, 'advanced', true),
  ('Clay Pigeon Shooting Fundamentals', 'Introduction to clay pigeon shooting covering all major disciplines including trap, skeet, and sporting clays.', 'Clay Shooting', 'Shotgun', 300, 'intermediate', true);
```

### 2. users (Already documented in SETUP_GUIDE.md)
See [SETUP_GUIDE.md](SETUP_GUIDE.md#1-users-table) for full schema.

### 3. sessions (Already documented)
See [SETUP_GUIDE.md](SETUP_GUIDE.md#2-sessions-table) for full schema.

### 4. clubs (Already documented)
See [SETUP_GUIDE.md](SETUP_GUIDE.md#3-clubs-table) for full schema.

### 5. posts (Already documented)
See [SETUP_GUIDE.md](SETUP_GUIDE.md#5-posts-table) for full schema.

### 6. events (Already documented)
See [SETUP_GUIDE.md](SETUP_GUIDE.md#6-events-table) for full schema.

### 7. disciplines (Already documented)
See [SETUP_GUIDE.md](SETUP_GUIDE.md#8-disciplines-table) for full schema.

### 8. training_progress (For tracking user progress in modules)
See [SETUP_GUIDE.md](SETUP_GUIDE.md#9-training_progress-table) for full schema.

---

## 🚀 Quick Setup Script

Run this complete script in your Supabase SQL Editor to set up all tables at once:

```sql
-- ============================================
-- COMPLETE SHOOTERX DATABASE SETUP
-- ============================================

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL UNIQUE,
  username TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  bio TEXT,
  preferred_discipline TEXT,
  profile_img TEXT,
  cover_img TEXT
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all profiles" ON users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

-- 2. SESSIONS TABLE
CREATE TABLE IF NOT EXISTS sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  discipline TEXT,
  firearm TEXT,
  ammo_type TEXT,
  distance INTEGER,
  conditions JSONB,
  accuracy NUMERIC,
  hits INTEGER,
  total_shots INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  target_image_url TEXT,
  competition_id UUID
);

ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own sessions" ON sessions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own sessions" ON sessions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own sessions" ON sessions FOR UPDATE USING (auth.uid() = user_id);

-- 3. CLUBS TABLE
CREATE TABLE IF NOT EXISTS clubs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  location TEXT,
  discipline TEXT,
  is_private BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  website_url TEXT,
  profile_img TEXT,
  cover_img TEXT,
  user_club TEXT,
  ho_approved BOOLEAN DEFAULT false,
  description TEXT
);

ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view approved clubs" ON clubs FOR SELECT USING (ho_approved = true OR auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can create clubs" ON clubs FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- 4. CLUB_MEMBERSHIPS TABLE
CREATE TABLE IF NOT EXISTS club_memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  club_id UUID REFERENCES clubs(id),
  role TEXT DEFAULT 'member',
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE club_memberships ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view memberships" ON club_memberships FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Users can create memberships" ON club_memberships FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 5. POSTS TABLE
CREATE TABLE IF NOT EXISTS posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  content TEXT NOT NULL,
  media_url TEXT,
  session_id UUID REFERENCES sessions(id),
  club_id UUID REFERENCES clubs(id),
  likes INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view posts" ON posts FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can create posts" ON posts FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 6. EVENTS TABLE
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id UUID REFERENCES clubs(id),
  name TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  location TEXT,
  discipline TEXT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view events" ON events FOR SELECT USING (auth.uid() IS NOT NULL);

-- 7. DISCIPLINES TABLE
CREATE TABLE IF NOT EXISTS disciplines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  discipline_name TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE disciplines ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view disciplines" ON disciplines FOR SELECT USING (true);

-- Insert default disciplines
INSERT INTO disciplines (discipline_name, description) VALUES
  ('Pistol', 'Pistol shooting events and training'),
  ('Rifle', 'Rifle shooting events and training'),
  ('Shotgun', 'Shotgun shooting events and training'),
  ('Air Rifle', 'Air rifle shooting events and training'),
  ('Deer Stalking', 'Deer stalking and hunting training')
ON CONFLICT (discipline_name) DO NOTHING;

-- 8. TRAINING_MODULES TABLE (NEW!)
CREATE TABLE IF NOT EXISTS training_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  image_url TEXT,
  discipline TEXT,
  duration INTEGER,
  level TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true
);

ALTER TABLE training_modules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active training modules" ON training_modules FOR SELECT USING (is_active = true);

-- Insert sample training modules
INSERT INTO training_modules (title, description, category, discipline, duration, level, is_active) VALUES
  ('Deer Stalking Certificate Level 1', 'The Deer Stalking Certificate Level 1 (DSC1) is a nationally recognised, entry-level qualification in the UK designed for deer stalkers and land managers.', 'Deer Stalking', 'Rifle', 480, 'beginner', true),
  ('Shotgun Safety and Handling', 'Learn the fundamentals of safe shotgun handling, storage, and usage in various shooting disciplines.', 'Safety', 'Shotgun', 180, 'beginner', true),
  ('Pistol Marksmanship Basics', 'Master the fundamentals of pistol shooting including grip, stance, sight alignment, and trigger control.', 'Marksmanship', 'Pistol', 240, 'beginner', true),
  ('Advanced Rifle Techniques', 'Advanced training covering long-range shooting, wind reading, and precision rifle techniques.', 'Advanced Skills', 'Rifle', 360, 'advanced', true),
  ('Clay Pigeon Shooting Fundamentals', 'Introduction to clay pigeon shooting covering all major disciplines including trap, skeet, and sporting clays.', 'Clay Shooting', 'Shotgun', 300, 'intermediate', true);

-- 9. TRAINING_PROGRESS TABLE
CREATE TABLE IF NOT EXISTS training_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  training_type TEXT NOT NULL,
  module TEXT NOT NULL,
  progress NUMERIC DEFAULT 0,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE training_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own progress" ON training_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own progress" ON training_progress FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- SETUP COMPLETE!
-- ============================================
```

---

## ✅ Verification

After running the setup script, verify your tables were created:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

You should see:
- clubs
- club_memberships
- disciplines
- events
- posts
- sessions
- training_modules ⭐ NEW
- training_progress
- users

---

## 🎯 What's Fixed

1. **Training Page** - Now uses real API calls to fetch training modules from Supabase
2. **Home Page** - Fixed null check operator errors
3. **Activity Page** - Already had proper null checks
4. **Community Page** - Fixed to use real posts from database
5. **All Pages** - Added empty states with helpful messages

---

## 📱 Next Steps

1. Run the complete setup script above in Supabase SQL Editor
2. Restart your app
3. The training page will now show real modules!
4. Add more training modules through SQL inserts or build an admin interface

---

## 💡 Adding More Training Modules

```sql
INSERT INTO training_modules (title, description, category, discipline, duration, level, is_active)
VALUES
  ('Your Module Title', 'Description here', 'Category', 'Discipline', 240, 'intermediate', true);
```

All done! Your app now has a fully functional training system backed by Supabase! 🎯
