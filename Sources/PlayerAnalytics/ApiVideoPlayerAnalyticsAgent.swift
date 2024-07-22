import Foundation

/// The player analytics agent that sends events to the collector.
class ApiVideoPlayerAnalyticsAgent {
    private let options: ApiVideoPlayerAnalyticsOptions
    private let client: HttpClient

    private var events = FixedSizedArrayWithUpsert<Event>(maxSize: eventsQueueSize)
    private let serialQueue = DispatchQueue(label: "video.api.player.analytics.serialQueue")

    private let sessionId: String

    private var batchGenerator: BatchGenerator?

    private init(options: ApiVideoPlayerAnalyticsOptions, sessionId: String) {
        self.options = options
        self.sessionId = sessionId
        client = HttpClient(options.collectorUrl.appendingPathComponent(options.collectorPath))
    }

    /// Sets the mediaId for the player analytics agent.
    /// - Parameters:
    /// - mediaId: The mediaId of the video. Either a videoId or a liveStreamId
    func setMediaId(_ mediaId: String) {
        serialQueue.sync {
            batchGenerator?.close()
            batchGenerator = BatchGenerator(
                sessionId: sessionId,
                mediaId: mediaId,
                playbackId: UUID().uuidString,
                batchReportIntervalInS: self.options.batchReportIntervalInS,
                serialQueue: serialQueue,
                onNewBatch: { batch in
                    self.reportBatch(batch)
                }
            )
        }
    }

    /// Temporary disables the player analytics agent.
    /// It is usefull when the player reads a non-api.video media.
    func disable() {
        serialQueue.sync {
            batchGenerator?.close()
            batchGenerator = nil
        }
    }

    /// Adds an event to the player analytics agent.
    func addEvent(_ event: Event) {
        batchGenerator?.addEvent(event)
    }

    private func reportBatch(_ batch: Batch) {
        client.post(batch, completion: ({ response in
            do {
                _ = try response.result()
            } catch {
                print("Error: \(error) for payload: \(batch)")
            }
        }))
    }

    deinit {
        batchGenerator?.close()
    }

    /// Create a new instance of the ApiVideoPlayerAnalyticsAgent.
    /// - Parameters:
    ///  - collectorUrl: The URL of the collector. Only for custom domain. Expected format: URL(string: "https://collector.mycustomdomain.com")!
    ///  - Returns: The ApiVideoPlayerAnalyticsAgent instance
    public static func create(collectorUrl: URL? = nil) -> ApiVideoPlayerAnalyticsAgent {
        let sessionId = SessionStorage.sessionId
        let options: ApiVideoPlayerAnalyticsOptions
        if let collectorUrl {
            options = ApiVideoPlayerAnalyticsOptions(collectorUrl: collectorUrl)
        } else {
            options = ApiVideoPlayerAnalyticsOptions()
        }
        return ApiVideoPlayerAnalyticsAgent(options: options, sessionId: sessionId)
    }

    private static let version = "2.0.0"
    private static let eventsQueueSize = 20

    private class BatchGenerator {
        private let sessionId: String
        private let mediaId: String
        private let playbackId: String
        private let batchReportIntervalInS: TimeInterval
        private let serialQueue: DispatchQueue

        private let onNewBatch: (Batch) -> Void

        private var events = FixedSizedArrayWithUpsert<Event>(maxSize: eventsQueueSize)

        private var scheduler: Timer?

        private var hasFirstPlay = false

        init(
            sessionId: String,
            mediaId: String,
            playbackId: String,
            batchReportIntervalInS: TimeInterval,
            serialQueue: DispatchQueue,
            onNewBatch: @escaping (Batch) -> Void
        ) {
            self.sessionId = sessionId
            self.mediaId = mediaId
            self.playbackId = playbackId
            self.batchReportIntervalInS = batchReportIntervalInS
            self.serialQueue = serialQueue
            self.onNewBatch = onNewBatch
        }

        private func startScheduler() {
            DispatchQueue.global(qos: .background).async {
                self.scheduler = Timer
                    .scheduledTimer(withTimeInterval: self.batchReportIntervalInS, repeats: true) { _ in
                        self.trySendBatch()
                    }
                RunLoop.current.run()
            }
        }

        private func getBatch() -> Batch? {
            let events = serialQueue.sync {
                let events = self.events.array
                self.events.removeAll()
                return events
            }
            if events.isEmpty {
                return nil
            }

            return Batch.createNow(
                sessionId: sessionId,
                playbackId: playbackId,
                mediaId: mediaId,
                events: events,
                version: ApiVideoPlayerAnalyticsAgent.version,
                referrer: ""
            )
        }

        private func trySendBatch() {
            guard let batch = getBatch() else {
                return
            }
            onNewBatch(batch)
        }

        func addEvent(_ event: Event) {
            if scheduler == nil {
                startScheduler()
            }
            serialQueue.sync {
                events.upsert(event)
            }
            if event.type == .play, !hasFirstPlay {
                hasFirstPlay = true
                trySendBatch()
            }
        }

        func close() {
            scheduler?.invalidate()
            trySendBatch()
        }

        deinit {
            close()
        }
    }
}

struct ApiVideoPlayerAnalyticsOptions {
    let collectorUrl: URL
    let collectorPath: String
    let batchReportIntervalInS: TimeInterval

    init(
        collectorUrl: URL = defaultCollectorUrl,
        collectorPath: String = defaultCollectorPath,
        batchReportIntervalInS: TimeInterval = defaultBatchReportIntervalInS
    ) {
        self.collectorUrl = collectorUrl
        self.collectorPath = collectorPath
        self.batchReportIntervalInS = batchReportIntervalInS
    }

    private static var defaultCollectorUrl: URL {
        let url = URL(string: "https://collector.api.video")
        guard let url else { fatalError("Invalid default collector URL") }
        return url
    }

    private static let defaultCollectorPath = "watch"
    private static let defaultBatchReportIntervalInS = 5.0
}

private enum SessionStorage {
    static let sessionId = UUID().uuidString
}
