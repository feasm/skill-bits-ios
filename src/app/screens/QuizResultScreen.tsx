import React from 'react';
import { useNavigate, useLocation } from 'react-router';
import { Trophy, RefreshCw, ChevronRight, Target } from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';
import { PrimaryButton } from '../components/PrimaryButton';

export function QuizResultScreen() {
  const navigate = useNavigate();
  const location = useLocation();
  const state = (location.state as any) || { score: 80, correctCount: 8, total: 10 };

  const { score = 80, correctCount = 8, total = 10 } = state;
  const passed = score >= 70;
  const minScore = 70;

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

      <div
        style={{
          flex: 1,
          overflowY: 'auto',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          padding: '24px 24px 32px',
        }}
      >
        {/* Score circle */}
        <div style={{ position: 'relative', marginBottom: 24 }}>
          <svg width="140" height="140" viewBox="0 0 140 140">
            {/* Background circle */}
            <circle cx="70" cy="70" r="58" fill="none" stroke={T.border} strokeWidth="10" />
            {/* Progress circle */}
            <circle
              cx="70"
              cy="70"
              r="58"
              fill="none"
              stroke="url(#scoreGrad)"
              strokeWidth="10"
              strokeLinecap="round"
              strokeDasharray={`${2 * Math.PI * 58}`}
              strokeDashoffset={`${2 * Math.PI * 58 * (1 - score / 100)}`}
              transform="rotate(-90 70 70)"
              style={{ transition: 'stroke-dashoffset 0.8s ease' }}
            />
            <defs>
              <linearGradient id="scoreGrad" x1="0%" y1="0%" x2="100%" y2="0%">
                <stop offset="0%" stopColor="#40E0D0" />
                <stop offset="100%" stopColor="#2D95DA" />
              </linearGradient>
            </defs>
          </svg>

          <div
            style={{
              position: 'absolute',
              inset: 0,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <span
              style={{
                color: T.textPrimary,
                fontSize: 32,
                fontWeight: 800,
                letterSpacing: '-1px',
              }}
            >
              {score}%
            </span>
            <span style={{ color: T.textTertiary, fontSize: 12 }}>pontuação</span>
          </div>
        </div>

        {/* Result badge */}
        <div
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: 8,
            padding: '8px 18px',
            borderRadius: 20,
            backgroundColor: passed ? 'rgba(17,153,142,0.08)' : 'rgba(220,53,69,0.06)',
            border: `1.5px solid ${passed ? 'rgba(17,153,142,0.3)' : 'rgba(220,53,69,0.2)'}`,
            marginBottom: 12,
          }}
        >
          {passed ? (
            <Trophy size={16} color="#11998E" />
          ) : (
            <Target size={16} color="#DC3545" />
          )}
          <span
            style={{
              color: passed ? '#11998E' : '#DC3545',
              fontSize: 14,
              fontWeight: 700,
            }}
          >
            {passed ? 'Aprovado! 🎉' : 'Continue tentando'}
          </span>
        </div>

        <h1
          style={{
            color: T.textPrimary,
            fontSize: 22,
            fontWeight: 800,
            marginBottom: 8,
            letterSpacing: '-0.4px',
            textAlign: 'center',
          }}
        >
          {passed ? 'Parabéns, você passou!' : 'Quase lá!'}
        </h1>
        <p
          style={{
            color: T.textSecondary,
            fontSize: 15,
            lineHeight: 1.6,
            textAlign: 'center',
            marginBottom: 28,
          }}
        >
          {passed
            ? 'Você completou o questionário com sucesso e pode avançar para o próximo módulo.'
            : `Você precisa de ${minScore}% para passar. Revise os tópicos e tente novamente.`}
        </p>

        {/* Stats grid */}
        <div
          style={{
            width: '100%',
            display: 'grid',
            gridTemplateColumns: '1fr 1fr 1fr',
            gap: 10,
            marginBottom: 24,
          }}
        >
          {[
            {
              value: `${correctCount}/${total}`,
              label: 'Corretas',
              color: '#11998E',
              bg: 'rgba(17,153,142,0.07)',
            },
            {
              value: `${total - correctCount}/${total}`,
              label: 'Incorretas',
              color: '#DC3545',
              bg: 'rgba(220,53,69,0.05)',
            },
            {
              value: `${minScore}%`,
              label: 'Mínimo',
              color: T.accent,
              bg: 'rgba(45,149,218,0.07)',
            },
          ].map((s, idx) => (
            <div
              key={idx}
              style={{
                backgroundColor: T.surface,
                borderRadius: 14,
                border: `1px solid ${T.border}`,
                padding: '14px 10px',
                textAlign: 'center',
                background: s.bg,
              }}
            >
              <p
                style={{
                  color: s.color,
                  fontSize: 20,
                  fontWeight: 800,
                  letterSpacing: '-0.5px',
                  marginBottom: 4,
                }}
              >
                {s.value}
              </p>
              <p style={{ color: T.textTertiary, fontSize: 11 }}>{s.label}</p>
            </div>
          ))}
        </div>

        {/* Review weaknesses */}
        {!passed && (
          <button
            onClick={() =>
              navigate('/quiz-review', {
                state: { courseId: state.courseId, moduleId: state.moduleId },
              })
            }
            style={{
              width: '100%',
              backgroundColor: T.surface,
              border: `1px solid ${T.border}`,
              borderRadius: 16,
              padding: '16px',
              display: 'flex',
              alignItems: 'center',
              gap: 14,
              cursor: 'pointer',
              fontFamily: fontStack,
              textAlign: 'left',
              marginBottom: 16,
            }}
          >
            <div
              style={{
                width: 40,
                height: 40,
                borderRadius: 12,
                backgroundColor: 'rgba(139,92,246,0.1)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexShrink: 0,
              }}
            >
              <Target size={20} color="#8B5CF6" />
            </div>
            <div style={{ flex: 1 }}>
              <p style={{ color: T.textPrimary, fontSize: 14, fontWeight: 600, marginBottom: 2 }}>
                Ver revisão guiada
              </p>
              <p style={{ color: T.textTertiary, fontSize: 12 }}>
                Revisar pontos fracos identificados
              </p>
            </div>
            <ChevronRight size={16} color={T.textTertiary} />
          </button>
        )}

        {/* CTAs */}
        {passed ? (
          <PrimaryButton
            onClick={() =>
              navigate('/next-lesson', {
                state: { courseId: state.courseId, moduleId: state.moduleId },
              })
            }
          >
            Continuar para próxima aula →
          </PrimaryButton>
        ) : (
          <PrimaryButton
            onClick={() =>
              navigate('/quiz-intro', {
                state: { courseId: state.courseId, moduleId: state.moduleId },
              })
            }
          >
            Refazer questionário
          </PrimaryButton>
        )}

        {passed && (
          <button
            onClick={() =>
              navigate('/quiz-review', {
                state: { courseId: state.courseId, moduleId: state.moduleId },
              })
            }
            style={{
              width: '100%',
              marginTop: 10,
              padding: '15px',
              backgroundColor: 'transparent',
              border: `1.5px solid ${T.border}`,
              borderRadius: 17,
              color: T.textSecondary,
              fontSize: 15,
              fontWeight: 600,
              cursor: 'pointer',
              fontFamily: fontStack,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 8,
            }}
          >
            <RefreshCw size={16} />
            Refazer quiz
          </button>
        )}
      </div>
    </div>
  );
}
