export interface Lesson {
  id: string;
  title: string;
  duration: string;
  status: 'locked' | 'available' | 'in_progress' | 'completed';
  progress?: number;
}

export interface Module {
  id: string;
  title: string;
  description: string;
  duration: string;
  lessons: Lesson[];
  quizAvailable: boolean;
  quizCompleted?: boolean;
  quizScore?: number;
}

export interface Course {
  id: string;
  title: string;
  shortDesc: string;
  description: string;
  category: string;
  tags: string[];
  level: 'Iniciante' | 'Intermediário' | 'Avançado';
  totalDuration: string;
  studentsCount: number;
  isPremium: boolean;
  progress: number;
  instructor: string;
  instructorRole: string;
  color1: string;
  color2: string;
  modules: Module[];
}

export interface QuizQuestion {
  id: string;
  question: string;
  options: string[];
  correctIndex: number;
  explanation: string;
}

export const quizQuestions: QuizQuestion[] = [
  {
    id: 'q1',
    question: 'O que é um container Docker?',
    options: [
      'Uma máquina virtual completa com SO próprio',
      'Um processo isolado que compartilha o kernel do host',
      'Um serviço de armazenamento em nuvem',
      'Um tipo de banco de dados distribuído',
    ],
    correctIndex: 1,
    explanation:
      'Containers compartilham o kernel do sistema operacional host, sendo mais leves que VMs completas.',
  },
  {
    id: 'q2',
    question: 'Qual instrução no Dockerfile define o comando padrão ao iniciar o container?',
    options: ['RUN', 'COPY', 'CMD', 'FROM'],
    correctIndex: 2,
    explanation: 'CMD define o comando que será executado quando o container iniciar.',
  },
  {
    id: 'q3',
    question: 'O que faz o comando `docker ps`?',
    options: [
      'Lista todas as imagens disponíveis',
      'Lista todos os containers em execução',
      'Remove containers parados',
      'Constrói uma nova imagem',
    ],
    correctIndex: 1,
    explanation: '`docker ps` exibe os containers atualmente em execução. Use `-a` para ver todos.',
  },
  {
    id: 'q4',
    question: 'Qual a diferença entre uma imagem e um container Docker?',
    options: [
      'Não há diferença, são a mesma coisa',
      'Imagem é o template imutável; container é a instância em execução',
      'Container é o template; imagem é a instância',
      'Imagens só existem em produção',
    ],
    correctIndex: 1,
    explanation:
      'Imagens são templates imutáveis (read-only). Containers são instâncias executáveis criadas a partir de imagens.',
  },
  {
    id: 'q5',
    question: 'Para que serve o Docker Compose?',
    options: [
      'Compilar código-fonte dentro de containers',
      'Gerenciar múltiplos containers como uma aplicação',
      'Substituir o Kubernetes em produção',
      'Criar imagens mais compactas automaticamente',
    ],
    correctIndex: 1,
    explanation:
      'Docker Compose permite definir e rodar aplicações multi-container com um arquivo YAML.',
  },
  {
    id: 'q6',
    question: 'O que é um volume Docker?',
    options: [
      'A memória RAM alocada para o container',
      'Um mecanismo para persistir dados além do ciclo de vida do container',
      'O espaço de CPU reservado',
      'Um tipo de rede virtual',
    ],
    correctIndex: 1,
    explanation:
      'Volumes permitem persistir e compartilhar dados entre containers e o host.',
  },
  {
    id: 'q7',
    question: 'Qual instrução do Dockerfile copia arquivos do host para a imagem?',
    options: ['ADD', 'COPY', 'MOVE', 'IMPORT'],
    correctIndex: 1,
    explanation: 'COPY é a instrução recomendada para copiar arquivos locais para a imagem.',
  },
  {
    id: 'q8',
    question: 'O que é o Docker Hub?',
    options: [
      'O daemon principal do Docker',
      'Um registro público de imagens Docker',
      'O CLI do Docker',
      'Uma ferramenta de orquestração',
    ],
    correctIndex: 1,
    explanation:
      'Docker Hub é o registro público padrão onde desenvolvedores publicam e baixam imagens.',
  },
  {
    id: 'q9',
    question: 'Como expor uma porta do container para o host?',
    options: [
      'docker run --share 80:8080',
      'docker run -p 8080:80',
      'docker run --expose 8080',
      'docker run --port 80',
    ],
    correctIndex: 1,
    explanation:
      'O flag `-p host:container` mapeia a porta do container para a porta do host.',
  },
  {
    id: 'q10',
    question: 'O que significa a instrução `FROM` no Dockerfile?',
    options: [
      'Define o autor da imagem',
      'Define a imagem base para o build',
      'Copia arquivos de outra imagem',
      'Executa um comando na imagem base',
    ],
    correctIndex: 1,
    explanation:
      'FROM define qual imagem base será usada como ponto de partida para o build.',
  },
];

