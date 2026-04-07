import SwiftUI

// MARK: - Storybook Thumbnail

/// A showcase thumbnail view for LegendUI design system.
/// Designed for 16:9 aspect ratio, perfect for GIF thumbnails.
private struct StorybookThumbnail: View {
    private var theme: LegendTheme { SharedTheme.value }

    @State private var showDialog = false
    @State private var toasts: [ToastValue] = []
    @State private var isDarkMode = false

    // Component states
    @State private var switchOn = true
    @State private var checkboxOn = true
    @State private var selectedPlan: Plan = .pro
    @State private var themeIconRotation: Double = 0

    // Animation states
    @State private var animatedChipIndex = 0
    @State private var pulseScale: CGFloat = 1.0

    private enum Plan: String, CaseIterable {
        case free = "Free"
        case pro = "Pro"
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = width * 9 / 16

            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        theme.colors.background.primary,
                        theme.colors.background.secondary,
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing,
                )
                .ignoresSafeArea()

                VStack(spacing: height * 0.04) {
                    // Header
                    headerSection

                    // Main content - 2x2 Grid
                    HStack(spacing: width * 0.03) {
                        // Left column
                        VStack(spacing: height * 0.04) {
                            componentsCard
                            selectCard
                        }

                        // Right column
                        VStack(spacing: height * 0.04) {
                            skeletonCard
                            interactiveCard
                        }
                    }
                    .padding(.horizontal, width * 0.04)

                    Spacer()

                    // Bottom chips
                    bottomSection
                }
                .padding(.vertical, height * 0.04)
            }
            .frame(width: width, height: height)
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .animation(.easeInOut(duration: 0.5), value: isDarkMode)
        .dialog(isPresented: $showDialog, hasBackgroundBlur: true) {
            DialogContent {
                DialogHeader(title: "Welcome to LegendUI", showCloseButton: true)

                DialogBody {
                    Text("A beautiful SwiftUI cross-platform design component library.")
                }

                DialogFooter {
                    DialogCloseButton("Close")

                    Button("Get Started") {
                        showDialog = false
                        toasts.append(ToastValue(
                            title: "Ready!",
                            message: "Start building",
                            type: .success,
                            duration: 3.0,
                        ))
                    }
                    .buttonStyle(.legend(variant: .primary, size: .sm, isFullWidth: false))
                }
            }
        }
        .toasts($toasts, alignment: .top)
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(spacing: 12) {
            // Logo
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(theme.colors.accent.default)
                    .frame(width: 40, height: 40)

                Text("L")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .scaleEffect(pulseScale)

            VStack(alignment: .leading, spacing: 1) {
                Text("LegendUI")
                    .fontStyle(theme.typography.lg)
                    .foregroundStyle(theme.colors.foreground.primary)

                Text("SwiftUI Design System")
                    .fontStyle(theme.typography.xs)
                    .foregroundStyle(theme.colors.foreground.secondary)
            }

            Spacer()

            // Dark mode toggle button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    themeIconRotation += 360
                }
                isDarkMode.toggle()
            } label: {
                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isDarkMode ? .yellow : .orange)
                    .rotationEffect(.degrees(themeIconRotation))
                    .frame(width: 32, height: 32)
                    .background(theme.colors.surface.secondary)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Components Card (Top Left)

    private var componentsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Buttons row
            HStack(spacing: 8) {
                Button("Primary") {}
                    .buttonStyle(.legend(variant: .primary, size: .sm, isFullWidth: false))

                Button("Secondary") {}
                    .buttonStyle(.legend(variant: .secondary, size: .sm, isFullWidth: false))

                Button {} label: {
                    Image(systemName: "heart.fill")
                }
                .buttonStyle(.legend(
                    variant: .danger,
                    size: .sm,
                    isIconOnly: true,
                    isFullWidth: false,
                ))
            }

            // Input + Toggles
            HStack(spacing: 12) {
                TextInput(
                    "Email",
                    text: .constant("hello@legendui.dev"),
                    prompt: "Enter email",
                    size: .sm,
                )

                Toggle(isOn: $switchOn) {
                    EmptyView()
                }
                .toggleStyle(.legendSwitch(size: .sm))

                Toggle(isOn: $checkboxOn) {
                    EmptyView()
                }
                .toggleStyle(.legendCheckbox(size: .sm))
            }

            // Spinners row
            HStack(spacing: 14) {
                Spinner(size: .sm, color: .success)
                Spinner(size: .sm, color: .warning)
                Spinner(size: .sm, color: .danger)

                Text("Loading...")
                    .fontStyle(theme.typography.xs)
                    .foregroundStyle(theme.colors.foreground.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    // MARK: - Select Card (Bottom Left)

    private var selectCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Plan")
                .fontStyle(theme.typography.sm)
                .foregroundStyle(theme.colors.foreground.secondary)

            Select(
                selection: $selectedPlan,
                items: [
                    SelectItem("Free", description: "$0/month", value: .free),
                    SelectItem("Pro", description: "$9/month", value: .pro),
                ],
                style: .card(size: .sm),
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    // MARK: - Skeleton Card (Top Right)

    private var skeletonCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Avatar + Name
            HStack(alignment: .center, spacing: 10) {
                Circle()
                    .fill(theme.colors.surface.tertiary)
                    .frame(width: 32, height: 32)
                    .skeleton(isLoading: true)

                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(theme.colors.surface.tertiary)
                        .frame(width: 80, height: 10)
                        .skeleton(isLoading: true)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(theme.colors.surface.tertiary)
                        .frame(width: 50, height: 8)
                        .skeleton(isLoading: true)
                }

                Spacer()
            }

            // Content text lines
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(theme.colors.surface.tertiary)
                    .frame(height: 8)
                    .skeleton(isLoading: true)

                RoundedRectangle(cornerRadius: 3)
                    .fill(theme.colors.surface.tertiary)
                    .frame(width: 120, height: 8)
                    .skeleton(isLoading: true)
            }

            // Image placeholder
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.colors.surface.tertiary)
                .frame(height: 50)
                .skeleton(isLoading: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    // MARK: - Interactive Card (Bottom Right)

    private var interactiveCard: some View {
        VStack(spacing: 12) {
            Text("Try it!")
                .fontStyle(theme.typography.base)
                .foregroundStyle(theme.colors.foreground.primary)

            Button {
                showDialog = true
            } label: {
                Label("Open Dialog", systemImage: "rectangle.on.rectangle")
            }
            .buttonStyle(.legend(variant: .primary, size: .sm, isFullWidth: true))

            Button {
                addRandomToast()
            } label: {
                Label("Show Toast", systemImage: "bell.badge")
            }
            .buttonStyle(.legend(variant: .secondary, size: .sm, isFullWidth: true))

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    themeIconRotation += 360
                }
                isDarkMode.toggle()
            } label: {
                Label(
                    isDarkMode ? "Light Mode" : "Dark Mode",
                    systemImage: isDarkMode ? "sun.max" : "moon",
                )
            }
            .buttonStyle(.legend(variant: .tertiary, size: .sm, isFullWidth: true))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
    }

    // MARK: - Bottom Section (Chips)

    private var bottomSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipItem("Buttons", color: .primary, index: 0)
                chipItem("Inputs", color: .secondary, index: 1)
                chipItem("Dialogs", color: .success, index: 2)
                chipItem("Toasts", color: .warning, index: 3)
                chipItem("Skeleton", color: .danger, index: 4)
                chipItem("Chips", color: .default, index: 5)
                chipItem("Toggles", color: .primary, index: 6)
                chipItem("Select", color: .secondary, index: 7)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Shared Components

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: theme.layout.radius.large, style: .continuous)
            .fill(theme.colors.surface.primary)
            .shadow(color: .black.opacity(0.08), radius: 12, y: 3)
    }

    private func chipItem(_ title: String, color: ChipColorType, index: Int) -> some View {
        Chip(
            title,
            variant: animatedChipIndex == index ? .solid : .flat,
            color: color,
            size: .sm,
        )
        .animation(.easeInOut(duration: 0.3), value: animatedChipIndex)
    }

    // MARK: - Helpers

    private func startAnimations() {
        // Pulse animation for logo
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.08
        }

        // Chip highlight animation (only auto animation)
        Task {
            while true {
                try? await Task.sleep(for: .seconds(1.0))
                withAnimation {
                    animatedChipIndex = (animatedChipIndex + 1) % 8
                }
            }
        }
    }

    private func addRandomToast() {
        let types: [ToastType] = [.default, .success, .warning, .danger]
        let titles = ["Notification", "Success!", "Warning", "Error"]
        let messages = [
            "Something happened",
            "Action completed",
            "Check this out",
            "Something went wrong",
        ]
        let randomIndex = Int.random(in: 0 ..< types.count)

        toasts.append(ToastValue(
            title: titles[randomIndex],
            message: messages[randomIndex],
            type: types[randomIndex],
            duration: 3.0,
        ))
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Storybook Thumbnail") {
        StorybookThumbnail()
            .frame(width: 1000, height: 562.5)
    }
#endif
