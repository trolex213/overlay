import SwiftUI

@main
struct OverlayTestApp: App {
    @NSApplicationDelegateAdaptor(MyAppDelegate.self) var appDelegate

    var body: some Scene {
        // No WindowGroup at all
        Settings {
            EmptyView()
        }
    }
}
