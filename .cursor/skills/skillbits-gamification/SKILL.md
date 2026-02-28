---
name: skillbits-gamification
description: Use when changing XP rules, level boundaries, streak logic, badge unlock rules, or reward feedback in SkillBits iOS.
---

# SkillBits Gamification

## Overview

Guia para evoluir XP, niveis, streak e badges mantendo coerencia entre app e backend.

## Arquivos principais

- `ios/Packages/SkillBitsGamification/Sources/SkillBitsGamification/Gamification.swift`
- `ios/Packages/SkillBitsGamification/Tests/SkillBitsGamificationTests/GamificationTests.swift`
- `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Models.swift`
- `supabase/migrations/20260227230003_functions.sql`
- `ios/Packages/SkillBitsProgress/Sources/SkillBitsProgress/ProgressView.swift`
- `ios/Packages/SkillBitsProfile/Sources/SkillBitsProfile/ProfileView.swift`

## Regras atuais

- Licao concluida: +20 XP.
- Quiz enviado: +30 XP.
- Quiz 100%: +50 bonus.
- Quiz-first 100%: +75 bonus.
- Streak calculado no backend.
- Badges atuais: b1, b2, b3.

## Cuidados

- Sempre alinhar regra no backend e no app.
- Evitar inconsistencias de "XP para proximo nivel" em telas diferentes.
- Alteracao de nivel exige ajuste nos testes de fronteira.

## Checklist rapido para mudancas

1. Ajustar regra em fonte de verdade (RPC/servico).
2. Ajustar renderizacao das telas de progresso/perfil.
3. Atualizar testes unitarios de gamificacao.
4. Revisar impacto em badges e mensagens de recompensa.

## Gaps atuais

- Nem todas as regras planejadas de badges/XP estao implementadas.
