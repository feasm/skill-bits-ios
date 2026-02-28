# Supabase Backend Integration - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrar o SkillBits iOS de dados mock in-memory para Supabase com auth real, PostgreSQL, e logica de gamificacao server-side.

**Architecture:** Supabase BaaS com PostgreSQL, auth nativo, RLS, e PostgreSQL Functions (RPC) para logica de gamificacao. O iOS mantem os Repository protocols existentes e ganha implementacoes Supabase no novo pacote `SkillBitsSupabase`.

**Tech Stack:** Supabase, PostgreSQL, supabase-swift SDK, SwiftUI, SPM

**Design doc:** `docs/plans/2026-02-27-supabase-backend-design.md`

---

## Task 1: Inicializar projeto Supabase

**Files:**
- Create: `supabase/config.toml` (gerado pelo CLI)
- Create: `.gitignore` update (adicionar `Secrets.swift`, `.env`)

**Step 1: Instalar Supabase CLI (se nao tiver)**

Run: `brew install supabase/tap/supabase`

**Step 2: Inicializar Supabase no repositorio**

Run: `supabase init` na raiz do projeto
Expected: diretorio `supabase/` criado com `config.toml`

**Step 3: Criar projeto no Supabase Dashboard**

Acesse https://supabase.com/dashboard e crie um novo projeto "skillbits".
Anote: `SUPABASE_URL` e `SUPABASE_ANON_KEY`.

**Step 4: Criar arquivo de segredos**

Create: `ios/SkillBitsApp/Sources/Secrets.swift`

```swift
enum Secrets {
    static let supabaseURL = "https://YOUR_PROJECT.supabase.co"
    static let supabaseAnonKey = "YOUR_ANON_KEY"
}
```

Adicionar `Secrets.swift` ao `.gitignore`.
Criar `ios/SkillBitsApp/Sources/Secrets.example.swift` com valores placeholder pra referencia.

**Step 5: Commit**

```bash
git add supabase/ .gitignore ios/SkillBitsApp/Sources/Secrets.example.swift
git commit -m "chore: init supabase project structure"
```

---

## Task 2: Migration - Schema de tabelas

**Files:**
- Create: `supabase/migrations/001_schema.sql`

**Step 1: Escrever migration SQL**

```sql
-- Courses (conteudo publico)
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

-- Modules
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

-- Lessons
CREATE TABLE lessons (
    id text PRIMARY KEY,
    module_id text NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    title text NOT NULL,
    duration text,
    content jsonb,
    sort_order int DEFAULT 0
);

CREATE INDEX idx_lessons_module ON lessons(module_id, sort_order);

-- User Progress (1:1 com auth.users)
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

-- Lesson Progress (por usuario, por licao)
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

-- Quiz Questions
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

-- Quiz Attempts
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
```

**Step 2: Aplicar migration localmente**

Run: `supabase db push` (ou `supabase start` + `supabase db reset`)
Expected: tabelas criadas sem erro

**Step 3: Commit**

```bash
git add supabase/migrations/001_schema.sql
git commit -m "feat(db): create initial schema with courses, progress, quiz tables"
```

---

## Task 3: Migration - Row Level Security

**Files:**
- Create: `supabase/migrations/002_rls.sql`

**Step 1: Escrever RLS policies**

```sql
-- Habilitar RLS em todas as tabelas
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;

-- Conteudo publico: leitura para usuarios autenticados
CREATE POLICY "courses_read" ON courses FOR SELECT TO authenticated USING (true);
CREATE POLICY "modules_read" ON modules FOR SELECT TO authenticated USING (true);
CREATE POLICY "lessons_read" ON lessons FOR SELECT TO authenticated USING (true);
CREATE POLICY "quiz_questions_read" ON quiz_questions FOR SELECT TO authenticated USING (true);

-- Dados privados: cada usuario so acessa o seu
CREATE POLICY "user_progress_all" ON user_progress FOR ALL TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "lesson_progress_all" ON lesson_progress FOR ALL TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "quiz_attempts_all" ON quiz_attempts FOR ALL TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
```

**Step 2: Aplicar e verificar**

Run: `supabase db push`
Expected: policies criadas sem erro

**Step 3: Commit**

```bash
git add supabase/migrations/002_rls.sql
git commit -m "feat(db): add RLS policies for data isolation"
```

---

## Task 4: Migration - PostgreSQL Functions (gamificacao server-side)

