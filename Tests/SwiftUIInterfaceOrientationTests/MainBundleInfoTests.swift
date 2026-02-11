import Testing
import UIKit
@testable import SwiftUIInterfaceOrientation

@Suite("MainBundleInfo", .tags(.infoPlist))
struct MainBundleInfoTests {
    @Test("supportedInterfaceOrientations returns a valid mask")
    func supportedOrientationsValid() {
        let mask = MainBundleInfo.supportedInterfaceOrientations
        let allKnown: UIInterfaceOrientationMask = [.portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight]
        #expect(mask.isSubset(of: allKnown) || mask.isEmpty)
    }

    @Test("supportedInterfaceOrientations is deterministic")
    func supportedOrientationsDeterministic() {
        let first = MainBundleInfo.supportedInterfaceOrientations
        let second = MainBundleInfo.supportedInterfaceOrientations
        #expect(first == second)
    }
}
