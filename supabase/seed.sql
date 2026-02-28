-- ============================================================
-- SkillBits MVP Seed Data
-- ============================================================

-- Courses
INSERT INTO courses (id, title, short_desc, description, emoji, category, level, total_duration, color1, color2, access_tier, instructor, sort_order) VALUES
('c1', 'Profissoes de T.I', 'Descubra as principais carreiras de tecnologia e encontre sua trilha', 'Explore as profissoes mais demandadas da area de tecnologia. De desenvolvimento de software a gestao de produtos, entenda o que cada carreira envolve no dia a dia, as habilidades necessarias e como escolher o caminho certo para voce.', '💼', 'Carreira', 'Iniciante', '8h 30min', '#667EEA', '#764BA2', 'free', 'Ana Beatriz Costa', 0),
('c2', 'Conceitos Basicos de T.I', 'Entenda como funcionam computadores, internet e seguranca digital', 'Uma base solida para quem esta comecando. Aprenda sobre hardware, software, internet, cloud, sistemas operacionais e seguranca digital de forma acessivel e pratica.', '🖥️', 'Fundamentos', 'Iniciante', '5h 40min', '#40E0D0', '#2D95DA', 'free', 'Carlos Eduardo Lima', 1),
('c3', 'Conceitos Basicos de Programacao', 'Seus primeiros passos no mundo da programacao', 'Aprenda os fundamentos da logica de programacao de forma pratica. De variaveis a funcoes, construa seu primeiro algoritmo e desenvolva o pensamento computacional necessario para qualquer linguagem.', '🧑‍💻', 'Programacao', 'Iniciante', '4h 30min', '#F7971E', '#FFD200', 'premium', 'Mariana Santos', 2);

-- Modules - Course c1 (Profissoes de T.I) - all free
INSERT INTO modules (id, course_id, title, description, duration, access_tier, sort_order) VALUES
('m1', 'c1', 'O que e TI e por que importa', 'Panorama do setor e impacto no mercado de trabalho', '1h', 'free', 0),
('m2', 'c1', 'Desenvolvedor de Software', 'Front-end, back-end, mobile e full stack', '1h 15min', 'free', 1),
('m3', 'c1', 'Designer de UX/UI', 'Pesquisa, prototipacao e design de interfaces', '1h 10min', 'free', 2),
('m4', 'c1', 'Analista e Cientista de Dados', 'Dados como base para decisoes estrategicas', '1h', 'free', 3),
('m5', 'c1', 'DevOps e Engenheiro de Infraestrutura', 'Automacao, deploy e confiabilidade', '1h', 'free', 4),
('m6', 'c1', 'Seguranca da Informacao', 'Protecao de sistemas, redes e dados', '55min', 'free', 5),
('m7', 'c1', 'Gestao de TI e Product Manager', 'Lideranca tecnica e gestao de produtos digitais', '1h', 'free', 6),
('m8', 'c1', 'Como escolher sua trilha', 'Autoavaliacao e proximos passos na carreira', '1h 10min', 'free', 7);

-- Modules - Course c2 (Conceitos Basicos de T.I) - m9 free, rest premium
INSERT INTO modules (id, course_id, title, description, duration, access_tier, sort_order) VALUES
('m9',  'c2', 'Hardware e Software', 'Componentes fisicos e logicos de um computador', '50min', 'free', 0),
('m10', 'c2', 'Como a Internet funciona', 'Protocolos, servidores e a web no dia a dia', '55min', 'premium', 1),
('m11', 'c2', 'Cloud Computing', 'Servicos na nuvem e por que sao tao usados', '50min', 'premium', 2),
('m12', 'c2', 'Sistemas Operacionais', 'Windows, Linux e macOS no contexto de TI', '55min', 'premium', 3),
('m13', 'c2', 'Seguranca digital no dia a dia', 'Proteja seus dados e dispositivos pessoais', '50min', 'premium', 4),
('m14', 'c2', 'Redes', 'Fundamentos de redes de computadores', '1h', 'premium', 5);

