import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { Search, SlidersHorizontal, Star, Clock, Users } from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';
import { StatusBar } from '../components/StatusBar';
import { courses } from '../data/courses';

const filters = ['Todos', 'Iniciante', 'Intermediário', 'Avançado'];
const categories = ['Todos', 'DevOps', 'Data Science', 'Cloud', 'Frontend', 'Infra'];

export function CoursesScreen() {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilter, setActiveFilter] = useState('Todos');
  const [isFocused, setIsFocused] = useState(false);

  const filtered = courses.filter((c) => {
    const matchSearch =
      c.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      c.tags.some((t) => t.toLowerCase().includes(searchQuery.toLowerCase()));
    const matchFilter = activeFilter === 'Todos' || c.level === activeFilter;
    return matchSearch && matchFilter;
  });

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

      {/* Header */}
      <div style={{ padding: '4px 24px 0', flexShrink: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <p style={{ color: T.textTertiary, fontSize: 13, marginBottom: 2 }}>Olá, Rafael 👋</p>
            <h1
              style={{
                color: T.textPrimary,
                fontSize: 26,
                fontWeight: 700,
                letterSpacing: '-0.5px',
              }}
            >
              Cursos
            </h1>
          </div>
          <div
            style={{
              width: 40,
              height: 40,
              borderRadius: 20,
              background: gradient,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <span style={{ color: '#fff', fontSize: 15, fontWeight: 700 }}>R</span>
          </div>
        </div>

        {/* Search bar */}
        <div style={{ position: 'relative', marginTop: 16 }}>
          <Search
            size={18}
            style={{
              position: 'absolute',
              left: 14,
              top: '50%',
              transform: 'translateY(-50%)',
              color: isFocused ? T.accent : T.textTertiary,
              transition: 'color 0.2s',
            }}
          />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            onFocus={() => setIsFocused(true)}
            onBlur={() => setIsFocused(false)}
            placeholder="Buscar cursos, tecnologias..."
            style={{
              width: '100%',
              padding: '13px 44px',
              backgroundColor: T.inputBg,
              border: `1.5px solid ${isFocused ? T.accent : T.inputBorder}`,
              borderRadius: 14,
              fontSize: 15,
              color: T.textPrimary,
              fontFamily: fontStack,
              outline: 'none',
              boxSizing: 'border-box',
              transition: 'border-color 0.2s',
            }}
          />
          <SlidersHorizontal
            size={18}
            style={{
              position: 'absolute',
              right: 14,
              top: '50%',
              transform: 'translateY(-50%)',
              color: T.textTertiary,
            }}
          />
        </div>

        {/* Filter pills */}
        <div
          style={{
            display: 'flex',
            gap: 8,
            marginTop: 14,
            overflowX: 'auto',
            paddingBottom: 2,
            scrollbarWidth: 'none',
          }}
        >
          {filters.map((f) => (
            <button
              key={f}
              onClick={() => setActiveFilter(f)}
              style={{
                flexShrink: 0,
                padding: '6px 16px',
                borderRadius: 20,
                border: 'none',
                backgroundColor: activeFilter === f ? T.accent : T.surface,
                color: activeFilter === f ? '#fff' : T.textSecondary,
                fontSize: 13,
                fontWeight: activeFilter === f ? 600 : 400,
                cursor: 'pointer',
                fontFamily: fontStack,
                boxShadow: activeFilter === f ? 'none' : `0 0 0 1.5px ${T.border}`,
                transition: 'all 0.18s ease',
              }}
            >
              {f}
            </button>
          ))}
        </div>
      </div>

      {/* Course list */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '16px 24px 20px' }}>
        {/* Stats banner */}
        <div
          style={{
            background: gradient,
            borderRadius: 17,
            padding: '16px 20px',
            marginBottom: 20,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <div>
            <p style={{ color: 'rgba(255,255,255,0.8)', fontSize: 13, marginBottom: 3 }}>
              Seu plano Premium
            </p>
            <p style={{ color: '#fff', fontSize: 16, fontWeight: 700 }}>
              {courses.length} cursos disponíveis
            </p>
          </div>
          <div
            style={{
              backgroundColor: 'rgba(255,255,255,0.2)',
              borderRadius: 12,
              padding: '8px 14px',
            }}
          >
            <Star size={18} fill="white" color="white" />
          </div>
        </div>

        <p style={{ color: T.textTertiary, fontSize: 13, marginBottom: 14, fontWeight: 500 }}>
          {filtered.length} curso{filtered.length !== 1 ? 's' : ''} encontrado
          {filtered.length !== 1 ? 's' : ''}
        </p>

        {filtered.map((course) => (
          <CourseCard
            key={course.id}
            course={course}
            onPress={() => navigate(`/app/courses/${course.id}`)}
          />
        ))}
      </div>
    </div>
  );
}

function CourseCard({ course, onPress }: { course: (typeof courses)[0]; onPress: () => void }) {
  return (
    <button
      onClick={onPress}
      style={{
        width: '100%',
        backgroundColor: T.surface,
        border: `1px solid ${T.border}`,
        borderRadius: 17,
        padding: '16px',
        marginBottom: 14,
        textAlign: 'left',
        cursor: 'pointer',
        fontFamily: fontStack,
        transition: 'box-shadow 0.18s ease',
        boxSizing: 'border-box',
      }}
    >
      {/* Top row */}
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: 12 }}>
        {/* Course icon */}
        <div
          style={{
            width: 48,
            height: 48,
            borderRadius: 13,
            background: `linear-gradient(135deg, ${course.color1} 0%, ${course.color2} 100%)`,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            flexShrink: 0,
          }}
        >
          <span style={{ fontSize: 22 }}>
            {course.category === 'DevOps'
              ? '🐳'
              : course.category === 'Data Science'
              ? '📊'
              : course.category === 'Cloud'
              ? '☁️'
              : course.category === 'Frontend'
              ? '⚛️'
              : '🌐'}
          </span>
        </div>

        {/* Badge */}
        <div
          style={{
            padding: '4px 10px',
            borderRadius: 8,
            backgroundColor: course.isPremium ? 'rgba(45,149,218,0.1)' : 'rgba(56,239,125,0.1)',
            border: `1px solid ${course.isPremium ? 'rgba(45,149,218,0.25)' : 'rgba(56,239,125,0.3)'}`,
          }}
        >
          <span
            style={{
              fontSize: 11,
              fontWeight: 700,
              color: course.isPremium ? '#2D95DA' : '#11998E',
              letterSpacing: 0.5,
            }}
          >
            {course.isPremium ? '★ PREMIUM' : 'GRÁTIS'}
          </span>
        </div>
      </div>

      {/* Title + desc */}
      <h3
        style={{
          color: T.textPrimary,
          fontSize: 16,
          fontWeight: 700,
          marginBottom: 5,
          letterSpacing: '-0.3px',
          lineHeight: 1.35,
        }}
      >
        {course.title}
      </h3>
      <p
        style={{
          color: T.textSecondary,
          fontSize: 13,
          lineHeight: 1.5,
          marginBottom: 12,
        }}
      >
        {course.shortDesc}
      </p>

      {/* Tags */}
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginBottom: 14 }}>
        {course.tags.slice(0, 4).map((tag) => (
          <span
            key={tag}
            style={{
              padding: '3px 10px',
              borderRadius: 6,
              backgroundColor: T.bg,
              border: `1px solid ${T.border}`,
              color: T.textTertiary,
              fontSize: 11,
              fontWeight: 500,
            }}
          >
            {tag}
          </span>
        ))}
      </div>

      {/* Progress (if enrolled) */}
      {course.progress > 0 && (
        <div style={{ marginBottom: 12 }}>
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
                width: `${course.progress}%`,
                background: gradient,
                borderRadius: 2,
              }}
            />
          </div>
          <p style={{ color: T.textTertiary, fontSize: 11, marginTop: 5 }}>
            {course.progress}% concluído
          </p>
        </div>
      )}

      {/* Stats row */}
      <div style={{ display: 'flex', gap: 16, alignItems: 'center' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
          <Clock size={13} color={T.textTertiary} />
          <span style={{ color: T.textTertiary, fontSize: 12 }}>{course.totalDuration}</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
          <Users size={13} color={T.textTertiary} />
          <span style={{ color: T.textTertiary, fontSize: 12 }}>
            {course.studentsCount.toLocaleString('pt-BR')}
          </span>
        </div>
        <div
          style={{
            marginLeft: 'auto',
            padding: '4px 10px',
            borderRadius: 6,
            backgroundColor: T.bg,
            border: `1px solid ${T.border}`,
          }}
        >
          <span
            style={{
              fontSize: 11,
              fontWeight: 500,
              color:
                course.level === 'Avançado'
                  ? '#E85D75'
                  : course.level === 'Intermediário'
                  ? '#E8973D'
                  : '#11998E',
            }}
          >
            {course.level}
          </span>
        </div>
      </div>
    </button>
  );
}
