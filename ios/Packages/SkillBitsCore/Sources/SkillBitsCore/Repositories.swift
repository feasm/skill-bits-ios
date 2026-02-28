import Foundation

public struct OnboardingAnswer: Codable, Sendable {
    public let reason: String
    public let dailyGoal: DailyGoal

    public init(reason: String, dailyGoal: DailyGoal) {
        self.reason = reason
        self.dailyGoal = dailyGoal
    }
}

public protocol AuthRepository: Sendable {
    func login(email: String, password: String) async throws
    func completeOnboarding(answer: OnboardingAnswer) async throws
}

public protocol CoursesRepository: Sendable {
    func fetchCourses() async throws -> [Course]
    func fetchCourse(id: String) async throws -> Course
}

public protocol LessonRepository: Sendable {
    func fetchLessonContent(courseId: String, moduleId: String, lessonId: String) async throws -> LessonContent
    func completeLesson(courseId: String, moduleId: String, lessonId: String) async throws
}

public protocol QuizRepository: Sendable {
    func fetchQuiz(moduleId: String) async throws -> [QuizQuestion]
    func submitQuiz(moduleId: String, answers: [Int], quizFirst: Bool) async throws -> QuizResult
    func fetchGuidedReview(moduleId: String) async throws -> [GuidedReviewPoint]
}

public protocol ProgressRepository: Sendable {
    func fetchProgress() async throws -> UserProgress
    func saveProgress(_ progress: UserProgress) async throws
}

public protocol PaywallRepository: Sendable {
    func isPremiumActive() async -> Bool
    func purchaseMonthly() async throws
    func purchaseAnnual() async throws
}
