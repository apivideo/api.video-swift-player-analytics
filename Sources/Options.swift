import Foundation

/// The analytics module constructor takes a Options parameter that contains the following options:
public struct Options {
    /// Information containing analytics collector url, video type (vod or live) and video id
    public var videoInfo: VideoInfo
    /// object containing metadata
    public var metadata = [[String: String]]()
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
        mediaUrl: String, metadata: [[String: String]], onSessionIdReceived: ((String) -> Void)? = nil,
        onPing: ((PlaybackPingMessage) -> Void)? = nil
    ) throws {
        self.init(
            videoInfo: try Options.parseMediaUrl(mediaUrl: mediaUrl),
            metadata: metadata,
            onSessionIdReceived: onSessionIdReceived,
            onPing: onPing
        )
    }

    /// Object option initializer
    /// - Parameters:
    ///   - videoInfo: Object that contains all video informations
    ///   - metadata: Object containing metadata
    ///   - onSessionIdReceived: Callback called once the session id has been received
    ///   - onPing: Callback called before sending the ping message
    public init(
        videoInfo: VideoInfo,
        metadata: [[String: String]],
        onSessionIdReceived: ((String) -> Void)? = nil,
        onPing: ((PlaybackPingMessage) -> Void)? = nil
    ) {
        self.videoInfo = videoInfo
        self.metadata = metadata
        self.onSessionIdReceived = onSessionIdReceived
        self.onPing = onPing
    }

    private static func parseMediaUrl(mediaUrl: String) throws -> VideoInfo {
        let pattern = "https:/.*[/](?<type>vod|live).*/(?<id>(vi|li)[^/^.]*)[/.].*"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        var videoType: VideoType!
        var videoId: String!

        if let match = regex?.firstMatch(in: mediaUrl, range: NSRange(location: 0, length: mediaUrl.utf16.count)) {
            if let videoTypeRange = Range(match.range(withName: "type"), in: mediaUrl) {
                videoType = try mediaUrl[videoTypeRange].description.toVideoType()
            } else {
                throw UrlError.malformedUrl("Can not parse media url")
            }

            if let videoIdRange = Range(match.range(withName: "id"), in: mediaUrl) {
                videoId = String(mediaUrl[videoIdRange])
            } else {
                throw UrlError.malformedUrl("Can not parse media url")
            }
        } else {
            throw UrlError.malformedUrl("Missing arguments in url")
        }

        return try VideoInfo(videoId: videoId, videoType: videoType)
    }
}
