import OSLog
import UIKit

/// A centralized manager for controlling interface orientation constraints in SwiftUI apps.
///
/// `InterfaceOrientationManager` provides a registry-based system for managing which interface
/// orientations are supported at any given time. Views register their orientation constraints
/// when they appear and unregister when they disappear. The manager computes the intersection
/// of all active constraints to determine the currently supported orientations.
///
/// To integrate with iOS, your app must wire the manager to the system by implementing
/// `application(_:supportedInterfaceOrientationsFor:)` in your `AppDelegate`:
///
/// ```swift
/// @main
/// class AppDelegate: UIResponder, UIApplicationDelegate {
///     func application(
///         _ application: UIApplication,
///         supportedInterfaceOrientationsFor window: UIWindow?
///     ) -> UIInterfaceOrientationMask {
///         InterfaceOrientationManager.shared.supportedInterfaceOrientations
///     }
/// }
/// ```
///
/// Then use the ``SwiftUI/View/supportedInterfaceOrientations(_:)`` modifier on your views:
///
/// ```swift
/// struct VideoPlayerView: View {
///     var body: some View {
///         VideoPlayer(player: player)
///             .supportedInterfaceOrientations(.landscape)
///     }
/// }
/// ```
///
/// The manager reads default orientations from your app's `Info.plist` under the
/// `UISupportedInterfaceOrientations` key, or you can provide a custom configuration
/// using ``configure(configuration:)``.
///
/// - Note: Call ``configure(configuration:)`` before accessing ``shared`` if you need
///   custom default orientations.
@MainActor
public final class InterfaceOrientationManager {
    nonisolated private static let logger = Logger(
        subsystem: "com.swiftui.interface.orientation",
        category: String(describing: InterfaceOrientationManager.self)
    )

    private static var configuration: Configuration?
    private static var isInitialized = false

    /// The shared singleton instance of the orientation manager.
    ///
    /// Access this property to get the manager instance that coordinates orientation
    /// constraints across your app. The instance is lazily initialized on first access.
    ///
    /// ```swift
    /// let currentOrientations = InterfaceOrientationManager.shared.supportedInterfaceOrientations
    /// ```
    ///
    /// - Important: If you need custom default orientations, call ``configure(configuration:)``
    ///   before first accessing this property.
    public static let shared = InterfaceOrientationManager()

    private let defaultOrientations: UIInterfaceOrientationMask
    private var orientations: [UUID: UIInterfaceOrientationMask] = [:]
    private var orientationObserver: (any NSObjectProtocol)?
    private var lastResolvedMask: UIInterfaceOrientationMask?

