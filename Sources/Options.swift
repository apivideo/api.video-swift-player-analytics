import Foundation

public struct Options {
  public var videoInfo: VideoInfo
  public var metadata = [[String: String]]()
  public let onSessionIdReceived: ((String) -> Void)?
  public let onPing: ((PlaybackPingMessage) -> Void)?

  public init(
    mediaUrl: String, metadata: [[String: String]], onSessionIdReceived: ((String) -> Void)? = nil,
    onPing: ((PlaybackPingMessage) -> Void)? = nil
  ) throws {
    videoInfo = try Options.parseMediaUrl(mediaUrl: mediaUrl)
    self.metadata = metadata
    self.onSessionIdReceived = onSessionIdReceived
    self.onPing = onPing
  }

  private static func parseMediaUrl(mediaUrl: String) throws -> VideoInfo {
    let regex = "https:/.*[/](vod|live)([/]|[/.][^/]*[/])([^/^.]*)[/.].*"

    let matcher = mediaUrl.match(regex)
    if matcher.isEmpty {
      throw UrlError.malformedUrl("Can not parse media url")
    }
    if matcher[0].count < 3 {
      throw UrlError.malformedUrl("Missing arguments in url")
    }

    let videoType = try matcher[0][1].description.toVideoType()
    let videoId = matcher[0][3]

    return VideoInfo(
      pingUrl: "https://collector.api.video/\(videoType.rawValue)", videoId: videoId,
      videoType: videoType)
  }
}
