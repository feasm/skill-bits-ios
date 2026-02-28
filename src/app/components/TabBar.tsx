import React from 'react';
import { useNavigate, useLocation } from 'react-router';
import { BookOpen, GraduationCap, BarChart2, User } from 'lucide-react';
import { T, gradient, fontStack } from '../tokens';

const tabs = [
  { id: 'courses', label: 'Cursos', icon: BookOpen, path: '/app/courses' },
  { id: 'my-study', label: 'Meu Estudo', icon: GraduationCap, path: '/app/my-study' },
  { id: 'progress', label: 'Progresso', icon: BarChart2, path: '/app/progress' },
  { id: 'profile', label: 'Perfil', icon: User, path: '/app/profile' },
];

export function TabBar() {
  const navigate = useNavigate();
  const location = useLocation();

  const activeTab = tabs.find((t) => location.pathname.startsWith(t.path))?.id || 'courses';

  return (
    <div
      style={{
        flexShrink: 0,
        backgroundColor: T.surface,
        borderTop: `1px solid ${T.border}`,
        paddingBottom: 28,
        fontFamily: fontStack,
      }}
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'flex-start',
          paddingTop: 8,
        }}
      >
        {tabs.map((tab) => {
          const isActive = tab.id === activeTab;
          const Icon = tab.icon;
          return (
            <button
              key={tab.id}
              onClick={() => navigate(tab.path)}
              style={{
                flex: 1,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: 4,
                background: 'none',
                border: 'none',
                cursor: 'pointer',
                padding: '4px 0 0',
                fontFamily: fontStack,
              }}
            >
              <div
                style={{
                  width: 28,
                  height: 28,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  borderRadius: 8,
                  background: isActive ? gradient : 'transparent',
                  transition: 'all 0.2s ease',
                }}
              >
                <Icon
                  size={isActive ? 16 : 22}
                  color={isActive ? '#fff' : T.textTertiary}
                  strokeWidth={isActive ? 2.5 : 1.8}
                />
              </div>
              <span
                style={{
                  fontSize: 10,
                  fontWeight: isActive ? 600 : 400,
                  color: isActive ? '#2D95DA' : T.textTertiary,
                  letterSpacing: 0.2,
                }}
              >
                {tab.label}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
