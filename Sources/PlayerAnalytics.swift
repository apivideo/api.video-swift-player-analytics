import Foundation

@available(iOS 11.0, *)
public class PlayerAnalytics {
    private var options: Options
    private static let playbackDelay = 10 * 1000
    private var timer: Timer?
    private var eventsStack = [PingEvent]()
    private let loadedAt = Date().preciseLocalTime

    public private(set) var sessionId: String? {
        didSet {
            options.onSessionIdReceived?(sessionId!)
        }
    }

    /// Field to call each time the playback time changes (it should be called often, the accuracy of the collected data depends on it).
    var currentTime: Float = 0

    public init(options: Options) {
        self.options = options
    }

    /// Method to call when the video starts playing for the first time.
    /// (in the case of a resume after paused, use resume()).
    /// - Parameter completion: Invoked when Result is succesful or failed.
    ///
    /// example of usage
    ///
    ///     // pretend that option is available
    ///     let analytics = PlayerAnalytics(options: option)
    ///     analytics.play { (result) in
    ///         switch result {
    ///             case .success(let data):
    ///             print(data)
    ///             case .failure(let error):
    ///             print(error)
    ///         }
    ///     }
    ///
    ///
    public func play(completion: @escaping (Result<Void, Error>) -> Void) {
        if timer == nil {
            schedule()
        }
        addEventAt(Event.PLAY) { result in
            completion(result)
        }
    }

    /// Method to call when the video playback is resumed after a pause.
    /// - Parameter completion: Invoked when Result is succesful or failed.
    public func resume(completion: @escaping (Result<Void, Error>) -> Void) {
        if timer == nil {
            schedule()
        }
        addEventAt(Event.RESUME) { result in
            completion(result)
        }
    }

    /// Method to call once the player is ready to play the media.
    /// - Parameter completion: Invoked when Result is succesful or failed.
    public func ready(completion: @escaping (Result<Void, Error>) -> Void) {
        addEventAt(Event.READY) { result in
            switch result {
            case .success:
                self.sendPing(payload: self.buildPingPayload()) { res in
                    completion(res)
                }
            case .failure:
                completion(result)
            }
        }
    }

    /// Method to call when the video is ended.
    /// - Parameter completion: Invoked when Result is succesful or failed.
    public func end(completion: @escaping (Result<Void, Error>) -> Void) {
        unSchedule()
        addEventAt(Event.END) { result in
            switch result {
            case .success:
                self.sendPing(payload: self.buildPingPayload()) { res in
                    completion(res)
                }
            case .failure:
                completion(result)
            }
        }
    }

    /// Method to call when the video is paused.
    /// - Parameter completion: Invoked when Result is succesful or failed.
    public func pause(completion: @escaping (Result<Void, Error>) -> Void) {
        unSchedule()
        addEventAt(Event.PAUSE) { result in
            switch result {
            case .success:
                self.sendPing(payload: self.buildPingPayload()) { res in
                    completion(res)
                }
            case .failure:
                completion(result)
            }
        }
    }

    /// Method to call when a seek event occurs.
    /// - Parameters:
    ///   - from: Start time in second.
    ///   - to: End time in second.
    ///   - completion: Invoked when Result is succesful or failed.
    public func seek(from: Float, to: Float, completion: @escaping (Result<Void, Error>) -> Void) {
        if from > 0, to > 0 {
            var event: Event
            if from < to {
                event = .SEEK_FORWARD
            } else {
                event = .SEEK_BACKWARD
            }
            eventsStack.append(
                PingEvent(emittedAt: Date().preciseLocalTime, type: event, at: nil, from: from, to: to))
            completion(.success(()))
        }
    }

    /// Method to call when the video player is disposed.
    /// - Parameter completion: Invoked when Result is succesful or failed.
    public func destroy(completion: @escaping (Result<Void, UrlError>) -> Void) {
        unSchedule()
        completion(.success(()))
    }

    private func addEventAt(_ eventName: Event, completion: @escaping (Result<Void, Error>) -> Void) {
        eventsStack.append(
            PingEvent(emittedAt: loadedAt, type: eventName, at: currentTime, from: nil, to: nil))
        completion(.success(()))
    }

    private func schedule() {
        timer = Timer.scheduledTimer(
            timeInterval: 10,
            target: self,
            selector: #selector(timerAction),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func timerAction() {
        sendPing(payload: buildPingPayload()) { result in
            switch result {
            case .success: break
            case let .failure(error):
                print(error)
            }
        }
    }

    private func unSchedule() {
        timer?.invalidate()
        timer = nil
    }

    private func buildPingPayload() -> PlaybackPingMessage {
        var session: Session
        switch options.videoInfo.videoType {
        case .LIVE:
            session = Session.buildLiveStreamSession(
                sessionId: sessionId, loadedAt: loadedAt, livestreamId: options.videoInfo.videoId,
                referrer: "", metadata: options.metadata
            )
        case .VOD:
            session = Session.buildVideoSession(
                sessionId: sessionId, loadedAt: loadedAt, videoId: options.videoInfo.videoId, referrer: "",
                metadata: options.metadata
            )
        }

        return PlaybackPingMessage(
            emittedAt: Date().preciseLocalTime, session: session, events: eventsStack
        )
    }

    private func sendPing(
        payload: PlaybackPingMessage, completion: @escaping (Result<Void, Error>) -> Void
    ) {
        if eventsStack.count > 0 {
            var request = RequestsBuilder().postClientUrlRequestBuilder(apiPath: options.videoInfo.pingUrl)
            var body: [String: Any] = [:]
            let encoder = JSONEncoder()
            var jsonPayload: Data!

            do {
                jsonPayload = try encoder.encode(payload)

                let data = String(data: jsonPayload, encoding: .utf8)!.data(using: .utf8)!
                body = try (JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])!
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                completion(.failure(error))
            }

            let session = RequestsBuilder().buildUrlSession()
            TasksExecutor.execute(session: session, request: request) { data, error in
                if data != nil {
                    var json: [String: AnyObject]
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data!) as? [String: AnyObject] else {
                            completion(.failure(JSONError.castError("Could not cast json to [String: AnyObject]")))
                            return
                        }
                        guard let mySession = json["session"] as? String else {
                            completion(.failure(JSONError.castError("Could not cast session Id from JSON")))
                            return
                        }
                        if self.sessionId == nil {
                            self.sessionId = mySession
                        }
                        self.cleanEventsStack()
                        completion(.success(()))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(error!))
                }
            }
        }
    }

    private func cleanEventsStack() {
        eventsStack.removeAll()
    }
}

public extension String {
    func toVideoType() throws -> VideoType {
        switch lowercased() {
        case "vod":
            return VideoType.VOD
        case "live":
            return VideoType.LIVE
        default:
            throw UrlError.invalidParameter("Can't determine if video is vod or live: \(self)")
        }
    }

    func match(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(
            in: self, options: [], range: NSMakeRange(0, nsString.length)
        ).map { match in
            (0 ..< match.numberOfRanges).map {
                match.range(at: $0).location == NSNotFound
                    ? "" : nsString.substring(with: match.range(at: $0))
            }
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
