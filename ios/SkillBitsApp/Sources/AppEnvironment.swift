import Foundation
import SkillBitsCore
import SkillBitsNetworking
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

    init() {
        let backend = MockBackendService()
        self.authRepository = MockAuthRepository()
        self.coursesRepository = MockCoursesRepository(backend: backend)
        self.lessonRepository = MockLessonRepository(backend: backend)
        self.quizRepository = MockQuizRepository(backend: backend)
        self.progressRepository = MockProgressRepository(backend: backend)
        self.paywallRepository = MockPaywallRepository(backend: backend)
    }
}
