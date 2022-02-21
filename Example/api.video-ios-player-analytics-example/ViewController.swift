//
//  ViewController.swift
//  api.video-ios-player-analytics-example
//
//  Created by Romain Petit on 02/02/2022.
//

import UIKit
import AVFoundation
import AVKit
import api_video_ios_player_analytics

class ViewController: UIViewController {
    @IBOutlet weak var videoUrlTextField: UITextField!
    var api: api_video_ios_player_analytics?
    var option: Options?
    var player: AVPlayer? = nil
    let controller = AVPlayerViewController()
    private var isFirstPlay = true
    
    private var videoUrl = "https://cdn.api.video/vod/vi7VQtn7FQgpxfF3s6cCgO8H/hls/manifest.m3u8"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //api_video_ios_player_analytics().schedule()
        videoUrlTextField.text = videoUrl
        do{
            option = try Options(mediaUrl: videoUrl, metadata: [["string 1": "String 2"], ["string 3": "String 4"]], onSessionIdReceived: { (id) in
                print("session ID : \(id)")
            })
        }catch{
            print("error with the url")
        }
        print(option!.videoInfo.videoType.rawValue)
        
        api = api_video_ios_player_analytics(options: option!)
    }
    
    private func setupAVPlayer() {
        player!.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        player!.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
                
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("dismiss player")
        self.controller.dismiss(animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as AnyObject? === player {
            if keyPath == "status" {
                if player!.status == .readyToPlay {
                    self.api?.ready {
                        print("ready done")
                    }
                }
            } else if keyPath == "rate" {
                if player!.rate > 0 {
                    if(isFirstPlay){
                        self.api!.play {
                            print("api play")
                        }
                    }else{
                        self.api!.resume {
                            print("api resume")
                        }
                    }
                    
                } else {
                    self.api!.pause {
                        print("api pause")
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
        present(controller, animated: true) {}
        
    }
}