**Files:**
- Create: `supabase/migrations/003_functions.sql`

**Step 1: Escrever funcoes RPC**

```sql
-- ============================================================
-- initialize_user_progress: chamada apos onboarding
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
    -- Cria registro de progresso
    INSERT INTO user_progress (user_id, daily_goal, onboarding_reason, badges)
    VALUES (
        v_user_id,
        p_daily_goal,
        p_reason,
        '[{"id":"b1","name":"Primeiro Passo","icon":"🚀","unlocked":false},{"id":"b2","name":"Quiz Master","icon":"⚡","unlocked":false},{"id":"b3","name":"Estudante Dedicado","icon":"🔥","unlocked":false}]'::jsonb
    )
    ON CONFLICT (user_id) DO NOTHING;

    -- Inicializa lesson_progress: primeira licao de cada modulo free = 'available', restante = 'locked'
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
-- complete_lesson: marca concluida, calcula XP, streak, desbloqueia proxima
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
    -- Marca licao como completed
    UPDATE lesson_progress
    SET status = 'completed', progress = 100, completed_at = now()
    WHERE user_id = v_user_id AND lesson_id = p_lesson_id;

    -- Busca sort_order da licao atual
    SELECT sort_order INTO v_lesson_sort FROM lessons WHERE id = p_lesson_id;

    -- Desbloqueia proxima licao do modulo
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

    -- Atualiza progresso do usuario (XP + streak + minutos)
    SELECT xp, streak_days, last_study_date, studied_minutes_today
    INTO v_current_xp, v_streak, v_last_date, v_minutes
    FROM user_progress WHERE user_id = v_user_id;

    -- Calcula streak
    IF v_last_date IS NULL OR v_last_date < v_today - interval '1 day' THEN
        v_streak := 1;
    ELSIF v_last_date = v_today - interval '1 day' THEN
        v_streak := v_streak + 1;
    END IF;
    -- Se v_last_date = v_today, streak nao muda

    -- Reseta minutos se novo dia
    IF v_last_date IS NULL OR v_last_date < v_today THEN
        v_minutes := 0;
    END IF;

    UPDATE user_progress
    SET xp = xp + v_xp_gained,
        streak_days = v_streak,
        studied_minutes_today = v_minutes + 10,
        last_study_date = v_today
    WHERE user_id = v_user_id;

    -- Atualiza badges
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
-- submit_quiz: corrige, calcula XP, desbloqueia proximo modulo
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
    v_questions RECORD;
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
    -- Conta acertos
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

    -- Calcula XP bonus
    IF v_score = 100 THEN
        v_xp_gained := v_xp_gained + 50;
    END IF;
    IF v_score = 100 AND p_quiz_first THEN
        v_xp_gained := v_xp_gained + 75;
    END IF;

    -- Registra tentativa
    INSERT INTO quiz_attempts (user_id, module_id, score, correct_count, total, passed, quiz_first, answers)
    VALUES (v_user_id, p_module_id, v_score, v_correct_count, v_total, v_passed, p_quiz_first, to_jsonb(p_answers));

    -- Atualiza XP
    UPDATE user_progress SET xp = xp + v_xp_gained WHERE user_id = v_user_id;

    -- Se aprovado: desbloqueia primeira licao do proximo modulo
    IF v_passed THEN
        SELECT m.course_id, m.sort_order INTO v_course_id, v_module_sort
        FROM modules m WHERE m.id = p_module_id;

        SELECT id INTO v_next_module_id
        FROM modules
        WHERE course_id = v_course_id AND sort_order > v_module_sort
        ORDER BY sort_order LIMIT 1;

        IF v_next_module_id IS NOT NULL THEN
            -- Desbloqueia primeira licao do proximo modulo
            INSERT INTO lesson_progress (user_id, lesson_id, status)
            SELECT v_user_id, l.id, 'available'
            FROM lessons l
            WHERE l.module_id = v_next_module_id
            ORDER BY l.sort_order LIMIT 1
            ON CONFLICT (user_id, lesson_id)
            DO UPDATE SET status = 'available' WHERE lesson_progress.status = 'locked';
        END IF;
    END IF;

    -- Atualiza badges
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
-- get_guided_review: retorna pontos fracos baseado na ultima tentativa
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
    -- Busca respostas da ultima tentativa
    SELECT answers INTO v_answers
    FROM quiz_attempts
    WHERE user_id = v_user_id AND module_id = p_module_id
    ORDER BY created_at DESC LIMIT 1;

    IF v_answers IS NULL THEN
        RETURN '[]'::json;
    END IF;

    -- Retorna questoes que o usuario errou
    SELECT json_agg(json_build_object(
        'id', q.id,
        'topic', q.question,
        'explanation', q.explanation,
        'lesson_id', (SELECT l.id FROM lessons l WHERE l.module_id = p_module_id ORDER BY l.sort_order LIMIT 1)
    )) INTO v_result
    FROM quiz_questions q
    WHERE q.module_id = p_module_id
    AND q.sort_order < jsonb_array_length(v_answers)
    AND (v_answers->>q.sort_order)::int != q.correct_index
    ORDER BY q.sort_order;

    RETURN COALESCE(v_result, '[]'::json);
END;
$$;

-- ============================================================
-- update_badges: funcao auxiliar para atualizar badges
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
    SELECT xp, streak_days, badges INTO v_xp, v_streak, v_badges FROM user_progress WHERE user_id = p_user_id;

    SELECT count(*) INTO v_lessons_completed FROM lesson_progress WHERE user_id = p_user_id AND status = 'completed';

    -- Badge "Primeiro Passo": completar 1 licao
    IF v_lessons_completed >= 1 THEN
        v_badges := update_badge_status(v_badges, 'b1', true);
    END IF;

    -- Badge "Quiz Master": atingir 300 XP
    IF v_xp >= 300 THEN
        v_badges := update_badge_status(v_badges, 'b2', true);
    END IF;

    -- Badge "Estudante Dedicado": streak de 7 dias
    IF v_streak >= 7 THEN
        v_badges := update_badge_status(v_badges, 'b3', true);
    END IF;

    UPDATE user_progress SET badges = v_badges WHERE user_id = p_user_id;
END;
$$;

-- Helper: atualiza status de um badge no array jsonb
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
```

