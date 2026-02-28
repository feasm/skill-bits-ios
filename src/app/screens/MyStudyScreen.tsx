import React from 'react';
import { useNavigate } from 'react-router';
import { PlayCircle, Clock, Flame, BookOpen, ChevronRight } from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';
import { courses } from '../data/courses';

const recentActivity = [
  {
    id: 'r1',
    lesson: 'O que são Containers?',
    course: 'Docker & Kubernetes na Prática',
    time: '2h atrás',
    icon: '🐳',
    color1: '#40E0D0',
    color2: '#2D95DA',
  },
  {
    id: 'r2',
    lesson: 'React 18: Novidades',
    course: 'React & TypeScript Moderno',
    time: 'Ontem',
    icon: '⚛️',
    color1: '#667EEA',
    color2: '#764BA2',
  },
  {
    id: 'r3',
    lesson: 'useState e useEffect',
    course: 'React & TypeScript Moderno',
    time: 'Ontem',
    icon: '⚛️',
    color1: '#667EEA',
    color2: '#764BA2',
  },
];

export function MyStudyScreen() {
  const navigate = useNavigate();
  const inProgressCourses = courses.filter((c) => c.progress > 0);

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
        backgroundColor: T.bg,
        fontFamily: fontStack,
        overflow: 'hidden',
      }}
    >
      <StatusBar />

      <div style={{ padding: '4px 24px 0', flexShrink: 0 }}>
        <h1
          style={{
            color: T.textPrimary,
            fontSize: 26,
            fontWeight: 700,
            letterSpacing: '-0.5px',
            marginBottom: 2,
          }}
        >
          Meu Estudo
        </h1>
        <p style={{ color: T.textTertiary, fontSize: 13 }}>
          Terça-feira, 25 de fevereiro
        </p>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '16px 24px 24px' }}>
        {/* Daily streak */}
        <div
          style={{
            background: gradient,
            borderRadius: 17,
            padding: '18px 20px',
            marginBottom: 20,
            display: 'flex',
            alignItems: 'center',
            gap: 16,
          }}
        >
          <div
            style={{
              width: 52,
              height: 52,
              borderRadius: 16,
              backgroundColor: 'rgba(255,255,255,0.2)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: 28,
              flexShrink: 0,
            }}
          >
            🔥
          </div>
          <div style={{ flex: 1 }}>
            <p style={{ color: 'rgba(255,255,255,0.8)', fontSize: 13, marginBottom: 4 }}>
              Sequência de estudos
            </p>
            <p style={{ color: '#fff', fontSize: 22, fontWeight: 800, letterSpacing: '-0.5px' }}>
              7 dias seguidos!
            </p>
          </div>
          <div style={{ textAlign: 'right' }}>
            <Flame size={28} color="rgba(255,255,255,0.7)" fill="rgba(255,255,255,0.3)" />
          </div>
        </div>

        {/* Today's goal */}
        <div
          style={{
            backgroundColor: T.surface,
            borderRadius: 17,
            border: `1px solid ${T.border}`,
            padding: '16px',
            marginBottom: 20,
          }}
        >
          <div
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              marginBottom: 12,
            }}
          >
            <p style={{ color: T.textPrimary, fontSize: 15, fontWeight: 700 }}>
              Meta de hoje
            </p>
            <span style={{ color: T.accent, fontSize: 13, fontWeight: 600 }}>2/3 aulas</span>
          </div>
          <div
            style={{
              height: 8,
              backgroundColor: T.border,
              borderRadius: 4,
              overflow: 'hidden',
              marginBottom: 8,
            }}
          >
            <div
              style={{
                height: '100%',
                width: '66%',
                background: gradient,
                borderRadius: 4,
              }}
            />
          </div>
          <p style={{ color: T.textTertiary, fontSize: 12 }}>
            Falta 1 aula para completar sua meta diária
          </p>
        </div>

        {/* Continue studying */}
        <div style={{ marginBottom: 20 }}>
          <p
            style={{
              color: T.textTertiary,
              fontSize: 13,
              fontWeight: 600,
              marginBottom: 12,
              letterSpacing: 0.2,
            }}
          >
            CONTINUAR ESTUDANDO
          </p>

          {inProgressCourses.map((course) => (
            <button
              key={course.id}
              onClick={() => navigate(`/app/courses/${course.id}`)}
              style={{
                width: '100%',
                backgroundColor: T.surface,
                border: `1px solid ${T.border}`,
                borderRadius: 16,
                padding: '16px',
                textAlign: 'left',
                cursor: 'pointer',
                fontFamily: fontStack,
                marginBottom: 10,
                display: 'flex',
                gap: 14,
                alignItems: 'center',
                boxSizing: 'border-box',
              }}
            >
              <div
                style={{
                  width: 50,
                  height: 50,
                  borderRadius: 14,
                  background: `linear-gradient(135deg, ${course.color1} 0%, ${course.color2} 100%)`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: 24,
                  flexShrink: 0,
                }}
              >
                {course.category === 'DevOps'
                  ? '🐳'
                  : course.category === 'Frontend'
                  ? '⚛️'
                  : '📚'}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <p
                  style={{
                    color: T.textPrimary,
                    fontSize: 14,
                    fontWeight: 700,
                    marginBottom: 4,
                    letterSpacing: '-0.2px',
                    whiteSpace: 'nowrap',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                  }}
                >
                  {course.title}
                </p>
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 8,
                    marginBottom: 8,
                  }}
                >
                  <Clock size={12} color={T.textTertiary} />
                  <span style={{ color: T.textTertiary, fontSize: 12 }}>
                    Próxima: {course.modules[0].lessons[2]?.title || 'Próxima aula'}
                  </span>
                </div>
                <div
                  style={{
                    height: 4,
                    backgroundColor: T.border,
                    borderRadius: 2,
                    overflow: 'hidden',
                  }}
                >
                  <div
                    style={{
                      height: '100%',
                      width: `${course.progress}%`,
                      background: gradient,
                      borderRadius: 2,
                    }}
                  />
                </div>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 8, flexShrink: 0 }}>
                <span style={{ color: T.accent, fontSize: 12, fontWeight: 600 }}>
                  {course.progress}%
                </span>
                <div
                  style={{
                    width: 32,
                    height: 32,
                    borderRadius: 10,
                    background: gradient,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <PlayCircle size={16} color="#fff" />
                </div>
              </div>
            </button>
          ))}
        </div>

        {/* Recent activity */}
        <div>
          <p
            style={{
              color: T.textTertiary,
              fontSize: 13,
              fontWeight: 600,
              marginBottom: 12,
              letterSpacing: 0.2,
            }}
          >
            ATIVIDADE RECENTE
          </p>

          <div
            style={{
              backgroundColor: T.surface,
              borderRadius: 16,
              border: `1px solid ${T.border}`,
              overflow: 'hidden',
            }}
          >
            {recentActivity.map((item, idx) => (
              <div
                key={item.id}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 12,
                  padding: '12px 16px',
                  borderBottom:
                    idx < recentActivity.length - 1 ? `1px solid ${T.border}` : 'none',
                }}
              >
                <div
                  style={{
                    width: 38,
                    height: 38,
                    borderRadius: 11,
                    background: `linear-gradient(135deg, ${item.color1} 0%, ${item.color2} 100%)`,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: 18,
                    flexShrink: 0,
                  }}
                >
                  {item.icon}
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <p
                    style={{
                      color: T.textPrimary,
                      fontSize: 13,
                      fontWeight: 600,
                      marginBottom: 2,
                      whiteSpace: 'nowrap',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                    }}
                  >
                    {item.lesson}
                  </p>
                  <p style={{ color: T.textTertiary, fontSize: 11 }}>{item.course}</p>
                </div>
                <div style={{ flexShrink: 0, display: 'flex', alignItems: 'center', gap: 4 }}>
                  <BookOpen size={12} color={T.textTertiary} />
                  <span style={{ color: T.textTertiary, fontSize: 11 }}>{item.time}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
