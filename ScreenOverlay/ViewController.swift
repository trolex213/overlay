//
//  ViewController.swift
//  ScreenOverlay
//
//  Created by Tony Zhang on 4/23/25.
//

import Cocoa  // Import macOS user interface framework (AppKit), required for building UI

// This class controls the main window’s content, including the text field and button
class ViewController: NSViewController {

    // MARK: - Outlets (linked to UI in Interface Builder)

    // MARK: - Outlets

    // This is an IBOutlet — a reference to a UI element in your .xib or storyboard file.
    // It connects the NSTextField (where the user types their instruction or prompt) to this code file.
    // Example user input: "How do I upload a file?" or "Open Settings"
    @IBOutlet weak var promptTextField: NSTextField!

    // This IBOutlet is connected to the Capture button in your UI.
    // When the user clicks it, it will trigger a function (see @IBAction below).
    // This button is what initiates the screenshot and annotation overlay.
    @IBOutlet weak var captureButton: NSButton!

    
    
    // MARK: - Lifecycle

    /// This function is called **once**, automatically, when the view controller’s UI is loaded into memory.
    /// Think of this as the place to set up anything that should happen **when the screen is first shown**.
    /// You might use it to:
    /// - Pre-fill the text field
    /// - Change button styles
    /// - Register observers
    /// - Print debug logs
    override func viewDidLoad() {
        super.viewDidLoad()  // Always call super.viewDidLoad() to ensure the parent class’s logic runs

        // 🔧 Optional setup area:
        // Example: promptTextField.stringValue = "What do you want to do?"
        // Example: captureButton.isEnabled = true
    }

    
    // MARK: - Button Action

    // Triggered when the user clicks the "Capture" button
    @IBAction func captureButtonClicked(_ sender: Any) {
        // Step 1: Get the user’s input from the text field
        let prompt = promptTextField.stringValue  // Extract the typed text as a Swift String
        
        // Step 2: Check if the prompt is empty (i.e., user didn’t type anything)
        if prompt.isEmpty {
            // Create a warning alert to inform the user that the prompt is requireds
            let alert = NSAlert()
            alert.messageText = "Empty Prompt"  // Main title of the alert
            alert.informativeText = "Please enter a prompt for annotation."  // Additional explanation
            alert.alertStyle = .warning  // Show a yellow triangle warning style
            alert.addButton(withTitle: "OK")  // Add a button the user can click to dismiss the alert
            alert.runModal()  // Display the alert and pause until user responds
            return  // Exit the function so no screenshot is taken
        }
        
        // Step 3: Hide this window temporarily so it doesn’t show up in the screenshot
        view.window?.orderOut(nil)  // This removes the window from the screen (without closing it)
        
        // Step 4: Wait briefly to ensure the window is fully hidden before taking the screenshot
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Step 5: Ask the AppDelegate to take a screenshot and display the overlay
            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                appDelegate.captureAndAnnotate(prompt: prompt)  // This shows the overlay based on the prompt
            }
            
            // Step 6: After the overlay is shown, bring the window that we hid from Step 3 back after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Make this window the primary window and visible again
                self.view.window?.makeKeyAndOrderFront(nil)
            }
        }
    }
}
