import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router';
import { ChevronLeft, CheckCircle2, XCircle, ChevronRight } from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';
import { PrimaryButton } from '../components/PrimaryButton';
import { quizQuestions } from '../data/courses';

type AnswerState = 'idle' | 'correct' | 'incorrect';

export function QuizQuestionScreen() {
  const navigate = useNavigate();
  const location = useLocation();
  const state = (location.state as any) || {};

  const [currentIndex, setCurrentIndex] = useState(0);
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [answerState, setAnswerState] = useState<AnswerState>('idle');
  const [correctCount, setCorrectCount] = useState(0);

  const total = quizQuestions.length;
  const question = quizQuestions[currentIndex];
  const progress = ((currentIndex + 1) / total) * 100;

  const handleConfirm = () => {
    if (selectedOption === null) return;
    const isCorrect = selectedOption === question.correctIndex;
    setAnswerState(isCorrect ? 'correct' : 'incorrect');
    if (isCorrect) setCorrectCount((c) => c + 1);
  };

  const handleNext = () => {
    if (currentIndex < total - 1) {
      setCurrentIndex((i) => i + 1);
      setSelectedOption(null);
      setAnswerState('idle');
    } else {
      const finalScore = Math.round(
        ((correctCount + (answerState === 'correct' ? 0 : 0)) / total) * 100
      );
      const score =
        answerState === 'correct'
          ? Math.round(((correctCount) / total) * 100)
          : Math.round(((correctCount) / total) * 100);
      navigate('/quiz-result', {
        state: {
          score,
          correctCount,
          total,
          courseId: state.courseId,
          moduleId: state.moduleId,
        },
      });
    }
  };

  const optionLabel = ['A', 'B', 'C', 'D'];

  const getOptionStyle = (idx: number): React.CSSProperties => {
    const base: React.CSSProperties = {
      width: '100%',
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '14px 16px',
      borderRadius: 14,
      border: '1.5px solid',
      cursor: answerState !== 'idle' ? 'default' : 'pointer',
      background: 'none',
      fontFamily: fontStack,
      textAlign: 'left',
      transition: 'all 0.2s ease',
      marginBottom: 10,
    };

    if (answerState === 'idle') {
      return {
        ...base,
        backgroundColor: selectedOption === idx ? 'rgba(45,149,218,0.06)' : T.surface,
        borderColor: selectedOption === idx ? T.accent : T.border,
      };
    }

    // After confirming
    if (idx === question.correctIndex) {
      return {
        ...base,
        backgroundColor: 'rgba(17,153,142,0.07)',
        borderColor: 'rgba(17,153,142,0.4)',
      };
    }
    if (idx === selectedOption && answerState === 'incorrect') {
      return {
        ...base,
        backgroundColor: 'rgba(220,53,69,0.05)',
        borderColor: 'rgba(220,53,69,0.3)',
      };
    }
    return {
      ...base,
      backgroundColor: T.surface,
      borderColor: T.border,
      opacity: 0.5,
    };
  };

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
      {/* Header */}
      <div style={{ backgroundColor: T.surface, borderBottom: `1px solid ${T.border}`, flexShrink: 0 }}>
        <StatusBar />
        <div style={{ padding: '0 20px 14px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 14 }}>
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
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: 8,
                }}
              >
                <span style={{ color: T.textSecondary, fontSize: 14, fontWeight: 600 }}>
                  Pergunta {currentIndex + 1} de {total}
                </span>
                <span style={{ color: T.accent, fontSize: 13, fontWeight: 600 }}>
                  {correctCount} ✓
                </span>
              </div>
              {/* Progress bar */}
              <div
                style={{
                  height: 6,
                  backgroundColor: T.border,
                  borderRadius: 3,
                  overflow: 'hidden',
                }}
              >
                <div
                  style={{
                    height: '100%',
                    width: `${progress}%`,
                    background: gradient,
                    borderRadius: 3,
                    transition: 'width 0.3s ease',
                  }}
                />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '20px 20px 24px' }}>
        {/* Question */}
        <div
          style={{
            backgroundColor: T.surface,
            borderRadius: 16,
            border: `1px solid ${T.border}`,
            padding: '20px',
            marginBottom: 20,
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
            PERGUNTA {currentIndex + 1}
          </p>
          <p
            style={{
              color: T.textPrimary,
              fontSize: 17,
              fontWeight: 600,
              lineHeight: 1.55,
              letterSpacing: '-0.2px',
            }}
          >
            {question.question}
          </p>
        </div>

        {/* Options */}
        {question.options.map((opt, idx) => (
          <button
            key={idx}
            onClick={() => answerState === 'idle' && setSelectedOption(idx)}
            style={getOptionStyle(idx)}
          >
            {/* Label badge */}
            <div
              style={{
                width: 32,
                height: 32,
                borderRadius: 10,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexShrink: 0,
                backgroundColor:
                  answerState !== 'idle' && idx === question.correctIndex
                    ? 'rgba(17,153,142,0.15)'
                    : answerState !== 'idle' && idx === selectedOption && answerState === 'incorrect'
                    ? 'rgba(220,53,69,0.1)'
                    : selectedOption === idx
                    ? 'rgba(45,149,218,0.12)'
                    : T.bg,
              }}
            >
              {answerState !== 'idle' && idx === question.correctIndex ? (
                <CheckCircle2 size={16} color="#11998E" />
              ) : answerState !== 'idle' &&
                idx === selectedOption &&
                answerState === 'incorrect' ? (
                <XCircle size={16} color="#DC3545" />
              ) : (
                <span
                  style={{
                    fontSize: 13,
                    fontWeight: 700,
                    color:
                      selectedOption === idx ? T.accent : T.textTertiary,
                  }}
                >
                  {optionLabel[idx]}
                </span>
              )}
            </div>

            <span
              style={{
                color:
                  answerState !== 'idle' && idx === question.correctIndex
                    ? '#11998E'
                    : answerState !== 'idle' &&
                      idx === selectedOption &&
                      answerState === 'incorrect'
                    ? '#DC3545'
                    : T.textPrimary,
                fontSize: 14,
                fontWeight:
                  answerState !== 'idle' && idx === question.correctIndex ? 600 : 400,
                lineHeight: 1.5,
                flex: 1,
              }}
            >
              {opt}
            </span>
          </button>
        ))}

        {/* Feedback */}
        {answerState !== 'idle' && (
          <div
            style={{
              backgroundColor:
                answerState === 'correct' ? 'rgba(17,153,142,0.07)' : 'rgba(220,53,69,0.05)',
              borderRadius: 14,
              border: `1.5px solid ${answerState === 'correct' ? 'rgba(17,153,142,0.3)' : 'rgba(220,53,69,0.2)'}`,
              padding: '14px 16px',
              marginTop: 4,
              marginBottom: 16,
              display: 'flex',
              gap: 12,
              alignItems: 'flex-start',
            }}
          >
            <div style={{ flexShrink: 0, marginTop: 1 }}>
              {answerState === 'correct' ? (
                <CheckCircle2 size={18} color="#11998E" />
              ) : (
                <XCircle size={18} color="#DC3545" />
              )}
            </div>
            <div>
              <p
                style={{
                  color: answerState === 'correct' ? '#11998E' : '#DC3545',
                  fontSize: 14,
                  fontWeight: 700,
                  marginBottom: 5,
                }}
              >
                {answerState === 'correct' ? 'Correto! 🎉' : 'Não foi dessa vez'}
              </p>
              <p style={{ color: T.textSecondary, fontSize: 13, lineHeight: 1.6 }}>
                {question.explanation}
              </p>
            </div>
          </div>
        )}
      </div>

      {/* Footer */}
      <div
        style={{
          flexShrink: 0,
          backgroundColor: T.surface,
          borderTop: `1px solid ${T.border}`,
          padding: '14px 20px 28px',
        }}
      >
        {answerState === 'idle' ? (
          <PrimaryButton onClick={handleConfirm} disabled={selectedOption === null}>
            Confirmar resposta
          </PrimaryButton>
        ) : (
          <button
            onClick={handleNext}
            style={{
              width: '100%',
              padding: '16px',
              background: gradient,
              border: 'none',
              borderRadius: 17,
              color: '#fff',
              fontSize: 16,
              fontWeight: 600,
              cursor: 'pointer',
              fontFamily: fontStack,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 8,
              boxShadow: '0 6px 20px rgba(45,149,218,0.28)',
            }}
          >
            {currentIndex < total - 1 ? 'Próxima pergunta' : 'Ver resultado'}
            <ChevronRight size={18} />
          </button>
        )}
      </div>
    </div>
  );
}
