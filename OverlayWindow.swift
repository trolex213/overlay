//
//  OverlayWindow.swift
//  ScreenOverlay
//
//  Created by Tony Zhang on 4/23/25.
//

import Cocoa

// A custom transparent, always-on-top, click-through window designed for visual overlays.
// This window is frameless, appears on all Spaces (including fullscreen apps), and does not block user interaction.
class OverlayWindow: NSWindow {

    // Initializes the overlay window with a predefined configuration for overlays.
    override init(contentRect: NSRect,
                  styleMask style: NSWindow.StyleMask,
                  backing backingStoreType: NSWindow.BackingStoreType,
                  defer flag: Bool) {

        // Call the NSWindow superclass initializer with custom style and backing
        super.init(contentRect: contentRect,
                   styleMask: .borderless,       // No title bar, buttons, or window frame
                   backing: .buffered,           // Standard double-buffered drawing
                   defer: false)                 // Do not defer window creation

        // 🟦 Visual appearance settings

        // Make the background fully transparent
        self.backgroundColor = NSColor.clear
        
        // Tell macOS that this window is not opaque so transparency works
        self.isOpaque = false

        // Remove the default shadow so the window doesn't visually "pop"
        self.hasShadow = false

        // 🟥 Window level settings

        // Set the window level high enough to stay above most standard app windows
        // popUpMenu level is a safe choice; you can go even higher if needed (like .screenSaver)
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        
        
        // 🟩 Space behavior settings

        // Allow the overlay to appear across all virtual desktops (Spaces)
        // and allow it to float above fullscreen apps like videos or presentations
        self.collectionBehavior = [
            .canJoinAllSpaces,         // Shows on all Spaces (desktops)
            .fullScreenAuxiliary       // Stays above fullscreen apps
        ]

        // 🟨 Interaction settings

        // Makes the window click-through: all mouse events pass through to windows behind it
        // This ensures it doesn't interfere with normal user interaction
        self.ignoresMouseEvents = false
    }
    
    // Allow this window to become the key window
    // This fixes the warning: -[NSWindow makeKeyWindow] called on ScreenOverlay.OverlayWindow which returned NO from -[NSWindow canBecomeKeyWindow]
    override var canBecomeKey: Bool {
        return true
    }
}
