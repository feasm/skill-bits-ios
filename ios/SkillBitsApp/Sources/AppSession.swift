import Foundation
import Observation
import SkillBitsSupabase

@Observable
final class AppSession {
    var isLoggedIn = false
    var onboardingCompleted = false

    func observeAuthState(manager: SupabaseManager?) {
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
                    }
                }
            }
        }
        Task {
            if await manager.hasExistingSession() {
                await MainActor.run { self.isLoggedIn = true }
            }
        }
    }
}
