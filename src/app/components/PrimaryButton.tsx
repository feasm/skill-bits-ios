import React from 'react';
import { gradient, fontStack } from '../tokens';

interface PrimaryButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  disabled?: boolean;
  fullWidth?: boolean;
  size?: 'sm' | 'md' | 'lg';
  style?: React.CSSProperties;
}

export function PrimaryButton({
  children,
  onClick,
  disabled = false,
  fullWidth = true,
  size = 'md',
  style,
}: PrimaryButtonProps) {
  const padding = size === 'lg' ? '18px 24px' : size === 'sm' ? '11px 20px' : '16px 24px';
  const fontSize = size === 'lg' ? 17 : size === 'sm' ? 14 : 16;

  return (
    <button
      onClick={onClick}
      disabled={disabled}
      style={{
        width: fullWidth ? '100%' : 'auto',
        padding,
        background: disabled ? '#C5D5E5' : gradient,
        border: 'none',
        borderRadius: 17,
        color: '#fff',
        fontSize,
        fontWeight: 600,
        cursor: disabled ? 'not-allowed' : 'pointer',
        fontFamily: fontStack,
        letterSpacing: '-0.2px',
        boxShadow: disabled ? 'none' : '0 6px 20px rgba(45,149,218,0.28)',
        transition: 'all 0.18s ease',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 8,
        ...style,
      }}
    >
      {children}
    </button>
  );
}

export function SecondaryButton({
  children,
  onClick,
  style,
}: {
  children: React.ReactNode;
  onClick?: () => void;
  style?: React.CSSProperties;
}) {
  return (
    <button
      onClick={onClick}
      style={{
        width: '100%',
        padding: '16px 24px',
        backgroundColor: '#FFFFFF',
        border: '1.5px solid #E6EDF5',
        borderRadius: 17,
        color: '#0B0F14',
        fontSize: 16,
        fontWeight: 600,
        cursor: 'pointer',
        fontFamily: fontStack,
        letterSpacing: '-0.2px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 8,
        ...style,
      }}
    >
      {children}
    </button>
  );
}
