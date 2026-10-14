<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/header-dark.png">
  <img alt="SkimUI — a tactile SwiftUI design system for utility apps" src="docs/header-light.png">
</picture>

# SkimUI

**A tactile SwiftUI design system for utility apps.** Quiet gray surfaces, one accent color,
and controls that respond the instant you touch them.

iOS 18+ · Swift 6.2 · Light & Dark · Liquid Glass on iOS 26 · MIT

## Built to be touched

Most of SkimUI is about how things *feel*, not just how they look.

- **Presses on touch-down — even inside scroll views.** SwiftUI's `isPressed` arrives late in a `ScrollView`.
  Every SkimUI button runs on `PressableButton`, a UIKit recognizer that shows the pressed state the moment
  a finger lands, hands off to the scroll view when you start scrolling, and stays pressed up to 30pt outside, like UIKit.
- **A stepped slider you can feel.** `SteppedSlider` stops only on real values with a haptic tick at each step;
  the knob stretches and the track presses in while you hold it. − / + buttons on both sides.
- **Numbers roll, gauges fill.** Values animate with `.numericText()` and gauges fill with a fast-start, soft-stop curve
  (`strongOut`) whenever they change.
- **Toasts you can flick away.** `.toasts($toasts)` stacks them, dismisses them on a timer or a swipe,
  and shows a compact capsule for one-liners.
- **Gestures that don't fight scrolling.** `HorizontalDragGesture` (segments) and `ScrubGesture` (long-press and drag
  across a chart) decide direction before the scroll view does, so vertical scrolling keeps working.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/sunghyun-k/skim-ui-swift", from: "1.1.0"),
]
```

## Quick start

Pick your accent color once at launch — in the app *and* in every extension — before any view is drawn.

```swift
import SkimUI

@main
struct MyApp: App {
    init() {
        AccentTheme.current = .blue // .lime (default), .blue, or your own
    }

    var body: some Scene {
        WindowGroup { UsageScreen() }
    }
}

struct UsageScreen: View {
    @State private var limit = 5
    @State private var toasts: [ToastValue] = []

    var body: some View {
        ScrollView {
            VStack(spacing: Space.l) {
                VStack(alignment: .leading, spacing: Space.l) {
                    ValueText("42", unit: "GB")
                    MeterRow(value: "1.4GB left", caption: "of 11GB", progress: 9.6 / 11)
                }
                .card()

                SteppedSlider(selection: $limit, steps: Array(1 ... 7)) { "\($0)GB" }
                    .card()
            }
            .padding(.horizontal, Space.gutter)
        }
        .screenBackground()
        .bottomBar {
            Button("Save") {
                toasts.append(ToastValue(title: "Saved", type: .success))
            }
            .buttonStyle(.floating)
            .padding(.horizontal, Space.gutter)
        }
        .toasts($toasts)
    }
}
```

Every component lives in `Storybook()` — show it from a debug screen or open its `#Preview` to try them all.

## Principles

1. **Neutral by default.** Surfaces, text and lines are steps of gray. Color is for state (caution, alert) and the theme
   (primary button, selection, gauge fill).
2. **Values read at a glance.** A large value with a small unit and one line of context. Digits are monospaced so they don't jitter.
3. **Flat surfaces.** Cards differ from the background by lightness only — no borders, blur or noise.
   Only floating things (a selected pill, a knob, a toast) cast a shallow shadow.
4. **Fast start, soft stop.** One motion curve (`strongOut`) for everything that moves.
5. **System chrome stays.** Tab bars, navigation bars, sheets, menus, alerts and `Form` controls are stock iOS
   (Liquid Glass on iOS 26). SkimUI restyles the surfaces, text and icons inside them.

In screen code, use `Palette` and `.textRole(_:)` instead of system colors (`Color.red`, `.secondary`).
Prefer `Icon` over SF Symbols, and reach for a symbol only when `Icon` has no fitting shape.

## Components

