import Foundation

public struct Session: Codable {
    let sessionId: String?
    let loadedAt: String
    let videoId: String?
    let livestreamId: String?
    let referrer: String
    let metadata: [Metadata]

    public static func buildLiveStreamSession(
        sessionId: String?, loadedAt: String, livestreamId: String, referrer: String,
        metadata: [String: String]
    ) -> Session {
        return Session(
            sessionId: sessionId, loadedAt: loadedAt, videoId: nil, livestreamId: livestreamId,
            referrer: referrer, metadata: metadata.toMetadata()
        )
    }

    public static func buildVideoSession(
        sessionId: String?, loadedAt: String, videoId: String, referrer: String,
        metadata: [String: String]
    ) -> Session {
        return Session(
            sessionId: sessionId, loadedAt: loadedAt, videoId: videoId, livestreamId: nil,
            referrer: referrer, metadata: metadata.toMetadata()
        )
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case loadedAt = "loaded_at"
        case videoId = "video_id"
        case livestreamId = "live_stream_id"
        case referrer, metadata
    }
}

/// This type is to simplify JSON serialization of dictionnary
public struct Metadata: Codable {
    let key: String
    let value: String

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        try container.encode(value, forKey: StringCodingKey(key))
    }
}

struct StringCodingKey: CodingKey {
    var stringValue: String
    init(stringValue: String) { self.stringValue = stringValue }
    init(_ stringValue: String) { self.init(stringValue: stringValue) }
    var intValue: Int?
    init?(intValue _: Int) { return nil }
}

extension Dictionary where Key == String, Value == String {
    func toMetadata() -> [Metadata] {
        self.map { key, value in Metadata(key: key, value: value) }
    }
}
