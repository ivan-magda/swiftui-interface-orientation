# swiftui-interface-orientation

A Swift package that provides orientation locking capabilities for SwiftUI views.

## Problem

SwiftUI doesn't have a built-in way to lock orientation for specific views. This package addresses this limitation by providing a centralized orientation manager and a view modifier to control orientations on a per-view basis.

## Features

- Lock orientation for specific SwiftUI views
- Support for all iOS orientations (portrait, landscape, upside down)
- Automatic resolution of conflicting orientation constraints
- Easy-to-use SwiftUI view modifier

## Requirements

- iOS 14.0 or later
- Swift 5.5 or later
- Xcode 13.0 or later

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

https://github.com/ivan-magda/swiftui-interface-orientation.git

```swift
dependencies: [
    .package(url: "https://github.com/ivan-magda/swiftui-interface-orientation.git", from: "1.0.0")
]
```

Or add it directly through Xcode:
1. In Xcode, select "File" → "Add Packages..."
2. Enter the URL: `https://github.com/ivan-magda/swiftui-interface-orientation.git`
3. Choose the version rule (e.g., "Up to Next Major")
4. Click "Add Package"

## Usage

### Setup

Configure the orientation manager early in your app lifecycle, typically in your App or Scene delegate:

```swift
import SwiftUIInterfaceOrientation

@main
struct MyApp: App {
    init() {
        // Configure with default orientations from Info.plist
        InterfaceOrientationManager.configure()
        
        // Or specify custom defaults
        // InterfaceOrientationManager.configure(configuration: .init(defaultOrientations: .portrait))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Using the View Modifier

Apply the `.supportedInterfaceOrientations()` modifier to any SwiftUI view:

```swift
import SwiftUI
import SwiftUIInterfaceOrientation

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Normal View") {
                    Text("This view uses the app's default orientations")
                }
                
                NavigationLink("Portrait Only") {
                    PortraitOnlyView()
                }
                
                NavigationLink("Landscape Only") {
                    LandscapeOnlyView()
                }
            }
        }
    }
}

struct PortraitOnlyView: View {
    var body: some View {
        Text("This view is locked to portrait orientation")
            .supportedInterfaceOrientations(.portrait)
    }
}

struct LandscapeOnlyView: View {
    var body: some View {
        Text("This view is locked to landscape orientation")
            .supportedInterfaceOrientations([.landscapeLeft, .landscapeRight])
    }
}
```

### Advanced: Integration with iOS Delegate Methods

For complete integration, you need to implement either the `UIApplicationDelegate` method or the `UIWindowSceneDelegate` method (for iOS 13+) to handle orientation requests:

#### Option 1: Using UIApplicationDelegate (works on all iOS versions)

```swift
import UIKit
import SwiftUIInterfaceOrientation

class AppDelegate: UIResponder, UIApplicationDelegate {
    // ... other AppDelegate code ...
    
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        // Delegate to the orientation manager
        return InterfaceOrientationManager.shared.supportedInterfaceOrientations
    }
}
```

#### Option 2: Using UIWindowSceneDelegate (iOS 13+)

```swift
import UIKit
import SwiftUIInterfaceOrientation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // ... other SceneDelegate code ...
    
    func windowScene(_ windowScene: UIWindowScene, 
                   didUpdate previousCoordinateSpace: UICoordinateSpace, 
                   interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, 
                   traitCollection previousTraitCollection: UITraitCollection) {
        // Let the manager know when orientation changes
        InterfaceOrientationManager.shared.updateSupportedInterfaceOrientations()
    }
    
    func windowScene(_ windowScene: UIWindowScene, 
                   supportedInterfaceOrientationsFor window: UIWindow) -> UIInterfaceOrientationMask {
        // Delegate to the orientation manager
        return InterfaceOrientationManager.shared.supportedInterfaceOrientations
    }
}
```

#### Option 3: Using SwiftUI's App protocol (iOS 14+)

```swift
import SwiftUI
import SwiftUIInterfaceOrientation

class OrientationDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return InterfaceOrientationManager.shared.supportedInterfaceOrientations
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

## How It Works

The package uses a centralized manager (`InterfaceOrientationManager`) that keeps track of orientation constraints from active views. When views appear and disappear, they register and unregister their constraints with the manager.

The manager computes the intersection of all active constraints to determine which orientations should be allowed. If the intersection would be empty (meaning there are conflicting constraints), it falls back to the default orientations.

## License

MIT License
