# Supabase Integration - Plano de Continuacao

> **Para o proximo agente:** Este documento descreve o que ja foi feito e o que falta para completar a integracao Supabase no SkillBits iOS. Leia inteiro antes de comecar.

## Contexto do Projeto

SkillBits e um app iOS (SwiftUI, iOS 17+, MVVM, SPM modular) de micro-learning gamificado para TI. O app estava 100% mockado (dados in-memory). Estamos migrando para Supabase (PostgreSQL + Auth + RPC functions).

**Design docs de referencia:**
- `docs/plans/2026-02-27-supabase-backend-design.md` -- decisoes de arquitetura
- `docs/plans/2026-02-27-supabase-implementation.md` -- plano original de 15 tasks

---

## O que JA foi feito (Tasks 1-14)

### Supabase (backend)
- `supabase/` inicializado com `config.toml`
- `supabase/migrations/20260227230001_schema.sql` -- 7 tabelas (courses, modules, lessons, user_progress, lesson_progress, quiz_questions, quiz_attempts)
- `supabase/migrations/20260227230002_rls.sql` -- RLS policies (conteudo publico read-only, dados do usuario isolados)
- `supabase/migrations/20260227230003_functions.sql` -- 6 PostgreSQL functions:
  - `initialize_user_progress(p_reason, p_daily_goal)` -- cria progresso apos onboarding
  - `complete_lesson(p_lesson_id, p_module_id)` -- marca licao, +20 XP, streak, desbloqueia proxima
  - `submit_quiz(p_module_id, p_answers, p_quiz_first)` -- corrige quiz, XP bonus, desbloqueia modulo
  - `get_guided_review(p_module_id)` -- retorna questoes erradas
  - `update_badges(p_user_id)` -- recalcula badges
  - `update_badge_status(p_badges, p_badge_id, p_unlocked)` -- helper
- `supabase/seed.sql` -- 3 cursos, 20 modulos, 57 licoes (5 com conteudo JSONB real), 50+ quiz questions

### iOS (Swift)
- **Pacote `SkillBitsSupabase`** criado em `ios/Packages/SkillBitsSupabase/` com:
  - `Package.swift` -- depende de `SkillBitsCore` + `supabase-swift` 2.0.0+
  - `DTOs.swift` -- CourseDTO, ModuleDTO, LessonDTO, LessonProgressDTO, QuizAttemptDTO, LessonBlockDTO, LessonBlockValue
  - `SupabaseAuthRepository.swift` -- signUp, login, completeOnboarding (RPC), currentSession, signOut
  - `SupabaseCoursesRepository.swift` -- fetchCourses/fetchCourse com joins de modules, lessons, lesson_progress, quiz_attempts
  - `SupabaseLessonRepository.swift` -- fetchLessonContent (JSONB parse), completeLesson (RPC)
  - `SupabaseQuizRepository.swift` -- fetchQuiz, submitQuiz (RPC), fetchGuidedReview (RPC)
  - `SupabaseProgressRepository.swift` -- fetchProgress, saveProgress

- **`AuthRepository` protocol** atualizado com `signUp`, `currentSession`, `signOut` (em `Repositories.swift`)
- **`MockAuthRepository`** atualizado com implementacoes no-op dos novos metodos

- **`AppEnvironment.swift`** reescrito com toggle `useMock: Bool`:
  - `useMock = true` -> repositorios mock (como antes)
  - `useMock = false` -> repositorios Supabase (SupabaseClient criado com `Secrets.supabaseURL` e `Secrets.supabaseAnonKey`)
  - Expoe `supabaseClient: SupabaseClient?` para o AppSession

- **`AppSession.swift`** reescrito com `observeAuthState(client:)`:
  - Escuta `authStateChanges` do Supabase SDK
  - Atualiza `isLoggedIn` em `.signedIn` / `.signedOut`
  - Verifica sessao existente no startup

- **`SkillBitsApp.swift`** atualizado:
  - Chama `session.observeAuthState(client: env.supabaseClient)` no `onAppear`

- **`LoginView`/`LoginViewModel`** atualizados:
  - Toggle signup/login (`isSignUp`)
  - Metodo `submit()` que chama `signUp` ou `login` conforme o modo
  - Botao "Criar conta gratis" / "Fazer login" funcional
  - Mensagens de erro distintas para signup vs login