-- Modules - Course c3 (Conceitos Basicos de Programacao) - all premium
INSERT INTO modules (id, course_id, title, description, duration, access_tier, sort_order) VALUES
('m15', 'c3', 'O que e programacao', 'Entenda o que significa programar e como o computador executa instrucoes', '45min', 'premium', 0),
('m16', 'c3', 'Variaveis e tipos', 'Armazene e manipule informacoes no seu programa', '50min', 'premium', 1),
('m17', 'c3', 'Condicoes', 'Faca seu programa tomar decisoes', '45min', 'premium', 2),
('m18', 'c3', 'Loops', 'Repita acoes de forma eficiente', '45min', 'premium', 3),
('m19', 'c3', 'Funcoes', 'Organize e reutilize blocos de codigo', '50min', 'premium', 4),
('m20', 'c3', 'Primeiro algoritmo', 'Junte tudo e construa seu primeiro programa completo', '55min', 'premium', 5);

-- Lessons - Course c1
INSERT INTO lessons (id, module_id, title, duration, sort_order, content) VALUES
('l1', 'm1', 'A revolucao digital e o mercado de TI', '10 min', 0,
 '[{"type":"heading","value":"A tecnologia mudou tudo — e continua mudando"},{"type":"paragraph","value":"A area de Tecnologia da Informacao (TI) deixou de ser um departamento de suporte para se tornar o motor de inovacao de praticamente todos os setores. De saude a agricultura, de financas a entretenimento, empresas dependem de profissionais de tecnologia para crescer, inovar e resolver problemas complexos."},{"type":"heading2","value":"O que e TI, afinal?"},{"type":"paragraph","value":"TI e o conjunto de recursos tecnologicos e computacionais usados para criar, armazenar, processar e transmitir informacoes. Isso inclui hardware, software, redes, bancos de dados e muito mais."},{"type":"list","value":["O setor de TI cresce 3x mais rapido que a economia geral","Existem mais vagas abertas do que profissionais qualificados","Salarios iniciais estao entre os mais altos do mercado","Trabalho remoto e flexibilidade sao comuns na area"]},{"type":"heading2","value":"Por que aprender sobre TI agora?"},{"type":"paragraph","value":"Independente da sua area de atuacao, entender tecnologia se tornou uma habilidade essencial. Mesmo que voce nao queira programar, saber como sistemas funcionam, como dados sao usados e como a internet opera vai te dar uma vantagem competitiva enorme."},{"type":"callout","title":"Dado importante","text":"Segundo pesquisas recentes, mais de 70% das empresas brasileiras relatam dificuldade em contratar profissionais de TI qualificados. Isso significa oportunidade para quem se preparar."}]'::jsonb),
('l2', 'm1', 'Areas de atuacao em tecnologia', '12 min', 1,
 '[{"type":"heading","value":"Um universo de possibilidades"},{"type":"paragraph","value":"Quando falamos em ''trabalhar com tecnologia'', estamos falando de dezenas de carreiras diferentes. Cada uma exige habilidades especificas e oferece desafios unicos. Vamos conhecer as principais areas."},{"type":"heading2","value":"Desenvolvimento de Software"},{"type":"paragraph","value":"Programadores criam os sistemas, apps e sites que usamos todos os dias. Dentro do desenvolvimento, existem especializacoes como front-end (interface), back-end (logica e servidores) e mobile (apps para celular)."},{"type":"heading2","value":"Dados e Inteligencia Artificial"},{"type":"paragraph","value":"Analistas e cientistas de dados transformam grandes volumes de informacao em insights para decisoes estrategicas. Com o crescimento de IA, essa area esta em plena expansao."},{"type":"heading2","value":"Infraestrutura e DevOps"},{"type":"paragraph","value":"Profissionais de infra cuidam dos servidores, redes e ambientes onde os sistemas rodam. DevOps conecta desenvolvimento e operacoes para entregas mais rapidas e confiaveis."},{"type":"list","value":["Desenvolvimento: front-end, back-end, mobile, full stack","Design: UX research, UI design, design systems","Dados: analise de dados, ciencia de dados, engenharia de dados","Infraestrutura: DevOps, SRE, cloud engineering","Seguranca: pentest, compliance, resposta a incidentes","Gestao: product manager, tech lead, CTO"]},{"type":"callout","title":"Dica","text":"Nao se preocupe em escolher agora. Ao longo deste curso, vamos explorar cada area em profundidade para que voce possa decidir com mais clareza."}]'::jsonb),
