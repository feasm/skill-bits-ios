import SwiftUI

public enum SBButtonSize {
    case sm
    case md
    case lg

    var height: CGFloat {
        switch self {
        case .sm: 42
        case .md: 50
        case .lg: 56
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .sm: 14
        case .md: 15
        case .lg: 17
        }
    }
}

public struct SBPressableButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(SBMotion.springSmooth, value: configuration.isPressed)
    }
}

public struct SBPrimaryButton: View {
    let title: String
    let size: SBButtonSize
    let icon: String?
    let disabled: Bool
    let action: () -> Void

    public init(_ title: String, size: SBButtonSize = .md, icon: String? = nil, disabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.size = size
        self.icon = icon
        self.disabled = disabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(SBFont.label(size.fontSize))
                    .tracking(-0.2)
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: size.fontSize - 1, weight: .bold))
                }
            }
            .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: size.height)
                .background(disabled ? AnyShapeStyle(Color(red: 0.773, green: 0.835, blue: 0.898)) : AnyShapeStyle(LinearGradient.skillBits))
                .clipShape(RoundedRectangle(cornerRadius: SBRadius.card, style: .continuous))
                .if(!disabled) { $0.sbShadow(.button) }
        }
        .disabled(disabled)
        .buttonStyle(SBPressableButtonStyle())
    }
}

public struct SBSecondaryButton: View {
    let title: String
    let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(SBFont.label(16))
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
    }
}

public struct SBOutlineButton: View {
    let title: String
    let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(SBFont.label(16))
                .foregroundStyle(SBColor.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: SBRadius.card, style: .continuous)
                        .stroke(SBColor.accent, lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: SBRadius.card, style: .continuous))
        }
        .buttonStyle(SBPressableButtonStyle())
    }
}

public struct SBGhostButton: View {
    let title: String
    let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(SBFont.label(14))
                .foregroundStyle(SBColor.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .buttonStyle(SBPressableButtonStyle())
    }
}

public struct SBDangerButton: View {
    let title: String
    let action: () -> Void

    public init(_ title: String = "Sair da conta", action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text(title)
            }
            .font(SBFont.label(15))
            .foregroundStyle(SBColor.error)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .overlay(
                RoundedRectangle(cornerRadius: SBRadius.card, style: .continuous)
                    .stroke(SBColor.error.opacity(0.25), lineWidth: 1.5)
            )
        }
        .buttonStyle(SBPressableButtonStyle())
    }
}

public struct SBTextField: View {
    let title: String
    let icon: String
    @Binding var text: String
    var secure: Bool
    var trailingIcon: String?
    var onTrailingTap: (() -> Void)?
    @FocusState private var focused: Bool

    public init(_ title: String, icon: String, text: Binding<String>, secure: Bool = false, trailingIcon: String? = nil, onTrailingTap: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self._text = text
        self.secure = secure
        self.trailingIcon = trailingIcon
        self.onTrailingTap = onTrailingTap
    }

    public var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(focused ? SBColor.accent : SBColor.textTertiary)
                .animation(SBMotion.quick, value: focused)
                .frame(width: 18)
            Group {
                if secure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                        .textInputAutocapitalization(.never)
                }
            }
            .focused($focused)
            .font(SBFont.body(15))
            .foregroundStyle(SBColor.textPrimary)
            if let trailingIcon {
                Button {
                    onTrailingTap?()
                } label: {
                    Image(systemName: trailingIcon)
                        .foregroundStyle(SBColor.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .background(SBColor.inputBg)
        .clipShape(RoundedRectangle(cornerRadius: SBRadius.input, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SBRadius.input, style: .continuous)
                .stroke(focused ? SBColor.accent : SBColor.inputBorder, lineWidth: 1.5)
                .animation(SBMotion.quick, value: focused)
        )
    }
}

public struct SBCard<Content: View>: View {
    private let content: Content
    private let padded: Bool

    public init(padded: Bool = true, @ViewBuilder content: () -> Content) {
        self.padded = padded
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padded ? SBSpacing.lg : 0)
            .background(SBColor.surface)
            .overlay(
                RoundedRectangle(cornerRadius: SBRadius.card, style: .continuous)
                    .stroke(SBColor.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: SBRadius.card, style: .continuous))
            .sbShadow(.card)
    }
}

