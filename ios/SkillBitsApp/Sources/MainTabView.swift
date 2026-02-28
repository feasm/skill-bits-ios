import SwiftUI
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
    @ObservedObject var session: AppSession
    let env: AppEnvironment

    @StateObject private var coursesViewModel: CoursesViewModel
    @StateObject private var progressViewModel: ProgressViewModel
    @StateObject private var profileViewModel: ProfileViewModel
    @State private var selectedTab: TabItem = .courses
    @State private var selectedCourse: Course?

    init(session: AppSession, env: AppEnvironment) {
        self.session = session
        self.env = env
        _coursesViewModel = StateObject(wrappedValue: CoursesViewModel(repo: env.coursesRepository, onboardingReason: session.onboardingReason))
        _progressViewModel = StateObject(wrappedValue: ProgressViewModel(repo: env.progressRepository, coursesRepo: env.coursesRepository))
        _profileViewModel = StateObject(wrappedValue: ProfileViewModel(repo: env.progressRepository, onboardingReason: session.onboardingReason))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                CoursesView(viewModel: coursesViewModel) { course in
                    selectedCourse = course
                }
            }
            .tabItem { Label("Cursos", systemImage: "book") }
            .tag(TabItem.courses)

            NavigationStack {
                MyStudyHost(env: env, openCourse: { course in
                    selectedCourse = course
                }, onExploreCourses: {
                    selectedTab = .courses
                })
            }
            .tabItem { Label("Meus estudos", systemImage: "flame") }
            .tag(TabItem.myStudy)

            NavigationStack {
                ProgressScreenView(viewModel: progressViewModel)
            }
            .tabItem { Label("Progresso", systemImage: "chart.bar") }
            .tag(TabItem.progress)

            ProfileScreenView(viewModel: profileViewModel) {
                withAnimation(SBMotion.springSmooth) {
                    session.isLoggedIn = false
                    session.onboardingCompleted = false
                }
            }
            .tabItem { Label("Perfil", systemImage: "person") }
            .tag(TabItem.profile)
        }
        .tint(SBColor.accent)
        .fullScreenCover(item: $selectedCourse) { course in
            CourseFlowView(
                initialCourse: course,
                env: env,
                onRefreshDashboards: { refreshDashboardsAfterLearningAction() }
            )
        }
        .sbOnChange(of: selectedTab) {
            SBHaptics.selection()
        }
        .sbOnChange(of: session.onboardingReason) { newValue in
            coursesViewModel.onboardingReason = newValue
            profileViewModel.onboardingReason = newValue
        }
    }
}

// MARK: - Course Flow (modal with own NavigationStack)

private struct CourseFlowView: View {
    @State var course: Course
    let env: AppEnvironment
    let onRefreshDashboards: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var activeModule: ModuleNavItem?
    @State private var activeLesson: LessonNavItem?
    @State private var activeQuizIntro: QuizIntroSession?
    @State private var activeQuiz: QuizSession?
    @State private var quizResult: QuizResult?
    @State private var pendingQuizSession: QuizSession?
    @State private var pendingQuizResult: QuizResult?
    @State private var nextLessonState: NextLessonState?
    @State private var pendingNextLesson: LessonNavItem?
    @StateObject private var premiumGate = PremiumGateState()
    @State private var showPaywall = false
    @State private var showPurchaseSuccess = false
    @State private var reviewPoints: [GuidedReviewPoint] = []
    @State private var showGuidedReview = false

    init(initialCourse: Course, env: AppEnvironment, onRefreshDashboards: @escaping () -> Void) {
        _course = State(initialValue: initialCourse)
        self.env = env
        self.onRefreshDashboards = onRefreshDashboards
    }

