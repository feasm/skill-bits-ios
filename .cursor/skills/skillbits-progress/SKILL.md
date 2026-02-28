---
name: skillbits-progress
description: Use when modifying the Progress tab, progress metrics, weekly chart data source, or progress-related UI states in SkillBits iOS.
---

# SkillBits Progress

## Overview

Guia para evolucao da aba de progresso mantendo consistencia de metricas.

## Arquivos principais

- `ios/Packages/SkillBitsProgress/Sources/SkillBitsProgress/ProgressView.swift`
- `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Models.swift`
- `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Repositories.swift`
- `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/SupabaseProgressRepository.swift`

## Dados exibidos

- XP total.
- Streak atual.
- Minutos estudados no dia.
- Progresso por curso.
- Badges desbloqueadas.
- Serie semanal (integrada com backend via `study_daily_log` + RPC `get_weekly_study`).

## Fluxo de dados semanais

- Tabela `study_daily_log` (user_id, study_date, minutes) registra minutos por dia.
- `complete_lesson` faz upsert automatico na tabela ao completar licao (+10 min).
- RPC `get_weekly_study` retorna ultimos 7 dias com `generate_series` + LEFT JOIN.
- Modelo iOS: `WeeklyStudyDay` (studyDate, minutes) em `SkillBitsCore/Models.swift`.
- Protocolo: `fetchWeeklyStudy()` em `ProgressRepository`.
- ViewModel busca dados no `load()` e expoe `weeklyStudy: [WeeklyStudyDay]`.
- View converte datas para labels de dia da semana (Seg, Ter, ...) via `Calendar.weekday`.

## Cuidados

- Nao introduzir metricas sem fonte de verdade.
- Manter fallback de erro/carregamento em todas as metricas.
- Garantir que nomes e valores exibidos batam com gamificacao e profile.
- Ao adicionar novas fontes de minutos de estudo (ex: quiz), atualizar tambem `study_daily_log`.

## Gaps atuais

- Alguns textos sugerem regras de XP que ainda nao estao totalmente ativas.
- Quiz completion nao registra minutos de estudo no daily log (somente lesson completion).
