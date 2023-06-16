import Foundation

public struct VideoInfo {
    public let videoId: String
    public let videoType: VideoType
    public let pingUrl: URL

    public static let DEFAULT_COLLECTOR_DOMAIN_URL = URL(string: "https://collector.api.video")!

    public init(videoId: String, videoType: VideoType, collectorDomainURL: URL = DEFAULT_COLLECTOR_DOMAIN_URL) throws {
        self.videoId = videoId
        self.videoType = videoType

        guard let pingUrl = URL(string: "\(collectorDomainURL)/\(videoType.rawValue)") else {
            throw UrlError.malformedUrl("Can not create media url")
        }
        self.pingUrl = pingUrl
    }

    internal static func parseMediaUrl(mediaUrl: String) throws -> VideoInfo {
        let pattern = "https:/.*[/](?<type>vod|live).*/(?<id>(vi|li)[^/^.]*)[/.].*"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        let videoType: VideoType!
        let videoId: String!

        guard let match = regex?.firstMatch(in: mediaUrl, range: NSRange(location: 0, length: mediaUrl.utf16.count)) else {
            throw UrlError.malformedUrl("Can not parse media url")
        }

        if let videoTypeRange = Range(match.range(withName: "type"), in: mediaUrl) {
            videoType = try String(mediaUrl[videoTypeRange]).toVideoType()
        } else {
            throw UrlError.malformedUrl("Can not get video type from URL")
        }

        if let videoIdRange = Range(match.range(withName: "id"), in: mediaUrl) {
            videoId = String(mediaUrl[videoIdRange])
        } else {
            throw UrlError.malformedUrl("Can not get video id from URL")
        }

        return try VideoInfo(videoId: videoId, videoType: videoType)
    }
}
