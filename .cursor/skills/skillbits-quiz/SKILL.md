---
name: skillbits-quiz
description: Use when modifying quiz-first flow, quiz scoring, guided review behavior, or quiz result UX in SkillBits iOS.
---

# SkillBits Quiz

## Overview

Guia para o fluxo de quiz (intro, questoes, resultado, revisao guiada) com foco no diferencial quiz-first.

## Arquivos principais

- `ios/Packages/SkillBitsQuiz/Sources/SkillBitsQuiz/QuizViews.swift`
- `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Models.swift`
- `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Repositories.swift`
- `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/SupabaseQuizRepository.swift`
- `supabase/migrations/20260227230003_functions.sql`

## Regras de negocio

- Aprovacao do quiz: score >= 70.
- Formula de score: `(correctCount * 100) / total`.
- Quiz-first deve continuar opcional (nao obrigatorio).
- Revisao guiada traz erros da ultima tentativa.

## Fluxo esperado

1. `QuizIntroView`: estudar primeiro ou ir direto para quiz.
2. `QuizQuestionView`: responder com feedback.
3. `QuizResultView`: aprovado/reprovado + CTA.
4. `GuidedReviewView`: reforco dos topicos errados.

## Cuidados

- Nao quebrar consistencia entre score local e backend.
- Nao remover explicacao pedagogica de erro/acerto.
- Em alteracoes de navegacao, validar apresentacao em sheet e fullScreenCover.

## Gaps atuais

- Navegacao de revisao para trecho de licao ainda limitada.
