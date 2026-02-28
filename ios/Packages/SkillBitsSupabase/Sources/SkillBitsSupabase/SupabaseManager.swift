import Foundation
import Supabase
import SkillBitsCore

public enum SupabaseAuthEvent: Sendable {
    case signedIn, signedOut
}

public final class SupabaseManager: @unchecked Sendable {
    let client: SupabaseClient

    public init(url: String, anonKey: String) {
        self.client = SupabaseClient(
            supabaseURL: URL(string: url)!,
            supabaseKey: anonKey
        )
    }

    // MARK: - Repositories

    public var authRepository: AuthRepository {
        SupabaseAuthRepository(client: client)
    }

    public var coursesRepository: CoursesRepository {
        SupabaseCoursesRepository(client: client)
    }

    public var lessonRepository: LessonRepository {
        SupabaseLessonRepository(client: client)
    }

    public var quizRepository: QuizRepository {
        SupabaseQuizRepository(client: client)
    }

    public var progressRepository: ProgressRepository {
        SupabaseProgressRepository(client: client)
    }

    // MARK: - Auth State

    public var authStateChanges: AsyncStream<SupabaseAuthEvent> {
        AsyncStream { [client] continuation in
            let task = Task {
                for await (event, _) in client.auth.authStateChanges {
                    switch event {
                    case .signedIn:
                        continuation.yield(.signedIn)
                    case .signedOut:
                        continuation.yield(.signedOut)
                    default:
                        break
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    public func hasExistingSession() async -> Bool {
        (try? await client.auth.session) != nil
    }
}
