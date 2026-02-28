# My Study Tab v2 (Study Hub)

## Contexto

- Problema atual:
  - A aba `Meus estudos` hoje mostra apenas cursos com `progress > 0`.
  - Quando nao ha progresso, a experiencia fica vazia e sem direcionamento.
  - Mesmo com dados, o conteudo e raso: lista simples com titulo, descricao curta e barra de progresso.
- Evidencia:
  - A implementacao atual em `MyStudyView` usa apenas `courses.filter { $0.progress > 0 }` e renderiza uma lista linear.
  - `MyStudyHost` apenas carrega cursos, sem estados de loading/erro/vazio para orientar o usuario.

## Objetivo

- Transformar `Meus estudos` em um Study Hub com clareza de proximo passo, mais contexto de progresso e melhor qualidade de UX iOS.
- Aumentar a probabilidade de retorno diario e continuacao de estudo sem alterar as regras de negocio existentes.

## Escopo

- Inclui:
  - Redesenho de UX da tab `Meus estudos` com estados distintos.
  - Novo modelo de secoes para usuarios com e sem progresso.
  - Especificacao de conteudo textual para empty state.
  - Criterios de aceite funcionais e de UX para implementacao.
- Nao inclui:
  - Mudancas em regras de desbloqueio, XP, badges ou streak.
  - Mudancas de backend/RPC.
  - Novos modelos de monetizacao.

## Arquivos e dominios envolvidos

- Skills relacionadas:
  - `.cursor/skills/skillbits-pm/SKILL.md`
  - `.cursor/skills/skillbits-home/SKILL.md`
  - `.cursor/skills/skillbits-navigation/SKILL.md`
  - `mobile-ios-design` (HIG, Dynamic Type, acessibilidade)
- Arquivos principais:
  - `ios/Packages/SkillBitsHome/Sources/SkillBitsHome/HomeAndStudyViews.swift`
  - `ios/SkillBitsApp/Sources/MainTabView.swift`
  - `ios/Packages/SkillBitsDesignSystem/Sources/SkillBitsDesignSystem/Components.swift`
  - `ios/Packages/SkillBitsDesignSystem/Sources/SkillBitsDesignSystem/DesignTokens.swift`

## Regras de negocio

- Regra 1:
  - A tab deve continuar baseada em dados de cursos e progresso ja existentes, sem nova regra de backend.
- Regra 2:
  - O estado vazio deve oferecer CTA claro para iniciar estudo (abrir catalogo), em vez de tela sem conteudo util.
- Regra 3:
  - O estado com progresso deve priorizar "Continuar agora" (proxima acao concreta).
- Regra 4:
  - A experiencia deve respeitar o formato atual do produto (texto, audio, quiz, gamificacao), sem dependencias de recursos novos.

## Solucao proposta (Study Hub)

### Estrutura de secoes

1. **Header utilitario**
   - Titulo: `Meus estudos`
   - Subtitulo contextual:
     - sem progresso: `Seu plano de aprendizado comeca aqui`
     - com progresso: `Continue do ponto onde voce parou`

2. **Card principal - Continuar agora**
   - Exibido para usuario com progresso > 0.
   - Mostra:
     - curso atual
     - proxima licao sugerida
     - progresso (%)
     - CTA primario `Continuar`

3. **Secao - Em andamento**
   - Lista de cursos com progresso > 0.
   - Cada card com:
     - titulo
     - porcentagem
     - barra de progresso
     - meta curta (ex.: `Faltam 2 licoes neste modulo`)

4. **Secao - Proximas recomendacoes**
   - Cursos com progresso = 0 (top 2-3), para estimular descoberta.

5. **Secao - Consistencia**
   - Mini resumo de habito:
     - minutos hoje
     - streak atual
     - quizzes concluidos na semana (placeholder local, se ainda nao houver dado real)

### Estado vazio (sem progresso)

- Card de boas-vindas com:
  - SF Symbol principal (`book.closed.fill` ou `sparkles`)
  - mensagem clara em 1 linha
  - texto de apoio curto (2 linhas max)
  - CTA primario: `Explorar cursos`
  - CTA secundario: `Ver recomendados para iniciantes`

### Estado de erro e carregamento

- Carregando:
  - usar estado visual consistente com `SBLoadingState`.
- Erro:
  - mensagem curta + CTA `Tentar novamente`.

## Diretrizes de UX (mobile-ios-design + HIG)

- Clarity:
  - Hierarquia visual simples, sem excesso de card concorrente.
- Deference:
  - Conteudo e progresso do usuario no centro; decoracao discreta.
- Depth:
  - Uso moderado de cards e espacamentos para separar blocos.
- Acessibilidade:
  - labels/hints em CTAs principais.
  - suporte a Dynamic Type sem truncar CTA critico.
- iOS nativo:
  - SF Symbols semanticos.
  - tipografia semantica.
  - comportamento previsivel de scroll e toque.

## Conteudo (copy inicial sugerida)

- Header vazio:
  - `Meus estudos`
  - `Seu plano de aprendizado comeca aqui`
- Empty card:
  - `Comece com um curso curto hoje`
  - `Em 15 minutos voce ja destrava seu primeiro progresso.`
  - CTA: `Explorar cursos`
- Header com progresso:
  - `Meus estudos`
  - `Continue do ponto onde voce parou`

## Criterios de aceite

- [ ] Usuario sem progresso visualiza empty state util (nao tela vazia).
- [ ] Empty state oferece CTA para iniciar jornada.
- [ ] Usuario com progresso visualiza bloco `Continuar agora`.
- [ ] Lista `Em andamento` mostra cursos com progresso > 0.
- [ ] Recomendacoes mostram cursos nao iniciados.
- [ ] Estados de loading e erro ficam claros.
- [ ] Layout segue tipografia semantica e funciona com Dynamic Type.
- [ ] Elementos principais possuem acessibilidade minima (`Label`/`Hint`).

## Dependencias

- Tecnicas:
  - Nenhuma mudanca obrigatoria de backend.
  - Reuso de componentes do Design System existente.
- Conteudo:
  - Copy de empty state e subtitulos.
  - Definicao da metrica exibida em `Consistencia` quando nao houver dado real para semana.

## Plano de entrega

- Passo 1: Ajustar estrutura da view `MyStudyView` para suportar estados (vazio/com progresso/loading/erro).
- Passo 2: Implementar bloco `Continuar agora`.
- Passo 3: Implementar secoes `Em andamento`, `Proximas recomendacoes`, `Consistencia`.
- Passo 4: Revisar acessibilidade e Dynamic Type.
- Passo 5: Validar UX final em iPhone (e iPad se aplicavel).
