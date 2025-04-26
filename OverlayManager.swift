//
//  OverlayManager.swift
//  ScreenOverlay
//
//  Created by Troy Zhang  on 04/24/25.
//
//  📌 OVERVIEW:
//  The OverlayManager class is responsible for displaying temporary visual overlays on the user's screen.
//  It supports two core overlay types:
//    1. A verification overlay that displays a code (e.g., for onboarding or device pairing)
//    2. An annotated screenshot overlay that displays a screenshot with visual highlight boxes
//
//  Both overlays appear on top of all apps (even fullscreen), are frameless ("no chrome"), and customizable.
//  Overlays dismiss upon user interaction (click or key press).
//
//  ✨ Features:
//  - Always-on-top, borderless, transparent overlays
//  - Click-to-dismiss
//  - Annotated image overlays with red highlight boxes
//  - Watermark label on annotation overlays
//  - Captures full-screen image using CoreGraphics
//

import Cocoa

class OverlayManager: NSObject {

    // The window used for the overlay display (verification or annotation).
    private var overlayWindow: OverlayWindow?

    // Reference to an event monitor (e.g., to allow dismissing overlays on click or key press).
    private var eventMonitor: Any?
    
    // Stores the most recently shown screenshot
    private var lastScreenshot: NSImage?
    
    // Stores the completion handler for verification overlay
    private var verificationCompletion: ((Bool) -> Void)?
    
    // MARK: - Initialization and Cleanup
    
    deinit {
        // Ensure everything is cleaned up when this object is deallocated
        hideOverlay()
    }
    
    // MARK: - Verification Overlay

    // Displays a small code box overlay (bottom-left corner) for onboarding/verification use cases.
    //
    // - Parameters:
    //   - code: A string to show the user (e.g., "123456")
    //   - completion: Callback triggered after dismissal (auto or manual)
    func showVerificationOverlay(code: String, completion: @escaping (Bool) -> Void) {
        // Clean up any existing overlay first
        hideOverlay()
        
        // Store the completion handler
        verificationCompletion = completion
        
        // Get the dimensions of the main screen
        guard let mainScreen = NSScreen.main else {
            completion(false)
            return
        }

        // Create a transparent, always-on-top overlay window
        overlayWindow = OverlayWindow(
            contentRect: mainScreen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        // Create a transparent view to fill the screen
        let overlayView = NSView(frame: mainScreen.frame)
        overlayView.wantsLayer = true
        overlayView.layer?.backgroundColor = NSColor.clear.cgColor

        // Create a styled container to hold the verification code
        let codeContainer = NSView(frame: NSRect(x: 16, y: 16, width: 200, height: 40))
        codeContainer.wantsLayer = true
        codeContainer.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        codeContainer.layer?.cornerRadius = 8

        // Create the verification code label
        let codeLabel = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 40))
        codeLabel.stringValue = "Code: \(code)"
        codeLabel.alignment = .center
        codeLabel.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        codeLabel.textColor = NSColor.white
        codeLabel.isBezeled = false
        codeLabel.isEditable = false
        codeLabel.drawsBackground = false

        // Nest the label inside the container, then add to overlay view
        codeContainer.addSubview(codeLabel)
        overlayView.addSubview(codeContainer)
        
        // Add a dismiss button for testing
        let dismissButton = NSButton(frame: NSRect(x: 16, y: 70, width: 200, height: 30))
        dismissButton.title = "Dismiss Overlay"
        dismissButton.bezelStyle = .rounded
        dismissButton.target = self
        dismissButton.action = #selector(dismissButtonClicked)
        overlayView.addSubview(dismissButton)

        // Set overlay view as window content
        overlayWindow?.contentView = overlayView

        // Allow interaction for this overlay (e.g., if you wanted to tap/click later)
        overlayWindow?.ignoresMouseEvents = true

        // Show the window above all other apps
        overlayWindow?.makeKeyAndOrderFront(nil)
        
