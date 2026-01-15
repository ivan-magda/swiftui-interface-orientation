import XCTest
import UIKit
@testable import SwiftUIInterfaceOrientation

@MainActor
final class InterfaceOrientationManagerTests: XCTestCase {
    override func setUp() async throws {
        InterfaceOrientationManager.configure(configuration: .init(defaultOrientations: .all))
    }

    func testCustomConfiguration() {
        // Create a new configuration with portrait-only default
        let config = InterfaceOrientationManager.Configuration(defaultOrientations: .portrait)

        // Configure the manager with this configuration
        InterfaceOrientationManager.configure(configuration: config)

        // Initialize a new test instance that uses this configuration
        let manager = InterfaceOrientationManager.shared

        // It should use the portrait-only default
        XCTAssertEqual(manager.supportedInterfaceOrientations, .portrait)

        // Register a landscape orientation
        let id = UUID()
        manager.register(orientations: .landscape, id: id)

        // Result should be empty (portrait ∩ landscape = ∅), so it falls back to default (.portrait)
        XCTAssertEqual(manager.supportedInterfaceOrientations, .portrait)

        // Clean up
        manager.unregister(orientationsWithID: id)
    }
}
