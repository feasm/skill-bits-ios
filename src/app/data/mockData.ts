export type LessonStatus = 'completed' | 'current' | 'locked';

export interface Lesson {
  id: string;
  title: string;
  duration: string;
  status: LessonStatus;
  progress?: number;
}

export interface Module {
  id: string;
  title: string;
  lessons: Lesson[];
  hasQuiz: boolean;
  quizPassed?: boolean;
}

export interface Course {
  id: string;
  title: string;
  subtitle: string;
  tags: string[];
  isPremium: boolean;
  instructor: string;
  totalLessons: number;
  totalHours: number;
  rating: number;
  students: number;
  accentColor: string;
  iconLetter: string;
  description: string;
  modules: Module[];
}

export const courses: Course[] = [
  {
    id: '1',
    title: 'AWS Cloud Practitioner',
    subtitle: 'Domine os fundamentos da nuvem AWS',
    tags: ['Cloud', 'AWS', 'DevOps'],
    isPremium: true,
    instructor: 'Rafael Mendes',
    totalLessons: 48,
    totalHours: 24,
    rating: 4.9,
    students: 3240,
    accentColor: '#2D95DA',
    iconLetter: 'A',
    description:
      'Prepare-se para a certificação AWS Cloud Practitioner com conteúdo atualizado, exercícios práticos e quizzes de fixação. Ideal para profissionais de TI que desejam iniciar na nuvem AWS e obter sua primeira certificação.',
    modules: [
      {
        id: 'm1',
        title: 'Fundamentos de Cloud Computing',
        hasQuiz: true,
        quizPassed: false,
        lessons: [
          { id: 'l1', title: 'O que é Cloud Computing?', duration: '12 min', status: 'completed' },
          { id: 'l2', title: 'Modelos de serviço: IaaS, PaaS, SaaS', duration: '15 min', status: 'completed' },
          {
            id: 'l3',
            title: 'Regiões e Zonas de Disponibilidade',
            duration: '10 min',
            status: 'current',
            progress: 0.35,
          },
          { id: 'l4', title: 'Modelos de implantação em nuvem', duration: '8 min', status: 'locked' },
        ],
      },
      {
        id: 'm2',
        title: 'Segurança e Conformidade',
        hasQuiz: true,
        quizPassed: false,
        lessons: [
          {
            id: 'l5',
            title: 'Modelo de responsabilidade compartilhada',
            duration: '14 min',
            status: 'locked',
          },
          { id: 'l6', title: 'IAM: Usuários, Grupos e Políticas', duration: '18 min', status: 'locked' },
          {
            id: 'l7',
            title: 'AWS Organizations e controle de acesso',
            duration: '12 min',
            status: 'locked',
          },
        ],
      },
      {
        id: 'm3',
        title: 'Tecnologia e Serviços Core',
        hasQuiz: true,
        quizPassed: false,
        lessons: [
          { id: 'l8', title: 'Computação: EC2, Lambda, ECS', duration: '20 min', status: 'locked' },
          {
            id: 'l9',
            title: 'Armazenamento: S3, EBS, EFS, Glacier',
            duration: '16 min',
            status: 'locked',
          },
          {
            id: 'l10',
            title: 'Banco de dados: RDS, DynamoDB, Aurora',
            duration: '14 min',
            status: 'locked',
          },
          { id: 'l11', title: 'Redes: VPC, Route 53, CloudFront', duration: '18 min', status: 'locked' },
        ],
      },
      {
        id: 'm4',
        title: 'Cobrança e Preços',
        hasQuiz: true,
        quizPassed: false,
        lessons: [
          { id: 'l12', title: 'Modelos de preços AWS', duration: '10 min', status: 'locked' },
          { id: 'l13', title: 'AWS Cost Explorer e Budgets', duration: '8 min', status: 'locked' },
          { id: 'l14', title: 'Planos de suporte AWS', duration: '6 min', status: 'locked' },
        ],
      },
    ],
  },
  {
    id: '2',
    title: 'Python para Data Science',
    subtitle: 'Da análise de dados ao machine learning',
    tags: ['Python', 'Data Science', 'ML'],
    isPremium: false,
    instructor: 'Ana Costa',
    totalLessons: 62,
    totalHours: 30,
    rating: 4.8,
    students: 5100,
    accentColor: '#40E0D0',
    iconLetter: 'P',
    description:
      'Aprenda Python desde o básico até técnicas avançadas de Data Science e Machine Learning com projetos reais do mercado.',
    modules: [
      {
        id: 'pm1',
        title: 'Fundamentos de Python',
        hasQuiz: true,
        quizPassed: true,
        lessons: [
          { id: 'pl1', title: 'Variáveis e tipos de dados', duration: '10 min', status: 'completed' },
          { id: 'pl2', title: 'Estruturas de controle', duration: '12 min', status: 'completed' },
          { id: 'pl3', title: 'Funções e módulos', duration: '15 min', status: 'completed' },
        ],
      },
      {
        id: 'pm2',
        title: 'Pandas e NumPy',
        hasQuiz: true,
        quizPassed: false,
        lessons: [
          { id: 'pl4', title: 'Arrays com NumPy', duration: '14 min', status: 'current', progress: 0.7 },
          { id: 'pl5', title: 'DataFrames com Pandas', duration: '18 min', status: 'locked' },
          { id: 'pl6', title: 'Limpeza e transformação de dados', duration: '20 min', status: 'locked' },
        ],
      },
    ],
  },
  {
    id: '3',
    title: 'Docker & Kubernetes',
    subtitle: 'Containers e orquestração na prática',
    tags: ['DevOps', 'Docker', 'K8s'],
    isPremium: true,
    instructor: 'Carlos Oliveira',
    totalLessons: 38,
    totalHours: 18,
    rating: 4.7,
    students: 2890,
    accentColor: '#6C63FF',
    iconLetter: 'D',
    description:
      'Aprenda containerização com Docker e orquestração com Kubernetes em projetos práticos e casos de uso reais do mercado.',
    modules: [
      {
        id: 'dm1',
        title: 'Fundamentos do Docker',
        hasQuiz: true,
        quizPassed: false,
        lessons: [
          { id: 'dl1', title: 'O que são containers?', duration: '8 min', status: 'locked' },
          { id: 'dl2', title: 'Instalação e primeiros passos', duration: '10 min', status: 'locked' },
          { id: 'dl3', title: 'Dockerfile e imagens', duration: '14 min', status: 'locked' },
        ],
      },
    ],
  },
  {
    id: '4',
    title: 'JavaScript Moderno',
    subtitle: 'ES6+, React e padrões profissionais',
    tags: ['JavaScript', 'Frontend', 'React'],
    isPremium: false,
    instructor: 'Mariana Santos',
    totalLessons: 55,
    totalHours: 28,
    rating: 4.9,
    students: 7200,
    accentColor: '#F59E0B',
    iconLetter: 'J',
    description:
      'Domine JavaScript moderno com ES6+, async/await, módulos e os melhores padrões utilizados por times de alta performance.',
    modules: [
      {
        id: 'jm1',
        title: 'ES6+ Fundamentals',
        hasQuiz: true,
        quizPassed: false,
        lessons: [
          {
            id: 'jl1',
            title: 'Arrow functions e template literals',
            duration: '10 min',
            status: 'locked',
          },
          { id: 'jl2', title: 'Destructuring e spread operator', duration: '12 min', status: 'locked' },
        ],
      },
    ],
  },
];

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
    question: 'O que é uma Zona de Disponibilidade (AZ) na AWS?',
    options: [
      'Um conjunto de múltiplas regiões geográficas',
      'Um ou mais data centers físicos em uma localização',
      'Um ponto de distribuição de conteúdo (CDN)',
      'Um serviço de backup automático de dados',
    ],
    correctIndex: 1,
    explanation:
      'Uma AZ é um ou mais data centers físicos dentro de uma região, com energia, rede e conectividade redundantes.',
  },
  {
    id: 'q2',
    question: 'Qual afirmação sobre o modelo de responsabilidade compartilhada está correta?',
    options: [
      'A AWS é responsável por toda a segurança do sistema',
      'O cliente é responsável por toda a segurança',
      'A AWS cuida da segurança DA nuvem; o cliente, da segurança NA nuvem',
      'A responsabilidade de segurança é igual para ambos',
    ],
    correctIndex: 2,
    explanation:
      'A AWS gerencia a segurança da infraestrutura, enquanto o cliente é responsável pelos dados, aplicações e configurações.',
  },
  {
    id: 'q3',
    question: 'O que significa IaaS no contexto de computação em nuvem?',
    options: [
      'Internet as a Service',
      'Integration as a Service',
      'Infrastructure as a Service',
      'Information as a Service',
    ],
    correctIndex: 2,
    explanation:
      'IaaS (Infrastructure as a Service) fornece infraestrutura de TI virtualizada — servidores, redes e armazenamento — pela internet.',
  },
  {
    id: 'q4',
    question: 'Qual é a principal função do Amazon S3?',
    options: [
      'Executar código serverless',
      'Armazenamento de objetos escalável',
      'Banco de dados relacional gerenciado',
      'Rede de entrega de conteúdo',
    ],
    correctIndex: 1,
    explanation:
      'O Amazon S3 (Simple Storage Service) é um serviço de armazenamento de objetos altamente escalável e durável.',
  },
  {
    id: 'q5',
    question: 'Qual serviço AWS permite executar código sem gerenciar servidores?',
    options: ['Amazon EC2', 'Amazon ECS', 'AWS Lambda', 'Amazon EKS'],
    correctIndex: 2,
    explanation:
      'O AWS Lambda é um serviço serverless que executa código em resposta a eventos, sem necessidade de provisionar servidores.',
  },
];

