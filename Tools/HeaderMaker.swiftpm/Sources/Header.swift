import SkimUI
import SwiftUI

/// README 헤더: 기울어진 컴포넌트 벽 + 왼쪽 타이틀.
struct HeaderView: View {
    static let size = CGSize(width: 1280, height: 640)

    var body: some View {
        ZStack(alignment: .leading) {
            Palette.void

            wall
                .rotationEffect(.degrees(-16))
                .scaleEffect(0.9)
                .offset(x: 360, y: 70)

            // 타이틀 쪽은 바탕색으로 덮어 읽히게
            LinearGradient(
                stops: [
                    .init(color: Palette.void, location: 0),
                    .init(color: Palette.void, location: 0.34),
                    .init(color: Palette.void.opacity(0), location: 0.47),
                ],
                startPoint: .leading,
                endPoint: .trailing,
            )

            VStack(alignment: .leading, spacing: 14) {
                Text("SkimUI")
                    .font(.system(size: 72, weight: .bold))
                    .tracking(-2)
                    .foregroundStyle(Palette.ink1)
                Text("A tactile SwiftUI design system\nfor utility apps")
                    .font(.system(size: 30, weight: .semibold))
                    .tracking(-0.5)
                    .foregroundStyle(Palette.ink2)
                    .lineSpacing(2)
                HStack(spacing: 8) {
                    ToneChip("iOS 18+", tone: .neutral)
                    ToneChip("Interactive", tone: .neutral)
                    ToneChip("Light & Dark", tone: .neutral)
                }
                .padding(.top, 10)
            }
            .padding(.leading, 84)
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .clipped()
    }

    private var wall: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(spacing: 18) {
                storage
                chips
                choice
                toasts
            }
            .frame(width: 360)
            .offset(y: 60)
            VStack(spacing: 18) {
                segmented
                rows
                slider
                emptyState
                buttons
            }
            .frame(width: 360)
            .offset(y: -220)
            VStack(spacing: 18) {
                icons
                bigValue
                choiceAlt
                gauge
            }
            .frame(width: 360)
            .offset(y: 20)
        }
    }

    // MARK: 타일

    private var storage: some View {
        VStack(alignment: .leading, spacing: Space.l) {
            HStack(alignment: .firstTextBaseline) {
                Text("Storage").textRole(.headline).foregroundStyle(Palette.ink1)
                Spacer()
                ToneChip("Almost full", tone: .caution)
            }
            // 이미지로 찍으면 차오르기 전(0)이 담겨서, 막대는 애니메이션 없이 따로 그린다.
            VStack(alignment: .leading, spacing: Space.s) {
                MeterRow(value: "1.4GB left", caption: "of 11GB")
                LinearGauge(progress: 9.6 / 11, fill: Palette.theme, animated: false)
            }
            StatSplit([.init(label: "Used", value: "9.6GB"), .init(label: "Today", value: "0.2GB")])
        }
        .card(padding: Space.l)
    }

    private var bigValue: some View {
        VStack(alignment: .leading, spacing: Space.s) {
            Text("This month").textRole(.footnote).foregroundStyle(Palette.ink3)
            ValueText("42", unit: "GB")
            LinearGauge(progress: 0.62, baseline: 0.5, fill: Palette.theme, animated: false)
        }
        .card(padding: Space.l)
    }

    private var chips: some View {
        HStack(spacing: 6) {
            SelectChip("Basic", detail: "5GB", isSelected: false) {}
            SelectChip("Plus", detail: "20GB", isSelected: false) {}
            SelectChip("Pro", detail: "50GB", isSelected: true) {}
            Spacer(minLength: 0)
        }
    }

    private var choice: some View {
        VStack(spacing: Space.s) {
            ChoiceCard(
                "Limited time",
                message: "Discount for the first months",
                isSelected: true,
            ) {}
            ChoiceCard("No discount", message: "The price never changes", isSelected: false) {}
        }
    }

    private var choiceAlt: some View {
        VStack(alignment: .leading, spacing: Space.m) {
            HStack(spacing: Space.m) { CheckBox(isOn: true)
                Text("Widgets").textRole(.body).foregroundStyle(Palette.ink1)
            }
            HStack(spacing: Space.m) { CheckBox(isOn: true)
                Text("Shortcuts").textRole(.body).foregroundStyle(Palette.ink1)
            }
            HStack(spacing: Space.m) { CheckBox(isOn: false)
                Text("Siri").textRole(.body).foregroundStyle(Palette.ink1)
            }
        }
        .card(padding: Space.l)
    }

    private var segmented: some View {
        SegmentedControl(
            selection: .constant("Week"),
            options: ["Day", "Week", "Month"].map { ($0, $0) },
        )
        .card(padding: Space.m)
    }

    private var slider: some View {
        VStack(alignment: .leading, spacing: Space.m) {
            Text("Daily limit").textRole(.headline).foregroundStyle(Palette.ink1)
            SteppedSlider(selection: .constant(4), steps: Array(1 ... 7)) { "\($0)GB" }
        }
        .card(padding: Space.l)
    }

    private var rows: some View {
        RowGroup("Settings") {
            ActionRow("History") { Disclosure() }
            ActionRow("Version") { Text("1.0.0") }
            ActionRow("Delete all data", isDestructive: true)
        }
    }

    private var emptyState: some View {
        EmptyState(
            icon: .sparkle,
            title: "Nothing here yet",
            message: "Items you add show up here.",
        ) {
            Button("Add item") {}.buttonStyle(.primary(.regular))
        }
        .card()
    }

    private var buttons: some View {
        VStack(spacing: Space.m) {
            Button("Continue") {}.buttonStyle(.primary)
            HStack {
                Button("Cancel") {}.buttonStyle(.secondary)
                Button("Save") {}.buttonStyle(.ink)
            }
        }
    }

    private var icons: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: Space.m), count: 5),
            spacing: Space.m,
        ) {
            ForEach(Icon.builtIn.prefix(15), id: \.self) { icon in
                IconView(icon, size: 20)
                    .foregroundStyle(Palette.ink1)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Palette.fill3))
            }
        }
        .card(padding: Space.l)
    }

    private var gauge: some View {
        HStack(spacing: Space.s) {
            ToneChip("neutral", tone: .neutral)
            ToneChip("calm", tone: .calm)
            ToneChip("caution", tone: .caution)
            ToneChip("alert", tone: .alert)
        }
    }

    private var toasts: some View {
        VStack(spacing: Space.m) {
            toast("Copied to clipboard", icon: .check, fill: Palette.theme, ink: Palette.onTheme)
            toast("Connection lost", icon: .close, fill: Palette.red, ink: .white)
        }
    }

    private func toast(_ title: String, icon: Icon, fill: Color, ink: Color) -> some View {
        HStack(spacing: 10) {
            IconView(icon, size: 16).foregroundStyle(ink)
                .frame(width: 30, height: 30)
                .background(Circle().fill(fill))
            Text(title).textRole(.headline).foregroundStyle(Palette.ink1)
        }
        .padding(.leading, Space.s).padding(.trailing, 18).padding(.vertical, Space.s)
        .background(Palette.raised, in: .capsule)
        .shadow(color: Palette.popShadow.opacity(0.8), radius: 14, y: 4)
    }
}

/// 앱 Documents에 PNG를 쓴다. `Tools/make-header.sh`가 꺼내서 `docs/`로 옮긴다.
@MainActor
enum HeaderExport {
    static func run() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for (name, scheme) in [("header-light", ColorScheme.light), ("header-dark", .dark)] {
            let renderer = ImageRenderer(content: HeaderView().environment(\.colorScheme, scheme))
            renderer.scale = 2
            renderer.proposedSize = .init(HeaderView.size)
            if let data = renderer.uiImage?.pngData() {
                try? data.write(to: docs.appending(path: "\(name).png"), options: .atomic)
            }
        }
    }
}
