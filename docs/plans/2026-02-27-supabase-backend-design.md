# SkillBits MVP -- Supabase Backend Design

## Resumo

Migrar o app SkillBits iOS de dados mock in-memory para um backend Supabase completo, com autenticacao real, persistencia em PostgreSQL, e logica de gamificacao server-side via PostgreSQL Functions.

## Decisoes de Arquitetura

| Decisao | Escolha | Justificativa |
|---------|---------|---------------|
| Backend | Supabase (BaaS) | Mais rapido pro MVP, PostgreSQL portavel, SDK Swift oficial |
| Auth | Supabase Auth (email/senha) | Pronto, seguro, sessao persistente no device |
| Logica de gamificacao | PostgreSQL Functions (RPC) | Server-side sem deploy separado, sem cold start |
| Conteudo dos cursos | JSONB no PostgreSQL | Flexivel, nao precisa de schema rigido pra LessonBlocks |
| Gate premium | Client-side + RLS | Client verifica access_tier, RLS como fallback |
| Migracao futura | Facil pra NestJS | PostgreSQL padrao, Repository protocols no iOS |

## Database Schema

### Tabelas

**courses**
- `id` text PK
- `title` text NOT NULL
- `short_desc` text
- `description` text
- `emoji` text
- `category` text
- `level` text
- `total_duration` text
- `color1` text
- `color2` text
- `access_tier` text DEFAULT 'free' -- 'free' | 'premium'
- `instructor` text
- `sort_order` int DEFAULT 0
- `created_at` timestamptz DEFAULT now()

**modules**
- `id` text PK
- `course_id` text FK -> courses(id) ON DELETE CASCADE
- `title` text NOT NULL
- `description` text
- `duration` text
- `access_tier` text DEFAULT 'free'
- `sort_order` int DEFAULT 0

**lessons**
- `id` text PK
- `module_id` text FK -> modules(id) ON DELETE CASCADE
- `title` text NOT NULL
- `duration` text
- `content` jsonb -- array de LessonBlock
- `sort_order` int DEFAULT 0

**user_progress**
- `id` uuid PK DEFAULT gen_random_uuid()
- `user_id` uuid NOT NULL FK -> auth.users(id) ON DELETE CASCADE UNIQUE
- `xp` int DEFAULT 0
- `streak_days` int DEFAULT 0
- `studied_minutes_today` int DEFAULT 0
- `last_study_date` date
- `daily_goal` text DEFAULT 'minutes15'
- `badges` jsonb DEFAULT '[]'
- `onboarding_reason` text
- `created_at` timestamptz DEFAULT now()

**lesson_progress**
- `id` uuid PK DEFAULT gen_random_uuid()
- `user_id` uuid NOT NULL FK -> auth.users(id) ON DELETE CASCADE
- `lesson_id` text NOT NULL FK -> lessons(id) ON DELETE CASCADE
- `status` text DEFAULT 'available' -- 'locked' | 'available' | 'inProgress' | 'completed'
- `progress` float DEFAULT 0
- `completed_at` timestamptz
- UNIQUE(user_id, lesson_id)

**quiz_questions**
- `id` text PK
- `module_id` text FK -> modules(id) ON DELETE CASCADE
- `question` text NOT NULL
- `options` jsonb NOT NULL -- array de strings
- `correct_index` int NOT NULL
- `explanation` text
- `sort_order` int DEFAULT 0

**quiz_attempts**
- `id` uuid PK DEFAULT gen_random_uuid()
- `user_id` uuid NOT NULL FK -> auth.users(id) ON DELETE CASCADE
- `module_id` text NOT NULL FK -> modules(id) ON DELETE CASCADE
- `score` int NOT NULL
- `correct_count` int NOT NULL
- `total` int NOT NULL
- `passed` boolean NOT NULL
- `quiz_first` boolean DEFAULT false
- `answers` jsonb
- `created_at` timestamptz DEFAULT now()

### Indexes

- `lesson_progress(user_id, lesson_id)` -- UNIQUE, consulta rapida de status
- `quiz_attempts(user_id, module_id)` -- consulta de tentativas
- `modules(course_id, sort_order)` -- listagem ordenada
- `lessons(module_id, sort_order)` -- listagem ordenada

## Row Level Security (RLS)

