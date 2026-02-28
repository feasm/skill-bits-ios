# SkillBits Backend State

Last update: 2026-02-28
Source of truth: migrations + seed + SkillBitsSupabase repositories

## 1) Supabase Project Status

- Cloud project linked: `anghblufkrjwfcuifcmb`
- Cloud URL: `https://anghblufkrjwfcuifcmb.supabase.co`
- iOS app points to cloud URL in `ios/SkillBitsApp/Sources/Secrets.swift`
- Auth note: email confirmation must be disabled for immediate sign-up session in current app flow

## 2) Database Schema

### `courses`

- `id text` (PK)
- `title text not null`
- `short_desc text`
- `description text`
- `emoji text`
- `category text`
- `level text`
- `total_duration text`
- `color1 text`
- `color2 text`
- `access_tier text not null default 'free'`
- `instructor text`
- `sort_order int default 0`
- `created_at timestamptz default now()`

### `modules`

- `id text` (PK)
- `course_id text` (FK -> `courses.id`, `on delete cascade`)
- `title text not null`
- `description text`
- `duration text`
- `access_tier text not null default 'free'`
- `sort_order int default 0`

### `lessons`

- `id text` (PK)
- `module_id text` (FK -> `modules.id`, `on delete cascade`)
- `title text not null`
- `duration text`
- `content jsonb`
- `sort_order int default 0`

### `user_progress`

- `id uuid` (PK, default `gen_random_uuid()`)
- `user_id uuid not null unique` (FK -> `auth.users.id`, `on delete cascade`)
- `xp int default 0`
- `streak_days int default 0`
- `studied_minutes_today int default 0`
- `last_study_date date`
- `daily_goal text default 'minutes15'`
- `badges jsonb default '[]'::jsonb`
- `onboarding_reason text`
- `created_at timestamptz default now()`

### `lesson_progress`

- `id uuid` (PK, default `gen_random_uuid()`)
- `user_id uuid not null` (FK -> `auth.users.id`, `on delete cascade`)
- `lesson_id text not null` (FK -> `lessons.id`, `on delete cascade`)
- `status text not null default 'available'`
- `progress float default 0`
- `completed_at timestamptz`
- `unique(user_id, lesson_id)`

### `quiz_questions`

- `id text` (PK)
- `module_id text not null` (FK -> `modules.id`, `on delete cascade`)
- `question text not null`
- `options jsonb not null`
- `correct_index int not null`
- `explanation text`
- `sort_order int default 0`

### `quiz_attempts`

- `id uuid` (PK, default `gen_random_uuid()`)
- `user_id uuid not null` (FK -> `auth.users.id`, `on delete cascade`)
- `module_id text not null` (FK -> `modules.id`, `on delete cascade`)
- `score int not null`
- `correct_count int not null`
- `total int not null`
- `passed boolean not null`
- `quiz_first boolean default false`
- `answers jsonb`
- `created_at timestamptz default now()`

## 3) Indexes

- `idx_modules_course` on `modules(course_id, sort_order)`
- `idx_lessons_module` on `lessons(module_id, sort_order)`
- `idx_lesson_progress_user` on `lesson_progress(user_id)`
- `idx_quiz_module` on `quiz_questions(module_id, sort_order)`
- `idx_quiz_attempts_user_module` on `quiz_attempts(user_id, module_id)`

## 4) RLS Policies (enabled on all core tables)

Tables with RLS enabled:
- `courses`
- `modules`
- `lessons`
- `quiz_questions`
- `user_progress`
- `lesson_progress`
- `quiz_attempts`

Policies:
- `courses_read`: `select` for `authenticated`, `using (true)`
- `modules_read`: `select` for `authenticated`, `using (true)`
- `lessons_read`: `select` for `authenticated`, `using (true)`
- `quiz_questions_read`: `select` for `authenticated`, `using (true)`
- `user_progress_all`: `for all` with `auth.uid() = user_id`
- `lesson_progress_all`: `for all` with `auth.uid() = user_id`
- `quiz_attempts_all`: `for all` with `auth.uid() = user_id`

## 5) RPC Functions

### `initialize_user_progress(p_reason text, p_daily_goal text default 'minutes15') returns json`

- Creates base row in `user_progress` with onboarding reason and default badges.
- Bootstraps `lesson_progress` across all lessons:
  - first lesson of free module -> `available`
  - other free lessons -> `locked`
  - premium modules -> `locked`
