import React from 'react';
import { useNavigate } from 'react-router';
import { ChevronLeft, AlertCircle, ChevronRight, BookOpen } from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';
import { PrimaryButton } from '../components/PrimaryButton';

const weakPoints = [
  {
    id: 'wp1',
    topic: 'Diferença entre imagem e container',
    description:
      'Você errou questões relacionadas ao ciclo de vida de imagens e containers Docker.',
    excerpt:
      'Uma imagem é um template imutável (read-only). Containers são instâncias executáveis criadas a partir de imagens...',
    section: 'Aula 1 · Seção: Anatomia de um container',
    difficulty: 'Básico',
  },
  {
    id: 'wp2',
    topic: 'Volumes Docker e persistência',
    description: 'Questões sobre persistência de dados e ciclo de vida de volumes incorretas.',
    excerpt:
      'Volumes permitem persistir e compartilhar dados entre containers e o sistema de arquivos do host...',
    section: 'Módulo 2 · Seção: Volumes e Persistência',
    difficulty: 'Intermediário',
  },
  {
    id: 'wp3',
    topic: 'Instrução FROM no Dockerfile',
    description: 'A instrução FROM foi confundida com outras instruções de cópia.',
    excerpt:
      'FROM define qual imagem base será usada como ponto de partida para o build da sua imagem...',
    section: 'Aula 1 · Seção: Dockerfile básico',
    difficulty: 'Básico',
  },
];

export function GuidedReviewScreen() {
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
      <div
        style={{
          backgroundColor: T.surface,
          borderBottom: `1px solid ${T.border}`,
          flexShrink: 0,
        }}
      >
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
          <div>
            <h1
              style={{
                color: T.textPrimary,
                fontSize: 17,
                fontWeight: 700,
                letterSpacing: '-0.3px',
              }}
            >
              Revisão Guiada
            </h1>
            <p style={{ color: T.textTertiary, fontSize: 12, marginTop: 1 }}>
              Pontos que precisam de atenção
            </p>
          </div>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '20px' }}>
        {/* Header info */}
        <div
          style={{
            backgroundColor: 'rgba(139,92,246,0.07)',
            borderRadius: 14,
            border: '1px solid rgba(139,92,246,0.2)',
            padding: '14px 16px',
            display: 'flex',
            gap: 12,
            alignItems: 'center',
            marginBottom: 20,
          }}
        >
          <AlertCircle size={20} color="#8B5CF6" style={{ flexShrink: 0 }} />
          <div>
            <p style={{ color: '#8B5CF6', fontSize: 14, fontWeight: 600, marginBottom: 3 }}>
              {weakPoints.length} tópicos identificados
            </p>
            <p style={{ color: T.textSecondary, fontSize: 13, lineHeight: 1.5 }}>
              Revise os trechos abaixo para fixar o conteúdo antes de refazer o quiz.
            </p>
          </div>
        </div>

        {/* Weak points list */}
        {weakPoints.map((wp, idx) => (
          <div
            key={wp.id}
            style={{
              backgroundColor: T.surface,
              borderRadius: 16,
              border: `1px solid ${T.border}`,
              marginBottom: 14,
              overflow: 'hidden',
            }}
          >
            {/* Header */}
            <div
              style={{
                padding: '14px 16px',
                borderBottom: `1px solid ${T.border}`,
                display: 'flex',
                alignItems: 'flex-start',
                gap: 12,
              }}
            >
              <div
                style={{
                  width: 32,
                  height: 32,
                  borderRadius: 10,
                  background:
                    wp.difficulty === 'Básico'
                      ? 'rgba(17,153,142,0.1)'
                      : 'rgba(232,151,61,0.1)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                  marginTop: 1,
                }}
              >
                <span style={{ fontSize: 14, fontWeight: 700, color: wp.difficulty === 'Básico' ? '#11998E' : '#E8973D' }}>
                  {idx + 1}
                </span>
              </div>
              <div style={{ flex: 1 }}>
                <p
                  style={{
                    color: T.textPrimary,
                    fontSize: 14,
                    fontWeight: 700,
                    marginBottom: 4,
                    letterSpacing: '-0.2px',
                  }}
                >
                  {wp.topic}
                </p>
                <p style={{ color: T.textSecondary, fontSize: 13, lineHeight: 1.5 }}>
                  {wp.description}
                </p>
              </div>
              <span
                style={{
                  padding: '3px 9px',
                  borderRadius: 6,
                  fontSize: 11,
                  fontWeight: 600,
                  backgroundColor:
                    wp.difficulty === 'Básico'
                      ? 'rgba(17,153,142,0.08)'
                      : 'rgba(232,151,61,0.08)',
                  color: wp.difficulty === 'Básico' ? '#11998E' : '#E8973D',
                  flexShrink: 0,
                }}
              >
                {wp.difficulty}
              </span>
            </div>

            {/* Excerpt */}
            <div
              style={{
                padding: '12px 16px',
                backgroundColor: T.bg,
                borderBottom: `1px solid ${T.border}`,
              }}
            >
              <p style={{ color: T.textTertiary, fontSize: 11, fontWeight: 600, marginBottom: 7, letterSpacing: 0.3 }}>
                TRECHO RELEVANTE
              </p>
              <p
                style={{
                  color: T.textSecondary,
                  fontSize: 13,
                  lineHeight: 1.65,
                  fontStyle: 'italic',
                }}
              >
                "{wp.excerpt}"
              </p>
            </div>

            {/* CTA */}
            <button
              onClick={() => navigate(`/app/courses/c1/modules/m1/lessons/l1`)}
              style={{
                width: '100%',
                padding: '12px 16px',
                display: 'flex',
                alignItems: 'center',
                gap: 10,
                background: 'none',
                border: 'none',
                cursor: 'pointer',
                fontFamily: fontStack,
                textAlign: 'left',
              }}
            >
              <BookOpen size={16} color={T.accent} />
              <span style={{ color: T.accent, fontSize: 13, fontWeight: 600, flex: 1 }}>
                Ver trecho no conteúdo
              </span>
              <p style={{ color: T.textTertiary, fontSize: 11 }}>{wp.section}</p>
              <ChevronRight size={14} color={T.textTertiary} />
            </button>
          </div>
        ))}

        {/* CTA */}
        <div style={{ marginTop: 8 }}>
          <PrimaryButton
            onClick={() =>
              navigate('/quiz-intro', { state: { courseId: 'c1', moduleId: 'm1' } })
            }
          >
            Refazer questionário
          </PrimaryButton>

          <button
            onClick={() => navigate('/app/courses')}
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
            Voltar aos cursos
          </button>
        </div>
      </div>
    </div>
  );
}