### Dados publicos (leitura p/ autenticados)
- `courses`: SELECT para `authenticated`
- `modules`: SELECT para `authenticated`
- `lessons`: SELECT para `authenticated`
- `quiz_questions`: SELECT para `authenticated`

### Dados privados (cada usuario ve so o seu)
- `user_progress`: ALL para `auth.uid() = user_id`
- `lesson_progress`: ALL para `auth.uid() = user_id`
- `quiz_attempts`: ALL para `auth.uid() = user_id`

## PostgreSQL Functions (RPC)

### `initialize_user_progress(p_reason text, p_daily_goal text)`
- Cria registro em user_progress com valores iniciais
- Cria lesson_progress para a primeira licao de cada modulo free como 'available'
- Demais licoes ficam 'locked'
- Chamada apos onboarding

### `complete_lesson(p_lesson_id text, p_course_id text, p_module_id text)`
- Marca lesson_progress como 'completed'
- Calcula XP (+20) e atualiza user_progress
- Atualiza streak (verifica last_study_date)
- Incrementa studied_minutes_today
- Desbloqueia proxima licao do modulo (status -> 'available')
- Retorna JSON: { xp_gained, new_xp, streak_days, next_lesson_id }

### `submit_quiz(p_module_id text, p_answers int[], p_quiz_first boolean)`
- Busca quiz_questions do modulo
- Calcula score e correct_count
- Determina se passed (>= 70%)
- Calcula XP: base 30, +50 se 100%, +75 se quiz_first e 100%
- Registra quiz_attempt
- Se passed: desbloqueia primeira licao do proximo modulo
- Retorna JSON: { score, correct_count, total, passed, quiz_first, xp_gained }

### `get_guided_review(p_module_id text)`
- Busca quiz_questions onde o usuario errou na ultima tentativa
- Retorna array de { topic, explanation, lesson_id }

## Autenticacao

### Fluxo
1. App abre -> Supabase SDK verifica sessao local
2. Se valida: carrega MainTabView
3. Se invalida: mostra LoginView
4. Login/Signup via `supabase.auth.signUp` / `supabase.auth.signIn`
5. Apos signup: mostra OnboardingView -> chama `initialize_user_progress`
6. Sessao persistida automaticamente pelo SDK

### Metodos suportados
- Email/senha (MVP)
- Apple Sign-In (pos-MVP, config no dashboard)

## Arquitetura iOS

### Novo pacote SPM: SkillBitsSupabase
- Depende de: SkillBitsCore, supabase-swift
- Contem implementacoes reais dos Repository protocols:
  - SupabaseAuthRepository
  - SupabaseCoursesRepository
  - SupabaseLessonRepository
  - SupabaseQuizRepository
  - SupabaseProgressRepository
  - SupabasePaywallRepository

### AppEnvironment com toggle
```swift
init(useMock: Bool = false) {
    if useMock {
        // mocks existentes
    } else {
        // repositorios Supabase
    }
}
```

### AppSession integrado com Supabase Auth
- `isLoggedIn` verifica sessao do SDK
- `onboardingCompleted` verifica se user_progress existe
- Listener de auth state changes

## Seeding de Conteudo

### Estrutura no repositorio
```
supabase/
  config.toml
  migrations/
    001_schema.sql
    002_rls.sql
    003_functions.sql
  seed.sql -- 3 cursos, ~16 modulos, ~57 licoes, quiz questions
```

### Comandos
- `supabase init` -- inicializa projeto
- `supabase start` -- PostgreSQL local via Docker
- `supabase db push` -- aplica migrations no cloud
- `supabase db seed` -- popula dados

## Credenciais

- Supabase URL e anon key em `Secrets.swift` ou `.xcconfig`
- Arquivo fora do git (adicionado ao .gitignore)
- Anon key e segura de expor (RLS protege), mas bom manter privada

## Escopo do MVP

### Incluido
- Auth email/senha com sessao persistente
- 3 cursos completos com conteudo real em JSONB
- Progresso persistido (XP, streak, licoes completas, quiz scores)
- Gamificacao server-side (XP, streak, desbloqueio)
- RLS para isolamento de dados
- Freemium gate (access_tier em courses e modules)

### Fora do escopo (pos-MVP)
- Apple Sign-In
- Offline support / cache local
- Push notifications
- Leaderboards
- Validacao server-side de IAP (StoreKit)
- Admin dashboard pra gerenciar cursos
