# Product Decision Record

## Metadados

- **Data:** 2026-02-28
- **Responsavel:** PM SkillBits
- **Status:** aprovado
- **Tema:** Evolucao da tab Meus estudos para Study Hub (B2)

## Contexto

A tab `Meus estudos` mostrava apenas uma lista simples de cursos com `progress > 0`, sem estados de loading/erro e sem orientacao para usuarios novos. O objetivo foi transformar a tab em um Study Hub que oriente o usuario ao proximo passo de estudo.

## Opcoes consideradas

1. **B1 - Apenas empty state**
   - Pros: rapido de implementar
   - Contras: nao melhora experiencia para usuarios com progresso

2. **B2 - Study Hub completo (escolhida)**
   - Pros: melhora experiencia em todos os estados; orienta proximo passo; mostra consistencia
   - Contras: escopo maior

3. **B3 - ViewModel dedicado**
   - Pros: separacao de responsabilidades mais explicita
   - Contras: complexidade extra sem necessidade atual; host simples ja resolve

## Decisao tomada

- **Decisao final:** Opcao B2 com host simples (sem ViewModel dedicado).
- **Motivo:** O host (MyStudyHost) ja gerencia estados de forma enxuta e o MyStudyView recebe dados puros com callbacks, seguindo o padrao existente.

## Impacto esperado

- **Usuario:** experiencia clara em todos os estados; proximo passo sempre visivel; motivacao via consistencia.
- **Negocio:** maior probabilidade de retorno diario e continuacao de estudo.
- **Tecnico:** nenhuma mudanca de backend; reuso de componentes do Design System.

## Escopo aprovado

- Inclui:
  - Estados loading/erro/vazio/com progresso na tab Meus estudos
  - Card "Continuar agora" com proxima licao
  - Secoes "Em andamento", "Proximas recomendacoes", "Consistencia"
  - Empty state orientado com CTA para catalogo
  - Acessibilidade minima e SF Symbols semanticos
- Nao inclui:
  - Mudancas de backend ou novas RPCs
  - Novas regras de XP/streak/badges
  - Dados de quizzes por semana (mostrado total geral)

## Artefatos atualizados

- `ios/SkillBitsApp/Sources/MainTabView.swift` (MyStudyHost evoluido)
- `ios/Packages/SkillBitsHome/Sources/SkillBitsHome/HomeAndStudyViews.swift` (MyStudyView refatorada)
- `docs/skillbits-feature-matrix.md` (status atualizado)
- `.cursor/skills/skillbits-home/SKILL.md` (arquitetura documentada)
- `docs/decisions/2026-02-28-study-hub-tab-v2.md` (este registro)

## Proximos passos

1. Validar UX em iPhone com dados reais
2. Considerar dado semanal de quizzes concluidos quando disponivel no backend
3. Avaliar se recomendacoes devem usar perfil do usuario (onboarding reason) para ranking

## Validacao do usuario

- **Aprovado por:** usuario
- **Canal:** chat
- **Observacoes:** plano B2 aprovado e executado conforme spec em `docs/feature-spec-my-study-tab-v2.md`
