---
name: skillbits-ios
description: Use when scaling architecture, creating new feature packages, evolving navigation/data layers, enforcing iOS best practices, or keeping SkillBits documentation updated after changes.
---

# SkillBits iOS

## Overview

Guia mestre para evoluir o SkillBits iOS com consistencia arquitetural, boas praticas de iOS e documentacao viva.

Este skill deve trabalhar junto com:
- `/mobile-ios-design` para decisoes de UX/UI e HIG.
- `/ios-development` para padroes Swift/SwiftUI, arquitetura e qualidade de codigo.

## Arquitetura atual (mapa vivo)

### Camadas

1. **Foundation**
   - `ios/Packages/SkillBitsCore`
   - `ios/Packages/SkillBitsDesignSystem`
2. **Infrastructure**
   - `ios/Packages/SkillBitsNetworking` (mock)
   - `ios/Packages/SkillBitsSupabase` (backend real)
3. **Feature**
   - `SkillBitsAuth`, `SkillBitsCourses`, `SkillBitsLesson`, `SkillBitsQuiz`, `SkillBitsPaywall`
4. **Feature + Gamification**
   - `SkillBitsHome`, `SkillBitsProgress`, `SkillBitsProfile` (dependem tambem de `SkillBitsGamification`)

### Regras de dependencia

- Features nao devem depender entre si diretamente.
- Contratos de dados e modelos ficam em `SkillBitsCore`.
- Componentes visuais e tokens ficam em `SkillBitsDesignSystem`.
- Regras de acesso a backend ficam em repositories (protocolos no Core, implementacoes em Supabase/Networking).

## Como escalar sem quebrar arquitetura

### Novo package de feature

1. Criar package iOS 17+ em `ios/Packages/<FeatureName>`.
2. Adicionar dependencia minima de `SkillBitsCore` e `SkillBitsDesignSystem`.
3. Registrar package em `ios/project.yml`.
4. Adicionar package ao target `SkillBitsApp` em `ios/project.yml`.
5. Expor views/viewmodels publicos com inits claros por dependencia.

### Novo model de dominio

- Criar em `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Models.swift`.
- Preferir conformances: `Identifiable`, `Codable`, `Hashable`, `Sendable`.
- Evitar logica de UI no model.

### Novo repository

1. Declarar protocolo em `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Repositories.swift`.
2. Implementar backend real em `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/`.
3. Implementar mock em `ios/Packages/SkillBitsNetworking/Sources/SkillBitsNetworking/`.
4. Registrar injecao em `ios/SkillBitsApp/Sources/AppEnvironment.swift`.

### Nova tela ou fluxo

- Preferir `@Observable` para ViewModel e injecao de repositorio via init.
- Em view, receber dados e closures de acao explicitamente.
- Respeitar padrao de navegacao central em `ios/SkillBitsApp/Sources/MainTabView.swift`.
- Usar `navigationDestination` para push e `sheet/fullScreenCover` para modal.
- Se envolver conteudo premium, validar fluxo com `PremiumGateState`.

## Design system (uso obrigatorio)

Antes de criar componente custom local, verificar:
- `SBPrimaryButton`, `SBSecondaryButton`, `SBOutlineButton`, `SBGhostButton`, `SBDangerButton`
- `SBCard`, `SBGlassCard`, `SBGradientBanner`
- `SBBadge`, `SBProgressBar`, `SBScoreCircle`, `SBStatCard`
- `SBLoadingState`, `SBErrorState`, `SBSkeletonCard`

### Tokens padrao

- Tipografia: `SBFont.*`
- Cores: `SBColor.*` (evitar hardcode)
- Movimento: `SBMotion.*`
- Haptics: `SBHaptics.*`
- Sombras: `.sbShadow(...)`
- Espacamento e raio: `SBSpacing.*`, `SBRadius.*`

## Checklist de qualidade (pre-merge)

1. Lints limpos nos arquivos alterados.
2. Sem hardcode visual desnecessario (cor/fonte/spacing).
3. Dark mode e contraste revisados.
4. Acessibilidade minima aplicada (`accessibilityLabel`, `accessibilityHint` quando relevante).
5. Animacoes usam `SBMotion` e interacoes usam `SBHaptics` quando fizer sentido.
6. Fluxos de navegacao e premium gate validados.

## Documentacao viva (obrigatorio apos mudancas relevantes)

Sempre atualizar docs quando mudar arquitetura, regras, fluxos ou features.

### Atualizar indice e visao geral
- `docs/skillbits-master-documentation.md`

### Atualizar estado das features
- `docs/skillbits-feature-matrix.md`

### Atualizar regras de negocio
- `docs/skillbits-business-rules.md`

### Atualizar skill correspondente
- `.cursor/skills/skillbits-*/SKILL.md` da feature alterada
- `.cursor/skills/skillbits-ios/SKILL.md` se o padrao arquitetural mudar

### Decisoes importantes

Para decisoes arquiteturais ou de produto com impacto duradouro, registrar em:
- `docs/decisions/YYYY-MM-DD-<tema>.md`
- usando `docs/decisions/_template.md`

## Snapshot atual do projeto

- Monorepo iOS com XcodeGen (`ios/project.yml`)
- iOS 17+
- Backend principal em Supabase
- Paywall com partes ainda mockadas
- Navegacao centralizada no app shell (`SkillBitsApp` + `MainTabView`)
- Arquitetura modular pronta para escalar por package

## Anti-patterns a evitar

- Duplicar regra de negocio em view.
- Criar acoplamento entre features (ex: Quiz importando Courses diretamente).
- Introduzir token visual fora do DesignSystem sem necessidade real.
- Alterar fluxo de navegacao sem validar os modais encadeados de quiz/paywall.
- Implementar feature sem atualizar documentacao.
