# SkillBits — MVP Design Document

**Data:** 2026-02-27
**Status:** Aprovado
**Versão:** 1.0

---

## 1. Visão Geral

**SkillBits** é um app mobile-first de micro-learning de T.I voltado ao mercado brasileiro, com posicionamento anti-doom-scroll.

> "Para de perder tempo no Instagram. Aprenda T.I em 15 minutos."

A proposta central é transformar o tempo ocioso do dia em aprendizado real — sessões curtas de 15 a 30 minutos, gamificadas e acessíveis, que concorrem diretamente com o scroll infinito das redes sociais.

---

## 2. Público-Alvo

| Perfil | Descrição |
|---|---|
| **Universitários** | Alunos de qualquer curso que querem entender o mundo de T.I ou migrar de área |
| **Curiosos** | Pessoas que ouvem falar de tecnologia no dia a dia e querem entender do que se trata |
| **Iniciantes em T.I** | Quem quer entrar na área mas não sabe por onde começar |

**Mercado:** Brasil (conteúdo 100% em português)
**Faixa etária principal:** 18–30 anos

---

## 3. Posicionamento e Marketing

- **Tagline:** *"Seu próximo skill cabe em 15 minutos."*
- **Ângulo de marketing:** Anti-Instagram — "ao invés de scrollar, aprenda algo que muda sua carreira"
- **Diferencial técnico:** Quiz-first learning — você aprende errando, com feedback imediato
- **Comparação de mercado:** Duolingo para T.I — gamificado, acessível, viciante

---

## 4. Modelo de Negócio — Freemium

| Camada | O que inclui |
|---|---|
| **Grátis** | Curso "Profissões de T.I" completo + Módulo 1 de "Conceitos Básicos de T.I" |
| **Premium** | Todos os cursos completos, áudio em todas as aulas, conquistas exclusivas |
| **Preço sugerido** | R$ 19,90/mês ou R$ 129,90/ano |

**Estratégia de conversão:** O curso gratuito funciona como isca — apresenta o produto, cria hábito via gamificação, e converte naturalmente quando o usuário quer continuar.

---

## 5. Cursos do MVP

### Curso 1 — Profissões de T.I *(100% Grátis)*
> Objetivo: mostrar ao usuário que existe um mundo enorme de carreiras em T.I e qual delas combina com ele.

**Módulos sugeridos:**
- O que é T.I e por que importa
- Desenvolvedor de Software (Front, Back, Mobile, Full Stack)
- Designer de UX/UI
- Analista de Dados e Cientista de Dados
- DevOps e Engenheiro de Infraestrutura
- Segurança da Informação
- Gestão de T.I e Product Manager
- Como escolher sua trilha e por onde começar

---

### Curso 2 — Conceitos Básicos de T.I *(Módulo 1 grátis, resto Premium)*
> Objetivo: desmistificar os termos e conceitos que aparecem no dia a dia de quem trabalha ou quer trabalhar com tecnologia.

**Módulos sugeridos:**
- Hardware e Software — o básico que todo mundo deveria saber
- Como a Internet funciona (DNS, HTTP, navegadores)
- O que é Cloud Computing — e por que todo mundo fala disso
- Sistemas Operacionais — Windows, Linux, MacOS
- Segurança digital no dia a dia (senhas, phishing, VPN)
- Redes — IP, Wifi, cabo, como os dados chegam até você

---

### Curso 3 — Conceitos Básicos de Programação *(100% Premium)*
> Objetivo: dar ao usuário o primeiro contato real com lógica de programação, sem precisar instalar nada.

**Módulos sugeridos:**
- O que é programação e o que um computador realmente faz
- Variáveis e tipos de dados — como guardar informação
- Condições — ensinando o computador a tomar decisões
- Loops — fazendo o computador repetir tarefas
- Funções — organizando o código
- Seu primeiro algoritmo — resolvendo um problema do zero

---

## 6. Hero Feature — Quiz-First Learning

O grande diferencial do SkillBits: o quiz não é só avaliação, é a principal forma de aprender.

### Como funciona

