import SwiftUI
import Observation
import SkillBitsCore
import SkillBitsAuth
import SkillBitsCourses
import SkillBitsLesson
import SkillBitsQuiz
import SkillBitsProgress
import SkillBitsProfile
import SkillBitsPaywall
import SkillBitsHome
import SkillBitsDesignSystem

struct MainTabView: View {
    @Bindable var session: AppSession
    let env: AppEnvironment

    @State private var selectedTab: TabItem = .courses
    @State private var selectedCourse: Course?
    @State private var activeModule: ModuleNavItem?
    @State private var activeLesson: LessonNavItem?
    @State private var activeQuizIntro: QuizIntroSession?
    @State private var activeQuiz: QuizSession?
    @State private var quizResult: QuizResult?
    @State private var pendingQuizSession: QuizSession?
    @State private var pendingQuizResult: QuizResult?
    @State private var nextLessonState: NextLessonState?
    @State private var premiumGate = PremiumGateState()
    @State private var showPaywall = false
    @State private var showPurchaseSuccess = false
    @State private var reviewPoints: [GuidedReviewPoint] = []
    @State private var showGuidedReview = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                CoursesView(viewModel: CoursesViewModel(repo: env.coursesRepository)) { course in
                    selectedCourse = course
                }
                .navigationDestination(item: $selectedCourse) { course in
                    CourseDetailView(course: course) { module in
                        premiumGate.require(tier: module.accessTier, context: module.title) {
                            activeModule = ModuleNavItem(course: course, module: module)
                        }
                    } startLesson: { module, lesson in
                        premiumGate.require(tier: module.accessTier, context: module.title) {
                            activeLesson = LessonNavItem(courseId: course.id, module: module, lesson: lesson)
                        }
                    }
                }
                .navigationDestination(item: $activeModule) { nav in
                    ModuleDetailView(course: nav.course, module: nav.module) { lesson in
                        premiumGate.require(tier: nav.module.accessTier, context: nav.module.title) {
                            activeLesson = LessonNavItem(courseId: nav.course.id, module: nav.module, lesson: lesson)
                        }
                    } startQuiz: { quizFirst in
                        premiumGate.require(tier: nav.module.accessTier, context: nav.module.title) {
                            activeQuizIntro = QuizIntroSession(moduleId: nav.module.id)
                        }
                    }
                }
                .navigationDestination(item: $activeLesson) { nav in
                    LessonReaderView(repo: env.lessonRepository, courseId: nav.courseId, moduleId: nav.module.id, lesson: nav.lesson) {
                        Task { await refreshCourse() }
                        let next = nextLesson(in: nav.module, currentLessonId: nav.lesson.id)
                        nextLessonState = NextLessonState(nextLesson: next)
                    } onStartQuiz: {
                        activeQuizIntro = QuizIntroSession(moduleId: nav.module.id)
                    }
                }
            }
            .premiumGateOverlay(premiumGate) {
                showPaywall = true
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(viewModel: PaywallViewModel(repo: env.paywallRepository)) {
                    showPaywall = false
                    showPurchaseSuccess = true
                    premiumGate.unlockPending()
                }
            }
            .sheet(isPresented: $showPurchaseSuccess) {
                PurchaseSuccessView {
                    showPurchaseSuccess = false
                }
            }
            .sheet(item: $activeQuizIntro, onDismiss: {
                if let pending = pendingQuizSession {
                    pendingQuizSession = nil
                    activeQuiz = pending
                }
            }) { intro in
                QuizIntroView {
                    pendingQuizSession = QuizSession(moduleId: intro.moduleId, quizFirst: false)
                    activeQuizIntro = nil
                } startQuizFirstMode: {
                    pendingQuizSession = QuizSession(moduleId: intro.moduleId, quizFirst: true)
                    activeQuizIntro = nil
                }
            }
            .sheet(item: $nextLessonState) { state in
                NextLessonView(nextLessonTitle: state.nextLesson?.title ?? "Modulo concluido") {
                    if let next = state.nextLesson, let current = activeLesson {
                        activeLesson = LessonNavItem(courseId: current.courseId, module: current.module, lesson: next)
                    }
                    nextLessonState = nil
                }
            }
            .fullScreenCover(item: $activeQuiz, onDismiss: {
                if let pending = pendingQuizResult {
                    pendingQuizResult = nil
                    quizResult = pending
                }
            }) { quiz in
                QuizQuestionView(repo: env.quizRepository, moduleId: quiz.moduleId, quizFirst: quiz.quizFirst, onExit: {
                    activeQuiz = nil
                }) { result in
                    pendingQuizResult = result
                    activeQuiz = nil
                }
            }
            .sheet(item: $quizResult, onDismiss: {
                if let pending = pendingQuizSession {
                    pendingQuizSession = nil
                    activeQuiz = pending
                }
            }) { result in
                QuizResultView(result: result) {
                    Task {
                        if result.passed { await refreshCourse() }
                        reviewPoints = (try? await env.quizRepository.fetchGuidedReview(moduleId: result.moduleId)) ?? []
                        await MainActor.run {
                            showGuidedReview = !reviewPoints.isEmpty
                        }
                    }
                } onRetry: {
                    pendingQuizSession = QuizSession(moduleId: result.moduleId, quizFirst: result.quizFirst)
                    quizResult = nil
                } onContinue: {
                    if result.passed { Task { await refreshCourse() } }
                    quizResult = nil
                }
            }
            .sheet(isPresented: $showGuidedReview) {
                NavigationStack {
                    GuidedReviewView(points: reviewPoints) { _ in
                        reviewPoints = []
                        showGuidedReview = false
                    }
                }
            }
            .tabItem { Label("Cursos", systemImage: "book") }
            .tag(TabItem.courses)

            NavigationStack {
                MyStudyHost(env: env) { course in
                    selectedTab = .courses
                    selectedCourse = course
                }
            }
            .tabItem { Label("Meus estudos", systemImage: "flame") }
            .tag(TabItem.myStudy)

            NavigationStack {
                ProgressScreenView(viewModel: ProgressViewModel(repo: env.progressRepository, coursesRepo: env.coursesRepository))
            }
            .tabItem { Label("Progresso", systemImage: "chart.bar") }
            .tag(TabItem.progress)

            ProfileScreenView(viewModel: ProfileViewModel(repo: env.progressRepository)) {
                withAnimation(SBMotion.springSmooth) {
                    session.isLoggedIn = false
                    session.onboardingCompleted = false
                }
            }
            .tabItem { Label("Perfil", systemImage: "person") }
            .tag(TabItem.profile)
        }
        .tint(SBColor.accent)
        .onChange(of: selectedTab) { _, _ in
            SBHaptics.selection()
        }
    }
}

