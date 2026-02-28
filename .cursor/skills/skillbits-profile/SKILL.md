---
name: skillbits-profile
description: Use when modifying profile data display, personal settings, study goal settings, notification settings, or profile navigation in SkillBits iOS.
---

# SkillBits Profile

## Overview

Guia para alteracoes na aba Perfil e suas sub-telas de configuracao.

## Arquivos principais

- `ios/Packages/SkillBitsProfile/Sources/SkillBitsProfile/ProfileView.swift`
- `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Models.swift`
- `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Repositories.swift`

## Escopo atual da feature

- Exibicao de avatar, nome, email, XP e estatisticas rapidas.
- Navegacao para:
  - Dados pessoais
  - Assinatura
  - Notificacoes
  - Meta de estudo
  - Central de ajuda
  - Privacidade e termos
- Acao de logout.

## Cuidados

- Manter separacao entre "estado visual" e "estado persistido".
- Nao exibir status de assinatura como real se backend ainda for mock.
- Revisar coerencia com Progress/Gamification ao mexer em XP/level/streak exibidos.

## Gaps atuais

- Salvar dados pessoais ainda incompleto.
- Parte das preferencias de notificacao/meta sem persistencia final.
- Tela de assinatura ainda depende de mock.