- **`project.yml`** atualizado com `SkillBitsSupabase` como package + dependency

- **`Secrets.swift`** criado com URL local (`http://127.0.0.1:54321`) e anon key padrao do Supabase local
- **`Secrets.example.swift`** criado com placeholders
- **`.gitignore`** criado (ignora Secrets.swift, DerivedData, .build, .DS_Store, etc.)

- **Quiz modal timing bug** ja estava corrigido (pendingQuizSession/pendingQuizResult + onDismiss nos sheets)

### O que NAO foi commitado
Nenhuma das mudancas acima foi commitada ainda. O git status mostra tudo como modified/untracked.

---

## O que FALTA fazer

### Task A: Regenerar Xcode project e resolver build errors

O `project.yml` foi atualizado mas o Xcode project nao foi regenerado. Precisa:

1. Rodar `xcodegen generate` em `ios/`
2. Abrir o projeto no Xcode
3. Resolver possiveis erros de build:
   - O `AppEnvironment.swift` faz `import Supabase` -- o Xcode project precisa ter o `SkillBitsSupabase` linkado, que traz `supabase-swift` transitivamente. Se `import Supabase` nao funcionar diretamente no app target, pode ser necessario adicionar `supabase-swift` como dependencia remota no `project.yml` tambem, ou expor o `SupabaseClient` de `SkillBitsSupabase` como re-export.
   - O `AppSession.swift` tambem faz `import Supabase`. Mesma questao.
   - **Alternativa mais limpa:** mover a criacao do `SupabaseClient` para dentro do `SkillBitsSupabase` package (tipo um `SupabaseClientProvider`) e so expor os repositorios. Assim o app target nao precisa importar `Supabase` diretamente.

**Solucao recomendada:**
- Criar um `SupabaseManager` em `SkillBitsSupabase` que encapsula o client e auth state observation
- `AppEnvironment` importa apenas `SkillBitsSupabase`, nao `Supabase`
- `AppSession` recebe callbacks, nao o client diretamente

Arquivos a modificar:
- `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/` -- adicionar SupabaseManager
- `ios/SkillBitsApp/Sources/AppEnvironment.swift` -- remover `import Supabase`
- `ios/SkillBitsApp/Sources/AppSession.swift` -- remover `import Supabase`

### Task B: Levantar Supabase local e testar migrations

1. Abrir Docker Desktop (ja foi instalado em `/Applications/Docker.app`)
2. Rodar `npx supabase start` na raiz do projeto (usa `npx` pois CLI nao esta instalado globalmente)
3. Anotar a `anon key` e `API URL` do output
4. Atualizar `Secrets.swift` com os valores do output (provavelmente ja estao corretos pois usam os defaults)
5. Rodar `npx supabase db reset` para aplicar migrations + seed
6. Verificar no Studio (`http://127.0.0.1:54323`):
   - Tabelas criadas
   - Dados do seed presentes
   - Functions criadas

### Task C: Build e fix de compilacao

Depois de regenerar o projeto:
1. `xcodebuild -project ios/SkillBits.xcodeproj -scheme SkillBitsApp -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1`
2. Corrigir quaisquer erros de compilacao
3. Erros provaveis:
   - `import Supabase` no app target (ver Task A)
   - Possible API mismatches com supabase-swift 2.x (verificar se `.rpc()` aceita os parametros como codificados)
   - `QuizQuestionView` mudou a interface (o MainTabView referencia `QuizQuestionView(repo:moduleId:quizFirst:onExit:)` que pode ser diferente do original)

### Task D: Testar no simulador

1. Rodar o app no simulador com Supabase local rodando
2. Fluxo completo:
   - Criar conta (signup)
   - Completar onboarding
   - Ver lista de cursos
   - Abrir curso, ler licao, completar
   - Fazer quiz
   - Verificar XP atualizado
   - Fechar e reabrir -> sessao mantida

### Task E: Commit

```bash
git add .
git commit -m "feat: integrate Supabase backend with auth, persistence, and server-side gamification"
```

---

## Arquitetura de referencia rapida

