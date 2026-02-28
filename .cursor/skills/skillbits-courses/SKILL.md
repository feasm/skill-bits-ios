---
name: skillbits-courses
description: Use when changing course catalog, course details, module access, search/filter behavior, or course progress logic in SkillBits iOS.
---

# SkillBits Courses

## Overview

Guia para alteracoes na jornada `Cursos -> Curso -> Modulo -> Licao/Quiz`.

## Arquivos principais

- `ios/Packages/SkillBitsCourses/Sources/SkillBitsCourses/CoursesViews.swift`
- `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Models.swift`
- `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Repositories.swift`
- `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/SupabaseCoursesRepository.swift`
- `ios/SkillBitsApp/Sources/MainTabView.swift`

## Regras chave

- Curso pode ser `free`, `partial` ou `premium` (derivado dos modulos).
- Acesso premium e verificado antes de abrir modulo/licao/quiz premium.
- Progresso de curso e calculado por licoes concluidas.

## Fluxo de navegacao

1. `CoursesView` lista cursos e filtros.
2. `CourseDetailView` mostra modulos e progresso.
3. `ModuleDetailView` lista licoes e entrada para quiz.

## Cuidados

- Nao quebrar ids estaveis (`courseId`, `moduleId`, `lessonId`).
- Nao calcular regra de premium em mais de um lugar.
- Ao mexer no filtro, preservar comportamento de busca por texto.

## Gaps atuais

- Parte do conteudo de licoes ainda nao existe no banco.
- Alguns controles de filtro avancado ainda sao placeholders.
