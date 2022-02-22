import Foundation
import MobileCoreServices

@available(iOS 11.0, *)
public class PlayerAnalytics {
    
    private var options: Options
    private static let playbackDelay = 10 * 1000
    private var timer: Timer?
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
    
    
    public func play(completion: @escaping (Bool, VideoError?) -> Void){
        schedule()
        addEventAt(Event.PLAY){(isDone, error) in
            completion(isDone, error)
        }
    }
    
    public func resume(completion: @escaping (Bool, VideoError?) -> Void){
        schedule()
        addEventAt(Event.RESUME){(isDone, error) in
            completion(isDone, error)
        }
    }
    
    public func ready(completion: @escaping (Bool, VideoError?) -> Void){
        addEventAt(Event.READY){ (isDone, error) in
            self.sendPing(payload: self.buildPingPayload()){ (isDone, error) in
                completion(isDone, error)
            }
        }
    }
    
    public func end(completion: @escaping (Bool, VideoError?) -> Void){
        unSchedule()
        addEventAt(Event.END){ (isDone, error) in
            self.sendPing(payload: self.buildPingPayload()){ (isDone, error) in
                completion(isDone, error)
            }
        }
    }
    
    public func pause(completion: @escaping (Bool, VideoError?) -> Void){
        unSchedule()
        addEventAt(Event.PAUSE){ (isDone, error) in
            self.sendPing(payload: self.buildPingPayload()){ (isDone, error) in
                completion(isDone, error)
            }
        }
    }
    
    public func seek(from:Float, to: Float, completion : @escaping (Bool, VideoError?) -> Void){
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
    
    public func destroy(completion: @escaping (Bool, VideoError?) -> Void){
        unSchedule()
        completion(true, nil)
    }
    
    private func addEventAt(_ eventName: Event, completion: @escaping (Bool, VideoError?) -> Void){
        eventsStack.append(PingEvent(emittedAt: loadedAt, type: eventName, at: currentTime, from: nil, to: nil))
        completion(true,nil)
    }
    
    private func schedule(){
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            self.timerAction()
        })
    }
    
    private func timerAction() {
        sendPing(payload: buildPingPayload()){ (isDone, error) in
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
    
    private func sendPing(payload: PlaybackPingMessage, completion: @escaping (Bool, VideoError?) -> Void){
        var request = RequestsBuilder().postClientUrlRequestBuilder(apiPath: options.videoInfo.pingUrl)
        var body:[String : Any] = [:]
        let encoder = JSONEncoder()
        let task: TasksExecutorProtocol = TasksExecutor()
        encoder.outputFormatting = .prettyPrinted
        let jsonpayload = try! encoder.encode(payload)
        
        if let data = String(data: jsonpayload, encoding: .utf8)?.data(using: .utf8) {
            do {
                body = try (JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])!
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                print(error.localizedDescription)
            }
        }
        let session = RequestsBuilder().urlSessionBuilder()
        task.execute(session: session, request: request){ (data, response) in
            if(data != nil){
                let json = try? JSONSerialization.jsonObject(with: data!) as? Dictionary<String, AnyObject>
                print(json as Any)
                if let mySession = json!["session"] as? String {
                    if(self.sessionId == nil){
                        self.sessionId = mySession
                    }
                }
                completion(true,nil)
            }else{
                completion(false, VideoError.Error("\(String(describing: response!.statusCode)): \(String(describing: response!.message))"))
            }
        }
    }
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
