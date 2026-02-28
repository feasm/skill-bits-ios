# SkillBits iOS - Review Critico de Governanca dos Skills

## Escopo

Revisao critica dos 12 arquivos `SKILL.md` criados em `.cursor/skills/skillbits-*`.

Objetivo: avaliar aderencia a um padrao mais rigido de governanca para uso recorrente por agentes.

## Criterios de avaliacao

Cada skill foi avaliado em 5 dimensoes (0-5):

1. **Descobribilidade** (descricao clara de quando usar)
2. **Cobertura funcional** (arquivos, regras e fluxo principal)
3. **Governanca operacional** (checklists/criterios de aceite)
4. **Confiabilidade** (riscos, cuidados, anti-regressoes)
5. **Evolutividade** (gaps e direcao de melhoria)

Nota final = media simples.

## Resultado por skill

| Skill | Descobribilidade | Cobertura | Governanca | Confiabilidade | Evolutividade | Nota final |
|---|---:|---:|---:|---:|---:|---:|
| skillbits-auth | 5 | 4 | 2 | 4 | 4 | 3.8 |
| skillbits-courses | 5 | 4 | 2 | 4 | 3 | 3.6 |
| skillbits-lessons | 5 | 4 | 2 | 4 | 3 | 3.6 |
| skillbits-quiz | 5 | 4 | 2 | 4 | 3 | 3.6 |
| skillbits-gamification | 5 | 5 | 3 | 4 | 4 | 4.2 |
| skillbits-progress | 5 | 4 | 2 | 4 | 4 | 3.8 |
| skillbits-profile | 5 | 4 | 2 | 4 | 4 | 3.8 |
| skillbits-paywall | 5 | 4 | 2 | 5 | 4 | 4.0 |
| skillbits-design-system | 5 | 4 | 2 | 4 | 3 | 3.6 |
| skillbits-home | 5 | 3 | 2 | 4 | 3 | 3.4 |
| skillbits-supabase | 5 | 5 | 2 | 5 | 4 | 4.2 |
| skillbits-navigation | 5 | 4 | 3 | 5 | 3 | 4.0 |

## Diagnostico critico

### Pontos fortes

- Frontmatter consistente e descricoes boas para acionamento automatico.
- Arquivos-alvo mapeados corretamente por dominio.
- Regras de negocio principais estao presentes na maior parte dos skills.
- Secoes de "Cuidados" e "Gaps atuais" ajudam a reduzir regressao.

### Fragilidades de governanca (principais)

1. **Falta de criterios de aceite formais**
   - A maioria nao define "Definition of Done" por mudanca.
2. **Falta de anti-patterns explicitos**
   - Existem cuidados, mas nao listas de "nunca fazer".
3. **Ausencia de check de verificacao padrao**
   - Nao ha sequencia minima obrigatoria de validacao (build/test/smoke).
4. **Pouco padrao de evidencias**
   - Nao define qual evidência deve ser registrada apos alteracoes (logs, telas, testes).
5. **Dependencia entre skills pouco formalizada**
   - Ex.: alteracoes de gamificacao deveriam forcar verificacao em progress/profile.

## Risco residual

- **Risco medio** para manutencao colaborativa: os skills sao bons guias taticos, mas ainda nao sao "procedurais" o suficiente para times maiores ou contribuidores novos.

## Recomendacoes de endurecimento (padrao v2)

Aplicar em todos os 12 skills uma secao padrao adicional:

1. `## Quando NAO usar`
2. `## Anti-patterns`
3. `## Checklist de verificacao minima`
4. `## Criterios de aceite`
5. `## Dependencias cruzadas obrigatorias`

### Template sugerido (v2)

```md
## Quando NAO usar
- ...

## Anti-patterns
- Nao ...
- Evitar ...

## Checklist de verificacao minima
1. Rodar ...
2. Validar ...
3. Confirmar ...

## Criterios de aceite
- [ ] ...
- [ ] ...

## Dependencias cruzadas obrigatorias
- Se mexer em X, revisar Y e Z.
```

## Priorizacao de melhoria

### Prioridade alta

- `skillbits-auth`
- `skillbits-paywall`
- `skillbits-supabase`
- `skillbits-navigation`

Motivo: domínios com maior impacto em fluxo critico, receita e regressao sistêmica.

### Prioridade media

- `skillbits-courses`
- `skillbits-lessons`
- `skillbits-quiz`
- `skillbits-gamification`
- `skillbits-progress`
- `skillbits-profile`

### Prioridade baixa

- `skillbits-home`
- `skillbits-design-system`

## Veredito

- **Aprovado para uso inicial** (v1).
- **Nao aprovado ainda para governanca rigida de escala** sem incorporar o padrao v2 acima.
