import React, { createContext, useContext, useReducer, ReactNode } from 'react';

export type ScreenType =
  | 'login'
  | 'courses'
  | 'my-study'
  | 'progress'
  | 'profile'
  | 'course-detail'
  | 'module-detail'
  | 'lesson-reader'
  | 'quiz-intro'
  | 'quiz-question'
  | 'quiz-result'
  | 'guided-review'
  | 'next-lesson';

export type TabType = 'courses' | 'my-study' | 'progress' | 'profile';
export type ModalType = 'listen' | 'font-prefs' | 'paywall' | null;

export interface NavEntry {
  screen: ScreenType;
  params?: Record<string, unknown>;
}

interface NavState {
  stack: NavEntry[];
  tab: TabType;
  modal: ModalType;
  isAuthenticated: boolean;
  paywallSuccess: boolean;
  quizAnswers: Record<number, number>;
  quizConfirmed: boolean;
  quizQuestionIndex: number;
  selectedAnswer: number | null;
  fontSize: number;
  lineHeight: number;
  listenSpeed: number;
  isPlaying: boolean;
}

type Action =
  | { type: 'PUSH'; entry: NavEntry }
  | { type: 'POP' }
  | { type: 'SET_TAB'; tab: TabType }
  | { type: 'SHOW_MODAL'; modal: ModalType }
  | { type: 'HIDE_MODAL' }
  | { type: 'LOGIN' }
  | { type: 'LOGOUT' }
  | { type: 'SELECT_ANSWER'; answer: number }
  | { type: 'CONFIRM_ANSWER' }
  | { type: 'NEXT_QUESTION' }
  | { type: 'RESET_QUIZ' }
  | { type: 'SET_FONT_SIZE'; size: number }
  | { type: 'SET_LINE_HEIGHT'; lineHeight: number }
  | { type: 'SET_LISTEN_SPEED'; speed: number }
  | { type: 'TOGGLE_PLAYING' }
  | { type: 'COMPLETE_PURCHASE' };

const initialState: NavState = {
  stack: [{ screen: 'login' }],
  tab: 'courses',
  modal: null,
  isAuthenticated: false,
  paywallSuccess: false,
  quizAnswers: {},
  quizConfirmed: false,
  quizQuestionIndex: 0,
  selectedAnswer: null,
  fontSize: 17,
  lineHeight: 1.75,
  listenSpeed: 1.0,
  isPlaying: false,
};

function reducer(state: NavState, action: Action): NavState {
  switch (action.type) {
    case 'PUSH':
      return { ...state, stack: [...state.stack, action.entry] };
    case 'POP':
      if (state.stack.length <= 1) return state;
      return { ...state, stack: state.stack.slice(0, -1) };
    case 'SET_TAB': {
      const tabScreenMap: Record<TabType, ScreenType> = {
        courses: 'courses',
        'my-study': 'my-study',
        progress: 'progress',
        profile: 'profile',
      };
      return { ...state, tab: action.tab, stack: [{ screen: tabScreenMap[action.tab] }] };
    }
    case 'SHOW_MODAL':
      return { ...state, modal: action.modal };
    case 'HIDE_MODAL':
      return { ...state, modal: null, paywallSuccess: false };
    case 'LOGIN':
      return { ...state, isAuthenticated: true, stack: [{ screen: 'courses' }] };
    case 'LOGOUT':
      return { ...initialState };
    case 'SELECT_ANSWER':
      return { ...state, selectedAnswer: action.answer, quizConfirmed: false };
    case 'CONFIRM_ANSWER':
      return {
        ...state,
        quizConfirmed: true,
        quizAnswers: { ...state.quizAnswers, [state.quizQuestionIndex]: state.selectedAnswer ?? -1 },
      };
    case 'NEXT_QUESTION':
      return { ...state, quizConfirmed: false, selectedAnswer: null, quizQuestionIndex: state.quizQuestionIndex + 1 };
    case 'RESET_QUIZ':
      return { ...state, quizAnswers: {}, quizConfirmed: false, quizQuestionIndex: 0, selectedAnswer: null };
    case 'SET_FONT_SIZE':
      return { ...state, fontSize: action.size };
    case 'SET_LINE_HEIGHT':
      return { ...state, lineHeight: action.lineHeight };
    case 'SET_LISTEN_SPEED':
      return { ...state, listenSpeed: action.speed };
    case 'TOGGLE_PLAYING':
      return { ...state, isPlaying: !state.isPlaying };
    case 'COMPLETE_PURCHASE':
      return { ...state, paywallSuccess: true };
    default:
      return state;
  }
}

interface NavContextType {
  state: NavState;
  currentScreen: ScreenType;
  currentParams: Record<string, unknown>;
  push: (screen: ScreenType, params?: Record<string, unknown>) => void;
  pop: () => void;
  setTab: (tab: TabType) => void;
  showModal: (modal: ModalType) => void;
  hideModal: () => void;
  login: () => void;
  logout: () => void;
  selectAnswer: (answer: number) => void;
  confirmAnswer: () => void;
  nextQuestion: () => void;
  resetQuiz: () => void;
  setFontSize: (size: number) => void;
  setLineHeight: (lh: number) => void;
  setListenSpeed: (speed: number) => void;
  togglePlaying: () => void;
  completePurchase: () => void;
}

const NavContext = createContext<NavContextType | null>(null);

export function NavigationProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(reducer, initialState);
  const currentEntry = state.stack[state.stack.length - 1];

  const value: NavContextType = {
    state,
    currentScreen: currentEntry.screen,
    currentParams: currentEntry.params ?? {},
    push: (screen, params) => dispatch({ type: 'PUSH', entry: { screen, params } }),
    pop: () => dispatch({ type: 'POP' }),
    setTab: (tab) => dispatch({ type: 'SET_TAB', tab }),
    showModal: (modal) => dispatch({ type: 'SHOW_MODAL', modal }),
    hideModal: () => dispatch({ type: 'HIDE_MODAL' }),
    login: () => dispatch({ type: 'LOGIN' }),
    logout: () => dispatch({ type: 'LOGOUT' }),
    selectAnswer: (answer) => dispatch({ type: 'SELECT_ANSWER', answer }),
    confirmAnswer: () => dispatch({ type: 'CONFIRM_ANSWER' }),
    nextQuestion: () => dispatch({ type: 'NEXT_QUESTION' }),
    resetQuiz: () => dispatch({ type: 'RESET_QUIZ' }),
    setFontSize: (size) => dispatch({ type: 'SET_FONT_SIZE', size }),
    setLineHeight: (lh) => dispatch({ type: 'SET_LINE_HEIGHT', lineHeight: lh }),
    setListenSpeed: (speed) => dispatch({ type: 'SET_LISTEN_SPEED', speed }),
    togglePlaying: () => dispatch({ type: 'TOGGLE_PLAYING' }),
    completePurchase: () => dispatch({ type: 'COMPLETE_PURCHASE' }),
  };

  return <NavContext.Provider value={value}>{children}</NavContext.Provider>;
}

export function useNav() {
  const ctx = useContext(NavContext);
  if (!ctx) throw new Error('useNav must be used within NavigationProvider');
  return ctx;
}
