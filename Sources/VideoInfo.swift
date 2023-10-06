import Foundation

/// The description of a video from api.video.
public struct VideoInfo {
    public let videoId: String
    public let videoType: VideoType
    public let pingUrl: URL

    public static let DEFAULT_COLLECTOR_DOMAIN_URL_STR = "https://collector.api.video"
    public static let DEFAULT_COLLECTOR_DOMAIN_URL = URL(string: DEFAULT_COLLECTOR_DOMAIN_URL_STR)!

    /// Creates a video from its infos
    /// - Parameters
    ///           - videoId: The video id
    ///           - videoType: The video type (either live or vod)
    ///           - collectorDomainURL: the URL for player analytics collector. Only for if you use a custom collector domain.
    public init(videoId: String, videoType: VideoType, collectorDomainURL: URL = DEFAULT_COLLECTOR_DOMAIN_URL) throws {
        self.videoId = videoId
        self.videoType = videoType

        guard let pingUrl = URL(string: "\(collectorDomainURL)/\(videoType.rawValue)") else {
            throw AnalyticsError.malformedUrl("Can not create media url")
        }
        self.pingUrl = pingUrl
    }

    /// Creates a video from a media URL from api.video.
    /// - Parameters
    ///           - mediaURL: the media URL of the video
    ///           - collectorDomainURL: the URL for player analytics collector. Only for if you use a custom collector domain.
    public static func from(
        _ mediaURL: String,
        collectorDomainURL: String = DEFAULT_COLLECTOR_DOMAIN_URL_STR
    ) throws -> VideoInfo {
        try from(URL(string: mediaURL)!, collectorDomainURL: URL(string: collectorDomainURL)!)
    }

    /// Creates a video from a media URL from api.video.
    /// - Parameters
    ///           - mediaURL: the media URL of the video
    ///           - collectorDomainURL: the URL for player analytics collector. Only for if you use a custom collector domain.
    public static func from(
        _ mediaURL: URL,
        collectorDomainURL: URL = DEFAULT_COLLECTOR_DOMAIN_URL
    ) throws -> VideoInfo {
        let mediaUrlStr = mediaURL.absoluteString
        let pattern = "https://[^/]+/(?>(?<type>vod|live)/)?(?>.*/)?(?<id>(vi|li)[^/^.]*).*"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        let videoType: VideoType!
        let videoId: String!

        guard let match = regex?.firstMatch(
            in: mediaUrlStr,
            range: NSRange(location: 0, length: mediaUrlStr.utf16.count)
        ) else {
            throw AnalyticsError.malformedUrl("Can not parse media url")
        }

        if let videoIdRange = Range(match.range(withName: "id"), in: mediaUrlStr) {
            videoId = String(mediaUrlStr[videoIdRange])
        } else {
            throw AnalyticsError.malformedUrl("Can not get video id from URL")
        }

        if let videoTypeRange = Range(match.range(withName: "type"), in: mediaUrlStr) {
            videoType = try String(mediaUrlStr[videoTypeRange]).toVideoType()
        } else {
            if videoId.starts(with: "li") {
                videoType = VideoType.LIVE
            } else {
                throw AnalyticsError.malformedUrl("Can not get video type from URL")
            }
        }

        return try VideoInfo(videoId: videoId, videoType: videoType, collectorDomainURL: collectorDomainURL)
    }
}
