import React from 'react';
import { useNavigate, useLocation } from 'react-router';
import { ChevronLeft, PlayCircle, BookOpen, ArrowRight, CheckCircle2 } from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';
import { PrimaryButton } from '../components/PrimaryButton';

export function NextLessonScreen() {
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
      <StatusBar />

      <div
        style={{
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '0 24px',
          textAlign: 'center',
        }}
      >
        {/* Completed badge */}
        <div
          style={{
            width: 76,
            height: 76,
            borderRadius: 38,
            background: 'rgba(17,153,142,0.1)',
            border: '2px solid rgba(17,153,142,0.25)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            marginBottom: 20,
          }}
        >
          <CheckCircle2 size={38} color="#11998E" fill="rgba(17,153,142,0.15)" />
        </div>

        <h1
          style={{
            color: T.textPrimary,
            fontSize: 26,
            fontWeight: 800,
            marginBottom: 10,
            letterSpacing: '-0.5px',
          }}
        >
          Lição concluída!
        </h1>
        <p style={{ color: T.textSecondary, fontSize: 15, lineHeight: 1.6, marginBottom: 36 }}>
          Muito bem! Continue o ritmo para avançar no curso.
        </p>

        {/* XP earned */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 10,
            backgroundColor: T.surface,
            borderRadius: 14,
            border: `1px solid ${T.border}`,
            padding: '12px 20px',
            marginBottom: 32,
          }}
        >
          <span style={{ fontSize: 20 }}>⚡</span>
          <div style={{ textAlign: 'left' }}>
            <p style={{ color: T.textPrimary, fontSize: 14, fontWeight: 700 }}>+25 XP ganhos</p>
            <p style={{ color: T.textTertiary, fontSize: 12 }}>Aula concluída</p>
          </div>
          <div style={{ marginLeft: 'auto' }}>
            <p style={{ color: T.accent, fontSize: 14, fontWeight: 700 }}>345 XP total</p>
          </div>
        </div>

        {/* Next lesson card */}
        <button
          onClick={() => navigate('/app/courses/c1/modules/m1/lessons/l4')}
          style={{
            width: '100%',
            backgroundColor: T.surface,
            borderRadius: 18,
            border: `1.5px solid ${T.border}`,
            padding: '18px',
            textAlign: 'left',
            cursor: 'pointer',
            fontFamily: fontStack,
            marginBottom: 16,
            overflow: 'hidden',
            position: 'relative',
          }}
        >
          {/* Gradient accent bar */}
          <div
            style={{
              position: 'absolute',
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              background: gradient,
              borderRadius: '0 0 0 0',
            }}
          />

          <div style={{ paddingLeft: 8 }}>
            <p
              style={{
                color: T.textTertiary,
                fontSize: 11,
                fontWeight: 600,
                letterSpacing: 0.5,
                marginBottom: 8,
                textTransform: 'uppercase',
              }}
            >
              Próxima aula
            </p>

            <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
              <div
                style={{
                  width: 42,
                  height: 42,
                  borderRadius: 12,
                  background: gradient,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                }}
              >
                <PlayCircle size={20} color="#fff" />
              </div>
              <div style={{ flex: 1 }}>
                <p
                  style={{
                    color: T.textPrimary,
                    fontSize: 15,
                    fontWeight: 700,
                    marginBottom: 4,
                    letterSpacing: '-0.2px',
                    lineHeight: 1.35,
                  }}
                >
                  Imagens vs Containers
                </p>
                <p style={{ color: T.textTertiary, fontSize: 13 }}>
                  Módulo 1 · Aula 4 · 14 min
                </p>
              </div>
              <ArrowRight size={18} color={T.accent} style={{ marginTop: 4, flexShrink: 0 }} />
            </div>
          </div>
        </button>

        {/* Module overview */}
        <div
          style={{
            width: '100%',
            backgroundColor: T.surface,
            borderRadius: 16,
            border: `1px solid ${T.border}`,
            padding: '14px 16px',
            display: 'flex',
            alignItems: 'center',
            gap: 12,
            marginBottom: 28,
          }}
        >
          <div
            style={{
              width: 40,
              height: 40,
              borderRadius: 11,
              background: 'rgba(45,149,218,0.1)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
          >
            <BookOpen size={18} color={T.accent} />
          </div>
          <div style={{ flex: 1, textAlign: 'left' }}>
            <p style={{ color: T.textPrimary, fontSize: 13, fontWeight: 600, marginBottom: 2 }}>
              Módulo 1: Fundamentos de Containers
            </p>
            <div
              style={{
                height: 4,
                backgroundColor: T.border,
                borderRadius: 2,
                overflow: 'hidden',
                marginTop: 6,
              }}
            >
              <div
                style={{
                  height: '100%',
                  width: '60%',
                  background: gradient,
                  borderRadius: 2,
                }}
              />
            </div>
            <p style={{ color: T.textTertiary, fontSize: 11, marginTop: 4 }}>
              3 de 5 aulas · 60%
            </p>
          </div>
        </div>

        {/* CTAs */}
        <PrimaryButton onClick={() => navigate('/app/courses/c1/modules/m1/lessons/l4')}>
          Continuar
        </PrimaryButton>

        <button
          onClick={() => navigate('/app/courses/c1/modules/m1')}
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
          }}
        >
          Voltar ao módulo
        </button>
      </div>
    </div>
  );
}
