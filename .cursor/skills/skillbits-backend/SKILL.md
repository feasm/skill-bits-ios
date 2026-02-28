---
name: skillbits-backend
description: Use when planning or executing SkillBits backend work in Supabase (schema, migrations, RLS, RPC, seed, DTO and repository mapping, local/cloud deploy), with mandatory documentation feedback loop after each approved change.
---

# SkillBits Backend

## Overview

Este skill representa o papel de PM tecnico de backend do SkillBits.
Ele deve sempre:

1. Planejar a demanda com rigor antes de codar.
2. Escolher estrategia de execucao por complexidade.
3. Manter banco, app iOS e documentacao sincronizados.
4. Retroalimentar o estado do backend apos cada mudanca aprovada.

## Skills obrigatorias (sempre invocar)

- `/supabase-postgres-best-practices` para qualquer SQL, schema, index, query e RLS.
- `/skillbits-supabase` para regras de negocio e mapeamento banco -> app.

## Documentos obrigatorios (ler antes de propor mudancas)

- `docs/skillbits-business-rules.md`
- `docs/skillbits-feature-matrix.md`
- `.cursor/skills/skillbits-backend/references/backend-state.md`
- `docs/plans/2026-02-27-supabase-backend-design.md`
- `docs/plans/2026-02-27-supabase-implementation.md`

## Dominios cobertos

- Schema e migrations (`supabase/migrations/`)
- Seguranca (RLS e policies)
- RPCs de negocio (gamificacao, desbloqueio, onboarding)
- Seed (`supabase/seed.sql`)
- Mapeamento Supabase no iOS:
  - `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/DTOs.swift`
  - `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/Supabase*Repository.swift`
  - `ios/Packages/SkillBitsSupabase/Sources/SkillBitsSupabase/SupabaseManager.swift`

## Ciclo obrigatorio de decisao

1. Ler contexto tecnico e de negocio.
2. Classificar complexidade da demanda: baixa, media ou alta.
3. Escrever proposta com impacto em:
   - schema/migrations
   - RLS
   - RPCs
   - seed
   - DTOs/repositories/UI impactada
4. Pedir validacao explicita do usuario.
5. Executar somente apos aprovacao.
6. Verificar:
   - banco local/remote
   - build iOS
   - contratos app <-> backend
7. Retroalimentar documentacao obrigatoria.

## Regra de execucao por complexidade

### Planejamento

- Planejamento deve ser sempre feito com raciocinio de alta capacidade (Opus 4.6 no fluxo da equipe).

### Execucao baixa/media complexidade

- Preferir execucao com agente rapido (Codex 5.3 no fluxo da equipe).
- Em Cursor, quando usar subagente Task para execucao simples, preferir `model: "fast"`.
- Exemplos:
  - adicionar coluna simples
  - criar index
  - ajuste pontual de seed
  - ajuste pequeno de DTO/repository

### Execucao alta complexidade

- Executar no agente principal de maior capacidade (Opus no fluxo da equipe).
- Nao delegar para agente rapido quando houver risco de contrato.
- Exemplos:
  - nova RPC com regra de gamificacao
  - redesign de RLS
  - mudanca de contrato de funcao usada pelo app
  - refactor de query com join/subquery complexa

### Regra de classificacao

Tratar como **alta complexidade** se qualquer item abaixo for verdadeiro:

- altera regra de negocio central (XP, streak, unlock, badges, quiz pass/fail)
- altera assinatura de RPC ou formato de retorno
- impacta mais de um repositorio do app
- exige migracao de dados ou backfill
- envolve trade-off de seguranca/performance

## Checklist obrigatorio de migracao

Para cada demanda de backend, copiar e preencher:

- [ ] Criar migration SQL em `supabase/migrations/` com timestamp
- [ ] Revisar indexes e performance
- [ ] Revisar/ajustar RLS e policies
- [ ] Revisar/ajustar RPCs impactadas
- [ ] Atualizar `supabase/seed.sql` se necessario
- [ ] Atualizar `DTOs.swift` se contrato mudou
- [ ] Atualizar `Supabase*Repository.swift` se contrato mudou
- [ ] Atualizar mocks quando houver mudanca de contrato
- [ ] Validar localmente (`npx supabase db reset`)
- [ ] Validar build iOS (`xcodebuild`)
- [ ] Validar cloud (`npx supabase db push` e smoke tests)

## Formato de proposta para o usuario

Antes de executar, responder sempre neste formato:

1. Contexto: problema e urgencia.
2. Proposta tecnica: o que muda.
3. SQL/migracao: estrategia de alteracao.
4. Impacto: RLS, RPC, seed, app iOS.
5. Riscos: seguranca, regressao, performance.
6. Plano de validacao: testes locais/cloud.
7. Recomendacao final.

## Regras criticas de contrato backend-app

- Nunca mudar contrato de RPC sem atualizar chamadas no app.
- Nunca alterar colunas/nomes no banco sem validar `CodingKeys` nos DTOs.
- Nunca deixar tabela nova sem RLS.
- Nunca subir migration sem considerar seed e bootstrap de novos usuarios.
- Nunca finalizar sem atualizar documentacao de backend.

## Retroalimentacao obrigatoria (sempre apos concluir)

Atualizar:

1. `.cursor/skills/skillbits-backend/references/backend-state.md`
2. `docs/skillbits-business-rules.md` (se regra de negocio mudou)
3. `.cursor/skills/skillbits-supabase/SKILL.md` (se contrato backend mudou)

## Artefatos obrigatorios de backend-state.md

Garantir que o arquivo de estado mantenha:

- tabelas e colunas
- indexes
- RLS policies
- RPCs (assinatura e comportamento)
- contagem de seed e conteudo MVP
- mapeamento para DTOs e repositories
- comandos operacionais (local e cloud)
- gaps conhecidos e proxima fronteira tecnica

## Escopo atual conhecido

- Core implementado: courses/modules/lessons/progress/quiz
- Gamificacao core em RPC: onboarding, complete lesson, submit quiz, guided review, badges
- Gaps: compra premium real (StoreKit + backend billing), fluxos de auth social e reset de senha

