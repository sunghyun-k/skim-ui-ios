import SkimUI
import SwiftUI

// 각 화면은 시작과 끝 상태가 같다 (영상이 이음매 없이 반복되게). 손가락은 `DemosUITests`가 움직인다.

// MARK: - Toast

/// 버튼은 위, 토스트는 화면 아래. 무대는 버튼부터 화면 끝까지.
struct ToastDemo: View {
    @Environment(\.presentToast) private var presentToast
    @State private var offline: ToastValue?

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                HStack(spacing: Space.s) {
                    Button("Copy") {
                        presentToast(ToastValue(
                            title: "Copied to clipboard",
                            type: .success,
                            duration: 1.6,
                        ))
                    }
                    Button("Sync") {
                        presentToast(ToastValue(
                            title: "Storage almost full",
                            message: "Free up space to keep syncing.",
                            type: .warning,
                            // 닫기 버튼으로 위의 토스트를 닫은 뒤에도 한동안 남아 있게
                            duration: 6,
                        ))
                    }
                    Button("Go offline") {
                        presentToast(ToastValue(
                            title: "Connection lost",
                            message: "Retrying in a moment…",
                            type: .danger,
                            duration: nil,
                        ))
                    }
                }
                .buttonStyle(.secondary(.small))
                // 토스트 자리 (홈 인디케이터 위에 뜬다)
                Color.clear.frame(height: 150)
            }
            .stage()
        }
        .ignoresSafeArea(edges: .bottom)
        .centered()
    }
}

// MARK: - Slider

struct SliderDemo: View {
    @State private var limit = 3

    var body: some View {
        VStack(alignment: .leading, spacing: Space.l) {
            VStack(alignment: .leading, spacing: Space.xs) {
                Text("Daily limit").textRole(.footnote).foregroundStyle(Palette.ink3)
                ValueText("\(limit)", unit: "GB")
                    .animation(.roll, value: limit)
            }
            SteppedSlider(selection: $limit, steps: Array(1 ... 7)) { "\($0)GB" }
                .accessibilityIdentifier("slider")
        }
        .card()
        .stage()
        .centered()
    }
}

// MARK: - Segmented

struct SegmentedDemo: View {
    @State private var period = "Day"

    private var usage: (value: String, progress: Double) {
        switch period {
        case "Day": ("0.4", 0.12)
        case "Week": ("2.8", 0.46)
        default: ("9.6", 0.87)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.l) {
            SegmentedControl(selection: $period, options: ["Day", "Week", "Month"].map { ($0, $0) })
            VStack(alignment: .leading, spacing: Space.s) {
                ValueText(usage.value, unit: "GB")
                    .animation(.roll, value: period)
                LinearGauge(progress: usage.progress, fill: Palette.theme)
            }
        }
        .card()
        .stage()
        .centered()
    }
}

// MARK: - Expandable

struct ExpandableDemo: View {
    /// 한 번에 하나만 펼친다 (아코디언).
    @State private var open: Int?

    private let faq = [
        (
            "Why did the total change?",
            "Usage from the last 24 hours is still being counted by your carrier."
        ),
        (
            "Can I change the reset day?",
            "Open the plan and pick a new reset day. Past periods stay as they are."
        ),
        ("Is my data shared?", "No. Everything stays on this iPhone."),
    ]

