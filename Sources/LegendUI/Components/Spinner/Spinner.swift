import SwiftUI

// MARK: - Spinner

/// A circular loading indicator with customizable size and color.
///
/// Use `Spinner` to indicate that content is loading or an operation is in progress.
/// The spinner automatically animates when `isLoading` is `true`.
public struct Spinner: View {
    private var theme: LegendTheme { SharedTheme.value }

    private let sizeType: SpinnerSizeType
    private let colorType: SpinnerColorType
    private let isLoading: Bool

    @State private var rotation: Double = 0

    /// Creates a new spinner with the specified configuration.
    ///
    /// - Parameters:
    ///   - size: The size of the spinner. Defaults to `.md`.
    ///   - color: The color style of the spinner. Defaults to `.default`.
    ///   - isLoading: Whether the spinner should be visible and animating. Defaults to `true`.
    public init(
        size: SpinnerSizeType = .md,
        color: SpinnerColorType = .default,
        isLoading: Bool = true,
    ) {
        self.sizeType = size
        self.colorType = color
        self.isLoading = isLoading
    }

    private var spinnerSize: SpinnerSize {
        .resolved(sizeType)
    }

    private var spinnerColor: SpinnerColor {
        .resolved(colorType, theme: theme)
    }

    public var body: some View {
        Group {
            if isLoading {
                SpinnerGradientView(
                    color: spinnerColor.color,
                    size: spinnerSize.size,
                    lineWidth: spinnerSize.lineWidth,
                )
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(
                        .linear(duration: 0.8)
                            .repeatForever(autoreverses: false),
                    ) {
                        rotation = 360
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Sizes") {
        VStack(spacing: 32) {
            HStack(spacing: 32) {
                VStack(spacing: 8) {
                    Spinner(size: .sm)
                    Text("Small")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 8) {
                    Spinner(size: .md)
                    Text("Medium")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 8) {
                    Spinner(size: .lg)
                    Text("Large")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }

    #Preview("Colors") {
        VStack(spacing: 32) {
            HStack(spacing: 32) {
                VStack(spacing: 8) {
                    Spinner(color: .default)
                    Text("Default")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 8) {
                    Spinner(color: .success)
                    Text("Success")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 8) {
                    Spinner(color: .warning)
                    Text("Warning")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 8) {
                    Spinner(color: .danger)
                    Text("Danger")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }

    #Preview("Custom Color") {
        VStack(spacing: 32) {
            HStack(spacing: 32) {
                VStack(spacing: 8) {
                    Spinner(color: .custom(.purple))
                    Text("Purple")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 8) {
                    Spinner(color: .custom(.pink))
                    Text("Pink")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 8) {
                    Spinner(color: .custom(.teal))
                    Text("Teal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }

    #Preview("Loading State") {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Loading...")
                Spinner(isLoading: true)
            }

            Divider()

            VStack(spacing: 16) {
                Text("Not Loading")
                Spinner(isLoading: false)
            }
        }
        .padding()
    }

    #Preview("Size & Color Combinations") {
        VStack(spacing: 24) {
            HStack(spacing: 24) {
                Spinner(size: .sm, color: .default)
                Spinner(size: .sm, color: .success)
                Spinner(size: .sm, color: .warning)
                Spinner(size: .sm, color: .danger)
            }

            HStack(spacing: 24) {
                Spinner(size: .md, color: .default)
                Spinner(size: .md, color: .success)
                Spinner(size: .md, color: .warning)
                Spinner(size: .md, color: .danger)
            }

            HStack(spacing: 24) {
                Spinner(size: .lg, color: .default)
                Spinner(size: .lg, color: .success)
                Spinner(size: .lg, color: .warning)
                Spinner(size: .lg, color: .danger)
            }
        }
        .padding()
    }

    #Preview("Dark Mode") {
        VStack(spacing: 32) {
            HStack(spacing: 32) {
                Spinner(size: .sm, color: .default)
                Spinner(size: .md, color: .success)
                Spinner(size: .lg, color: .warning)
            }
        }
        .padding()
        .preferredColorScheme(.dark)
    }

    #Preview("In Context") {
        VStack(spacing: 32) {
            // Button with spinner
            HStack {
                Spinner(size: .sm)
                Text("Loading...")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            // Card with centered spinner
            VStack(spacing: 16) {
                Spinner(size: .md, color: .default)
                Text("Loading data...")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(32)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            // Large loading state
            VStack(spacing: 24) {
                Spinner(size: .lg, color: .success)
                Text("Please wait")
                    .font(.headline)
                Text("Fetching your content...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(40)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(16)
        }
        .padding()
    }
#endif
