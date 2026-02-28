import React from 'react';

interface GradientButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  disabled?: boolean;
  size?: 'sm' | 'md' | 'lg';
  fullWidth?: boolean;
  variant?: 'primary' | 'outline' | 'ghost';
}

export function GradientButton({
  children,
  onClick,
  disabled,
  size = 'lg',
  fullWidth = true,
  variant = 'primary',
}: GradientButtonProps) {
  const heights = { sm: 42, md: 50, lg: 56 };
  const fontSizes = { sm: 14, md: 15, lg: 17 };

  const getStyle = (): React.CSSProperties => {
    const base: React.CSSProperties = {
      borderRadius: 18,
      height: heights[size],
      width: fullWidth ? '100%' : 'auto',
      padding: fullWidth ? undefined : '0 24px',
      border: 'none',
      cursor: disabled ? 'not-allowed' : 'pointer',
      fontSize: fontSizes[size],
      fontWeight: 600,
      letterSpacing: '-0.2px',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 8,
      transition: 'opacity 0.15s ease, transform 0.1s ease',
      opacity: disabled ? 0.55 : 1,
      fontFamily: 'inherit',
      flexShrink: 0,
    };

    if (variant === 'primary') {
      return {
        ...base,
        background: disabled ? '#C0CEDB' : 'linear-gradient(135deg, #40E0D0 0%, #2D95DA 100%)',
        color: '#FFFFFF',
        boxShadow: disabled ? 'none' : '0 4px 16px rgba(45, 149, 218, 0.28)',
      };
    }
    if (variant === 'outline') {
      return {
        ...base,
        background: 'transparent',
        color: '#2D95DA',
        border: '1.5px solid #2D95DA',
      };
    }
    // ghost
    return {
      ...base,
      background: 'transparent',
      color: '#4B5B6A',
    };
  };

  return (
    <button onClick={onClick} disabled={disabled} style={getStyle()}>
      {children}
    </button>
  );
}
