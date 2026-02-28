import SwiftUI
import Observation
import SkillBitsCore
import SkillBitsDesignSystem

@Observable
public final class LoginViewModel {
    public var email = ""
    public var password = ""
    public var loading = false
    private let repo: AuthRepository

    public init(repo: AuthRepository) { self.repo = repo }

    public func login(onSuccess: @escaping () -> Void) {
        loading = true
        Task {
            try? await repo.login(email: email, password: password)
            await MainActor.run {
                self.loading = false
                onSuccess()
            }
        }
    }
}

public struct LoginView: View {
    @Bindable var viewModel: LoginViewModel
    let onLoginSuccess: () -> Void
    @State private var showPassword = false
    @State private var animateIn = false

    public init(viewModel: LoginViewModel, onLoginSuccess: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onLoginSuccess = onLoginSuccess
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(LinearGradient.skillBits)
                        .frame(width: 76, height: 76)
                        .overlay(
                            Image(systemName: "square.3.layers.3d.down.forward")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .sbShadow(.logo)
                        .padding(.top, 20)

                    VStack(spacing: 8) {
                        Text("Bem-vindo")
                            .font(SBFont.display(30))
                            .tracking(-0.5)
                            .foregroundStyle(SBColor.textPrimary)
                        Text("Faca login para continuar estudando")
                            .font(SBFont.body(16))
                            .foregroundStyle(SBColor.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 12) {
                        SBTextField("Seu email", icon: "envelope.fill", text: $viewModel.email)
                        if showPassword {
                            SBTextField("Sua senha", icon: "lock.fill", text: $viewModel.password, trailingIcon: "eye.slash", onTrailingTap: {
                                withAnimation(SBMotion.quick) { showPassword = false }
                            })
                        } else {
                            SBTextField("Sua senha", icon: "lock.fill", text: $viewModel.password, secure: true, trailingIcon: "eye", onTrailingTap: {
                                withAnimation(SBMotion.quick) { showPassword = true }
                            })
                        }
                    }

                    HStack {
                        Spacer()
                        Button("Esqueci minha senha") {}
                            .font(SBFont.label(14))
                            .foregroundStyle(SBColor.accent)
                    }

                    SBPrimaryButton(viewModel.loading ? "Entrando..." : "Entrar", size: .lg, disabled: viewModel.loading) {
                        viewModel.login(onSuccess: onLoginSuccess)
                    }

                    HStack(spacing: 10) {
                        Rectangle().fill(SBColor.border).frame(height: 1)
                        Text("ou continue com")
                            .font(SBFont.body(12))
                            .foregroundStyle(SBColor.textTertiary)
                        Rectangle().fill(SBColor.border).frame(height: 1)
                    }
                    .padding(.vertical, 8)

                    Button {} label: {
                        HStack(spacing: 8) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Entrar com Apple")
                                .font(SBFont.label(16))
                        }
                        .foregroundStyle(SBColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(SBColor.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: SBRadius.card, style: .continuous)
                                .stroke(SBColor.border, lineWidth: 1.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: SBRadius.card, style: .continuous))
                    }
                    .buttonStyle(SBPressableButtonStyle())

                    HStack(spacing: 4) {
                        Text("Nao tem conta?")
                            .font(SBFont.body(14))
                            .foregroundStyle(SBColor.textSecondary)
                        Button("Criar conta gratis") {}
                            .font(SBFont.label(14))
                            .foregroundStyle(SBColor.accent)
                    }
                    .padding(.top, 4)

                    Text("Ao continuar, voce concorda com os Termos e Politica de Privacidade.")
                        .font(SBFont.body(12))
                        .foregroundStyle(SBColor.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)
                .animation(SBMotion.medium, value: animateIn)
            }
        }
        .onAppear { animateIn = true }
    }
}

@Observable
public final class OnboardingViewModel {
    public var selectedReason = ""
    public var dailyGoal: DailyGoal = .minutes15
    private let repo: AuthRepository

    public init(repo: AuthRepository) { self.repo = repo }

    public func submit(onFinish: @escaping () -> Void) {
        Task {
            try? await repo.completeOnboarding(answer: OnboardingAnswer(reason: selectedReason, dailyGoal: dailyGoal))
            await MainActor.run { onFinish() }
        }
    }
}

