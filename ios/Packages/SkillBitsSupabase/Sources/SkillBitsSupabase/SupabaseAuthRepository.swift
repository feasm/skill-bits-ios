import Foundation
import SkillBitsCore
import Supabase

public struct SupabaseAuthRepository: AuthRepository, Sendable {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
    }

    public func login(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    public func completeOnboarding(answer: OnboardingAnswer) async throws {
        try await client.rpc("initialize_user_progress", params: [
            "p_reason": answer.reason,
            "p_daily_goal": answer.dailyGoal == .minutes15 ? "minutes15" : "minutes30"
        ]).execute()
    }

    public func currentSession() async -> Bool {
        (try? await client.auth.session) != nil
    }

    public func signOut() async throws {
        try await client.auth.signOut()
    }
}
