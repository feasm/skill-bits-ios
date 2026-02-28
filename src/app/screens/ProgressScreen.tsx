import React from 'react';
import { useNavigate } from 'react-router';
import { Trophy, Flame, Clock, BookOpen, TrendingUp, Award } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell } from 'recharts';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';

const weekData = [
  { day: 'Seg', mins: 25 },
  { day: 'Ter', mins: 40 },
  { day: 'Qua', mins: 15 },
  { day: 'Qui', mins: 55 },
  { day: 'Sex', mins: 30 },
  { day: 'Sáb', mins: 10 },
  { day: 'Dom', mins: 45 },
];

const certificates = [
  {
    id: 'cert1',
    title: 'Fundamentos React',
    date: 'Jan 2026',
    color1: '#667EEA',
    color2: '#764BA2',
    icon: '⚛️',
  },
];

export function ProgressScreen() {
  const navigate = useNavigate();
  const maxMins = Math.max(...weekData.map((d) => d.mins));
  const totalThisWeek = weekData.reduce((a, b) => a + b.mins, 0);

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
          Progresso
        </h1>
        <p style={{ color: T.textTertiary, fontSize: 13 }}>
          Veja sua evolução detalhada
        </p>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '16px 24px 28px' }}>
        {/* Stats grid */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: '1fr 1fr',
            gap: 12,
            marginBottom: 20,
          }}
        >
          {[
            {
              icon: Flame,
              value: '7',
              label: 'Dias seguidos',
              color: '#F7971E',
              bg: 'rgba(247,151,30,0.1)',
              suffix: '🔥',
            },
            {
              icon: Clock,
              value: `${Math.round(totalThisWeek / 60)}h ${totalThisWeek % 60}min`,
              label: 'Esta semana',
              color: T.accent,
              bg: 'rgba(45,149,218,0.1)',
            },
            {
              icon: BookOpen,
              value: '8',
              label: 'Aulas concluídas',
              color: '#11998E',
              bg: 'rgba(17,153,142,0.1)',
            },
            {
              icon: Trophy,
              value: '1',
              label: 'Certificado',
              color: '#8B5CF6',
              bg: 'rgba(139,92,246,0.1)',
            },
          ].map((s, idx) => (
            <div
              key={idx}
              style={{
                backgroundColor: T.surface,
                borderRadius: 16,
                border: `1px solid ${T.border}`,
                padding: '16px',
              }}
            >
              <div
                style={{
                  width: 36,
                  height: 36,
                  borderRadius: 10,
                  backgroundColor: s.bg,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  marginBottom: 10,
                }}
              >
                <s.icon size={18} color={s.color} />
              </div>
              <p
                style={{
                  color: T.textPrimary,
                  fontSize: 22,
                  fontWeight: 800,
                  letterSpacing: '-0.5px',
                  marginBottom: 3,
                }}
              >
                {s.value}
              </p>
              <p style={{ color: T.textTertiary, fontSize: 12 }}>{s.label}</p>
            </div>
          ))}
        </div>

        {/* Weekly chart */}
        <div
          style={{
            backgroundColor: T.surface,
            borderRadius: 17,
            border: `1px solid ${T.border}`,
            padding: '18px',
            marginBottom: 20,
          }}
        >
          <div
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              marginBottom: 16,
            }}
          >
            <div>
              <p
                style={{
                  color: T.textPrimary,
                  fontSize: 15,
                  fontWeight: 700,
                  letterSpacing: '-0.3px',
                }}
              >
                Minutos estudados
              </p>
              <p style={{ color: T.textTertiary, fontSize: 12, marginTop: 2 }}>
                Últimos 7 dias
              </p>
            </div>
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 5,
                backgroundColor: 'rgba(17,153,142,0.08)',
                borderRadius: 10,
                padding: '5px 10px',
                border: '1px solid rgba(17,153,142,0.15)',
              }}
            >
              <TrendingUp size={13} color="#11998E" />
              <span style={{ color: '#11998E', fontSize: 12, fontWeight: 600 }}>+18%</span>
            </div>
          </div>

          <ResponsiveContainer width="100%" height={120}>
            <BarChart data={weekData} barSize={22}>
              <XAxis
                dataKey="day"
                axisLine={false}
                tickLine={false}
                tick={{ fill: T.textTertiary, fontSize: 11 }}
              />
              <YAxis hide />
              <Tooltip
                contentStyle={{
                  backgroundColor: T.surface,
                  border: `1px solid ${T.border}`,
                  borderRadius: 10,
                  padding: '6px 10px',
                  fontFamily: fontStack,
                  fontSize: 12,
                  color: T.textPrimary,
                  boxShadow: '0 4px 12px rgba(11,15,20,0.1)',
                }}
                formatter={(value: number) => [`${value} min`, 'Estudo']}
                cursor={{ fill: 'transparent' }}
              />
              <Bar dataKey="mins" radius={[8, 8, 0, 0]}>
                {weekData.map((entry, index) => (
                  <Cell
                    key={index}
                    fill={entry.mins === maxMins ? '#2D95DA' : '#E6EDF5'}
                  />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Course completion */}
        <div style={{ marginBottom: 20 }}>
          <p
            style={{
              color: T.textTertiary,
              fontSize: 13,
              fontWeight: 600,
              marginBottom: 12,
              letterSpacing: 0.2,
            }}
          >
            CURSOS EM ANDAMENTO
          </p>

          {[
            { title: 'Docker & Kubernetes na Prática', progress: 35, color1: '#40E0D0', color2: '#2D95DA', icon: '🐳' },
            { title: 'React & TypeScript Moderno', progress: 70, color1: '#667EEA', color2: '#764BA2', icon: '⚛️' },
          ].map((c, idx) => (
            <div
              key={idx}
              style={{
                backgroundColor: T.surface,
                borderRadius: 14,
                border: `1px solid ${T.border}`,
                padding: '14px 16px',
                marginBottom: 10,
                display: 'flex',
                gap: 12,
                alignItems: 'center',
              }}
            >
              <div
                style={{
                  width: 40,
                  height: 40,
                  borderRadius: 12,
                  background: `linear-gradient(135deg, ${c.color1} 0%, ${c.color2} 100%)`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: 20,
                  flexShrink: 0,
                }}
              >
                {c.icon}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <p
                  style={{
                    color: T.textPrimary,
                    fontSize: 13,
                    fontWeight: 600,
                    marginBottom: 6,
                    whiteSpace: 'nowrap',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                  }}
                >
                  {c.title}
                </p>
                <div
                  style={{
                    height: 5,
                    backgroundColor: T.border,
                    borderRadius: 3,
                    overflow: 'hidden',
                  }}
                >
                  <div
                    style={{
                      height: '100%',
                      width: `${c.progress}%`,
                      background: `linear-gradient(90deg, ${c.color1} 0%, ${c.color2} 100%)`,
                      borderRadius: 3,
                    }}
                  />
                </div>
              </div>
              <span
                style={{
                  color: T.accent,
                  fontSize: 13,
                  fontWeight: 700,
                  flexShrink: 0,
                }}
              >
                {c.progress}%
              </span>
            </div>
          ))}
        </div>

        {/* Certificates */}
        <div>
          <p
            style={{
              color: T.textTertiary,
              fontSize: 13,
              fontWeight: 600,
              marginBottom: 12,
              letterSpacing: 0.2,
            }}
          >
            CERTIFICADOS
          </p>

          {certificates.map((cert) => (
            <div
              key={cert.id}
              style={{
                backgroundColor: T.surface,
                borderRadius: 16,
                border: `1px solid ${T.border}`,
                padding: '16px',
                display: 'flex',
                gap: 14,
                alignItems: 'center',
                marginBottom: 10,
              }}
            >
              <div
                style={{
                  width: 48,
                  height: 48,
                  borderRadius: 14,
                  background: `linear-gradient(135deg, ${cert.color1} 0%, ${cert.color2} 100%)`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: 24,
                  flexShrink: 0,
                }}
              >
                {cert.icon}
              </div>
              <div style={{ flex: 1 }}>
                <p
                  style={{
                    color: T.textPrimary,
                    fontSize: 14,
                    fontWeight: 700,
                    marginBottom: 3,
                  }}
                >
                  {cert.title}
                </p>
                <p style={{ color: T.textTertiary, fontSize: 12 }}>
                  Concluído em {cert.date}
                </p>
              </div>
              <div
                style={{
                  width: 36,
                  height: 36,
                  borderRadius: 10,
                  backgroundColor: 'rgba(139,92,246,0.1)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <Award size={18} color="#8B5CF6" />
              </div>
            </div>
          ))}

          {/* Locked cert */}
          <div
            style={{
              backgroundColor: T.surface,
              borderRadius: 16,
              border: `1.5px dashed ${T.border}`,
              padding: '16px',
              display: 'flex',
              gap: 14,
              alignItems: 'center',
              opacity: 0.6,
            }}
          >
            <div
              style={{
                width: 48,
                height: 48,
                borderRadius: 14,
                backgroundColor: T.bg,
                border: `1px solid ${T.border}`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: 22,
              }}
            >
              🔒
            </div>
            <div>
              <p style={{ color: T.textSecondary, fontSize: 14, fontWeight: 600, marginBottom: 3 }}>
                Docker & Kubernetes
              </p>
              <p style={{ color: T.textTertiary, fontSize: 12 }}>
                Complete o curso para desbloquear
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
