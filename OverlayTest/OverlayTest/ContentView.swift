import SwiftUI

struct OverlayStuffView: View {
    @StateObject var websocketManager = WebSocketManager()
    var screenWidth: CGFloat
    var screenHeight: CGFloat

    var body: some View {
        ZStack {
            Color.black.opacity(0.01) // Light background for debugging

            if let box = websocketManager.boundingBoxes.first {
                BoundingBoxView(
                    x: box.x,
                    y: screenHeight - box.y - box.height, // Y flip
                    width: box.width,
                    height: box.height
                )
            }
        }
        .frame(width: screenWidth, height: screenHeight)
        .border(Color.blue) // Add border to see screen edges
        .onAppear {
            print("Screen size passed: \(screenWidth) x \(screenHeight)")
        }
    }
}
