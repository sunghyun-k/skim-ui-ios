import SwiftUI

/// 그림 타일의 모양.
public enum TileShape: Sendable, Equatable {
    /// 둥근 사각. `aspect`는 너비 ÷ 높이.
    case rounded(aspect: CGFloat = 4.0 / 3.0)
    /// 원 (색·문자판처럼 둥근 것).
    case circle
}

/// 그림으로 고르는 피커 (시계 앱 "외관"·"문자판"처럼).
/// 그림이 곧 타일이다 — 꽉 채운 미리보기에 얇은 테두리, 고른 타일은 틈을 두고 같은 모양의 잉크 링이 감싼다.
/// 이름은 아래에, 고른 것만 진하게. 색은 그림이 내고 링은 선택만 알린다.
///
/// `tileWidth`를 주지 않으면 옵션이 한 줄을 나눠 갖고, 주면 그 너비로 가로 스크롤된다 (옵션이 많을 때).
public struct TilePicker<Value: Hashable, Thumbnail: View>: View {
    @Binding var selection: Value
    let options: [Value]
    let shape: TileShape
    let tileWidth: CGFloat?
    let label: (Value) -> String
    let detail: ((Value) -> String)?
    let thumbnail: (Value) -> Thumbnail

    public init(
        selection: Binding<Value>,
        options: [Value],
        shape: TileShape = .rounded(),
        tileWidth: CGFloat? = nil,
        label: @escaping (Value) -> String,
        detail: ((Value) -> String)? = nil,
        @ViewBuilder thumbnail: @escaping (Value) -> Thumbnail,
    ) {
        _selection = selection
        self.options = options
        self.shape = shape
        self.tileWidth = tileWidth
        self.label = label
        self.detail = detail
        self.thumbnail = thumbnail
    }

    public init(
        selection: Binding<Value>,
        options: [Value],
        shape: TileShape = .rounded(),
        tileWidth: CGFloat? = nil,
        label: @escaping (Value) -> LocalizedStringResource,
        detail: ((Value) -> LocalizedStringResource)? = nil,
        @ViewBuilder thumbnail: @escaping (Value) -> Thumbnail,
    ) {
        self.init(
            selection: selection,
            options: options,
            shape: shape,
            tileWidth: tileWidth,
            label: { String(localized: label($0)) },
            detail: detail.map { detail in { String(localized: detail($0)) } },
            thumbnail: thumbnail,
        )
    }

    public var body: some View {
        if tileWidth != nil {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    row
                }
                .onAppear { proxy.scrollTo(selection, anchor: .center) }
            }
        } else {
            row
        }
    }

    private var row: some View {
        HStack(alignment: .top, spacing: Space.s) {
            ForEach(options, id: \.self) { option in
                TileButton(
                    isSelected: option == selection,
                    shape: shape,
                    width: tileWidth,
                    label: label(option),
                    detail: detail?(option),
                    thumbnail: thumbnail(option),
                ) {
                    withAnimation(.strongOut) { selection = option }
                }
                .id(option)
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}

private struct TileButton<Thumbnail: View>: View {
    let isSelected: Bool
    let shape: TileShape
    let width: CGFloat?
    let label: String
    let detail: String?
    let thumbnail: Thumbnail
    let action: () -> Void

    /// 그림과 링 사이 틈, 링 두께.
    private static var gap: CGFloat {
        4
    }

    private static var ring: CGFloat {
        3
    }

    private static var inset: CGFloat {
        gap + ring
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: Space.s) {
                tile
                VStack(spacing: 0) {
                    Text(label)
                        .textRole(.callout)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundStyle(isSelected ? Palette.ink1 : Palette.ink3)
                        .lineLimit(1)
                    if let detail {
                        Text(detail)
                            .textRole(.caption)
                            .foregroundStyle(Palette.ink4)
                            .lineLimit(1)
                    }
                }
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: width == nil ? .infinity : nil)
            .frame(width: width)
        }
        .buttonStyle(.pressable)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text([label, detail].compactMap(\.self).joined(separator: ", ")))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    @ViewBuilder private var tile: some View {
        switch shape {
        case .rounded(let aspect):
            let radius = Radius.inner
            let inner = RoundedRectangle(cornerRadius: radius, style: .continuous)
            let outer = RoundedRectangle(cornerRadius: radius + Self.inset, style: .continuous)
            framed(inner, outer: outer, aspect: aspect)
        case .circle:
            framed(Circle(), outer: Circle(), aspect: 1)
        }
    }

    private func framed(
        _ inner: some InsettableShape,
        outer: some InsettableShape,
        aspect: CGFloat,
    ) -> some View {
        Color.clear
            .aspectRatio(aspect, contentMode: .fit)
            .overlay { thumbnail }
            .background(Palette.wash)
            .clipShape(inner)
            // 그림이 바탕과 같은 색이어도 경계가 보이게
            .overlay { inner.strokeBorder(Palette.fill(0.08), lineWidth: 1) }
            .shadow(color: Palette.popShadow.opacity(0.35), radius: 2, y: 1)
            .padding(Self.inset)
            .overlay {
                outer.strokeBorder(Palette.ink1, lineWidth: Self.ring)
                    .opacity(isSelected ? 1 : 0)
                    .scaleEffect(isSelected ? 1 : 1.04)
            }
    }
}

#if DEBUG
    #Preview("Tile Picker") {
        TilePickerPreview()
    }

    private struct TilePickerPreview: View {
        enum Mode: String, CaseIterable { case light = "Light", dark = "Dark", auto = "Auto" }

        @State private var mode = Mode.auto
        @State private var hue = 2
        private let hues: [Color] = [
            .init(light: 0xFFFFFF, dark: 0xFFFFFF),
            Palette.theme,
            Palette.blue,
            Palette.orange,
            Palette.red,
            .init(light: 0x1C1C1E, dark: 0x1C1C1E),
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: Space.l) {
                SectionTitle("Appearance")
                TilePicker(selection: $mode, options: Mode.allCases, label: \.rawValue) { mode in
                    switch mode {
                    case .light: Color(light: 0xFFFFFF, dark: 0xFFFFFF)
                    case .dark: Color(light: 0x1C1C1E, dark: 0x1C1C1E)
                    case .auto:
                        HStack(spacing: 0) {
                            Color(light: 0xFFFFFF, dark: 0xFFFFFF)
                            Color(light: 0x1C1C1E, dark: 0x1C1C1E)
                        }
                    }
                }
                SectionTitle("Color")
                TilePicker(
                    selection: $hue,
                    options: Array(hues.indices),
                    shape: .circle,
                    tileWidth: 72,
                    label: { "Color \($0 + 1)" },
                ) { hues[$0] }
            }
            .card()
            .padding(Space.gutter)
            .frame(maxHeight: .infinity)
            .screenBackground()
        }
    }
#endif
