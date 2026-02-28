# Curso 01 - Como funciona a Internet

## Metadados do curso

- id: `c4`
- title: `Como funciona a Internet`
- short_desc: `Entenda, de forma simples, como uma mensagem sai do seu celular e chega ao mundo.`
- description: `Curso introdutorio para estudantes e curiosos que querem entender os conceitos essenciais da internet sem jargao tecnico. Do caminho de uma requisicao aos protocolos basicos, o foco e clareza pratica para iniciantes.`
- emoji: `🌐`
- category: `Fundamentos`
- level: `Iniciante`
- total_duration: `25 min`
- color1: `#3B82F6`
- color2: `#06B6D4`
- access_tier: `free`
- instructor: `Time SkillBits`

## Tipo pedagogico

- `teorico puro`

## Modulos

- id: `m21`
  - course_id: `c4`
  - title: `A jornada de uma informacao`
  - description: `Do app ate o servidor: o caminho de uma requisicao.`
  - duration: `8 min`
  - access_tier: `free`
  - sort_order: `0`

- id: `m22`
  - course_id: `c4`
  - title: `Protocolos sem complicacao`
  - description: `HTTP, HTTPS, DNS e IP explicados com exemplos do dia a dia.`
  - duration: `8 min`
  - access_tier: `free`
  - sort_order: `1`

- id: `m23`
  - course_id: `c4`
  - title: `Velocidade, seguranca e boas praticas`
  - description: `Latencia, cache e protecao basica para navegar melhor.`
  - duration: `9 min`
  - access_tier: `free`
  - sort_order: `2`

## Licoes por modulo

- id: `l58`
  - module_id: `m21`
  - title: `O que acontece quando voce abre um site`
  - duration: `4 min`
  - sort_order: `0`
  - content (JSONB):
    - `{"type":"heading","value":"Da tela ao servidor em poucos passos"}`
    - `{"type":"paragraph","value":"Quando voce abre um site, seu navegador envia uma requisicao para um servidor. O servidor responde com os dados necessarios para montar a pagina."}`
    - `{"type":"list","value":["Voce digita um endereco","O navegador busca para onde enviar","O servidor processa e responde","A pagina aparece na tela"]}`
    - `{"type":"callout","title":"Dica","text":"Pense na internet como um sistema de entregas: voce faz um pedido e recebe uma resposta."}`

- id: `l59`
  - module_id: `m21`
  - title: `Cliente, servidor e rede`
  - duration: `4 min`
  - sort_order: `1`
  - content (JSONB):
    - `{"type":"heading","value":"Quem pede, quem responde, por onde passa"}`
    - `{"type":"paragraph","value":"Cliente e o dispositivo do usuario. Servidor e o computador que guarda dados e responde pedidos. Rede e o caminho entre os dois."}`
    - `{"type":"heading2","value":"Exemplo simples"}`
    - `{"type":"paragraph","value":"Seu celular e o cliente. O servidor do app guarda conteudo. A internet conecta os dois."}`
    - `{"type":"callout","title":"Reflexao","text":"Sem servidor, apps modernos nao entregam conteudo dinamico."}`

- id: `l60`
  - module_id: `m22`
  - title: `O que e DNS e por que ele importa`
  - duration: `4 min`
  - sort_order: `0`
  - content (JSONB):
    - `{"type":"heading","value":"DNS e a lista de contatos da internet"}`
    - `{"type":"paragraph","value":"Voce lembra nomes de sites, nao numeros IP. O DNS traduz nomes como exemplo.com para o endereco IP correspondente."}`
    - `{"type":"list","value":["Voce informa o nome do site","DNS encontra o IP","Navegador usa o IP para conectar"]}`
    - `{"type":"callout","title":"Mito desfeito","text":"DNS nao deixa internet mais rapida por si so, mas evita que voce tenha que decorar IPs."}`

- id: `l61`
  - module_id: `m22`
  - title: `HTTP vs HTTPS sem jargao`
  - duration: `4 min`
  - sort_order: `1`
  - content (JSONB):
    - `{"type":"heading","value":"Como os dados trafegam"}`
    - `{"type":"paragraph","value":"HTTP envia dados sem criptografia. HTTPS adiciona camada de seguranca para proteger as informacoes durante o trajeto."}`
    - `{"type":"code","language":"text","text":"HTTP  -> sem criptografia\nHTTPS -> com criptografia (TLS)"}`
    - `{"type":"callout","title":"Dado importante","text":"Sempre prefira HTTPS em login, pagamento e envio de dados pessoais."}`

- id: `l62`
  - module_id: `m23`
  - title: `Por que a internet fica lenta`
  - duration: `4 min`
  - sort_order: `0`
  - content (JSONB):
    - `{"type":"heading","value":"Latencia, congestionamento e distancia"}`
    - `{"type":"paragraph","value":"A velocidade percebida depende de tempo de resposta (latencia), capacidade da rede e carga dos servidores."}`
    - `{"type":"list","value":["Wi-Fi fraco","Muitos usuarios ao mesmo tempo","Servidor sobrecarregado","Rota longa ate o servidor"]}`
    - `{"type":"callout","title":"Dica","text":"Trocar de rede ou aproximar do roteador pode melhorar a experiencia imediatamente."}`