('l3', 'm1', 'Habilidades valorizadas por recrutadores', '11 min', 2,
 '[{"type":"heading","value":"O que as empresas realmente procuram"},{"type":"paragraph","value":"Alem de conhecimento tecnico, empresas de tecnologia valorizam um conjunto de habilidades comportamentais e praticas que fazem a diferenca no dia a dia."},{"type":"heading2","value":"Habilidades tecnicas (hard skills)"},{"type":"list","value":["Logica de programacao e pensamento algoritmico","Conhecimento de pelo menos uma linguagem de programacao","Entendimento basico de bancos de dados","Familiaridade com controle de versao (Git)","Nocoes de redes e sistemas operacionais"]},{"type":"heading2","value":"Habilidades comportamentais (soft skills)"},{"type":"list","value":["Resolucao de problemas: decomposicao e analise critica","Comunicacao clara: saber explicar ideias tecnicas para nao-tecnicos","Aprendizado continuo: a tecnologia muda rapido","Trabalho em equipe: metodologias ageis exigem colaboracao constante"]},{"type":"paragraph","value":"O profissional que combina habilidades tecnicas solidas com boa comunicacao e capacidade de adaptacao tem as melhores oportunidades no mercado."},{"type":"callout","title":"Mito desfeito","text":"Voce nao precisa ser genio em matematica para trabalhar com TI. A maioria das funcoes exige logica e persistencia, nao calculo avancado."}]'::jsonb),
('l4', 'm1', 'Como TI transforma todos os setores', '9 min', 3,
 '[{"type":"heading","value":"TI nao e so para empresas de tecnologia"},{"type":"paragraph","value":"Todos os setores da economia estao passando por uma transformacao digital. Profissionais de TI sao necessarios em hospitais, bancos, fazendas, escolas e muito mais."},{"type":"heading2","value":"Exemplos praticos"},{"type":"list","value":["Saude: prontuarios eletronicos, telemedicina, IA para diagnosticos","Financas: fintechs, pagamentos digitais, blockchain","Educacao: plataformas de ensino online, gamificacao","Agricultura: sensores IoT, drones, analise de solo por satelite","Varejo: e-commerce, personalizacao por dados, logistica inteligente"]},{"type":"paragraph","value":"Isso significa que, alem de trabalhar em empresas de tecnologia, voce pode aplicar seus conhecimentos de TI no setor que mais te interessa."},{"type":"callout","title":"Reflexao","text":"Pense em uma area que voce gosta. Como a tecnologia esta transformando esse setor? Essa pode ser a intersecao perfeita para sua carreira."}]'::jsonb),
('l5', 'm2', 'O que faz um dev front-end', '10 min', 0,
 '[{"type":"heading","value":"A interface que o usuario ve e toca"},{"type":"paragraph","value":"O desenvolvedor front-end e responsavel por transformar designs em interfaces funcionais. Tudo que voce ve em um site ou app — botoes, menus, animacoes — foi construido por um front-end."},{"type":"heading2","value":"Tecnologias principais"},{"type":"list","value":["HTML: estrutura do conteudo","CSS: estilizacao e layout","JavaScript: interatividade e logica","Frameworks: React, Vue, Angular, SwiftUI"]},{"type":"heading2","value":"O dia a dia"},{"type":"paragraph","value":"Um front-end recebe designs (geralmente do Figma) e os transforma em codigo. Trabalha em estreita colaboracao com designers e desenvolvedores back-end para garantir que a experiencia do usuario seja fluida e performatica."},{"type":"code","language":"html","text":"<button class=\"btn-primary\">\n  Iniciar curso\n</button>"},{"type":"callout","title":"Carreira","text":"Front-end e uma das portas de entrada mais populares em TI. Com HTML, CSS e JavaScript voce ja consegue construir projetos impressionantes para seu portfolio."}]'::jsonb),
