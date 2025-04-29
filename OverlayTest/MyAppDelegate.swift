import SwiftUI

class MyAppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            let scale = screen.backingScaleFactor
            let pixelWidth = screenFrame.width * scale
            let pixelHeight = screenFrame.height * scale
            
            // 🔥 Print every important value
            print("========== SCREEN INFO ==========")
            print("Screen Frame (in points): width = \(screenFrame.width), height = \(screenFrame.height)")
            print("Backing Scale Factor: \(scale)")
            print("Screen Size (in pixels): width = \(pixelWidth), height = \(pixelHeight)")
            print("==================================")


            let screenSizeInPixels = NSRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight)

            window = NSWindow(
                contentRect: screenSizeInPixels,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            
            window.isOpaque = false
            window.backgroundColor = .clear
            window.ignoresMouseEvents = true
            window.sharingType = .none
            window.collectionBehavior = [.canJoinAllSpaces]
            
            let contentView = OverlayStuffView(
                screenWidth: pixelWidth,
                screenHeight: pixelHeight
            )
            window.contentView = NSHostingView(rootView: contentView)
            
            window.level = .statusBar
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
        } else {
            // fallback
            let fallbackScreen = NSRect(x: 0, y: 0, width: 3072, height: 1920)
            window = NSWindow(contentRect: fallbackScreen, styleMask: [.borderless], backing: .buffered, defer: false)
        }
    }

}
