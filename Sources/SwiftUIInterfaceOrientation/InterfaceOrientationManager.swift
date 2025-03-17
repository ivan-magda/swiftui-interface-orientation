import Combine
import OSLog
import UIKit

/// A manager that handles interface orientation constraints for SwiftUI views.
///
/// This class provides a centralized way to manage interface orientations across your SwiftUI app.
/// It maintains a registry of orientation constraints from active views and resolves them
/// to determine the supported orientations for the app.
///
/// Usage:
/// ```swift
/// // In your AppDelegate or early in the app lifecycle:
/// InterfaceOrientationManager.configure()
///
/// // In your SwiftUI views:
/// someView
///     .supportedInterfaceOrientations(.portrait)
/// ```
public final class InterfaceOrientationManager {
    private static let logger = Logger(
        subsystem: "com.swiftui.interface.orientation",
        category: String(describing: InterfaceOrientationManager.self)
    )

    private static var configuration: Configuration?

    /// The shared instance of the orientation manager.
    public static let shared = InterfaceOrientationManager()

    private let defaultOrientations: UIInterfaceOrientationMask
    private var orientations: [UUID: UIInterfaceOrientationMask] = [:]
    private var cancellables = Set<AnyCancellable>()

    /// The currently resolved interface orientations based on registered constraints.
    ///
    /// This property computes the intersection of all registered orientation masks.
    /// If the intersection is empty, it falls back to the default orientations.
    public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if orientations.isEmpty {
            return defaultOrientations
        }

        let resolved = orientations.values.reduce(defaultOrientations) { result, orientation in
            result.intersection(orientation)
        }

        Self.logger.debug("Resolved supported interface orientations: \(String(describing: resolved))")

        if resolved.isEmpty {
            Self.logger.warning("Empty orientation mask resolved, using defaultOrientations instead")
            return defaultOrientations
        } else {
            return resolved
        }
    }

    private init() {
        defaultOrientations = Self.configuration?.defaultOrientations ?? Self.loadOrientationsFromInfoPlist()
        setupOrientationChangeObserver()
        updateSupportedInterfaceOrientations()
    }

    // MARK: Public API

    /// Configures the orientation manager with the provided configuration.
    ///
    /// Call this method early in your app's lifecycle, preferably in the AppDelegate.
    ///
    /// - Parameter configuration: The configuration to use. Defaults to reading from Info.plist.
    public static func configure(configuration: Configuration = .fromInfoPlist()) {
        self.configuration = configuration
    }

    // MARK: Internal API

    /// Registers orientation constraints for a view.
    ///
    /// - Parameters:
    ///   - orientations: The allowed orientations for the view.
    ///   - id: A unique identifier for the view.
    func register(orientations: UIInterfaceOrientationMask, id: UUID) {
        assert(!orientations.isEmpty, "Using an empty orientation mask is not allowed")

        self.orientations[id] = orientations
        updateSupportedInterfaceOrientations()
    }

    /// Unregisters orientation constraints for a view.
    ///
    /// - Parameter id: The unique identifier of the view whose constraints should be removed.
    func unregister(orientationsWithID id: UUID) {
        orientations[id] = nil
        updateSupportedInterfaceOrientations()
    }

    // MARK: Private API

    private func updateSupportedInterfaceOrientations() {
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return Self.logger.error("No active window scene found")
            }

            windowScene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }

    private func setupOrientationChangeObserver() {
        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                self?.updateSupportedInterfaceOrientations()
            }
            .store(in: &cancellables)
    }

    private static func loadOrientationsFromInfoPlist() -> UIInterfaceOrientationMask {
        let plistOrientations = MainBundleInfo.supportedInterfaceOrientations

        if plistOrientations.isEmpty {
            Self.logger.warning("Default orientations not found in Info.plist, using .all")
            return .all
        } else {
            return plistOrientations
        }
    }
}

// MARK: - Configuration -

extension InterfaceOrientationManager {
    /// Configuration for the InterfaceOrientationManager.
    public struct Configuration {
        /// The default orientations to use when no specific constraints are registered.
        public let defaultOrientations: UIInterfaceOrientationMask

        /// Creates a new configuration with the specified default orientations.
        ///
        /// - Parameter defaultOrientations: The default orientations to use.
        public init(defaultOrientations: UIInterfaceOrientationMask) {
            self.defaultOrientations = defaultOrientations
        }

        /// Creates a configuration from the app's Info.plist settings.
        ///
        /// This reads the `UISupportedInterfaceOrientations` key from Info.plist.
        public static func fromInfoPlist() -> Configuration {
            Configuration(defaultOrientations: loadOrientationsFromInfoPlist())
        }
    }
}