```
ios/
  project.yml                              -- XcodeGen config (atualizado)
  SkillBitsApp/Sources/
    SkillBitsApp.swift                      -- entry point, observa auth state
    AppEnvironment.swift                    -- DI container, toggle mock/supabase
    AppSession.swift                        -- auth state (isLoggedIn, onboardingCompleted)
    MainTabView.swift                       -- navegacao principal + quiz flow
    Secrets.swift                           -- URL + anon key (gitignored)
  Packages/
    SkillBitsCore/                          -- Models.swift, Repositories.swift (protocols)
    SkillBitsNetworking/                    -- MockBackendService, MockRepositories
    SkillBitsSupabase/                      -- NOVO: Supabase repositories + DTOs
    SkillBitsAuth/                          -- LoginView, OnboardingView
    SkillBitsCourses/                       -- CoursesView, CourseDetailView
    SkillBitsLesson/                        -- LessonReaderView
    SkillBitsQuiz/                          -- QuizIntroView, QuizQuestionView, QuizResultView
    SkillBitsProgress/                      -- ProgressScreenView
    SkillBitsProfile/                       -- ProfileScreenView
    SkillBitsPaywall/                       -- PaywallView
    SkillBitsDesignSystem/                  -- Design tokens, componentes UI
    SkillBitsGamification/                  -- XPService, LevelService, StreakService
    SkillBitsHome/                          -- HomeView (escondida)

supabase/
  config.toml
  migrations/
    20260227230001_schema.sql               -- tabelas
    20260227230002_rls.sql                  -- seguranca
    20260227230003_functions.sql            -- logica server-side
  seed.sql                                  -- dados dos 3 cursos MVP
```

## Repository Protocols (referencia)

```swift
public protocol AuthRepository: Sendable {
    func signUp(email: String, password: String) async throws
    func login(email: String, password: String) async throws
    func completeOnboarding(answer: OnboardingAnswer) async throws
    func currentSession() async -> Bool
    func signOut() async throws
}

public protocol CoursesRepository: Sendable {
    func fetchCourses() async throws -> [Course]
    func fetchCourse(id: String) async throws -> Course
}

public protocol LessonRepository: Sendable {
    func fetchLessonContent(courseId: String, moduleId: String, lessonId: String) async throws -> LessonContent
    func completeLesson(courseId: String, moduleId: String, lessonId: String) async throws
}

public protocol QuizRepository: Sendable {
    func fetchQuiz(moduleId: String) async throws -> [QuizQuestion]
    func submitQuiz(moduleId: String, answers: [Int], quizFirst: Bool) async throws -> QuizResult
    func fetchGuidedReview(moduleId: String) async throws -> [GuidedReviewPoint]
}

public protocol ProgressRepository: Sendable {
    func fetchProgress() async throws -> UserProgress
    func saveProgress(_ progress: UserProgress) async throws
}
```

## Comandos uteis

```bash
# Supabase local (precisa Docker rodando)
npx supabase start              # sobe PostgreSQL + Auth + Studio
npx supabase db reset           # aplica migrations + seed do zero
npx supabase stop               # para tudo

# Xcode project
cd ios && xcodegen generate     # regenera .xcodeproj do project.yml

# Build
xcodebuild -project ios/SkillBits.xcodeproj -scheme SkillBitsApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Studio local
open http://127.0.0.1:54323     # dashboard visual do Supabase
```

## Riscos e pontos de atencao

1. **`import Supabase` no app target** -- o tipo `SupabaseClient` e usado em `AppEnvironment` e `AppSession`. Se nao compilar, encapsular num `SupabaseManager` dentro do package `SkillBitsSupabase`.

2. **supabase-swift API** -- o SDK pode ter mudancas de API entre versoes. Verificar se `.rpc()`, `.from()`, `.auth.signUp()` etc. compilam com a versao resolvida.

3. **JSONB parsing** -- `LessonBlockDTO` usa um enum `LessonBlockValue` custom para decodificar valores que podem ser String ou [String]. Testar com dados reais do seed.

4. **PostgreSQL arrays** -- a funcao `submit_quiz` recebe `int[]`. O supabase-swift envia arrays como JSON. Verificar se o cast funciona ou se precisa ajustar o tipo do parametro.

5. **Docker** -- Docker Desktop foi instalado mas nunca foi iniciado com sucesso. Na primeira execucao pode pedir para aceitar licenca e fazer setup.

6. **Nenhum commit foi feito** -- todas as mudancas estao unstaged. Commitar apos build funcionar.