private struct ModuleNavItem: Identifiable, Hashable {
    let course: Course
    let module: Module
    var id: String { "\(course.id)|\(module.id)" }
}

private struct LessonNavItem: Identifiable, Hashable {
    let courseId: String
    let module: Module
    let lesson: Lesson
    var id: String { "\(courseId)|\(module.id)|\(lesson.id)" }
}

private struct QuizSession: Identifiable {
    let moduleId: String
    let quizFirst: Bool
    var id: String { moduleId + "|" + String(quizFirst) }
}

private struct QuizIntroSession: Identifiable {
    let moduleId: String
    var id: String { moduleId }
}

private struct NextLessonState: Identifiable {
    let nextLesson: Lesson?
    var id: String { nextLesson?.id ?? "none" }
}

private struct MyStudyHost: View {
    let env: AppEnvironment
    let openCourse: (Course) -> Void
    @State private var courses: [Course] = []

    var body: some View {
        MyStudyView(courses: courses, openCourse: openCourse)
            .task {
                courses = (try? await env.coursesRepository.fetchCourses()) ?? []
            }
    }
}

private extension MainTabView {
    func nextLesson(in module: Module, currentLessonId: String) -> Lesson? {
        guard let index = module.lessons.firstIndex(where: { $0.id == currentLessonId }) else { return nil }
        guard index + 1 < module.lessons.count else { return nil }
        return module.lessons[index + 1]
    }

    func refreshCourse() async {
        guard let courseId = selectedCourse?.id else { return }
        guard let updated = try? await env.coursesRepository.fetchCourse(id: courseId) else { return }
        await MainActor.run {
            selectedCourse = updated
            if let currentModuleId = activeModule?.module.id,
               let updatedModule = updated.modules.first(where: { $0.id == currentModuleId }) {
                activeModule = ModuleNavItem(course: updated, module: updatedModule)
            }
        }
    }
}
