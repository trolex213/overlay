import SwiftUI

struct BoundingBoxView: View {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        Rectangle()
            .stroke(Color.red, lineWidth: 8)
            .frame(width: width, height: height)
            .position(x: x + width/2, y: y + height/2)
    }
}
