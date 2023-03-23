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
            mediaUrl: "https://cdn.api.video/vod/YOUR_VIDEO_ID/hls/manifest.m3u8",
            metadata: [[:]], onSessionIdReceived: nil, onPing: nil
        )
        XCTAssertEqual(option.videoInfo.videoId, "YOUR_VIDEO_ID")
        XCTAssertEqual(option.videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(option.videoInfo.pingUrl, "https://collector.api.video/vod")
    }

    func testValidVodUrl() throws {
        let option = try Options(
            mediaUrl: "https://vod.api.video/vod/YOUR_VIDEO_ID/hls/manifest.m3u8",
            metadata: [[:]], onSessionIdReceived: nil, onPing: nil
        )
        XCTAssertEqual(option.videoInfo.videoId, "YOUR_VIDEO_ID")
        XCTAssertEqual(option.videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(option.videoInfo.pingUrl, "https://collector.api.video/vod")
    }

    func testValidLiveUrl() throws {
        let option = try Options(
            mediaUrl: "https://live.api.video/YOUR_LIVE_STREAM_ID.m3u8", metadata: [[:]],
            onSessionIdReceived: nil, onPing: nil
        )
        XCTAssertEqual(option.videoInfo.videoId, "YOUR_LIVE_STREAM_ID")
        XCTAssertEqual(option.videoInfo.videoType, VideoType.LIVE)
        XCTAssertEqual(option.videoInfo.pingUrl, "https://collector.api.video/live")
    }

    func testInvalidUrl() throws {
        XCTAssertThrowsError(
            try Options(
                mediaUrl: "https://mydomain/video.m3u8", metadata: [[:]], onSessionIdReceived: nil,
                onPing: nil
            ))
    }
}
