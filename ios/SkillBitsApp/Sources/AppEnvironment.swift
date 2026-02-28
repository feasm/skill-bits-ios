import Foundation
import SkillBitsCore
import SkillBitsNetworking
import SkillBitsSupabase
import SkillBitsAuth
import SkillBitsCourses
import SkillBitsLesson
import SkillBitsQuiz
import SkillBitsProgress
import SkillBitsProfile
import SkillBitsPaywall
import SkillBitsHome

final class AppEnvironment {
    let authRepository: AuthRepository
    let coursesRepository: CoursesRepository
    let lessonRepository: LessonRepository
    let quizRepository: QuizRepository
    let progressRepository: ProgressRepository
    let paywallRepository: PaywallRepository
    let supabaseManager: SupabaseManager?

    init(useMock: Bool = false) {
        if useMock {
            let backend = MockBackendService()
            self.supabaseManager = nil
            self.authRepository = MockAuthRepository()
            self.coursesRepository = MockCoursesRepository(backend: backend)
            self.lessonRepository = MockLessonRepository(backend: backend)
            self.quizRepository = MockQuizRepository(backend: backend)
            self.progressRepository = MockProgressRepository(backend: backend)
            self.paywallRepository = MockPaywallRepository(backend: backend)
        } else {
            let manager = SupabaseManager(url: Secrets.supabaseURL, anonKey: Secrets.supabaseAnonKey)
            self.supabaseManager = manager
            self.authRepository = manager.authRepository
            self.coursesRepository = manager.coursesRepository
            self.lessonRepository = manager.lessonRepository
            self.quizRepository = manager.quizRepository
            self.progressRepository = manager.progressRepository
            self.paywallRepository = MockPaywallRepository(backend: MockBackendService())
        }
    }
}
