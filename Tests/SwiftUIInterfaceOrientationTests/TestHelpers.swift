import Testing
import UIKit

extension Tag {
    @Tag static var registration: Self
    @Tag static var intersection: Self
    @Tag static var configuration: Self
    @Tag static var infoPlist: Self
}

extension UIInterfaceOrientationMask: @retroactive CustomTestStringConvertible {
    public var testDescription: String {
        switch self {
        case .portrait: "portrait"
        case .landscape: "landscape"
        case .landscapeLeft: "landscapeLeft"
        case .landscapeRight: "landscapeRight"
        case .portraitUpsideDown: "portraitUpsideDown"
        case .all: "all"
        case .allButUpsideDown: "allButUpsideDown"
        default: "mask(\(rawValue))"
        }
    }
}
