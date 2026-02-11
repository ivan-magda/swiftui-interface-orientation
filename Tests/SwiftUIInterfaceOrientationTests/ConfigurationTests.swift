import Testing
import UIKit
@testable import SwiftUIInterfaceOrientation

@Suite("Configuration", .tags(.configuration))
@MainActor
struct ConfigurationTests {
    @Test(
        "Initializes with specified orientations",
        arguments: [
            UIInterfaceOrientationMask.landscape,
            .all,
            .portrait,
            .allButUpsideDown
        ]
    )
    func initWithOrientations(mask: UIInterfaceOrientationMask) {
        let config = InterfaceOrientationManager.Configuration(defaultOrientations: mask)
        #expect(config.defaultOrientations == mask)
    }

    @Test("fromInfoPlist returns valid configuration")
    func fromInfoPlist() {
        let config = InterfaceOrientationManager.Configuration.fromInfoPlist()
        #expect(!config.defaultOrientations.isEmpty)
    }
}