public struct SBGlassCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

public struct SBNavBar: View {
    let title: String
    let subtitle: String?
    let onBack: (() -> Void)?

    public init(title: String, subtitle: String? = nil, onBack: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.onBack = onBack
    }

    public var body: some View {
        HStack(spacing: 12) {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(SBColor.textPrimary)
                        .frame(width: 38, height: 38)
                        .background(SBColor.background)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(SBColor.border))
                }
                .buttonStyle(.plain)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SBFont.title(17))
                    .foregroundStyle(SBColor.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(SBFont.body(12))
                        .foregroundStyle(SBColor.textTertiary)
                }
            }
            Spacer()
        }
    }
}

public struct SBFilterPill: View {
    let title: String
    let active: Bool

    public init(_ title: String, active: Bool) {
        self.title = title
        self.active = active
    }

    public var body: some View {
        Text(title)
            .font(SBFont.label(13))
            .foregroundStyle(active ? .white : SBColor.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 7)
            .background(active ? AnyShapeStyle(SBColor.accent) : AnyShapeStyle(SBColor.surface))
            .overlay(
                RoundedRectangle(cornerRadius: SBRadius.pill, style: .continuous)
                    .stroke(active ? SBColor.accent : SBColor.border, lineWidth: 1.5)
            )
            .clipShape(Capsule())
            .animation(SBMotion.quick, value: active)
    }
}

public struct SBBadge: View {
    public enum Kind {
        case premium
        case free
        case partial
        case level(String)
        case custom(background: Color, text: Color)
    }

    let text: String
    let kind: Kind

    public init(_ text: String, kind: Kind = .premium) {
        self.text = text
        self.kind = kind
    }

    public var body: some View {
        Text(text.uppercased())
            .font(SBFont.label(11))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(bgColor)
            .foregroundStyle(textColor)
            .overlay(Capsule().stroke(borderColor, lineWidth: 1))
            .clipShape(Capsule())
    }

    private var bgColor: Color {
        switch kind {
        case .premium: SBColor.accent.opacity(0.12)
        case .free: Color(red: 0.220, green: 0.937, blue: 0.490).opacity(0.14)
        case .partial: Color.orange.opacity(0.12)
        case .level(let value):
            colorForLevel(value).opacity(0.14)
        case .custom(let background, _):
            background
        }
    }

    private var textColor: Color {
        switch kind {
        case .premium: SBColor.accent
        case .free: SBColor.success
        case .partial: .orange
        case .level(let value): colorForLevel(value)
        case .custom(_, let text):
            text
        }
    }

    private var borderColor: Color {
        textColor.opacity(0.30)
    }

    private func colorForLevel(_ value: String) -> Color {
        let lower = value.lowercased()
        if lower.contains("inic") { return SBColor.success }
        if lower.contains("inter") { return SBColor.warning }
        return Color(red: 0.910, green: 0.365, blue: 0.459)
    }
}

public struct SBProgressBar: View {
    let value: Double
    let height: CGFloat
    let gradient: LinearGradient

    public init(value: Double, height: CGFloat = 8, gradient: LinearGradient = .skillBits) {
        self.value = min(max(value, 0), 1)
        self.height = height
        self.gradient = gradient
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(SBColor.border)
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(gradient)
                    .frame(width: geo.size.width * value)
                    .animation(.easeOut(duration: 0.4), value: value)
            }
        }
        .frame(height: height)
        .accessibilityElement()
        .accessibilityLabel("Progresso")
        .accessibilityValue("\(Int(value * 100))%")
    }
}

public struct SBSectionHeader: View {
    let title: String

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title.uppercased())
            .font(SBFont.label(13))
            .tracking(0.4)
            .foregroundStyle(SBColor.textTertiary)
    }
}

