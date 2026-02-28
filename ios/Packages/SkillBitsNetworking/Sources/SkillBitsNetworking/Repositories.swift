import Foundation
import SkillBitsCore

public final class MockAuthRepository: AuthRepository {
    public init() {}
    public func login(email: String, password: String) async throws {}
    public func completeOnboarding(answer: OnboardingAnswer) async throws {}
}

public final class MockCoursesRepository: CoursesRepository {
    private let backend: MockBackendService
    public init(backend: MockBackendService) { self.backend = backend }
    public func fetchCourses() async throws -> [Course] { await backend.listCourses() }
    public func fetchCourse(id: String) async throws -> Course { try await backend.course(id: id) }
}

public final class MockLessonRepository: LessonRepository {
    private let backend: MockBackendService
    public init(backend: MockBackendService) { self.backend = backend }
    public func fetchLessonContent(courseId: String, moduleId: String, lessonId: String) async throws -> LessonContent { await backend.lessonContent(lessonId: lessonId) }
    public func completeLesson(courseId: String, moduleId: String, lessonId: String) async throws { await backend.completeLesson(courseId: courseId, moduleId: moduleId, lessonId: lessonId) }
}

public final class MockQuizRepository: QuizRepository {
    private let backend: MockBackendService
    public init(backend: MockBackendService) { self.backend = backend }
    public func fetchQuiz(moduleId: String) async throws -> [QuizQuestion] { await backend.quiz(moduleId: moduleId) }
    public func submitQuiz(moduleId: String, answers: [Int], quizFirst: Bool) async throws -> QuizResult { await backend.submit(moduleId: moduleId, answers: answers, quizFirst: quizFirst) }
    public func fetchGuidedReview(moduleId: String) async throws -> [GuidedReviewPoint] { await backend.guidedReview(moduleId: moduleId) }
}

public final class MockProgressRepository: ProgressRepository {
    private let backend: MockBackendService
    public init(backend: MockBackendService) { self.backend = backend }
    public func fetchProgress() async throws -> UserProgress { await backend.fetchProgress() }
    public func saveProgress(_ progress: UserProgress) async throws { await backend.saveProgress(progress) }
}

public final class MockPaywallRepository: PaywallRepository {
    private let backend: MockBackendService
    public init(backend: MockBackendService) { self.backend = backend }
    public func isPremiumActive() async -> Bool { await backend.isPremium() }
    public func purchaseMonthly() async throws { await backend.setPremium(true) }
    public func purchaseAnnual() async throws { await backend.setPremium(true) }
}