- id: `l63`
  - module_id: `m23`
  - title: `Boas praticas para navegar com seguranca`
  - duration: `5 min`
  - sort_order: `1`
  - content (JSONB):
    - `{"type":"heading","value":"Habitos que evitam problemas"}`
    - `{"type":"paragraph","value":"Seguranca na internet comeca com atitudes simples no dia a dia."}`
    - `{"type":"list","value":["Verificar HTTPS","Evitar links suspeitos","Usar senha forte e unica","Ativar autenticacao em duas etapas"]}`
    - `{"type":"heading2","value":"Fechamento do curso"}`
    - `{"type":"paragraph","value":"Agora voce entende os blocos essenciais da internet e consegue interpretar melhor termos comuns em tecnologia."}`

## Quiz por modulo

- id: `q1-m21`
  - module_id: `m21`
  - question: `No fluxo basico da internet, quem responde a requisicao do navegador?`
  - options: `["O roteador","O servidor","O DNS","O cabo de rede"]`
  - correct_index: `1`
  - explanation: `O servidor processa a requisicao e devolve os dados para o cliente.`
  - sort_order: `0`

- id: `q2-m21`
  - module_id: `m21`
  - question: `No contexto web, cliente e:`
  - options: `["Quem desenvolve o app","O dispositivo do usuario","Um tipo de firewall","Um tipo de banco de dados"]`
  - correct_index: `1`
  - explanation: `Cliente e o dispositivo/aplicacao que faz o pedido ao servidor.`
  - sort_order: `1`

- id: `q3-m21`
  - module_id: `m21`
  - question: `Qual sequencia faz mais sentido?`
  - options: `["Servidor -> Cliente -> Requisicao","Cliente -> Requisicao -> Servidor -> Resposta","DNS -> Senha -> Firewall","Roteador -> App -> Banco sem servidor"]`
  - correct_index: `1`
  - explanation: `O cliente envia requisicao, o servidor processa e retorna resposta.`
  - sort_order: `2`

- id: `q1-m22`
  - module_id: `m22`
  - question: `O principal papel do DNS e:`
  - options: `["Criptografar dados","Traduzir nome de dominio para IP","Aumentar sinal do Wi-Fi","Armazenar senhas"]`
  - correct_index: `1`
  - explanation: `DNS converte nomes amigaveis em enderecos IP usados na conexao.`
  - sort_order: `0`

- id: `q2-m22`
  - module_id: `m22`
  - question: `HTTPS difere de HTTP porque:`
  - options: `["Nao usa internet","Usa criptografia para proteger dados","So funciona em celular","Dispensa servidor"]`
  - correct_index: `1`
  - explanation: `HTTPS adiciona criptografia (TLS) no transporte dos dados.`
  - sort_order: `1`

- id: `q3-m22`
  - module_id: `m22`
  - question: `Em qual situacao HTTPS e mais critico?`
  - options: `["Ler uma noticia publica","Enviar login e senha","Abrir calculadora offline","Trocar papel de parede"]`
  - correct_index: `1`
  - explanation: `Dados sensiveis exigem canal seguro para reduzir risco de interceptacao.`
  - sort_order: `2`

- id: `q1-m23`
  - module_id: `m23`
  - question: `Latencia significa principalmente:`
  - options: `["Tamanho da tela","Tempo de resposta da comunicacao","Capacidade da bateria","Quantidade de apps instalados"]`
  - correct_index: `1`
  - explanation: `Latencia e o tempo que o dado leva para ir e voltar.`
  - sort_order: `0`

- id: `q2-m23`
  - module_id: `m23`
  - question: `Qual pratica melhora seguranca online?`
  - options: `["Mesma senha em tudo","Ignorar atualizacoes","Ativar autenticacao em dois fatores","Compartilhar codigo de verificacao"]`
  - correct_index: `2`
  - explanation: `2FA reduz risco mesmo quando a senha vaza.`
  - sort_order: `1`

- id: `q3-m23`
  - module_id: `m23`
  - question: `Um motivo comum para internet lenta e:`
  - options: `["Servidor sobrecarregado","Uso de HTTPS","Nome curto de dominio","Tela em modo escuro"]`
  - correct_index: `0`
  - explanation: `Carga alta no servidor pode aumentar o tempo de resposta.`
  - sort_order: `2`

## Regras de design instrucional

- 1 conceito por licao.
- 3-7 minutos por licao.
- 3 questoes por modulo (total 9).
- Linguagem simples e exemplos reais.
- Uso de callouts: dado importante, dica, mito desfeito, reflexao.
- Mantido no formato atual do app: texto estruturado + audio TTS + quiz + XP/streak/badges.

## Criterios de aceite para dev/content

- [ ] Curso cadastrado com metadados completos no padrao de `courses`.
- [ ] Modulos `m21-m23` cadastrados no padrao de `modules`.
- [ ] Licoes `l58-l63` com JSONB valido usando tipos suportados.
- [ ] Quizzes cadastrados com 3 questoes por modulo.
- [ ] Fluxo do curso respeita desbloqueio sequencial e regra de aprovacao >= 70.
- [ ] Conteudo pode ser lido por TTS sem ajustes manuais.
