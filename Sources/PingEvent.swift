import Foundation

public struct PingEvent: Codable {
    let emittedAt: String
    let type: Event
    let at: Float?
    let from: Float?
    let to: Float?

    private enum CodingKeys: String, CodingKey {
        case emittedAt = "emitted_at"
        case type, at, from, to
    }
}
