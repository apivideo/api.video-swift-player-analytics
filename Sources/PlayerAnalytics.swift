import AVFoundation
import Foundation

@available(iOS 11.0, *)
public class PlayerAnalytics {
    private var options: Options
    private static let playbackDelay = 10 * 1_000
    private var timer: Timer?
    private var eventsStack = [PingEvent]()
    private let loadedAt = Date().preciseLocalTime
    private let messageBuilderQueue = DispatchQueue(label: "video.api.analytics.MessageBuilderQueue")

    public private(set) var sessionId: String? {
        didSet {
            options.onSessionIdReceived?(sessionId!)
        }
    }

    /// Field to call each time the playback time changes (it should be called often, the accuracy of the collected data
    /// depends on it).
    var currentTime: Float = 0

    public init(options: Options) {
        self.options = options
    }

    /// Method to call when the video starts playing for the first time.
    /// (in the case of a resume after paused, use resume()).
    /// - Parameter completion: Invoked when Result is successful or failed.
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
        addEvent(Event.PLAY)
        completion(.success(()))
    }

    /// Method to call when the video playback is resumed after a pause.
    /// - Parameter completion: Invoked when Result is successful or failed.
    public func resume(completion: @escaping (Result<Void, Error>) -> Void) {
        if timer == nil {
            schedule()
        }
        addEvent(Event.RESUME)
        completion(.success(()))
    }

    /// Method to call once the player is ready to play the media.
    /// - Parameter completion: Invoked when Result is successful or failed.
    public func ready(completion: @escaping (Result<Void, Error>) -> Void) {
        addEvent(Event.READY)
        self.sendPing(payload: self.buildPingPayload()) { res in
            completion(res)
        }
    }

    /// Method to call when the video is ended.
    /// - Parameter completion: Invoked when Result is successful or failed.
    public func end(completion: @escaping (Result<Void, Error>) -> Void) {
        unSchedule()
        addEvent(Event.END)
        self.sendPing(payload: self.buildPingPayload()) { res in
            completion(res)
        }
    }

    /// Method to call when the video is paused.
    /// - Parameter completion: Invoked when Result is successful or failed.
    public func pause(completion: @escaping (Result<Void, Error>) -> Void) {
        unSchedule()
        addEvent(Event.PAUSE)
        self.sendPing(payload: self.buildPingPayload()) { res in
            completion(res)
        }
    }

    /// Method to call when a seek event occurs.
    /// - Parameters:
    ///   - from: Start time in second.
    ///   - to: End time in second.
    ///   - completion: Invoked when Result is successful or failed.
    public func seek(from: Float, to: Float, completion: @escaping (Result<Void, Error>) -> Void) {
        precondition(from >= 0, "from must be positive value but from=\(from)")
        precondition(to >= 0, "to must be positive value but to=\(to)")
        var event: Event
        if from < to {
            event = .SEEK_FORWARD
        } else {
            event = .SEEK_BACKWARD
        }
        addEvent(
            PingEvent(type: event, at: nil, from: from, to: to)
        )
        completion(.success(()))
    }

    /// Method to call when a seek event occurs.
    /// - Parameters:
    ///   - from: Start time in second.
    ///   - to: End time in second.
    ///   - completion: Invoked when Result is successful or failed.
    public func seek(from: CMTime, to: CMTime, completion: @escaping (Result<Void, Error>) -> Void) {
        seek(from: Float(from.seconds), to: Float(to.seconds), completion: completion)
    }

    /// Method to call when the video player is disposed.
    /// - Parameter completion: Invoked when Result is successful or failed.
    public func destroy(completion: @escaping (Result<Void, Error>) -> Void) {
        unSchedule()
        completion(.success(()))
    }

    private func addEvent(_ eventName: Event) {
        addEvent(PingEvent(type: eventName, at: currentTime, from: nil, to: nil))
    }

    private func addEvent(_ event: PingEvent) {
        eventsStack.append(event)
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

    @objc
    private func timerAction() {
        sendPing(payload: buildPingPayload()) { _ in
        }
    }

    private func unSchedule() {
        timer?.invalidate()
        timer = nil
    }

    private func buildPingPayload() -> PlaybackPingMessage {
        defer { self.cleanEventsStack() } // Clean events to avoid having stuck events.

        return messageBuilderQueue.sync {
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
    }

    private func sendPing(
        payload: PlaybackPingMessage, completion: @escaping (Result<Void, Error>) -> Void
    ) {
        RequestsBuilder.sendPing(
            taskExecutor: DefaultTasksExecutor.self,
            url: options.videoInfo.pingUrl,
            payload: payload
        ) { res in
            switch res {
            case let .success(sessionId):
                if self.sessionId == nil {
                    self.sessionId = sessionId
                }
                completion(.success(()))
            case let .failure(error):
                print("Failed to send events: \(payload) due to \(error)")
                completion(.failure(error))
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
            throw AnalyticsError.invalidParameter("Can't determine if video is vod or live: \(self)")
        }
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
