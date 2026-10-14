import SwiftUI

/// 컴포넌트 갤러리. 전부 만져 볼 수 있다. 앱의 디버그 화면에 띄우거나 #Preview로 본다.
/// 토스트는 앱 뿌리의 `installToasts()`로 뜬다.
public struct Storybook: View {
    public init() {}

    @State private var segment = "Day"
    @State private var level = 3
    @State private var limit: Double? = 5
    @State private var query = ""
    @State private var amount = ""
    @State private var filter = "All"
    @State private var plan: Int? = 0
    @State private var choice = 0
    @State private var option: String? = "a"
    @State private var step = 1
    @State private var isOn = true
    @State private var checked = true
    @State private var floatingEnabled = true
    @Environment(\.presentToast) private var presentToast
    @State private var isLoading = true
    @State private var tile = 2
    @State private var isCovering = false

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.xxxl) {
                    group("Typography") { typography }
                    group("Palette") { palette }
                    group("Icons") { icons }
                    group("Cards & readouts") { readouts }
                    group("Rows") { rows }
                    group("Controls") { controls }
                    group("Selection") { selection }
                    group("Form") { form }
                    group("Feedback") { feedback }
                    group("Buttons") { buttons }
                }
                .padding(.horizontal, Space.gutter)
                .padding(.vertical, Space.xl)
            }
            .screenBackground()
            .bottomBar {
                Button("Continue") {}
                    .buttonStyle(.floating)
                    .disabled(!floatingEnabled)
                    .padding(.horizontal, Space.gutter)
                    .padding(.bottom, Space.s)
            }
            .navigationTitle("SkimUI")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(Palette.ink1)
    }

    private func group(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Space.m) {
            SectionTitle(title)
            content()
        }
    }

    private var typography: some View {
        VStack(alignment: .leading, spacing: Space.s) {
            ValueText("42", unit: "GB")
            Text("Large title").textRole(.largeTitle)
            Text("Page title").textRole(.pageTitle)
            Text("Title").textRole(.title)
            Text("Headline").textRole(.headline)
            Text("Body text reads like this.").textRole(.body)
            Text("Callout").textRole(.callout).foregroundStyle(Palette.ink2)
            Text("Footnote").textRole(.footnote).foregroundStyle(Palette.ink3)
            Text("Caption").textRole(.caption).foregroundStyle(Palette.ink4)
        }
        .foregroundStyle(Palette.ink1)
        .card()
    }

    private var palette: some View {
        let swatches: [(String, Color)] = [
            ("ink1", Palette.ink1),
            ("ink2", Palette.ink2),
            ("ink3", Palette.ink3),
            (
                "ink4",
                Palette.ink4
            ),
            ("theme", Palette.theme),
            ("themeLine", Palette.themeLine),
            ("red", Palette.red),
            (
                "orange",
                Palette.orange
            ),
            ("yellow", Palette.yellow),
            ("green", Palette.green),
            ("blue", Palette.blue),
            (
                "purple",
                Palette.purple
            ),
        ]
        return LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 72), spacing: Space.s)],
            spacing: Space.s,
        ) {
            ForEach(swatches, id: \.0) { name, color in
                VStack(spacing: Space.xs) {
                    RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                        .fill(color)
                        .frame(height: 40)
                        .insetRing(
                            RoundedRectangle(cornerRadius: Radius.control, style: .continuous),
                            0.1,
                        )
                    Text(name).textRole(.caption).foregroundStyle(Palette.ink3)
                }
            }
        }
        .card(padding: Space.l)
    }

    private var icons: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: Space.m)], spacing: Space.m) {
            ForEach(Icon.builtIn, id: \.self) { icon in
                IconView(icon, size: 22)
                    .foregroundStyle(Palette.ink1)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Palette.fill3))
            }
        }
        .card(padding: Space.l)
    }

    private var readouts: some View {
        VStack(spacing: Space.m) {
            VStack(alignment: .leading, spacing: Space.l) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Storage").textRole(.headline).foregroundStyle(Palette.ink1)
                    Spacer()
                    ToneChip("Almost full", tone: .caution)
                }
                MeterRow(value: "5.2GB left", caption: "of 11GB", progress: 5.8 / 11)
                StatSplit([
                    .init(label: "Used", value: "5.8GB"),
                    .init(label: "Today", value: "0.2GB"),
                ])
            }
            .card(padding: Space.l)
            HStack(spacing: Space.s) {
                ForEach(Tone.allCases, id: \.self) { tone in
                    ToneChip("\(tone)", tone: tone)
                }
            }
            LinearGauge(progress: 0.62, baseline: 0.5, fill: Palette.theme)
        }
    }

    private var rows: some View {
        VStack(spacing: Space.l) {
            RowGroup("Settings") {
                ActionRow("Notifications", subtitle: "Daily summary at 9 AM") {
                    Toggle("", isOn: $isOn).labelsHidden().switchTint()
                }
                Button {} label: {
                    ActionRow("History") { Disclosure() }
                }
                .buttonStyle(.pressableRow)
                ActionRow("Version") { Text("1.0.0") }
                ActionRow("Delete all data", isDestructive: true)
            }
            RowGroup {
                LabeledRow("Plan", value: "Monthly", actionTitle: "Edit") {}
                LabeledRow("Renews", value: "Dec 31, 2026", note: "In 78 days")
                LabeledRow("Note", value: "Not set", isMuted: true)
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            SegmentedControl(
                selection: $segment,
                options: ["Day", "Week", "Month"].map { ($0, $0) },
            )
            SteppedSlider(selection: $level, steps: Array(1 ... 7)) { "\($0)" }
            StepProgress(count: 5, current: step) { step = $0 }
            HStack {
                Button("Back") { step = max(step - 1, 0) }.buttonStyle(.secondary)
                Button("Next") { step = min(step + 1, 4) }.buttonStyle(.secondary)
            }
        }
        .card()
    }

    private var selection: some View {
        VStack(alignment: .leading, spacing: Space.l) {
            ChipScroller {
                ForEach(["All", "Favorites", "Recent", "Shared", "Archived"], id: \.self) { item in
                    SelectChip(item, isSelected: filter == item) { filter = item }
                }
            }
            HStack(spacing: 6) {
                SelectChip("Basic", detail: "5GB", isSelected: plan == 0) { plan = 0 }
                SelectChip("Plus", detail: "20GB", isSelected: plan == 1) { plan = 1 }
                SelectChip("3 mo", isSelected: plan == 2, shape: .square) { plan = 2 }
            }
            VStack(spacing: Space.s) {
                ChoiceCard(
                    "Limited time",
                    message: "Discount for the first months",
                    isSelected: choice == 0,
                ) { choice = 0 }
                ChoiceCard(
                    "No discount",
                    message: "The price never changes",
                    isSelected: choice == 1,
                ) { choice = 1 }
            }
            VStack(alignment: .leading, spacing: Space.s) {
                SheetHeader("Pick one", message: "Shown in a sheet")
                OptionRow("First option", isSelected: option == "a") { option = "a" }
                OptionRow("Second option", note: "With a note", isSelected: option == "b") {
                    option = "b"
                }
                OptionRow("None", isSelected: option == nil, isMuted: true) { option = nil }
            }
            .padding(.vertical, Space.l)
            .padding(.horizontal, Space.s)
            .background(CardBackground())
            TilePicker(
                selection: $tile,
                options: [0, 1, 2],
                label: { ["Light", "Dark", "Auto"][$0] },
            ) { index in
                HStack(spacing: 0) {
                    if index != 1 {
                        Color(light: 0xFFFFFF, dark: 0xFFFFFF)
                    }
                    if index != 0 {
                        Color(light: 0x1C1C1E, dark: 0x1C1C1E)
                    }
                }
            }
            .card()
            HStack(spacing: Space.xl) {
                Toggle("Checkbox", isOn: $checked).toggleStyle(.check)
                RadioDot(isSelected: checked)
            }
        }
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            QuestionHeader("What should we call it?", message: "You can change it later.")
            Field("Search", help: "Name or keyword") {
                TextField("Type to search", text: $query).textFieldStyle(.field(icon: .search))
            }
            Field("Amount", isOptional: true) {
                TextField("0", text: $amount)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.field(unit: "USD", large: true))
            }
            FieldSlider("Limit", selection: $limit, steps: [1, 3, 5, 10, 20]) {
                "\($0.formatted())GB"
            }
            RevealButton("Show more options") {}
        }
        .dismissesKeyboardOnTap()
    }

    private var feedback: some View {
        VStack(alignment: .leading, spacing: Space.m) {
            HStack(spacing: Space.s) {
                Button("Toast") {
                    presentToast(ToastValue(title: "Copied to clipboard", type: .success))
                }
                .buttonStyle(.secondary(.small))
                // 토스트가 떠 있는 동안 상태 표시줄을 숨긴 커버가 열렸다 닫혀도 상태 표시줄이 따라가는지.
                Button("Toast over a cover") {
                    presentToast(ToastValue(
                        title: "Status bar follows the app",
                        message: "A cover hides it and closes in a second.",
                        duration: 5,
                    ))
                    isCovering = true
                }
                .buttonStyle(.secondary(.small))
            }
            .fullScreenCover(isPresented: $isCovering) {
                Text("Status bar hidden")
                    .textRole(.title)
                    .foregroundStyle(Palette.ink1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .screenBackground()
                    .statusBarHidden()
                    .task {
                        try? await Task.sleep(for: .seconds(1.5))
                        isCovering = false
                    }
            }
            Banner(icon: .warning, text: "Sync failed. Try again later.", tone: .caution)
            Banner(icon: .info, text: "Everything is up to date.")
            Banner(
                icon: .calendar,
                title: "Calendar access needed",
                text: "Allow access to show your events in widgets.",
                actionTitle: "Allow",
                action: {},
                onDismiss: {},
            )
            Notice("Connect an account to see more.", actionTitle: "Connect") {}
            HStack {
                Text("Loading placeholder").textRole(.body)
                Spacer()
                Toggle("", isOn: $isLoading).labelsHidden().switchTint()
            }
            .skeleton(isLoading: isLoading)
            EmptyState(
                icon: .sparkle,
                title: "Nothing here yet",
                message: "Items you add will show up here.",
            ) {
                Button("Add item") {
                    presentToast(ToastValue(
                        title: "Added",
                        message: "The item was added.",
                        type: .success,
                    ))
                }
                .buttonStyle(.primary(.regular))
            }
            .card()
        }
    }

    private var buttons: some View {
        VStack(spacing: Space.m) {
            Button("Primary") {}.buttonStyle(.primary)
            Button("Disabled") {}.buttonStyle(.primary).disabled(true)
            Button("Ink") {}.buttonStyle(.ink)
            Button("Delete") {}.buttonStyle(.destructive)
            HStack {
                Button("Cancel") {}.buttonStyle(.secondary)
                Button("Save") {}.buttonStyle(.primary(.regular))
                Button {} label: { IconView(.plus, size: 18) }.buttonStyle(CircleIconButtonStyle())
            }
            Button("Quiet") {}.buttonStyle(.quiet)
            Toggle("Floating button enabled", isOn: $floatingEnabled)
                .textRole(.body)
                .foregroundStyle(Palette.ink1)
                .switchTint()
        }
    }
}

#Preview("Dark") {
    Storybook()
        .installToasts()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    Storybook()
        .installToasts()
        .preferredColorScheme(.light)
}