export type LessonBlock =
  | { type: 'heading'; text: string }
  | { type: 'subheading'; text: string }
  | { type: 'paragraph'; text: string }
  | { type: 'list'; items: string[] }
  | { type: 'code'; language: string; text: string }
  | { type: 'callout'; title: string; text: string };

export const lessonContent: LessonBlock[] = [
  { type: 'heading', text: 'O que são Regiões AWS?' },
  {
    type: 'paragraph',
    text: 'A AWS opera em múltiplas regiões geográficas ao redor do mundo. Uma região é um conjunto de data centers em uma localização geográfica específica, totalmente isolada de outras regiões para garantir máxima disponibilidade e resiliência dos serviços.',
  },
  { type: 'subheading', text: 'Critérios para escolher uma Região' },
  {
    type: 'list',
    items: [
      'Latência para seus usuários finais',
      'Requisitos de conformidade e residência de dados',
      'Disponibilidade dos serviços necessários',
      'Custo dos serviços naquela região',
    ],
  },
  { type: 'subheading', text: 'Zonas de Disponibilidade (AZs)' },
  {
    type: 'paragraph',
    text: 'Cada região é composta por múltiplas Zonas de Disponibilidade (geralmente 2 a 6). Uma AZ é um ou mais data centers fisicamente separados, mas interconectados por rede privada de alta velocidade e baixíssima latência.',
  },
  {
    type: 'code',
    language: 'python',
    text: `import boto3

# Listar todas as regiões disponíveis
ec2 = boto3.client('ec2', region_name='us-east-1')
response = ec2.describe_regions()

for region in response['Regions']:
    print(f"Região: {region['RegionName']}")`,
  },
  {
    type: 'callout',
    title: 'Dica de prova',
    text: 'Para o AWS Cloud Practitioner: uma Região contém múltiplas AZs. As AZs são fisicamente separadas mas conectadas por rede privada de alta velocidade.',
  },
  { type: 'subheading', text: 'Pontos de Presença (Edge Locations)' },
  {
    type: 'paragraph',
    text: 'Além das regiões e AZs, a AWS possui mais de 400 Pontos de Presença (PoPs) distribuídos globalmente, utilizados principalmente pelo Amazon CloudFront para entrega de conteúdo com baixíssima latência aos usuários finais.',
  },
];

export const guidedReviewPoints = [
  {
    id: 'rp1',
    topic: 'Diferença entre Região e AZ',
    context:
      'Uma Região contém múltiplas AZs. Cada AZ é um data center físico independente com infraestrutura redundante.',
    difficulty: 'medium' as const,
    icon: '🗺️',
  },
  {
    id: 'rp2',
    topic: 'Critérios de seleção de Região',
    context: 'Latência, conformidade, disponibilidade de serviços e custo são os quatro fatores principais.',
    difficulty: 'easy' as const,
    icon: '✅',
  },
  {
    id: 'rp3',
    topic: 'Pontos de Presença (PoPs)',
    context: 'Usados pelo CloudFront para distribuição de conteúdo com baixa latência. Mais de 400 no mundo.',
    difficulty: 'hard' as const,
    icon: '📡',
  },
];

export const myStudyCourses = [
  { courseId: '1', progress: 0.35, lastAccessed: 'Hoje', currentLesson: 'Regiões e Zonas de Disponibilidade' },
  { courseId: '2', progress: 0.62, lastAccessed: 'Ontem', currentLesson: 'Arrays com NumPy' },
];
