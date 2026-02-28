---
name: skillbits-auth
description: Use when working on login, signup, onboarding completion, session restoration, or auth navigation phases in the SkillBits iOS app.
---

# SkillBits Auth e Onboarding

## Overview

Guia para alterar autenticacao e onboarding sem quebrar o fluxo de fases (`login -> onboarding -> main`).

## Arquivos principais

- `ios/SkillBitsApp/Sources/SkillBitsApp.swift`
- `ios/SkillBitsApp/Sources/AppSession.swift`
- `ios/SkillBitsApp/Sources/AppEnvironment.swift`
- `ios/Packages/SkillBitsAuth/Sources/SkillBitsAuth/AuthViews.swift`
- `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/SupabaseAuthRepository.swift`
- `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Repositories.swift`

## Regras de negocio

- Login e cadastro usam Supabase Auth (email/senha).
- Onboarding e considerado concluido quando existe `user_progress` para o usuario.
- Onboarding chama `initialize_user_progress` para inicializar progresso.
- `AppSession` observa mudancas de autenticacao e restaura estado.

## Fluxo esperado

1. Usuario nao logado: mostrar `LoginView`.
2. Usuario logado sem onboarding: mostrar `OnboardingView`.
3. Usuario logado com onboarding: mostrar `MainTabView`.

## Cuidados ao alterar

- Nao mover regra de fases para dentro das views de feature.
- Nao duplicar estado de sessao em mais de um lugar.
- Nao introduzir dependencia direta de UI dentro do repositorio.

## Gaps atuais

- Sign in with Apple ainda e stub.
- Recuperacao de senha ainda e stub.
