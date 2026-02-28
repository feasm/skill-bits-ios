-- ============================================================
-- SkillBits MVP Schema
-- ============================================================

CREATE TABLE courses (
    id text PRIMARY KEY,
    title text NOT NULL,
    short_desc text,
    description text,
    emoji text,
    category text,
    level text,
    total_duration text,
    color1 text,
    color2 text,
    access_tier text NOT NULL DEFAULT 'free',
    instructor text,
    sort_order int DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE modules (
    id text PRIMARY KEY,
    course_id text NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title text NOT NULL,
    description text,
    duration text,
    access_tier text NOT NULL DEFAULT 'free',
    sort_order int DEFAULT 0
);

CREATE INDEX idx_modules_course ON modules(course_id, sort_order);

CREATE TABLE lessons (
    id text PRIMARY KEY,
    module_id text NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    title text NOT NULL,
    duration text,
    content jsonb,
    sort_order int DEFAULT 0
);

CREATE INDEX idx_lessons_module ON lessons(module_id, sort_order);

CREATE TABLE user_progress (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    xp int DEFAULT 0,
    streak_days int DEFAULT 0,
    studied_minutes_today int DEFAULT 0,
    last_study_date date,
    daily_goal text DEFAULT 'minutes15',
    badges jsonb DEFAULT '[]'::jsonb,
    onboarding_reason text,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE lesson_progress (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    lesson_id text NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    status text NOT NULL DEFAULT 'available',
    progress float DEFAULT 0,
    completed_at timestamptz,
    UNIQUE(user_id, lesson_id)
);

CREATE INDEX idx_lesson_progress_user ON lesson_progress(user_id);

CREATE TABLE quiz_questions (
    id text PRIMARY KEY,
    module_id text NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    question text NOT NULL,
    options jsonb NOT NULL,
    correct_index int NOT NULL,
    explanation text,
    sort_order int DEFAULT 0
);

CREATE INDEX idx_quiz_module ON quiz_questions(module_id, sort_order);

CREATE TABLE quiz_attempts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    module_id text NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    score int NOT NULL,
    correct_count int NOT NULL,
    total int NOT NULL,
    passed boolean NOT NULL,
    quiz_first boolean DEFAULT false,
    answers jsonb,
    created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_quiz_attempts_user_module ON quiz_attempts(user_id, module_id);
