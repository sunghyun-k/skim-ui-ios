# LegendUI

A SwiftUI cross-platform design component library. Supports iOS 17+ and macOS 14+.

![gif](https://github.com/user-attachments/assets/0a505a4d-fb1e-4ff8-8ead-52d5265b8e0c)

## Installation

Add the package to your Xcode project:

```
https://github.com/sunghyun-k/legendui-swift
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sunghyun-k/legendui-swift", from: "0.1.0")
]
```

## Components

| Component | Description |
|-----------|-------------|
| **Button** | Customizable button with variants, sizes, and loading states |
| **Chip** | Compact element for tags, filters, or selections |
| **Dialog** | Modal dialog with header, body, and footer |
| **Select** | Single-selection with Radio, Card, Dropdown, Segmented styles |
| **Separator** | Horizontal or vertical divider |
| **Skeleton** | Loading placeholder with shimmer/pulse animations |
| **Spinner** | Loading indicator |
| **Surface** | Theme-aware container backgrounds |
| **TextInput** | Text field with validation states |
| **Toast** | Stackable notification messages |
| **ToggleStyle** | Checkbox and Switch styles |

## Quick Start

```swift
import SwiftUI
import LegendUI

struct ContentView: View {
    @State private var toasts: [ToastValue] = []

    var body: some View {
        VStack(spacing: 16) {
            Button("Show Toast") {
                toasts.append(ToastValue(
                    title: "Success",
                    message: "Operation completed",
                    type: .success
                ))
            }
            .buttonStyle(.legend(variant: .primary))
        }
        .toasts($toasts)
    }
}
```

## Theming

LegendUI uses a theme system for consistent styling:

```swift
// Use default theme (automatic)
ContentView()

// Or apply custom theme
SharedTheme.value = customTheme
```

## Requirements

- iOS 17.0+
- macOS 14.0+
- Swift 6.0+

## License

MIT License. See [LICENSE](LICENSE) for details.
