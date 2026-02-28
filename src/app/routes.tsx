import React from 'react';
import { createBrowserRouter, Navigate } from 'react-router';
import { LoginScreen } from './screens/LoginScreen';
import { MainLayout } from './screens/MainLayout';
import { CoursesScreen } from './screens/CoursesScreen';
import { CourseDetailScreen } from './screens/CourseDetailScreen';
import { ModuleDetailScreen } from './screens/ModuleDetailScreen';
import { LessonReaderScreen } from './screens/LessonReaderScreen';
import { PaywallScreen } from './screens/PaywallScreen';
import { PurchaseSuccessScreen } from './screens/PurchaseSuccessScreen';
import { QuizIntroScreen } from './screens/QuizIntroScreen';
import { QuizQuestionScreen } from './screens/QuizQuestionScreen';
import { QuizResultScreen } from './screens/QuizResultScreen';
import { GuidedReviewScreen } from './screens/GuidedReviewScreen';
import { NextLessonScreen } from './screens/NextLessonScreen';
import { MyStudyScreen } from './screens/MyStudyScreen';
import { ProgressScreen } from './screens/ProgressScreen';
import { ProfileScreen } from './screens/ProfileScreen';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <Navigate to="/login" replace />,
  },
  {
    path: '/login',
    element: <LoginScreen />,
  },
  {
    path: '/app',
    element: <MainLayout />,
    children: [
      { index: true, element: <Navigate to="/app/courses" replace /> },
      { path: 'courses', element: <CoursesScreen /> },
      { path: 'courses/:courseId', element: <CourseDetailScreen /> },
      { path: 'courses/:courseId/modules/:moduleId', element: <ModuleDetailScreen /> },
      { path: 'my-study', element: <MyStudyScreen /> },
      { path: 'progress', element: <ProgressScreen /> },
      { path: 'profile', element: <ProfileScreen /> },
    ],
  },
  {
    path: '/app/courses/:courseId/modules/:moduleId/lessons/:lessonId',
    element: <LessonReaderScreen />,
  },
  { path: '/paywall', element: <PaywallScreen /> },
  { path: '/purchase-success', element: <PurchaseSuccessScreen /> },
  { path: '/quiz-intro', element: <QuizIntroScreen /> },
  { path: '/quiz-question', element: <QuizQuestionScreen /> },
  { path: '/quiz-result', element: <QuizResultScreen /> },
  { path: '/quiz-review', element: <GuidedReviewScreen /> },
  { path: '/next-lesson', element: <NextLessonScreen /> },
]);