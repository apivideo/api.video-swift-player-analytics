import Foundation

public struct PingEvent: Codable {
    let emittedAt: String
    let type: Event
    let at: Float?
    let from: Float?
    let to: Float?

    init(type: Event, at: Float?, from: Float?, to: Float?) {
        self.emittedAt = Date().preciseLocalTime
        self.type = type
        self.at = at
        self.from = from
        self.to = to
    }
}
