import React from 'react';
import { useNavigate } from 'react-router';
import { X, Check, Zap, BookOpen, HelpCircle, Download, Star } from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';
import { PrimaryButton } from '../components/PrimaryButton';

const benefits = [
  { icon: BookOpen, text: 'Acesso a todos os cursos Premium' },
  { icon: Zap, text: 'Aulas em texto com leitura otimizada' },
  { icon: HelpCircle, text: 'Questionários e certificados' },
  { icon: Star, text: 'Conteúdo atualizado mensalmente' },
  { icon: Download, text: 'Acesso offline aos materiais' },
];

export function PaywallScreen() {
  const navigate = useNavigate();

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
      <div style={{ position: 'relative', backgroundColor: T.surface, flexShrink: 0 }}>
        <StatusBar />
        <button
          onClick={() => navigate(-1)}
          style={{
            position: 'absolute',
            top: 62,
            right: 20,
            background: T.bg,
            border: `1px solid ${T.border}`,
            borderRadius: 20,
            width: 34,
            height: 34,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            zIndex: 10,
          }}
        >
          <X size={17} color={T.textSecondary} />
        </button>
      </div>

      <div style={{ flex: 1, overflowY: 'auto' }}>
        {/* Hero */}
        <div
          style={{
            background: gradient,
            padding: '24px 24px 32px',
            textAlign: 'center',
          }}
        >
          <div
            style={{
              width: 72,
              height: 72,
              borderRadius: 22,
              backgroundColor: 'rgba(255,255,255,0.2)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              margin: '0 auto 20px',
              backdropFilter: 'blur(10px)',
            }}
          >
            <span style={{ fontSize: 36 }}>⭐</span>
          </div>

          <div
            style={{
              display: 'inline-block',
              padding: '5px 14px',
              borderRadius: 10,
              backgroundColor: 'rgba(255,255,255,0.2)',
              marginBottom: 14,
            }}
          >
            <span style={{ color: '#fff', fontSize: 12, fontWeight: 700, letterSpacing: 1 }}>
              PLANO PREMIUM
            </span>
          </div>

          <h1
            style={{
              color: '#fff',
              fontSize: 26,
              fontWeight: 800,
              marginBottom: 12,
              letterSpacing: '-0.5px',
              lineHeight: 1.3,
            }}
          >
            Aprimore seu aprendizado em TI
          </h1>
          <p style={{ color: 'rgba(255,255,255,0.85)', fontSize: 15, lineHeight: 1.6 }}>
            Acesso ilimitado a todos os cursos, questionários e certificados.
          </p>
        </div>

        {/* Pricing card */}
        <div
          style={{
            margin: '20px 20px 0',
            backgroundColor: T.surface,
            borderRadius: 18,
            border: `2px solid ${T.accent}`,
            padding: '20px',
            position: 'relative',
            overflow: 'hidden',
          }}
        >
          <div
            style={{
              position: 'absolute',
              top: 14,
              right: 14,
              padding: '4px 12px',
              borderRadius: 8,
              background: gradient,
            }}
          >
            <span style={{ color: '#fff', fontSize: 11, fontWeight: 700 }}>RECOMENDADO</span>
          </div>

          <p style={{ color: T.textTertiary, fontSize: 13, marginBottom: 6 }}>Mensal</p>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 4, marginBottom: 6 }}>
            <span
              style={{
                color: T.textPrimary,
                fontSize: 36,
                fontWeight: 800,
                letterSpacing: '-1px',
              }}
            >
              R$ 39,90
            </span>
            <span style={{ color: T.textTertiary, fontSize: 15 }}>/mês</span>
          </div>
          <p style={{ color: T.textTertiary, fontSize: 13 }}>
            Cancele quando quiser · Sem fidelidade
          </p>

          {/* Price comparison */}
          <div
            style={{
              marginTop: 14,
              padding: '10px 14px',
              backgroundColor: 'rgba(17,153,142,0.06)',
              borderRadius: 10,
              border: '1px solid rgba(17,153,142,0.15)',
            }}
          >
            <p style={{ color: '#11998E', fontSize: 13, fontWeight: 500 }}>
              💡 Equivale a R$ 1,33/dia para aprender TI
            </p>
          </div>
        </div>

        {/* Benefits */}
        <div style={{ padding: '20px 20px 0' }}>
          <h2
            style={{
              color: T.textPrimary,
              fontSize: 16,
              fontWeight: 700,
              marginBottom: 14,
              letterSpacing: '-0.3px',
            }}
          >
            O que está incluído
          </h2>

          <div
            style={{
              backgroundColor: T.surface,
              borderRadius: 16,
              border: `1px solid ${T.border}`,
              overflow: 'hidden',
            }}
          >
            {benefits.map((b, idx) => (
              <div
                key={idx}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 14,
                  padding: '14px 16px',
                  borderBottom: idx < benefits.length - 1 ? `1px solid ${T.border}` : 'none',
                }}
              >
                <div
                  style={{
                    width: 36,
                    height: 36,
                    borderRadius: 10,
                    background: gradient,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    flexShrink: 0,
                  }}
                >
                  <b.icon size={17} color="#fff" />
                </div>
                <span style={{ color: T.textSecondary, fontSize: 14, flex: 1 }}>{b.text}</span>
                <Check size={16} color="#11998E" />
              </div>
            ))}
          </div>
        </div>

        {/* Testimonial */}
        <div
          style={{
            margin: '16px 20px 0',
            backgroundColor: T.surface,
            borderRadius: 16,
            border: `1px solid ${T.border}`,
            padding: '16px',
          }}
        >
          <div style={{ display: 'flex', gap: 2, marginBottom: 10 }}>
            {[...Array(5)].map((_, i) => (
              <Star key={i} size={14} color="#F7971E" fill="#F7971E" />
            ))}
          </div>
          <p style={{ color: T.textSecondary, fontSize: 13, lineHeight: 1.6, marginBottom: 10 }}>
            "Consegui minha primeira vaga como DevOps Engineer depois de 3 meses estudando aqui.
            Vale cada centavo!"
          </p>
          <p style={{ color: T.textTertiary, fontSize: 12, fontWeight: 500 }}>— Thiago M., DevOps Jr.</p>
        </div>

        <div style={{ height: 110 }} />
      </div>

      {/* Sticky footer */}
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
        <PrimaryButton onClick={() => navigate('/purchase-success')} size="lg">
          Assinar por R$ 39,90/mês
        </PrimaryButton>

        <div style={{ display: 'flex', justifyContent: 'center', gap: 20, marginTop: 14 }}>
          <button
            style={{
              background: 'none',
              border: 'none',
              color: T.textTertiary,
              fontSize: 13,
              cursor: 'pointer',
              fontFamily: fontStack,
            }}
          >
            Restaurar compra
          </button>
          <button
            style={{
              background: 'none',
              border: 'none',
              color: T.textTertiary,
              fontSize: 13,
              cursor: 'pointer',
              fontFamily: fontStack,
            }}
          >
            Termos de uso
          </button>
        </div>
      </div>
    </div>
  );
}
