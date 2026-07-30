import React, { Suspense, lazy, useEffect, useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { A11yProvider } from './contexts/A11yContext';
import { ToastProvider } from './contexts/ToastContext';
import { AppLayout } from './components/layout/AppLayout';
import { SkipToMainContent } from './components/ui/SkipToMainContent';
import { ScreenReaderAnnouncer } from './components/ui/ScreenReaderAnnouncer';

// Route-level code-splitting: each page is fetched only when its route is visited.
const LoginPage = lazy(() => import('./pages/LoginPage').then(m => ({ default: m.LoginPage })));
const RegisterPage = lazy(() => import('./pages/RegisterPage').then(m => ({ default: m.RegisterPage })));
const ForgotPasswordPage = lazy(() => import('./pages/ForgotPasswordPage').then(m => ({ default: m.ForgotPasswordPage })));
const DashboardPage = lazy(() => import('./pages/DashboardPage').then(m => ({ default: m.DashboardPage })));
const MapPage = lazy(() => import('./pages/MapPage').then(m => ({ default: m.MapPage })));
const CalendarPage = lazy(() => import('./pages/CalendarPage').then(m => ({ default: m.CalendarPage })));
const AiChatPage = lazy(() => import('./pages/AiChatPage').then(m => ({ default: m.AiChatPage })));
const MessagesPage = lazy(() => import('./pages/MessagesPage').then(m => ({ default: m.MessagesPage })));
const FeedPage = lazy(() => import('./pages/FeedPage').then(m => ({ default: m.FeedPage })));
const PlansPage = lazy(() => import('./pages/PlansPage').then(m => ({ default: m.PlansPage })));
const SettingsPage = lazy(() => import('./pages/SettingsPage').then(m => ({ default: m.SettingsPage })));
const AdminPage = lazy(() => import('./pages/AdminPage').then(m => ({ default: m.AdminPage })));

function RouteFallback() {
  return (
    <div className="min-h-screen bg-bg-primary flex items-center justify-center">
      <div className="flex flex-col items-center gap-4">
        <div className="w-12 h-12 border-2 border-accent-blue border-t-transparent rounded-full animate-spin" />
        <p className="text-text-muted text-sm">Carregando...</p>
      </div>
    </div>
  );
}

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { session, loading } = useAuth();
  if (loading) return (
    <div className="min-h-screen bg-bg-primary flex items-center justify-center">
      <div className="flex flex-col items-center gap-4">
        <div className="w-12 h-12 border-2 border-accent-blue border-t-transparent rounded-full animate-spin" />
        <p className="text-text-muted text-sm">Carregando...</p>
      </div>
    </div>
  );
  if (!session) return <Navigate to="/login" replace />;
  return <>{children}</>;
}

function PageTransition({ children }: { children: React.ReactNode }) {
  const location = useLocation();
  const [displayChildren, setDisplayChildren] = useState(children);
  const [transitionStage, setTransitionStage] = useState('page-enter');

  useEffect(() => {
    setTransitionStage('page-enter');
    const timeout = setTimeout(() => {
      setDisplayChildren(children);
      setTransitionStage('page-enter-active');
    }, 50);
    return () => clearTimeout(timeout);
  }, [location.pathname]);

  return (
    <div className={`${transitionStage} ${transitionStage === 'page-enter-active' ? 'page-enter-active' : ''}`}>
      {displayChildren}
    </div>
  );
}

function AppRoutes() {
  return (
    <Suspense fallback={<RouteFallback />}>
      <Routes>
        <Route path="/login" element={<PageTransition><LoginPage /></PageTransition>} />
        <Route path="/register" element={<PageTransition><RegisterPage /></PageTransition>} />
        <Route path="/forgot-password" element={<PageTransition><ForgotPasswordPage /></PageTransition>} />
        <Route path="/" element={
          <ProtectedRoute>
            <AppLayout />
          </ProtectedRoute>
        }>
          <Route index element={<PageTransition><DashboardPage /></PageTransition>} />
          <Route path="map" element={<PageTransition><MapPage /></PageTransition>} />
          <Route path="calendar" element={<PageTransition><CalendarPage /></PageTransition>} />
          <Route path="ai-chat" element={<PageTransition><AiChatPage /></PageTransition>} />
          <Route path="messages" element={<PageTransition><MessagesPage /></PageTransition>} />
          <Route path="feed" element={<PageTransition><FeedPage /></PageTransition>} />
          <Route path="plans" element={<PageTransition><PlansPage /></PageTransition>} />
          <Route path="settings" element={<PageTransition><SettingsPage /></PageTransition>} />
          <Route path="admin" element={<PageTransition><AdminPage /></PageTransition>} />
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Suspense>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <A11yProvider>
          <ToastProvider>
            <SkipToMainContent />
            <AppRoutes />
            <ScreenReaderAnnouncer message="Página carregada" />
          </ToastProvider>
        </A11yProvider>
      </AuthProvider>
    </BrowserRouter>
  );
}