public struct SBStatCard: View {
    let icon: String
    let value: String
    let label: String
    let tint: Color

    public init(icon: String, value: String, label: String, tint: Color) {
        self.icon = icon
        self.value = value
        self.label = label
        self.tint = tint
    }

    public var body: some View {
        SBCard {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                    .background(tint.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Text(value)
                    .font(SBFont.stat(22))
                    .foregroundStyle(SBColor.textPrimary)
                Text(label)
                    .font(SBFont.body(12))
                    .foregroundStyle(SBColor.textTertiary)
            }
        }
    }
}

public struct SBAnimatedCounter: View {
    let target: Int
    let font: Font
    let color: Color
    @State private var current: Double = 0

    public init(target: Int, font: Font = SBFont.stat(22), color: Color = SBColor.textPrimary) {
        self.target = target
        self.font = font
        self.color = color
    }

    public var body: some View {
        Text("\(Int(current))")
            .font(font)
            .foregroundStyle(color)
            .accessibilityLabel("\(target)")
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    current = Double(target)
                }
            }
            .onChange(of: target) { _, newValue in
                current = 0
                withAnimation(.easeOut(duration: 0.8)) {
                    current = Double(newValue)
                }
            }
    }
}

public struct SBScoreCircle: View {
    let score: Int
    @State private var progress: CGFloat = 0

    public init(score: Int) {
        self.score = max(0, min(100, score))
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(SBColor.border, lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(LinearGradient.skillBits, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(SBMotion.scoreCircle, value: progress)
            VStack(spacing: 4) {
                SBAnimatedCounter(target: score, font: SBFont.stat(32))
                Text("pontuacao")
                    .font(SBFont.label(12))
                    .foregroundStyle(SBColor.textTertiary)
            }
        }
        .frame(width: 140, height: 140)
        .onAppear { progress = CGFloat(score) / 100 }
    }
}

public struct SBIconButton: View {
    let icon: String
    let action: () -> Void

    public init(icon: String, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(SBColor.textPrimary)
                .frame(width: 38, height: 38)
                .background(SBColor.background)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(SBColor.border))
        }
        .buttonStyle(SBPressableButtonStyle())
    }
}

public struct SBGradientBanner<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(LinearGradient.skillBits)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: SBRadius.card, style: .continuous))
    }
}

public struct SBSettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void

    public init(icon: String, title: String, subtitle: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(SBColor.accent)
                    .frame(width: 36, height: 36)
                    .background(SBColor.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(SBFont.label(14))
                        .foregroundStyle(SBColor.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(SBFont.body(12))
                            .foregroundStyle(SBColor.textTertiary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(SBColor.textTertiary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(SBPressableButtonStyle())
    }
}

public struct SBBottomSheetHandle: View {
    public init() {}

    public var body: some View {
        Capsule()
            .fill(SBColor.border)
            .frame(width: 36, height: 4)
            .padding(.top, 8)
    }
}

public struct SBBottomSheet<Content: View>: View {
    let title: String
    let content: Content

    public init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 14) {
            SBBottomSheetHandle()
            Text(title)
                .font(SBFont.title(17))
            content
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

public struct SBLoadingState: View {
    let message: String

    public init(_ message: String = "Carregando...") {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
            Text(message)
                .font(SBFont.body(14))
                .foregroundStyle(SBColor.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

public struct SBErrorState: View {
    let title: String
    let message: String
    let retryAction: () -> Void

    public init(
        title: String = "Algo deu errado",
        message: String = "Nao foi possivel carregar os dados.",
        retryAction: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: 12) {
            Spacer()
            SBCard {
                VStack(spacing: 10) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 28))
                        .foregroundStyle(SBColor.error)
                    Text(title)
                        .font(SBFont.title(17))
                    Text(message)
                        .font(SBFont.body(13))
                        .foregroundStyle(SBColor.textSecondary)
                        .multilineTextAlignment(.center)
                    SBPrimaryButton("Tentar novamente", size: .md) {
                        retryAction()
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}

public extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
