import React from 'react';
import { useNavigate, useParams } from 'react-router';
import {
  ChevronLeft,
  CheckCircle2,
  PlayCircle,
  Lock,
  Clock,
  HelpCircle,
  Trophy,
} from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';
import { courses } from '../data/courses';

export function ModuleDetailScreen() {
  const { courseId, moduleId } = useParams();
  const navigate = useNavigate();

  const course = courses.find((c) => c.id === courseId) || courses[0];
  const mod = course.modules.find((m) => m.id === moduleId) || course.modules[0];

  const completedLessons = mod.lessons.filter((l) => l.status === 'completed').length;
  const progress = Math.round((completedLessons / mod.lessons.length) * 100);

  const statusIcon = (status: string, progress?: number) => {
    if (status === 'completed')
      return <CheckCircle2 size={20} color="#11998E" fill="rgba(17,153,142,0.1)" />;
    if (status === 'locked') return <Lock size={20} color={T.textTertiary} />;
    if (status === 'in_progress')
      return (
        <div style={{ position: 'relative', width: 20, height: 20 }}>
          <PlayCircle size={20} color={T.accent} />
          {progress && (
            <div
              style={{
                position: 'absolute',
                bottom: -3,
                right: -3,
                width: 10,
                height: 10,
                borderRadius: 5,
                background: gradient,
                border: '1.5px solid #fff',
              }}
            />
          )}
        </div>
      );
    return <PlayCircle size={20} color={T.accent} />;
  };

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
      <div style={{ backgroundColor: T.surface, borderBottom: `1px solid ${T.border}`, flexShrink: 0 }}>
        <StatusBar />
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            padding: '0 20px 16px',
            gap: 12,
          }}
        >
          <button
            onClick={() => navigate(-1)}
            style={{
              background: T.bg,
              border: `1px solid ${T.border}`,
              borderRadius: 12,
              width: 38,
              height: 38,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              flexShrink: 0,
            }}
          >
            <ChevronLeft size={20} color={T.textPrimary} />
          </button>
          <div style={{ flex: 1, minWidth: 0 }}>
            <p style={{ color: T.textTertiary, fontSize: 12, marginBottom: 2 }}>
              {course.title}
            </p>
            <h1
              style={{
                color: T.textPrimary,
                fontSize: 17,
                fontWeight: 700,
                letterSpacing: '-0.3px',
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
              }}
            >
              {mod.title}
            </h1>
          </div>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto' }}>
        {/* Progress card */}
        <div
          style={{
            margin: '16px 20px',
            backgroundColor: T.surface,
            borderRadius: 15,
            padding: '16px',
            border: `1px solid ${T.border}`,
          }}
        >
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              marginBottom: 12,
            }}
          >
            <div>
              <p style={{ color: T.textSecondary, fontSize: 13, marginBottom: 2 }}>
                Progresso do módulo
              </p>
              <p
                style={{
                  color: T.textPrimary,
                  fontSize: 22,
                  fontWeight: 800,
                  letterSpacing: '-0.5px',
                }}
              >
                {progress}%
              </p>
            </div>
            <div
              style={{
                width: 52,
                height: 52,
                borderRadius: 26,
                background:
                  progress === 100 ? 'rgba(17,153,142,0.1)' : `linear-gradient(135deg, ${course.color1}22 0%, ${course.color2}22 100%)`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              {progress === 100 ? (
                <Trophy size={22} color="#11998E" />
              ) : (
                <span style={{ fontSize: 22, fontWeight: 800, color: course.color2 }}>
                  {completedLessons}/{mod.lessons.length}
                </span>
              )}
            </div>
          </div>

          <div
            style={{
              height: 8,
              backgroundColor: T.border,
              borderRadius: 4,
              overflow: 'hidden',
            }}
          >
            <div
              style={{
                height: '100%',
                width: `${progress}%`,
                background: progress === 100 ? 'linear-gradient(90deg, #11998E, #38EF7D)' : gradient,
                borderRadius: 4,
                transition: 'width 0.4s ease',
              }}
            />
          </div>

          <div
            style={{ display: 'flex', gap: 16, marginTop: 12 }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
              <Clock size={13} color={T.textTertiary} />
              <span style={{ color: T.textTertiary, fontSize: 12 }}>{mod.duration}</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
              <CheckCircle2 size={13} color={T.textTertiary} />
              <span style={{ color: T.textTertiary, fontSize: 12 }}>
                {completedLessons} de {mod.lessons.length} aulas
              </span>
            </div>
          </div>
        </div>

        {/* Lessons list */}
        <div style={{ padding: '0 20px' }}>
          <p style={{ color: T.textTertiary, fontSize: 13, fontWeight: 500, marginBottom: 12 }}>
            AULAS
          </p>

          <div
            style={{
              backgroundColor: T.surface,
              borderRadius: 15,
              border: `1px solid ${T.border}`,
              overflow: 'hidden',
            }}
          >
            {mod.lessons.map((lesson, idx) => {
              const isLast = idx === mod.lessons.length - 1;
              return (
                <button
                  key={lesson.id}
                  onClick={() => {
                    if (lesson.status !== 'locked') {
                      navigate(
                        `/app/courses/${courseId}/modules/${moduleId}/lessons/${lesson.id}`
                      );
                    }
                  }}
                  disabled={lesson.status === 'locked'}
                  style={{
                    width: '100%',
                    display: 'flex',
                    alignItems: 'center',
                    gap: 14,
                    padding: '14px 16px',
                    background: 'none',
                    border: 'none',
                    borderBottom: isLast ? 'none' : `1px solid ${T.border}`,
                    cursor: lesson.status === 'locked' ? 'default' : 'pointer',
                    fontFamily: fontStack,
                    textAlign: 'left',
                    opacity: lesson.status === 'locked' ? 0.5 : 1,
                    transition: 'opacity 0.15s',
                  }}
                >
                  {/* Icon */}
                  <div style={{ flexShrink: 0 }}>
                    {statusIcon(lesson.status, lesson.progress)}
                  </div>

                  {/* Text */}
                  <div style={{ flex: 1 }}>
                    <p
                      style={{
                        color:
                          lesson.status === 'locked' ? T.textTertiary : T.textPrimary,
                        fontSize: 14,
                        fontWeight: lesson.status === 'in_progress' ? 600 : 500,
                        marginBottom: lesson.progress ? 6 : 0,
                        letterSpacing: '-0.2px',
                      }}
                    >
                      {lesson.title}
                    </p>

                    {/* In-progress bar */}
                    {lesson.status === 'in_progress' && lesson.progress && (
                      <div
                        style={{
                          height: 3,
                          backgroundColor: T.border,
                          borderRadius: 2,
                          overflow: 'hidden',
                        }}
                      >
                        <div
                          style={{
                            height: '100%',
                            width: `${lesson.progress}%`,
                            background: gradient,
                            borderRadius: 2,
                          }}
                        />
                      </div>
                    )}
                  </div>

                  {/* Duration + status */}
                  <div style={{ flexShrink: 0, textAlign: 'right' }}>
                    <p style={{ color: T.textTertiary, fontSize: 12 }}>{lesson.duration}</p>
                    {lesson.status === 'in_progress' && (
                      <p style={{ color: T.accent, fontSize: 11, fontWeight: 600, marginTop: 2 }}>
                        {lesson.progress}%
                      </p>
                    )}
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Quiz card */}
        {mod.quizAvailable && (
          <div style={{ padding: '16px 20px 32px' }}>
            <button
              onClick={() =>
                navigate('/quiz-intro', {
                  state: { courseId, moduleId, quizCompleted: mod.quizCompleted, score: mod.quizScore },
                })
              }
              style={{
                width: '100%',
                backgroundColor: mod.quizCompleted ? 'rgba(17,153,142,0.06)' : T.surface,
                border: `1.5px solid ${mod.quizCompleted ? 'rgba(17,153,142,0.3)' : T.border}`,
                borderRadius: 15,
                padding: '16px',
                display: 'flex',
                alignItems: 'center',
                gap: 14,
                cursor: 'pointer',
                fontFamily: fontStack,
                textAlign: 'left',
              }}
            >
              <div
                style={{
                  width: 44,
                  height: 44,
                  borderRadius: 13,
                  backgroundColor: mod.quizCompleted
                    ? 'rgba(17,153,142,0.12)'
                    : 'rgba(45,149,218,0.1)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                }}
              >
                {mod.quizCompleted ? (
                  <Trophy size={22} color="#11998E" />
                ) : (
                  <HelpCircle size={22} color={T.accent} />
                )}
              </div>
              <div style={{ flex: 1 }}>
                <p
                  style={{
                    color: T.textPrimary,
                    fontSize: 15,
                    fontWeight: 700,
                    marginBottom: 3,
                    letterSpacing: '-0.2px',
                  }}
                >
                  Questionário do módulo
                </p>
                {mod.quizCompleted ? (
                  <p style={{ color: '#11998E', fontSize: 13, fontWeight: 500 }}>
                    Concluído · Nota: {mod.quizScore}%
                  </p>
                ) : (
                  <p style={{ color: T.textTertiary, fontSize: 13 }}>10 perguntas · ~15 min</p>
                )}
              </div>
              <ChevronLeft
                size={18}
                color={mod.quizCompleted ? '#11998E' : T.accent}
                style={{ transform: 'rotate(180deg)' }}
              />
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
