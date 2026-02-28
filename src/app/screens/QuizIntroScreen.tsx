import React from 'react';
import { useNavigate, useLocation } from 'react-router';
import { ChevronLeft, HelpCircle, Target, Clock, Award } from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';
import { PrimaryButton } from '../components/PrimaryButton';

export function QuizIntroScreen() {
  const navigate = useNavigate();
  const location = useLocation();
  const state = (location.state as any) || {};

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
        <div style={{ display: 'flex', alignItems: 'center', padding: '0 20px 16px', gap: 12 }}>
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
            }}
          >
            <ChevronLeft size={20} color={T.textPrimary} />
          </button>
          <h1
            style={{
              color: T.textPrimary,
              fontSize: 17,
              fontWeight: 700,
              letterSpacing: '-0.3px',
            }}
          >
            Questionário
          </h1>
        </div>
      </div>

      <div
        style={{
          flex: 1,
          overflowY: 'auto',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          padding: '32px 24px',
        }}
      >
        {/* Icon */}
        <div
          style={{
            width: 88,
            height: 88,
            borderRadius: 26,
            background: gradient,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            marginBottom: 24,
            boxShadow: '0 12px 32px rgba(45,149,218,0.25)',
          }}
        >
          <HelpCircle size={44} color="#fff" />
        </div>

        <h2
          style={{
            color: T.textPrimary,
            fontSize: 24,
            fontWeight: 800,
            marginBottom: 10,
            letterSpacing: '-0.5px',
            textAlign: 'center',
            lineHeight: 1.3,
          }}
        >
          Questionário do Módulo 1
        </h2>
        <p
          style={{
            color: T.textSecondary,
            fontSize: 15,
            lineHeight: 1.65,
            textAlign: 'center',
            marginBottom: 32,
          }}
        >
          Teste seu conhecimento sobre os fundamentos de containers e Docker.
        </p>

        {/* Stats cards */}
        <div
          style={{
            width: '100%',
            display: 'grid',
            gridTemplateColumns: '1fr 1fr 1fr',
            gap: 10,
            marginBottom: 28,
          }}
        >
          {[
            { icon: HelpCircle, value: '10', label: 'Perguntas', color: T.accent },
            { icon: Clock, value: '~15', label: 'Minutos', color: '#8B5CF6' },
            { icon: Target, value: '70%', label: 'Mínimo', color: '#11998E' },
          ].map((s, idx) => (
            <div
              key={idx}
              style={{
                backgroundColor: T.surface,
                borderRadius: 14,
                border: `1px solid ${T.border}`,
                padding: '14px 10px',
                textAlign: 'center',
              }}
            >
              <s.icon size={20} color={s.color} style={{ marginBottom: 6 }} />
              <p
                style={{
                  color: T.textPrimary,
                  fontSize: 20,
                  fontWeight: 800,
                  letterSpacing: '-0.5px',
                  marginBottom: 3,
                }}
              >
                {s.value}
              </p>
              <p style={{ color: T.textTertiary, fontSize: 11 }}>{s.label}</p>
            </div>
          ))}
        </div>

        {/* Rules */}
        <div
          style={{
            width: '100%',
            backgroundColor: T.surface,
            borderRadius: 16,
            border: `1px solid ${T.border}`,
            padding: '16px',
            marginBottom: 28,
          }}
        >
          <p
            style={{
              color: T.textTertiary,
              fontSize: 12,
              fontWeight: 600,
              letterSpacing: 0.5,
              marginBottom: 12,
            }}
          >
            COMO FUNCIONA
          </p>
          {[
            'Leia cada pergunta com atenção',
            'Escolha a melhor alternativa e confirme',
            'Feedback imediato após cada resposta',
            'Precisa de 70% para passar no módulo',
          ].map((rule, idx) => (
            <div key={idx} style={{ display: 'flex', gap: 10, marginBottom: idx < 3 ? 10 : 0 }}>
              <div
                style={{
                  width: 22,
                  height: 22,
                  borderRadius: 11,
                  background: gradient,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                  marginTop: 1,
                }}
              >
                <span style={{ color: '#fff', fontSize: 11, fontWeight: 700 }}>{idx + 1}</span>
              </div>
              <span style={{ color: T.textSecondary, fontSize: 14, lineHeight: 1.5 }}>{rule}</span>
            </div>
          ))}
        </div>

        {/* Previous score */}
        {state.quizCompleted && (
          <div
            style={{
              width: '100%',
              backgroundColor: 'rgba(17,153,142,0.06)',
              borderRadius: 14,
              border: '1px solid rgba(17,153,142,0.2)',
              padding: '14px 16px',
              marginBottom: 24,
              display: 'flex',
              alignItems: 'center',
              gap: 12,
            }}
          >
            <Award size={22} color="#11998E" />
            <div>
              <p style={{ color: '#11998E', fontSize: 14, fontWeight: 600, marginBottom: 2 }}>
                Você já completou este quiz
              </p>
              <p style={{ color: T.textTertiary, fontSize: 13 }}>
                Última nota: {state.score}% · Refaça para melhorar
              </p>
            </div>
          </div>
        )}

        <PrimaryButton
          onClick={() =>
            navigate('/quiz-question', {
              state: { courseId: state.courseId, moduleId: state.moduleId },
            })
          }
          size="lg"
        >
          Começar questionário
        </PrimaryButton>
      </div>
    </div>
  );
}
