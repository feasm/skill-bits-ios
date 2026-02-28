import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router';
import { CheckCircle, Star, Zap, BookOpen } from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';
import { PrimaryButton } from '../components/PrimaryButton';

export function PurchaseSuccessScreen() {
  const navigate = useNavigate();
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => setVisible(true), 100);
    return () => clearTimeout(timer);
  }, []);

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
          padding: '0 28px',
          textAlign: 'center',
        }}
      >
        {/* Success circle */}
        <div
          style={{
            opacity: visible ? 1 : 0,
            transform: visible ? 'scale(1)' : 'scale(0.6)',
            transition: 'all 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275)',
            marginBottom: 28,
          }}
        >
          <div
            style={{
              width: 100,
              height: 100,
              borderRadius: 50,
              background: gradient,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: '0 16px 48px rgba(45,149,218,0.35)',
              position: 'relative',
            }}
          >
            <CheckCircle size={50} color="#fff" fill="rgba(255,255,255,0.25)" />

            {/* Orbiting stars */}
            {[
              { angle: -45, delay: '0s' },
              { angle: 45, delay: '0.1s' },
              { angle: 135, delay: '0.2s' },
              { angle: 225, delay: '0.3s' },
            ].map((s, i) => (
              <div
                key={i}
                style={{
                  position: 'absolute',
                  width: 24,
                  height: 24,
                  borderRadius: 12,
                  backgroundColor: T.surface,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  border: `1px solid ${T.border}`,
                  transform: `rotate(${s.angle}deg) translate(62px) rotate(-${s.angle}deg)`,
                  opacity: visible ? 1 : 0,
                  transition: `all 0.4s ease ${s.delay}`,
                  boxShadow: '0 2px 8px rgba(11,15,20,0.1)',
                }}
              >
                <Star size={11} color="#F7971E" fill="#F7971E" />
              </div>
            ))}
          </div>
        </div>

        <div
          style={{
            opacity: visible ? 1 : 0,
            transform: visible ? 'translateY(0)' : 'translateY(20px)',
            transition: 'all 0.4s ease 0.2s',
          }}
        >
          <h1
            style={{
              color: T.textPrimary,
              fontSize: 28,
              fontWeight: 800,
              marginBottom: 14,
              letterSpacing: '-0.5px',
              lineHeight: 1.3,
            }}
          >
            Assinatura ativada! 🎉
          </h1>
          <p
            style={{
              color: T.textSecondary,
              fontSize: 16,
              lineHeight: 1.7,
              marginBottom: 32,
            }}
          >
            Você agora tem acesso ilimitado a todos os cursos Premium. Bons estudos!
          </p>

          {/* Perks */}
          <div
            style={{
              backgroundColor: T.surface,
              borderRadius: 16,
              border: `1px solid ${T.border}`,
              padding: '16px',
              marginBottom: 32,
              textAlign: 'left',
            }}
          >
            {[
              { icon: BookOpen, text: '5 cursos Premium desbloqueados' },
              { icon: Zap, text: 'Novos cursos adicionados todo mês' },
              { icon: Star, text: 'Certificados incluídos' },
            ].map((item, idx, arr) => (
              <div
                key={idx}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 12,
                  paddingBottom: idx < arr.length - 1 ? 12 : 0,
                  marginBottom: idx < arr.length - 1 ? 12 : 0,
                  borderBottom: idx < arr.length - 1 ? `1px solid ${T.border}` : 'none',
                }}
              >
                <div
                  style={{
                    width: 36,
                    height: 36,
                    borderRadius: 10,
                    background: 'rgba(17,153,142,0.1)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    flexShrink: 0,
                  }}
                >
                  <item.icon size={17} color="#11998E" />
                </div>
                <span style={{ color: T.textSecondary, fontSize: 14 }}>{item.text}</span>
              </div>
            ))}
          </div>

          <PrimaryButton onClick={() => navigate('/app/courses')} size="lg">
            Voltar para Cursos
          </PrimaryButton>
        </div>
      </div>
    </div>
  );
}
