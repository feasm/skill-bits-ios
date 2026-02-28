---
name: skillbits-home
description: Use when updating the home dashboard, my-study list behavior, greeting/progress cards, or home-level engagement components in SkillBits iOS.
---

# SkillBits Home e My Study

## Overview

Guia para alterar o dashboard de estudo e a tab Study Hub (Meus estudos).

## Arquivos principais

- `ios/Packages/SkillBitsHome/Sources/SkillBitsHome/HomeAndStudyViews.swift`
- `ios/SkillBitsApp/Sources/MainTabView.swift`
- `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Models.swift`

## Responsabilidades da feature

- Home com resumo rapido:
  - saudacao
  - streak
  - meta diaria
  - continuar estudando
  - recomendacoes
- Study Hub (Meus estudos) com:
  - estados de loading, erro e vazio orientados
  - card principal "Continuar agora" com proxima licao
  - secao "Em andamento" (cursos com progresso)
  - secao "Proximas recomendacoes" (cursos nao iniciados)
  - secao "Consistencia" (minutos hoje, streak, quizzes concluidos)
  - empty state com CTA para explorar catalogo

## Arquitetura da tab Study Hub

- `MyStudyHost` (em MainTabView): gerencia estado (courses, progress, isLoading, loadError) e passa dados para `MyStudyView`.
- `MyStudyView`: recebe dados e callbacks; sem logica de fetch propria.
- Computados internos: `inProgressCourses`, `recommendedCourses`, `continueCourse`, `nextLesson(for:)`.
- Callbacks: `openCourse`, `onExploreCourses`, `onRetry`.

## Cuidados

- Nao transformar home em duplicacao de `ProgressScreen`.
- Priorizar leitura rapida (cards simples e CTA claro).
- Garantir que links de "continuar" levem ao proximo passo natural.
- Manter consistencia entre Home e Study Hub sem duplicar logica.

## Gaps atuais

- Quizzes concluidos na secao Consistencia mostram total geral; ainda nao ha dado semanal vindo do backend.
- Parte da experiencia de recomendacao pode evoluir com dados reais de perfil.
