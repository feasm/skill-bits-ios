# Product Decision Record

## Metadados

- **Data:** 2026-02-28
- **Responsavel:** PM SkillBits
- **Status:** aprovado
- **Tema:** Spec do Curso 01 - Como funciona a Internet

## Contexto

O app precisa acelerar a producao de conteudo real para MVP. A primeira entrega deve seguir exatamente o formato atual de ensino (texto estruturado, audio TTS, quiz e gamificacao), sem exigir novas capacidades tecnicas.

## Opcoes consideradas

1. **Opcao A - Curso totalmente teorico curto**
   - Prós: rapido de produzir e consistente com stack atual.
   - Contras: menor sensacao de pratica.
2. **Opcao B - Curso teorico-aplicado com pseudo-pratica**
   - Prós: maior engajamento sem aumentar escopo tecnico.
   - Contras: exige mais cuidado instrucional.
3. **Opcao C - Curso pratico com sandbox/editor**
   - Prós: alta percepcao de valor em temas tecnicos.
   - Contras: fora do escopo atual do app.

## Decisao tomada

- **Decisao final:** seguir com curso `Como funciona a Internet` no formato teorico puro, 25 min, 3 modulos, 6 licoes e 9 questoes.
- **Motivo:** maximiza velocidade de entrega e aderencia ao formato existente do produto.

## Impacto esperado

- **Usuario:** mais conteudo util para iniciantes sem friccao de uso.
- **Negocio:** melhora percepcao de catalogo ativo e suporte ao funil de retencao.
- **Tecnico:** sem mudancas de arquitetura; apenas insercao de dados e conteudo.

## Escopo aprovado

- Inclui: spec completa de curso, modulos, licoes e quiz no padrao de seed.
- Nao inclui: implementacao de backend/app, novos componentes, mudanca de regras de negocio.

## Artefatos atualizados

- `docs/course-spec-01-como-funciona-a-internet.md`
- `docs/skillbits-master-documentation.md`

## Proximos passos

1. Converter a spec em insercoes de seed/migracao de conteudo.
2. Revisar linguagem e didatica final das licoes.
3. Testar fluxo completo no app (catalogo -> licao -> quiz -> progresso).

## Validacao do usuario

- **Aprovado por:** glance
- **Canal:** chat
- **Observacoes:** solicitacao direta para montar a spec do curso 1 via skill de PM.

