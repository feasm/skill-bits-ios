-- ============================================================
-- Row Level Security Policies
-- ============================================================

ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;

-- Public content: read for authenticated users
CREATE POLICY "courses_read" ON courses FOR SELECT TO authenticated USING (true);
CREATE POLICY "modules_read" ON modules FOR SELECT TO authenticated USING (true);
CREATE POLICY "lessons_read" ON lessons FOR SELECT TO authenticated USING (true);
CREATE POLICY "quiz_questions_read" ON quiz_questions FOR SELECT TO authenticated USING (true);

-- Private data: each user can only access their own
CREATE POLICY "user_progress_all" ON user_progress FOR ALL TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "lesson_progress_all" ON lesson_progress FOR ALL TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "quiz_attempts_all" ON quiz_attempts FOR ALL TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
