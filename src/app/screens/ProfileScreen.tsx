import React from 'react';
import { useNavigate } from 'react-router';
import {
  ChevronRight,
  Bell,
  Shield,
  HelpCircle,
  Star,
  LogOut,
  CreditCard,
  User,
  Edit3,
} from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';

const settingsGroups = [
  {
    title: 'Conta',
    items: [
      { icon: User, label: 'Dados pessoais', subtitle: 'Nome, e-mail, senha' },
      { icon: CreditCard, label: 'Assinatura', subtitle: 'Premium · Próx. cobrança: 25/03', badge: 'Premium' },
      { icon: Bell, label: 'Notificações', subtitle: 'Meta diária, lembretes' },
    ],
  },
  {
    title: 'Preferências',
    items: [
      { icon: Star, label: 'Meta de estudo', subtitle: '3 aulas por dia' },
    ],
  },
  {
    title: 'Suporte',
    items: [
      { icon: HelpCircle, label: 'Central de ajuda', subtitle: null },
      { icon: Shield, label: 'Privacidade e termos', subtitle: null },
    ],
  },
];

export function ProfileScreen() {
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
      <StatusBar />

      <div style={{ padding: '4px 24px 0', flexShrink: 0 }}>
        <h1
          style={{
            color: T.textPrimary,
            fontSize: 26,
            fontWeight: 700,
            letterSpacing: '-0.5px',
          }}
        >
          Perfil
        </h1>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '16px 24px 28px' }}>
        {/* Profile card */}
        <div
          style={{
            backgroundColor: T.surface,
            borderRadius: 20,
            border: `1px solid ${T.border}`,
            padding: '20px',
            marginBottom: 20,
            display: 'flex',
            alignItems: 'center',
            gap: 16,
          }}
        >
          {/* Avatar */}
          <div style={{ position: 'relative', flexShrink: 0 }}>
            <div
              style={{
                width: 66,
                height: 66,
                borderRadius: 33,
                background: gradient,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                boxShadow: '0 6px 18px rgba(45,149,218,0.25)',
              }}
            >
              <span style={{ color: '#fff', fontSize: 26, fontWeight: 800 }}>R</span>
            </div>
            <button
              style={{
                position: 'absolute',
                bottom: 0,
                right: 0,
                width: 24,
                height: 24,
                borderRadius: 12,
                background: gradient,
                border: '2px solid #fff',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
            >
              <Edit3 size={11} color="#fff" />
            </button>
          </div>

          {/* Info */}
          <div style={{ flex: 1, minWidth: 0 }}>
            <p
              style={{
                color: T.textPrimary,
                fontSize: 18,
                fontWeight: 800,
                letterSpacing: '-0.4px',
                marginBottom: 3,
              }}
            >
              Rafael Costa
            </p>
            <p style={{ color: T.textTertiary, fontSize: 13, marginBottom: 8 }}>
              rafael@email.com
            </p>
            <div
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: 5,
                padding: '4px 10px',
                borderRadius: 8,
                background: gradient,
              }}
            >
              <Star size={11} color="#fff" fill="#fff" />
              <span style={{ color: '#fff', fontSize: 11, fontWeight: 700 }}>PREMIUM</span>
            </div>
          </div>
        </div>

        {/* XP Progress */}
        <div
          style={{
            backgroundColor: T.surface,
            borderRadius: 16,
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
              marginBottom: 10,
            }}
          >
            <div>
              <p style={{ color: T.textSecondary, fontSize: 13, marginBottom: 3 }}>
                Nível 4 · Desenvolvedor em formação
              </p>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <span style={{ fontSize: 16 }}>⚡</span>
                <span
                  style={{
                    color: T.textPrimary,
                    fontSize: 17,
                    fontWeight: 800,
                    letterSpacing: '-0.3px',
                  }}
                >
                  345 XP
                </span>
              </div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <p style={{ color: T.textTertiary, fontSize: 12 }}>Próximo nível</p>
              <p style={{ color: T.accent, fontSize: 13, fontWeight: 700 }}>500 XP</p>
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
                width: '69%',
                background: gradient,
                borderRadius: 4,
              }}
            />
          </div>
          <p style={{ color: T.textTertiary, fontSize: 11, marginTop: 6 }}>
            155 XP para o nível 5
          </p>
        </div>

        {/* Quick stats */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: '1fr 1fr 1fr',
            gap: 10,
            marginBottom: 20,
          }}
        >
          {[
            { value: '2', label: 'Cursos', emoji: '📚' },
            { value: '18', label: 'Aulas', emoji: '✅' },
            { value: '7', label: 'Dias', emoji: '🔥' },
          ].map((s, idx) => (
            <div
              key={idx}
              style={{
                backgroundColor: T.surface,
                borderRadius: 14,
                border: `1px solid ${T.border}`,
                padding: '12px 10px',
                textAlign: 'center',
              }}
            >
              <p style={{ fontSize: 20, marginBottom: 4 }}>{s.emoji}</p>
              <p
                style={{
                  color: T.textPrimary,
                  fontSize: 18,
                  fontWeight: 800,
                  letterSpacing: '-0.5px',
                  marginBottom: 2,
                }}
              >
                {s.value}
              </p>
              <p style={{ color: T.textTertiary, fontSize: 11 }}>{s.label}</p>
            </div>
          ))}
        </div>

        {/* Settings groups */}
        {settingsGroups.map((group) => (
          <div key={group.title} style={{ marginBottom: 20 }}>
            <p
              style={{
                color: T.textTertiary,
                fontSize: 13,
                fontWeight: 600,
                marginBottom: 10,
                letterSpacing: 0.2,
              }}
            >
              {group.title.toUpperCase()}
            </p>
            <div
              style={{
                backgroundColor: T.surface,
                borderRadius: 16,
                border: `1px solid ${T.border}`,
                overflow: 'hidden',
              }}
            >
              {group.items.map((item, idx) => (
                <button
                  key={idx}
                  style={{
                    width: '100%',
                    display: 'flex',
                    alignItems: 'center',
                    gap: 14,
                    padding: '14px 16px',
                    background: 'none',
                    border: 'none',
                    borderBottom:
                      idx < group.items.length - 1 ? `1px solid ${T.border}` : 'none',
                    cursor: 'pointer',
                    fontFamily: fontStack,
                    textAlign: 'left',
                  }}
                >
                  <div
                    style={{
                      width: 36,
                      height: 36,
                      borderRadius: 10,
                      backgroundColor: T.bg,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      flexShrink: 0,
                    }}
                  >
                    <item.icon size={17} color={T.textSecondary} />
                  </div>
                  <div style={{ flex: 1 }}>
                    <p style={{ color: T.textPrimary, fontSize: 14, fontWeight: 600 }}>
                      {item.label}
                    </p>
                    {item.subtitle && (
                      <p style={{ color: T.textTertiary, fontSize: 12, marginTop: 1 }}>
                        {item.subtitle}
                      </p>
                    )}
                  </div>
                  {item.badge && (
                    <div
                      style={{
                        padding: '3px 9px',
                        borderRadius: 7,
                        background: gradient,
                        marginRight: 6,
                      }}
                    >
                      <span style={{ color: '#fff', fontSize: 11, fontWeight: 700 }}>
                        {item.badge}
                      </span>
                    </div>
                  )}
                  <ChevronRight size={16} color={T.textTertiary} />
                </button>
              ))}
            </div>
          </div>
        ))}

        {/* Sign out */}
        <button
          onClick={() => navigate('/login')}
          style={{
            width: '100%',
            padding: '15px',
            backgroundColor: T.surface,
            border: `1.5px solid rgba(220,53,69,0.2)`,
            borderRadius: 16,
            color: '#DC3545',
            fontSize: 15,
            fontWeight: 600,
            cursor: 'pointer',
            fontFamily: fontStack,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 10,
          }}
        >
          <LogOut size={17} />
          Sair da conta
        </button>

        <p style={{ color: T.textTertiary, fontSize: 11, textAlign: 'center', marginTop: 16 }}>
          TechStudy v1.0.0 · Todos os direitos reservados
        </p>
      </div>
    </div>
  );
}
