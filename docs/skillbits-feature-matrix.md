# SkillBits iOS - Matriz de Funcionalidades e Avaliacao de MVP

## Objetivo

Inventariar funcionalidades atuais, avaliar o diferencial competitivo do app e propor melhorias simples para acelerar entrega de MVP.

## Diagnostico rapido do produto

## Diferencial real hoje

1. **Quiz-first learning**: proposta forte e relativamente unica em apps para iniciantes de T.I em portugues.
2. **Posicionamento anti-doom-scroll**: narrativa de marketing clara e de facil comunicacao.
3. **Arquitetura modular iOS**: base tecnica boa para escalar features.

## Risco principal de MVP

~~**Conteudo insuficiente**: a maior parte das licoes ainda esta sem conteudo completo.~~  
**Resolvido** (2026-02-28): todas as 57 licoes possuem conteudo JSONB completo.  
Proximo risco principal: monetizacao real (StoreKit) ainda pendente.

## Inventario de funcionalidades atuais

Legenda de status:
- **Completo:** fluxo funcional principal implementado.
- **Parcial:** UI existe, mas regra/persistencia incompleta.
- **Stub:** UI existe sem logica funcional.

| Dominio | Feature | Status | Comentario |
|---|---|---|---|
| Auth | Login/cadastro email-senha | Completo | Integrado ao Supabase Auth |
| Auth | Sign in with Apple | Stub | Botao sem acao |
| Auth | Esqueci minha senha | Stub | Botao sem acao |
| Onboarding | Motivo + meta diaria | Completo | Chama RPC de inicializacao |
| Cursos | Catalogo com busca/filtros | Completo | Fluxo principal funcional |
| Cursos | Detalhe curso/modulo/licao | Completo | Navegacao e desbloqueio ativos |
| Lessons | Leitor de conteudo | Completo | Blocos ricos (heading, list, code, etc.) |
| Lessons | Audio/TTS | Completo | Recurso util para micro-learning |
| Quiz | Intro, questoes, resultado | Completo | Feedback imediato no fluxo |
| Quiz | Revisao guiada | Completo | Retorna erros da ultima tentativa |
| Gamificacao | XP e niveis | Completo | Com pequenas inconsistencias de exibicao |
| Gamificacao | Streak | Completo | Fonte no backend |
| Gamificacao | Badges | Parcial | 3 implementados; plano previa mais |
| Progresso | Painel de progresso | Completo | Grafico semanal integrado com backend (study_daily_log) |
| Perfil | Dados pessoais | Parcial | Tela existe, salvar incompleto |
| Perfil | Meta de estudo | Parcial | UX existe, persistencia parcial |
| Perfil | Notificacoes | Parcial | Toggles sem persistencia robusta |
| Monetizacao | Premium gate + paywall | Parcial | Fluxo visual bom |
| Monetizacao | Compra real (StoreKit) | Stub | Ainda em mock |
| Qualidade | Testes de UI/integracao | Stub | Cobertura baixa |
| Home | Study Hub (Meus estudos) | Completo | Empty state orientado, Continuar agora, Em andamento, Recomendacoes, Consistencia |
| Qualidade | Politica de refresh por TTL nas tabs | Completo | Evita refetch a cada troca de tab; refresh forcado por acao do usuario e pull-to-refresh |
| Navegacao | Fluxo de curso como modal isolado | Completo | fullScreenCover com NavigationStack propria; botao X para fechar fluxo; back entre niveis |

## Governanca por skills (skillbits-ios)

Para escalar o produto com consistencia, toda evolucao de feature deve seguir o skill mestre:
- `.cursor/skills/skillbits-ios/SKILL.md`

### Regras de governanca

1. Mudancas de UI/UX devem consultar `/mobile-ios-design`.
2. Mudancas de arquitetura e qualidade Swift devem consultar `/ios-development`.
3. Toda feature nova deve respeitar separacao por package e contratos em `SkillBitsCore`.
4. Mudancas em regra de negocio precisam atualizar `docs/skillbits-business-rules.md`.
5. Mudancas no estado de features precisam atualizar esta matriz.

### Checklist de atualizacao de docs por alteracao

- Atualizar `docs/skillbits-feature-matrix.md` (status e comentario por dominio).
- Atualizar `docs/skillbits-master-documentation.md` quando houver novo artefato relevante (skill, spec ou decisao).
- Atualizar `docs/decisions/YYYY-MM-DD-<tema>.md` para decisoes arquiteturais persistentes.