**Step 2: Aplicar e testar com SQL**

Run: `supabase db push`
Testar: executar `SELECT initialize_user_progress('curiosidade', 'minutes15')` no SQL Editor (como usuario de teste)

**Step 3: Commit**

```bash
git add supabase/migrations/003_functions.sql
git commit -m "feat(db): add RPC functions for gamification logic"
```

---

## Task 5: Seed data - 3 cursos MVP

**Files:**
- Create: `supabase/seed.sql`

**Step 1: Escrever seed SQL**

Migrar todo o conteudo do `MockBackendService` (`ios/Packages/SkillBitsNetworking/Sources/SkillBitsNetworking/MockBackend.swift`) para SQL INSERTs.

Inclui:
- 3 cursos (c1 Profissoes TI, c2 Conceitos TI, c3 Conceitos Programacao)
- Todos os modulos (~16) com sort_order
- Todas as licoes (~57) com sort_order
- Conteudo JSONB para as licoes que tem conteudo real (l1-l5 no mock atual)
- Quiz questions para m1 (10 questoes reais do mock) + questoes basicas para outros modulos

Formato do conteudo JSONB (deve mapear para `LessonBlock` do Swift):
```json
[
    {"type": "heading", "value": "Titulo"},
    {"type": "paragraph", "value": "Texto..."},
    {"type": "list", "value": ["Item 1", "Item 2"]},
    {"type": "code", "language": "swift", "text": "let x = 1"},
    {"type": "callout", "title": "Dica", "text": "Texto..."}
]
```

**Step 2: Aplicar seed**

Run: `supabase db seed`
Verificar: `SELECT count(*) FROM courses;` -> 3
Verificar: `SELECT count(*) FROM lessons;` -> 57
Verificar: `SELECT count(*) FROM quiz_questions WHERE module_id = 'm1';` -> 10

**Step 3: Commit**

```bash
git add supabase/seed.sql
git commit -m "feat(db): seed 3 MVP courses with lessons and quiz data"
```

---

## Task 6: Criar pacote SPM SkillBitsSupabase

**Files:**
- Create: `ios/Packages/SkillBitsSupabase/Package.swift`
- Create: `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/SupabaseClientProvider.swift`
- Modify: `ios/project.yml` (se usar XcodeGen) ou Xcode project pra adicionar o pacote

