---
name: skillbits-lessons
description: Use when updating lesson reader UI, lesson content rendering blocks, completion flow, or text-to-speech behavior in SkillBits iOS.
---

# SkillBits Lessons

## Overview

Guia para evoluir o leitor de licoes sem quebrar progresso, audio e renderizacao de blocos.

## Arquivos principais

- `ios/Packages/SkillBitsLesson/Sources/SkillBitsLesson/LessonView.swift`
- `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Models.swift`
- `ios/Packages/SkillBitsCore/Sources/SkillBitsCore/Repositories.swift`
- `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/SupabaseLessonRepository.swift`

## Estrutura de conteudo

- Licao usa `LessonContent` com `LessonBlock`.
- Tipos atuais: heading, heading2, paragraph, list, code, callout.
- Conteudo vem de `lessons.content` (JSONB).

## Regras

- Conclusao de licao e manual por botao.
- Marcar licao concluida deve refletir em progresso e desbloqueio seguinte.
- Audio (TTS) e suporte de acessibilidade/consumo rapido.

## Cuidados

- Preservar compatibilidade de parsing dos blocos existentes.
- Evitar acoplamento de UI com regra de desbloqueio.
- Alteracoes de TTS devem manter comportamento de pausa/retomada.

## Gaps atuais

- Grande parte das licoes ainda sem conteudo completo no banco.
