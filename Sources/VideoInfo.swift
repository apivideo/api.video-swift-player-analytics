import Foundation

public struct VideoInfo {
    public let videoId: String
    public let videoType: VideoType
    public let pingUrl: String
    public init(videoId: String, videoType: VideoType) {
        self.videoId = videoId
        self.videoType = videoType
        self.pingUrl = "https://collector.api.video/\(videoType.rawValue)"
    }
}
