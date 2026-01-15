import XCTest
import UIKit
@testable import SwiftUIInterfaceOrientation

@MainActor
final class InterfaceOrientationManagerTests: XCTestCase {
    private var manager: InterfaceOrientationManager { InterfaceOrientationManager.shared }

    // MARK: - Default Orientations

    func testDefaultOrientationsWhenNoConstraintsRegistered() {
        XCTAssertFalse(manager.supportedInterfaceOrientations.isEmpty)
    }

    func testDefaultOrientationsAreNonEmpty() {
        let defaults = manager.supportedInterfaceOrientations
        XCTAssertFalse(defaults.isEmpty)
        XCTAssertTrue(defaults.contains(.portrait) || defaults.contains(.landscape))
    }

    // MARK: - Single Constraint Registration

    func testSinglePortraitConstraint() {
        let id = UUID()

        manager.register(orientations: .portrait, id: id)
        XCTAssertEqual(manager.supportedInterfaceOrientations, .portrait)

        manager.unregister(orientationsWithID: id)
    }

    func testSingleLandscapeConstraint() {
        let id = UUID()

        manager.register(orientations: .landscape, id: id)
        XCTAssertEqual(manager.supportedInterfaceOrientations, .landscape)

        manager.unregister(orientationsWithID: id)
    }

    func testSingleAllButUpsideDownConstraint() {
        let id = UUID()

        manager.register(orientations: .allButUpsideDown, id: id)
        XCTAssertEqual(manager.supportedInterfaceOrientations, .allButUpsideDown)

        manager.unregister(orientationsWithID: id)
    }

    func testSingleLandscapeLeftConstraint() {
        let id = UUID()

        manager.register(orientations: .landscapeLeft, id: id)
        XCTAssertEqual(manager.supportedInterfaceOrientations, .landscapeLeft)

        manager.unregister(orientationsWithID: id)
    }

    func testSingleLandscapeRightConstraint() {
        let id = UUID()

        manager.register(orientations: .landscapeRight, id: id)
        XCTAssertEqual(manager.supportedInterfaceOrientations, .landscapeRight)

        manager.unregister(orientationsWithID: id)
    }

    // MARK: - Multiple Constraints with Intersection

    func testTwoCompatibleConstraintsIntersection() {
        let id1 = UUID()
        let id2 = UUID()

        manager.register(orientations: .allButUpsideDown, id: id1)
        manager.register(orientations: .portrait, id: id2)

        // allButUpsideDown ∩ portrait = portrait
        XCTAssertEqual(manager.supportedInterfaceOrientations, .portrait)

        manager.unregister(orientationsWithID: id1)
        manager.unregister(orientationsWithID: id2)
    }

    func testMultiplePortraitConstraints() {
        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()

        manager.register(orientations: .portrait, id: id1)
        manager.register(orientations: .portrait, id: id2)
        manager.register(orientations: .portrait, id: id3)

        XCTAssertEqual(manager.supportedInterfaceOrientations, .portrait)

        manager.unregister(orientationsWithID: id1)
        manager.unregister(orientationsWithID: id2)
        manager.unregister(orientationsWithID: id3)
    }

    func testLandscapeLeftAndLandscapeIntersection() {
        let id1 = UUID()
        let id2 = UUID()

        manager.register(orientations: .landscape, id: id1)
        manager.register(orientations: .landscapeLeft, id: id2)

        // landscape ∩ landscapeLeft = landscapeLeft
        XCTAssertEqual(manager.supportedInterfaceOrientations, .landscapeLeft)

        manager.unregister(orientationsWithID: id1)
        manager.unregister(orientationsWithID: id2)
    }

    func testAllButUpsideDownAndLandscapeIntersection() {
        let id1 = UUID()
        let id2 = UUID()

        manager.register(orientations: .allButUpsideDown, id: id1)
        manager.register(orientations: .landscape, id: id2)

        // allButUpsideDown ∩ landscape = landscape
        XCTAssertEqual(manager.supportedInterfaceOrientations, .landscape)

        manager.unregister(orientationsWithID: id1)
        manager.unregister(orientationsWithID: id2)
    }

    // MARK: - Empty Intersection Fallback

    func testConflictingConstraintsFallsBackToDefault() {
        let defaultOrientations = manager.supportedInterfaceOrientations
        let id1 = UUID()
        let id2 = UUID()

        manager.register(orientations: .portrait, id: id1)
        manager.register(orientations: .landscape, id: id2)

        // portrait ∩ landscape = ∅, falls back to default
        XCTAssertEqual(manager.supportedInterfaceOrientations, defaultOrientations)

        manager.unregister(orientationsWithID: id1)
        manager.unregister(orientationsWithID: id2)
    }

    func testLandscapeLeftAndLandscapeRightConflict() {
        let defaultOrientations = manager.supportedInterfaceOrientations
        let id1 = UUID()
        let id2 = UUID()

        manager.register(orientations: .landscapeLeft, id: id1)
        manager.register(orientations: .landscapeRight, id: id2)

        // landscapeLeft ∩ landscapeRight = ∅, falls back to default
        XCTAssertEqual(manager.supportedInterfaceOrientations, defaultOrientations)

        manager.unregister(orientationsWithID: id1)
        manager.unregister(orientationsWithID: id2)
    }

    // MARK: - Unregistration

