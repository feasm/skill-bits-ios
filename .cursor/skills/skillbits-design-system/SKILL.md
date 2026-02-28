---
name: skillbits-design-system
description: Use when adjusting design tokens, shared UI components, typography, spacing, color system, or reusable visual patterns in SkillBits iOS.
---

# SkillBits Design System

## Overview

Guia para manter consistencia visual e de componentes reutilizaveis do app.

## Arquivos principais

- `ios/Packages/SkillBitsDesignSystem/Sources/SkillBitsDesignSystem/DesignTokens.swift`
- `ios/Packages/SkillBitsDesignSystem/Sources/SkillBitsDesignSystem/Components.swift`

## Tokens disponiveis

- Cores (`SBColor`)
- Tipografia (`SBFont`)
- Espacamentos (`SBSpacing`)
- Raios (`SBRadius`)
- Animacoes (`SBMotion`)
- Sombras (`SBShadowStyle`)
- Haptics (`SBHaptics`)

## Componentes base

- Botoes (`SBPrimaryButton`, `SBSecondaryButton`, etc.)
- Cards (`SBCard`, `SBGlassCard`)
- Navegacao (`SBNavBar`)
- Badges/progresso (`SBBadge`, `SBProgressBar`, `SBScoreCircle`)
- Estados (`SBLoadingState`, `SBErrorState`)

## Cuidados

- Priorizar componentes do Design System em vez de criar variacao local.
- Evitar hardcode de cor/fonte fora do package.
- Garantir contraste e acessibilidade ao alterar tokens.

## Gaps atuais

- Falta padronizacao completa de acessibilidade em todas as telas.