| | |
|---|---|
| Surfaces | `.screenBackground()`, `.card()`, `CardBackground`, `.formSection()`, `.bottomBar { }`, `Hairline` |
| Text & numbers | `ValueText`, `SectionTitle`, `StatSplit`, `MeterRow`, `LinearGauge` |
| Rows | `RowGroup`, `ActionRow`, `LabeledRow`, `Disclosure`, `Notice` |
| Buttons | `.primary`, `.secondary`, `.ink`, `.destructive`, `.floating` / `.floatingInk` (Liquid Glass), `.quiet`, `.pressable`, `.pressableRow`, `.pressableCard`, `CircleIconButtonStyle`, `.busyLabel(_:)` |
| Controls | `SegmentedControl`, `SteppedSlider`, `StepProgress`, `.switchTint()`, `.toggleStyle(.check)` |
| Selection | `SelectChip`, `ChipScroller`, `ChoiceCard`, `TilePicker`, `OptionRow`, `RadioDot`, `CheckBox`, `SheetHeader` |
| Form | `Field`, `FieldHeader`, `.textFieldStyle(.field(...))`, `FieldBox`, `FieldSlider`, `RevealButton`, `QuestionHeader`, `.dismissesKeyboardOnTap()` |
| Feedback | `ToneChip`, `Banner`, `EmptyState`, `.toasts($toasts)`, `.skeleton(isLoading:)` |
| Gestures | `PressableButton`, `HorizontalDragGesture`, `ScrubGesture` |

### Toasts

```swift
@State private var toasts: [ToastValue] = []

content.toasts($toasts) // top by default; `alignment: .bottom` for the bottom edge

toasts.append(ToastValue(title: "Copied to clipboard", type: .success))
toasts.append(ToastValue(title: "Storage almost full", message: "Free up space to keep syncing.", type: .warning))
toasts.append(ToastValue(title: "Connection lost", type: .danger, duration: nil)) // stays until closed
```

`type` picks the badge color (`.default`, `.success`, `.warning`, `.danger`) and `icon:` swaps the glyph inside it.
A title-only toast is a compact capsule; a message or close button makes it a card. The close button appears by default
only on toasts that don't dismiss themselves (`duration: nil`).

Toasts follow the safe area of the view you attach them to — no manual insets. Attach `.toasts` inside a `TabView` or
`NavigationStack` and they clear the tab bar, navigation bar and toolbars automatically. A sheet gets its own `.toasts`.

## Tokens

| Token | |
|---|---|
| `Palette` | `void` (screen), `surface` (card), `raised` (floating), `ink1`–`ink4` (text), `hair`, `wash`, `fill1` / `fill3`, `plate`, state colors (`red`, `yellow` / `cautionInk`, `orange` / `orangeInk`), spare hues, and the theme (`theme`, `themeLine`, `themeWash`, `onTheme`) |
| `AccentTheme` | The one thing that differs per app |
| `TextRole` | `.textRole(.hero)` … `.caption` — SF Pro, Dynamic Type, tight tracking, monospaced digits |
| `Space`, `Radius` | 4pt grid; continuous corners (`card` 26, `inner` 15, `track` 12.5, `control` 9) |
| `Animation` | `.strongOut`, `.fill`, `.press`, `.roll`, `.soft` |
| `Icon`, `IconView` | Hand-drawn 24pt template icons |
| `Tone` | `neutral` · `calm` · `caution` · `alert` → `color`, `fillColor`, `isColored` |

Yellow, lime, mint, aqua and cyan are too light for text on white — use them for graphics only.

### Your own theme and colors

```swift
extension AccentTheme {
    static let coral = AccentTheme(
        fill: Color(light: 0xFF6B5B, dark: 0xFF7A6B),
        line: Color(light: 0xD94436, dark: 0xFF7A6B),
        onFill: Color(light: 0xFFFFFF, dark: 0x000000),
    )
}

extension Palette {
    static let brand = Color(light: 0x123456, dark: 0x6789AB)
}
```

## Icons

Bold filled shapes on a 24pt grid with inner details cut out; line icons (arrows, check, chevrons) are 2.4–2.6pt
with round caps and joins. Add your app's own icons to its asset catalog, drawn with the same rules:

```swift
extension Icon {
    static let sim = Icon("sim", bundle: .module)
}

IconView(.sim, size: 20)
Label("Lines", icon: .sim) // tab bars, menus and toolbars keep their system look
```

## Development

- **Build:** iOS only — `xcodebuild build -scheme skim-ui-swift -destination 'generic/platform=iOS Simulator'`.
- **Icons:** the SVG source is `Tools/icons.py`. Edit it, run `python3 Tools/icons.py`, and add a static member to `Icon`.
- **Header image:** `Tools/HeaderMaker.swiftpm` draws it from real components. Run `Tools/make-header.sh` to rebuild
  `docs/header-light.png` and `docs/header-dark.png` on a simulator.

## License

MIT. See [LICENSE](LICENSE).
