
import Foundation
public struct PlaybackPingMessage : Codable{
    let emittedAt: String
    let session: Session
    let events: [PingEvent]
    
    private enum CodingKeys : String, CodingKey {
        case emittedAt = "emitted_at", session, events
    }
}