('l6', 'm2', 'Back-end e APIs', '12 min', 1, NULL),
('l7', 'm2', 'Desenvolvimento mobile', '11 min', 2, NULL),
('l8', 'm2', 'Full stack: vale a pena?', '10 min', 3, NULL),
('l9', 'm3', 'Diferenca entre UX e UI', '10 min', 0, NULL),
('l10', 'm3', 'Ferramentas do designer', '12 min', 1, NULL),
('l11', 'm3', 'Portfolio e mercado de trabalho', '11 min', 2, NULL),
('l12', 'm4', 'O que faz um analista de dados', '10 min', 0, NULL),
('l13', 'm4', 'Cientista de dados e machine learning', '13 min', 1, NULL),
('l14', 'm4', 'Ferramentas e linguagens para dados', '11 min', 2, NULL),
('l15', 'm5', 'O papel do DevOps no time', '10 min', 0, NULL),
('l16', 'm5', 'CI/CD e automacao', '12 min', 1, NULL),
('l17', 'm5', 'Cloud e infraestrutura moderna', '11 min', 2, NULL),
('l18', 'm6', 'O que faz um profissional de seguranca', '10 min', 0, NULL),
('l19', 'm6', 'Tipos de ameacas e ataques', '12 min', 1, NULL),
('l20', 'm6', 'Certificacoes e carreira', '9 min', 2, NULL),
('l21', 'm7', 'Gestor de TI vs Product Manager', '10 min', 0, NULL),
('l22', 'm7', 'Metodologias ageis no dia a dia', '12 min', 1, NULL),
('l23', 'm7', 'De tecnico a lider: transicao de carreira', '11 min', 2, NULL),
('l24', 'm8', 'Autoavaliacao: perfil e interesses', '10 min', 0, NULL),
('l25', 'm8', 'Roadmap de estudo por area', '13 min', 1, NULL),
('l26', 'm8', 'Comunidades e networking', '10 min', 2, NULL),
('l27', 'm8', 'Primeiro projeto pratico', '12 min', 3, NULL);

-- Lessons - Course c2
INSERT INTO lessons (id, module_id, title, duration, sort_order) VALUES
('l28', 'm9',  'O que e hardware', '10 min', 0),
('l29', 'm9',  'O que e software', '9 min', 1),
('l30', 'm9',  'Como hardware e software trabalham juntos', '11 min', 2),
('l31', 'm10', 'O caminho de um site ate voce', '11 min', 0),
('l32', 'm10', 'HTTP, DNS e IP explicados', '12 min', 1),
('l33', 'm11', 'O que e cloud computing', '10 min', 0),
('l34', 'm11', 'IaaS, PaaS e SaaS', '11 min', 1),
('l35', 'm12', 'O que faz um sistema operacional', '10 min', 0),
('l36', 'm12', 'Windows vs Linux vs macOS', '12 min', 1),
('l37', 'm12', 'Terminal e linha de comando', '11 min', 2),
('l38', 'm13', 'Senhas seguras e autenticacao', '10 min', 0),
('l39', 'm13', 'Phishing e engenharia social', '12 min', 1),
('l40', 'm14', 'O que e uma rede de computadores', '10 min', 0),
('l41', 'm14', 'Wi-Fi, roteadores e switches', '12 min', 1),
('l42', 'm14', 'Modelo TCP/IP simplificado', '11 min', 2);