export const courses: Course[] = [
  {
    id: 'c1',
    title: 'Docker & Kubernetes na Prática',
    shortDesc: 'Do zero ao deploy em produção com containers',
    description:
      'Aprenda a containerizar aplicações com Docker e orquestrar em Kubernetes. Curso completo com projetos reais, do ambiente local ao deploy na AWS.',
    category: 'DevOps',
    tags: ['Docker', 'Kubernetes', 'DevOps', 'AWS'],
    level: 'Intermediário',
    totalDuration: '14h 30min',
    studentsCount: 8420,
    isPremium: true,
    progress: 35,
    instructor: 'Carlos Mendes',
    instructorRole: 'DevOps Engineer · Ex-Netflix',
    color1: '#40E0D0',
    color2: '#2D95DA',
    modules: [
      {
        id: 'm1',
        title: 'Fundamentos de Containers',
        description: 'Entenda o que são containers e como o Docker funciona por baixo dos panos.',
        duration: '2h 15min',
        quizAvailable: true,
        quizCompleted: true,
        quizScore: 80,
        lessons: [
          { id: 'l1', title: 'O que são Containers?', duration: '12 min', status: 'completed' },
          { id: 'l2', title: 'Instalando o Docker', duration: '8 min', status: 'completed' },
          { id: 'l3', title: 'Seu Primeiro Container', duration: '18 min', status: 'in_progress', progress: 60 },
          { id: 'l4', title: 'Imagens vs Containers', duration: '14 min', status: 'available' },
          { id: 'l5', title: 'Dockerfile: construindo imagens', duration: '22 min', status: 'available' },
        ],
      },
      {
        id: 'm2',
        title: 'Docker em Produção',
        description: 'Volumes, redes, Docker Compose e boas práticas para produção.',
        duration: '3h 40min',
        quizAvailable: true,
        quizCompleted: false,
        lessons: [
          { id: 'l6', title: 'Volumes e Persistência', duration: '20 min', status: 'locked' },
          { id: 'l7', title: 'Redes Docker', duration: '18 min', status: 'locked' },
          { id: 'l8', title: 'Docker Compose', duration: '30 min', status: 'locked' },
          { id: 'l9', title: 'Multi-stage Builds', duration: '24 min', status: 'locked' },
        ],
      },
      {
        id: 'm3',
        title: 'Kubernetes Essencial',
        description: 'Pods, Deployments, Services e escalabilidade com K8s.',
        duration: '4h 20min',
        quizAvailable: true,
        lessons: [
          { id: 'l10', title: 'Introdução ao Kubernetes', duration: '16 min', status: 'locked' },
          { id: 'l11', title: 'Pods e Deployments', duration: '28 min', status: 'locked' },
          { id: 'l12', title: 'Services e Ingress', duration: '22 min', status: 'locked' },
          { id: 'l13', title: 'ConfigMaps e Secrets', duration: '18 min', status: 'locked' },
          { id: 'l14', title: 'Deploy na AWS EKS', duration: '35 min', status: 'locked' },
        ],
      },
    ],
  },
  {
    id: 'c2',
    title: 'Python para Data Science',
    shortDesc: 'Análise de dados, ML e visualizações com Python',
    description:
      'Domine Python aplicado à Ciência de Dados. Pandas, NumPy, Matplotlib, Scikit-learn e muito mais em projetos práticos.',
    category: 'Data Science',
    tags: ['Python', 'Pandas', 'ML', 'Numpy'],
    level: 'Iniciante',
    totalDuration: '18h 00min',
    studentsCount: 12300,
    isPremium: true,
    progress: 0,
    instructor: 'Ana Rodrigues',
    instructorRole: 'Data Scientist · Ex-iFood',
    color1: '#F7971E',
    color2: '#FFD200',
    modules: [
      {
        id: 'm1',
        title: 'Python Fundamental',
        description: 'Bases de Python para ciência de dados.',
        duration: '3h 00min',
        quizAvailable: true,
        lessons: [
          { id: 'l1', title: 'Ambiente e Jupyter', duration: '15 min', status: 'available' },
          { id: 'l2', title: 'Tipos e Estruturas', duration: '20 min', status: 'locked' },
          { id: 'l3', title: 'Funções e Módulos', duration: '18 min', status: 'locked' },
        ],
      },
      {
        id: 'm2',
        title: 'Pandas & NumPy',
        description: 'Manipulação e análise de dados.',
        duration: '4h 30min',
        quizAvailable: true,
        lessons: [
          { id: 'l4', title: 'DataFrames', duration: '25 min', status: 'locked' },
          { id: 'l5', title: 'Limpeza de Dados', duration: '30 min', status: 'locked' },
          { id: 'l6', title: 'Agregações e GroupBy', duration: '22 min', status: 'locked' },
        ],
      },
    ],
  },
  {
    id: 'c3',
    title: 'AWS Cloud Practitioner',
    shortDesc: 'Certificação AWS do zero com simulados',
    description:
      'Prepare-se para a certificação AWS Cloud Practitioner com teoria, labs e simulados completos.',
    category: 'Cloud',
    tags: ['AWS', 'Cloud', 'Certificação', 'S3', 'EC2'],
    level: 'Iniciante',
    totalDuration: '10h 00min',
    studentsCount: 6100,
    isPremium: true,
    progress: 0,
    instructor: 'Lucas Ferreira',
    instructorRole: 'AWS Certified Solutions Architect',
    color1: '#FF6B35',
    color2: '#F7C59F',
    modules: [
      {
        id: 'm1',
        title: 'Introdução à AWS',
        description: 'Serviços core e modelo de responsabilidade.',
        duration: '2h 00min',
        quizAvailable: true,
        lessons: [
          { id: 'l1', title: 'O que é Cloud Computing?', duration: '10 min', status: 'available' },
          { id: 'l2', title: 'Serviços Core da AWS', duration: '22 min', status: 'locked' },
        ],
      },
    ],
  },
  {
    id: 'c4',
    title: 'React & TypeScript Moderno',
    shortDesc: 'Construa apps profissionais com React 18 e TS',
    description:
      'Aprenda React moderno com TypeScript, hooks avançados, performance e arquitetura de aplicações escaláveis.',
    category: 'Frontend',
    tags: ['React', 'TypeScript', 'Hooks', 'Frontend'],
    level: 'Intermediário',
    totalDuration: '16h 00min',
    studentsCount: 9800,
    isPremium: false,
    progress: 70,
    instructor: 'Beatriz Lima',
    instructorRole: 'Frontend Engineer · Meta',
    color1: '#667EEA',
    color2: '#764BA2',
    modules: [
      {
        id: 'm1',
        title: 'Fundamentos do React 18',
        description: 'Components, hooks e Concurrent Features.',
        duration: '3h 30min',
        quizAvailable: true,
        quizCompleted: true,
        quizScore: 90,
        lessons: [
          { id: 'l1', title: 'React 18: Novidades', duration: '14 min', status: 'completed' },
          { id: 'l2', title: 'JSX e Components', duration: '18 min', status: 'completed' },
          { id: 'l3', title: 'useState e useEffect', duration: '24 min', status: 'completed' },
          { id: 'l4', title: 'Hooks Avançados', duration: '28 min', status: 'completed' },
        ],
      },
    ],
  },
  {
    id: 'c5',
    title: 'Fundamentos de Redes',
    shortDesc: 'TCP/IP, segurança e infraestrutura de redes',
    description:
      'Entenda como as redes de computadores funcionam: protocolos TCP/IP, firewalls, VPNs e segurança básica.',
    category: 'Infra',
    tags: ['Redes', 'TCP/IP', 'Segurança', 'Linux'],
    level: 'Iniciante',
    totalDuration: '8h 00min',
    studentsCount: 4200,
    isPremium: false,
    progress: 0,
    instructor: 'Marcos Silva',
    instructorRole: 'Network Engineer · Claro',
    color1: '#11998E',
    color2: '#38EF7D',
    modules: [
      {
        id: 'm1',
        title: 'Modelo OSI e TCP/IP',
        description: 'As camadas de rede e seus protocolos.',
        duration: '2h 00min',
        quizAvailable: true,
        lessons: [
          { id: 'l1', title: 'Modelo OSI', duration: '18 min', status: 'available' },
          { id: 'l2', title: 'Protocolo TCP vs UDP', duration: '16 min', status: 'locked' },
        ],
      },
    ],
  },
];

