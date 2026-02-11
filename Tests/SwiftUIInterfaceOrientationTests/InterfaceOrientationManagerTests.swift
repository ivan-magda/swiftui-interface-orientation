import Testing
import UIKit
@testable import SwiftUIInterfaceOrientation

@Suite("InterfaceOrientationManager", .serialized)
@MainActor
struct InterfaceOrientationManagerTests {

    // MARK: - Default Orientations

    @Suite("Default Orientations")
    @MainActor
    struct DefaultOrientations {
        private let manager = InterfaceOrientationManager.shared

        @Test("Returns non-empty mask when no constraints registered")
        func defaultOrientationsNonEmpty() {
            #expect(!manager.supportedInterfaceOrientations.isEmpty)
        }

        @Test("Contains portrait or landscape by default")
        func defaultContainsPortraitOrLandscape() {
            let defaults = manager.supportedInterfaceOrientations
            #expect(!defaults.isEmpty)
            #expect(defaults.contains(.portrait) || defaults.contains(.landscape))
        }
    }

    // MARK: - Single Constraint Registration

    @Suite("Single Constraint Registration", .tags(.registration))
    @MainActor
    struct SingleConstraint {
        private let manager = InterfaceOrientationManager.shared

        @Test(
            "Registers a single constraint",
            arguments: [
                (UIInterfaceOrientationMask.portrait, "portrait"),
                (.landscape, "landscape"),
                (.allButUpsideDown, "allButUpsideDown"),
                (.landscapeLeft, "landscapeLeft"),
                (.landscapeRight, "landscapeRight")
            ]
        )
        func singleConstraint(mask: UIInterfaceOrientationMask, name: String) {
            let id = UUID()
            defer { manager.unregister(orientationsWithID: id) }
            manager.register(orientations: mask, id: id)
            #expect(manager.supportedInterfaceOrientations == mask)
        }
    }

    // MARK: - Multiple Constraints with Intersection

    @Suite("Multiple Constraints with Intersection", .tags(.intersection))
    @MainActor
    struct MultipleConstraints {
        private let manager = InterfaceOrientationManager.shared

        @Test(
            "Intersection of two masks",
            arguments: [
                (
                    UIInterfaceOrientationMask.allButUpsideDown,
                    UIInterfaceOrientationMask.portrait,
                    UIInterfaceOrientationMask.portrait
                ),
                (.landscape, .landscapeLeft, .landscapeLeft),
                (.allButUpsideDown, .landscape, .landscape)
            ]
        )
        func intersection(
            mask1: UIInterfaceOrientationMask,
            mask2: UIInterfaceOrientationMask,
            expected: UIInterfaceOrientationMask
        ) {
            let id1 = UUID()
            let id2 = UUID()
            defer {
                manager.unregister(orientationsWithID: id1)
                manager.unregister(orientationsWithID: id2)
            }
            manager.register(orientations: mask1, id: id1)
            manager.register(orientations: mask2, id: id2)
            #expect(manager.supportedInterfaceOrientations == expected)
        }

        @Test("Multiple identical portrait constraints")
        func multiplePortraitConstraints() {
            let id1 = UUID()
            let id2 = UUID()
            let id3 = UUID()
            defer {
                manager.unregister(orientationsWithID: id1)
                manager.unregister(orientationsWithID: id2)
                manager.unregister(orientationsWithID: id3)
            }

            manager.register(orientations: .portrait, id: id1)
            manager.register(orientations: .portrait, id: id2)
            manager.register(orientations: .portrait, id: id3)

            #expect(manager.supportedInterfaceOrientations == .portrait)
        }
    }

    // MARK: - Empty Intersection Fallback

    @Suite("Empty Intersection Fallback", .tags(.intersection))
    @MainActor
    struct EmptyIntersectionFallback {
        private let manager = InterfaceOrientationManager.shared

        @Test("Conflicting constraints fall back to default")
        func conflictingFallsBackToDefault() {
            let defaultOrientations = manager.supportedInterfaceOrientations
            let id1 = UUID()
            let id2 = UUID()
            defer {
                manager.unregister(orientationsWithID: id1)
                manager.unregister(orientationsWithID: id2)
            }

            manager.register(orientations: .portrait, id: id1)
            manager.register(orientations: .landscape, id: id2)

            #expect(manager.supportedInterfaceOrientations == defaultOrientations)
        }

        @Test("LandscapeLeft and landscapeRight conflict falls back to default")
        func landscapeLeftRightConflict() {
            let defaultOrientations = manager.supportedInterfaceOrientations
            let id1 = UUID()
            let id2 = UUID()
            defer {
                manager.unregister(orientationsWithID: id1)
                manager.unregister(orientationsWithID: id2)
            }

            manager.register(orientations: .landscapeLeft, id: id1)
            manager.register(orientations: .landscapeRight, id: id2)

            #expect(manager.supportedInterfaceOrientations == defaultOrientations)
        }
    }

    // MARK: - Unregistration

