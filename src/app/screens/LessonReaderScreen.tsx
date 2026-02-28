import React, { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import {
  ChevronLeft,
  Type,
  Headphones,
  CheckCircle,
  HelpCircle,
  X,
  Play,
  Pause,
  Plus,
  Minus,
  ChevronRight,
} from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';
import { PrimaryButton } from '../components/PrimaryButton';
import { lessonContent } from '../data/courses';

type FontSize = 'sm' | 'md' | 'lg' | 'xl';
type LineSpacing = 'compact' | 'normal' | 'relaxed';

const fontSizeMap: Record<FontSize, number> = { sm: 14, md: 16, lg: 18, xl: 20 };
const lineSpacingMap: Record<LineSpacing, number> = { compact: 1.5, normal: 1.75, relaxed: 2.1 };

export function LessonReaderScreen() {
  const { courseId, moduleId, lessonId } = useParams();
  const navigate = useNavigate();

  const [showFontSettings, setShowFontSettings] = useState(false);
  const [showAudioSheet, setShowAudioSheet] = useState(false);
  const [fontSize, setFontSize] = useState<FontSize>('md');
  const [lineSpacing, setLineSpacing] = useState<LineSpacing>('normal');
  const [fontFamily, setFontFamily] = useState<'system' | 'serif'>('system');
  const [isPlaying, setIsPlaying] = useState(false);
  const [speed, setSpeed] = useState(1.0);
  const [isCompleted, setIsCompleted] = useState(false);

  const fs = fontSizeMap[fontSize];
  const ls = lineSpacingMap[lineSpacing];
  const ff =
    fontFamily === 'serif'
      ? "Georgia, 'Times New Roman', serif"
      : fontStack;

  const adjustSpeed = (delta: number) => {
    setSpeed((s) => Math.round(Math.min(3.0, Math.max(0.5, s + delta)) * 10) / 10);
  };

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
        backgroundColor: T.surface,
        fontFamily: fontStack,
        overflow: 'hidden',
        position: 'relative',
      }}
    >
      {/* Navbar */}
      <div
        style={{
          backgroundColor: T.surface,
          borderBottom: `1px solid ${T.border}`,
          flexShrink: 0,
        }}
      >
        <StatusBar />
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            padding: '0 20px 14px',
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
          <div style={{ flex: 1 }}>
            <p style={{ color: T.textTertiary, fontSize: 11, marginBottom: 1 }}>Módulo 1</p>
            <p
              style={{
                color: T.textPrimary,
                fontSize: 14,
                fontWeight: 600,
                letterSpacing: '-0.2px',
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
              }}
            >
              {lessonContent.title}
            </p>
          </div>
          <button
            onClick={() => setShowFontSettings(true)}
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
            <Type size={17} color={T.textSecondary} />
          </button>
        </div>
      </div>

      {/* Reading area */}
      <div style={{ flex: 1, overflowY: 'auto' }}>
        <div style={{ padding: '24px 22px 12px', maxWidth: 360, margin: '0 auto' }}>
          {/* Read time */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 8,
              marginBottom: 20,
            }}
          >
            <div
              style={{
                padding: '4px 12px',
                borderRadius: 8,
                backgroundColor: 'rgba(45,149,218,0.08)',
                border: '1px solid rgba(45,149,218,0.15)',
              }}
            >
              <span style={{ color: T.accent, fontSize: 12, fontWeight: 600 }}>
                Aula 1 · {lessonContent.readTime}
              </span>
            </div>
          </div>

          {/* Content */}
          {lessonContent.content.map((block, idx) => {
            if (block.type === 'heading') {
              return (
                <h1
                  key={idx}
                  style={{
                    fontFamily: ff,
                    fontSize: fs + 8,
                    fontWeight: 800,
                    color: T.textPrimary,
                    lineHeight: 1.3,
                    marginBottom: 16,
                    letterSpacing: '-0.5px',
                  }}
                >
                  {block.text}
                </h1>
              );
            }
            if (block.type === 'heading2') {
              return (
                <h2
                  key={idx}
                  style={{
                    fontFamily: ff,
                    fontSize: fs + 4,
                    fontWeight: 700,
                    color: T.textPrimary,
                    lineHeight: 1.35,
                    marginTop: 24,
                    marginBottom: 12,
                    letterSpacing: '-0.3px',
                  }}
                >
                  {block.text}
                </h2>
              );
            }
            if (block.type === 'paragraph') {
              return (
                <p
                  key={idx}
                  style={{
                    fontFamily: ff,
                    fontSize: fs,
                    color: T.textSecondary,
                    lineHeight: ls,
                    marginBottom: 16,
                  }}
                >
                  {block.text}
                </p>
              );
            }
            if (block.type === 'list' && block.items) {
              return (
                <ul
                  key={idx}
                  style={{ paddingLeft: 0, marginBottom: 16, listStyle: 'none' }}
                >
                  {block.items.map((item, i) => (
                    <li
                      key={i}
                      style={{
                        display: 'flex',
                        gap: 10,
                        marginBottom: 10,
                        alignItems: 'flex-start',
                      }}
                    >
                      <div
                        style={{
                          width: 6,
                          height: 6,
                          borderRadius: 3,
                          background: gradient,
                          marginTop: fs * ls * 0.5 - 3,
                          flexShrink: 0,
                        }}
                      />
                      <span
                        style={{
                          fontFamily: ff,
                          fontSize: fs,
                          color: T.textSecondary,
                          lineHeight: ls,
                          flex: 1,
                        }}
                      >
                        {item}
                      </span>
                    </li>
                  ))}
                </ul>
              );
            }
            if (block.type === 'code') {
              return (
                <div
                  key={idx}
                  style={{
                    backgroundColor: '#1A2235',
                    borderRadius: 14,
                    marginBottom: 20,
                    overflow: 'hidden',
                    border: '1px solid rgba(255,255,255,0.06)',
                  }}
                >
                  <div
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '10px 16px',
                      borderBottom: '1px solid rgba(255,255,255,0.08)',
                    }}
                  >
                    <span
                      style={{
                        color: 'rgba(255,255,255,0.5)',
                        fontSize: 11,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                        textTransform: 'uppercase',
                      }}
                    >
                      {block.language}
                    </span>
                    <div style={{ display: 'flex', gap: 5 }}>
                      {['#FF5F57', '#FEBC2E', '#28C840'].map((c) => (
                        <div
                          key={c}
                          style={{ width: 10, height: 10, borderRadius: 5, backgroundColor: c }}
                        />
                      ))}
                    </div>
                  </div>
                  <pre
                    style={{
                      margin: 0,
                      padding: '14px 16px',
                      overflowX: 'auto',
                      fontFamily: "'SF Mono', 'Fira Code', 'Fira Mono', monospace",
                      fontSize: 12.5,
                      lineHeight: 1.7,
                      color: '#E2E8F4',
                    }}
                  >
                    <code>{block.text}</code>
                  </pre>
                </div>
              );
            }
            return null;
          })}
        </div>

        {/* Action section */}
        <div
          style={{
            margin: '8px 20px 24px',
            backgroundColor: T.bg,
            borderRadius: 16,
            border: `1px solid ${T.border}`,
            overflow: 'hidden',
          }}
        >
          <p
            style={{
              padding: '14px 16px 10px',
              color: T.textTertiary,
              fontSize: 12,
              fontWeight: 600,
              letterSpacing: 0.5,
              textTransform: 'uppercase',
              borderBottom: `1px solid ${T.border}`,
            }}
          >
            Ações
          </p>

          {[
            {
              icon: Headphones,
              label: 'Ouvir o texto',
              color: '#2D95DA',
              bg: 'rgba(45,149,218,0.08)',
              action: () => setShowAudioSheet(true),
            },
            {
              icon: CheckCircle,
              label: isCompleted ? 'Aula concluída ✓' : 'Marcar como concluída',
              color: isCompleted ? '#11998E' : T.textSecondary,
              bg: isCompleted ? 'rgba(17,153,142,0.08)' : T.bg,
              action: () => setIsCompleted(true),
            },
            {
              icon: HelpCircle,
              label: 'Iniciar questionário',
              color: '#8B5CF6',
              bg: 'rgba(139,92,246,0.08)',
              action: () =>
                navigate('/quiz-intro', {
                  state: { courseId, moduleId },
                }),
            },
          ].map((item, idx, arr) => (
            <button
              key={idx}
              onClick={item.action}
              style={{
                width: '100%',
                display: 'flex',
                alignItems: 'center',
                gap: 14,
                padding: '14px 16px',
                background: 'none',
                border: 'none',
                borderBottom: idx < arr.length - 1 ? `1px solid ${T.border}` : 'none',
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
                  backgroundColor: item.bg,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                }}
              >
                <item.icon size={18} color={item.color} />
              </div>
              <span style={{ color: item.color, fontSize: 14, fontWeight: 600, flex: 1 }}>
                {item.label}
              </span>
              <ChevronRight size={16} color={T.textTertiary} />
            </button>
          ))}
        </div>

        {/* Next lesson */}
        <div style={{ padding: '0 20px 32px' }}>
          <PrimaryButton
            onClick={() =>
              navigate('/next-lesson', { state: { courseId, moduleId } })
            }
          >
            Concluir e continuar →
          </PrimaryButton>
        </div>
      </div>

      {/* Font Settings Bottom Sheet */}
      {showFontSettings && (
        <div
          style={{
            position: 'absolute',
            inset: 0,
            backgroundColor: 'rgba(11,15,20,0.45)',
            display: 'flex',
            alignItems: 'flex-end',
            zIndex: 100,
          }}
          onClick={(e) => {
            if (e.target === e.currentTarget) setShowFontSettings(false);
          }}
        >
          <div
            style={{
              width: '100%',
              backgroundColor: T.surface,
              borderRadius: '20px 20px 0 0',
              padding: '0 24px 40px',
            }}
          >
            {/* Handle */}
            <div
              style={{
                width: 36,
                height: 4,
                backgroundColor: T.border,
                borderRadius: 2,
                margin: '12px auto 20px',
              }}
            />

            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                marginBottom: 24,
              }}
            >
              <h3
                style={{
                  color: T.textPrimary,
                  fontSize: 17,
                  fontWeight: 700,
                  letterSpacing: '-0.3px',
                }}
              >
                Preferências de leitura
              </h3>
              <button
                onClick={() => setShowFontSettings(false)}
                style={{
                  background: T.bg,
                  border: `1px solid ${T.border}`,
                  borderRadius: 20,
                  width: 32,
                  height: 32,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
              >
                <X size={16} color={T.textSecondary} />
              </button>
            </div>

            {/* Font family */}
            <SettingSection label="Fonte">
              <div style={{ display: 'flex', gap: 10 }}>
                {(['system', 'serif'] as const).map((f) => (
                  <button
                    key={f}
                    onClick={() => setFontFamily(f)}
                    style={{
                      flex: 1,
                      padding: '12px',
                      borderRadius: 12,
                      border: `1.5px solid ${fontFamily === f ? T.accent : T.border}`,
                      backgroundColor: fontFamily === f ? 'rgba(45,149,218,0.06)' : T.bg,
                      cursor: 'pointer',
                      fontFamily: f === 'serif' ? 'Georgia, serif' : fontStack,
                      color: fontFamily === f ? T.accent : T.textSecondary,
                      fontSize: 15,
                      fontWeight: 600,
                    }}
                  >
                    {f === 'system' ? 'SF Pro' : 'Serif'}
                  </button>
                ))}
              </div>
            </SettingSection>

            {/* Font size */}
            <SettingSection label="Tamanho do texto">
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  gap: 8,
                }}
              >
                <span style={{ color: T.textTertiary, fontSize: 13 }}>A</span>
                {(['sm', 'md', 'lg', 'xl'] as FontSize[]).map((s) => (
                  <button
                    key={s}
                    onClick={() => setFontSize(s)}
                    style={{
                      flex: 1,
                      height: 36,
                      borderRadius: 10,
                      border: `1.5px solid ${fontSize === s ? T.accent : T.border}`,
                      backgroundColor: fontSize === s ? T.accent : T.bg,
                      color: fontSize === s ? '#fff' : T.textSecondary,
                      cursor: 'pointer',
                      fontSize: { sm: 13, md: 15, lg: 17, xl: 19 }[s],
                      fontWeight: 600,
                    }}
                  >
                    A
                  </button>
                ))}
                <span style={{ color: T.textTertiary, fontSize: 19 }}>A</span>
              </div>
            </SettingSection>

            {/* Line spacing */}
            <SettingSection label="Espaçamento de linha">
              <div style={{ display: 'flex', gap: 10 }}>
                {(['compact', 'normal', 'relaxed'] as LineSpacing[]).map((s) => (
                  <button
                    key={s}
                    onClick={() => setLineSpacing(s)}
                    style={{
                      flex: 1,
                      padding: '10px 6px',
                      borderRadius: 12,
                      border: `1.5px solid ${lineSpacing === s ? T.accent : T.border}`,
                      backgroundColor: lineSpacing === s ? 'rgba(45,149,218,0.06)' : T.bg,
                      cursor: 'pointer',
                      color: lineSpacing === s ? T.accent : T.textSecondary,
                      fontSize: 12,
                      fontWeight: 600,
                    }}
                  >
                    {s === 'compact' ? 'Compacto' : s === 'normal' ? 'Normal' : 'Espaçado'}
                  </button>
                ))}
              </div>
            </SettingSection>
          </div>
        </div>
      )}

      {/* Audio Bottom Sheet */}
      {showAudioSheet && (
        <div
          style={{
            position: 'absolute',
            inset: 0,
            backgroundColor: 'rgba(11,15,20,0.45)',
            display: 'flex',
            alignItems: 'flex-end',
            zIndex: 100,
          }}
          onClick={(e) => {
            if (e.target === e.currentTarget) setShowAudioSheet(false);
          }}
        >
          <div
            style={{
              width: '100%',
              backgroundColor: T.surface,
              borderRadius: '20px 20px 0 0',
              padding: '0 24px 44px',
            }}
          >
            <div
              style={{
                width: 36,
                height: 4,
                backgroundColor: T.border,
                borderRadius: 2,
                margin: '12px auto 20px',
              }}
            />

            {/* Title */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                marginBottom: 8,
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <div
                  style={{
                    width: 40,
                    height: 40,
                    borderRadius: 12,
                    background: gradient,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <Headphones size={18} color="#fff" />
                </div>
                <div>
                  <p style={{ color: T.textPrimary, fontSize: 15, fontWeight: 700 }}>
                    Ouvir o texto
                  </p>
                  <p style={{ color: T.textTertiary, fontSize: 12, marginTop: 1 }}>
                    Narração automática
                  </p>
                </div>
              </div>
              <button
                onClick={() => setShowAudioSheet(false)}
                style={{
                  background: T.bg,
                  border: `1px solid ${T.border}`,
                  borderRadius: 20,
                  width: 32,
                  height: 32,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
              >
                <X size={16} color={T.textSecondary} />
              </button>
            </div>

            {/* Progress bar */}
            <div style={{ margin: '20px 0 8px' }}>
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
                    width: isPlaying ? '35%' : '35%',
                    background: gradient,
                    borderRadius: 2,
                  }}
                />
              </div>
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  marginTop: 8,
                }}
              >
                <span style={{ color: T.textTertiary, fontSize: 12 }}>4:12</span>
                <span style={{ color: T.textTertiary, fontSize: 12 }}>12:00</span>
              </div>
            </div>

            {/* Controls */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: 20,
                margin: '20px 0',
              }}
            >
              {/* Speed - */}
              <button
                onClick={() => adjustSpeed(-0.25)}
                style={{
                  width: 40,
                  height: 40,
                  borderRadius: 20,
                  backgroundColor: T.bg,
                  border: `1px solid ${T.border}`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
              >
                <Minus size={16} color={T.textSecondary} />
              </button>

              {/* Speed display */}
              <div
                style={{
                  minWidth: 48,
                  textAlign: 'center',
                  backgroundColor: T.bg,
                  borderRadius: 10,
                  padding: '6px 10px',
                  border: `1px solid ${T.border}`,
                }}
              >
                <span
                  style={{
                    color: T.textPrimary,
                    fontSize: 14,
                    fontWeight: 700,
                  }}
                >
                  {speed.toFixed(1)}×
                </span>
              </div>

              {/* Play/Pause */}
              <button
                onClick={() => setIsPlaying(!isPlaying)}
                style={{
                  width: 60,
                  height: 60,
                  borderRadius: 30,
                  background: gradient,
                  border: 'none',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  boxShadow: '0 6px 20px rgba(45,149,218,0.3)',
                }}
              >
                {isPlaying ? (
                  <Pause size={24} color="#fff" fill="#fff" />
                ) : (
                  <Play size={24} color="#fff" fill="#fff" style={{ marginLeft: 3 }} />
                )}
              </button>

              {/* Speed display */}
              <div style={{ minWidth: 48, textAlign: 'center' }}>
                <span style={{ color: T.textTertiary, fontSize: 12 }}>velocidade</span>
              </div>

              {/* Speed + */}
              <button
                onClick={() => adjustSpeed(0.25)}
                style={{
                  width: 40,
                  height: 40,
                  borderRadius: 20,
                  backgroundColor: T.bg,
                  border: `1px solid ${T.border}`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
              >
                <Plus size={16} color={T.textSecondary} />
              </button>
            </div>

            <button
              onClick={() => setShowAudioSheet(false)}
              style={{
                width: '100%',
                padding: '15px',
                backgroundColor: T.bg,
                border: `1.5px solid ${T.border}`,
                borderRadius: 16,
                color: T.textSecondary,
                fontSize: 15,
                fontWeight: 600,
                cursor: 'pointer',
                fontFamily: fontStack,
              }}
            >
              Fechar
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

function SettingSection({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div style={{ marginBottom: 20 }}>
      <p style={{ color: T.textTertiary, fontSize: 12, fontWeight: 600, marginBottom: 10, letterSpacing: 0.3 }}>
        {label.toUpperCase()}
      </p>
      {children}
    </div>
  );
}