        // Add an event listener to dismiss the overlay on click or key press
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .keyDown]) { [weak self] event in
            guard let self = self else { return event }
            self.completeVerification(true)
            return event
        }
    }
    
    // Helper method to dismiss the overlay when button is clicked
    @objc func dismissButtonClicked() {
        completeVerification(true)
    }
    
    // Helper method to complete verification and avoid duplicate calls
    private func completeVerification(_ success: Bool) {
        // Get reference to completion handler before cleaning up
        let completion = verificationCompletion
        
        // Clean up resources
        hideOverlay()
        
        // Call completion if it exists (only once)
        if let completion = completion {
            // Clear stored reference to prevent multiple calls
            verificationCompletion = nil
            
            // Call on main thread to be safe
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }

    // MARK: - Annotated Screenshot Overlay

    // Displays a full-screen image (e.g., a screenshot) with optional red highlight boxes and a watermark.
    //
    // - Parameters:
    //   - image: The screenshot to display
    //   - boxes: An optional list of highlight rectangles (each as a dictionary with "x", "y", "width", "height")
    func showAnnotationOverlay(image: NSImage, boxes: [[String: CGFloat]] = []) {
        // Remove any existing overlay first
        hideOverlay()
        
        // Save the current screenshot.
        lastScreenshot = image
        
        // Fetches the main display size, so the overlay fills the whole screen.
        guard let mainScreen = NSScreen.main else { return }

        // Create a transparent, top-level window
        overlayWindow = OverlayWindow(
            contentRect: mainScreen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        // Create the main container view
        let overlayView = NSView(frame: mainScreen.frame)

        // Add the screenshot image to fill the screen
        let imageView = NSImageView(frame: mainScreen.frame) // NSImageView is like <img> in HTML
        imageView.image = image
        imageView.imageScaling = .scaleProportionallyUpOrDown // fit-to-screen without distorting aspect ratio
        overlayView.addSubview(imageView)

        // Draw each highlight box (as a red-bordered view) on top of the image
        // Note to self: in macOS coordinate space, (0,0) is at the bottom left of the screen, not the middle
        for box in boxes {
            if let x = box["x"], let y = box["y"], let width = box["width"], let height = box["height"] {
                let boxView = NSView(frame: NSRect(x: x, y: y, width: width, height: height))
                boxView.wantsLayer = true
                boxView.layer?.borderWidth = 5
                boxView.layer?.borderColor = NSColor.red.cgColor
                overlayView.addSubview(boxView)
            }
        }

        // Add a watermark label in the bottom-left corner
        let watermark = NSTextField(frame: NSRect(x: 16, y: 16, width: 200, height: 30))
        watermark.stringValue = "JARVIS"
        watermark.alignment = .left
        watermark.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        watermark.textColor = NSColor.white
        watermark.isBezeled = false
        watermark.isEditable = false
        watermark.drawsBackground = false
        watermark.wantsLayer = true
        watermark.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        watermark.layer?.cornerRadius = 8

        // Add left padding using paragraph style
        let paddingStyle = NSMutableParagraphStyle()
        paddingStyle.paragraphSpacing = 5
        paddingStyle.headIndent = 5
        paddingStyle.firstLineHeadIndent = 5
        watermark.attributedStringValue = NSAttributedString(
            string: "JARVIS",
            attributes: [.paragraphStyle: paddingStyle]
        )
        
        // Add a dismiss button for testing
        let dismissButton = NSButton(frame: NSRect(x: 16, y: 60, width: 200, height: 30))
        dismissButton.title = "Dismiss Overlay"
        dismissButton.bezelStyle = .rounded
        dismissButton.target = self
        dismissButton.action = #selector(dismissButtonClicked)

        overlayView.addSubview(watermark)
        overlayView.addSubview(dismissButton)

        // Assign the overlay content
        overlayWindow?.contentView = overlayView

        // Allow click/key interaction (so user can dismiss)
        overlayWindow?.ignoresMouseEvents = false

        // Show overlay above everything
        overlayWindow?.makeKeyAndOrderFront(nil)

        // Add an event listener to dismiss the overlay on click or key press
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .keyDown]) { [weak self] event in
            self?.hideOverlay()
            return event
        }
    }

    // MARK: - Overlay Cleanup

    // Hides the overlay window, invalidates the timer, and removes event monitors.
    func hideOverlay() {
        // Remove event monitor if active
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }

        // Close and release the overlay window
        overlayWindow?.close()
        overlayWindow = nil
    }

    // MARK: - Screen Capture

    // Captures the current screen as an NSImage using CoreGraphics.
    //
    // - Returns: A screenshot image, or nil if it fails (e.g., screen recording permissions denied)
    func captureScreen() -> NSImage? {
        let mainDisplay = CGMainDisplayID()

        guard let cgImage = CGDisplayCreateImage(mainDisplay) else { return nil }

        let image = NSImage(
            cgImage: cgImage,
            size: NSSize(width: CGFloat(cgImage.width), height: CGFloat(cgImage.height))
        )

        // Store the screenshot so it can be reused later
        lastScreenshot = image

        return image
    }
    
    // Returns the most recently shown screenshot (if available)
    func getLastScreenshot() -> NSImage? {
        return lastScreenshot
    }
}
