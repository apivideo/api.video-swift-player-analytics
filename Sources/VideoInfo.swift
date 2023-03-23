import Foundation

public struct VideoInfo {
    public let videoId: String
    public let videoType: VideoType
    public let pingUrl: URL

    public init(videoId: String, videoType: VideoType) throws {
        self.videoId = videoId
        self.videoType = videoType
        guard let pingUrl = URL(string: "https://collector.api.video/\(videoType.rawValue)") else {
            throw UrlError.malformedUrl("Can not create media url")
        }
        self.pingUrl = pingUrl
    }
}
