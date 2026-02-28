# SkillBits iOS - Regras de Negocio

## Objetivo

Este documento consolida as regras de negocio do app SkillBits com base no estado atual do codigo (app iOS + Supabase).

## Acesso e desbloqueio de conteudo

- **Tier de acesso por modulo:** `free` ou `premium`.
- **Acesso efetivo por curso:**
  - `.free` quando todos os modulos sao free.
  - `.partial` quando existe mistura de free e premium.
  - `.premium` quando todos os modulos sao premium.
- **Onboarding concluido:** a RPC `initialize_user_progress` cria `user_progress` e libera a primeira licao de cada modulo free.
- **Conteudo premium inicial:** licoes de modulos premium iniciam como `locked`.
- **Desbloqueio sequencial de licoes:** ao concluir uma licao, a proxima licao do mesmo modulo e desbloqueada (`complete_lesson`).
- **Desbloqueio de proximo modulo:** aprovado no quiz (score >= 70) libera a primeira licao do proximo modulo (`submit_quiz`).
- **Regra de gate premium:** ao tentar abrir modulo/licao/quiz premium, `PremiumGateState.require()` apresenta gate e paywall.

## Progresso de estudo

- **Conclusao de licao:** acao manual do usuario no botao "Marcar concluida".
- **Persistencia de conclusao:** backend grava `status = completed`, `progress = 100`, `completed_at = now()`.
- **Progresso de curso:** `(licoes_concluidas / total_licoes) * 100`.
- **Progresso de modulo:** calculado na UI por `doneLessons / totalLessons`.
- **Meta diaria:** atualmente 15 ou 30 minutos (do onboarding).
- **Minutos estudados por licao concluida:**
  - Supabase: +10 min.
  - Mock backend: +12 min.
- **Reset diario de minutos:** ao virar o dia, `studied_minutes_today` reinicia.

## Quiz, aprovacao e revisao

- **Formula de score:** `score = (correctCount * 100) / total`.
- **Criterio de aprovacao:** `score >= 70`.
- **Quiz-first:** usuario pode ir direto ao quiz sem ler antes.
- **Feedback imediato:** ao errar, o fluxo mostra resposta correta e explicacao.
- **Repeticao de quiz:** usuario pode refazer quiz.
- **Revisao guiada:** retorna apenas questoes incorretas da ultima tentativa (`get_guided_review`).

## XP, niveis e streak

### Regras de XP (estado atual implementado)

| Acao | XP |
|---|---|
| Licao concluida | +20 |
| Quiz enviado | +30 |
| Quiz com 100% | +50 bonus |
| Quiz-first com 100% | +75 bonus |

- **Maximo por quiz perfeito quiz-first:** 155 XP.

### Niveis

| Nivel | Faixa de XP | Nome |
|---|---|---|
| 1 | < 300 | Bit |
| 2 | >= 300 e < 1000 | Byte |
| 3 | >= 1000 e < 3000 | KiloByte |
| 4 | >= 3000 e < 7000 | MegaByte |
| 5 | >= 7000 | GigaByte |

### Streak

- **Nao estudou ontem:** streak vira 1.
- **Estudou ontem:** streak incrementa +1.
- **Ja estudou hoje:** streak nao muda.
- **Fonte de verdade do streak:** backend (`complete_lesson`), nao o app local.

## Badges

Badges atualmente calculados no backend (`update_badges`):

| ID | Nome | Regra |
|---|---|---|
| b1 | Primeiro Passo | >= 1 licao concluida |
| b2 | Quiz Master | >= 300 XP |
| b3 | Estudante Dedicado | streak >= 7 dias |

Observacoes:
- O design original previa mais badges.
- No app, `BadgeService` cobre parcialmente regras locais; a regra principal esta nas RPCs.

## Onboarding e personalizacao inicial

- **Pergunta de motivo:** universidade, carreira, curiosidade, evolucao.
- **Pergunta de tempo diario:** 15 ou 30 minutos.
- **Recomendacao inicial de curso (UI):**
  - universidade/curiosidade -> curso `c2`.
  - carreira -> curso `c1`.
  - evolucao -> curso `c3`.
- **Finalizacao de onboarding:** chama `initialize_user_progress`.

## Autenticacao e sessao

- **Login e cadastro:** email/senha via Supabase Auth.
- **Persistencia de sessao:** monitorada por `authStateChanges`.
- **Restauracao de onboarding:** ao logar, app tenta buscar `user_progress` para decidir se onboarding ja foi concluido.
- **Sign in with Apple:** botao presente, sem acao implementada.
- **Esqueci minha senha:** botao presente, sem acao implementada.

## Carregamento e refresh de dados (tabs)

- **Skeleton na primeira carga:** exibido apenas quando a tela ainda nao tem dados carregados.
- **Troca de tab:** nao deve forcar refetch imediato por padrao.
- **Refresh automatico por TTL:** cada ViewModel de tab usa janela de cache para evitar fetch excessivo.
- **Refresh forcado:** ocorre quando o usuario puxa para atualizar (`pull-to-refresh`) ou conclui acao de estudo relevante (ex: concluir licao/quiz com progresso).
- **Erro durante refresh com cache existente:** UI mantem dados anteriores e mostra erro inline, sem bloquear a tela inteira.

## Navegacao do fluxo de curso

- **Apresentacao:** fluxo de curso (detalhe, modulo, aula) e apresentado como `fullScreenCover` com `NavigationStack` propria, isolada da tab bar.
- **Botao X (fechar):** presente em todas as telas do fluxo; fecha o modal inteiro e retorna a tela de origem.
- **Back:** navega entre niveis dentro do fluxo (Aula → Modulo → Detalhe do curso).
- **Raiz do modal (CourseDetailView):** mostra apenas botao X (nao ha back, pois e a raiz).
- **Telas internas (ModuleDetailView, LessonReaderView):** mostram back + X.
- **Quiz e paywall:** apresentados como sheets/covers contextuais dentro do fluxo modal.
- **Abertura de curso:** funciona de qualquer tab sem necessidade de troca de tab previa.

## Monetizacao e premium

- **Modelo:** freemium com bloqueio de conteudo premium por modulo/licao/quiz.
- **Contrato de repositorio:** `isPremiumActive`, `purchaseMonthly`, `purchaseAnnual`.
- **Estado atual de compra:** mock (`MockPaywallRepository`) em ambos modos de ambiente.
- **StoreKit 2:** ainda nao integrado.

## Regras declaradas no plano original que ainda nao estao completas no codigo

- XP diario por manter streak (+10/dia) nao esta consolidado de ponta a ponta.
- XP por completar modulo/curso (+100/+500) aparece no plano, mas nao esta claro como regra ativa no backend atual.
- Beneficio premium "revisoes guiadas ilimitadas" aparece na comunicacao, sem regra distinta no backend.

## Status por dominio

| Dominio | Status |
|---|---|
| Acesso free/premium e gate | Implementado |
| Desbloqueio por quiz e sequencial | Implementado |
| XP base e niveis | Implementado (com pequenas inconsistencias de exibicao) |
| Streak backend | Implementado |
| Badges iniciais (3) | Implementado |
| Revisao guiada | Implementado |
| Onboarding (2 perguntas) | Implementado |
| Sign in with Apple / reset senha | Stub |
| Monetizacao real (StoreKit) | Stub |