**Step 1: Criar Package.swift**

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SkillBitsSupabase",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SkillBitsSupabase", targets: ["SkillBitsSupabase"])
    ],
    dependencies: [
        .package(path: "../SkillBitsCore"),
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "SkillBitsSupabase",
            dependencies: [
                "SkillBitsCore",
                .product(name: "Supabase", package: "supabase-swift")
            ]
        )
    ]
)
```

**Step 2: Criar SupabaseClientProvider**

```swift
import Foundation
import Supabase

public enum SupabaseClientProvider {
    private static var _client: SupabaseClient?

    public static func configure(url: String, anonKey: String) {
        _client = SupabaseClient(
            supabaseURL: URL(string: url)!,
            supabaseKey: anonKey
        )
    }

    public static var client: SupabaseClient {
        guard let client = _client else {
            fatalError("SupabaseClientProvider.configure() must be called before accessing client")
        }
        return client
    }
}
```

**Step 3: Commit**

```bash
git add ios/Packages/SkillBitsSupabase/
git commit -m "feat: create SkillBitsSupabase SPM package with supabase-swift"
```

---

## Task 7: SupabaseAuthRepository

**Files:**
- Create: `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/SupabaseAuthRepository.swift`
- Modify: `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Repositories.swift` (adicionar `signUp` ao protocol se necessario)

**Step 1: Avaliar se AuthRepository precisa de signUp**

O protocol atual so tem `login` e `completeOnboarding`. Adicionar `signUp(email:password:)` ao protocol.

```swift
public protocol AuthRepository: Sendable {
    func signUp(email: String, password: String) async throws
    func login(email: String, password: String) async throws
    func completeOnboarding(answer: OnboardingAnswer) async throws
    func currentSession() async -> Bool
    func signOut() async throws
}
```

Atualizar `MockAuthRepository` pra implementar os novos metodos (no-ops).

**Step 2: Implementar SupabaseAuthRepository**

```swift
import Foundation
import SkillBitsCore
import Supabase

public struct SupabaseAuthRepository: AuthRepository, Sendable {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
    }

    public func login(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    public func completeOnboarding(answer: OnboardingAnswer) async throws {
        try await client.rpc("initialize_user_progress", params: [
            "p_reason": answer.reason,
            "p_daily_goal": answer.dailyGoal == .minutes15 ? "minutes15" : "minutes30"
        ]).execute()
    }

    public func currentSession() async -> Bool {
        return (try? await client.auth.session) != nil
    }

    public func signOut() async throws {
        try await client.auth.signOut()
    }
}
```

**Step 3: Commit**

```bash
git add ios/Packages/SkillBitsSupabase/Sources/ ios/Packages/SkillBitsCore/
git commit -m "feat: implement SupabaseAuthRepository with signUp, login, onboarding"
```

---

## Task 8: SupabaseCoursesRepository

**Files:**
- Create: `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/SupabaseCoursesRepository.swift`
- Create: `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/DTOs.swift` (Codable structs para mapear rows do DB)

**Step 1: Criar DTOs para mapeamento DB -> Swift Models**

Os DTOs sao necessarios porque os nomes das colunas no DB sao snake_case e os Swift models sao camelCase, e a estrutura e relacional (joins).

```swift
import Foundation
import SkillBitsCore

struct CourseDTO: Decodable {
    let id: String
    let title: String
    let shortDesc: String
    let description: String
    let emoji: String
    let category: String
    let level: String
    let totalDuration: String
    let color1: String
    let color2: String
    let accessTier: String
    let instructor: String

    enum CodingKeys: String, CodingKey {
        case id, title, description, emoji, category, level, color1, color2, instructor
        case shortDesc = "short_desc"
        case totalDuration = "total_duration"
        case accessTier = "access_tier"
    }

    func toDomain(modules: [Module], progress: Int) -> Course {
        Course(
            id: id,
            title: title,
            shortDesc: shortDesc,
            description: description,
            emoji: emoji,
            category: category,
            level: level,
            totalDuration: totalDuration,
            color1: color1,
            color2: color2,
            accessTier: accessTier == "premium" ? .premium : .free,
            instructor: instructor,
            progress: progress,
            modules: modules
        )
    }
}

struct ModuleDTO: Decodable {
    let id: String
    let courseId: String
    let title: String
    let description: String
    let duration: String
    let accessTier: String
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id, title, description, duration
        case courseId = "course_id"
        case accessTier = "access_tier"
        case sortOrder = "sort_order"
    }
}

