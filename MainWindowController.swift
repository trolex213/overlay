// In MainWindowController.swift

import Cocoa

class MainWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Set a proper title for the window
        window?.title = "Screen Overlay"
        
        // Ensure the window is visible and brought to front
        window?.makeKeyAndOrderFront(nil)
    }
}