    func testUnregisterRestoresDefaultOrientations() {
        let defaultOrientations = manager.supportedInterfaceOrientations
        let id = UUID()

        manager.register(orientations: .portrait, id: id)
        XCTAssertEqual(manager.supportedInterfaceOrientations, .portrait)

        manager.unregister(orientationsWithID: id)
        XCTAssertEqual(manager.supportedInterfaceOrientations, defaultOrientations)
    }

    func testUnregisterOneOfMultipleConstraints() {
        let id1 = UUID()
        let id2 = UUID()

        manager.register(orientations: .allButUpsideDown, id: id1)
        manager.register(orientations: .portrait, id: id2)
        XCTAssertEqual(manager.supportedInterfaceOrientations, .portrait)

        manager.unregister(orientationsWithID: id2)
        XCTAssertEqual(manager.supportedInterfaceOrientations, .allButUpsideDown)

        manager.unregister(orientationsWithID: id1)
    }

    func testUnregisterNonExistentIdHasNoEffect() {
        let id = UUID()
        let nonExistentId = UUID()

        manager.register(orientations: .portrait, id: id)
        manager.unregister(orientationsWithID: nonExistentId)

        XCTAssertEqual(manager.supportedInterfaceOrientations, .portrait)

        manager.unregister(orientationsWithID: id)
    }

    func testUnregisterAllConstraintsRestoresDefault() {
        let defaultOrientations = manager.supportedInterfaceOrientations
        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()

        manager.register(orientations: .portrait, id: id1)
        manager.register(orientations: .portrait, id: id2)
        manager.register(orientations: .portrait, id: id3)

        manager.unregister(orientationsWithID: id1)
        manager.unregister(orientationsWithID: id2)
        manager.unregister(orientationsWithID: id3)

        XCTAssertEqual(manager.supportedInterfaceOrientations, defaultOrientations)
    }

    // MARK: - Re-registration

    func testReregisterWithSameIdUpdatesConstraint() {
        let id = UUID()

        manager.register(orientations: .portrait, id: id)
        XCTAssertEqual(manager.supportedInterfaceOrientations, .portrait)

        manager.register(orientations: .landscape, id: id)
        XCTAssertEqual(manager.supportedInterfaceOrientations, .landscape)

        manager.unregister(orientationsWithID: id)
    }

    func testReregisterFromPortraitToAllButUpsideDown() {
        let id = UUID()

        manager.register(orientations: .portrait, id: id)
        XCTAssertEqual(manager.supportedInterfaceOrientations, .portrait)

        manager.register(orientations: .allButUpsideDown, id: id)
        XCTAssertEqual(manager.supportedInterfaceOrientations, .allButUpsideDown)

        manager.unregister(orientationsWithID: id)
    }

    // MARK: - Configuration

    func testConfigurationInitWithDefaultOrientations() {
        let config = InterfaceOrientationManager.Configuration(defaultOrientations: .landscape)
        XCTAssertEqual(config.defaultOrientations, .landscape)
    }

    func testConfigurationWithAllOrientations() {
        let config = InterfaceOrientationManager.Configuration(defaultOrientations: .all)
        XCTAssertEqual(config.defaultOrientations, .all)
    }

    func testConfigurationWithPortrait() {
        let config = InterfaceOrientationManager.Configuration(defaultOrientations: .portrait)
        XCTAssertEqual(config.defaultOrientations, .portrait)
    }

    func testConfigurationWithAllButUpsideDown() {
        let config = InterfaceOrientationManager.Configuration(defaultOrientations: .allButUpsideDown)
        XCTAssertEqual(config.defaultOrientations, .allButUpsideDown)
    }

    // MARK: - Edge Cases

    func testRegisterSameOrientationAsDefault() {
        let defaultOrientations = manager.supportedInterfaceOrientations
        let id = UUID()

        manager.register(orientations: defaultOrientations, id: id)
        XCTAssertEqual(manager.supportedInterfaceOrientations, defaultOrientations)

        manager.unregister(orientationsWithID: id)
    }

    func testComplexIntersectionScenario() {
        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()

        manager.register(orientations: [.portrait, .landscapeLeft, .landscapeRight], id: id1)
        manager.register(orientations: [.portrait, .landscapeLeft], id: id2)
        manager.register(orientations: .portrait, id: id3)

        // Final intersection should be portrait
        XCTAssertEqual(manager.supportedInterfaceOrientations, .portrait)

        // Remove most restrictive
        manager.unregister(orientationsWithID: id3)
        XCTAssertEqual(manager.supportedInterfaceOrientations, [.portrait, .landscapeLeft])

        // Remove next
        manager.unregister(orientationsWithID: id2)
        XCTAssertEqual(manager.supportedInterfaceOrientations, [.portrait, .landscapeLeft, .landscapeRight])

        manager.unregister(orientationsWithID: id1)
    }

    func testRegistrationOrderDoesNotAffectResult() {
        let id1 = UUID()
        let id2 = UUID()

        // Register in one order
        manager.register(orientations: .portrait, id: id1)
        manager.register(orientations: .allButUpsideDown, id: id2)
        let result1 = manager.supportedInterfaceOrientations

        manager.unregister(orientationsWithID: id1)
        manager.unregister(orientationsWithID: id2)

        // Register in reverse order
        manager.register(orientations: .allButUpsideDown, id: id2)
        manager.register(orientations: .portrait, id: id1)
        let result2 = manager.supportedInterfaceOrientations

        XCTAssertEqual(result1, result2)
        XCTAssertEqual(result1, .portrait)

        manager.unregister(orientationsWithID: id1)
        manager.unregister(orientationsWithID: id2)
    }
}
