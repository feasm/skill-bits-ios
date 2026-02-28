# SkillBits iOS - Master Documentation

## Visao geral

Este indice consolida a documentacao funcional e de produto do SkillBits para facilitar consulta rapida.

## Documentos principais

- `docs/skillbits-business-rules.md`
  - Regras de negocio implementadas (acesso, progresso, quiz, XP, streak, badges, onboarding, auth e monetizacao).
  - Status por dominio (implementado/parcial/stub).

- `docs/skillbits-courses-catalog.md`
  - Catalogo dos cursos atuais (c1, c2, c3) com modulos e cobertura real de conteudo.
  - 20 sugestoes de novos cursos de micro-learning (15-30 min, iniciante).

- `docs/skillbits-feature-matrix.md`
  - Inventario atual de funcionalidades por status.
  - Avaliacao critica do diferencial do app.
  - Lista de 20 funcionalidades novas com valor, complexidade e recomendacao de MVP.

- `docs/skillbits-skills-governance-review.md`
  - Revisao critica dos skills existentes.
  - Recomendacoes de endurecimento de governanca.

- `docs/decisions/_template.md`
  - Template para registrar decisoes de produto.
  - Base para historico em `docs/decisions/YYYY-MM-DD-<tema>.md`.

- `docs/course-spec-01-como-funciona-a-internet.md`
  - Spec detalhada do primeiro novo curso do roadmap.
  - Estruturada para seed em `courses/modules/lessons/quiz_questions`.

- `docs/feature-spec-my-study-tab-v2.md`
  - Spec da evolucao da tab Meus estudos para Study Hub.
  - Pronta para implementacao por dev com criterios de aceite.

## Decisoes recentes de UX/performance

- **Migracao iOS 16.4 - 2026-02-28**
  - Deployment target rebaixado de iOS 17 para iOS 16.4 para ampliar base de usuarios.
  - ViewModels migrados de @Observable para ObservableObject + @Published.
  - Polyfills criados em DesignSystem/Compatibility.swift: sbOnChange, sbNavigationDestination, SBUnevenRoundedRectangle.
  - Codigo iOS 17 preservado via `if #available` nos polyfills.
  - Decisao detalhada em `docs/decisions/2026-02-28-ios-16-4-migration.md`.

- **Study Hub (Meus estudos) - 2026-02-28**
  - Tab evoluida de lista simples para Study Hub orientado a acao.
  - Estados claros: loading, erro, vazio (com CTA), com progresso (secoes).
  - Decisao detalhada em `docs/decisions/2026-02-28-study-hub-tab-v2.md`.

- **Loading e refresh nas tabs**
  - Skeleton aparece apenas na primeira carga real da tela.
  - Troca de tab nao dispara refetch sempre.
  - Refetch automatico segue janela de tempo (TTL) nos ViewModels.
  - Refetch forcado acontece em acoes explicitas (ex: concluir aula/quiz) e pull-to-refresh.

- **Navegacao do fluxo de curso - 2026-02-28**
  - Fluxo de curso (detalhe → modulo → aula) apresentado como fullScreenCover com NavigationStack propria.
  - Botao X sempre visivel para fechar o fluxo inteiro e voltar a tela de origem.
  - Back button navega entre niveis dentro do fluxo.
  - Quiz, paywall e sheets de lesson permanecem contextuais ao fluxo.
  - Abertura de curso funciona de qualquer tab (nao requer troca de tab).

## Skills funcionais do projeto

- ` .cursor/skills/skillbits-auth/SKILL.md`
- ` .cursor/skills/skillbits-courses/SKILL.md`
- ` .cursor/skills/skillbits-lessons/SKILL.md`
- ` .cursor/skills/skillbits-quiz/SKILL.md`
- ` .cursor/skills/skillbits-gamification/SKILL.md`
- ` .cursor/skills/skillbits-progress/SKILL.md`
- ` .cursor/skills/skillbits-profile/SKILL.md`
- ` .cursor/skills/skillbits-paywall/SKILL.md`
- ` .cursor/skills/skillbits-design-system/SKILL.md`
- ` .cursor/skills/skillbits-home/SKILL.md`
- ` .cursor/skills/skillbits-supabase/SKILL.md`
- ` .cursor/skills/skillbits-navigation/SKILL.md`
- ` .cursor/skills/skillbits-ios/SKILL.md`
  - Skill mestre de arquitetura e escalabilidade iOS.
  - Define workflow de documentacao viva apos mudancas no projeto.
- ` .cursor/skills/skillbits-pm/SKILL.md`
  - Skill de Product Manager para analise, priorizacao e documentacao apos validacao.

## Respostas objetivas de produto

- O app **tem diferencial real**: quiz-first para T.I iniciante em portugues.
- A lista de funcionalidades sugeridas **ja esta categorizada e ranqueada** em `docs/skillbits-feature-matrix.md`.
- A lista de novos cursos de micro-learning **ja esta estruturada** em `docs/skillbits-courses-catalog.md`.

## Ordem recomendada de leitura

1. `docs/skillbits-feature-matrix.md` (visao executiva de MVP)
2. `docs/skillbits-business-rules.md` (regras e lacunas reais)
3. `docs/skillbits-courses-catalog.md` (oferta de conteudo atual e expansao)
4. `docs/course-spec-01-como-funciona-a-internet.md` (curso pronto para implementacao de conteudo)
5. `docs/feature-spec-my-study-tab-v2.md` (planejamento da experiencia Meus estudos)