Ao entrar em qualquer módulo, o usuário vê **dois caminhos**:

```
┌─────────────────────────────────────┐
│           Módulo 1                  │
│   O que é T.I e por que importa     │
│                                     │
│  📖  Estudar primeiro               │
│      Leia a aula, depois o quiz     │
│                                     │
│  ⚡  Ir direto pro Quiz             │
│      Teste o que você já sabe       │
└─────────────────────────────────────┘
```

### Feedback instantâneo (auto-aprendizado)

Quando o usuário erra uma questão, em vez de esperar o fim do quiz:

```
❌ Você respondeu: "Um tipo de banco de dados"
✅ Resposta correta: "Um processo isolado que compartilha o kernel do host"

💡 Por que? Containers compartilham o kernel do SO host,
   sendo mais leves que VMs completas. Pense neles como
   "caixas portáteis" para aplicações.

          [ Entendi, próxima questão ]
```

### Regras do Quiz-First

- Pode repetir o quiz quantas vezes quiser
- XP bônus (+50%) para quem acerta indo direto pro quiz
- Cada erro ensina — nunca pune sem explicar
- Módulo desbloqueado após 70% de acertos no quiz

---

## 7. Sistema de Gamificação

### Streak Diário
- Contador de dias consecutivos de estudo
- Meta diária configurada pelo usuário: **15 min** ou **30 min**
- Streak quebrado se passar 1 dia sem estudar
- Notificação push antes da meia-noite para preservar streak

### Sistema de XP

| Ação | XP |
|---|---|
| Completar uma aula | +20 XP |
| Completar quiz (qualquer resultado) | +30 XP |
| Quiz com 100% de acertos | +50 XP |
| Quiz-first com 100% de acertos | +75 XP (bônus) |
| Manter streak diário | +10 XP/dia |
| Completar um módulo | +100 XP |
| Completar um curso | +500 XP |

### Sistema de Níveis

| Nível | XP necessário | Nome |
|---|---|---|
| 1 | 0 | 🔵 Bit |
| 2 | 300 | 🟢 Byte |
| 3 | 1.000 | 🟡 KiloByte |
| 4 | 3.000 | 🟠 MegaByte |
| 5 | 7.000 | 🔴 GigaByte |

### Badges de Conquista

| Badge | Condição |
|---|---|
| 🚀 Primeiro Passo | Completar a primeira aula |
| ⚡ Quiz Master | Completar 5 quizzes com 100% |
| 🔥 Em Chamas | 7 dias de streak |
| 💪 Maratonista | 30 dias de streak |
| 🎯 Atirador de Elite | 10 quizzes via Quiz-first com 100% |
| 🎓 Graduado | Completar um curso completo |
| 👾 Bit Master | Atingir nível GigaByte |

---

## 8. Áudio nas Aulas

Cada aula tem um **botão de play** que narra o conteúdo em áudio enquanto o usuário acompanha o texto.

- **MVP:** Áudio gerado via TTS (Text-to-Speech) — rápido de produzir, funcional
- **Pós-MVP:** Substituir por narração humana gravada para maior qualidade
- O áudio não bloqueia a leitura — usuário pode ler e ouvir simultaneamente
- Velocidade ajustável (1x, 1.25x, 1.5x)

---

## 9. Onboarding

Ao criar a conta, o usuário responde 2 perguntas rápidas:

**1. Por que você está aqui?**
- 🎓 Sou universitário querendo entender T.I
- 💼 Quero mudar de carreira para T.I
- 🤔 Só tenho curiosidade sobre tecnologia
- 👨‍💻 Já trabalho em T.I e quero me atualizar

**2. Quanto tempo por dia você tem?**
- ⚡ 15 minutos (modo rápido)
- 🔥 30 minutos (modo dedicado)

Com base nas respostas, o app sugere por qual curso começar e define a meta diária automaticamente.

---

## 10. Feature Set Completo — Existe vs. Construir

