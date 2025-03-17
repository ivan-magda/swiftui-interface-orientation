# swiftui-interface-orientation

A Swift package that provides orientation locking capabilities for SwiftUI views.

## Problem

SwiftUI doesn't have a built-in way to lock orientation for specific views. This package addresses this limitation by providing a centralized orientation manager and a view modifier to control orientations on a per-view basis.

## Features

- Lock orientation for specific SwiftUI views
- Support for all iOS orientations (portrait, landscape, upside down)
- Automatic resolution of conflicting orientation constraints
- Easy-to-use SwiftUI view modifier
- Thread-safe implementation
- Comprehensive unit tests

## Requirements

- iOS 14.0 or later
- Swift 5.5 or later
- Xcode 13.0 or later

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftUIOrientationLock.git", from: "1.0.0")
]
```

Or add it directly through Xcode:
1. In Xcode, select "File" → "Add Packages..."
2. Enter the URL: `https://github.com/yourusername/SwiftUIOrientationLock.git`
3. Choose the version rule (e.g., "Up to Next Major")
4. Click "Add Package"

## Usage

### Setup

Configure the orientation manager early in your app lifecycle, typically in your App or Scene delegate:

```swift
import SwiftUIOrientationLock

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
import SwiftUIOrientationLock

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

### Advanced: Handle iOS Window Scene Delegate

For complete integration, you'll need to implement `UIWindowSceneDelegate` and override `supportedInterfaceOrientationsFor`:

```swift
import UIKit
import SwiftUIOrientationLock

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // ... other code ...
    
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

## How It Works

The package uses a centralized manager (`InterfaceOrientationManager`) that keeps track of orientation constraints from active views. When views appear and disappear, they register and unregister their constraints with the manager.

The manager computes the intersection of all active constraints to determine which orientations should be allowed. If the intersection would be empty (meaning there are conflicting constraints), it falls back to the default orientations.

## License

MIT License

## Author

Your Name

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
