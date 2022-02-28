import AVFoundation
import AVKit
import ApiVideoPlayerAnalytics
import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var videoUrlTextField: UITextField!
  var api: PlayerAnalytics?
  var option: Options?
  var player: AVPlayer? = nil
  let controller = AVPlayerViewController()
  private var isFirstPlay = true

  private var videoUrl = "https://cdn.api.video/vod/vi21aJxFa0A1AFM6FPVmjnhA/hls/manifest.m3u8"

  override func viewDidLoad() {
    super.viewDidLoad()
    videoUrlTextField.text = videoUrl
    do {
      option = try Options(
        mediaUrl: videoUrl, metadata: [["string 1": "String 2"], ["string 3": "String 4"]],
        onSessionIdReceived: { (id) in
          print("session ID : \(id)")
        })
    } catch {
      print("error with the url")
    }
    print(option!.videoInfo.videoType.rawValue)

    api = PlayerAnalytics(options: option!)
  }

  private func setupAVPlayer() {
    player!.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
    player!.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(playerDidFinishPlaying),
      name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)

  }

  @objc func playerDidFinishPlaying(note: NSNotification) {
    print("dismiss player")
    self.controller.dismiss(animated: true)
  }

  override func observeValue(
    forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    if object as AnyObject? === player {
      if keyPath == "status" {
        if player!.status == .readyToPlay {
          self.api?.ready { (error) in
            print("ready done")
          }
        }
      } else if keyPath == "rate" {
        if player!.rate > 0 {
          if isFirstPlay {
            self.api!.play { (result) in
              switch result {
              case .success(let data):
                print("play")
                print(data)
              case .failure(let error):
                print(error)
              }
            }

          } else {
            self.api!.resume { (result) in
              switch result {
              case .success(let data):
                print("resume")
                print(data)
              case .failure(let error):
                print(error)
              }
            }
          }

        } else {
          self.api!.pause { (result) in
            switch result {
            case .success(let data):
              print("pause")
              print(data)
            case .failure(let error):
              print(error)
            }
          }
        }
      }
    }
  }

  @IBAction func playVideo(_ sender: Any) {
    player = AVPlayer(playerItem: nil)
    player?.replaceCurrentItem(with: AVPlayerItem(url: URL(string: videoUrlTextField.text!)!))
    self.controller.player = player
    setupAVPlayer()
    //let seekTime = PlayerPlaybackT
    //        let seekTime = PlayerPlaybackTimeFormatter.getConvertedCMTimeByProgress(player: player, progress: progressWhenSliderIsReleased)
    //        player!.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
    //            guard let `self` = self else { return }
    //            print("Player time after seeking: \(CMTimeGetSeconds(self.player.currentTime()))")
    //        }
    present(controller, animated: true) {}

  }
}