    /// The currently resolved interface orientations based on all registered constraints.
    ///
    /// This computed property returns the intersection of all orientation masks registered
    /// by active views. The resolution algorithm works as follows:
    ///
    /// 1. If no constraints are registered, returns the default orientations from
    ///    ``Configuration`` or `Info.plist`.
    /// 2. Otherwise, computes the intersection of all registered masks with the defaults.
    /// 3. If the intersection is empty (conflicting constraints), falls back to defaults.
    ///
    /// Return this value from your `AppDelegate`'s
    /// `application(_:supportedInterfaceOrientationsFor:)` method:
    ///
    /// ```swift
    /// func application(
    ///     _ application: UIApplication,
    ///     supportedInterfaceOrientationsFor window: UIWindow?
    /// ) -> UIInterfaceOrientationMask {
    ///     InterfaceOrientationManager.shared.supportedInterfaceOrientations
    /// }
    /// ```
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
        Self.isInitialized = true
        defaultOrientations = Self.configuration?.defaultOrientations ?? Self.loadOrientationsFromInfoPlist()
        lastResolvedMask = defaultOrientations
        setupOrientationChangeObserver()
        updateSupportedInterfaceOrientations()
    }

    // MARK: Public API

    /// Configures the orientation manager with custom settings before initialization.
    ///
    /// Call this method early in your app's lifecycle, before first accessing ``shared``.
    /// This is typically done in your `AppDelegate`'s `application(_:didFinishLaunchingWithOptions:)`:
    ///
    /// ```swift
    /// func application(
    ///     _ application: UIApplication,
    ///     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    /// ) -> Bool {
    ///     InterfaceOrientationManager.configure(
    ///         configuration: .init(defaultOrientations: .portrait)
    ///     )
    ///     return true
    /// }
    /// ```
    ///
    /// If not called, the manager automatically reads default orientations from your app's
    /// `Info.plist` under the `UISupportedInterfaceOrientations` key.
    ///
    /// - Parameter configuration: The configuration specifying default orientations.
    ///   Defaults to ``Configuration/fromInfoPlist()``.
    public static func configure(configuration: Configuration = .fromInfoPlist()) {
        assert(!isInitialized, "configure() must be called before accessing InterfaceOrientationManager.shared")
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
        updateSupportedInterfaceOrientationsIfNeeded()
    }

    /// Unregisters orientation constraints for a view.
    ///
    /// - Parameter id: The unique identifier of the view whose constraints should be removed.
    func unregister(orientationsWithID id: UUID) {
        orientations[id] = nil
        updateSupportedInterfaceOrientationsIfNeeded()
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

    private func handleOrientationChange() {
        guard !orientations.isEmpty else {
            return
        }
        updateSupportedInterfaceOrientations()
    }

    private func updateSupportedInterfaceOrientationsIfNeeded() {
        let currentMask = supportedInterfaceOrientations
        guard currentMask != lastResolvedMask else {
            return
        }

        lastResolvedMask = currentMask
        Self.logger.debug("Supported orientations changed: \(currentMask.rawValue)")

        updateSupportedInterfaceOrientations()
    }

    private func setupOrientationChangeObserver() {
        orientationObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleOrientationChange()
            }
        }
    }

    nonisolated private static func loadOrientationsFromInfoPlist() -> UIInterfaceOrientationMask {
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
    /// Configuration options for customizing the orientation manager's behavior.
    ///
    /// Use this struct to specify custom default orientations instead of reading from
    /// `Info.plist`. Pass the configuration to ``InterfaceOrientationManager/configure(configuration:)``
    /// before the manager is first accessed.
    ///
    /// ```swift
    /// // Use portrait as default, allow views to override
    /// InterfaceOrientationManager.configure(
    ///     configuration: Configuration(defaultOrientations: .portrait)
    /// )
    ///
    /// // Or use Info.plist values (the default behavior)
    /// InterfaceOrientationManager.configure(
    ///     configuration: .fromInfoPlist()
    /// )
    /// ```
    public struct Configuration {
        /// The default interface orientations when no view constraints are active.
        ///
        /// These orientations are used as the base mask for computing supported orientations.
        /// When views register constraints via ``SwiftUI/View/supportedInterfaceOrientations(_:)``,
        /// the manager computes the intersection of those constraints with this default mask.
        ///
        /// Common values include:
        /// - `.all` - Allow all orientations
        /// - `.portrait` - Portrait only
        /// - `.landscape` - Landscape left and right
        /// - `.allButUpsideDown` - All except portrait upside down (recommended for iPhone)
        public let defaultOrientations: UIInterfaceOrientationMask

        /// Creates a configuration with the specified default orientations.
        ///
        /// ```swift
        /// let config = Configuration(defaultOrientations: .portrait)
        /// InterfaceOrientationManager.configure(configuration: config)
        /// ```
        ///
        /// - Parameter defaultOrientations: The orientation mask to use when no view
        ///   constraints are registered, or as the base for intersection calculations.
        public init(defaultOrientations: UIInterfaceOrientationMask) {
            self.defaultOrientations = defaultOrientations
        }

        /// Creates a configuration using orientations defined in the app's Info.plist.
        ///
        /// This factory method reads the `UISupportedInterfaceOrientations` key from your
        /// app's `Info.plist` file and converts the string values to a `UIInterfaceOrientationMask`.
        ///
        /// ```swift
        /// // Explicitly use Info.plist values
        /// InterfaceOrientationManager.configure(configuration: .fromInfoPlist())
        /// ```
        ///
        /// - Returns: A configuration with default orientations from Info.plist, or `.all`
        ///   if the plist key is missing or empty.
        public static func fromInfoPlist() -> Configuration {
            Configuration(defaultOrientations: loadOrientationsFromInfoPlist())
        }
    }
}
