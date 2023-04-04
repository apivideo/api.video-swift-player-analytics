//
//  Options.swift
//

import XCTest

@testable import ApiVideoPlayerAnalytics

class OptionsTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testValidVodFormerUrl() throws {
        let option = try Options(
            mediaUrl: "https://cdn.api.video/vod/vi5oNqxkifcXkT4auGNsvgZB/hls/manifest.m3u8",
            metadata: [[:]], onSessionIdReceived: nil, onPing: nil
        )
        XCTAssertEqual(option.videoInfo.videoId, "vi5oNqxkifcXkT4auGNsvgZB")
        XCTAssertEqual(option.videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(option.videoInfo.pingUrl.absoluteString, "https://collector.api.video/vod")
    }

    func testValidVodUrl() throws {
        let option = try Options(
            mediaUrl: "https://vod.api.video/vod/vi5oNqxkifcXkT4auGNsvgZB/hls/manifest.m3u8",
            metadata: [[:]], onSessionIdReceived: nil, onPing: nil
        )
        XCTAssertEqual(option.videoInfo.videoId, "vi5oNqxkifcXkT4auGNsvgZB")
        XCTAssertEqual(option.videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(option.videoInfo.pingUrl.absoluteString, "https://collector.api.video/vod")
    }

    func testValidLiveUrl() throws {
        let option = try Options(
            mediaUrl: "https://live.api.video/li77ACbZjzEJgmr8d0tm4xFt.m3u8", metadata: [[:]],
            onSessionIdReceived: nil, onPing: nil
        )
        XCTAssertEqual(option.videoInfo.videoId, "li77ACbZjzEJgmr8d0tm4xFt")
        XCTAssertEqual(option.videoInfo.videoType, VideoType.LIVE)
        XCTAssertEqual(option.videoInfo.pingUrl.absoluteString, "https://collector.api.video/live")
    }
    
    func testValidPrivateLiveUrl() throws {
        let option = try Options(
            mediaUrl: "https://live.api.video/PRIVATE_TOKEN/li77ACbZjzEJgmr8d0tm4xFt.m3u8", metadata: [[:]],
            onSessionIdReceived: nil, onPing: nil
        )
        XCTAssertEqual(option.videoInfo.videoId, "li77ACbZjzEJgmr8d0tm4xFt")
        XCTAssertEqual(option.videoInfo.videoType, VideoType.LIVE)
        XCTAssertEqual(option.videoInfo.pingUrl.absoluteString, "https://collector.api.video/live")
    }

    func testInvalidUrl() throws {
        XCTAssertThrowsError(
            try Options(
                mediaUrl: "https://mydomain/video.m3u8", metadata: [[:]], onSessionIdReceived: nil,
                onPing: nil
            ))
    }
}
