import SwiftUI

extension View {
    /// Restricts the supported interface orientations while this view is visible.
    ///
    /// Use this modifier to constrain which device orientations are allowed when your view
    /// is on screen. The constraints are registered with ``InterfaceOrientationManager`` when
    /// the view appears and automatically removed when it disappears.
    ///
    /// When multiple views with orientation constraints are visible simultaneously, the
    /// manager computes the intersection of all constraints. If no common orientations exist,
    /// the default orientations are used instead.
    ///
    /// ```swift
    /// struct ContentView: View {
    ///     var body: some View {
    ///         NavigationView {
    ///             List {
    ///                 NavigationLink("Portrait-only view") {
    ///                     Text("This view is portrait only")
    ///                         .supportedInterfaceOrientations(.portrait)
    ///                 }
    ///
    ///                 NavigationLink("Landscape-only view") {
    ///                     Text("This view is landscape only")
    ///                         .supportedInterfaceOrientations(.landscape)
    ///                 }
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// For video players or media that benefits from landscape orientation:
    ///
    /// ```swift
    /// struct VideoDetailView: View {
    ///     var body: some View {
    ///         VideoPlayer(player: player)
    ///             .supportedInterfaceOrientations(.landscape)
    ///     }
    /// }
    /// ```
    ///
    /// To allow all orientations except upside down (common for iPhone apps):
    ///
    /// ```swift
    /// MyContentView()
    ///     .supportedInterfaceOrientations(.allButUpsideDown)
    /// ```
    ///
    /// - Parameter orientations: The interface orientations to allow for this view.
    ///   Pass `nil` or an empty mask to remove constraints and allow the default orientations.
    /// - Returns: A view that registers the specified orientation constraints with
    ///   ``InterfaceOrientationManager`` for its lifetime.
    public func supportedInterfaceOrientations(_ orientations: UIInterfaceOrientationMask?) -> some View {
        modifier(InterfaceOrientationsViewModifier(orientations: orientations ?? []))
    }
}

/// A view modifier that manages interface orientation constraints for a view.
private struct InterfaceOrientationsViewModifier: ViewModifier {
    let orientations: UIInterfaceOrientationMask

    @State private var id = UUID()

    func body(content: Content) -> some View {
        content
            .onAppear {
                if !orientations.isEmpty {
                    InterfaceOrientationManager.shared.register(orientations: orientations, id: id)
                }
            }
            .onDisappear {
                InterfaceOrientationManager.shared.unregister(orientationsWithID: id)
            }
            .onChange(of: orientations) { newValue in
                if orientations.isEmpty {
                    InterfaceOrientationManager.shared.unregister(orientationsWithID: id)
                } else {
                    InterfaceOrientationManager.shared.register(orientations: newValue, id: id)
                }
            }
    }
}
