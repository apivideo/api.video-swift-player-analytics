import ApiVideoPlayerAnalytics
import AVFoundation
import AVKit
import UIKit

class ViewController: UIViewController {
    private let player = ApiVideoAnalyticsAVPlayer(playerItem: nil)
    private let playerViewController = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Replace with your media ID (either your video ID or your live stream ID)
        let url = Utils.inferManifestURL(mediaId: "vi77Dgk0F8eLwaFOtC5870yn")
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.view.frame = view.frame
        playerViewController.player = player
    }
}
