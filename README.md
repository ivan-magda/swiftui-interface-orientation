# SwiftUI Interface Orientation

[![Swift 6](https://img.shields.io/badge/Swift-6-orange.svg)](https://swift.org)
[![iOS 14+](https://img.shields.io/badge/iOS-14+-blue.svg)](https://developer.apple.com/ios/)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Per-view orientation locking for SwiftUI apps. Attach one modifier to a view and it locks the app to the orientations you specify while that view is on screen.

```swift
Text("This view stays portrait")
    .supportedInterfaceOrientations(.portrait)
```

## Table of Contents

- [Background](#background)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

## Background

SwiftUI has no built-in way to control orientation per view. Your options are to lock the whole app through `Info.plist`, or to manage `application(_:supportedInterfaceOrientationsFor:)` by hand and track which screen is visible across the UIKit lifecycle.

This package replaces that bookkeeping with a single view modifier. Each view registers its allowed orientations when it appears and removes them when it disappears. A shared `InterfaceOrientationManager` holds the registry, computes the intersection of every active constraint, and asks the system to re-evaluate the supported orientations. When two visible views ask for orientations that don't overlap, the manager falls back to your app defaults instead of returning an empty mask.

## Features

- One modifier, `.supportedInterfaceOrientations(_:)`, applied directly to any view.
- Constraints register on `onAppear` and clear on `onDisappear`, so navigating away restores the previous orientation.
- Multiple visible views resolve to the intersection of their masks; an empty intersection falls back to your defaults.
- Defaults read from `UISupportedInterfaceOrientations` in `Info.plist`, or set them explicitly through `Configuration`.
- Updates supported orientations through `setNeedsUpdateOfSupportedInterfaceOrientations()` on iOS 16+, falling back to `attemptRotationToDeviceOrientation()` on earlier versions.
- `@MainActor`-isolated manager built for the Swift 6 language mode.

## Installation

### Xcode

1. Open **File → Add Package Dependencies…**
2. Enter the URL: `https://github.com/ivan-magda/swiftui-interface-orientation.git`
3. Choose the `SwiftUIInterfaceOrientation` library and add it to your target.

### Package.swift

Add the package to your dependencies:

```swift
dependencies: [
    .package(
        url: "https://github.com/ivan-magda/swiftui-interface-orientation.git",
        from: "1.2.0"
    )
]
```

Then add the product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(
            name: "SwiftUIInterfaceOrientation",
            package: "swiftui-interface-orientation"
        )
    ]
)
```

### App-level setup

The manager resolves orientations, but iOS only asks for them through your app delegate. Implement `application(_:supportedInterfaceOrientationsFor:)` and return `InterfaceOrientationManager.shared.supportedInterfaceOrientations`. Without this hook the modifier has no effect.

```swift
import SwiftUI
import SwiftUIInterfaceOrientation

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        InterfaceOrientationManager.shared.supportedInterfaceOrientations
    }
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

The manager reads its defaults from the `UISupportedInterfaceOrientations` key in your app's `Info.plist`. To set defaults in code instead, see [Custom defaults](#custom-defaults).

## Usage

### Lock a single view

Apply the modifier to any view. The constraint applies while the view is visible and clears when it leaves the screen.

```swift
import SwiftUI
import SwiftUIInterfaceOrientation

struct PortraitOnlyView: View {
    var body: some View {
        Text("Locked to portrait")
            .supportedInterfaceOrientations(.portrait)
    }
}
```

### Navigation

Each destination declares its own orientations. The constraint registers when the destination appears and clears when you navigate back.

```swift
struct ContentView: View {
    var body: some View {
        NavigationStack { // NavigationView on iOS 14-15
            List {
                NavigationLink("Portrait screen") {
                    Text("Portrait only")
                        .supportedInterfaceOrientations(.portrait)
                }

                NavigationLink("Landscape screen") {
                    Text("Landscape only")
                        .supportedInterfaceOrientations(.landscape)
                }
            }
        }
    }
}
```

### Allow all but upside down

A common choice for iPhone apps:

```swift
ContentView()
    .supportedInterfaceOrientations(.allButUpsideDown)
```

### Clear a constraint

Pass `nil` or an empty mask to remove this view's constraint and let the defaults apply.

```swift
SomeView()
    .supportedInterfaceOrientations(isLocked ? .portrait : nil)
```

### Custom defaults

By default the manager reads `UISupportedInterfaceOrientations` from `Info.plist`. To supply defaults in code, call `configure(configuration:)` before anything accesses `InterfaceOrientationManager.shared`. The call asserts if the manager has already initialized, so place it at the start of your launch sequence, such as in `application(_:didFinishLaunchingWithOptions:)`.

```swift
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        InterfaceOrientationManager.configure(
            configuration: .init(defaultOrientations: .portrait)
        )
        return true
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        InterfaceOrientationManager.shared.supportedInterfaceOrientations
    }
}
```

`Configuration.fromInfoPlist()` is the default and reproduces the automatic behavior.

## Project Structure

```
Sources/SwiftUIInterfaceOrientation/
├── InterfaceOrientationManager.swift   // Registry, resolution, and Configuration
├── View+InterfaceOrientation.swift     // The .supportedInterfaceOrientations(_:) modifier
└── MainBundleInfo.swift                // Reads UISupportedInterfaceOrientations from Info.plist
```

## Contributing

Issues and pull requests are welcome. The package builds with `swift build`, and the test suite runs against an iOS simulator:

```bash
xcodebuild test \
  -scheme SwiftUIInterfaceOrientation \
  -destination "platform=iOS Simulator,OS=18.4,name=iPhone 16" \
  -configuration Debug
```

Lint with `swiftlint --strict` before opening a pull request.

## License

Released under the MIT License. See [LICENSE](LICENSE) for the full text.