### ✅ Já existe (aproveitar)
- Catálogo de cursos com busca e filtros por nível/categoria
- Estrutura Curso → Módulo → Aula com status (locked/available/in_progress/completed)
- Leitor de aula em texto rico (heading, paragraph, code, callout, list)
- Sistema de quiz (intro → perguntas → resultado → revisão guiada)
- Tela de progresso
- Paywall + tela de compra premium
- Tab bar: Cursos, Meus Estudos, Progresso, Perfil
- Tela de login

### 🔨 Construir no MVP

| Feature | Prioridade | Observações |
|---|---|---|
| Rebrand para SkillBits | 🔴 Alta | Nome, cores, logo, identidade visual |
| Quiz-first mechanic | 🔴 Alta | Dois caminhos no módulo: estudar vs. quiz direto |
| Feedback instantâneo no quiz | 🔴 Alta | Pop-up ao errar, antes de seguir |
| Player de áudio na aula | 🔴 Alta | TTS no MVP, gravado no futuro |
| Streak diário | 🔴 Alta | Contador + notificação push |
| Sistema de XP | 🔴 Alta | Acumulado por ações, persistido |
| Sistema de níveis (Bit → GigaByte) | 🟡 Média | Baseado no XP total |
| Badges de conquista | 🟡 Média | 7 badges iniciais |
| Onboarding (2 perguntas) | 🟡 Média | Personaliza a experiência inicial |
| Meta diária (15 ou 30 min) | 🟡 Média | Configurável, com progresso do dia |
| Conteúdo dos 3 cursos | 🔴 Alta | Profissões TI, Básico TI, Básico Prog. |
| Freemium gates | 🔴 Alta | Curso 1 free, Curso 2 parcial, Curso 3 premium |

---

## 11. Telas Novas / Modificadas

| Tela | Status | Mudança |
|---|---|---|
| LoginScreen | Modificar | Rebrand SkillBits |
| OnboardingScreen | **Nova** | 2 perguntas + seleção de meta |
| CoursesScreen | Modificar | Badge free/premium atualizado |
| ModuleDetailScreen | Modificar | Dois botões: Estudar vs. Quiz-first |
| LessonReaderScreen | Modificar | Adicionar player de áudio |
| QuizQuestionScreen | Modificar | Feedback instantâneo ao errar |
| ProgressScreen | Modificar | Adicionar XP, nível, streak, badges |
| ProfileScreen | Modificar | Mostrar nível, XP total, badges earned |
| HomeScreen | **Nova** (opcional) | Streak do dia, meta diária, próxima aula |

---

## 12. O que fica fora do MVP

- Leaderboards / ranking entre usuários
- Modo social (seguir amigos, compartilhar conquistas)
- Narração humana gravada (substituição do TTS)
- Curso 4 em diante
- Notificações push (pode vir logo após o MVP)

---

## 13. Stack Técnica — iOS

### Linguagem & Framework
- **Linguagem:** Swift 5.9+
- **UI:** SwiftUI
- **iOS mínimo:** iOS 17+
- **Arquitetura:** MVVM (Model → ViewModel → View)
- **Gerenciamento de estado:** `@Observable` (Swift 5.9 Observation framework)

### Arquitetura Modular — Swift Package Manager

Cada feature é um **Swift Package independente**. O app principal (`SkillBitsApp`) apenas compõe os pacotes, sem conter lógica de negócio.

