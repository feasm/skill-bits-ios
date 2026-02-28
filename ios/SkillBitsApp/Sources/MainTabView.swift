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
    @State private var selectedModule: Module?
    @State private var selectedLesson: Lesson?
    @State private var activeQuizIntro: QuizIntroSession?
    @State private var activeQuiz: QuizSession?
    @State private var quizResult: QuizResult?
    @State private var nextLessonState: NextLessonState?
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
                        selectedModule = module
                    } startLesson: { module, lesson in
                        selectedModule = module
                        selectedLesson = lesson
                    }
                }
                .navigationDestination(item: $selectedModule) { module in
                    if let course = selectedCourse {
                        ModuleDetailView(course: course, module: module) { lesson in
                            if course.accessTier == .premium {
                                showPaywall = true
                            } else {
                                selectedLesson = lesson
                            }
                        } startQuiz: { quizFirst in
                            if course.accessTier == .premium {
                                showPaywall = true
                            } else {
                                activeQuizIntro = QuizIntroSession(moduleId: module.id)
                            }
                        }
                    }
                }
                .navigationDestination(item: $selectedLesson) { lesson in
                    if let course = selectedCourse, let module = selectedModule {
                        LessonReaderView(viewModel: LessonViewModel(repo: env.lessonRepository), courseId: course.id, moduleId: module.id, lesson: lesson) {
                            let next = nextLesson(in: module, currentLessonId: lesson.id)
                            nextLessonState = NextLessonState(nextLesson: next)
                        } onStartQuiz: {
                            activeQuizIntro = QuizIntroSession(moduleId: module.id)
                        }
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(viewModel: PaywallViewModel(repo: env.paywallRepository)) {
                    showPaywall = false
                    showPurchaseSuccess = true
                }
            }
            .sheet(isPresented: $showPurchaseSuccess) {
                PurchaseSuccessView {
                    showPurchaseSuccess = false
                }
            }
            .sheet(item: $activeQuizIntro) { intro in
                QuizIntroView {
                    activeQuizIntro = nil
                    runQuiz(moduleId: intro.moduleId, quizFirst: false)
                } startQuizFirstMode: {
                    activeQuizIntro = nil
                    runQuiz(moduleId: intro.moduleId, quizFirst: true)
                }
            }
            .sheet(item: $nextLessonState) { state in
                NextLessonView(nextLessonTitle: state.nextLesson?.title ?? "Modulo concluido") {
                    if let next = state.nextLesson {
                        selectedLesson = next
                    }
                    nextLessonState = nil
                }
            }
            .fullScreenCover(item: $activeQuiz) { quiz in
                let vm = QuizViewModel(repo: env.quizRepository)
                QuizQuestionView(viewModel: vm) { result in
                    quizResult = result
                    activeQuiz = nil
                }
                .onAppear {
                    vm.load(moduleId: quiz.moduleId, quizFirst: quiz.quizFirst)
                }
            }
            .sheet(item: $quizResult) { result in
                QuizResultView(result: result) {
                    Task {
                        reviewPoints = (try? await env.quizRepository.fetchGuidedReview(moduleId: result.moduleId)) ?? []
                        await MainActor.run {
                            showGuidedReview = !reviewPoints.isEmpty
                        }
                    }
                } onRetry: {
                    runQuiz(moduleId: result.moduleId, quizFirst: result.quizFirst)
                } onContinue: {
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

            NavigationStack {
                ProfileScreenView(viewModel: ProfileViewModel(repo: env.progressRepository)) {
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

    private func runQuiz(moduleId: String, quizFirst: Bool) {
        activeQuiz = QuizSession(moduleId: moduleId, quizFirst: quizFirst)
    }
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
    func moduleForLesson(in course: Course, lessonId: String) -> Module? {
        course.modules.first(where: { module in
            module.lessons.contains(where: { $0.id == lessonId })
        })
    }

    func nextLesson(in module: Module, currentLessonId: String) -> Lesson? {
        guard let index = module.lessons.firstIndex(where: { $0.id == currentLessonId }) else { return nil }
        guard index + 1 < module.lessons.count else { return nil }
        return module.lessons[index + 1]
    }
}