struct LessonDTO: Decodable {
    let id: String
    let moduleId: String
    let title: String
    let duration: String
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id, title, duration
        case moduleId = "module_id"
        case sortOrder = "sort_order"
    }
}

struct LessonProgressDTO: Decodable {
    let lessonId: String
    let status: String
    let progress: Float

    enum CodingKeys: String, CodingKey {
        case status, progress
        case lessonId = "lesson_id"
    }
}
```

**Step 2: Implementar SupabaseCoursesRepository**

```swift
import Foundation
import SkillBitsCore
import Supabase

public struct SupabaseCoursesRepository: CoursesRepository, Sendable {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func fetchCourses() async throws -> [Course] {
        let courses: [CourseDTO] = try await client.from("courses")
            .select().order("sort_order").execute().value

        var result: [Course] = []
        for courseDTO in courses {
            let course = try await buildCourse(courseDTO)
            result.append(course)
        }
        return result
    }

    public func fetchCourse(id: String) async throws -> Course {
        let courseDTO: CourseDTO = try await client.from("courses")
            .select().eq("id", value: id).single().execute().value
        return try await buildCourse(courseDTO)
    }

    private func buildCourse(_ dto: CourseDTO) async throws -> Course {
        let moduleDTOs: [ModuleDTO] = try await client.from("modules")
            .select().eq("course_id", value: dto.id).order("sort_order").execute().value

        let lessonDTOs: [LessonDTO] = try await client.from("lessons")
            .select()
            .in("module_id", values: moduleDTOs.map(\.id))
            .order("sort_order")
            .execute().value

        let userId = try await client.auth.session.user.id
        let progressDTOs: [LessonProgressDTO] = try await client.from("lesson_progress")
            .select()
            .eq("user_id", value: userId.uuidString)
            .in("lesson_id", values: lessonDTOs.map(\.id))
            .execute().value

        let progressMap = Dictionary(uniqueKeysWithValues: progressDTOs.map { ($0.lessonId, $0) })

        // Busca ultimo quiz attempt por modulo
        let quizAttempts: [QuizAttemptDTO] = try await client.from("quiz_attempts")
            .select()
            .eq("user_id", value: userId.uuidString)
            .in("module_id", values: moduleDTOs.map(\.id))
            .order("created_at", ascending: false)
            .execute().value

        let latestQuizByModule = Dictionary(grouping: quizAttempts, by: \.moduleId)
            .mapValues(\.first)

        var modules: [Module] = []
        for modDTO in moduleDTOs {
            let modLessons = lessonDTOs.filter { $0.moduleId == modDTO.id }
            let lessons = modLessons.map { lessonDTO -> Lesson in
                let prog = progressMap[lessonDTO.id]
                let status: LessonStatus = {
                    guard let s = prog?.status else { return .locked }
                    return LessonStatus(rawValue: s) ?? .locked
                }()
                return Lesson(
                    id: lessonDTO.id,
                    title: lessonDTO.title,
                    duration: lessonDTO.duration,
                    status: status,
                    progress: prog.map { Int($0.progress) }
                )
            }

            let quiz = latestQuizByModule[modDTO.id] ?? nil
            let hasQuestions = true // assume cada modulo tem quiz

            modules.append(Module(
                id: modDTO.id,
                title: modDTO.title,
                description: modDTO.description,
                duration: modDTO.duration,
                lessons: lessons,
                quizAvailable: hasQuestions,
                quizCompleted: quiz?.passed ?? false,
                quizScore: quiz?.score,
                accessTier: modDTO.accessTier == "premium" ? .premium : .free
            ))
        }

        // Calcula progresso do curso
        let totalLessons = modules.flatMap(\.lessons).count
        let completedLessons = modules.flatMap(\.lessons).filter { $0.status == .completed }.count
        let progress = totalLessons > 0 ? (completedLessons * 100) / totalLessons : 0

        return dto.toDomain(modules: modules, progress: progress)
    }
}

struct QuizAttemptDTO: Decodable {
    let moduleId: String
    let score: Int
    let passed: Bool

    enum CodingKeys: String, CodingKey {
        case score, passed
        case moduleId = "module_id"
    }
}
```

**Step 3: Commit**

```bash
git add ios/Packages/SkillBitsSupabase/Sources/
git commit -m "feat: implement SupabaseCoursesRepository with DTOs and progress"
```

---

## Task 9: SupabaseLessonRepository

**Files:**
- Create: `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/SupabaseLessonRepository.swift`

**Step 1: Implementar**

O `content` JSONB precisa ser parseado para `[LessonBlock]`. Definir um `LessonContentDTO` que faz esse mapeamento.

```swift
import Foundation
import SkillBitsCore
import Supabase

