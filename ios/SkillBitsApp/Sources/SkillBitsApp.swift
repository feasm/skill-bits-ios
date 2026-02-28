import SwiftUI
import SkillBitsAuth

@main
struct SkillBitsApp: App {
    @State private var session = AppSession()
    private let env = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            if !session.isLoggedIn {
                LoginView(viewModel: LoginViewModel(repo: env.authRepository)) {
                    session.isLoggedIn = true
                }
            } else if !session.onboardingCompleted {
                OnboardingView(viewModel: OnboardingViewModel(repo: env.authRepository)) {
                    session.onboardingCompleted = true
                }
            } else {
                MainTabView(session: session, env: env)
            }
        }
    }
}
