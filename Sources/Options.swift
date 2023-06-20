import Foundation

/// The analytics module constructor takes a Options parameter that contains the following options:
public struct Options {
    /// Information containing analytics collector url, video type (vod or live) and video id
    public var videoInfo: VideoInfo
    /// object containing metadata
    public var metadata: [String: String]
    /// Callback called once the session id has been received
    public let onSessionIdReceived: ((String) -> Void)?
    /// Callback called before sending the ping message
    public let onPing: ((PlaybackPingMessage) -> Void)?

    /// Object option initializer
    /// - Parameters:
    ///   - mediaUrl: Url of the media
    ///   - metadata: object containing metadata
    ///   - onSessionIdReceived: Callback called once the session id has been received
    ///   - onPing: Callback called before sending the ping message
    public init(
        mediaUrl: URL,
        metadata: [String: String] = [:],
        onSessionIdReceived: ((String) -> Void)? = nil,
        onPing: ((PlaybackPingMessage) -> Void)? = nil
    ) throws {
        self.init(
            videoInfo: try VideoInfo.from(mediaUrl),
            metadata: metadata,
            onSessionIdReceived: onSessionIdReceived,
            onPing: onPing
        )
    }

    /// Object option initializer
    /// - Parameters:
    ///   - mediaUrl: Url of the media
    ///   - metadata: object containing metadata
    ///   - onSessionIdReceived: Callback called once the session id has been received
    ///   - onPing: Callback called before sending the ping message
    public init(
        mediaUrl: String,
        metadata: [String: String] = [:],
        onSessionIdReceived: ((String) -> Void)? = nil,
        onPing: ((PlaybackPingMessage) -> Void)? = nil
    ) throws {
        try self.init(
            mediaUrl: URL(string: mediaUrl)!,
            metadata: metadata,
            onSessionIdReceived: onSessionIdReceived,
            onPing: onPing
        )
    }

    /// Object option initializer.
    /// For custom collector domain, use this constructor.
    /// - Parameters:
    ///   - videoInfo: Object that contains all video informations
    ///   - metadata: Object containing metadata
    ///   - onSessionIdReceived: Callback called once the session id has been received
    ///   - onPing: Callback called before sending the ping message
    public init(
        videoInfo: VideoInfo,
        metadata: [String: String] = [:],
        onSessionIdReceived: ((String) -> Void)? = nil,
        onPing: ((PlaybackPingMessage) -> Void)? = nil
    ) {
        self.videoInfo = videoInfo
        self.metadata = metadata
        self.onSessionIdReceived = onSessionIdReceived
        self.onPing = onPing
    }
}