public struct OnboardingView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onFinish: () -> Void
    @State private var selectedGoalIndex = 0

    public init(viewModel: OnboardingViewModel, onFinish: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onFinish = onFinish
    }

    private struct MotivationOption: Identifiable {
        let id: String
        let emoji: String
        let title: String
        let subtitle: String
    }

    private let reasons: [MotivationOption] = [
        MotivationOption(id: "universidade", emoji: "🎓", title: "Sou universitario", subtitle: "Quero construir base tecnica com consistencia"),
        MotivationOption(id: "carreira", emoji: "🚀", title: "Migrar de carreira", subtitle: "Quero entrar em tecnologia mais rapido"),
        MotivationOption(id: "curiosidade", emoji: "🔎", title: "Aprender no meu ritmo", subtitle: "Tenho curiosidade e quero evoluir sem pressao"),
        MotivationOption(id: "evolucao", emoji: "💻", title: "Evoluir na area", subtitle: "Ja trabalho com tecnologia e quero destravar proximo nivel")
    ]

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Vamos personalizar seu estudo")
                        .font(SBFont.display(28))
                        .tracking(-0.3)
                        .foregroundStyle(SBColor.textPrimary)
                    Text("Escolha seu objetivo e sua meta diaria para comecar.")
                        .font(SBFont.body(15))
                        .foregroundStyle(SBColor.textSecondary)

                    sectionHeader(icon: "clock.fill", title: "Tempo por dia")
                    HStack(spacing: 10) {
                        goalChip(title: "15", subtitle: "minutos", selected: selectedGoalIndex == 0) {
                            selectedGoalIndex = 0
                            viewModel.dailyGoal = .minutes15
                        }
                        goalChip(title: "30", subtitle: "minutos", selected: selectedGoalIndex == 1) {
                            selectedGoalIndex = 1
                            viewModel.dailyGoal = .minutes30
                        }
                    }

                    sectionHeader(icon: "target", title: "Objetivo")
                    VStack(spacing: 10) {
                        ForEach(reasons) { reason in
                            Button {
                                withAnimation(SBMotion.springSmooth) {
                                    viewModel.selectedReason = reason.id
                                }
                                SBHaptics.selection()
                            } label: {
                                HStack(spacing: 12) {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(viewModel.selectedReason == reason.id ? SBColor.accentBg : SBColor.background)
                                        .frame(width: 54, height: 54)
                                        .overlay(Text(reason.emoji).font(.system(size: 32)))
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(reason.title)
                                            .font(SBFont.title(16))
                                            .foregroundStyle(SBColor.textPrimary)
                                        Text(reason.subtitle)
                                            .font(SBFont.body(13))
                                            .foregroundStyle(SBColor.textSecondary)
                                            .lineLimit(2)
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(minHeight: 78)
                                .padding(14)
                                .background(SBColor.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: SBRadius.cardLg, style: .continuous)
                                        .stroke(viewModel.selectedReason == reason.id ? SBColor.accent : SBColor.border, lineWidth: 2)
                                )
                            }
                            .clipShape(RoundedRectangle(cornerRadius: SBRadius.cardLg, style: .continuous))
                            .buttonStyle(SBPressableButtonStyle())
                        }
                    }
                    .padding(.bottom, 92)
                }
                .padding(24)
            }
        }
        .safeAreaInset(edge: .bottom) {
            SBCard {
                SBPrimaryButton("Comecar", size: .lg, icon: "arrow.right", disabled: viewModel.selectedReason.isEmpty) {
                    viewModel.submit(onFinish: onFinish)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(SBColor.surface)
            .sbShadow(.sticky)
        }
    }

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 10) {
            Rectangle().fill(SBColor.border).frame(height: 1)
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(SBColor.accent)
            Text(title)
                .font(SBFont.label(12))
                .foregroundStyle(SBColor.textSecondary)
            Rectangle().fill(SBColor.border).frame(height: 1)
        }
    }

    private func goalChip(title: String, subtitle: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 14, weight: .bold))
                Text(title)
                    .font(SBFont.stat(22))
                Text(subtitle)
                    .font(SBFont.body(12))
            }
            .foregroundStyle(selected ? .white : SBColor.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 88)
                .background(selected ? AnyShapeStyle(LinearGradient.skillBits) : AnyShapeStyle(SBColor.surface))
                .overlay(
                    RoundedRectangle(cornerRadius: SBRadius.card, style: .continuous)
                        .stroke(selected ? Color.clear : SBColor.border, lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: SBRadius.card, style: .continuous))
        }
        .buttonStyle(SBPressableButtonStyle())
    }
}
