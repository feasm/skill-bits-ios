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

    private var courses: [Course] = [
        Course(
            id: "c1",
            title: "Docker do Zero ao Deploy",
            shortDesc: "Containers na prática para desenvolvimento e produção",
            description: "Aprenda Docker com foco em fluxo real de desenvolvimento, imagens otimizadas e deploy com docker-compose.",
            emoji: "🐳",
            category: "DevOps",
            level: "Iniciante",
            totalDuration: "6h 20min",
            color1: "#40E0D0",
            color2: "#2D95DA",
            accessTier: .free,
            progress: 40,
            modules: [
                Module(
                    id: "m1",
                    title: "Fundamentos de Containers",
                    description: "Entenda imagens, containers e ciclo de vida",
                    duration: "2h 10min",
                    lessons: [
                        Lesson(id: "l1", title: "O que e container e por que usar", duration: "11 min", status: .completed, progress: 100),
                        Lesson(id: "l2", title: "Imagens, camadas e Dockerfile", duration: "14 min", status: .completed, progress: 100),
                        Lesson(id: "l3", title: "Build e run na prática", duration: "16 min", status: .inProgress, progress: 45),
                        Lesson(id: "l4", title: "Volumes, bind mounts e persistência", duration: "13 min", status: .available),
                        Lesson(id: "l5", title: "Rede entre containers", duration: "12 min", status: .available)
                    ],
                    quizAvailable: true
                ),
                Module(
                    id: "m2",
                    title: "Docker Compose para times",
                    description: "Suba stack completa com banco e API",
                    duration: "2h",
                    lessons: [
                        Lesson(id: "l6", title: "Sintaxe do compose.yaml", duration: "12 min", status: .locked),
                        Lesson(id: "l7", title: "Orquestrando API + banco + cache", duration: "15 min", status: .locked),
                        Lesson(id: "l8", title: "Healthcheck e observabilidade", duration: "13 min", status: .locked)
                    ],
                    quizAvailable: true
                ),
                Module(
                    id: "m3",
                    title: "Boas práticas de produção",
                    description: "Segurança, tamanho de imagem e deploy",
                    duration: "2h 10min",
                    lessons: [
                        Lesson(id: "l9", title: "Multi-stage build", duration: "12 min", status: .locked),
                        Lesson(id: "l10", title: "Hardening de containers", duration: "14 min", status: .locked),
                        Lesson(id: "l11", title: "Deploy em VPS e cloud", duration: "16 min", status: .locked)
                    ],
                    quizAvailable: true
                )
            ]
        ),
        Course(
            id: "c2",
            title: "Python para Data Science",
            shortDesc: "Da linguagem aos primeiros insights com dados",
            description: "Uma trilha rápida para quem quer começar em dados com Python, pandas e visualização.",
            emoji: "🐍",
            category: "Data Science",
            level: "Iniciante",
            totalDuration: "5h 10min",
            color1: "#F7971E",
            color2: "#FFD200",
            accessTier: .premium,
            progress: 0,
            modules: [
                Module(
                    id: "m4",
                    title: "Python aplicado",
                    description: "Tipos, loops e funções para dados",
                    duration: "1h 45min",
                    lessons: [
                        Lesson(id: "l12", title: "Setup do ambiente para dados", duration: "10 min", status: .available),
                        Lesson(id: "l13", title: "Estruturas e funções úteis", duration: "13 min", status: .locked),
                        Lesson(id: "l14", title: "Leitura de CSV com pandas", duration: "11 min", status: .locked)
                    ],
                    quizAvailable: true
                )
            ]
        ),
        Course(
            id: "c3",
            title: "AWS Foundations",
            shortDesc: "Conceitos essenciais de cloud para iniciantes",
            description: "Compreenda serviços base da AWS e monte arquitetura simples, segura e escalável.",
            emoji: "☁️",
            category: "Cloud",
            level: "Intermediario",
            totalDuration: "4h 30min",
            color1: "#FF6B35",
            color2: "#F7C59F",
            accessTier: .premium,
            progress: 0,
            modules: [
                Module(
                    id: "m5",
                    title: "Core services",
                    description: "EC2, S3, IAM e VPC sem complicação",
                    duration: "1h 30min",
                    lessons: [
                        Lesson(id: "l15", title: "Regioes e zonas de disponibilidade", duration: "9 min", status: .available),
                        Lesson(id: "l16", title: "S3 na prática", duration: "12 min", status: .locked)
                    ],
                    quizAvailable: true
                )
            ]
        ),
        Course(
            id: "c4",
            title: "React para Frontend Moderno",
            shortDesc: "Componentes reutilizáveis e estado sem dor",
            description: "Aprenda React focando em construção de interfaces reais e arquitetura de componentes.",
            emoji: "⚛️",
            category: "Frontend",
            level: "Iniciante",
            totalDuration: "4h 45min",
            color1: "#667EEA",
            color2: "#764BA2",
            accessTier: .free,
            progress: 15,
            modules: [
                Module(
                    id: "m6",
                    title: "Componentização eficiente",
                    description: "Props, estado local e composição",
                    duration: "1h 40min",
                    lessons: [
                        Lesson(id: "l17", title: "Pensando em componentes", duration: "10 min", status: .completed, progress: 100),
                        Lesson(id: "l18", title: "Estado e eventos", duration: "13 min", status: .inProgress, progress: 20),
                        Lesson(id: "l19", title: "Listas e performance", duration: "12 min", status: .available)
                    ],
                    quizAvailable: true
                )
            ]
        ),
        Course(
            id: "c5",
            title: "Redes para Infra",
            shortDesc: "TCP/IP, DNS e troubleshooting para carreira DevOps",
            description: "Domine conceitos de rede essenciais para trabalhar com infraestrutura moderna.",
            emoji: "🌐",
            category: "Infra",
            level: "Intermediario",
            totalDuration: "3h 50min",
            color1: "#11998E",
            color2: "#38EF7D",
            accessTier: .premium,
            progress: 0,
            modules: [
                Module(
                    id: "m7",
                    title: "Base de redes",
                    description: "Entenda pacotes, portas e latência",
                    duration: "1h 20min",
                    lessons: [
                        Lesson(id: "l20", title: "Modelo TCP/IP", duration: "9 min", status: .available),
                        Lesson(id: "l21", title: "DNS e resolução de nomes", duration: "12 min", status: .locked),
                        Lesson(id: "l22", title: "Troubleshooting com ping e traceroute", duration: "11 min", status: .locked)
                    ],
                    quizAvailable: true
                )
            ]
        )
    ]

    private let lessonContentById: [String: LessonContent] = [
        "l1": LessonContent(
            lessonId: "l1",
            title: "O que e container e por que usar",
            readTime: "11 min",
            content: [
                .heading("Containers resolvem o problema do \"na minha maquina funciona\""),
                .paragraph("Container e uma unidade leve e portavel que empacota aplicacao e dependencias. Isso garante que seu app rode da mesma forma no notebook, CI e producao."),
                .list([
                    "Isolamento por processo e filesystem",
                    "Inicializacao rapida em segundos",
                    "Padronizacao entre ambientes"
                ]),
                .heading2("Imagem x Container"),
                .paragraph("A imagem e um template imutavel em camadas. O container e a instancia em execucao dessa imagem, com estado de runtime."),
                .code(language: "bash", text: "docker pull nginx:alpine\ndocker run --name web -p 8080:80 nginx:alpine"),
                .callout(title: "Boa pratica", text: "Prefira tags de versao explicitas e evite latest em producao para builds reproduziveis.")
            ]
        ),
        "l2": LessonContent(
            lessonId: "l2",
            title: "Imagens, camadas e Dockerfile",
            readTime: "14 min",
            content: [
                .heading("Cada instrução cria uma camada"),
                .paragraph("Camadas permitem cache de build. Se voce muda apenas uma linha no final do Dockerfile, as camadas anteriores podem ser reaproveitadas."),
                .list([
                    "Comece com imagem base pequena",
                    "Copie apenas arquivos necessarios",
                    "Agrupe comandos para reduzir camadas"
                ]),
                .code(language: "dockerfile", text: "FROM node:20-alpine\nWORKDIR /app\nCOPY package*.json ./\nRUN npm ci --omit=dev\nCOPY . .\nCMD [\"node\", \"server.js\"]")
            ]
        ),
        "l3": LessonContent(
            lessonId: "l3",
            title: "Build e run na prática",
            readTime: "16 min",
            content: [
                .heading("Fluxo minimo para subir um app"),
                .paragraph("Primeiro voce gera a imagem com docker build. Depois cria um container com docker run configurando portas, variaveis e volumes."),
                .heading2("Comandos essenciais"),
                .code(language: "bash", text: "docker build -t skillbits-api:1.0 .\ndocker run --rm -p 3000:3000 --env NODE_ENV=production skillbits-api:1.0"),
                .paragraph("Use --rm para remover containers ao parar e manter o ambiente limpo durante desenvolvimento."),
                .callout(title: "Debug", text: "Se a porta estiver ocupada, troque o host port: -p 3001:3000")
            ]
        )
    ]

    public init() {}

    public func listCourses() -> [Course] { courses }

    public func course(id: String) throws -> Course {
        guard let course = courses.first(where: { $0.id == id }) else { throw NetworkError.notFound }
        return course
    }

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

    public func quiz(moduleId: String) -> [QuizQuestion] {
        if moduleId != "m1" {
            return [
                QuizQuestion(id: "q1-\(moduleId)", question: "Qual beneficio principal de estudar em micro-licoes?", options: ["Menos consistencia", "Maior aderencia diaria", "Mais tempo por aula"], correctIndex: 1, explanation: "Licoes curtas facilitam criar e manter habito de estudo.")
            ]
        }
        return [
            QuizQuestion(id: "q1-m1", question: "Qual comando cria uma imagem Docker?", options: ["docker run", "docker build", "docker start", "docker logs"], correctIndex: 1, explanation: "docker build gera uma imagem a partir de um Dockerfile."),
            QuizQuestion(id: "q2-m1", question: "Qual diferenca correta entre imagem e container?", options: ["Imagem e processo em execucao", "Container e template imutavel", "Imagem e template, container e instancia", "Nao existe diferenca"], correctIndex: 2, explanation: "Imagem e template imutavel, container e instancia em runtime."),
            QuizQuestion(id: "q3-m1", question: "Qual flag mapeia portas no docker run?", options: ["-e", "-v", "-p", "--name"], correctIndex: 2, explanation: "A flag -p mapeia porta do host para porta do container."),
            QuizQuestion(id: "q4-m1", question: "Em geral, qual imagem base tende a ser menor?", options: ["ubuntu:latest", "node:alpine", "debian:stable", "python:slim-buster"], correctIndex: 1, explanation: "Imagens alpine costumam ser menores e mais leves."),
            QuizQuestion(id: "q5-m1", question: "Para que servem volumes?", options: ["Criptografar trafego", "Persistir dados entre execucoes", "Aumentar CPU", "Substituir redes"], correctIndex: 1, explanation: "Volumes armazenam dados fora do lifecycle do container."),
            QuizQuestion(id: "q6-m1", question: "Qual pratica melhora reproducibilidade de build?", options: ["Usar latest sempre", "Fixar tags de versao", "Remover Dockerfile", "Rodar tudo como root"], correctIndex: 1, explanation: "Fixar versoes reduz variabilidade entre ambientes."),
            QuizQuestion(id: "q7-m1", question: "Qual instrucao define o diretorio de trabalho?", options: ["WORKDIR", "RUN", "COPY", "EXPOSE"], correctIndex: 0, explanation: "WORKDIR define o contexto de execucao no container."),
            QuizQuestion(id: "q8-m1", question: "Qual comando lista containers em execucao?", options: ["docker images", "docker ps", "docker build", "docker inspect"], correctIndex: 1, explanation: "docker ps mostra containers ativos."),
            QuizQuestion(id: "q9-m1", question: "Qual comando remove automaticamente o container ao parar?", options: ["docker run --rm", "docker run --prune", "docker clean", "docker rm --all"], correctIndex: 0, explanation: "A flag --rm remove o container ao finalizar."),
            QuizQuestion(id: "q10-m1", question: "Por que separar COPY package*.json antes do restante do codigo?", options: ["Para evitar npm", "Para aproveitar cache de dependencias", "Para reduzir RAM", "Para criar volume"], correctIndex: 1, explanation: "Isso preserva cache do npm ci quando o codigo muda mas dependencias nao.")
        ]
    }

    public func submit(moduleId: String, answers: [Int], quizFirst: Bool) -> QuizResult {
        let questions = quiz(moduleId: moduleId)
        let correct = zip(questions, answers).filter { $0.0.correctIndex == $0.1 }.count
        let score = Int((Double(correct) / Double(max(questions.count, 1))) * 100)
        var gained = 30
        if score == 100 { gained += 50 }
        if quizFirst && score == 100 { gained += 25 }
        progress.xp += gained
        return QuizResult(moduleId: moduleId, score: score, correctCount: correct, total: questions.count, passed: score >= 70, quizFirst: quizFirst)
    }

    public func guidedReview(moduleId: String) -> [GuidedReviewPoint] {
        [
            GuidedReviewPoint(id: "gr1-\(moduleId)", topic: "Imagem vs Container", explanation: "Revise a diferenca entre template imutavel e instancia em runtime.", lessonId: "l1"),
            GuidedReviewPoint(id: "gr2-\(moduleId)", topic: "Persistencia com Volumes", explanation: "Releia quando usar volume nomeado versus bind mount.", lessonId: "l2")
        ]
    }

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

        let totalLessons = courses[courseIdx].modules.flatMap(\.lessons).count
        let completedLessons = courses[courseIdx].modules.flatMap(\.lessons).filter { $0.status == .completed }.count
        courses[courseIdx].progress = Int((Double(completedLessons) / Double(max(1, totalLessons))) * 100)
        progress.studiedMinutesToday = min(progress.dailyGoal.rawValue, progress.studiedMinutesToday + 12)
        progress.xp += 20
    }

    public func fetchProgress() -> UserProgress { progress }
    public func saveProgress(_ value: UserProgress) { progress = value }
    public func setPremium(_ enabled: Bool) { premiumEnabled = enabled }
    public func isPremium() -> Bool { premiumEnabled }
}
