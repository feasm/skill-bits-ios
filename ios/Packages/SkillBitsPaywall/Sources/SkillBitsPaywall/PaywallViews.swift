import SwiftUI
import Observation
import SkillBitsCore
import SkillBitsDesignSystem

@Observable
public final class PaywallViewModel {
    public var isLoading = false
    private let repo: PaywallRepository

    public init(repo: PaywallRepository) { self.repo = repo }

    public func buyMonthly(onSuccess: @escaping () -> Void) {
        isLoading = true
        Task {
            try? await repo.purchaseMonthly()
            await MainActor.run {
                self.isLoading = false
                onSuccess()
            }
        }
    }

    public func buyAnnual(onSuccess: @escaping () -> Void) {
        isLoading = true
        Task {
            try? await repo.purchaseAnnual()
            await MainActor.run {
                self.isLoading = false
                onSuccess()
            }
        }
    }
}

public struct PaywallView: View {
    @Bindable var viewModel: PaywallViewModel
    public let onSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var animateIn = false

    public init(viewModel: PaywallViewModel, onSuccess: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onSuccess = onSuccess
    }

    public var body: some View {
        ZStack {
            SBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    HStack {
                        Spacer()
                        SBIconButton(icon: "xmark") { dismiss() }
                    }

                    SBGradientBanner {
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.2))
                                .frame(width: 72, height: 72)
                                .overlay(Image(systemName: "star.fill").font(.system(size: 30)).foregroundStyle(.white))
                            SBBadge("Plano premium", kind: .custom(background: .white.opacity(0.25), text: .white))
                            Text("Acelere sua evolucao")
                                .font(SBFont.display(26))
                            Text("Acesso completo, trilhas avancadas e beneficios exclusivos")
                                .font(SBFont.body(13))
                                .foregroundStyle(.white.opacity(0.86))
                                .multilineTextAlignment(.center)
                        }
                    }

                    SBCard {
                        VStack(spacing: 8) {
                            SBBadge("Recomendado")
                            Text("R$ 19,90")
                                .font(SBFont.display(36))
                            Text("/mes")
                                .font(SBFont.body(12))
                                .foregroundStyle(SBColor.textTertiary)
                            Text("Cancele quando quiser")
                                .font(SBFont.body(12))
                                .foregroundStyle(SBColor.textSecondary)
                            Text("Economize com plano anual")
                                .font(SBFont.label(12))
                                .foregroundStyle(SBColor.success)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    VStack(spacing: 10) {
                        benefit("Acesso a todos os cursos")
                        benefit("Revisoes guiadas ilimitadas")
                        benefit("Sprints e trilhas premium")
                    }

                    SBPrimaryButton(viewModel.isLoading ? "Processando..." : "Assinar mensal", size: .lg) {
                        SBHaptics.selection()
                        viewModel.buyMonthly {
                            SBHaptics.success()
                            onSuccess()
                        }
                    }
                    SBSecondaryButton("Assinar anual") {
                        SBHaptics.selection()
                        viewModel.buyAnnual {
                            SBHaptics.success()
                            onSuccess()
                        }
                    }
                }
                .padding(20)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)
                .animation(SBMotion.medium, value: animateIn)
            }
        }
        .onAppear { animateIn = true }
    }

    private func benefit(_ text: String) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient.skillBits)
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: "checkmark").foregroundStyle(.white))
            Text(text)
                .font(SBFont.body(14))
                .foregroundStyle(SBColor.textPrimary)
            Spacer()
        }
    }
}

public struct PurchaseSuccessView: View {
    public let backToCourses: () -> Void
    @State private var visible = false

    public init(backToCourses: @escaping () -> Void) {
        self.backToCourses = backToCourses
    }

    public var body: some View {
        ZStack {
            SBMeshBackground()
            ScrollView {
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient.skillBits)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 46))
                                    .foregroundStyle(.white)
                            )
                            .sbShadow(.celebration)
                            .scaleEffect(visible ? 1 : 0.6)
                            .opacity(visible ? 1 : 0)
                            .animation(.interpolatingSpring(stiffness: 180, damping: 12), value: visible)

                        ForEach(Array([0.0, 90.0, 180.0, 270.0].enumerated()), id: \.offset) { idx, angle in
                            Image(systemName: "sparkle")
                                .foregroundStyle(SBColor.warningAlt)
                                .offset(x: visible ? 62 : 48)
                                .rotationEffect(.degrees(angle))
                                .opacity(visible ? 1 : 0)
                                .animation(SBMotion.medium.delay(Double(idx) * 0.1), value: visible)
                        }
                    }

                    Text("Assinatura ativada!")
                        .font(SBFont.display(28))
                        .offset(y: visible ? 0 : 20)
                        .opacity(visible ? 1 : 0)
                        .animation(SBMotion.medium.delay(0.2), value: visible)
                    Text("Seu acesso premium foi liberado com sucesso.")
                        .font(SBFont.body(14))
                        .foregroundStyle(SBColor.textSecondary)
                    SBCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Beneficios liberados")
                                .font(SBFont.label(14))
                            Text("• Cursos premium\n• Revisoes ilimitadas\n• Conteudo exclusivo")
                                .font(SBFont.body(13))
                                .foregroundStyle(SBColor.textSecondary)
                        }
                    }
                    SBPrimaryButton("Voltar para Cursos", size: .lg) { backToCourses() }
                }
                .padding(24)
            }
        }
        .onAppear {
            visible = true
            SBHaptics.xpGain()
        }
    }
}