public struct SupabaseLessonRepository: LessonRepository, Sendable {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func fetchLessonContent(courseId: String, moduleId: String, lessonId: String) async throws -> LessonContent {
        struct LessonRow: Decodable {
            let id: String
            let title: String
            let duration: String
            let content: [LessonBlockDTO]?
        }

        let row: LessonRow = try await client.from("lessons")
            .select("id, title, duration, content")
            .eq("id", value: lessonId)
            .single()
            .execute().value

        let blocks = (row.content ?? []).map { $0.toDomain() }

        return LessonContent(
            lessonId: row.id,
            title: row.title,
            readTime: row.duration,
            content: blocks
        )
    }

    public func completeLesson(courseId: String, moduleId: String, lessonId: String) async throws {
        try await client.rpc("complete_lesson", params: [
            "p_lesson_id": lessonId,
            "p_module_id": moduleId
        ]).execute()
    }
}
```

**Step 2: Criar LessonBlockDTO**

Adicionar ao `DTOs.swift`:

```swift
struct LessonBlockDTO: Decodable {
    let type: String
    let value: AnyCodable?
    let language: String?
    let text: String?
    let title: String?

    func toDomain() -> LessonBlock {
        switch type {
        case "heading":
            return .heading(value?.stringValue ?? "")
        case "heading2":
            return .heading2(value?.stringValue ?? "")
        case "paragraph":
            return .paragraph(value?.stringValue ?? "")
        case "list":
            return .list(value?.stringArrayValue ?? [])
        case "code":
            return .code(language: language ?? "", text: text ?? "")
        case "callout":
            return .callout(title: title, text: text ?? value?.stringValue ?? "")
        default:
            return .paragraph(value?.stringValue ?? "")
        }
    }
}
```

Nota: `AnyCodable` pode ser substituido por um enum custom decodable, ou usar o Supabase built-in `AnyJSON`. Avaliar na implementacao.

**Step 3: Commit**

```bash
git add ios/Packages/SkillBitsSupabase/Sources/
git commit -m "feat: implement SupabaseLessonRepository with content parsing"
```

---

## Task 10: SupabaseQuizRepository

**Files:**
- Create: `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/SupabaseQuizRepository.swift`

**Step 1: Implementar**

```swift
import Foundation
import SkillBitsCore
import Supabase

public struct SupabaseQuizRepository: QuizRepository, Sendable {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func fetchQuiz(moduleId: String) async throws -> [QuizQuestion] {
        struct QuizDTO: Decodable {
            let id: String
            let question: String
            let options: [String]
            let correctIndex: Int
            let explanation: String

            enum CodingKeys: String, CodingKey {
                case id, question, options, explanation
                case correctIndex = "correct_index"
            }
        }

        let dtos: [QuizDTO] = try await client.from("quiz_questions")
            .select()
            .eq("module_id", value: moduleId)
            .order("sort_order")
            .execute().value

        return dtos.map {
            QuizQuestion(id: $0.id, question: $0.question, options: $0.options,
                        correctIndex: $0.correctIndex, explanation: $0.explanation)
        }
    }

    public func submitQuiz(moduleId: String, answers: [Int], quizFirst: Bool) async throws -> QuizResult {
        struct SubmitResult: Decodable {
            let moduleId: String
            let score: Int
            let correctCount: Int
            let total: Int
            let passed: Bool
            let quizFirst: Bool

            enum CodingKeys: String, CodingKey {
                case score, total, passed
                case moduleId = "module_id"
                case correctCount = "correct_count"
                case quizFirst = "quiz_first"
            }
        }

        let result: SubmitResult = try await client.rpc("submit_quiz", params: [
            "p_module_id": AnyJSON.string(moduleId),
            "p_answers": AnyJSON.array(answers.map { AnyJSON.integer($0) }),
            "p_quiz_first": AnyJSON.bool(quizFirst)
        ]).execute().value

        return QuizResult(
            moduleId: result.moduleId,
            score: result.score,
            correctCount: result.correctCount,
            total: result.total,
            passed: result.passed,
            quizFirst: result.quizFirst
        )
    }

