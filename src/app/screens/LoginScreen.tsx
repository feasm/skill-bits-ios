import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { Eye, EyeOff, Mail, Lock } from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';
import { PrimaryButton } from '../components/PrimaryButton';

export function LoginScreen() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [focusedField, setFocusedField] = useState<string | null>(null);

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

      <div style={{ flex: 1, overflowY: 'auto', padding: '0 24px' }}>
        {/* Logo */}
        <div style={{ display: 'flex', justifyContent: 'center', marginTop: 40, marginBottom: 32 }}>
          <div
            style={{
              width: 76,
              height: 76,
              background: gradient,
              borderRadius: 22,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: '0 12px 32px rgba(45,149,218,0.28)',
            }}
          >
            <svg width="38" height="38" viewBox="0 0 24 24" fill="none">
              <path
                d="M12 3L2 8l10 5 10-5-10-5z"
                stroke="white"
                strokeWidth="2"
                strokeLinejoin="round"
                fill="rgba(255,255,255,0.2)"
              />
              <path d="M2 16l10 5 10-5" stroke="white" strokeWidth="2" strokeLinejoin="round" />
              <path d="M2 12l10 5 10-5" stroke="white" strokeWidth="2" strokeLinejoin="round" />
            </svg>
          </div>
        </div>

        {/* Title */}
        <h1
          style={{
            color: T.textPrimary,
            fontSize: 30,
            fontWeight: 700,
            marginBottom: 8,
            textAlign: 'center',
            letterSpacing: '-0.5px',
          }}
        >
          Bem-vindo
        </h1>
        <p
          style={{
            color: T.textSecondary,
            fontSize: 16,
            textAlign: 'center',
            marginBottom: 36,
            lineHeight: 1.5,
          }}
        >
          Faça login para continuar estudando
        </p>

        {/* Email field */}
        <div style={{ marginBottom: 14 }}>
          <label
            style={{
              display: 'block',
              color: T.textSecondary,
              fontSize: 14,
              marginBottom: 7,
              fontWeight: 500,
            }}
          >
            Email
          </label>
          <div style={{ position: 'relative' }}>
            <Mail
              size={18}
              style={{
                position: 'absolute',
                left: 15,
                top: '50%',
                transform: 'translateY(-50%)',
                color: focusedField === 'email' ? '#2D95DA' : T.textTertiary,
                transition: 'color 0.2s',
              }}
            />
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              onFocus={() => setFocusedField('email')}
              onBlur={() => setFocusedField(null)}
              placeholder="seu@email.com"
              style={{
                width: '100%',
                padding: '14px 16px 14px 44px',
                backgroundColor: T.inputBg,
                border: `1.5px solid ${focusedField === 'email' ? '#2D95DA' : T.inputBorder}`,
                borderRadius: 14,
                fontSize: 16,
                color: T.textPrimary,
                fontFamily: fontStack,
                outline: 'none',
                boxSizing: 'border-box',
                transition: 'border-color 0.2s',
              }}
            />
          </div>
        </div>

        {/* Password field */}
        <div style={{ marginBottom: 12 }}>
          <label
            style={{
              display: 'block',
              color: T.textSecondary,
              fontSize: 14,
              marginBottom: 7,
              fontWeight: 500,
            }}
          >
            Senha
          </label>
          <div style={{ position: 'relative' }}>
            <Lock
              size={18}
              style={{
                position: 'absolute',
                left: 15,
                top: '50%',
                transform: 'translateY(-50%)',
                color: focusedField === 'password' ? '#2D95DA' : T.textTertiary,
                transition: 'color 0.2s',
              }}
            />
            <input
              type={showPassword ? 'text' : 'password'}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              onFocus={() => setFocusedField('password')}
              onBlur={() => setFocusedField(null)}
              placeholder="••••••••"
              style={{
                width: '100%',
                padding: '14px 48px 14px 44px',
                backgroundColor: T.inputBg,
                border: `1.5px solid ${focusedField === 'password' ? '#2D95DA' : T.inputBorder}`,
                borderRadius: 14,
                fontSize: 16,
                color: T.textPrimary,
                fontFamily: fontStack,
                outline: 'none',
                boxSizing: 'border-box',
                transition: 'border-color 0.2s',
              }}
            />
            <button
              onClick={() => setShowPassword(!showPassword)}
              style={{
                position: 'absolute',
                right: 15,
                top: '50%',
                transform: 'translateY(-50%)',
                background: 'none',
                border: 'none',
                cursor: 'pointer',
                color: T.textTertiary,
                padding: 0,
                display: 'flex',
              }}
            >
              {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
            </button>
          </div>
        </div>

        {/* Forgot password */}
        <div style={{ textAlign: 'right', marginBottom: 28 }}>
          <button
            style={{
              background: 'none',
              border: 'none',
              color: T.accent,
              fontSize: 14,
              cursor: 'pointer',
              padding: 0,
              fontFamily: fontStack,
              fontWeight: 500,
            }}
          >
            Esqueci minha senha
          </button>
        </div>

        {/* Primary button */}
        <PrimaryButton onClick={() => navigate('/app/courses')} size="lg">
          Entrar
        </PrimaryButton>

        {/* Divider */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, margin: '20px 0' }}>
          <div style={{ flex: 1, height: 1, backgroundColor: T.border }} />
          <span style={{ color: T.textTertiary, fontSize: 13 }}>ou continue com</span>
          <div style={{ flex: 1, height: 1, backgroundColor: T.border }} />
        </div>

        {/* Apple sign-in */}
        <button
          style={{
            width: '100%',
            padding: '16px',
            backgroundColor: T.surface,
            border: `1.5px solid ${T.border}`,
            borderRadius: 17,
            color: T.textPrimary,
            fontSize: 16,
            fontWeight: 600,
            cursor: 'pointer',
            fontFamily: fontStack,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 10,
            letterSpacing: '-0.2px',
          }}
        >
          <svg width="18" height="22" viewBox="0 0 814 1000">
            <path
              d="M788.1 340.9c-5.8 4.5-108.2 62.2-108.2 190.5 0 148.4 130.3 200.9 134.2 202.2-.6 3.2-20.7 71.9-68.7 141.9-42.8 61.6-87.5 123.1-155.5 123.1s-85.5-39.5-164-39.5c-76 0-103.7 40.8-165.9 40.8s-105-37.5-150.3-105.5C88.3 716.7 46.4 638.5 46.4 509.9c0-236.4 153.8-357.5 303.8-357.5 101.2 0 185.5 67.2 249.2 67.2 60.8 0 155.2-71.4 269.3-71.4 19.9 0 154.2 2 238.4 118.8zm-198.5-160.6c-48.2 57.6-107.8 97.4-168.4 97.4-9 0-14.7-.6-21.7-2.3-1.3-9.4-1.3-18.8-1.3-28.2 0-62.3 26-124.2 68.7-169.7 45.5-48.8 119.5-85.5 187.5-88.9 1.3 11.5 1.9 23.1 1.9 34 0 60.2-22.4 122.8-66.7 157.7z"
              fill="#0B0F14"
            />
          </svg>
          Entrar com Apple
        </button>

        {/* Create account */}
        <div style={{ textAlign: 'center', marginTop: 20, marginBottom: 8 }}>
          <span style={{ color: T.textSecondary, fontSize: 14 }}>Não tem uma conta? </span>
          <button
            style={{
              background: 'none',
              border: 'none',
              color: T.accent,
              fontSize: 14,
              cursor: 'pointer',
              padding: 0,
              fontFamily: fontStack,
              fontWeight: 600,
            }}
          >
            Criar conta grátis
          </button>
        </div>
      </div>

      {/* Terms */}
      <div style={{ padding: '12px 28px 28px', textAlign: 'center', flexShrink: 0 }}>
        <p style={{ color: T.textTertiary, fontSize: 12, lineHeight: 1.7 }}>
          Ao continuar, você concorda com os{' '}
          <span style={{ color: T.accent }}>Termos de Uso</span> e a{' '}
          <span style={{ color: T.accent }}>Política de Privacidade</span>.
        </p>
      </div>
    </div>
  );
}
