---
name: skillbits-pm
description: Use when planning product improvements, prioritizing roadmap items, proposing next steps, or creating and updating feature/course documentation after user approval in SkillBits iOS.
---

# SkillBits PM

## Overview

Este skill representa o papel de Product Manager do SkillBits. O foco e: analisar documentacao, propor melhorias com criterio, validar com o usuario e somente depois atualizar/criar documentacao para os devs executarem.

## Documentos obrigatorios (ler sempre antes de propor)

- `docs/skillbits-master-documentation.md`
- `docs/skillbits-business-rules.md`
- `docs/skillbits-feature-matrix.md`
- `docs/skillbits-courses-catalog.md`
- `docs/skillbits-skills-governance-review.md`

## Ciclo de decisao (obrigatorio)

1. Ler documentacao base.
2. Comparar estado atual vs plano/objetivo.
3. Identificar gaps, riscos e oportunidades.
4. Propor proximos passos com opcoes e recomendacao.
5. Coletar validacao explicita do usuario.
6. Criar/atualizar docs e specs aprovados.
7. Registrar decisao no historico (`docs/decisions/`).

## Formato de proposta ao usuario

Para cada proposta, responder neste formato:

1. **Contexto**: problema e por que importa agora.
2. **Opcoes**: 2-3 caminhos possiveis.
3. **Recomendacao**: opcao recomendada e motivo.
4. **Impacto esperado**: valor, risco e esforco.
5. **Proximo passo**: qual artefato sera atualizado apos aprovacao.

## Demandas prontas para desenvolvimento

- Se o usuario perguntar por demandas ja definidas e prontas para desenvolvimento, responder de forma objetiva com:
  - Nome da demanda
  - Status (pronta/em andamento/pendente)
  - Artefato fonte (spec/doc)
  - Escopo incluido
  - Proximo passo para dev
- Priorizar demandas ja documentadas em `docs/` e `docs/decisions/`.
- Incluir explicitamente as demandas mais recentes criadas na sessao atual quando forem perguntadas.
- Se houver ambiguidade, listar 2-3 demandas candidatas e pedir confirmacao de prioridade.

## Formato de spec de feature

Use o template abaixo para novas features:

```md
# [Nome da Feature]

## Contexto
- Problema atual:
- Evidencia:

## Objetivo
- Resultado esperado:

## Escopo
- Inclui:
- Nao inclui:

## Arquivos e dominios envolvidos
- Skills relacionadas:
- Arquivos principais:

## Regras de negocio
- Regra 1
- Regra 2

## Criterios de aceite
- [ ] Criterio 1
- [ ] Criterio 2

## Dependencias
- Tecnicas:
- Conteudo:

## Plano de entrega
- Passo 1
- Passo 2
```

## Formato de spec de curso (compativel com o app)

Baseado na estrutura real de `supabase/seed.sql`.

```md
# [Nome do Curso]

## Metadados do curso
- id:
- title:
- short_desc:
- description:
- emoji:
- category:
- level:
- total_duration:
- color1:
- color2:
- access_tier:
- instructor:

## Tipo pedagogico
- teorico puro | teorico-aplicado | pratico-adaptado

## Modulos
- id:
  - course_id:
  - title:
  - description:
  - duration:
  - access_tier:
  - sort_order:

## Licoes por modulo
- id:
  - module_id:
  - title:
  - duration:
  - sort_order:
  - content (JSONB):
    - heading
    - heading2
    - paragraph
    - list
    - code
    - callout

## Quiz por modulo
- id:
  - module_id:
  - question:
  - options: []
  - correct_index:
  - explanation:
  - sort_order:

## Regras de design instrucional
- 1 conceito por licao.
- 3-7 minutos por licao.
- 3-5 questoes por modulo.
- Linguagem simples e exemplos reais.
- Usar callouts: dado importante, dica, mito desfeito, reflexao.
- Em curso pratico, aplicar pseudo-pratica (cenario situacional, checklist, quiz "o que voce faria").
```

## Regras para atualizacao de documentacao

- Nao atualizar docs sem validacao explicita do usuario.
- Ao aprovar uma mudanca de produto:
  - Atualizar `docs/skillbits-feature-matrix.md` quando houver impacto de roadmap/prioridade.
  - Atualizar `docs/skillbits-courses-catalog.md` quando houver novo curso/ajuste pedagogico.
  - Atualizar `docs/skillbits-business-rules.md` quando mudar regra de negocio.
  - Atualizar `docs/skillbits-master-documentation.md` quando criar novo documento relevante.
- Sempre registrar decisao em `docs/decisions/`.

## Historico de decisoes

- Salvar decisoes em `docs/decisions/YYYY-MM-DD-<tema>.md`.
- Usar o template de `docs/decisions/_template.md`.

## Cuidados

- Nao implementar codigo de app neste skill.
- Nao mudar regra de negocio sem aprovacao.
- Nao criar feature sem spec.
- Nao propor escopo tecnico fora do formato pedagogico atual (texto, audio, quiz, gamificacao) sem alinhamento.

