-- ============================================================
-- study_daily_log: historical daily study minutes for weekly chart
-- ============================================================

CREATE TABLE study_daily_log (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    study_date date NOT NULL,
    minutes int NOT NULL DEFAULT 0,
    UNIQUE(user_id, study_date)
);

CREATE INDEX idx_study_daily_log_user ON study_daily_log(user_id, study_date);

-- ============================================================
-- get_weekly_study: return last 7 days of study minutes
-- ============================================================

CREATE OR REPLACE FUNCTION get_weekly_study()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_result json;
BEGIN
    SELECT json_agg(
        json_build_object('study_date', d.day::date, 'minutes', COALESCE(s.minutes, 0))
        ORDER BY d.day
    ) INTO v_result
    FROM generate_series(
        current_date - interval '6 days',
        current_date,
        interval '1 day'
    ) AS d(day)
    LEFT JOIN study_daily_log s
        ON s.study_date = d.day::date
        AND s.user_id = v_user_id;

    RETURN COALESCE(v_result, '[]'::json);
END;
$$;

-- ============================================================
-- complete_lesson: updated to also log daily study minutes
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

    INSERT INTO study_daily_log (user_id, study_date, minutes)
    VALUES (v_user_id, v_today, 10)
    ON CONFLICT (user_id, study_date)
    DO UPDATE SET minutes = study_daily_log.minutes + 10;

    PERFORM update_badges(v_user_id);

    RETURN json_build_object(
        'xp_gained', v_xp_gained,
        'new_xp', v_current_xp + v_xp_gained,
        'streak_days', v_streak,
        'next_lesson_id', v_next_lesson_id
    );
END;
$$;
