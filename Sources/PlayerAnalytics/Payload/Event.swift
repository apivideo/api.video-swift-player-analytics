import Foundation

/// A struct representing an event that is emitted by the player.
struct Event: Codable {
    let emittedAtInMs: Int64
    let type: EventType
    let videoTimeInS: Float
    let videoWidth: Int
    let videoHeight: Int
    let paused: Bool
    let errorCode: ErrorCode

    enum CodingKeys: String, CodingKey {
        case emittedAtInMs = "eat"
        case type = "typ"
        case videoTimeInS = "vti"
        case videoWidth = "vwi"
        case videoHeight = "vhe"
        case paused = "pau"
        case errorCode = "eco"
    }

    enum EventType: Int, Codable {
        case loaded = 1
        case play = 2
        case pause = 3
        case timeUpdate = 4
        case error = 5
        case end = 6
        case seek = 7
        case src = 8
    }

    static func createNow(
        type: EventType,
        videoTimeInS: Float,
        videoWidth: Int,
        videoHeight: Int,
        paused: Bool,
        errorCode: ErrorCode
    ) -> Event {
        return Event(
            emittedAtInMs: TimeUtils.currentTimeInMs(),
            type: type,
            videoTimeInS: videoTimeInS,
            videoWidth: videoWidth,
            videoHeight: videoHeight,
            paused: paused,
            errorCode: errorCode
        )
    }
}

// MARK: Equatable

extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.isEqual(rhs)
    }

    func isEqual(_ other: Event) -> Bool {
        if type != other.type {
            return false
        }
        if paused != other.paused {
            return false
        }
        return true
    }
}
