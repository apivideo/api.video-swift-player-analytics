import Foundation

public struct PlaybackPingMessage: Codable {
    let emittedAt: String
    let session: Session
    let events: [PingEvent]
}