-- Lessons - Course c3
INSERT INTO lessons (id, module_id, title, duration, sort_order) VALUES
('l43', 'm15', 'Linguagens e compiladores', '10 min', 0),
('l44', 'm15', 'Seu primeiro Hello World', '11 min', 1),
('l45', 'm15', 'Como pensar como um programador', '10 min', 2),
('l46', 'm16', 'O que sao variaveis', '10 min', 0),
('l47', 'm16', 'Tipos de dados: texto, numero e booleano', '12 min', 1),
('l48', 'm16', 'Operacoes basicas com variaveis', '11 min', 2),
('l49', 'm17', 'If, else e else if', '11 min', 0),
('l50', 'm17', 'Operadores de comparacao', '10 min', 1),
('l51', 'm18', 'While e for', '12 min', 0),
('l52', 'm18', 'Quando usar cada tipo de loop', '10 min', 1),
('l53', 'm19', 'Criando e chamando funcoes', '11 min', 0),
('l54', 'm19', 'Parametros e retorno', '12 min', 1),
('l55', 'm20', 'Planejando o algoritmo', '10 min', 0),
('l56', 'm20', 'Implementando passo a passo', '13 min', 1),
('l57', 'm20', 'Testando e corrigindo erros', '12 min', 2);

-- Quiz Questions - Module m1 (10 questions)
INSERT INTO quiz_questions (id, module_id, question, options, correct_index, explanation, sort_order) VALUES
('q1-m1', 'm1', 'Qual setor NAO e impactado significativamente por TI?', '["Saude","Agricultura","Financas","Nenhum — todos sao impactados"]'::jsonb, 3, 'Todos os setores da economia sao transformados pela tecnologia da informacao.', 0),
('q2-m1', 'm1', 'O que diferencia um desenvolvedor front-end de um back-end?', '["Front-end trabalha com servidores","Back-end cria interfaces visuais","Front-end cria a interface que o usuario ve","Nao ha diferenca"]'::jsonb, 2, 'O front-end e responsavel pela interface do usuario, enquanto o back-end cuida da logica e servidores.', 1),
('q3-m1', 'm1', 'Qual habilidade comportamental e mais valorizada em TI?', '["Memorizar codigos","Trabalho isolado","Resolucao de problemas","Velocidade de digitacao"]'::jsonb, 2, 'Saber decompor e resolver problemas e a habilidade mais buscada por recrutadores.', 2),
('q4-m1', 'm1', 'O que significa a sigla TI?', '["Tecnologia Industrial","Tecnologia da Informacao","Trabalho Integrado","Tecnica de Inovacao"]'::jsonb, 1, 'TI significa Tecnologia da Informacao.', 3),
('q5-m1', 'm1', 'Qual afirmacao sobre o mercado de TI e verdadeira?', '["Ha mais profissionais do que vagas","Salarios sao geralmente baixos","Existem mais vagas do que profissionais qualificados","Trabalho remoto nao e comum"]'::jsonb, 2, 'O deficit de profissionais qualificados e uma realidade global no setor de TI.', 4),
('q6-m1', 'm1', 'O que faz um profissional de DevOps?', '["Cria interfaces de usuario","Conecta desenvolvimento e operacoes para entregas rapidas","Analisa dados de marketing","Gerencia equipes de vendas"]'::jsonb, 1, 'DevOps integra desenvolvimento e operacoes para melhorar a velocidade e confiabilidade das entregas.', 5),
('q7-m1', 'm1', 'Qual e uma porta de entrada popular para iniciar em TI?', '["Seguranca da informacao avancada","Gestao de projetos","Desenvolvimento front-end","Engenharia de dados"]'::jsonb, 2, 'Front-end e acessivel para iniciantes e permite criar projetos visiveis rapidamente.', 6),
('q8-m1', 'm1', 'Git e uma ferramenta usada para:', '["Design de interfaces","Controle de versao de codigo","Gerenciamento de emails","Criacao de bancos de dados"]'::jsonb, 1, 'Git e o sistema de controle de versao mais usado por desenvolvedores.', 7),
('q9-m1', 'm1', 'O que e uma fintech?', '["Uma fazenda tecnologica","Uma empresa de tecnologia financeira","Um tipo de hardware","Uma linguagem de programacao"]'::jsonb, 1, 'Fintechs sao empresas que usam tecnologia para inovar em servicos financeiros.', 8),
('q10-m1', 'm1', 'Qual combinacao traz mais oportunidades no mercado?', '["Apenas habilidades tecnicas","Apenas habilidades comportamentais","Habilidades tecnicas + comunicacao + adaptacao","Apenas certificacoes"]'::jsonb, 2, 'A combinacao de hard skills com soft skills e o que abre as melhores portas no mercado.', 9);