    public func fetchGuidedReview(moduleId: String) async throws -> [GuidedReviewPoint] {
        struct ReviewDTO: Decodable {
            let id: String
            let topic: String
            let explanation: String
            let lessonId: String

            enum CodingKeys: String, CodingKey {
                case id, topic, explanation
                case lessonId = "lesson_id"
            }
        }

        let dtos: [ReviewDTO] = try await client.rpc("get_guided_review", params: [
            "p_module_id": moduleId
        ]).execute().value

        return dtos.map {
            GuidedReviewPoint(id: $0.id, topic: $0.topic, explanation: $0.explanation, lessonId: $0.lessonId)
        }
    }
}
```

**Step 2: Commit**

```bash
git add ios/Packages/SkillBitsSupabase/Sources/
git commit -m "feat: implement SupabaseQuizRepository with RPC calls"
```

---

## Task 11: SupabaseProgressRepository

**Files:**
- Create: `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/SupabaseProgressRepository.swift`

**Step 1: Implementar**

```swift
import Foundation
import SkillBitsCore
import Supabase

public struct SupabaseProgressRepository: ProgressRepository, Sendable {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func fetchProgress() async throws -> UserProgress {
        struct ProgressDTO: Decodable {
            let xp: Int
            let streakDays: Int
            let dailyGoal: String
            let studiedMinutesToday: Int
            let badges: [BadgeDTO]

            enum CodingKeys: String, CodingKey {
                case xp, badges
                case streakDays = "streak_days"
                case dailyGoal = "daily_goal"
                case studiedMinutesToday = "studied_minutes_today"
            }
        }

        struct BadgeDTO: Decodable {
            let id: String
            let name: String
            let icon: String
            let unlocked: Bool
        }

        let userId = try await client.auth.session.user.id

        let dto: ProgressDTO = try await client.from("user_progress")
            .select()
            .eq("user_id", value: userId.uuidString)
            .single()
            .execute().value

        return UserProgress(
            xp: dto.xp,
            streakDays: dto.streakDays,
            dailyGoal: dto.dailyGoal == "minutes30" ? .minutes30 : .minutes15,
            studiedMinutesToday: dto.studiedMinutesToday,
            badges: dto.badges.map { Badge(id: $0.id, name: $0.name, icon: $0.icon, unlocked: $0.unlocked) }
        )
    }

    public func saveProgress(_ progress: UserProgress) async throws {
        let userId = try await client.auth.session.user.id

        try await client.from("user_progress")
            .update([
                "xp": AnyJSON.integer(progress.xp),
                "streak_days": AnyJSON.integer(progress.streakDays),
                "daily_goal": AnyJSON.string(progress.dailyGoal == .minutes30 ? "minutes30" : "minutes15"),
                "studied_minutes_today": AnyJSON.integer(progress.studiedMinutesToday)
            ])
            .eq("user_id", value: userId.uuidString)
            .execute()
    }
}
```

**Step 2: Commit**

```bash
git add ios/Packages/SkillBitsSupabase/Sources/
git commit -m "feat: implement SupabaseProgressRepository"
```

---

## Task 12: Integrar AppEnvironment e AppSession

**Files:**
- Modify: `ios/SkillBitsApp/Sources/AppEnvironment.swift`
- Modify: `ios/SkillBitsApp/Sources/AppSession.swift`
- Modify: `ios/SkillBitsApp/Sources/SkillBitsApp.swift`
- Create: `ios/SkillBitsApp/Sources/Secrets.swift` (com valores reais)

**Step 1: Atualizar AppEnvironment com toggle mock/supabase**

```swift
import Foundation
import SkillBitsCore
import SkillBitsNetworking
import SkillBitsSupabase
import Supabase

final class AppEnvironment {
    let authRepository: AuthRepository
    let coursesRepository: CoursesRepository
    let lessonRepository: LessonRepository
    let quizRepository: QuizRepository
    let progressRepository: ProgressRepository
    let paywallRepository: PaywallRepository
    let supabaseClient: SupabaseClient?

