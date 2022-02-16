import Foundation
import MobileCoreServices

@available(iOS 11.0, *)
public class api_video_ios_player_analytics {
    
    private var options: Options
    private static let playbackDelay = 10 * 1000
    private var timer: Timer?
    private var counter = 0 // a supprimer ceci est un test
    private var eventsStack = [PingEvent]()
    private let loadedAt = Date().preciseLocalTime
    
    private(set) public var sessionId: String? = nil{
        didSet{
            print("didset : \(self.sessionId ?? "error")")
            self.options.onSessionIdReceived?(sessionId!)
        }
    }
    
    var currentTime: Float = 0
    
    
    public init(options: Options) {
        self.options = options
    }
    
    
    public func play(completion: @escaping () -> ()){
        schedule()
        addEventAt(Event.PLAY){
            completion()
        }
    }
    
    public func resume(completion: @escaping () -> ()){
        schedule()
        addEventAt(Event.RESUME){
            completion()
        }
    }
    
    public func ready(completion: @escaping () -> ()){
        addEventAt(Event.READY){
            self.sendPing(payload: self.buildPingPayload()){
                completion()
            }
        }
    }
    
    public func end(completion: @escaping () -> ()){
        unSchedule()
        addEventAt(Event.END){
            self.sendPing(payload: self.buildPingPayload()){
                completion()
            }
        }
    }
    
    
    public func pause(completion: @escaping () -> ()){
        unSchedule()
        addEventAt(Event.PAUSE){
            print("event pause")
            self.sendPing(payload: self.buildPingPayload()){
                completion()
            }
        }
        
    }
    
    public func seek(from:Float, to: Float, completion : @escaping () -> ()){
        if((from > 0) && (to > 0)){
            var event: Event
            if(from < to){
                event = .SEEK_FORWARD
            }else{
                event = .SEEK_BACKWARD
            }
            eventsStack.append(PingEvent(emittedAt: Date().preciseLocalTime, type: event, at: nil, from: from, to: to))
        }
    }
    
    public func destroy(completion: @escaping () -> ()){
        unSchedule()
        completion()
        //        completion(pause())
    }
    
    
    private func addEventAt(_ eventName: Event, completion: @escaping() -> ()){
        eventsStack.append(PingEvent(emittedAt: loadedAt, type: eventName, at: currentTime, from: nil, to: nil))
        completion()
        //do the completion
    }
    
    private func schedule(){
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            self.timerAction()
        })
    }
    
    private func timerAction() {
        sendPing(payload: buildPingPayload()){
            print("schedule sended")
        }
    }
    
    private func unSchedule(){
        timer?.invalidate()
    }
    
    
    private func buildPingPayload()-> PlaybackPingMessage{
        var session: Session
        switch options.videoInfo.videoType {
        case .LIVE:
            session = Session.buildLiveStreamSession(sessionId: sessionId, loadedAt: loadedAt, livestreamId: options.videoInfo.videoId, referrer: "", metadata: options.metadata)
        case .VOD:
            session = Session.buildVideoSession(sessionId: sessionId, loadedAt: loadedAt, videoId: options.videoInfo.videoId, referrer: "", metadata: options.metadata)
        }
        
        return PlaybackPingMessage(emittedAt: Date().preciseLocalTime, session: session, events: eventsStack)
    }
    
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    
    
    private func sendPing(payload: PlaybackPingMessage, completion: @escaping () ->()){
        var request = RequestsBuilder().postClientUrlRequestBuilder(apiPath: options.videoInfo.pingUrl)
        var body:[String : Any] = [:]
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonpayload = try! encoder.encode(payload)
        print("json payload : \(String(data: jsonpayload, encoding: .utf8)!)")
        
        if let data = String(data: jsonpayload, encoding: .utf8)?.data(using: .utf8) {
            do {
                body = try (JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])!
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
        
        let session = RequestsBuilder().urlSessionBuilder()
        TasksExecutor().execute(session: session, request: request){ (data, response) in
            if(data != nil){
                let json = try? JSONSerialization.jsonObject(with: data!) as? Dictionary<String, AnyObject>
                print(json as Any)
                if let mySession = json!["session"] as? String {
                    if(self.sessionId == nil){
                        self.sessionId = mySession
                    }
                }
                completion()
            }
        }
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


public struct PlaybackPingMessage : Codable{
    let emittedAt: String
    let session: Session
    let events: [PingEvent]
    
    private enum CodingKeys : String, CodingKey {
        case emittedAt = "emitted_at", session, events
    }
}


public struct PingEvent: Codable{
    let emittedAt: String
    let type: Event
    let at: Float?
    let from: Float?
    let to: Float?
    
    private enum CodingKeys : String, CodingKey {
        case emittedAt = "emitted_at", type, at, from, to
    }
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

public struct Session: Codable{
    let sessionId: String?
    let loadedAt: String
    let videoId: String?
    let livestreamId: String?
    let referrer: String
    let metadata: [[String:String]]
    
    public static func buildLiveStreamSession(sessionId: String?, loadedAt: String, livestreamId: String, referrer: String, metadata : [[String : String]]) -> Session{
        return Session(sessionId: sessionId, loadedAt: loadedAt, videoId: nil, livestreamId: livestreamId, referrer: referrer, metadata: metadata)
    }
    public static func buildVideoSession(sessionId: String?, loadedAt: String, videoId: String, referrer: String, metadata : [[String : String]]) -> Session{
        return Session(sessionId: sessionId, loadedAt: loadedAt, videoId: videoId, livestreamId: nil, referrer: referrer, metadata: metadata)
    }
    
    private enum CodingKeys : String, CodingKey {
        case sessionId = "session_id", loadedAt = "loaded_at", videoId = "video_id", livestreamId, referrer, metadata
    }
    
}

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
            print("The media url doesn't look like an api.video URL.")
        }
        
        do {
            let videoType = try matcher[0][1].description.toVideoType()
            let videoId = matcher[0][3]
            
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

@available(iOS 11.0, *)
extension Formatter {
    // create static date formatters for your date representations
    static let preciseLocalTime: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        
        return formatter
    }()
}

@available(iOS 11.0, *)
extension Date {
    var preciseLocalTime: String {
        return Formatter.preciseLocalTime.string(from: self)
    }
    
}
