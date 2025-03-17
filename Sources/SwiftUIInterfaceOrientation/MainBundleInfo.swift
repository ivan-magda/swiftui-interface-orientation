import UIKit

enum MainBundleInfo {
    private static var infoDictionary: [String: Any]? { Bundle.main.infoDictionary }

    static var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let plistOrientations = infoDictionary?["UISupportedInterfaceOrientations"] as? [String] ?? []

        let orientationToMaskMap: [String: UIInterfaceOrientationMask] = [
            "UIInterfaceOrientationPortrait": .portrait,
            "UIInterfaceOrientationPortraitUpsideDown": .portraitUpsideDown,
            "UIInterfaceOrientationLandscapeLeft": .landscapeLeft,
            "UIInterfaceOrientationLandscapeRight": .landscapeRight
        ]
        // swiftlint:disable:next reduce_into
        return plistOrientations.reduce([]) { combinedMask, orientationKey in
            if let maskValue = orientationToMaskMap[orientationKey] {
                return combinedMask.union(maskValue)
            } else {
                assertionFailure(
                    "Unknown value '\(orientationKey)' for Info.plist entry UISupportedInterfaceOrientations"
                )
                return combinedMask
            }
        }
    }
}
