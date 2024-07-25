import AVFoundation
import Foundation

/// An AVPlayer with api.video player analytics integration.
public class ApiVideoAnalyticsAVPlayer: AVPlayer {
    private let agent: ApiVideoPlayerAnalyticsAgent
    private var timeObserver: Any?

    private var currentItemObserver: NSKeyValueObservation?
    private var statusObserver: NSKeyValueObservation?
    private var timeControlStatusObserver: NSKeyValueObservation?

    /// Initializes an AVPlayer that plays a single audiovisual resource referenced by URL with a custom collector.
    /// Parameters:
    /// - url: The URL that points to the api.video media.
    /// - collectorUrl: The URL of the collector. Only for custom domain. Expected format: URL(string: "https://collector.mycustomdomain.com")!
    public init(url: URL, collectorUrl: URL) {
        agent = ApiVideoPlayerAnalyticsAgent.create(collectorUrl: collectorUrl)
        super.init(url: url)
        addObservers()
    }

    /// Initializes an AVPlayer that plays a single audiovisual resource referenced by URL.
    /// Parameters:
    /// - url: The URL that points to the api.video media.
    override public init(url: URL) {
        agent = ApiVideoPlayerAnalyticsAgent.create()
        super.init(url: url)
        addObservers()
    }

    /// Initializes an AVPlayer that plays a single media item with a custom collector.
    /// Parameters:
    /// - playerItem: The AVPlayerItem that the player will play.
    /// - collectorUrl: The URL of the collector. Only for custom domain. Expected format: URL(string: "https://collector.mycustomdomain.com")!
    public init(playerItem: AVPlayerItem?, collectorUrl: URL) {
        agent = ApiVideoPlayerAnalyticsAgent.create(collectorUrl: collectorUrl)
        super.init(playerItem: playerItem)
        addObservers()
    }

    /// Initializes an AVPlayer that plays a single media item.
    /// Parameters:
    /// - playerItem: The AVPlayerItem that the player will play.
    override public init(playerItem: AVPlayerItem?) {
        agent = ApiVideoPlayerAnalyticsAgent.create()
        super.init(playerItem: playerItem)
        addObservers()
    }

    override public init() {
        agent = ApiVideoPlayerAnalyticsAgent.create()
        super.init()
        addObservers()
    }

    override public func seek(to time: CMTime) {
        super.seek(to: time)
        addEvent(.seek)
    }

    override public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) {
        super.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
        addEvent(.seek)
    }

    override public func seek(to date: Date) {
        super.seek(to: date)
        addEvent(.seek)
    }

    override public func seek(to time: CMTime, completionHandler: @escaping (Bool) -> Void) {
        super.seek(to: time, completionHandler: completionHandler)
        addEvent(.seek)
    }

    override public func seek(to date: Date, completionHandler: @escaping (Bool) -> Void) {
        super.seek(to: date, completionHandler: completionHandler)
        addEvent(.seek)
    }

    override public func seek(
        to time: CMTime,
        toleranceBefore: CMTime,
        toleranceAfter: CMTime,
        completionHandler: @escaping (Bool) -> Void
    ) {
        super.seek(
            to: time,
            toleranceBefore: toleranceBefore,
            toleranceAfter: toleranceAfter,
            completionHandler: completionHandler
        )
        addEvent(.seek)
    }

    private func addEvent(_ eventType: Event.EventType) {
        let errorCode: ErrorCode
        if let error = error as? AVError {
            errorCode = error.analyticsErrorCode
        } else {
            errorCode = .none
        }
        let videoSize = currentItem?.presentationSize ?? CGSize.zero
        let paused = timeControlStatus != .playing
        let event = Event.createNow(
            type: eventType,
            videoTimeInS: Float(currentTime().seconds),
            videoWidth: Int(videoSize.width),
            videoHeight: Int(videoSize.height),
            paused: paused,
            errorCode: errorCode
        )
        agent.addEvent(event)
    }

    deinit {
        removeObservers()
    }

    @objc
    func playerItemDidPlayToEnd() {
        addEvent(.end)
    }

    private func addPlayerItemObserver(_ playerItem: AVPlayerItem) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidPlayToEnd),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }

    private func removePlayerItemObserver() {
        if let playerItem = currentItem {
            removePlayerItemObserver(playerItem)
        }
    }

    private func removePlayerItemObserver(_ playerItem: AVPlayerItem) {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }

    private func addPlayerObserver() {
        currentItemObserver = observe(\.currentItem, options: [.new, .old], changeHandler: { [weak self] _, change in
            self?.onCurrentItem(change)
        })
        statusObserver = observe(\.status, options: [.new], changeHandler: { [weak self] player, change in
            self?.onStatus(player: player, change: change)
        })
        timeControlStatusObserver = observe(
            \.timeControlStatus,
            options: [.new, .old],
            changeHandler: { [weak self] player, change in
                self?.onTimeControlStatus(player: player, change: change)
            }
        )
    }

    private func removePlayerObserver() {
        currentItemObserver?.invalidate()
        currentItemObserver = nil
        statusObserver?.invalidate()
        statusObserver = nil
        timeControlStatusObserver?.invalidate()
        timeControlStatusObserver = nil
    }

    private func addTimeObserver() {
        if timeObserver != nil {
            return
        }
        timeObserver = addPeriodicTimeObserver(
            forInterval: CMTimeMake(value: 250, timescale: 1_000),
            queue: nil,
            using: { _ in
                self.addEvent(.timeUpdate)
            }
        )
    }

    private func removeTimeObserver() {
        if let timeObserver = timeObserver {
            removeTimeObserver(timeObserver)
        }
        timeObserver = nil
    }

    private func addObservers() {
        addPlayerObserver()
        if let playerItem = currentItem {
            addPlayerItemObserver(playerItem)
        }
        addTimeObserver()
    }

    private func removeObservers() {
        removeTimeObserver()
        removePlayerItemObserver()
        removePlayerObserver()
    }

    private func onCurrentItem(_ change: NSKeyValueObservedChange<AVPlayerItem?>) {
        if let oldPlayerItem = change.oldValue,
           let oldPlayerItem
        {
            removePlayerItemObserver(oldPlayerItem)
        }
        if let newPlayerItem = change.newValue,
           let newPlayerItem
        {
            guard let asset = newPlayerItem.asset as? AVURLAsset else {
                agent.disable()
                return
            }
            guard let mediaId = Utils.parseMediaUrl(asset.url) else {
                agent.disable()
                return
            }

            agent.setMediaId(mediaId)
            addEvent(.src)
            addPlayerItemObserver(newPlayerItem)
        } else {
            agent.disable()
        }
    }

    private func onStatus(player: AVPlayer, change _: NSKeyValueObservedChange<AVPlayer.Status>) {
        switch player.status {
        case .failed:
            addEvent(.error)

        case .readyToPlay:
            addEvent(.loaded)

        default:
            break
        }
    }

    private func onTimeControlStatus(player: AVPlayer, change _: NSKeyValueObservedChange<AVPlayer.TimeControlStatus>) {
        let timeControlStatus = player.timeControlStatus
        if timeControlStatus == AVPlayer.TimeControlStatus.playing {
            addEvent(.play)
            addTimeObserver()
        } else if timeControlStatus == AVPlayer.TimeControlStatus.paused {
            addEvent(.pause)
            removeTimeObserver()
        }
    }
}
