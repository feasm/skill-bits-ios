---
name: skillbits-paywall
description: Use when changing premium gating, paywall screens, purchase flow integration, or premium access state handling in SkillBits iOS.
---

# SkillBits Paywall

## Overview

Guia para alteracoes do gate premium, telas de paywall e estado de assinatura.

## Arquivos principais

- `ios/Packages/SkillBitsPaywall/Sources/SkillBitsPaywall/PremiumGate.swift`
- `ios/Packages/SkillBitsPaywall/Sources/SkillBitsPaywall/PaywallViews.swift`
- `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Repositories.swift`
- `ios/SkillBitsApp/Sources/AppEnvironment.swift`
- `ios/SkillBitsApp/Sources/MainTabView.swift`

## Regras de acesso

- Acesso premium deve bloquear modulo/licao/quiz premium.
- `PremiumGateState.require()` decide se executa acao ou abre gate.
- Compra bem-sucedida deve liberar acao pendente.

## Cuidados

- Nao acoplar regra de negocio ao texto de marketing.
- Preservar caminho de fallback quando compra falhar/cancelar.
- Ao integrar StoreKit 2, manter interface `PaywallRepository` estavel.

## Gaps atuais

- Fluxo de compra real ainda nao integrado.
- `MockPaywallRepository` ainda e usado no ambiente principal.