## Melhorias simples para MVP rapido

## O que fazer primeiro (alto impacto, baixo risco)

1. ~~Finalizar conteudo das licoes restantes (prioridade absoluta).~~ **Feito** (57/57 licoes com conteudo, 2026-02-28).
2. Implementar Sign in with Apple e fluxo de recuperacao de senha.
3. Integrar compra real (StoreKit 2) para validar modelo freemium.
4. ~~Substituir dados hardcoded do progresso por dados reais.~~ **Feito** (weekly chart integrado, 2026-02-28).
5. Fechar gaps de persistencia no perfil (meta e preferencias principais).
6. ~~Evoluir tab `Meus estudos` para Study Hub (empty state orientado + continuar agora + secoes de consistencia).~~ **Feito** (Study Hub B2, 2026-02-28).

## O que pode esperar para pos-MVP

- Recursos sociais complexos (leaderboard/comunidade).
- Offline robusto com sync avancado.
- Features de analytics mais profundas.

## Ranking de 20 novas funcionalidades

Escala:
- **Valor:** 1 (baixo) a 5 (alto)
- **Complexidade:** 1 (simples) a 5 (complexa)
- **Recomendacao MVP:** SIM/NAO

| # | Funcionalidade | Valor | Complexidade | Recomendacao MVP | Justificativa curta |
|---|---|---:|---:|---|---|
| 1 | Notificacoes push de streak | 5 | 2 | SIM | Aumenta retorno diario rapidamente |
| 2 | Compartilhar conquista no Instagram | 4 | 2 | SIM | Crescimento organico com baixo custo |
| 3 | Modo offline para licoes | 4 | 4 | NAO | Importante, mas escopo tecnico maior |
| 4 | Leaderboard semanal | 4 | 3 | NAO | Bom para engajamento, porem adiciona complexidade backend/social |
| 5 | Flashcards com repeticao espacada | 5 | 3 | SIM | Alto impacto pedagogico e retencao |
| 6 | Trilhas guiadas de 7 dias | 5 | 2 | SIM | Facilita onboarding do iniciante |
| 7 | Widget iOS de streak/progresso | 4 | 2 | SIM | Reforco diario fora do app |
| 8 | Certificado de conclusao | 4 | 2 | SIM | Alto valor percebido por estudantes |
| 9 | Toggle manual de dark mode | 3 | 1 | SIM | Simples e melhora UX |
| 10 | Busca global no conteudo | 3 | 3 | NAO | Util, mas nao critica para versao inicial |
| 11 | Progresso por topico (radar) | 3 | 3 | NAO | Visual interessante, baixo impacto no core |
| 12 | Comentarios por licao | 3 | 4 | NAO | Exige moderacao e operacao |
| 13 | Integracao Apple Health | 2 | 2 | NAO | Nice-to-have sem impacto direto de negocio |
| 14 | Pomodoro integrado | 3 | 2 | NAO | Pode entrar depois sem bloquear MVP |
| 15 | Daily challenge de quiz | 5 | 2 | SIM | Excelente gatilho de uso diario |
| 16 | Quiz diagnostico no onboarding | 4 | 3 | NAO | Bom, mas aumenta friccao inicial |
| 17 | Glossario de termos de T.I | 4 | 1 | SIM | Muito valor educacional com implementacao simples |
| 18 | Indicador de tempo real de leitura | 3 | 1 | SIM | Ajuste simples e util ao micro-learning |
| 19 | Favoritar licoes | 3 | 2 | NAO | Util, mas nao essencial no MVP |
| 20 | Celebracao de level-up | 4 | 2 | SIM | Reforca recompensa e habit loop |

## Pacote recomendado para MVP (11 features)

- 1, 2, 5, 6, 7, 8, 9, 15, 17, 18, 20

## Avaliacao final de diferencial

- **Existe diferencial?** Sim, principalmente no quiz-first + nicho T.I iniciante em portugues.
- **Esse diferencial esta maduro para mercado?** Parcialmente.
- **O que falta para virar MVP de verdade?**
  1. Conteudo completo.
  2. Monetizacao real.
  3. Fechar funcionalidades basicas de confianca (Apple Sign-In/recuperacao/salvamento de perfil).

Com esses tres pontos resolvidos, o produto ja pode testar tracao real com publico-alvo.
