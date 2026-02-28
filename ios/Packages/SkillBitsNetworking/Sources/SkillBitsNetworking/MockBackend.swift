import Foundation
import SkillBitsCore

public actor MockBackendService {
    private var premiumEnabled = false
    private var progress = UserProgress(
        xp: 180,
        streakDays: 3,
        dailyGoal: .minutes15,
        studiedMinutesToday: 8,
        badges: [
            Badge(id: "b1", name: "Primeiro Passo", icon: "🚀", unlocked: true),
            Badge(id: "b2", name: "Quiz Master", icon: "⚡", unlocked: false)
        ]
    )

    // MARK: - Courses

    private var courses: [Course] = [
        Course(
            id: "c1",
            title: "Profissoes de T.I",
            shortDesc: "Descubra as principais carreiras de tecnologia e encontre sua trilha",
            description: "Explore as profissoes mais demandadas da area de tecnologia. De desenvolvimento de software a gestao de produtos, entenda o que cada carreira envolve no dia a dia, as habilidades necessarias e como escolher o caminho certo para voce.",
            emoji: "💼",
            category: "Carreira",
            level: "Iniciante",
            totalDuration: "8h 30min",
            color1: "#667EEA",
            color2: "#764BA2",
            accessTier: .free,
            instructor: "Ana Beatriz Costa",
            progress: 18,
            modules: [
                Module(
                    id: "m1",
                    title: "O que e TI e por que importa",
                    description: "Panorama do setor e impacto no mercado de trabalho",
                    duration: "1h",
                    lessons: [
                        Lesson(id: "l1", title: "A revolucao digital e o mercado de TI", duration: "10 min", status: .completed, progress: 100),
                        Lesson(id: "l2", title: "Areas de atuacao em tecnologia", duration: "12 min", status: .completed, progress: 100),
                        Lesson(id: "l3", title: "Habilidades valorizadas por recrutadores", duration: "11 min", status: .completed, progress: 100),
                        Lesson(id: "l4", title: "Como TI transforma todos os setores", duration: "9 min", status: .completed, progress: 100)
                    ],
                    quizAvailable: true,
                    quizCompleted: true,
                    quizScore: 90
                ),
                Module(
                    id: "m2",
                    title: "Desenvolvedor de Software",
                    description: "Front-end, back-end, mobile e full stack",
                    duration: "1h 15min",
                    lessons: [
                        Lesson(id: "l5", title: "O que faz um dev front-end", duration: "10 min", status: .completed, progress: 100),
                        Lesson(id: "l6", title: "Back-end e APIs", duration: "12 min", status: .inProgress, progress: 40),
                        Lesson(id: "l7", title: "Desenvolvimento mobile", duration: "11 min", status: .available),
                        Lesson(id: "l8", title: "Full stack: vale a pena?", duration: "10 min", status: .locked)
                    ],
                    quizAvailable: true
                ),
                Module(
                    id: "m3",
                    title: "Designer de UX/UI",
                    description: "Pesquisa, prototipacao e design de interfaces",
                    duration: "1h 10min",
                    lessons: [
                        Lesson(id: "l9", title: "Diferenca entre UX e UI", duration: "10 min", status: .locked),
                        Lesson(id: "l10", title: "Ferramentas do designer", duration: "12 min", status: .locked),
                        Lesson(id: "l11", title: "Portfolio e mercado de trabalho", duration: "11 min", status: .locked)
                    ],
                    quizAvailable: true
                ),
                Module(
                    id: "m4",
                    title: "Analista e Cientista de Dados",
                    description: "Dados como base para decisoes estrategicas",
                    duration: "1h",
                    lessons: [
                        Lesson(id: "l12", title: "O que faz um analista de dados", duration: "10 min", status: .locked),
                        Lesson(id: "l13", title: "Cientista de dados e machine learning", duration: "13 min", status: .locked),
                        Lesson(id: "l14", title: "Ferramentas e linguagens para dados", duration: "11 min", status: .locked)
                    ],
                    quizAvailable: true
                ),
                Module(
                    id: "m5",
                    title: "DevOps e Engenheiro de Infraestrutura",
                    description: "Automacao, deploy e confiabilidade",
                    duration: "1h",
                    lessons: [
                        Lesson(id: "l15", title: "O papel do DevOps no time", duration: "10 min", status: .locked),
                        Lesson(id: "l16", title: "CI/CD e automacao", duration: "12 min", status: .locked),
                        Lesson(id: "l17", title: "Cloud e infraestrutura moderna", duration: "11 min", status: .locked)
                    ],
                    quizAvailable: true
                ),
                Module(
                    id: "m6",
                    title: "Seguranca da Informacao",
                    description: "Protecao de sistemas, redes e dados",
                    duration: "55min",
                    lessons: [
                        Lesson(id: "l18", title: "O que faz um profissional de seguranca", duration: "10 min", status: .locked),
                        Lesson(id: "l19", title: "Tipos de ameacas e ataques", duration: "12 min", status: .locked),
                        Lesson(id: "l20", title: "Certificacoes e carreira", duration: "9 min", status: .locked)
                    ],
                    quizAvailable: true
                ),
                Module(
                    id: "m7",
                    title: "Gestao de TI e Product Manager",
                    description: "Lideranca tecnica e gestao de produtos digitais",
                    duration: "1h",
                    lessons: [
                        Lesson(id: "l21", title: "Gestor de TI vs Product Manager", duration: "10 min", status: .locked),
                        Lesson(id: "l22", title: "Metodologias ageis no dia a dia", duration: "12 min", status: .locked),
                        Lesson(id: "l23", title: "De tecnico a lider: transicao de carreira", duration: "11 min", status: .locked)
                    ],
                    quizAvailable: true
                ),
                Module(
                    id: "m8",
                    title: "Como escolher sua trilha",
                    description: "Autoavaliacao e proximos passos na carreira",
                    duration: "1h 10min",
                    lessons: [
                        Lesson(id: "l24", title: "Autoavaliacao: perfil e interesses", duration: "10 min", status: .locked),
                        Lesson(id: "l25", title: "Roadmap de estudo por area", duration: "13 min", status: .locked),
                        Lesson(id: "l26", title: "Comunidades e networking", duration: "10 min", status: .locked),
                        Lesson(id: "l27", title: "Primeiro projeto pratico", duration: "12 min", status: .locked)
                    ],
                    quizAvailable: true
                )
            ]
        ),

        Course(
            id: "c2",
            title: "Conceitos Basicos de T.I",
            shortDesc: "Entenda como funcionam computadores, internet e seguranca digital",
            description: "Uma base solida para quem esta comecando. Aprenda sobre hardware, software, internet, cloud, sistemas operacionais e seguranca digital de forma acessivel e pratica.",
            emoji: "🖥️",
            category: "Fundamentos",
            level: "Iniciante",
            totalDuration: "5h 40min",
            color1: "#40E0D0",
            color2: "#2D95DA",
            accessTier: .free,
            instructor: "Carlos Eduardo Lima",
            progress: 0,
            modules: [
                Module(
                    id: "m9",
                    title: "Hardware e Software",
                    description: "Componentes fisicos e logicos de um computador",
                    duration: "50min",
                    lessons: [
                        Lesson(id: "l28", title: "O que e hardware", duration: "10 min", status: .available),
                        Lesson(id: "l29", title: "O que e software", duration: "9 min", status: .locked),
                        Lesson(id: "l30", title: "Como hardware e software trabalham juntos", duration: "11 min", status: .locked)
                    ],
                    quizAvailable: true,
                    accessTier: .free
                ),
                Module(
                    id: "m10",
                    title: "Como a Internet funciona",
                    description: "Protocolos, servidores e a web no dia a dia",
                    duration: "55min",
                    lessons: [
                        Lesson(id: "l31", title: "O caminho de um site ate voce", duration: "11 min", status: .locked),
                        Lesson(id: "l32", title: "HTTP, DNS e IP explicados", duration: "12 min", status: .locked)
                    ],
                    quizAvailable: true,
                    accessTier: .premium
                ),
                Module(
                    id: "m11",
                    title: "Cloud Computing",
                    description: "Servicos na nuvem e por que sao tao usados",
                    duration: "50min",
                    lessons: [
                        Lesson(id: "l33", title: "O que e cloud computing", duration: "10 min", status: .locked),
                        Lesson(id: "l34", title: "IaaS, PaaS e SaaS", duration: "11 min", status: .locked)
                    ],
                    quizAvailable: true,
                    accessTier: .premium
                ),
                Module(
                    id: "m12",
                    title: "Sistemas Operacionais",
                    description: "Windows, Linux e macOS no contexto de TI",
                    duration: "55min",
                    lessons: [
                        Lesson(id: "l35", title: "O que faz um sistema operacional", duration: "10 min", status: .locked),
                        Lesson(id: "l36", title: "Windows vs Linux vs macOS", duration: "12 min", status: .locked),
                        Lesson(id: "l37", title: "Terminal e linha de comando", duration: "11 min", status: .locked)
                    ],
                    quizAvailable: true,
                    accessTier: .premium
                ),
                Module(
                    id: "m13",
                    title: "Seguranca digital no dia a dia",
                    description: "Proteja seus dados e dispositivos pessoais",
                    duration: "50min",
                    lessons: [
                        Lesson(id: "l38", title: "Senhas seguras e autenticacao", duration: "10 min", status: .locked),
                        Lesson(id: "l39", title: "Phishing e engenharia social", duration: "12 min", status: .locked)
                    ],
                    quizAvailable: true,
                    accessTier: .premium
                ),
                Module(
                    id: "m14",
                    title: "Redes",
                    description: "Fundamentos de redes de computadores",
                    duration: "1h",
                    lessons: [
                        Lesson(id: "l40", title: "O que e uma rede de computadores", duration: "10 min", status: .locked),
                        Lesson(id: "l41", title: "Wi-Fi, roteadores e switches", duration: "12 min", status: .locked),
                        Lesson(id: "l42", title: "Modelo TCP/IP simplificado", duration: "11 min", status: .locked)
                    ],
                    quizAvailable: true,
                    accessTier: .premium
                )
            ]
        ),

        Course(
            id: "c3",
            title: "Conceitos Basicos de Programacao",
            shortDesc: "Seus primeiros passos no mundo da programacao",
            description: "Aprenda os fundamentos da logica de programacao de forma pratica. De variaveis a funcoes, construa seu primeiro algoritmo e desenvolva o pensamento computacional necessario para qualquer linguagem.",
            emoji: "🧑‍💻",
            category: "Programacao",
            level: "Iniciante",
            totalDuration: "4h 30min",
            color1: "#F7971E",
            color2: "#FFD200",
            accessTier: .premium,
            instructor: "Mariana Santos",
            progress: 0,
            modules: [
                Module(
                    id: "m15",
                    title: "O que e programacao",
                    description: "Entenda o que significa programar e como o computador executa instrucoes",
                    duration: "45min",
                    lessons: [
                        Lesson(id: "l43", title: "Linguagens e compiladores", duration: "10 min", status: .available),
                        Lesson(id: "l44", title: "Seu primeiro Hello World", duration: "11 min", status: .locked),
                        Lesson(id: "l45", title: "Como pensar como um programador", duration: "10 min", status: .locked)
                    ],
                    quizAvailable: true,
                    accessTier: .premium
                ),
                Module(
                    id: "m16",
                    title: "Variaveis e tipos",
                    description: "Armazene e manipule informacoes no seu programa",
                    duration: "50min",
                    lessons: [
                        Lesson(id: "l46", title: "O que sao variaveis", duration: "10 min", status: .locked),
                        Lesson(id: "l47", title: "Tipos de dados: texto, numero e booleano", duration: "12 min", status: .locked),
                        Lesson(id: "l48", title: "Operacoes basicas com variaveis", duration: "11 min", status: .locked)
                    ],
                    quizAvailable: true,
                    accessTier: .premium
                ),
                Module(
                    id: "m17",
                    title: "Condicoes",
                    description: "Faca seu programa tomar decisoes",
                    duration: "45min",
                    lessons: [
                        Lesson(id: "l49", title: "If, else e else if", duration: "11 min", status: .locked),
                        Lesson(id: "l50", title: "Operadores de comparacao", duration: "10 min", status: .locked)
                    ],
                    quizAvailable: true,
                    accessTier: .premium
                ),
                Module(
                    id: "m18",
                    title: "Loops",
                    description: "Repita acoes de forma eficiente",
                    duration: "45min",
                    lessons: [
                        Lesson(id: "l51", title: "While e for", duration: "12 min", status: .locked),
                        Lesson(id: "l52", title: "Quando usar cada tipo de loop", duration: "10 min", status: .locked)
                    ],
                    quizAvailable: true,
                    accessTier: .premium
                ),
                Module(
                    id: "m19",
                    title: "Funcoes",
                    description: "Organize e reutilize blocos de codigo",
                    duration: "50min",
                    lessons: [
                        Lesson(id: "l53", title: "Criando e chamando funcoes", duration: "11 min", status: .locked),
                        Lesson(id: "l54", title: "Parametros e retorno", duration: "12 min", status: .locked)
                    ],
                    quizAvailable: true,
                    accessTier: .premium
                ),
                Module(
                    id: "m20",
                    title: "Primeiro algoritmo",
                    description: "Junte tudo e construa seu primeiro programa completo",
                    duration: "55min",
                    lessons: [
                        Lesson(id: "l55", title: "Planejando o algoritmo", duration: "10 min", status: .locked),
                        Lesson(id: "l56", title: "Implementando passo a passo", duration: "13 min", status: .locked),
                        Lesson(id: "l57", title: "Testando e corrigindo erros", duration: "12 min", status: .locked)
                    ],
                    quizAvailable: true,
                    accessTier: .premium
                )
            ]
        )
    ]

    // MARK: - Lesson Content

    private let lessonContentById: [String: LessonContent] = [
        "l1": LessonContent(
            lessonId: "l1",
            title: "A revolucao digital e o mercado de TI",
            readTime: "10 min",
            content: [
                .heading("A tecnologia mudou tudo — e continua mudando"),
                .paragraph("A area de Tecnologia da Informacao (TI) deixou de ser um departamento de suporte para se tornar o motor de inovacao de praticamente todos os setores. De saude a agricultura, de financas a entretenimento, empresas dependem de profissionais de tecnologia para crescer, inovar e resolver problemas complexos."),
                .heading2("O que e TI, afinal?"),
                .paragraph("TI e o conjunto de recursos tecnologicos e computacionais usados para criar, armazenar, processar e transmitir informacoes. Isso inclui hardware, software, redes, bancos de dados e muito mais."),
                .list([
                    "O setor de TI cresce 3x mais rapido que a economia geral",
                    "Existem mais vagas abertas do que profissionais qualificados",
                    "Salarios iniciais estao entre os mais altos do mercado",
                    "Trabalho remoto e flexibilidade sao comuns na area"
                ]),
                .heading2("Por que aprender sobre TI agora?"),
                .paragraph("Independente da sua area de atuacao, entender tecnologia se tornou uma habilidade essencial. Mesmo que voce nao queira programar, saber como sistemas funcionam, como dados sao usados e como a internet opera vai te dar uma vantagem competitiva enorme."),
                .callout(title: "Dado importante", text: "Segundo pesquisas recentes, mais de 70% das empresas brasileiras relatam dificuldade em contratar profissionais de TI qualificados. Isso significa oportunidade para quem se preparar.")
            ]
        ),
        "l2": LessonContent(
            lessonId: "l2",
            title: "Areas de atuacao em tecnologia",
            readTime: "12 min",
            content: [
                .heading("Um universo de possibilidades"),
                .paragraph("Quando falamos em 'trabalhar com tecnologia', estamos falando de dezenas de carreiras diferentes. Cada uma exige habilidades especificas e oferece desafios unicos. Vamos conhecer as principais areas."),
                .heading2("Desenvolvimento de Software"),
                .paragraph("Programadores criam os sistemas, apps e sites que usamos todos os dias. Dentro do desenvolvimento, existem especializacoes como front-end (interface), back-end (logica e servidores) e mobile (apps para celular)."),
                .heading2("Dados e Inteligencia Artificial"),
                .paragraph("Analistas e cientistas de dados transformam grandes volumes de informacao em insights para decisoes estrategicas. Com o crescimento de IA, essa area esta em plena expansao."),
                .heading2("Infraestrutura e DevOps"),
                .paragraph("Profissionais de infra cuidam dos servidores, redes e ambientes onde os sistemas rodam. DevOps conecta desenvolvimento e operacoes para entregas mais rapidas e confiaveis."),
                .list([
                    "Desenvolvimento: front-end, back-end, mobile, full stack",
                    "Design: UX research, UI design, design systems",
                    "Dados: analise de dados, ciencia de dados, engenharia de dados",
                    "Infraestrutura: DevOps, SRE, cloud engineering",
                    "Seguranca: pentest, compliance, resposta a incidentes",
                    "Gestao: product manager, tech lead, CTO"
                ]),
                .callout(title: "Dica", text: "Nao se preocupe em escolher agora. Ao longo deste curso, vamos explorar cada area em profundidade para que voce possa decidir com mais clareza.")
            ]
        ),
        "l3": LessonContent(
            lessonId: "l3",
            title: "Habilidades valorizadas por recrutadores",
            readTime: "11 min",
            content: [
                .heading("O que as empresas realmente procuram"),
                .paragraph("Alem de conhecimento tecnico, empresas de tecnologia valorizam um conjunto de habilidades comportamentais e praticas que fazem a diferenca no dia a dia."),
                .heading2("Habilidades tecnicas (hard skills)"),
                .list([
                    "Logica de programacao e pensamento algoritmico",
                    "Conhecimento de pelo menos uma linguagem de programacao",
                    "Entendimento basico de bancos de dados",
                    "Familiaridade com controle de versao (Git)",
                    "Nocoes de redes e sistemas operacionais"
                ]),
                .heading2("Habilidades comportamentais (soft skills)"),
                .list([
                    "Resolucao de problemas: decomposicao e analise critica",
                    "Comunicacao clara: saber explicar ideias tecnicas para nao-tecnicos",
                    "Aprendizado continuo: a tecnologia muda rapido",
                    "Trabalho em equipe: metodologias ageis exigem colaboracao constante"
                ]),
                .paragraph("O profissional que combina habilidades tecnicas solidas com boa comunicacao e capacidade de adaptacao tem as melhores oportunidades no mercado."),
                .callout(title: "Mito desfeito", text: "Voce nao precisa ser genio em matematica para trabalhar com TI. A maioria das funcoes exige logica e persistencia, nao calculo avancado.")
            ]
        ),
        "l4": LessonContent(
            lessonId: "l4",
            title: "Como TI transforma todos os setores",
            readTime: "9 min",
            content: [
                .heading("TI nao e so para empresas de tecnologia"),
                .paragraph("Todos os setores da economia estao passando por uma transformacao digital. Profissionais de TI sao necessarios em hospitais, bancos, fazendas, escolas e muito mais."),
                .heading2("Exemplos praticos"),
                .list([
                    "Saude: prontuarios eletronicos, telemedicina, IA para diagnosticos",
                    "Financas: fintechs, pagamentos digitais, blockchain",
                    "Educacao: plataformas de ensino online, gamificacao",
                    "Agricultura: sensores IoT, drones, analise de solo por satelite",
                    "Varejo: e-commerce, personalizacao por dados, logistica inteligente"
                ]),
                .paragraph("Isso significa que, alem de trabalhar em empresas de tecnologia, voce pode aplicar seus conhecimentos de TI no setor que mais te interessa."),
                .callout(title: "Reflexao", text: "Pense em uma area que voce gosta. Como a tecnologia esta transformando esse setor? Essa pode ser a intersecao perfeita para sua carreira.")
            ]
        ),
        "l5": LessonContent(
            lessonId: "l5",
            title: "O que faz um dev front-end",
            readTime: "10 min",
            content: [
                .heading("A interface que o usuario ve e toca"),
                .paragraph("O desenvolvedor front-end e responsavel por transformar designs em interfaces funcionais. Tudo que voce ve em um site ou app — botoes, menus, animacoes — foi construido por um front-end."),
                .heading2("Tecnologias principais"),
                .list([
                    "HTML: estrutura do conteudo",
                    "CSS: estilizacao e layout",
                    "JavaScript: interatividade e logica",
                    "Frameworks: React, Vue, Angular, SwiftUI"
                ]),
                .heading2("O dia a dia"),
                .paragraph("Um front-end recebe designs (geralmente do Figma) e os transforma em codigo. Trabalha em estreita colaboracao com designers e desenvolvedores back-end para garantir que a experiencia do usuario seja fluida e performatica."),
                .code(language: "html", text: "<button class=\"btn-primary\">\n  Iniciar curso\n</button>"),
                .callout(title: "Carreira", text: "Front-end e uma das portas de entrada mais populares em TI. Com HTML, CSS e JavaScript voce ja consegue construir projetos impressionantes para seu portfolio.")
            ]
        )
    ]

    public init() {}

    // MARK: - Course API

    public func listCourses() -> [Course] { courses }

    public func course(id: String) throws -> Course {
        guard let course = courses.first(where: { $0.id == id }) else { throw NetworkError.notFound }
        return course
    }

    // MARK: - Lesson Content

    public func lessonContent(lessonId: String) -> LessonContent {
        lessonContentById[lessonId] ?? LessonContent(
            lessonId: lessonId,
            title: "Conteudo em preparacao",
            readTime: "9 min",
            content: [
                .heading("Aula em atualizacao"),
                .paragraph("Este conteudo ainda sera expandido nas proximas iteracoes de produto."),
                .list(["Resumo da aula", "Ponto principal", "Proximo passo recomendado"])
            ]
        )
    }

    // MARK: - Quiz

    public func quiz(moduleId: String) -> [QuizQuestion] {
        if moduleId == "m1" {
            return quizModule1
        }
        return [
            QuizQuestion(id: "q1-\(moduleId)", question: "Qual beneficio principal de estudar em micro-licoes?", options: ["Menos consistencia", "Maior aderencia diaria", "Mais tempo por aula"], correctIndex: 1, explanation: "Licoes curtas facilitam criar e manter habito de estudo."),
            QuizQuestion(id: "q2-\(moduleId)", question: "O que e mais importante para comecar na area de TI?", options: ["Ter diploma em exatas", "Curiosidade e persistencia", "Saber matematica avancada"], correctIndex: 1, explanation: "Curiosidade e vontade de aprender sao as bases para qualquer carreira em tecnologia.")
        ]
    }

    private let quizModule1: [QuizQuestion] = [
        QuizQuestion(id: "q1-m1", question: "Qual setor NAO e impactado significativamente por TI?", options: ["Saude", "Agricultura", "Financas", "Nenhum — todos sao impactados"], correctIndex: 3, explanation: "Todos os setores da economia sao transformados pela tecnologia da informacao."),
        QuizQuestion(id: "q2-m1", question: "O que diferencia um desenvolvedor front-end de um back-end?", options: ["Front-end trabalha com servidores", "Back-end cria interfaces visuais", "Front-end cria a interface que o usuario ve", "Nao ha diferenca"], correctIndex: 2, explanation: "O front-end e responsavel pela interface do usuario, enquanto o back-end cuida da logica e servidores."),
        QuizQuestion(id: "q3-m1", question: "Qual habilidade comportamental e mais valorizada em TI?", options: ["Memorizar codigos", "Trabalho isolado", "Resolucao de problemas", "Velocidade de digitacao"], correctIndex: 2, explanation: "Saber decompor e resolver problemas e a habilidade mais buscada por recrutadores."),
        QuizQuestion(id: "q4-m1", question: "O que significa a sigla TI?", options: ["Tecnologia Industrial", "Tecnologia da Informacao", "Trabalho Integrado", "Tecnica de Inovacao"], correctIndex: 1, explanation: "TI significa Tecnologia da Informacao."),
        QuizQuestion(id: "q5-m1", question: "Qual afirmacao sobre o mercado de TI e verdadeira?", options: ["Ha mais profissionais do que vagas", "Salarios sao geralmente baixos", "Existem mais vagas do que profissionais qualificados", "Trabalho remoto nao e comum"], correctIndex: 2, explanation: "O deficit de profissionais qualificados e uma realidade global no setor de TI."),
        QuizQuestion(id: "q6-m1", question: "O que faz um profissional de DevOps?", options: ["Cria interfaces de usuario", "Conecta desenvolvimento e operacoes para entregas rapidas", "Analisa dados de marketing", "Gerencia equipes de vendas"], correctIndex: 1, explanation: "DevOps integra desenvolvimento e operacoes para melhorar a velocidade e confiabilidade das entregas."),
        QuizQuestion(id: "q7-m1", question: "Qual e uma porta de entrada popular para iniciar em TI?", options: ["Seguranca da informacao avancada", "Gestao de projetos", "Desenvolvimento front-end", "Engenharia de dados"], correctIndex: 2, explanation: "Front-end e acessivel para iniciantes e permite criar projetos visiveis rapidamente."),
        QuizQuestion(id: "q8-m1", question: "Git e uma ferramenta usada para:", options: ["Design de interfaces", "Controle de versao de codigo", "Gerenciamento de emails", "Criacao de bancos de dados"], correctIndex: 1, explanation: "Git e o sistema de controle de versao mais usado por desenvolvedores."),
        QuizQuestion(id: "q9-m1", question: "O que e uma fintech?", options: ["Uma fazenda tecnologica", "Uma empresa de tecnologia financeira", "Um tipo de hardware", "Uma linguagem de programacao"], correctIndex: 1, explanation: "Fintechs sao empresas que usam tecnologia para inovar em servicos financeiros."),
        QuizQuestion(id: "q10-m1", question: "Qual combinacao traz mais oportunidades no mercado?", options: ["Apenas habilidades tecnicas", "Apenas habilidades comportamentais", "Habilidades tecnicas + comunicacao + adaptacao", "Apenas certificacoes"], correctIndex: 2, explanation: "A combinacao de hard skills com soft skills e o que abre as melhores portas no mercado.")
    ]

    public func submit(moduleId: String, answers: [Int], quizFirst: Bool) -> QuizResult {
        let questions = quiz(moduleId: moduleId)
        let correct = zip(questions, answers).filter { $0.0.correctIndex == $0.1 }.count
        let score = Int((Double(correct) / Double(max(questions.count, 1))) * 100)
        var gained = 30
        if score == 100 { gained += 50 }
        if quizFirst && score == 100 { gained += 75 }
        progress.xp += gained

        let passed = score >= 70

        if passed {
            for ci in courses.indices {
                if let mi = courses[ci].modules.firstIndex(where: { $0.id == moduleId }) {
                    courses[ci].modules[mi].quizCompleted = true
                    courses[ci].modules[mi].quizScore = score

                    let nextMi = mi + 1
                    if nextMi < courses[ci].modules.count {
                        if let firstLocked = courses[ci].modules[nextMi].lessons.firstIndex(where: { $0.status == .locked }) {
                            if firstLocked == 0 {
                                courses[ci].modules[nextMi].lessons[0].status = .available
                            }
                        } else if courses[ci].modules[nextMi].lessons.first?.status == .locked {
                            courses[ci].modules[nextMi].lessons[0].status = .available
                        }
                    }

                    recalculateProgress(courseIndex: ci)
                    break
                }
            }
        }

        return QuizResult(moduleId: moduleId, score: score, correctCount: correct, total: questions.count, passed: passed, quizFirst: quizFirst)
    }

    // MARK: - Guided Review

    public func guidedReview(moduleId: String) -> [GuidedReviewPoint] {
        if moduleId == "m1" {
            return [
                GuidedReviewPoint(id: "gr1-m1", topic: "O mercado de TI", explanation: "Revise por que o setor de TI cresce mais rapido que a economia geral e o que isso significa para profissionais.", lessonId: "l1"),
                GuidedReviewPoint(id: "gr2-m1", topic: "Areas de atuacao", explanation: "Relembre as principais areas — desenvolvimento, dados, infra, seguranca e gestao — e suas diferencas.", lessonId: "l2"),
                GuidedReviewPoint(id: "gr3-m1", topic: "Hard skills vs Soft skills", explanation: "Revise quais habilidades tecnicas e comportamentais sao mais valorizadas por recrutadores.", lessonId: "l3")
            ]
        }
        return [
            GuidedReviewPoint(id: "gr1-\(moduleId)", topic: "Conceitos fundamentais", explanation: "Revise os conceitos-chave abordados neste modulo.", lessonId: "l1"),
            GuidedReviewPoint(id: "gr2-\(moduleId)", topic: "Aplicacao pratica", explanation: "Releia como aplicar os conceitos no dia a dia.", lessonId: "l2")
        ]
    }

    // MARK: - Lesson Completion

    public func completeLesson(courseId: String, moduleId: String, lessonId: String) {
        guard let courseIdx = courses.firstIndex(where: { $0.id == courseId }) else { return }
        guard let moduleIdx = courses[courseIdx].modules.firstIndex(where: { $0.id == moduleId }) else { return }
        guard let lessonIdx = courses[courseIdx].modules[moduleIdx].lessons.firstIndex(where: { $0.id == lessonId }) else { return }

        courses[courseIdx].modules[moduleIdx].lessons[lessonIdx].status = .completed
        courses[courseIdx].modules[moduleIdx].lessons[lessonIdx].progress = 100
        if lessonIdx + 1 < courses[courseIdx].modules[moduleIdx].lessons.count {
            let nextStatus = courses[courseIdx].modules[moduleIdx].lessons[lessonIdx + 1].status
            if nextStatus == .locked {
                courses[courseIdx].modules[moduleIdx].lessons[lessonIdx + 1].status = .available
            }
        }

        recalculateProgress(courseIndex: courseIdx)
        progress.studiedMinutesToday = min(progress.dailyGoal.rawValue, progress.studiedMinutesToday + 12)
        progress.xp += 20
    }

    // MARK: - Progress

    public func fetchProgress() -> UserProgress { progress }
    public func saveProgress(_ value: UserProgress) { progress = value }
    public func setPremium(_ enabled: Bool) { premiumEnabled = enabled }
    public func isPremium() -> Bool { premiumEnabled }

    // MARK: - Helpers

    private func recalculateProgress(courseIndex ci: Int) {
        let totalLessons = courses[ci].modules.flatMap(\.lessons).count
        let completedLessons = courses[ci].modules.flatMap(\.lessons).filter { $0.status == .completed }.count
        courses[ci].progress = Int((Double(completedLessons) / Double(max(1, totalLessons))) * 100)
    }
}
