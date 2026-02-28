import SwiftUI
import SkillBitsCore
import SkillBitsDesignSystem

// MARK: - Coordinator

public final class PremiumGateState: ObservableObject {
    @Published public var isPresented = false
    @Published public var contextTitle: String?
    private var pendingAction: (() -> Void)?
    private var paywallAction: (() -> Void)?

    public init() {}

    /// Checks the access tier: runs the action immediately if free,
    /// or presents the premium gate sheet if premium.
    public func require(
        tier: AccessTier,
        context: String? = nil,
        action: @escaping () -> Void
    ) {
        guard tier == .premium else {
            action()
            return
        }
        contextTitle = context
        pendingAction = action
        isPresented = true
    }

    /// Called when the user taps "Unlock Premium" on the gate sheet.
    public func openPaywall(via handler: @escaping () -> Void) {
        paywallAction = handler
    }

    func triggerPaywall() {
        isPresented = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.paywallAction?()
        }
    }

    /// Called after a successful purchase to execute the original action.
    public func unlockPending() {
        pendingAction?()
        pendingAction = nil
    }
}

// MARK: - Gate Sheet View

public struct PremiumGateSheet: View {
    let contextTitle: String?
    let onUnlock: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var animateIn = false

    public init(contextTitle: String?, onUnlock: @escaping () -> Void) {
        self.contextTitle = contextTitle
        self.onUnlock = onUnlock
    }

    public var body: some View {
        VStack(spacing: 0) {
            SBBottomSheetHandle()
                .padding(.top, 10)

            ScrollView {
                VStack(spacing: 20) {
                    lockIcon
                    headerText
                    benefitsList
                    actions
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .background(SBColor.background)
        .onAppear {
            withAnimation(SBMotion.springBouncy) { animateIn = true }
            SBHaptics.selection()
        }
    }

    // MARK: - Sections

    private var lockIcon: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [SBColor.accent.opacity(0.15), SBColor.teal.opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 88, height: 88)

            Circle()
                .fill(LinearGradient.skillBits)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                )
                .shadow(color: SBColor.gradientShadow, radius: 12, y: 6)
        }
        .scaleEffect(animateIn ? 1 : 0.5)
        .opacity(animateIn ? 1 : 0)
    }

    private var headerText: some View {
        VStack(spacing: 6) {
            Text("Conteudo Premium")
                .font(SBFont.display(22))
                .foregroundStyle(SBColor.textPrimary)

            if let contextTitle {
                Text("\"\(contextTitle)\" faz parte do plano premium.")
                    .font(SBFont.body(14))
                    .foregroundStyle(SBColor.textSecondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Esse conteudo faz parte do plano premium.")
                    .font(SBFont.body(14))
                    .foregroundStyle(SBColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 12)
        .animation(SBMotion.medium.delay(0.08), value: animateIn)
    }

    private var benefitsList: some View {
        SBCard {
            VStack(alignment: .leading, spacing: 12) {
                benefitRow(icon: "book.fill", text: "Acesso a todos os cursos")
                benefitRow(icon: "arrow.trianglehead.2.counterclockwise", text: "Revisoes guiadas ilimitadas")
                benefitRow(icon: "bolt.fill", text: "Sprints e trilhas exclusivas")
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 16)
        .animation(SBMotion.medium.delay(0.14), value: animateIn)
    }

    private var actions: some View {
        VStack(spacing: 10) {
            SBPrimaryButton("Desbloquear Premium", size: .lg, icon: "sparkles") {
                SBHaptics.selection()
                onUnlock()
            }

            Button {
                dismiss()
            } label: {
                Text("Agora nao")
                    .font(SBFont.label(14))
                    .foregroundStyle(SBColor.textTertiary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Fechar")
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 16)
        .animation(SBMotion.medium.delay(0.20), value: animateIn)
    }

    // MARK: - Components

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(LinearGradient.skillBits)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                )

            Text(text)
                .font(SBFont.body(14))
                .foregroundStyle(SBColor.textPrimary)

            Spacer()
        }
    }
}

// MARK: - View Modifier

public struct PremiumGateOverlay: ViewModifier {
    @ObservedObject var gate: PremiumGateState
    let openPaywall: () -> Void

    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $gate.isPresented) {
                PremiumGateSheet(contextTitle: gate.contextTitle) {
                    gate.triggerPaywall()
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(24)
            }
            .onAppear {
                gate.openPaywall(via: openPaywall)
            }
    }
}

public extension View {
    /// Attaches the premium gate sheet to this view hierarchy.
    /// Apply once near the root (e.g., on the NavigationStack).
    func premiumGateOverlay(
        _ gate: PremiumGateState,
        openPaywall: @escaping () -> Void
    ) -> some View {
        modifier(PremiumGateOverlay(gate: gate, openPaywall: openPaywall))
    }
}
