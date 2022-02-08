//
//  ViewController.swift
//  api.video-ios-player-analytics-example
//
//  Created by Romain Petit on 02/02/2022.
//

import UIKit
import api_video_ios_player_analytics

class ViewController: UIViewController {
    
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
            let option = try Options.init(mediaUrl: "video/vod/vi5oDagRVJBSKHxSiPux5rYD/hls/manifest.m3u8", metadata: ["string 1": "String 2"])
            print(option.videoInfo.videoType.rawValue)
        }catch{
            
        }
        // Do any additional setup after loading the view.
    }
    
    
}

