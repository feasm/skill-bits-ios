import React from 'react';
import { T, fontStack } from '../tokens';

export function StatusBar({ light = false }: { light?: boolean }) {
  const textColor = light ? 'rgba(255,255,255,0.95)' : T.textPrimary;

  return (
    <div
      style={{
        height: 54,
        backgroundColor: 'transparent',
        position: 'relative',
        flexShrink: 0,
        fontFamily: fontStack,
      }}
    >
      {/* Dynamic Island */}
      <div
        style={{
          position: 'absolute',
          top: 10,
          left: '50%',
          transform: 'translateX(-50%)',
          width: 120,
          height: 34,
          backgroundColor: '#000',
          borderRadius: 20,
          zIndex: 10,
        }}
      />

      {/* Time */}
      <div
        style={{
          position: 'absolute',
          top: 16,
          left: 24,
          fontSize: 15,
          fontWeight: 600,
          color: textColor,
          letterSpacing: '-0.3px',
        }}
      >
        9:41
      </div>

      {/* Right icons */}
      <div
        style={{
          position: 'absolute',
          top: 18,
          right: 20,
          display: 'flex',
          gap: 6,
          alignItems: 'center',
        }}
      >
        {/* Signal */}
        <svg width="17" height="12" viewBox="0 0 17 12" fill="none">
          <rect x="0" y="7" width="3" height="5" rx="1" fill={textColor} />
          <rect x="4.5" y="4.5" width="3" height="7.5" rx="1" fill={textColor} />
          <rect x="9" y="2" width="3" height="10" rx="1" fill={textColor} />
          <rect x="13.5" y="0" width="3" height="12" rx="1" fill={textColor} />
        </svg>

        {/* Wifi */}
        <svg width="16" height="12" viewBox="0 0 16 12" fill="none">
          <path
            d="M8 9.5a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3z"
            fill={textColor}
          />
          <path
            d="M5.05 7.55a4.2 4.2 0 0 1 5.9 0"
            stroke={textColor}
            strokeWidth="1.5"
            strokeLinecap="round"
          />
          <path
            d="M2.2 4.7a8 8 0 0 1 11.6 0"
            stroke={textColor}
            strokeWidth="1.5"
            strokeLinecap="round"
          />
          <path
            d="M0 2.2A11.5 11.5 0 0 1 16 2.2"
            stroke={textColor}
            strokeWidth="1.5"
            strokeLinecap="round"
            opacity="0.4"
          />
        </svg>

        {/* Battery */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <div
            style={{
              width: 24,
              height: 12,
              borderRadius: 3,
              border: `1.5px solid ${textColor}`,
              position: 'relative',
              overflow: 'hidden',
            }}
          >
            <div
              style={{
                position: 'absolute',
                left: 2,
                top: 2,
                width: '75%',
                height: 'calc(100% - 4px)',
                backgroundColor: textColor,
                borderRadius: 1.5,
              }}
            />
          </div>
          <div
            style={{
              width: 2,
              height: 5,
              backgroundColor: textColor,
              borderRadius: '0 1px 1px 0',
            }}
          />
        </div>
      </div>
    </div>
  );
}