    var body: some View {
        NavigationStack {
            CourseDetailView(
                course: course,
                onClose: { dismiss() },
                openModule: { module in
                    premiumGate.require(tier: module.accessTier, context: module.title) {
                        activeModule = ModuleNavItem(course: course, module: module)
                    }
                },
                startLesson: { module, lesson in
                    premiumGate.require(tier: module.accessTier, context: module.title) {
                        activeLesson = LessonNavItem(courseId: course.id, module: module, lesson: lesson)
                    }
                }
            )
            .sbNavigationDestination(item: $activeModule) { nav in
                ModuleDetailView(
                    course: nav.course,
                    module: nav.module,
                    onClose: { dismiss() },
                    startLesson: { lesson in
                        premiumGate.require(tier: nav.module.accessTier, context: nav.module.title) {
                            activeLesson = LessonNavItem(courseId: nav.course.id, module: nav.module, lesson: lesson)
                        }
                    },
                    startQuiz: { _ in
                        premiumGate.require(tier: nav.module.accessTier, context: nav.module.title) {
                            activeQuizIntro = QuizIntroSession(moduleId: nav.module.id, moduleTitle: nav.module.title)
                        }
                    }
                )
            }
            .sbNavigationDestination(item: $activeLesson) { nav in
                LessonReaderView(
                    repo: env.lessonRepository,
                    courseId: nav.courseId,
                    moduleId: nav.module.id,
                    lesson: nav.lesson,
                    onClose: { dismiss() },
                    onComplete: {
                        Task {
                            await refreshCourse()
                            onRefreshDashboards()
                        }
                        let next = nextLesson(in: nav.module, currentLessonId: nav.lesson.id)
                        nextLessonState = NextLessonState(nextLesson: next)
                    },
                    onStartQuiz: {
                        activeQuizIntro = QuizIntroSession(moduleId: nav.module.id, moduleTitle: nav.module.title)
                    }
                )
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
            QuizIntroView(
                moduleTitle: intro.moduleTitle,
                quizRepo: env.quizRepository,
                moduleId: intro.moduleId
            ) {
                pendingQuizSession = QuizSession(moduleId: intro.moduleId, quizFirst: false)
                activeQuizIntro = nil
            } startQuizFirstMode: {
                pendingQuizSession = QuizSession(moduleId: intro.moduleId, quizFirst: true)
                activeQuizIntro = nil
            }
        }
        .sheet(item: $nextLessonState, onDismiss: {
            if let pending = pendingNextLesson {
                pendingNextLesson = nil
                activeLesson = pending
            }
        }) { state in
            NextLessonView(nextLessonTitle: state.nextLesson?.title ?? "Modulo concluido") {
                if let next = state.nextLesson, let current = activeLesson {
                    pendingNextLesson = LessonNavItem(courseId: current.courseId, module: current.module, lesson: next)
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
                    if result.passed {
                        await refreshCourse()
                        onRefreshDashboards()
                    }
                    reviewPoints = (try? await env.quizRepository.fetchGuidedReview(moduleId: result.moduleId)) ?? []
                    await MainActor.run {
                        showGuidedReview = !reviewPoints.isEmpty
                    }
                }
            } onRetry: {
                pendingQuizSession = QuizSession(moduleId: result.moduleId, quizFirst: result.quizFirst)
                quizResult = nil
            } onContinue: {
                if result.passed {
                    Task {
                        await refreshCourse()
                        onRefreshDashboards()
                    }
                }
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
    }

    private func refreshCourse() async {
        guard let updated = try? await env.coursesRepository.fetchCourse(id: course.id) else { return }
        await MainActor.run {
            course = updated
            if let currentModuleId = activeModule?.module.id,
               let updatedModule = updated.modules.first(where: { $0.id == currentModuleId }) {
                activeModule = ModuleNavItem(course: updated, module: updatedModule)
            }
        }
    }

    private func nextLesson(in module: Module, currentLessonId: String) -> Lesson? {
        guard let index = module.lessons.firstIndex(where: { $0.id == currentLessonId }) else { return nil }
        guard index + 1 < module.lessons.count else { return nil }
        return module.lessons[index + 1]
    }
}

// MARK: - Navigation Models

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
    let moduleTitle: String
    var id: String { moduleId }
}

private struct NextLessonState: Identifiable {
    let nextLesson: Lesson?
    var id: String { nextLesson?.id ?? "none" }
}

// MARK: - My Study Host

private struct MyStudyHost: View {
    let env: AppEnvironment
    let openCourse: (Course) -> Void
    let onExploreCourses: () -> Void
    @State private var courses: [Course] = []
    @State private var progress: UserProgress?
    @State private var isLoading = false
    @State private var loadError = false
    @State private var hasLoadedOnce = false
    @State private var lastLoadedAt: Date?
    private let refreshInterval: TimeInterval = 300

    var body: some View {
        MyStudyView(
            courses: courses,
            progress: progress,
            isLoading: isLoading && !hasLoadedOnce,
            loadError: loadError && !hasLoadedOnce,
            openCourse: openCourse,
            onExploreCourses: onExploreCourses,
            onRetry: { Task { await fetchIfNeeded(force: true) } }
        )
        .task { await fetchIfNeeded(force: false) }
        .refreshable { await fetchIfNeeded(force: true) }
    }

    private func fetchIfNeeded(force: Bool) async {
        guard force || shouldFetch else { return }
        if !hasLoadedOnce { isLoading = true }
        loadError = false
        do {
            let fetchedCourses = try await env.coursesRepository.fetchCourses()
            let fetchedProgress = try? await env.progressRepository.fetchProgress()
            courses = fetchedCourses
            progress = fetchedProgress
            hasLoadedOnce = true
            lastLoadedAt = Date()
        } catch {
            if !hasLoadedOnce { loadError = true }
        }
        isLoading = false
    }

    private var shouldFetch: Bool {
        guard let lastLoadedAt else { return true }
        return Date().timeIntervalSince(lastLoadedAt) >= refreshInterval
    }
}

// MARK: - Dashboard Refresh

private extension MainTabView {
    func refreshDashboardsAfterLearningAction() {
        coursesViewModel.invalidateCache()
        progressViewModel.invalidateCache()
        profileViewModel.invalidateCache()
        coursesViewModel.load(force: true)
        progressViewModel.load(force: true)
        profileViewModel.load(force: true)
    }
}
