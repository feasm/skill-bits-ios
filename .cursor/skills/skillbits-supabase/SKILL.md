---
name: skillbits-supabase
description: Use when changing Supabase schema, RLS policies, RPC business rules, seed content, or repository mapping between Supabase and app models in SkillBits iOS.
---

# SkillBits Supabase Backend

## Overview

Guia operacional para alteracoes em:

- schema/migrations SQL
- RLS/policies
- funcoes RPC
- seed data
- contrato backend -> DTO -> repositories -> UI

Use junto com `skillbits-backend` para planejamento/execucao por complexidade.

## Arquivos principais

- `supabase/migrations/20260227230001_schema.sql`
- `supabase/migrations/20260227230002_rls.sql`
- `supabase/migrations/20260227230003_functions.sql`
- `supabase/seed.sql`
- `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/SupabaseManager.swift`
- `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/Supabase*Repository.swift`
- `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/DTOs.swift`

## Tabelas core e colunas principais

### `courses`

- PK: `id`
- Metadados: `title`, `short_desc`, `description`, `emoji`, `category`, `level`
- UX: `total_duration`, `color1`, `color2`, `instructor`, `sort_order`
- Monetizacao: `access_tier` (`free|premium`)

### `modules`

- PK: `id`, FK: `course_id -> courses.id`
- Conteudo: `title`, `description`, `duration`, `sort_order`
- Monetizacao: `access_tier`

### `lessons`

- PK: `id`, FK: `module_id -> modules.id`
- Conteudo: `title`, `duration`, `sort_order`, `content jsonb`

### `user_progress`

- PK: `id`, unique FK: `user_id -> auth.users.id`
- Gamificacao: `xp`, `streak_days`, `studied_minutes_today`, `last_study_date`
- Personalizacao: `daily_goal`, `onboarding_reason`
- Conquistas: `badges jsonb`

### `lesson_progress`

- PK: `id`, FKs: `user_id`, `lesson_id`
- Estado: `status`, `progress`, `completed_at`
- Restricao: `unique(user_id, lesson_id)`

### `quiz_questions`

- PK: `id`, FK: `module_id`
- Pergunta: `question`, `options jsonb`, `correct_index`, `explanation`, `sort_order`

### `quiz_attempts`

- PK: `id`, FKs: `user_id`, `module_id`
- Resultado: `score`, `correct_count`, `total`, `passed`
- Contexto: `quiz_first`, `answers jsonb`, `created_at`

## RPCs core (assinatura e comportamento)

### `initialize_user_progress(p_reason text, p_daily_goal text default 'minutes15') -> json`

- Cria `user_progress` com badges iniciais.
- Cria `lesson_progress` inicial para todas as lessons.
- Regras de unlock inicial:
  - primeiro lesson de modulo free: `available`
  - demais lessons free: `locked`
  - modulo premium: `locked`

### `complete_lesson(p_lesson_id text, p_module_id text) -> json`

- Marca lesson como concluida.
- Unlock da proxima lesson no modulo.
- Atualiza streak e minutos do dia.
- Concede XP base (`20`).
- Recalcula badges.

Retorno esperado:
- `xp_gained`
- `new_xp`
- `streak_days`
- `next_lesson_id`

### `submit_quiz(p_module_id text, p_answers int[], p_quiz_first boolean default false) -> json`

- Corrige respostas contra `quiz_questions`.
- Regra de aprovacao: `score >= 70`.
- XP:
  - base `30`
  - bonus `+50` em 100%
  - bonus extra `+75` em 100% com `quiz_first=true`
- Persiste tentativa em `quiz_attempts`.
- Se aprovado, unlock da primeira lesson do proximo modulo.
- Recalcula badges.

Retorno esperado:
- `module_id`, `score`, `correct_count`, `total`, `passed`, `quiz_first`, `xp_gained`

### `get_guided_review(p_module_id text) -> json`

- Busca ultima tentativa do usuario para modulo.
- Compara `answers` vs `correct_index`.
- Retorna pontos fracos com `id`, `topic`, `explanation`, `lesson_id`.

### `update_badges(p_user_id uuid) -> void`

- Unlock rules:
  - `b1`: primeira lesson completa
  - `b2`: `xp >= 300`
  - `b3`: `streak_days >= 7`

### `update_badge_status(p_badges jsonb, p_badge_id text, p_unlocked boolean) -> jsonb`

- Helper interno para editar jsonb de badges.

## RLS atual

- Conteudo publico para usuarios autenticados:
  - `courses`, `modules`, `lessons`, `quiz_questions` com `SELECT USING (true)`
- Dados privados por usuario:
  - `user_progress`, `lesson_progress`, `quiz_attempts`
  - regra `auth.uid() = user_id` em `USING` e `WITH CHECK`

## Regras criticas

- Regras de desbloqueio e gamificacao vivem principalmente nas RPCs.
- RLS deve restringir dados de progresso/tentativas por `auth.uid()`.
- Mudanca de regra no banco deve refletir em DTO/repository e UI.
- Toda migration nova exige revisao de seed e efeito no onboarding.

## Mapping backend -> app (DTOs/repositorios)

### DTOs (`DTOs.swift`)

- `CourseDTO`
  - `short_desc -> shortDesc`
  - `total_duration -> totalDuration`
  - `access_tier -> accessTier`
- `ModuleDTO`
  - `course_id -> courseId`
  - `access_tier -> accessTier`
  - `sort_order -> sortOrder`
- `LessonDTO`
  - `module_id -> moduleId`
  - `sort_order -> sortOrder`
- `LessonProgressDTO`
  - `lesson_id -> lessonId`
- `QuizAttemptDTO`
  - `module_id -> moduleId`
- `LessonBlockDTO`
  - parse de `content jsonb` para blocos de UI

### Repositories (`Supabase*Repository.swift`)

- `SupabaseAuthRepository.completeOnboarding` chama `initialize_user_progress`
- `SupabaseLessonRepository.completeLesson` chama `complete_lesson`
- `SupabaseQuizRepository.submitQuiz` chama `submit_quiz`
- `SupabaseQuizRepository.fetchGuidedReview` chama `get_guided_review`
- `SupabaseCoursesRepository` agrega:
  - `courses` + `modules` + `lessons`
  - `lesson_progress` por usuario
  - ultimo quiz por modulo (`quiz_attempts`)
- `SupabaseProgressRepository` faz read/write de `user_progress`

## Estado de seed (MVP atual)

- `courses`: 3
- `modules`: 20
- `lessons`: 57 (100% com conteudo JSONB)
- `quiz_questions`: 48

## Cuidados

- Nao alterar contrato de RPC sem atualizar chamadas no app.
- Nao alterar nome de coluna sem revisar `CodingKeys` dos DTOs.
- Nao publicar seed inconsistente com schema.
- Validar impacto de migracoes em ambiente local antes de subir.
- Validar auth flow no cloud antes de afirmar regressao no app.

## Fluxo operacional recomendado

1. Criar migration timestamp em `supabase/migrations/`.
2. Atualizar RLS/RPC/seed conforme impacto.
3. Rodar `npx --yes supabase db reset`.
4. Validar build iOS (`xcodebuild`).
5. Aplicar em cloud com `npx --yes supabase db push --include-seed`.
6. Atualizar docs de estado:
   - `.cursor/skills/skillbits-backend/references/backend-state.md`

## Gaps atuais

- Compra premium ainda nao sincronizada com backend real.
- Sem trilha completa de reset password/social login.
- Badges ainda com apenas 3 regras basicas.
