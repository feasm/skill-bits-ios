import Foundation
import Observation
import SkillBitsCore
import SkillBitsSupabase

@Observable
final class AppSession {
    var isLoggedIn = false
    var onboardingCompleted = false
    var onboardingReason: String?

    func observeAuthState(manager: SupabaseManager?, progressRepo: ProgressRepository?) {
        guard let manager else { return }
        Task {
            for await event in manager.authStateChanges {
                await MainActor.run {
                    switch event {
                    case .signedIn:
                        self.isLoggedIn = true
                    case .signedOut:
                        self.isLoggedIn = false
                        self.onboardingCompleted = false
                        self.onboardingReason = nil
                    }
                }
                if case .signedIn = event {
                    await restoreOnboardingState(progressRepo: progressRepo)
                }
            }
        }
        Task {
            if await manager.hasExistingSession() {
                await MainActor.run { self.isLoggedIn = true }
                await restoreOnboardingState(progressRepo: progressRepo)
            }
        }
    }

    private func restoreOnboardingState(progressRepo: ProgressRepository?) async {
        guard let repo = progressRepo else { return }
        do {
            let progress = try await repo.fetchProgress()
            await MainActor.run {
                self.onboardingCompleted = true
                self.onboardingReason = progress.onboardingReason
            }
        } catch {
            // user_progress not found — onboarding not yet completed
        }
    }
}