    init(useMock: Bool = false) {
        if useMock {
            let backend = MockBackendService()
            self.supabaseClient = nil
            self.authRepository = MockAuthRepository()
            self.coursesRepository = MockCoursesRepository(backend: backend)
            self.lessonRepository = MockLessonRepository(backend: backend)
            self.quizRepository = MockQuizRepository(backend: backend)
            self.progressRepository = MockProgressRepository(backend: backend)
            self.paywallRepository = MockPaywallRepository(backend: backend)
        } else {
            let client = SupabaseClient(
                supabaseURL: URL(string: Secrets.supabaseURL)!,
                supabaseKey: Secrets.supabaseAnonKey
            )
            self.supabaseClient = client
            self.authRepository = SupabaseAuthRepository(client: client)
            self.coursesRepository = SupabaseCoursesRepository(client: client)
            self.lessonRepository = SupabaseLessonRepository(client: client)
            self.quizRepository = SupabaseQuizRepository(client: client)
            self.progressRepository = SupabaseProgressRepository(client: client)
            self.paywallRepository = MockPaywallRepository(backend: MockBackendService()) // MVP: paywall fica mock
        }
    }
}
```

**Step 2: Atualizar AppSession com Supabase Auth state**

```swift
import Foundation
import Observation
import Supabase

@Observable
final class AppSession {
    var isLoggedIn = false
    var onboardingCompleted = false

    func observeAuthState(client: SupabaseClient?) {
        guard let client else { return }
        Task {
            for await (event, _) in client.auth.authStateChanges {
                await MainActor.run {
                    switch event {
                    case .signedIn:
                        self.isLoggedIn = true
                    case .signedOut:
                        self.isLoggedIn = false
                        self.onboardingCompleted = false
                    default:
                        break
                    }
                }
            }
        }
        // Check initial session
        Task {
            if let _ = try? await client.auth.session {
                await MainActor.run { self.isLoggedIn = true }
            }
        }
    }
}
```

**Step 3: Atualizar SkillBitsApp.swift para configurar Supabase**

Chamar `session.observeAuthState(client: env.supabaseClient)` no `onAppear`.

**Step 4: Commit**

```bash
git add ios/SkillBitsApp/Sources/
git commit -m "feat: wire AppEnvironment and AppSession with Supabase"
```

---

## Task 13: Atualizar LoginView e OnboardingView

**Files:**
- Modify: `ios/Packages/SkillBitsAuth/Sources/SkillBitsAuth/AuthViews.swift`

**Step 1: Adicionar signup ao LoginView**

A tela de login precisa de um botao de "Criar conta" que chama `signUp` do auth repository. Adicionar toggle entre login e signup na mesma tela.

**Step 2: Tratar erros**

Mostrar erros de auth (email invalido, senha fraca, credenciais incorretas) com um `Text` ou alert.

**Step 3: Commit**

```bash
git add ios/Packages/SkillBitsAuth/
git commit -m "feat: add signup flow and error handling to LoginView"
```

---

## Task 14: Fix quiz modal timing bug

**Files:**
- Modify: `ios/SkillBitsApp/Sources/MainTabView.swift`

**Step 1: Adicionar estados pendentes**

```swift
@State private var pendingQuizSession: QuizSession?
@State private var pendingQuizResult: QuizResult?
```

**Step 2: Refatorar sheets com onDismiss**

Aplicar o pattern descrito no plano `fix_quiz_modal_timing`:
- `.sheet(item: $activeQuizIntro, onDismiss: { ... })` -- verifica `pendingQuizSession`
- `.fullScreenCover(item: $activeQuiz, onDismiss: { ... })` -- verifica `pendingQuizResult`
- `.sheet(item: $quizResult, onDismiss: { ... })` -- verifica `pendingQuizSession` (retry)

**Step 3: Testar**

Verificar que:
1. Clicar "Estudar primeiro" no QuizIntro abre o quiz
2. Clicar "Ir direto para o quiz" abre o quiz
3. Finalizar quiz mostra resultado
4. Retry no resultado abre quiz novamente

**Step 4: Commit**

```bash
git add ios/SkillBitsApp/Sources/MainTabView.swift
git commit -m "fix: resolve quiz modal timing bug with pending state + onDismiss"
```

---

## Task 15: Teste end-to-end

**Step 1: Criar conta de teste no Supabase**

Usar o Dashboard ou app pra criar um usuario de teste.

**Step 2: Verificar fluxo completo**

1. Abrir app -> tela de login
2. Criar conta -> onboarding -> main tabs
3. Ver cursos -> abrir curso -> ler licao -> completar
4. Verificar XP atualizado
5. Fazer quiz -> ver resultado
6. Fechar e reabrir app -> sessao mantida, progresso persistido

**Step 3: Commit final**

```bash
git add .
git commit -m "feat: complete Supabase backend integration for MVP"
```