- Returns `{"success": true}`.

### `complete_lesson(p_lesson_id text, p_module_id text) returns json`

- Marks lesson as completed (`status`, `progress=100`, `completed_at`).
- Unlocks next lesson in same module.
- Updates XP and streak in `user_progress`:
  - base XP gain: `20`
  - increments daily studied minutes by `10`
- Recalculates badges via `update_badges`.
- Returns payload with `xp_gained`, `new_xp`, `streak_days`, `next_lesson_id`.

### `submit_quiz(p_module_id text, p_answers int[], p_quiz_first boolean default false) returns json`

- Grades answers against `quiz_questions`.
- Pass rule: `score >= 70`.
- XP rules:
  - base XP gain: `30`
  - +`50` on perfect score (`100`)
  - +`75` extra on perfect score when `quiz_first = true`
- Stores attempt in `quiz_attempts`.
- On pass, unlocks first lesson of next module in same course.
- Recalculates badges via `update_badges`.
- Returns payload with `score`, `correct_count`, `total`, `passed`, `quiz_first`, `xp_gained`.

### `get_guided_review(p_module_id text) returns json`

- Uses latest `quiz_attempts.answers`.
- Returns weak points array with:
  - `id` (question id)
  - `topic` (question text)
  - `explanation`
  - `lesson_id` (first lesson in module)
- Returns empty array when no attempt exists.

### `update_badges(p_user_id uuid) returns void`

- Reads user XP, streak and completed lessons.
- Unlocks badge ids:
  - `b1` after first completed lesson
  - `b2` at `xp >= 300`
  - `b3` at `streak_days >= 7`

### `update_badge_status(p_badges jsonb, p_badge_id text, p_unlocked boolean) returns jsonb`

- Helper to toggle `unlocked` inside badges jsonb array.

## 6) Seed Snapshot

- Courses: `3` (`c1`..`c3`)
- Modules: `20` (`m1`..`m20`)
- Lessons: `57` (`l1`..`l57`)
- Quiz questions: `48`
  - `m1`: 10 perguntas
  - `m2`..`m20`: 2 perguntas por modulo

Conteudo JSONB: **100% das 57 lessons possuem content preenchido** (atualizado 2026-02-28).
- c1 (l1-l27): 27 lessons com conteudo completo
- c2 (l28-l42): 15 lessons com conteudo completo
- c3 (l43-l57): 15 lessons com conteudo completo

## 7) iOS Mapping Snapshot

Package: `ios/Packages/SkillBitsSupabase`

### Manager

- `SupabaseManager` encapsula `SupabaseClient`.
- Expone factories de repositories e `authStateChanges` como `AsyncStream`.

### DTO mappings

- `CourseDTO`: mapeia `short_desc`, `total_duration`, `access_tier`
- `ModuleDTO`: mapeia `course_id`, `access_tier`, `sort_order`
- `LessonDTO`: mapeia `module_id`, `sort_order`
- `LessonProgressDTO`: mapeia `lesson_id`, `status`, `progress`
- `QuizAttemptDTO`: mapeia `module_id`, `score`, `passed`
- `LessonBlockDTO`: parseia blocos `jsonb` (`heading`, `heading2`, `paragraph`, `list`, `code`, `callout`)

### Repository <-> RPC usage

- `SupabaseAuthRepository.completeOnboarding` -> `initialize_user_progress`
- `SupabaseLessonRepository.completeLesson` -> `complete_lesson`
- `SupabaseQuizRepository.submitQuiz` -> `submit_quiz`
- `SupabaseQuizRepository.fetchGuidedReview` -> `get_guided_review`

## 8) Operational Commands

Local:
- `npx --yes supabase start`
- `npx --yes supabase db reset`
- `npx --yes supabase status`

Cloud:
- `SUPABASE_ACCESS_TOKEN=... npx --yes supabase link --project-ref anghblufkrjwfcuifcmb`
- `SUPABASE_ACCESS_TOKEN=... npx --yes supabase db push --include-seed`

Smoke tests:
- auth sign-up/sign-in
- select `courses` with bearer token
- call RPCs with bearer token

## 9) Known Gaps / Next Scale Steps

- Premium entitlement real ainda pendente (StoreKit + backend billing source of truth).
- Falta trilha completa para reset password e auth providers sociais.
- Badges ainda limitadas a 3 regras basicas.
- Faltam testes automatizados de regressao para RPCs criticas.