-- Generic quiz questions for other modules (2 per module)
INSERT INTO quiz_questions (id, module_id, question, options, correct_index, explanation, sort_order) VALUES
('q1-m2', 'm2', 'Qual e a principal responsabilidade de um desenvolvedor front-end?', '["Gerenciar servidores","Criar a interface do usuario","Analisar dados","Gerenciar projetos"]'::jsonb, 1, 'O front-end e responsavel por criar a interface que o usuario ve e interage.', 0),
('q2-m2', 'm2', 'O que e uma API?', '["Uma linguagem de programacao","Uma interface para comunicacao entre sistemas","Um tipo de banco de dados","Um framework CSS"]'::jsonb, 1, 'API (Application Programming Interface) permite que diferentes sistemas se comuniquem.', 1),
('q1-m3', 'm3', 'Qual a diferenca principal entre UX e UI?', '["Nao ha diferenca","UX foca na experiencia, UI no visual","UX e para mobile, UI para web","UX e mais importante que UI"]'::jsonb, 1, 'UX (User Experience) foca na experiencia geral, UI (User Interface) foca no design visual.', 0),
('q2-m3', 'm3', 'Qual ferramenta e mais usada por designers de interface?', '["Excel","Figma","Word","PowerPoint"]'::jsonb, 1, 'Figma e a ferramenta mais popular para design de interfaces.', 1),
('q1-m4', 'm4', 'O que faz um cientista de dados?', '["Cria interfaces","Analisa dados para gerar insights","Gerencia redes","Vende software"]'::jsonb, 1, 'Cientistas de dados analisam dados complexos para gerar insights que apoiam decisoes.', 0),
('q2-m4', 'm4', 'Qual linguagem e mais usada em ciencia de dados?', '["Java","C++","Python","Swift"]'::jsonb, 2, 'Python e a linguagem mais popular em ciencia de dados por sua simplicidade e bibliotecas.', 1),
('q1-m5', 'm5', 'O que significa CI/CD?', '["Codigo Integrado/Codigo Distribuido","Integracao Continua/Entrega Continua","Computacao Inteligente/Cloud Digital","Controle Interno/Controle de Deploy"]'::jsonb, 1, 'CI/CD significa Continuous Integration/Continuous Delivery.', 0),
('q2-m5', 'm5', 'Qual o papel principal do DevOps?', '["Criar interfaces bonitas","Integrar dev e operacoes para entregas rapidas","Gerenciar equipes de vendas","Analisar metricas de marketing"]'::jsonb, 1, 'DevOps integra desenvolvimento e operacoes para entregas mais rapidas e confiaveis.', 1),
('q1-m6', 'm6', 'O que e phishing?', '["Um tipo de programacao","Um ataque que tenta enganar o usuario","Um protocolo de rede","Um tipo de servidor"]'::jsonb, 1, 'Phishing e um ataque de engenharia social que tenta enganar usuarios para roubar dados.', 0),
('q2-m6', 'm6', 'Qual e a melhor pratica para senhas?', '["Usar a mesma senha em tudo","Senhas curtas e simples","Senhas longas e unicas por servico","Anotar senhas em papel"]'::jsonb, 2, 'Senhas longas, unicas e gerenciadas por um password manager sao a melhor pratica.', 1),
('q1-m7', 'm7', 'O que faz um Product Manager?', '["Programa sistemas","Define a estrategia e prioridades do produto","Gerencia a infraestrutura","Cria designs visuais"]'::jsonb, 1, 'O PM define visao, estrategia e prioridades do produto.', 0),
('q2-m7', 'm7', 'O que sao metodologias ageis?', '["Formas de programar mais rapido","Abordagens iterativas de gestao de projetos","Ferramentas de design","Linguagens de programacao"]'::jsonb, 1, 'Metodologias ageis como Scrum e Kanban focam em entregas iterativas e feedback constante.', 1),
('q1-m8', 'm8', 'Qual o primeiro passo para escolher uma carreira em TI?', '["Escolher a linguagem mais popular","Fazer autoavaliacao de interesses e perfil","Buscar o maior salario","Copiar a escolha de um amigo"]'::jsonb, 1, 'Autoavaliacao ajuda a alinhar interesses pessoais com as areas de TI.', 0),
('q2-m8', 'm8', 'Por que networking e importante em TI?', '["Para conseguir senhas","Para trocar conhecimento e oportunidades","Para vender produtos","Nao e importante"]'::jsonb, 1, 'Networking permite trocar conhecimento, descobrir vagas e acelerar o crescimento profissional.', 1),
('q1-m9', 'm9', 'O que e hardware?', '["Programas de computador","Componentes fisicos do computador","Uma linguagem de programacao","Um sistema operacional"]'::jsonb, 1, 'Hardware sao os componentes fisicos como processador, memoria e disco.', 0),
('q2-m9', 'm9', 'Qual a relacao entre hardware e software?', '["Sao independentes","Software controla o hardware","Hardware nao precisa de software","Sao a mesma coisa"]'::jsonb, 1, 'O software da instrucoes para o hardware executar tarefas.', 1),
('q1-m10', 'm10', 'O que e DNS?', '["Um tipo de hardware","Sistema que traduz nomes de dominio em IPs","Uma linguagem de programacao","Um navegador web"]'::jsonb, 1, 'DNS (Domain Name System) traduz nomes como google.com em enderecos IP.', 0),
('q2-m10', 'm10', 'O que significa HTTP?', '["High Tech Transfer Protocol","HyperText Transfer Protocol","Hardware Transfer Protocol","Home Technology Protocol"]'::jsonb, 1, 'HTTP e o protocolo usado para transferir paginas web.', 1),
('q1-m11', 'm11', 'O que e cloud computing?', '["Computacao em computadores locais","Uso de recursos computacionais via internet","Um tipo de hardware","Uma linguagem de programacao"]'::jsonb, 1, 'Cloud computing e o uso de recursos computacionais remotos via internet.', 0),
('q2-m11', 'm11', 'O que e SaaS?', '["Software as a Service","System as a Server","Storage as a Solution","Security as a Standard"]'::jsonb, 0, 'SaaS significa Software as a Service — software acessado pela internet sem instalacao.', 1),
('q1-m12', 'm12', 'Qual a funcao de um sistema operacional?', '["Criar paginas web","Gerenciar hardware e software do computador","Projetar interfaces","Analisar dados"]'::jsonb, 1, 'O SO gerencia os recursos de hardware e fornece uma plataforma para software rodar.', 0),
('q2-m12', 'm12', 'Qual sistema operacional e open source?', '["Windows","macOS","Linux","iOS"]'::jsonb, 2, 'Linux e o principal sistema operacional de codigo aberto.', 1),
('q1-m13', 'm13', 'O que e autenticacao de dois fatores?', '["Usar duas senhas","Verificacao com dois metodos diferentes","Login em dois dispositivos","Duas contas de email"]'::jsonb, 1, 'Autenticacao de dois fatores usa dois metodos diferentes para verificar identidade.', 0),
('q2-m13', 'm13', 'O que e engenharia social?', '["Engenharia de software","Manipulacao psicologica para obter informacoes","Um curso universitario","Programacao de redes sociais"]'::jsonb, 1, 'Engenharia social manipula pessoas para revelar informacoes confidenciais.', 1),
('q1-m14', 'm14', 'O que e um roteador?', '["Um tipo de software","Dispositivo que direciona trafego de rede","Uma linguagem de programacao","Um tipo de processador"]'::jsonb, 1, 'Roteadores direcionam pacotes de dados entre redes.', 0),
('q2-m14', 'm14', 'O que e TCP/IP?', '["Um tipo de hardware","Conjunto de protocolos de comunicacao da internet","Uma linguagem de programacao","Um sistema operacional"]'::jsonb, 1, 'TCP/IP e o conjunto de protocolos que permite a comunicacao na internet.', 1),
('q1-m15', 'm15', 'O que e uma linguagem de programacao?', '["Um idioma falado por programadores","Conjunto de instrucoes para o computador","Um tipo de hardware","Um sistema operacional"]'::jsonb, 1, 'Linguagens de programacao sao conjuntos de instrucoes que o computador entende.', 0),
('q2-m15', 'm15', 'O que e um compilador?', '["Um editor de texto","Programa que traduz codigo fonte em codigo de maquina","Um tipo de rede","Um banco de dados"]'::jsonb, 1, 'Compiladores traduzem codigo legivel em instrucoes que o computador pode executar.', 1),
('q1-m16', 'm16', 'O que e uma variavel?', '["Um tipo de hardware","Espaco na memoria para armazenar dados","Uma funcao matematica","Um tipo de rede"]'::jsonb, 1, 'Variaveis sao espacos na memoria que armazenam valores que podem mudar.', 0),
('q2-m16', 'm16', 'Qual e um tipo de dado basico?', '["Pagina web","Booleano","Roteador","Sistema operacional"]'::jsonb, 1, 'Booleano (true/false) e um dos tipos de dados fundamentais em programacao.', 1),
('q1-m17', 'm17', 'Para que serve o if/else?', '["Repetir codigo","Tomar decisoes no programa","Criar variaveis","Conectar a internet"]'::jsonb, 1, 'if/else permite que o programa tome decisoes baseadas em condicoes.', 0),
('q2-m17', 'm17', 'O que e um operador de comparacao?', '["Simbolo que soma numeros","Simbolo que compara dois valores","Tipo de variavel","Tipo de funcao"]'::jsonb, 1, 'Operadores de comparacao (==, >, <, etc) comparam valores e retornam verdadeiro/falso.', 1),
('q1-m18', 'm18', 'O que e um loop?', '["Uma variavel especial","Estrutura que repete instrucoes","Um tipo de funcao","Um operador"]'::jsonb, 1, 'Loops repetem um bloco de codigo enquanto uma condicao for verdadeira.', 0),
('q2-m18', 'm18', 'Quando usar um loop for?', '["Quando nao sabe quantas vezes repetir","Quando sabe o numero exato de repeticoes","Nunca","Apenas para strings"]'::jsonb, 1, 'O loop for e ideal quando voce sabe quantas vezes precisa repetir.', 1),
('q1-m19', 'm19', 'O que e uma funcao?', '["Um tipo de variavel","Bloco de codigo reutilizavel","Um operador","Um loop especial"]'::jsonb, 1, 'Funcoes sao blocos de codigo organizados e reutilizaveis.', 0),
('q2-m19', 'm19', 'O que e um parametro?', '["Valor fixo","Valor passado para uma funcao executar","Tipo de loop","Nome do programa"]'::jsonb, 1, 'Parametros sao valores que voce passa para funcoes para customizar seu comportamento.', 1),
('q1-m20', 'm20', 'Qual o primeiro passo para criar um algoritmo?', '["Escrever codigo imediatamente","Planejar a logica antes de programar","Escolher a linguagem mais dificil","Copiar codigo da internet"]'::jsonb, 1, 'Planejar a logica (pseudocodigo, fluxograma) antes de programar e essencial.', 0),
('q2-m20', 'm20', 'O que e debugging?', '["Criar bugs","Processo de encontrar e corrigir erros","Tipo de programacao","Tecnica de design"]'::jsonb, 1, 'Debugging e o processo de identificar e corrigir erros no codigo.', 1);
