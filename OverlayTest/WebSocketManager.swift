import Foundation
import Starscream
import SwiftUI

class WebSocketManager: ObservableObject, WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket connected: \(headers)")
        case .disconnected(let reason, let code):
            print("WebSocket disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            handleMessage(string)
        case .binary(let data):
            print("Received binary data: \(data.count) bytes")
        case .error(let error):
            print("WebSocket error: \(error?.localizedDescription ?? "Unknown error")")
        default:
            break
        }
    }

    
    
    private var socket: WebSocket?
    @Published var boundingBoxes: [BoundingBox] = []

    init() {
        var request = URLRequest(url: URL(string: "ws://localhost:8000/ws")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    private func handleMessage(_ text: String) {
        print("Running handleMessage")
        guard let data = text.data(using: .utf8) else { return }
        do {
            let decoded = try JSONDecoder().decode(BoundingBoxResponse.self, from: data)
            
            let boxes = decoded.bboxes.map { (key, value) in
                let x1 = CGFloat(value[0])
                let y1 = CGFloat(value[1])
                let x2 = CGFloat(value[2])
                let y2 = CGFloat(value[3])
                
                let width = x2 - x1
                let height = y2 - y1
                
                return BoundingBox(
                    id: key,
                    x: x1,
                    y: y1,
                    width: width,
                    height: height
                )
            }

            DispatchQueue.main.async {
                self.boundingBoxes = boxes
                print("✅ Bounding Boxes Updated:")
                for box in boxes {
                    print("ID: \(box.id) | x: \(box.x) | y: \(box.y) | width: \(box.width) | height: \(box.height)")
                }
            }
        } catch {
            print("Failed to decode JSON: \(error)")
        }
    }
}

struct BoundingBox: Identifiable {
    let id: String
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
}

struct BoundingBoxResponse: Codable {
    let bboxes: [String: [Int]]
}
