import React from 'react';
import { RouterProvider } from 'react-router';
import { router } from './routes';
import { fontStack } from './tokens';

export default function App() {
  return (
    <div
      style={{
        minHeight: '100vh',
        backgroundColor: '#C8D5E8',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '24px 16px',
        fontFamily: fontStack,
      }}
    >
      {/* Phone outer wrapper — includes decorative buttons */}
      <div style={{ position: 'relative', flexShrink: 0 }}>
        {/* Volume buttons (left) */}
        <div
          style={{
            position: 'absolute',
            left: -4,
            top: 130,
            width: 4,
            height: 32,
            backgroundColor: '#1A1A1A',
            borderRadius: '3px 0 0 3px',
            zIndex: 1,
          }}
        />
        <div
          style={{
            position: 'absolute',
            left: -4,
            top: 178,
            width: 4,
            height: 62,
            backgroundColor: '#1A1A1A',
            borderRadius: '3px 0 0 3px',
            zIndex: 1,
          }}
        />
        <div
          style={{
            position: 'absolute',
            left: -4,
            top: 256,
            width: 4,
            height: 62,
            backgroundColor: '#1A1A1A',
            borderRadius: '3px 0 0 3px',
            zIndex: 1,
          }}
        />
        {/* Power button (right) */}
        <div
          style={{
            position: 'absolute',
            right: -4,
            top: 190,
            width: 4,
            height: 80,
            backgroundColor: '#1A1A1A',
            borderRadius: '0 3px 3px 0',
            zIndex: 1,
          }}
        />

        {/* Phone frame */}
        <div
          style={{
            width: 393,
            height: 852,
            borderRadius: 52,
            backgroundColor: '#111',
            padding: '10px',
            boxShadow:
              '0 60px 120px rgba(0,0,0,0.45), 0 20px 60px rgba(0,0,0,0.3), 0 0 0 1px rgba(255,255,255,0.07) inset',
          }}
        >
          {/* Screen */}
          <div
            style={{
              width: '100%',
              height: '100%',
              borderRadius: 44,
              overflow: 'hidden',
              backgroundColor: '#F7FAFD',
              position: 'relative',
            }}
          >
            <RouterProvider router={router} />
          </div>
        </div>
      </div>

      {/* Label */}
      <div
        style={{
          position: 'fixed',
          bottom: 18,
          left: '50%',
          transform: 'translateX(-50%)',
          backgroundColor: 'rgba(0,0,0,0.55)',
          backdropFilter: 'blur(12px)',
          borderRadius: 20,
          padding: '6px 16px',
        }}
      >
        <span
          style={{
            color: 'rgba(255,255,255,0.88)',
            fontSize: 12,
            fontFamily: fontStack,
            letterSpacing: 0.3,
          }}
        >
          TechStudy · iPhone 14 Pro · 393×852
        </span>
      </div>
    </div>
  );
}
