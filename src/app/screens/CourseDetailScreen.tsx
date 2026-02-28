import React, { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import {
  ChevronLeft,
  Clock,
  Users,
  BookOpen,
  ChevronRight,
  Lock,
  CheckCircle2,
  PlayCircle,
} from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';
import { PrimaryButton } from '../components/PrimaryButton';
import { courses } from '../data/courses';

export function CourseDetailScreen() {
  const { courseId } = useParams();
  const navigate = useNavigate();
  const [expandedModule, setExpandedModule] = useState<string | null>('m1');

  const course = courses.find((c) => c.id === courseId) || courses[0];

  const totalLessons = course.modules.reduce((acc, m) => acc + m.lessons.length, 0);
  const completedLessons = course.modules.reduce(
    (acc, m) => acc + m.lessons.filter((l) => l.status === 'completed').length,
    0
  );

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
      {/* Hero header */}
      <div
        style={{
          background: `linear-gradient(160deg, ${course.color1} 0%, ${course.color2} 100%)`,
          flexShrink: 0,
          position: 'relative',
        }}
      >
        <StatusBar light />

        <div style={{ padding: '0 20px 24px' }}>
          <button
            onClick={() => navigate(-1)}
            style={{
              background: 'rgba(255,255,255,0.2)',
              border: 'none',
              borderRadius: 12,
              width: 38,
              height: 38,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              marginBottom: 20,
            }}
          >
            <ChevronLeft size={20} color="#fff" />
          </button>

          {/* Category pill */}
          <div
            style={{
              display: 'inline-flex',
              padding: '4px 12px',
              borderRadius: 8,
              backgroundColor: 'rgba(255,255,255,0.2)',
              marginBottom: 10,
            }}
          >
            <span style={{ color: '#fff', fontSize: 12, fontWeight: 600 }}>{course.category}</span>
          </div>

          <h1
            style={{
              color: '#fff',
              fontSize: 24,
              fontWeight: 800,
              letterSpacing: '-0.5px',
              lineHeight: 1.3,
              marginBottom: 10,
            }}
          >
            {course.title}
          </h1>
          <p style={{ color: 'rgba(255,255,255,0.85)', fontSize: 14, lineHeight: 1.6 }}>
            {course.shortDesc}
          </p>

          {/* Stats row */}
          <div
            style={{
              display: 'flex',
              gap: 20,
              marginTop: 16,
              paddingTop: 16,
              borderTop: '1px solid rgba(255,255,255,0.2)',
            }}
          >
            {[
              { icon: BookOpen, label: `${totalLessons} aulas` },
              { icon: Clock, label: course.totalDuration },
              { icon: Users, label: `${course.studentsCount.toLocaleString('pt-BR')}` },
            ].map((s, i) => (
              <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <s.icon size={14} color="rgba(255,255,255,0.8)" />
                <span style={{ color: 'rgba(255,255,255,0.9)', fontSize: 13, fontWeight: 500 }}>
                  {s.label}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Scrollable content */}
      <div style={{ flex: 1, overflowY: 'auto' }}>
        {/* Instructor card */}
        <div
          style={{
            margin: '16px 20px 0',
            backgroundColor: T.surface,
            borderRadius: 15,
            padding: '14px 16px',
            border: `1px solid ${T.border}`,
            display: 'flex',
            alignItems: 'center',
            gap: 12,
          }}
        >
          <div
            style={{
              width: 44,
              height: 44,
              borderRadius: 22,
              background: `linear-gradient(135deg, ${course.color1} 0%, ${course.color2} 100%)`,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
          >
            <span style={{ color: '#fff', fontSize: 17, fontWeight: 700 }}>
              {course.instructor.charAt(0)}
            </span>
          </div>
          <div>
            <p style={{ color: T.textPrimary, fontSize: 14, fontWeight: 600 }}>
              {course.instructor}
            </p>
            <p style={{ color: T.textTertiary, fontSize: 12, marginTop: 1 }}>
              {course.instructorRole}
            </p>
          </div>
        </div>

        {/* Tags */}
        <div
          style={{ display: 'flex', gap: 8, padding: '16px 20px 0', flexWrap: 'wrap' }}
        >
          {course.tags.map((tag) => (
            <span
              key={tag}
              style={{
                padding: '5px 12px',
                borderRadius: 8,
                backgroundColor: T.inputBg,
                border: `1px solid ${T.inputBorder}`,
                color: T.textSecondary,
                fontSize: 12,
                fontWeight: 500,
              }}
            >
              {tag}
            </span>
          ))}
          <span
            style={{
              padding: '5px 12px',
              borderRadius: 8,
              backgroundColor:
                course.level === 'Avançado'
                  ? 'rgba(232,93,117,0.08)'
                  : course.level === 'Intermediário'
                  ? 'rgba(232,151,61,0.08)'
                  : 'rgba(17,153,142,0.08)',
              border: `1px solid ${
                course.level === 'Avançado'
                  ? 'rgba(232,93,117,0.2)'
                  : course.level === 'Intermediário'
                  ? 'rgba(232,151,61,0.2)'
                  : 'rgba(17,153,142,0.2)'
              }`,
              color:
                course.level === 'Avançado'
                  ? '#E85D75'
                  : course.level === 'Intermediário'
                  ? '#E8973D'
                  : '#11998E',
              fontSize: 12,
              fontWeight: 600,
            }}
          >
            {course.level}
          </span>
        </div>

        {/* Description */}
        <div style={{ padding: '16px 20px 0' }}>
          <h2
            style={{
              color: T.textPrimary,
              fontSize: 17,
              fontWeight: 700,
              marginBottom: 10,
              letterSpacing: '-0.3px',
            }}
          >
            Sobre o curso
          </h2>
          <p style={{ color: T.textSecondary, fontSize: 14, lineHeight: 1.7 }}>
            {course.description}
          </p>
        </div>

        {/* Progress (if enrolled) */}
        {course.progress > 0 && (
          <div
            style={{
              margin: '16px 20px 0',
              backgroundColor: T.surface,
              borderRadius: 15,
              padding: '14px 16px',
              border: `1px solid ${T.border}`,
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                marginBottom: 10,
              }}
            >
              <span style={{ color: T.textSecondary, fontSize: 13, fontWeight: 500 }}>
                Seu progresso
              </span>
              <span style={{ color: T.accent, fontSize: 13, fontWeight: 700 }}>
                {completedLessons}/{totalLessons} aulas
              </span>
            </div>
            <div
              style={{
                height: 6,
                backgroundColor: T.border,
                borderRadius: 3,
                overflow: 'hidden',
              }}
            >
              <div
                style={{
                  height: '100%',
                  width: `${course.progress}%`,
                  background: gradient,
                  borderRadius: 3,
                  transition: 'width 0.3s ease',
                }}
              />
            </div>
            <p style={{ color: T.textTertiary, fontSize: 12, marginTop: 6 }}>
              {course.progress}% concluído
            </p>
          </div>
        )}

        {/* Modules */}
        <div style={{ padding: '20px 20px 0' }}>
          <h2
            style={{
              color: T.textPrimary,
              fontSize: 17,
              fontWeight: 700,
              marginBottom: 14,
              letterSpacing: '-0.3px',
            }}
          >
            Conteúdo do curso
          </h2>

          {course.modules.map((mod, idx) => {
            const isExpanded = expandedModule === mod.id;
            const completedCount = mod.lessons.filter((l) => l.status === 'completed').length;
            return (
              <div
                key={mod.id}
                style={{
                  backgroundColor: T.surface,
                  border: `1px solid ${T.border}`,
                  borderRadius: 15,
                  marginBottom: 10,
                  overflow: 'hidden',
                }}
              >
                <button
                  onClick={() => setExpandedModule(isExpanded ? null : mod.id)}
                  style={{
                    width: '100%',
                    padding: '16px',
                    display: 'flex',
                    alignItems: 'center',
                    background: 'none',
                    border: 'none',
                    cursor: 'pointer',
                    fontFamily: fontStack,
                    textAlign: 'left',
                    gap: 12,
                  }}
                >
                  <div
                    style={{
                      width: 36,
                      height: 36,
                      borderRadius: 10,
                      background:
                        completedCount === mod.lessons.length
                          ? 'rgba(17,153,142,0.1)'
                          : `linear-gradient(135deg, ${course.color1}22 0%, ${course.color2}22 100%)`,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      flexShrink: 0,
                    }}
                  >
                    <span
                      style={{
                        fontSize: 14,
                        fontWeight: 700,
                        color:
                          completedCount === mod.lessons.length ? '#11998E' : course.color2,
                      }}
                    >
                      {idx + 1}
                    </span>
                  </div>
                  <div style={{ flex: 1 }}>
                    <p
                      style={{
                        color: T.textPrimary,
                        fontSize: 14,
                        fontWeight: 600,
                        marginBottom: 3,
                        letterSpacing: '-0.2px',
                      }}
                    >
                      {mod.title}
                    </p>
                    <p style={{ color: T.textTertiary, fontSize: 12 }}>
                      {mod.lessons.length} aulas · {mod.duration}
                      {completedCount > 0 && ` · ${completedCount} concluídas`}
                    </p>
                  </div>
                  <ChevronRight
                    size={18}
                    color={T.textTertiary}
                    style={{
                      transform: isExpanded ? 'rotate(90deg)' : 'rotate(0deg)',
                      transition: 'transform 0.2s ease',
                    }}
                  />
                </button>

                {isExpanded && (
                  <div
                    style={{ borderTop: `1px solid ${T.border}`, padding: '8px 16px 14px' }}
                  >
                    {mod.lessons.slice(0, 3).map((lesson) => (
                      <button
                        key={lesson.id}
                        onClick={() =>
                          navigate(
                            `/app/courses/${course.id}/modules/${mod.id}/lessons/${lesson.id}`
                          )
                        }
                        disabled={lesson.status === 'locked'}
                        style={{
                          width: '100%',
                          display: 'flex',
                          alignItems: 'center',
                          gap: 12,
                          padding: '10px 0',
                          background: 'none',
                          border: 'none',
                          borderBottom: `1px solid ${T.border}`,
                          cursor: lesson.status === 'locked' ? 'default' : 'pointer',
                          fontFamily: fontStack,
                          textAlign: 'left',
                          opacity: lesson.status === 'locked' ? 0.55 : 1,
                        }}
                      >
                        {lesson.status === 'completed' ? (
                          <CheckCircle2 size={18} color="#11998E" />
                        ) : lesson.status === 'locked' ? (
                          <Lock size={18} color={T.textTertiary} />
                        ) : (
                          <PlayCircle size={18} color={T.accent} />
                        )}
                        <div style={{ flex: 1 }}>
                          <p
                            style={{
                              color: lesson.status === 'locked' ? T.textTertiary : T.textPrimary,
                              fontSize: 13,
                              fontWeight: 500,
                            }}
                          >
                            {lesson.title}
                          </p>
                        </div>
                        <span style={{ color: T.textTertiary, fontSize: 12 }}>
                          {lesson.duration}
                        </span>
                      </button>
                    ))}
                    <button
                      onClick={() =>
                        navigate(`/app/courses/${course.id}/modules/${mod.id}`)
                      }
                      style={{
                        marginTop: 10,
                        width: '100%',
                        padding: '10px',
                        backgroundColor: T.bg,
                        border: `1px solid ${T.border}`,
                        borderRadius: 10,
                        color: T.accent,
                        fontSize: 13,
                        fontWeight: 600,
                        cursor: 'pointer',
                        fontFamily: fontStack,
                      }}
                    >
                      Ver todas as aulas →
                    </button>
                  </div>
                )}
              </div>
            );
          })}
        </div>

        <div style={{ height: 100 }} />
      </div>

      {/* Sticky CTA */}
      <div
        style={{
          position: 'absolute',
          bottom: 0,
          left: 0,
          right: 0,
          backgroundColor: T.surface,
          borderTop: `1px solid ${T.border}`,
          padding: '14px 20px 28px',
          boxShadow: '0 -8px 24px rgba(11,15,20,0.06)',
        }}
      >
        {course.isPremium && course.progress === 0 ? (
          <PrimaryButton onClick={() => navigate('/paywall')}>
            ★ Assinar Premium — R$ 39,90/mês
          </PrimaryButton>
        ) : (
          <PrimaryButton
            onClick={() =>
              navigate(`/app/courses/${course.id}/modules/${course.modules[0].id}`)
            }
          >
            {course.progress > 0 ? 'Continuar curso' : 'Começar gratuitamente'}
          </PrimaryButton>
        )}
      </div>
    </div>
  );
}