    var body: some View {
        VStack {
            RowGroup("FAQ") {
                ForEach(faq.indices, id: \.self) { index in
                    ExpandableRow(faq[index].0, isExpanded: Binding(
                        get: { open == index },
                        set: { open = $0 ? index : nil },
                    )) {
                        Text(faq[index].1)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        // 펼쳐도 무대 크기가 그대로이게 (자르기 영역은 처음 한 번 잰다)
        .frame(height: 270, alignment: .top)
        .stage()
        .centered()
    }
}

// MARK: - Skeleton

struct SkeletonDemo: View {
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: Space.l) {
            // shimmer는 받은 자리를 다 채우므로, 실제 내용으로 자리를 잡고 그 위에 겹친다.
            storage
                .hidden()
                .overlay {
                    storage
                        .redacted(reason: isLoading ? .placeholder : [])
                        .skeleton(isLoading: isLoading)
                }
                .card()

            Button("Refresh") {
                Task {
                    isLoading = true
                    try? await Task.sleep(for: .seconds(1.8))
                    isLoading = false
                }
            }
            .buttonStyle(.secondary(.small))
        }
        .stage()
        .centered()
    }

    private var storage: some View {
        VStack(alignment: .leading, spacing: Space.l) {
            HStack(alignment: .firstTextBaseline) {
                Text("Storage").textRole(.headline).foregroundStyle(Palette.ink1)
                Spacer()
                ToneChip("Almost full", tone: .caution)
            }
            MeterRow(value: "1.4GB left", caption: "of 11GB", progress: 9.6 / 11)
            StatSplit([.init(label: "Used", value: "9.6GB"), .init(label: "Today", value: "0.2GB")])
        }
    }
}

// MARK: - Selection

struct SelectionDemo: View {
    @State private var plan = 0
    @State private var choice = 0
    @State private var widgets = true
    @State private var shortcuts = false

    var body: some View {
        VStack(alignment: .leading, spacing: Space.l) {
            HStack(spacing: 6) {
                SelectChip("Basic", detail: "5GB", isSelected: plan == 0) { plan = 0 }
                SelectChip("Plus", detail: "20GB", isSelected: plan == 1) { plan = 1 }
                SelectChip("Pro", detail: "50GB", isSelected: plan == 2) { plan = 2 }
            }
            VStack(spacing: Space.s) {
                ChoiceCard(
                    "Limited time",
                    message: "Discount for the first months",
                    isSelected: choice == 0,
                ) {
                    choice = 0
                }
                ChoiceCard(
                    "No discount",
                    message: "The price never changes",
                    isSelected: choice == 1,
                ) {
                    choice = 1
                }
            }
            HStack(spacing: Space.xl) {
                Toggle("Widgets", isOn: $widgets)
                Toggle("Shortcuts", isOn: $shortcuts)
            }
            .toggleStyle(.check)
            .textRole(.body)
            .foregroundStyle(Palette.ink1)
            .padding(.horizontal, Space.xs)
        }
        .stage()
        .centered()
    }
}

// MARK: - Tiles

struct TilesDemo: View {
    @State private var appearance = 0
    @State private var face = 1

    private let faces: [(Color, Color)] = [
        (Palette.theme, Palette.green),
        (Palette.blue, Palette.purple),
        (Palette.orange, Palette.red),
        (Palette.ink4, Palette.ink2),
    ]

    var body: some View {
        VStack(spacing: Space.l) {
            TilePicker(
                selection: $appearance,
                options: [0, 1, 2],
                label: { ["Light", "Dark", "Auto"][$0] },
            ) { index in
                appearanceThumbnail(index)
            }
            .card()
            TilePicker(
                selection: $face,
                options: [0, 1, 2, 3],
                shape: .circle,
                label: { ["Lime", "Ocean", "Sunset", "Mono"][$0] },
            ) { index in
                LinearGradient(
                    colors: [faces[index].0, faces[index].1],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing,
                )
            }
            .card()
        }
        .stage()
        .centered()
    }

    /// 작은 화면 그림: 바탕 + 카드 두 장.
    private func appearanceThumbnail(_ index: Int) -> some View {
        HStack(spacing: 0) {
            if index != 1 {
                mini(dark: false)
            }
            if index != 0 {
                mini(dark: true)
            }
        }
    }

    private func mini(dark: Bool) -> some View {
        let back = dark ? Color(light: 0x000000, dark: 0x000000) : Color(
            light: 0xF2F2F7,
            dark: 0xF2F2F7,
        )
        let card = dark ? Color(light: 0x1C1C1E, dark: 0x1C1C1E) : Color(
            light: 0xFFFFFF,
            dark: 0xFFFFFF,
        )
        return VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 4).fill(card).frame(height: 18)
            RoundedRectangle(cornerRadius: 4).fill(card).frame(height: 12)
            Spacer(minLength: 0)
        }
        .padding(6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(back)
    }
}
