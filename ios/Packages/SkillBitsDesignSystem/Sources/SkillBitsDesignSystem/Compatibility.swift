import SwiftUI

// MARK: - onChange compatibility (iOS 16.4 / iOS 17+)

public extension View {
    @ViewBuilder
    func sbOnChange<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
        if #available(iOS 17, *) {
            onChange(of: value) { _, newValue in action(newValue) }
        } else {
            onChange(of: value) { newValue in action(newValue) }
        }
    }

    @ViewBuilder
    func sbOnChange<V: Equatable>(of value: V, perform action: @escaping () -> Void) -> some View {
        if #available(iOS 17, *) {
            onChange(of: value) { _, _ in action() }
        } else {
            onChange(of: value) { _ in action() }
        }
    }
}

// MARK: - navigationDestination(item:) polyfill (iOS 16.4 / iOS 17+)

public extension View {
    @ViewBuilder
    func sbNavigationDestination<Item: Hashable, Content: View>(
        item: Binding<Item?>,
        @ViewBuilder destination: @escaping (Item) -> Content
    ) -> some View {
        if #available(iOS 17, *) {
            navigationDestination(item: item, destination: destination)
        } else {
            navigationDestination(isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            )) {
                if let unwrapped = item.wrappedValue {
                    destination(unwrapped)
                }
            }
        }
    }
}

// MARK: - UnevenRoundedRectangle polyfill (iOS 16.4 / iOS 17+)

public struct SBUnevenRoundedRectangle: Shape {
    var topLeadingRadius: CGFloat
    var topTrailingRadius: CGFloat
    var bottomLeadingRadius: CGFloat
    var bottomTrailingRadius: CGFloat

    public init(
        topLeadingRadius: CGFloat = 0,
        topTrailingRadius: CGFloat = 0,
        bottomLeadingRadius: CGFloat = 0,
        bottomTrailingRadius: CGFloat = 0
    ) {
        self.topLeadingRadius = topLeadingRadius
        self.topTrailingRadius = topTrailingRadius
        self.bottomLeadingRadius = bottomLeadingRadius
        self.bottomTrailingRadius = bottomTrailingRadius
    }

    public func path(in rect: CGRect) -> Path {
        if #available(iOS 17, *) {
            return UnevenRoundedRectangle(
                topLeadingRadius: topLeadingRadius,
                bottomLeadingRadius: bottomLeadingRadius,
                bottomTrailingRadius: bottomTrailingRadius,
                topTrailingRadius: topTrailingRadius
            ).path(in: rect)
        } else {
            var path = Path()
            let tl = min(topLeadingRadius, min(rect.width, rect.height) / 2)
            let tr = min(topTrailingRadius, min(rect.width, rect.height) / 2)
            let bl = min(bottomLeadingRadius, min(rect.width, rect.height) / 2)
            let br = min(bottomTrailingRadius, min(rect.width, rect.height) / 2)

            path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
            path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                        tangent2End: CGPoint(x: rect.maxX, y: rect.minY + tr),
                        radius: tr)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
            path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
                        tangent2End: CGPoint(x: rect.maxX - br, y: rect.maxY),
                        radius: br)
            path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
            path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
                        tangent2End: CGPoint(x: rect.minX, y: rect.maxY - bl),
                        radius: bl)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
            path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                        tangent2End: CGPoint(x: rect.minX + tl, y: rect.minY),
                        radius: tl)
            path.closeSubpath()
            return path
        }
    }
}