```
SkillBits/
├── SkillBitsApp/                  # App target principal (entry point, DI, navigation)
│
└── Packages/
    ├── SkillBitsCore/             # Modelos compartilhados, protocolos, utilitários
    │   ├── Models/                # Course, Module, Lesson, Quiz, User, Badge
    │   ├── Protocols/             # CourseRepository, QuizRepository, etc.
    │   └── Extensions/            # Date, String, etc.
    │
    ├── SkillBitsDesignSystem/     # Design tokens, componentes visuais reutilizáveis
    │   ├── Tokens/                # Cores, tipografia, espaçamentos, gradientes
    │   ├── Components/            # SkillButton, SkillCard, ProgressBar, BadgeView
    │   └── Animations/            # Feedback de acerto/erro, streak fire, etc.
    │
    ├── SkillBitsAuth/             # Feature: Login e Onboarding
    │   ├── Models/
    │   ├── ViewModels/            # LoginViewModel, OnboardingViewModel
    │   └── Views/                 # LoginView, OnboardingView
    │
    ├── SkillBitsCourses/          # Feature: Catálogo de cursos
    │   ├── Models/
    │   ├── ViewModels/            # CoursesViewModel, CourseDetailViewModel
    │   └── Views/                 # CoursesView, CourseDetailView, ModuleDetailView
    │
    ├── SkillBitsLesson/           # Feature: Leitor de aula + Áudio
    │   ├── Models/                # LessonBlock (heading, paragraph, code, callout)
    │   ├── ViewModels/            # LessonViewModel, AudioPlayerViewModel
    │   └── Views/                 # LessonReaderView, AudioPlayerView
    │
    ├── SkillBitsQuiz/             # Feature: Quiz-first (hero feature)
    │   ├── Models/                # QuizQuestion, QuizResult, QuizMode
    │   ├── ViewModels/            # QuizViewModel
    │   └── Views/                 # QuizIntroView, QuizQuestionView,
    │                              #   QuizResultView, InstantFeedbackView
    │
    ├── SkillBitsGamification/     # Feature: XP, Streak, Níveis, Badges
    │   ├── Models/                # UserProgress, Badge, Level, Streak
    │   ├── ViewModels/            # GamificationViewModel
    │   ├── Services/              # XPService, StreakService, BadgeService
    │   └── Views/                 # LevelBadgeView, StreakView, XPBarView
    │
    ├── SkillBitsProgress/         # Feature: Tela de progresso do usuário
    │   ├── ViewModels/            # ProgressViewModel
    │   └── Views/                 # ProgressView
    │
    ├── SkillBitsPaywall/          # Feature: Freemium / Paywall
    │   ├── Services/              # StoreKitService (In-App Purchase)
    │   ├── ViewModels/            # PaywallViewModel
    │   └── Views/                 # PaywallView, PurchaseSuccessView
    │
    └── SkillBitsProfile/          # Feature: Perfil do usuário
        ├── ViewModels/            # ProfileViewModel
        └── Views/                 # ProfileView
```

### Padrão MVVM por Feature

```
View (SwiftUI)
  └── observa → ViewModel (@Observable)
                  └── chama → Repository (Protocol)
                               └── implementado por → DataSource (local/remote)
```

**Exemplo — SkillBitsQuiz:**
```swift
// Model
struct QuizQuestion: Identifiable, Codable {
    let id: String
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

// ViewModel
@Observable
class QuizViewModel {
    var currentQuestion: QuizQuestion?
    var showInstantFeedback: Bool = false
    var selectedAnswer: Int? = nil
    var isCorrect: Bool = false
    var xpEarned: Int = 0

    func selectAnswer(_ index: Int) { ... }
    func nextQuestion() { ... }
}

// View
struct QuizQuestionView: View {
    @State var viewModel: QuizViewModel
    // ...
}
```

### Persistência
- **MVP:** `UserDefaults` para progresso, XP, streak e badges (simples, sem backend)
- **Pós-MVP:** Migrar para CloudKit (sync entre dispositivos) + backend próprio

### Áudio (TTS no MVP)
- `AVSpeechSynthesizer` — nativo iOS, sem dependências externas
- Voz: `pt-BR` com velocidade configurável

### In-App Purchase (Freemium)
- `StoreKit 2` — API moderna, async/await nativo
- Gerenciado no pacote `SkillBitsPaywall`

### Dependências externas (mínimas no MVP)
- Nenhuma obrigatória — aproveitar o máximo do SDK nativo iOS

---

## 14. Referência Visual — App React

O app React existente (`age-study-ios`) serve como **protótipo visual e funcional** de referência para a implementação iOS. Todas as telas, fluxos e interações já estão desenhados e podem ser consultados como especificação.

**Repositório de referência:** `/Users/glance/Documents/Projects/Personal/age-study-ios`

---

*Documento gerado em sessão de brainstorming — 2026-02-27*
