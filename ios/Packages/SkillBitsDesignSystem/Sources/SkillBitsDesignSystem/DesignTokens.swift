import SwiftUI

public enum SBColor {
    public static let background = Color(red: 0.969, green: 0.980, blue: 0.992)
    public static let surface = Color.white
    public static let border = Color(red: 0.902, green: 0.929, blue: 0.961)
    public static let textPrimary = Color(red: 0.043, green: 0.059, blue: 0.078)
    public static let textSecondary = Color(red: 0.294, green: 0.357, blue: 0.416)
    public static let textTertiary = Color(red: 0.463, green: 0.533, blue: 0.604)
    public static let inputBg = Color(red: 0.949, green: 0.965, blue: 0.984)
    public static let inputBorder = Color(red: 0.882, green: 0.918, blue: 0.957)
    public static let accent = Color(red: 0.176, green: 0.584, blue: 0.855)
    public static let teal = Color(red: 0.251, green: 0.878, blue: 0.816)
    public static let success = Color(red: 0.067, green: 0.600, blue: 0.557)
    public static let error = Color(red: 0.863, green: 0.208, blue: 0.271)
    public static let warning = Color(red: 0.910, green: 0.592, blue: 0.239)
    public static let warningAlt = Color(red: 0.969, green: 0.592, blue: 0.118)
    public static let purple = Color(red: 0.545, green: 0.361, blue: 0.965)

    public static let successBg = success.opacity(0.12)
    public static let errorBg = error.opacity(0.10)
    public static let purpleBg = purple.opacity(0.10)
    public static let accentBg = accent.opacity(0.10)
    public static let gradientShadow = accent.opacity(0.28)
}

public enum SBRadius {
    public static let card: CGFloat = 17
    public static let cardLg: CGFloat = 20
    public static let input: CGFloat = 14
    public static let pill: CGFloat = 20
    public static let icon: CGFloat = 12
    public static let tag: CGFloat = 7
}

public enum SBSpacing {
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 20
    public static let xxl: CGFloat = 24
}

public enum SBFont {
    public static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .default)
    }

    public static func title(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }

    public static func body(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }

    public static func label(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }

    public static func stat(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    public static func code(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
}

public enum SBMotion {
    public static let springBouncy: Animation = .spring(response: 0.50, dampingFraction: 0.70)
    public static let springSmooth: Animation = .spring(response: 0.40, dampingFraction: 0.85)
    public static let quick: Animation = .easeOut(duration: 0.20)
    public static let medium: Animation = .easeInOut(duration: 0.35)
    public static let slow: Animation = .easeInOut(duration: 0.60)
    public static let scoreCircle: Animation = .easeOut(duration: 0.80)
    public static let staggerDelay: Double = 0.06
}

public struct SBShadowStyle: ViewModifier {
    public enum Kind {
        case button
        case logo
        case sticky
        case card
        case celebration
    }

    let kind: Kind

    public func body(content: Content) -> some View {
        switch kind {
        case .button:
            content.shadow(color: SBColor.gradientShadow, radius: 20, x: 0, y: 6)
        case .logo:
            content.shadow(color: SBColor.gradientShadow, radius: 32, x: 0, y: 12)
        case .sticky:
            content.shadow(color: Color.black.opacity(0.06), radius: 24, x: 0, y: -8)
        case .card:
            content.shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        case .celebration:
            content.shadow(color: SBColor.gradientShadow, radius: 48, x: 0, y: 16)
        }
    }
}

public extension View {
    func sbShadow(_ kind: SBShadowStyle.Kind) -> some View {
        modifier(SBShadowStyle(kind: kind))
    }
}

#if canImport(UIKit)
import UIKit

public enum SBHaptics {
    public static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    public static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    public static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    public static func xpGain() {
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.prepare()
        gen.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            gen.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                gen.impactOccurred()
            }
        }
    }
}

public extension LinearGradient {
    static var skillBits: LinearGradient {
        LinearGradient(colors: [SBColor.teal, SBColor.accent], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var subtle: LinearGradient {
        LinearGradient(
            colors: [SBColor.teal.opacity(0.12), SBColor.accent.opacity(0.12)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var success: LinearGradient {
        LinearGradient(
            colors: [SBColor.success, Color(red: 0.220, green: 0.937, blue: 0.490)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

public extension Color {
    init(hex: String) {
        var sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if sanitized.count == 3 {
            sanitized = sanitized.map { "\($0)\($0)" }.joined()
        }
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

public struct SBMeshBackground: View {
    public init() {}

    public var body: some View {
        ZStack {
            Circle()
                .fill(SBColor.teal.opacity(0.16))
                .frame(width: 320, height: 320)
                .offset(x: -130, y: -220)
                .blur(radius: 80)
            Circle()
                .fill(SBColor.accent.opacity(0.16))
                .frame(width: 380, height: 380)
                .offset(x: 140, y: -190)
                .blur(radius: 90)
            Circle()
                .fill(SBColor.purple.opacity(0.08))
                .frame(width: 260, height: 260)
                .offset(x: 0, y: 320)
                .blur(radius: 90)
        }
        .ignoresSafeArea()
    }
}

#else
public enum SBHaptics {
    public static func success() {}
    public static func selection() {}
    public static func error() {}
    public static func xpGain() {}
}
#endif