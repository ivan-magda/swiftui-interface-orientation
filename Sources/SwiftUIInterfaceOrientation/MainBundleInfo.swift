import UIKit

/// A utility for reading configuration values from the app's main bundle Info.plist.
///
/// This enum provides type-safe access to Info.plist values, specifically for parsing
/// the `UISupportedInterfaceOrientations` array into a `UIInterfaceOrientationMask`.
enum MainBundleInfo {
    private static var infoDictionary: [String: Any]? { Bundle.main.infoDictionary }

    private static let orientationToMaskMap: [String: UIInterfaceOrientationMask] = [
        "UIInterfaceOrientationPortrait": .portrait,
        "UIInterfaceOrientationPortraitUpsideDown": .portraitUpsideDown,
        "UIInterfaceOrientationLandscapeLeft": .landscapeLeft,
        "UIInterfaceOrientationLandscapeRight": .landscapeRight
    ]

    /// The supported interface orientations as defined in the app's Info.plist.
    ///
    /// Reads the `UISupportedInterfaceOrientations` key from Info.plist and converts
    /// the string values to a combined `UIInterfaceOrientationMask`. The plist contains
    /// string values like `UIInterfaceOrientationPortrait` which are mapped to their
    /// corresponding mask values.
    ///
    /// Supported plist values:
    /// - `UIInterfaceOrientationPortrait` → `.portrait`
    /// - `UIInterfaceOrientationPortraitUpsideDown` → `.portraitUpsideDown`
    /// - `UIInterfaceOrientationLandscapeLeft` → `.landscapeLeft`
    /// - `UIInterfaceOrientationLandscapeRight` → `.landscapeRight`
    ///
    /// - Returns: A combined orientation mask, or an empty mask if the key is missing.
    static var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let plistOrientations = infoDictionary?["UISupportedInterfaceOrientations"] as? [String] ?? []

        return plistOrientations.reduce(into: UIInterfaceOrientationMask()) { combinedMask, orientationKey in
            if let maskValue = orientationToMaskMap[orientationKey] {
                combinedMask.formUnion(maskValue)
            } else {
                assertionFailure(
                    "Unknown value '\(orientationKey)' for Info.plist entry UISupportedInterfaceOrientations"
                )
            }
        }
    }
}
