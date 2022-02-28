import Foundation

public struct Session: Codable {
  let sessionId: String?
  let loadedAt: String
  let videoId: String?
  let livestreamId: String?
  let referrer: String
  let metadata: [[String: String]]

  public static func buildLiveStreamSession(
    sessionId: String?, loadedAt: String, livestreamId: String, referrer: String,
    metadata: [[String: String]]
  ) -> Session {
    return Session(
      sessionId: sessionId, loadedAt: loadedAt, videoId: nil, livestreamId: livestreamId,
      referrer: referrer, metadata: metadata)
  }
  public static func buildVideoSession(
    sessionId: String?, loadedAt: String, videoId: String, referrer: String,
    metadata: [[String: String]]
  ) -> Session {
    return Session(
      sessionId: sessionId, loadedAt: loadedAt, videoId: videoId, livestreamId: nil,
      referrer: referrer, metadata: metadata)
  }

  private enum CodingKeys: String, CodingKey {
    case sessionId = "session_id"
    case loadedAt = "loaded_at"
    case videoId = "video_id"
    case livestreamId, referrer, metadata
  }

}
