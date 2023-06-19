import XCTest

@testable import ApiVideoPlayerAnalytics

class OptionsTest: XCTestCase {
    func testValidVodFormerUrl() throws {
        let option = try Options(
            mediaUrl: "https://cdn.api.video/vod/vi5oNqxkifcXkT4auGNsvgZB/hls/manifest.m3u8"
        )
        XCTAssertEqual(option.videoInfo.videoId, "vi5oNqxkifcXkT4auGNsvgZB")
        XCTAssertEqual(option.videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(option.videoInfo.pingUrl.absoluteString, "https://collector.api.video/vod")
    }

    func testValidVodUrl() throws {
        let option = try Options(
            mediaUrl: "https://vod.api.video/vod/vi5oNqxkifcXkT4auGNsvgZB/hls/manifest.m3u8"
        )
        XCTAssertEqual(option.videoInfo.videoId, "vi5oNqxkifcXkT4auGNsvgZB")
        XCTAssertEqual(option.videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(option.videoInfo.pingUrl.absoluteString, "https://collector.api.video/vod")
    }

    func testValidPrivateVodUrl() throws {
        let option = try Options(
            mediaUrl: "https://vod.api.video/vod/vi5oNqxkifcXkT4auGNsvgZB/token/PRIVATE_TOKEN/hls/manifest.m3u8"
        )
        XCTAssertEqual(option.videoInfo.videoId, "vi5oNqxkifcXkT4auGNsvgZB")
        XCTAssertEqual(option.videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(option.videoInfo.pingUrl.absoluteString, "https://collector.api.video/vod")
    }

    func testValidLiveUrl() throws {
        let option = try Options(
            mediaUrl: "https://live.api.video/li77ACbZjzEJgmr8d0tm4xFt.m3u8"
        )
        XCTAssertEqual(option.videoInfo.videoId, "li77ACbZjzEJgmr8d0tm4xFt")
        XCTAssertEqual(option.videoInfo.videoType, VideoType.LIVE)
        XCTAssertEqual(option.videoInfo.pingUrl.absoluteString, "https://collector.api.video/live")
    }

    func testValidPrivateLiveUrl() throws {
        let option = try Options(
            mediaUrl: "https://live.api.video/private/PRIVATE_TOKEN/li77ACbZjzEJgmr8d0tm4xFt.m3u8"
        )
        XCTAssertEqual(option.videoInfo.videoId, "li77ACbZjzEJgmr8d0tm4xFt")
        XCTAssertEqual(option.videoInfo.videoType, VideoType.LIVE)
        XCTAssertEqual(option.videoInfo.pingUrl.absoluteString, "https://collector.api.video/live")
    }

    func testInvalidUrl() throws {
        XCTAssertThrowsError(
            try Options(
                mediaUrl: "https://mydomain/video.m3u8"
            )
        )
    }
}
