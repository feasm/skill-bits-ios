import SwiftUI
import SkillBitsAuth
import SkillBitsDesignSystem

@main
struct SkillBitsApp: App {
    @State private var session = AppSession()
    private let env = AppEnvironment()

    private enum AppPhase: Equatable {
        case login, onboarding, main
    }

    private var phase: AppPhase {
        if !session.isLoggedIn { return .login }
        if !session.onboardingCompleted { return .onboarding }
        return .main
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                switch phase {
                case .login:
                    LoginView(viewModel: LoginViewModel(repo: env.authRepository)) {
                        withAnimation(SBMotion.springSmooth) {
                            session.isLoggedIn = true
                        }
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))

                case .onboarding:
                    OnboardingView(viewModel: OnboardingViewModel(repo: env.authRepository)) {
                        withAnimation(SBMotion.springSmooth) {
                            session.onboardingCompleted = true
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .scale(scale: 0.92).combined(with: .opacity)
                    ))

                case .main:
                    MainTabView(session: session, env: env)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .scale(scale: 1.05).combined(with: .opacity)
                        ))
                }
            }
            .animation(SBMotion.springSmooth, value: phase)
            .onAppear {
                session.observeAuthState(manager: env.supabaseManager)
            }
        }
    }
}
