import SwiftUI

// MARK: - Skeleton

// MARK: - Animation Type

/// The animation style for skeleton loading effects.
public enum SkeletonAnimation: Sendable {
    case shimmer(duration: TimeInterval = 3.0)
    case pulse(duration: TimeInterval = 1.5, minOpacity: Double = 0.4, maxOpacity: Double = 1.0)
    case none
}

// MARK: - Shimmer Constants

private enum ShimmerConstants {
    static let gradientWidth: CGFloat = 600
    static let paddingWidth: CGFloat = 600
    static let skeletonOpacity: Double = 0.1
}

// MARK: - Shimmer Effect

private struct ShimmerEffect: ViewModifier {
    let duration: TimeInterval
    @State private var isAnimating = false
    @State private var startPhase: CGFloat = 0

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            let globalFrame = geometry.frame(in: .global)

            content
                .mask(alignment: .leading) {
                    AnimatableShimmer(
                        isAnimating: isAnimating,
                        startPhase: startPhase,
                        globalFrame: globalFrame,
                        duration: duration,
                    )
                }
        }
        .onAppear {
            startPhase = Date().timeIntervalSince1970
                .truncatingRemainder(dividingBy: duration) / duration

            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                isAnimating.toggle()
            }
        }
    }
}

private struct AnimatableShimmer: View, @MainActor Animatable {
    var progress: CGFloat
    let startPhase: CGFloat
    let globalFrame: CGRect
    let duration: TimeInterval

    init(isAnimating: Bool, startPhase: CGFloat, globalFrame: CGRect, duration: TimeInterval) {
        self.progress = isAnimating ? 1 : 0
        self.startPhase = startPhase
        self.globalFrame = globalFrame
        self.duration = duration
    }

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        let gradientWidth = ShimmerConstants.gradientWidth
        let unitWidth = gradientWidth + ShimmerConstants.paddingWidth

        let actualPhase = (startPhase + progress).truncatingRemainder(dividingBy: 1.0)
        let cycleOffset = unitWidth * actualPhase

        let viewOffsetInPattern = globalFrame.minX.truncatingRemainder(dividingBy: unitWidth)
        let localOffsetX = cycleOffset - viewOffsetInPattern - unitWidth

        let maskColor = Color.black

        HStack(spacing: 0) {
            ForEach(0 ..< 5, id: \.self) { _ in
                maskColor.frame(width: ShimmerConstants.paddingWidth)
                LinearGradient(
                    colors: [
                        maskColor,
                        maskColor.opacity(ShimmerConstants.skeletonOpacity),
                        maskColor,
                    ],
                    startPoint: .leading,
                    endPoint: .trailing,
                )
                .frame(width: gradientWidth)
            }
        }
        .offset(x: localOffsetX)
    }
}

// MARK: - Pulse Effect

private struct PulseEffect: ViewModifier {
    let duration: TimeInterval
    let minOpacity: Double
    let maxOpacity: Double
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? maxOpacity : minOpacity)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

// MARK: - Skeleton Modifier

private struct SkeletonModifier: ViewModifier {
    let isLoading: Bool
    let animation: SkeletonAnimation

    func body(content: Content) -> some View {
        if isLoading {
            switch animation {
            case .shimmer(let duration):
                content.modifier(ShimmerEffect(duration: duration))
            case .pulse(let duration, let minOpacity, let maxOpacity):
                content.modifier(PulseEffect(
                    duration: duration,
                    minOpacity: minOpacity,
                    maxOpacity: maxOpacity,
                ))
            case .none:
                content
            }
        } else {
            content
        }
    }
}

// MARK: - View Extension

extension View {
    /// Applies a skeleton loading effect to the view.
    ///
    /// Use this modifier to show placeholder animations while content is loading.
    /// The skeleton effect masks the view with an animated overlay.
    ///
    /// - Parameters:
    ///   - isLoading: When `true`, the skeleton animation is displayed.
    ///                When `false`, the view renders normally.
    ///   - animation: The animation style to use. Defaults to `.shimmer()`.
    ///                Use `.pulse()` for a fading effect or `.none` to disable animation.
    public func skeleton(
        isLoading: Bool,
        animation: SkeletonAnimation = .shimmer(),
    ) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading, animation: animation))
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Shimmer") {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Palette.fill3)
                .frame(width: 200, height: 20)
                .skeleton(isLoading: true)

            RoundedRectangle(cornerRadius: 8)
                .fill(Palette.fill3)
                .frame(width: 150, height: 20)
                .skeleton(isLoading: true)

            RoundedRectangle(cornerRadius: 8)
                .fill(Palette.fill3)
                .frame(width: 100, height: 20)
                .skeleton(isLoading: true)
        }
        .padding()
    }

    #Preview("Pulse") {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Palette.fill3)
                .frame(width: 200, height: 20)
                .skeleton(isLoading: true, animation: .pulse())

            Circle()
                .fill(Palette.fill3)
                .frame(width: 48, height: 48)
                .skeleton(isLoading: true, animation: .pulse())
        }
        .padding()
    }

    #Preview("Card Skeleton") {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Palette.fill3)
                    .frame(width: 48, height: 48)
                    .skeleton(isLoading: true)

                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Palette.fill3)
                        .frame(width: 120, height: 14)
                        .skeleton(isLoading: true)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Palette.fill3)
                        .frame(width: 80, height: 12)
                        .skeleton(isLoading: true)
                }
            }

            RoundedRectangle(cornerRadius: 8)
                .fill(Palette.fill3)
                .frame(height: 160)
                .skeleton(isLoading: true)
        }
        .padding()
    }

    #Preview("List Skeleton") {
        VStack(spacing: 16) {
            ForEach(0 ..< 3, id: \.self) { _ in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Palette.fill3)
                        .frame(width: 48, height: 48)
                        .skeleton(isLoading: true)

                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Palette.fill3)
                            .frame(maxWidth: .infinity)
                            .frame(height: 14)
                            .skeleton(isLoading: true)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Palette.fill3)
                            .frame(width: 150, height: 12)
                            .skeleton(isLoading: true)
                    }
                }
            }
        }
        .padding()
    }
#endif
