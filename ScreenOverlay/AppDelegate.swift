//
//  AppDelegate.swift
//  ScreenOverlay
//
//  Created by Tony Zhang on 4/23/25.
//  Think of this as like the "manager" of your app. it basically tells our computer "whatever task you want
//  done, i'll take care of it"

import Cocoa

// The @main attribute tells Swift that this is the entry point of the app.
// when you launch your app, Swift looks for this class to start the app.
// AppDelegate conforms to NSApplicationDelegate, which defines key app lifecycle events.
@main
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties

    // OverlayManager controls all overlay functionality — verification codes, screenshot highlights, etc.
    private var overlayManager: OverlayManager?
    
    // Store a reference to the main window controller to prevent it from being deallocated
    private var mainWindowController: MainWindowController?

    // Boolean flag used to check whether this is the first launch of the application.
    // In this implementation, it only lives for the current session — not persisted across launches.
    private var isFirstLaunch = true

    // MARK: - App Lifecycle

    // Called automatically when the app has finished launching and is ready to run.
    // This is where you initialize core services and perform startup logic.
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Ensure the app is active before showing windows
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        // Initialize the overlay system
        overlayManager = OverlayManager()
        
        // Create and store the main window controller
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let windowController = storyboard.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier("MainWindowController")
        ) as? MainWindowController {
            print("🟢 Successfully cast to MainWindowController")
            self.mainWindowController = windowController
            self.mainWindowController?.showWindow(nil)
        } else {
            print("❌ Failed to cast to MainWindowController")
        }
        
        // If this is the first time the app is launching in this session
        if isFirstLaunch {
            // Generate a random 6-digit string to simulate a verification code
            let verificationCode = String(Int.random(in: 100000...999999))
            
            // Show the verification overlay using OverlayManager
            // It will display the code in a floating overlay at the bottom-left
            // The completion handler is called after 5 seconds or a user click
            overlayManager?.showVerificationOverlay(code: verificationCode) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    // Verification overlay timed out or was closed successfully
                    print("✅ Verification successful!")

                    // Mark that verification is no longer needed for this session
                    self.isFirstLaunch = false
                    
                    // Make sure the main window is visible and in front
                    DispatchQueue.main.async {
                        self.overlayManager?.hideOverlay()
                        
                        guard let controller = self.mainWindowController else {
                            print("❌ controller is nil")
                            return
                        }

                        print("🧪 Calling showWindow")
                        controller.showWindow(nil)

                        if let window = controller.window {
                            print("🧪 Calling makeKeyAndOrderFront on window: \(window)")
                            window.makeKeyAndOrderFront(nil)
                        } else {
                            print("❌ controller.window is nil")
                        }
                    }
                } else {
                    // Verification failed or was dismissed manually
                    print("❌ Verification failed or was cancelled")

                    // Exit the app entirely if the user didn't complete verification
                    NSApplication.shared.terminate(nil)
                }
            }
        }
    }

    // Called just before the app quits (e.g., user hits Cmd+Q or system shutdown).
    // Use this to clean up background tasks, timers, or save final state.
    func applicationWillTerminate(_ aNotification: Notification) {
        // Clean up the overlay manager
        overlayManager?.hideOverlay()
        overlayManager = nil
    }

    // Tells the system that your app supports restoring UI state securely
    // when relaunching after being quit — for privacy/security-aware apps.
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    // MARK: - Public Method to Trigger Annotated Help

    // Called externally (e.g., from a ViewController or voice agent) when a user asks for help.
    // This method captures the screen, optionally analyzes it, and displays an overlay with highlights.
    //
    // - Parameter prompt: The natural language instruction or request from the user
    func captureAndAnnotate(prompt: String) {
        // Step 1: Take a full-screen screenshot
        guard let screenshot = overlayManager?.captureScreen() else {
            // If capturing fails (e.g., screen recording permissions not granted), log an error
            print("❌ Failed to capture screen")
            return
        }
        
        // Step 2: For now, create a fake red highlight box centered on the screen.
        // In the future, this would come from a Planner Agent analyzing the prompt and UI.
        let screenWidth = screenshot.size.width
        let screenHeight = screenshot.size.height
        
        // Define one centered rectangle box covering 50% of the screen
        let boxes: [[String: CGFloat]] = [
            [
                "x": screenWidth * 0.25,     // 25% from the left
                "y": screenHeight * 0.25,    // 25% from the bottom
                "width": screenWidth * 0.5,  // 50% of screen width
                "height": screenHeight * 0.5 // 50% of screen height
            ]
        ]
        
        // Step 3: Use the overlay manager to display the screenshot and highlights
        overlayManager?.showAnnotationOverlay(image: screenshot, boxes: boxes)
        
        // Log the interaction — useful for debugging or observing Planner behavior
        print("🔍 Showing annotation for prompt: \(prompt)")
    }
}
