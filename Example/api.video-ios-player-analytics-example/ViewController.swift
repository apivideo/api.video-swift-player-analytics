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
    var api: api_video_ios_player_analytics?
    var option: Options?
    var player: AVPlayer? = nil
    let controller = AVPlayerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //api_video_ios_player_analytics().schedule()
        let liveStr = "live"
        let vodStr = "vod"
        let vODStr = "VOD"
        let toto = "toto"
        var videoTypeLive: VideoType?
        var videoTypeVod: VideoType?
        var videoTypeVOD: VideoType?
        var videoTypeToto: VideoType?
        let session = Session.buildLiveStreamSession(sessionId: "id", loadedAt: "ajd", livestreamId: "icjeioheoi", referrer: "ref", metadata: [[:]])
        print(session)
        
        //        guard let videoType = toto.toVideoType() else { return VideoType.LIVE }
        do{
            videoTypeLive = try liveStr.toVideoType()
            print(videoTypeLive ?? "error")
            videoTypeVod = try vodStr.toVideoType()
            print(videoTypeVod ?? "error")
            videoTypeVOD = try vODStr.toVideoType()
            print(videoTypeVOD ?? "error")
            videoTypeToto = try toto.toVideoType()
            print(videoTypeToto as Any)
            
        } catch{
            print(error)
        }
        do{
            option = try Options(mediaUrl: "https://cdn.api.video/vod/vi7VQtn7FQgpxfF3s6cCgO8H/hls/manifest.m3u8", metadata: [["string 1": "String 2"], ["string 3": "String 4"]], onSessionIdReceived: { (id) in
                print("session ID : \(id)")
            })
            
            
            
        }catch{
            print("error with the url")
        }
        print(option!.videoInfo.videoType.rawValue)
        api = api_video_ios_player_analytics(options: option!)
        // Do any additional setup after loading the view.
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
            } else if keyPath == "timeControlStatus" {
                if #available(iOS 10.0, *) {
                    if player!.timeControlStatus == .playing {
                        print("it's Playing")
                    } else {
                        print("it's not Playing")
                    }
                }
            } else if keyPath == "rate" {
                if player!.rate > 0 {
                    self.api!.play {
                        print("api play")
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
        
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
        player = AVPlayer(url: URL(string: "https://cdn.api.video/vod/vi6H2fJmGLjUX2novcT0EyWs/hls/manifest.m3u8")!)
        
        // Create a new AVPlayerViewController and pass it a reference to the player.
        
        self.controller.player = player
        
        setupAVPlayer()
        
        
        // Modally present the player and call the player's play() method when complete.
        present(controller, animated: true) {
                    
        }
    }
    
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
