import XCTest
import UIKit
@testable import SwiftUIInterfaceOrientation

@MainActor
final class InterfaceOrientationManagerTests: XCTestCase {
    override func setUp() async throws {
        InterfaceOrientationManager.configure(configuration: .init(defaultOrientations: .all))
    }

    func testCustomConfiguration() {
        let config = InterfaceOrientationManager.Configuration(defaultOrientations: .portrait)
        InterfaceOrientationManager.configure(configuration: config)

        let manager = InterfaceOrientationManager.shared
        XCTAssertEqual(manager.supportedInterfaceOrientations, .portrait)

        let id = UUID()
        manager.register(orientations: .landscape, id: id)

        // portrait ∩ landscape = ∅, falls back to default
        XCTAssertEqual(manager.supportedInterfaceOrientations, .portrait)

        manager.unregister(orientationsWithID: id)
    }
}
