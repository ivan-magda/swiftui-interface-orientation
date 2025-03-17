import SwiftUI

extension View {
    /// Restricts the interface orientations for this view.
    ///
    /// Use this modifier to specify which orientations are allowed when this view is active.
    /// When the view appears, it registers these constraints with the `InterfaceOrientationManager`.
    /// When the view disappears, the constraints are automatically removed.
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
    ///                         .supportedInterfaceOrientations([.landscapeLeft, .landscapeRight])
    ///                 }
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter orientations: The interface orientations to allow for this view.
    ///   Pass `nil` to remove any constraints.
    /// - Returns: A view with the specified orientation constraints.
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
