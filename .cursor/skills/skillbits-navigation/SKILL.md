---
name: skillbits-navigation
description: Use when updating root app phases, tab routing, navigation stacks, sheets, or full-screen flows in SkillBits iOS.
---

# SkillBits Navigation

## Overview

Guia para alteracoes na navegacao global (fases, tabs, stacks, sheets e covers).

## Arquivos principais

- `ios/SkillBitsApp/Sources/SkillBitsApp.swift`
- `ios/SkillBitsApp/Sources/MainTabView.swift`
- `ios/SkillBitsApp/Sources/RouterModels.swift`

## Estrutura atual

- Fases de app:
  - `login`
  - `onboarding`
  - `main`
- `main` usa `TabView` com 4 abas:
  - Cursos
  - Meus estudos
  - Progresso
  - Perfil
- Fluxos modais:
  - sheets (intro quiz, resultado, gate, etc.)
  - fullScreenCover (perguntas do quiz)

## Cuidados

- Nao perder contexto de curso/modulo/licao ao abrir modais.
- Validar ordem de apresentacao/dismiss entre sheets encadeados.
- Em alteracao de rotas, manter cobertura de cenarios premium gate.

## Checklist rapido

1. Validar transicao entre fases de sessao.
2. Validar navegacao profunda do curso ate quiz/resultado.
3. Validar retorno correto apos concluir licao/quiz.
4. Validar fluxos premium (gate -> paywall -> sucesso).
