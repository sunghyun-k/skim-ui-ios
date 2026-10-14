import SwiftUI
import UIKit

/// 색 토큰. 면·글자는 iOS 시스템 회색 체계(그룹 바탕 + 카드), 색은 iOS 위젯 시안에서 뽑은 화사한 색.
/// 라이트 색은 같은 색상(hue)에서 명도만 내려, 흰 바탕 대비를 같은 계열 iOS 라이트 시스템 색에 맞췄다
/// (노랑 1.5:1 ~ 보라 4.2:1 — 그래픽용). 노랑·라임·민트·아쿠아·시안은 라이트에서 글자로 쓰지 않는다.
/// 화면에서 `Color.red` 같은 시스템 색을 직접 쓰지 않는다 — 전부 여기서. 앱 고유 색은 `extension Palette`에 같은 방식으로 더한다.
public nonisolated enum Palette {
    // MARK: 면 (surface)

    /// 화면 바탕 (`systemGroupedBackground`).
    public static let void = Color(light: 0xF2F2F7, dark: 0x000000)
    /// 카드 (`secondarySystemGroupedBackground`). 다크에서도 바탕보다 밝게 뜬다.
    public static let surface = Color(light: 0xFFFFFF, dark: 0x1C1C1E)
    /// 화면 위에 떠 있는 면 (토스트). 다크에서는 카드 위에서도 뜨도록 한 단계 더 밝다.
    public static let raised = Color(light: 0xFFFFFF, dark: 0x2C2C2E)

    // MARK: 글자 (ink) — 1이 가장 진하다

    public static let ink1 = Color(light: 0x000000, dark: 0xFFFFFF)
    public static let ink2 = Color(light: 0x3A3A3C, dark: 0xE5E5EA)
    public static let ink3 = Color(light: 0x6C6C70, dark: 0xAEAEB2)
    /// `secondaryLabel`을 불투명하게.
    public static let ink4 = Color(light: 0x8A8A8E, dark: 0x8D8D93)
    /// `ink1`로 채운 버튼 위 글자.
    public static let onInk = Color(light: 0xFFFFFF, dark: 0x000000)

    // MARK: 선·채움

    /// 1pt 선.
    public static let hair = Color(light: 0x000000, lightAlpha: 0.1, dark: 0xFFFFFF, darkAlpha: 0.1)
    /// 옅은 채움 — 게이지 트랙, 오목한 곳.
    public static let wash = Color(
        light: 0x000000,
        lightAlpha: 0.045,
        dark: 0xFFFFFF,
        darkAlpha: 0.06,
    )

    /// 컨트롤 면 — iOS `systemFill` 계열 (회색 반투명). 검정 바탕에서도 카드 면만큼 떠 보이고,
    /// 카드 위에서는 한 단계 더 밝다. 입력칸·선택 카드·칩·보조 버튼·원형 버튼·트랙은 이걸로.
    /// 1 = `systemFill` (진행 막대의 빈 칸), 3 = `tertiarySystemFill` (기본).
    public static let fill1 = Color(
        light: 0x787880,
        lightAlpha: 0.20,
        dark: 0x787880,
        darkAlpha: 0.36,
    )
    public static let fill3 = Color(
        light: 0x767680,
        lightAlpha: 0.12,
        dark: 0x767680,
        darkAlpha: 0.24,
    )

    /// 흰 N% 채움 — 점·눈금·테두리처럼 면이 아닌 작은 것에.
    /// 라이트에서는 검정으로 뒤집는다. 흰 바탕 위 검정은 같은 비율이면 더 진해 보여서 0.7배.
    public static func fill(_ opacity: Double) -> Color {
        Color(light: 0x000000, lightAlpha: opacity * 0.7, dark: 0xFFFFFF, darkAlpha: opacity)
    }

    /// 선택된 세그먼트 알약 (iOS 세그먼트처럼 라이트는 흰 판 + 그림자, 다크는 회색 판).
    public static let tabPill = Color(light: 0xFFFFFF, dark: 0x636366)
    /// 떠 있는 것의 그림자.
    public static let popShadow = Color(
        light: 0x000000,
        lightAlpha: 0.14,
        dark: 0x000000,
        darkAlpha: 0.45,
    )
    /// 채운 캡슐 버튼(주·잉크)의 그림자. 라이트는 흰 카드 위에서 진해 보여 옅게, 다크는 `popShadow`와 같다.
    public static let buttonShadow = Color(
        light: 0x000000,
        lightAlpha: 0.04,
        dark: 0x000000,
        darkAlpha: 0.45,
    )

    // MARK: 색 — 다크는 시안 그대로, 라이트는 같은 색상에서 명도를 내렸다

    /// 경고.
    public static let red = Color(light: 0xFE374B, dark: 0xFB4150)
    /// 다 쓴 뒤 속도 제한으로 계속 쓰는 중 (게이지·막대). 라이트에서 글자로는 `orangeInk`.
    public static let orange = Color(light: 0xFA7C0B, dark: 0xFA7C0B)
    /// 주황 글자. 라이트 주황은 흰 바탕에서 흐려서(2.9:1) 진하게 (5.2:1).
    public static let orangeInk = Color(light: 0xC2410C, dark: 0xFA7C0B)
    /// 주의 (게이지·막대·칩 바탕). 라이트에서 글자로는 `cautionInk`.
    public static let yellow = Color(light: 0xF5CF06, dark: 0xFDD600)
    /// 주의 글자. 라이트 노랑은 흰 바탕에서 안 읽혀서 호박색으로 (4.6:1).
    public static let cautionInk = Color(light: 0xA36701, dark: 0xFDD600)
    /// 테마 — 슬라이더 채움·토글·주 버튼·진행 단계·게이지 채움. 앱마다 `AccentTheme.current`로 바꾼다 (기본 라임).
    /// 흰 바탕에서 글자·얇은 선으로는 쓰지 않는다 — 그건 `themeLine`.
    public static var theme: Color {
        AccentTheme.current.fill
    }

    /// 테마색 선 — 고른 칩·카드 테두리, 체크, 탭 바 선택. 라이트는 흰 바탕에서 보이게 진하게 (3:1).
    public static var themeLine: Color {
        AccentTheme.current.line
    }

    /// 고른 칩·카드 바탕에 까는 옅은 테마색 (`plate` 위에).
    public static var themeWash: Color {
        AccentTheme.current.fill.opacity(0.12)
    }

    /// 화면 바탕 위에 놓이는 고르기 판 (선택 카드·칩). 라이트는 흰 판 — iOS 그룹 바탕 위 셀처럼 바탕보다 밝게 뜬다
    /// (회색 `fill3`은 바탕보다 진해서 가라앉고, 그 위 라임은 탁한 올리브가 된다). 다크는 `fill3`과 같다.
    public static let plate = Color(light: 0xFFFFFF, dark: 0x767680, darkAlpha: 0.24)
    /// `theme`로 채운 면 위 글자.
    public static var onTheme: Color {
        AccentTheme.current.onFill
    }

    /// 슬라이더 손잡이 (모드와 관계없이 흰색).
    public static let knob = Color(light: 0xFFFFFF, dark: 0xFFFFFF)
    public static let green = Color(light: 0x06C84D, dark: 0x04E458)
    public static let mint = Color(light: 0x0ECB7F, dark: 0x21FCA0)
    public static let aqua = Color(light: 0x06C5BB, dark: 0x05F8EB)
    public static let cyan = Color(light: 0x31BFE4, dark: 0x5DD8FC)
    public static let blue = Color(light: 0x3780DA, dark: 0x4092F8)
    public static let purple = Color(light: 0xB346EE, dark: 0xC35EFC)
    public static let magenta = Color(light: 0xE50EB2, dark: 0xFA42C6)
    public static let pink = Color(light: 0xFE237D, dark: 0xFD3580)
}

extension Color {
    /// 라이트·다크 두 벌. 위젯·잠금 화면에서도 시스템이 모드에 맞춰 고른다.
    /// 격리 없이 — SwiftUI가 애니메이션 중 백그라운드 렌더 스레드에서 색을 고른다 (MainActor면 격리 검사로 크래시).
    /// `p3`: 값을 Display P3로 읽는다 — sRGB 밖의 진한 색 (형광 라임). sRGB 화면에서는 가장 가까운 색으로.
    public nonisolated init(
        light: UInt32,
        lightAlpha: Double = 1,
        dark: UInt32,
        darkAlpha: Double = 1,
        p3: Bool = false,
    ) {
        self.init(uiColor: UIColor { @Sendable traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark, alpha: darkAlpha, p3: p3)
                : UIColor(hex: light, alpha: lightAlpha, p3: p3)
        })
    }
}

extension UIColor {
    convenience nonisolated init(hex: UInt32, alpha: Double, p3: Bool = false) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        if p3 {
            self.init(displayP3Red: red, green: green, blue: blue, alpha: alpha)
        } else {
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
}
