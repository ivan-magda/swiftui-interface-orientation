# SwiftUI Interface Orientation

[![Swift 6](https://img.shields.io/badge/Swift-6-orange.svg)](https://swift.org)
[![iOS 14+](https://img.shields.io/badge/iOS-14+-blue.svg)](https://developer.apple.com/ios/)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Lock screen orientation per-view in SwiftUI. No UIKit subclassing, no hacks.**

```swift
Text("This view stays portrait")
    .supportedInterfaceOrientations(.portrait)
```

That's it. The view locks to portrait. Navigate away, it unlocks. Conflicting constraints across multiple views? Handled automatically.

## The Problem

SwiftUI has no native way to lock orientation for specific views. You either lock the entire app in Info.plist, or dive into UIKit lifecycle callbacks scattered across AppDelegate, SceneDelegate, and view controllers.

This package gives you a single view modifier that just works.

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/ivan-magda/swiftui-interface-orientation.git", from: "1.1.0")
]
```

Or in Xcode: **File → Add Packages** → paste the URL above.

## Quick Start

### 1. Configure the manager (once, at app launch)

```swift
import SwiftUIInterfaceOrientation

@main
struct MyApp: App {
    init() {
        InterfaceOrientationManager.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. Wire up iOS orientation callbacks

```swift
class OrientationDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        InterfaceOrientationManager.shared.supportedInterfaceOrientations
    }
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(OrientationDelegate.self) var delegate

    init() {
        InterfaceOrientationManager.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 3. Lock any view to specific orientations

```swift
struct PortraitOnlyView: View {
    var body: some View {
        Text("Locked to portrait")
            .supportedInterfaceOrientations(.portrait)
    }
}

struct LandscapeOnlyView: View {
    var body: some View {
        VideoPlayer(player: player)
            .supportedInterfaceOrientations([.landscapeLeft, .landscapeRight])
    }
}
```

## How It Works

The package uses a centralized `InterfaceOrientationManager` that tracks orientation constraints from all active views:

1. When a view with `.supportedInterfaceOrientations()` appears, it registers its constraint
2. When the view disappears, the constraint is removed
3. The manager computes the intersection of all active constraints
4. If constraints conflict (intersection is empty), it falls back to your app's defaults from Info.plist

This means nested views with different constraints "just work"—the most restrictive common orientation wins.

## API

### View Modifier

```swift
func supportedInterfaceOrientations(_ orientations: UIInterfaceOrientationMask) -> some View
```

### Configuration

```swift
// Use defaults from Info.plist
InterfaceOrientationManager.configure()

// Or specify custom defaults
InterfaceOrientationManager.configure(
    configuration: .init(defaultOrientations: .portrait)
)
```

### Orientation Masks

```swift
.portrait           // Portrait only
.landscapeLeft      // Landscape, home button on right
.landscapeRight     // Landscape, home button on left
.portraitUpsideDown // Upside down (iPad only effectively)
.landscape          // Both landscape orientations
.all                // All orientations
.allButUpsideDown   // All except upside down
```

## Requirements

- iOS 14.0+
- Swift 6
- Xcode 16.0+

## License

MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Issues and PRs welcome.