export const lessonContent = {
  title: 'O que são Containers?',
  readTime: '12 min de leitura',
  content: [
    {
      type: 'heading',
      text: 'Containers: a revolução do deploy moderno',
    },
    {
      type: 'paragraph',
      text: 'Antes dos containers, o problema clássico do desenvolvimento era o famoso "funciona na minha máquina". Cada desenvolvedor tinha um ambiente diferente, com versões distintas de bibliotecas, configurações e dependências. Isso tornava o processo de deploy imprevisível e propenso a falhas.',
    },
    {
      type: 'heading2',
      text: 'O que é um container?',
    },
    {
      type: 'paragraph',
      text: 'Um container é um processo isolado que roda no kernel do sistema operacional host, mas com seu próprio sistema de arquivos, rede e espaço de processos. Pense nele como uma "caixa" que empacota sua aplicação junto com todas as suas dependências.',
    },
    {
      type: 'list',
      items: [
        'Isolamento: cada container tem seu próprio ambiente',
        'Portabilidade: roda igual em qualquer máquina com Docker',
        'Leveza: compartilha o kernel do host (diferente de VMs)',
        'Velocidade: inicia em milissegundos, não minutos',
      ],
    },
    {
      type: 'heading2',
      text: 'Container vs Máquina Virtual',
    },
    {
      type: 'paragraph',
      text: 'A principal diferença está na camada de virtualização. Máquinas virtuais emulam hardware completo e precisam de um SO completo, consumindo muito mais recursos. Containers, por sua vez, compartilham o kernel do host:',
    },
    {
      type: 'code',
      language: 'bash',
      text: `# VM tradicional: consome GB de RAM, demora minutos para iniciar
$ virtualbox start myapp-vm  # ~2-4 GB RAM, ~60s boot

# Container Docker: consume MB de RAM, inicia em < 1 segundo  
$ docker run -d nginx          # ~50 MB RAM, < 500ms boot
$ docker ps
CONTAINER ID   IMAGE   STATUS          PORTS
a3f2d1c8e901   nginx   Up 2 seconds    0.0.0.0:80->80/tcp`,
    },
    {
      type: 'heading2',
      text: 'A anatomia de um container',
    },
    {
      type: 'paragraph',
      text: 'Todo container Docker é criado a partir de uma imagem. Uma imagem é um template imutável, empilhado em camadas (layers). Cada instrução no Dockerfile cria uma nova camada:',
    },
    {
      type: 'code',
      language: 'dockerfile',
      text: `# Dockerfile — definindo nossa imagem
FROM node:18-alpine        # camada base

WORKDIR /app               # define diretório de trabalho
COPY package*.json ./      # copia dependências
RUN npm ci                 # instala (cria nova camada)

COPY . .                   # copia código-fonte
EXPOSE 3000                # documenta a porta

CMD ["node", "server.js"]  # comando padrão`,
    },
    {
      type: 'paragraph',
      text: 'As camadas são compartilhadas entre imagens, o que torna o sistema altamente eficiente em disco. Se duas imagens usam a mesma base (ex: `node:18-alpine`), essa camada é armazenada apenas uma vez.',
    },
  ],
};
