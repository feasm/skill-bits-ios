import Foundation
import SkillBitsCore
import SkillBitsSupabase

final class AppSession: ObservableObject {
    @Published var isLoggedIn = false
    @Published var onboardingCompleted = false
    @Published var onboardingReason: String?

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
