import ApiVideoPlayerAnalytics
import AVFoundation
import AVKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var progressSlider: UISlider!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var videoControllerView: UIView!
    @IBOutlet var goForward15Button: UIButton!
    @IBOutlet var goBackward15Button: UIButton!

    let videoPlayerView = UIView()
    var player: AVPlayer!
    var asset: AVAsset!
    var playerItem: AVPlayerItem!
    var fromCMTime: CMTime!
    private var playerItemContext = 0
    let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]
    var timeObserver: Any?
    var playerAnalytics: PlayerAnalytics?
    var option: Options?
    var isFistPlayed = true
    let videoLink = "https://cdn.api.video/vod/YOUR_VIDEO_ID/hls/manifest.m3u8"
    var videoUrl: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: videoLink) else {
            return
        }
        videoUrl = url
        asset = AVAsset(url: videoUrl)
        playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: requiredAssetKeys)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
        NotificationCenter.default.addObserver(
            self, selector: #selector(playerDidFinishPlaying),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem
        )

        do {
            option = try Options(mediaUrl: videoLink, metadata: [["string 1": "String 2"], ["string 3": "String 4"]], onSessionIdReceived: { id in
                print("sessionid : \(id)")
            })
        } catch {
            print("error with the url")
        }

        playerAnalytics = PlayerAnalytics(options: option!)

        // Player
        // progressSlider.isContinuous = false

        videoPlayerView.backgroundColor = UIColor.black
        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)

        view.addSubview(videoPlayerView)
        view.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        view.sendSubviewToBack(videoPlayerView)
        progressSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupVideoPlayer()
    }

    func setupVideoPlayer() {
        player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoPlayerView.bounds
        videoPlayerView.layer.addSublayer(playerLayer)
        player?.isMuted = false
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { _ in
            self.updatePlayerState()
        })
        videoControllerView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.25)
        videoControllerView.layer.cornerRadius = 20
        timeRemainingLabel.textColor = UIColor.orange
        progressSlider.tintColor = UIColor.orange.withAlphaComponent(0.7)
        progressSlider.thumbTintColor = UIColor.orange
        playPauseButton.tintColor = UIColor.orange
        goForward15Button.tintColor = UIColor.orange
        goBackward15Button.tintColor = UIColor.orange
    }

    func updatePlayerState() {
        guard let currentTime = player?.currentTime() else { return }
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        progressSlider.value = Float(currentTimeInSeconds)
        if let currentItem = player?.currentItem {
            let duration = currentItem.duration
            if CMTIME_IS_INVALID(duration) {
                return
            }
            let currentTime = currentItem.currentTime()
            progressSlider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))

            // Update time remaining label
            let totalTimeInSeconds = CMTimeGetSeconds(duration)
            let remainingTimeInSeconds = totalTimeInSeconds - currentTimeInSeconds

            let mins = remainingTimeInSeconds / 60
            let secs = remainingTimeInSeconds.truncatingRemainder(dividingBy: 60)
            let timeformatter = NumberFormatter()
            timeformatter.minimumIntegerDigits = 2
            timeformatter.minimumFractionDigits = 0
            timeformatter.roundingMode = .down
            guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
                return
            }
            timeRemainingLabel.text = "\(minsStr):\(secsStr)"
        }
    }

    @IBAction func playPauseSelected(_: Any) {
        guard let player = player else { return }
        if !player.isPlaying {
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            if isFistPlayed {
                playerAnalytics?.play { result in
                    switch result {
                    case .success:
                        print("video played for the fist time")
                    case let .failure(error):
                        print("error when video played for the first time : \(error)")
                    }
                }
                isFistPlayed = false
            } else {
                playerAnalytics?.resume { result in
                    switch result {
                    case .success:
                        print("video played on resume")
                    case let .failure(error):
                        print("error when video played on resume : \(error)")
                    }
                }
            }
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player.pause()
            playerAnalytics?.pause { result in
                switch result {
                case .success:
                    print("video paused")
                case let .failure(error):
                    print("error when video paused : \(error)")
                }
            }
        }
    }

    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        guard let duration = player?.currentItem?.duration else { return }
        player.pause()

        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                // handle drag began
                fromCMTime = CMTime(value: CMTimeValue(Float64(slider.value) * CMTimeGetSeconds(duration)), timescale: 1)
            case .moved:
                // handle drag moved
                break
            case .ended:
                // handle drag ended
                let value = Float64(progressSlider.value) * CMTimeGetSeconds(duration)
                let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
                let currentTime = fromCMTime.seconds
                player.seek(to: seekTime)
                playerAnalytics?.seek(from: fromCMTime, to: seekTime) { result in
                    switch result {
                    case .success:
                        print("success seek")
                        self.player.play()
                    case let .failure(error):
                        print("error seek : \(error)")
                    }
                }
            default:
                break
            }
        }
    }

    @IBAction func goForward(_: Any) {
        guard let currentTime = player?.currentTime() else { return }
        let currentTimeInSecondsPlus15 = CMTimeGetSeconds(currentTime).advanced(by: 15)
        let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsPlus15), timescale: 1)
        player?.seek(to: seekTime)
        playerAnalytics?.seek(from: Float(CMTimeGetSeconds(currentTime)), to: Float(seekTime.seconds)) { result in
            switch result {
            case .success:
                print("success seek")
            case let .failure(error):
                print("error seek : \(error)")
            }
        }
    }

    @IBAction func goBackward(_: Any) {
        guard let currentTime = player?.currentTime() else { return }
        let currentTimeInSecondsMinus15 = CMTimeGetSeconds(currentTime).advanced(by: -15)
        let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsMinus15), timescale: 1)
        player?.seek(to: seekTime)
        playerAnalytics?.seek(from: Float(CMTimeGetSeconds(currentTime)), to: Float(seekTime.seconds)) { result in
            switch result {
            case .success:
                print("success seek")
            case let .failure(error):
                print("error seek : \(error)")
            }
        }
    }

    @objc func playerDidFinishPlaying(note _: NSNotification) {
        playerAnalytics?.end { result in
            switch result {
            case .success:
                print("success end")
                self.playerAnalytics?.destroy { result in
                    switch result {
                    case .success:
                        print("success destroy")
                    case .failure:
                        print("error destroy")
                    }
                }
            case .failure:
                print("error end")
            }
        }
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            // Switch over status value
            if status == .readyToPlay {
                playerAnalytics?.ready { result in
                    switch result {
                    case .success:
                        print("video is ready to be played")
                    case let .failure(error):
                        print("video is not ready to be played: \(error)")
                    }
                }
            }
        }
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
