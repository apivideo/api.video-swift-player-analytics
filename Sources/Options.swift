import Foundation
public struct Options{
    public var videoInfo: VideoInfo
    public var metadata = [[String: String]]()
    public let onSessionIdReceived: ((String) -> ())?
    public let onPing: ((PlaybackPingMessage) -> ())?
    
    public init(mediaUrl: String, metadata: [[String: String]], onSessionIdReceived: ((String) -> ())? = nil, onPing: ((PlaybackPingMessage) -> ())? = nil) throws {
        do{
            videoInfo = try Options.parseMediaUrl(mediaUrl: mediaUrl)
        }catch{
            throw VideoError.Error("error with media url")
        }
        self.metadata = metadata
        self.onSessionIdReceived = onSessionIdReceived
        self.onPing = onPing
    }
    
    private static func parseMediaUrl(mediaUrl: String) throws -> VideoInfo{
        let regex = "https:/.*[/](vod|live)([/]|[/.][^/]*[/])([^/^.]*)[/.].*"
        
        let matcher = mediaUrl.match(regex)
        if(matcher.isEmpty){
            throw VideoError.Error("The media url doesn't look like an api.video URL")
        }
        if (matcher[0].count < 3) {
            throw VideoError.Error("The media url doesn't look like an api.video URL")
        }
        
        do {
            let videoType = try matcher[0][1].description.toVideoType()
            let videoId = matcher[0][3]
            
            return VideoInfo(pingUrl: "https://collector.api.video/\(videoType.rawValue)", videoId: videoId, videoType: videoType)
        } catch let error {
            throw VideoError.Error("The media url doesn't look like an api.video URL : \(error)")
        }
        
    }
}