    @Suite("Unregistration", .tags(.registration))
    @MainActor
    struct Unregistration {
        private let manager = InterfaceOrientationManager.shared

        @Test("Unregister restores default orientations")
        func unregisterRestoresDefault() {
            let defaultOrientations = manager.supportedInterfaceOrientations
            let id = UUID()

            manager.register(orientations: .portrait, id: id)
            #expect(manager.supportedInterfaceOrientations == .portrait)

            manager.unregister(orientationsWithID: id)
            #expect(manager.supportedInterfaceOrientations == defaultOrientations)
        }

        @Test("Unregister one of multiple constraints")
        func unregisterOneOfMultiple() {
            let id1 = UUID()
            let id2 = UUID()
            defer { manager.unregister(orientationsWithID: id1) }

            manager.register(orientations: .allButUpsideDown, id: id1)
            manager.register(orientations: .portrait, id: id2)
            #expect(manager.supportedInterfaceOrientations == .portrait)

            manager.unregister(orientationsWithID: id2)
            #expect(manager.supportedInterfaceOrientations == .allButUpsideDown)
        }

        @Test("Unregister non-existent ID has no effect")
        func unregisterNonExistentId() {
            let id = UUID()
            let nonExistentId = UUID()
            defer { manager.unregister(orientationsWithID: id) }

            manager.register(orientations: .portrait, id: id)
            manager.unregister(orientationsWithID: nonExistentId)

            #expect(manager.supportedInterfaceOrientations == .portrait)
        }

        @Test("Unregister all constraints restores default")
        func unregisterAllRestoresDefault() {
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

            #expect(manager.supportedInterfaceOrientations == defaultOrientations)
        }
    }

    // MARK: - Re-registration

    @Suite("Re-registration", .tags(.registration))
    @MainActor
    struct ReRegistration {
        private let manager = InterfaceOrientationManager.shared

        @Test("Re-register with same ID updates constraint")
        func reregisterUpdateConstraint() {
            let id = UUID()
            defer { manager.unregister(orientationsWithID: id) }

            manager.register(orientations: .portrait, id: id)
            #expect(manager.supportedInterfaceOrientations == .portrait)

            manager.register(orientations: .landscape, id: id)
            #expect(manager.supportedInterfaceOrientations == .landscape)
        }

        @Test("Re-register from portrait to allButUpsideDown")
        func reregisterPortraitToAllButUpsideDown() {
            let id = UUID()
            defer { manager.unregister(orientationsWithID: id) }

            manager.register(orientations: .portrait, id: id)
            #expect(manager.supportedInterfaceOrientations == .portrait)

            manager.register(orientations: .allButUpsideDown, id: id)
            #expect(manager.supportedInterfaceOrientations == .allButUpsideDown)
        }
    }

    // MARK: - Edge Cases

    @Suite("Edge Cases")
    @MainActor
    struct EdgeCases {
        private let manager = InterfaceOrientationManager.shared

        @Test("Register same orientation as default")
        func registerSameAsDefault() {
            let defaultOrientations = manager.supportedInterfaceOrientations
            let id = UUID()
            defer { manager.unregister(orientationsWithID: id) }

            manager.register(orientations: defaultOrientations, id: id)
            #expect(manager.supportedInterfaceOrientations == defaultOrientations)
        }

        @Test("Complex intersection with progressive unregistration")
        func complexIntersection() {
            let id1 = UUID()
            let id2 = UUID()
            let id3 = UUID()
            defer {
                manager.unregister(orientationsWithID: id1)
                manager.unregister(orientationsWithID: id2)
                manager.unregister(orientationsWithID: id3)
            }

            manager.register(orientations: [.portrait, .landscapeLeft, .landscapeRight], id: id1)
            manager.register(orientations: [.portrait, .landscapeLeft], id: id2)
            manager.register(orientations: .portrait, id: id3)

            #expect(manager.supportedInterfaceOrientations == .portrait)

            manager.unregister(orientationsWithID: id3)
            #expect(manager.supportedInterfaceOrientations == [.portrait, .landscapeLeft])

            manager.unregister(orientationsWithID: id2)
            #expect(
                manager.supportedInterfaceOrientations == [.portrait, .landscapeLeft, .landscapeRight]
            )
        }

        @Test("Registration order does not affect result")
        func registrationOrderIndependent() {
            let id1 = UUID()
            let id2 = UUID()

            manager.register(orientations: .portrait, id: id1)
            manager.register(orientations: .allButUpsideDown, id: id2)
            let result1 = manager.supportedInterfaceOrientations

            manager.unregister(orientationsWithID: id1)
            manager.unregister(orientationsWithID: id2)

            manager.register(orientations: .allButUpsideDown, id: id2)
            manager.register(orientations: .portrait, id: id1)
            let result2 = manager.supportedInterfaceOrientations

            manager.unregister(orientationsWithID: id1)
            manager.unregister(orientationsWithID: id2)

            #expect(result1 == result2)
            #expect(result1 == .portrait)
        }
    }
}
