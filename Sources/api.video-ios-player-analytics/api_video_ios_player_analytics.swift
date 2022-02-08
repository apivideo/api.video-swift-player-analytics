import Foundation
@available(iOS 10.0, *)
public class api_video_ios_player_analytics {
    
    
    private static let playbackDelay = 10 * 1000
    private var timer: Timer?
    private var counter = 0 // a supprimer ceci est un test
    private var eventsStack = [PingEvent]()
    private let currentTime = Date().preciseLocalTime
    
    
    public func play(completion: @escaping () -> ()){
        schedule()
        //        addEventAt(Event.PLAY)
    }
    
    public func resume(completion: @escaping () -> ()){
        schedule()
        //        addEventAt(Event.RESUME)
    }
    
    public func ready(completion: @escaping () -> ()){
        //        addEventAt(Event.READY)
        //        sendPing(buildPingPayload())
    }
    
    public func end(completion: @escaping () -> ()){
        unSchedule()
        //addEventAt(Event.End)
        //        sendPing(buildPingPayload())
    }
    
    
    public func pause(completion: @escaping () -> ()){
        unSchedule()
        //addEventAt(Event.PAUSE)
        //        sendPing(buildPingPayload())
    }
    
    public func destroy(completion: @escaping () -> ()){
        unSchedule()
        //        completion(pause())
    }
    
    
    private func addEventAt(eventName: Event, completion: @escaping() -> ()){
        eventsStack.append(PingEvent(emittedAt: currentTime, type: eventName, at: nil, from: nil, to: nil))
        //do the completion
    }
    
    private func schedule(){
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            self.timerAction()
        })
    }
    
    private func timerAction() {
        counter += 1
    }
    
    private func unSchedule(){
        timer?.invalidate()
    }
    
    
    
    
    private func sendPing(payload: PlaybackPingMessage, completion: @escaping () ->()){
        
    }
    
    
    
    public init() {
    }
}

public enum VideoType: String{
    case VOD = "vod"
    case LIVE = "live"
    static let all = [VOD,LIVE]
    
}

enum VideoError: Error {
    case Error(String)
}

extension String{
    public func toVideoType() throws -> VideoType{
        switch self.lowercased() {
        case "vod":
            return VideoType.VOD
        case "live":
            return VideoType.LIVE
        default:
            throw VideoError.Error("Can't determine if video is vod or live.")
        }
    }
}

public struct VideoInfo{
    public let pingUrl: String
    public let videoId: String
    public let videoType: VideoType
}


public class PlaybackPingMessage : Codable{
    let emittedAt: String
    let session: String
    let events: [Event]
}


public struct PingEvent: Codable{
    let emittedAt: String
    let type: Event
    let at: Float?
    let from: Float?
    let to: Float?
}

public enum Event: String, Codable{
    case PLAY = "play"
    case RESUME = "resume"
    case READY = "ready"
    case PAUSE = "pause"
    case END = "end"
    case SEEK_FORWARD = "seek.forward"
    case SEEK_BACKWARD = "seek.backward"
}

public class StringRequest{
    var method: Int
    var url: String
    var body: String?
    
    init(method: Int, url: String){
        self.method = method
        self.url = url
    }
    
    init(method: Int, url: String, body: String?){
        self.method = method
        self.url = url
        self.body = body
    }
}

public struct Options{
    public var videoInfo: VideoInfo
    public var metadata = [String: String]()
    public let onSessionIdReceived: ((String) -> ())?
    public let onPing: ((PlaybackPingMessage) -> ())?
    
    public init(mediaUrl: String, metadata: [String: String], onSessionIdReceived: ((String) -> ())? = nil, onPing: ((PlaybackPingMessage) -> ())? = nil) throws {
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
            print("The media url doesn't look like an api.video URL.")
        }
        
        do {
            let videoType = try matcher[0][1].description.toVideoType()
            let videoId = try matcher[0][3]
            
            return VideoInfo(pingUrl: "https://collector.api.video/\(videoType.rawValue)", videoId: videoId, videoType: videoType)
        } catch let error {
            print(error.localizedDescription)
            throw VideoError.Error("The media url doesn't look like an api.video URL : \(error)")
        }
        
    }
}

extension String {
    public func match(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, nsString.length)).map { match in
            (0..<match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
        } ?? []
    }
}

extension Formatter {
    // create static date formatters for your date representations
    static let preciseLocalTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    static let preciseGMTTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}

extension Date {
    var preciseLocalTime: String {
        return Formatter.preciseLocalTime.string(for: self) ?? ""
    }
    // or GMT time
    var preciseGMTTime: String {
        return Formatter.preciseGMTTime.string(for: self) ?? ""
    }
}
