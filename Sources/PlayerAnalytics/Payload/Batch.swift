import Foundation

/// A struct representing a batch of events that are emitted by the player.
struct Batch: Codable {
    let sendAtInMs: Int64
    let sessionId: String
    let playbackId: String
    let mediaId: String
    let events: [Event]
    let version: String
    let referrer: String

    enum CodingKeys: String, CodingKey {
        case sendAtInMs = "sat"
        case sessionId = "sid"
        case playbackId = "pid"
        case mediaId = "mid"
        case events = "eve"
        case version = "ver"
        case referrer = "ref"
    }

    static func createNow(
        sessionId: String,
        playbackId: String,
        mediaId: String,
        events: [Event],
        version: String,
        referrer: String
    ) -> Batch {
        return Batch(
            sendAtInMs: TimeUtils.currentTimeInMs(),
            sessionId: sessionId,
            playbackId: playbackId,
            mediaId: mediaId,
            events: events,
            version: version,
            referrer: referrer
        )
    }
}
