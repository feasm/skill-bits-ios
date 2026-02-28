-- ============================================================
-- Helper: update a single badge's unlocked status in jsonb array
-- ============================================================
CREATE OR REPLACE FUNCTION update_badge_status(p_badges jsonb, p_badge_id text, p_unlocked boolean)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
    v_idx int;
    v_badge jsonb;
BEGIN
    FOR v_idx IN 0..jsonb_array_length(p_badges) - 1
    LOOP
        v_badge := p_badges->v_idx;
        IF v_badge->>'id' = p_badge_id THEN
            p_badges := jsonb_set(p_badges, ARRAY[v_idx::text, 'unlocked'], to_jsonb(p_unlocked));
        END IF;
    END LOOP;
    RETURN p_badges;
END;
$$;

-- ============================================================
-- update_badges: recalculate badge unlock state
-- ============================================================
CREATE OR REPLACE FUNCTION update_badges(p_user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_xp int;
    v_streak int;
    v_lessons_completed int;
    v_badges jsonb;
BEGIN
    SELECT xp, streak_days, badges INTO v_xp, v_streak, v_badges
    FROM user_progress WHERE user_id = p_user_id;

    IF v_badges IS NULL THEN RETURN; END IF;

    SELECT count(*) INTO v_lessons_completed
    FROM lesson_progress WHERE user_id = p_user_id AND status = 'completed';

    IF v_lessons_completed >= 1 THEN
        v_badges := update_badge_status(v_badges, 'b1', true);
    END IF;

    IF v_xp >= 300 THEN
        v_badges := update_badge_status(v_badges, 'b2', true);
    END IF;

    IF v_streak >= 7 THEN
        v_badges := update_badge_status(v_badges, 'b3', true);
    END IF;

    UPDATE user_progress SET badges = v_badges WHERE user_id = p_user_id;
END;
$$;

-- ============================================================
-- initialize_user_progress: called after onboarding
-- ============================================================
CREATE OR REPLACE FUNCTION initialize_user_progress(
    p_reason text,
    p_daily_goal text DEFAULT 'minutes15'
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_lesson RECORD;
    v_is_first boolean;
BEGIN
    INSERT INTO user_progress (user_id, daily_goal, onboarding_reason, badges)
    VALUES (
        v_user_id,
        p_daily_goal,
        p_reason,
        '[{"id":"b1","name":"Primeiro Passo","icon":"🚀","unlocked":false},{"id":"b2","name":"Quiz Master","icon":"⚡","unlocked":false},{"id":"b3","name":"Estudante Dedicado","icon":"🔥","unlocked":false}]'::jsonb
    )
    ON CONFLICT (user_id) DO NOTHING;

    FOR v_lesson IN
        SELECT l.id as lesson_id, l.module_id, l.sort_order, m.access_tier
        FROM lessons l
        JOIN modules m ON m.id = l.module_id
        ORDER BY m.sort_order, l.sort_order
    LOOP
        v_is_first := (v_lesson.sort_order = (
            SELECT MIN(l2.sort_order) FROM lessons l2 WHERE l2.module_id = v_lesson.module_id
        ));

        INSERT INTO lesson_progress (user_id, lesson_id, status)
        VALUES (
            v_user_id,
            v_lesson.lesson_id,
            CASE
                WHEN v_lesson.access_tier = 'premium' THEN 'locked'
                WHEN v_is_first THEN 'available'
                ELSE 'locked'
            END
        )
        ON CONFLICT (user_id, lesson_id) DO NOTHING;
    END LOOP;

    RETURN json_build_object('success', true);
END;
$$;

-- ============================================================
-- complete_lesson: mark done, grant XP, update streak, unlock next
-- ============================================================
CREATE OR REPLACE FUNCTION complete_lesson(
    p_lesson_id text,
    p_module_id text
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_xp_gained int := 20;
    v_current_xp int;
    v_streak int;
    v_last_date date;
    v_today date := current_date;
    v_minutes int;
    v_next_lesson_id text;
    v_lesson_sort int;
BEGIN
    UPDATE lesson_progress
    SET status = 'completed', progress = 100, completed_at = now()
    WHERE user_id = v_user_id AND lesson_id = p_lesson_id;

    SELECT sort_order INTO v_lesson_sort FROM lessons WHERE id = p_lesson_id;

    SELECT l.id INTO v_next_lesson_id
    FROM lessons l
    WHERE l.module_id = p_module_id AND l.sort_order > v_lesson_sort
    ORDER BY l.sort_order
    LIMIT 1;

    IF v_next_lesson_id IS NOT NULL THEN
        INSERT INTO lesson_progress (user_id, lesson_id, status)
        VALUES (v_user_id, v_next_lesson_id, 'available')
        ON CONFLICT (user_id, lesson_id)
        DO UPDATE SET status = 'available' WHERE lesson_progress.status = 'locked';
    END IF;

    SELECT xp, streak_days, last_study_date, studied_minutes_today
    INTO v_current_xp, v_streak, v_last_date, v_minutes
    FROM user_progress WHERE user_id = v_user_id;

    IF v_last_date IS NULL OR v_last_date < v_today - interval '1 day' THEN
        v_streak := 1;
    ELSIF v_last_date = v_today - interval '1 day' THEN
        v_streak := v_streak + 1;
    END IF;

    IF v_last_date IS NULL OR v_last_date < v_today THEN
        v_minutes := 0;
    END IF;

    UPDATE user_progress
    SET xp = xp + v_xp_gained,
        streak_days = v_streak,
        studied_minutes_today = v_minutes + 10,
        last_study_date = v_today
    WHERE user_id = v_user_id;

    PERFORM update_badges(v_user_id);

    RETURN json_build_object(
        'xp_gained', v_xp_gained,
        'new_xp', v_current_xp + v_xp_gained,
        'streak_days', v_streak,
        'next_lesson_id', v_next_lesson_id
    );
END;
$$;

-- ============================================================
-- submit_quiz: grade answers, grant XP, unlock next module
-- ============================================================
CREATE OR REPLACE FUNCTION submit_quiz(
    p_module_id text,
    p_answers int[],
    p_quiz_first boolean DEFAULT false
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_correct_count int := 0;
    v_total int := 0;
    v_score int;
    v_passed boolean;
    v_xp_gained int := 30;
    v_q RECORD;
    v_idx int := 0;
    v_next_module_id text;
    v_course_id text;
    v_module_sort int;
BEGIN
    FOR v_q IN
        SELECT correct_index FROM quiz_questions
        WHERE module_id = p_module_id
        ORDER BY sort_order
    LOOP
        v_total := v_total + 1;
        IF v_idx < array_length(p_answers, 1) AND p_answers[v_idx + 1] = v_q.correct_index THEN
            v_correct_count := v_correct_count + 1;
        END IF;
        v_idx := v_idx + 1;
    END LOOP;

    IF v_total = 0 THEN
        RETURN json_build_object('error', 'no questions found');
    END IF;

    v_score := (v_correct_count * 100) / v_total;
    v_passed := v_score >= 70;

    IF v_score = 100 THEN
        v_xp_gained := v_xp_gained + 50;
    END IF;
    IF v_score = 100 AND p_quiz_first THEN
        v_xp_gained := v_xp_gained + 75;
    END IF;

    INSERT INTO quiz_attempts (user_id, module_id, score, correct_count, total, passed, quiz_first, answers)
    VALUES (v_user_id, p_module_id, v_score, v_correct_count, v_total, v_passed, p_quiz_first, to_jsonb(p_answers));

    UPDATE user_progress SET xp = xp + v_xp_gained WHERE user_id = v_user_id;

    IF v_passed THEN
        SELECT m.course_id, m.sort_order INTO v_course_id, v_module_sort
        FROM modules m WHERE m.id = p_module_id;

        SELECT id INTO v_next_module_id
        FROM modules
        WHERE course_id = v_course_id AND sort_order > v_module_sort
        ORDER BY sort_order LIMIT 1;

        IF v_next_module_id IS NOT NULL THEN
            INSERT INTO lesson_progress (user_id, lesson_id, status)
            SELECT v_user_id, l.id, 'available'
            FROM lessons l
            WHERE l.module_id = v_next_module_id
            ORDER BY l.sort_order LIMIT 1
            ON CONFLICT (user_id, lesson_id)
            DO UPDATE SET status = 'available' WHERE lesson_progress.status = 'locked';
        END IF;
    END IF;

    PERFORM update_badges(v_user_id);

    RETURN json_build_object(
        'module_id', p_module_id,
        'score', v_score,
        'correct_count', v_correct_count,
        'total', v_total,
        'passed', v_passed,
        'quiz_first', p_quiz_first,
        'xp_gained', v_xp_gained
    );
END;
$$;

-- ============================================================
-- get_guided_review: return weak points from last attempt
-- ============================================================
CREATE OR REPLACE FUNCTION get_guided_review(p_module_id text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_answers jsonb;
    v_result json;
BEGIN
    SELECT answers INTO v_answers
    FROM quiz_attempts
    WHERE user_id = v_user_id AND module_id = p_module_id
    ORDER BY created_at DESC LIMIT 1;

    IF v_answers IS NULL THEN
        RETURN '[]'::json;
    END IF;

    SELECT json_agg(json_build_object(
        'id', q.id,
        'topic', q.question,
        'explanation', q.explanation,
        'lesson_id', (SELECT l.id FROM lessons l WHERE l.module_id = p_module_id ORDER BY l.sort_order LIMIT 1)
    )) INTO v_result
    FROM quiz_questions q
    WHERE q.module_id = p_module_id
    AND q.sort_order < jsonb_array_length(v_answers)
    AND (v_answers->>q.sort_order::text)::int != q.correct_index
    ORDER BY q.sort_order;

    RETURN COALESCE(v_result, '[]'::json);
END;
$$;
