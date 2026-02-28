import React from 'react';
import { Outlet } from 'react-router';
import { TabBar } from '../components/TabBar';

export function MainLayout() {
  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
        overflow: 'hidden',
      }}
    >
      <div style={{ flex: 1, overflow: 'hidden' }}>
        <Outlet />
      </div>
      <TabBar />
    </div>
  );
}
