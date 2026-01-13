# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

```bash
# Build the package
swift build

# Run all tests (requires iOS simulator)
xcodebuild test \
  -scheme SwiftUIInterfaceOrientation \
  -destination "platform=iOS Simulator,OS=18.1,name=iPhone 16" \
  -configuration Debug

# Run a single test
xcodebuild test \
  -scheme SwiftUIInterfaceOrientation \
  -destination "platform=iOS Simulator,OS=18.1,name=iPhone 16" \
  -only-testing:SwiftUIInterfaceOrientationTests/InterfaceOrientationManagerTests/testCustomConfiguration

# Lint
swiftlint --strict
```

## Architecture

This is a Swift Package for iOS that provides orientation locking for SwiftUI views. The core design uses a centralized manager with view-based registration.

### Key Components

- **InterfaceOrientationManager** (`InterfaceOrientationManager.swift`): Singleton that maintains a registry of orientation constraints (keyed by UUID). Computes supported orientations by intersecting all registered constraints with defaults. Falls back to default orientations if intersection is empty.

- **View Modifier** (`View+InterfaceOrientation.swift`): The `.supportedInterfaceOrientations()` modifier that registers/unregisters constraints on `onAppear`/`onDisappear`. Each view instance gets a unique UUID for its constraints.

- **MainBundleInfo** (`MainBundleInfo.swift`): Utility to parse `UISupportedInterfaceOrientations` from Info.plist into `UIInterfaceOrientationMask`.

### Integration Pattern

Apps must wire the manager to iOS by implementing `application(_:supportedInterfaceOrientationsFor:)` in their AppDelegate and returning `InterfaceOrientationManager.shared.supportedInterfaceOrientations`.

## Code Style

- Swift 6.0 tools version with Swift 5 language mode
- SwiftLint enforced with strict mode (see `.swiftlint.yml`)
- Line length: 120 warning, 150 error
- Force unwrapping triggers lint warnings (use `force_unwrapping` opt-in rule)
