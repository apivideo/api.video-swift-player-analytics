import XCTest

@testable import ApiVideoPlayerAnalytics

class VideoInfoTest: XCTestCase {
    func testValidEmbedVodUrl() throws {
        let videoInfo = try VideoInfo.from(
            "https://embed.api.video/vod/vi5oNqxkifcXkT4auGNsvgZB"
        )
        XCTAssertEqual(videoInfo.videoId, "vi5oNqxkifcXkT4auGNsvgZB")
        XCTAssertEqual(videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(videoInfo.pingUrl.absoluteString, "https://collector.api.video/vod")
    }

    func testValidVodFormerUrl() throws {
        let videoInfo = try VideoInfo.from(
            "https://cdn.api.video/vod/vi5oNqxkifcXkT4auGNsvgZB/hls/manifest.m3u8"
        )
        XCTAssertEqual(videoInfo.videoId, "vi5oNqxkifcXkT4auGNsvgZB")
        XCTAssertEqual(videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(videoInfo.pingUrl.absoluteString, "https://collector.api.video/vod")
    }

    func testValidVodUrl() throws {
        let videoInfo = try VideoInfo.from(
            "https://vod.api.video/vod/vi5oNqxkifcXkT4auGNsvgZB/hls/manifest.m3u8"
        )
        XCTAssertEqual(videoInfo.videoId, "vi5oNqxkifcXkT4auGNsvgZB")
        XCTAssertEqual(videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(videoInfo.pingUrl.absoluteString, "https://collector.api.video/vod")
    }

    func testValidMp4Url() throws {
        let videoInfo = try VideoInfo.from(
            "https://vod.api.video/vod/vi5oNqxkifcXkT4auGNsvgZB/mp4/source.mp4"
        )
        XCTAssertEqual(videoInfo.videoId, "vi5oNqxkifcXkT4auGNsvgZB")
        XCTAssertEqual(videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(videoInfo.pingUrl.absoluteString, "https://collector.api.video/vod")
    }

    func testValidPrivateVodUrl() throws {
        let videoInfo = try VideoInfo.from(
            "https://vod.api.video/vod/vi5oNqxkifcXkT4auGNsvgZB/token/PRIVATE_TOKEN/hls/manifest.m3u8"
        )
        XCTAssertEqual(videoInfo.videoId, "vi5oNqxkifcXkT4auGNsvgZB")
        XCTAssertEqual(videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(videoInfo.pingUrl.absoluteString, "https://collector.api.video/vod")
    }

    func testValidEmbedLiveUrl() throws {
        let videoInfo = try VideoInfo.from(
            "https://embed.api.video/live/li77ACbZjzEJgmr8d0tm4xFt"
        )
        XCTAssertEqual(videoInfo.videoId, "li77ACbZjzEJgmr8d0tm4xFt")
        XCTAssertEqual(videoInfo.videoType, VideoType.LIVE)
        XCTAssertEqual(videoInfo.pingUrl.absoluteString, "https://collector.api.video/live")
    }

    func testValidLiveUrl() throws {
        let videoInfo = try VideoInfo.from(
            "https://live.api.video/li77ACbZjzEJgmr8d0tm4xFt.m3u8"
        )
        XCTAssertEqual(videoInfo.videoId, "li77ACbZjzEJgmr8d0tm4xFt")
        XCTAssertEqual(videoInfo.videoType, VideoType.LIVE)
        XCTAssertEqual(videoInfo.pingUrl.absoluteString, "https://collector.api.video/live")
    }

    func testValidPrivateLiveUrl() throws {
        let videoInfo = try VideoInfo.from(
            "https://live.api.video/private/PRIVATE_TOKEN/li77ACbZjzEJgmr8d0tm4xFt.m3u8"
        )
        XCTAssertEqual(videoInfo.videoId, "li77ACbZjzEJgmr8d0tm4xFt")
        XCTAssertEqual(videoInfo.videoType, VideoType.LIVE)
        XCTAssertEqual(videoInfo.pingUrl.absoluteString, "https://collector.api.video/live")
    }

    // Custom URL
    func testValidEmbedVodUrlWithCustomDomain() throws {
        let videoInfo = try VideoInfo.from(
            "https://mycustom.domain/vod/vi5oNqxkifcXkT4auGNsvgZB",
            collectorDomainURL: "https://mycustom.collector.domain"
        )
        XCTAssertEqual(videoInfo.videoId, "vi5oNqxkifcXkT4auGNsvgZB")
        XCTAssertEqual(videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(videoInfo.pingUrl.absoluteString, "https://mycustom.collector.domain/vod")
    }

    func testValidVodUrlWithCustomDomain() throws {
        let videoInfo = try VideoInfo.from(
            "https://mycustom.domain/vod/vi5oNqxkifcXkT4auGNsvgZB/hls/manifest.m3u8",
            collectorDomainURL: "https://mycustom.collector.domain"
        )
        XCTAssertEqual(videoInfo.videoId, "vi5oNqxkifcXkT4auGNsvgZB")
        XCTAssertEqual(videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(videoInfo.pingUrl.absoluteString, "https://mycustom.collector.domain/vod")
    }

    func testValidPrivateVodUrlWithCustomDomain() throws {
        let videoInfo = try VideoInfo.from(
            "https://mycustom.domain/vod/vi5oNqxkifcXkT4auGNsvgZB/token/PRIVATE_TOKEN/hls/manifest.m3u8",
            collectorDomainURL: "https://mycustom.collector.domain"
        )
        XCTAssertEqual(videoInfo.videoId, "vi5oNqxkifcXkT4auGNsvgZB")
        XCTAssertEqual(videoInfo.videoType, VideoType.VOD)
        XCTAssertEqual(videoInfo.pingUrl.absoluteString, "https://mycustom.collector.domain/vod")
    }

    func testValidEmbedLiveUrlWithCustomDomain() throws {
        let videoInfo = try VideoInfo.from(
            "https://mycustom.domain/live/li77ACbZjzEJgmr8d0tm4xFt",
            collectorDomainURL: "https://mycustom.collector.domain"
        )
        XCTAssertEqual(videoInfo.videoId, "li77ACbZjzEJgmr8d0tm4xFt")
        XCTAssertEqual(videoInfo.videoType, VideoType.LIVE)
        XCTAssertEqual(videoInfo.pingUrl.absoluteString, "https://mycustom.collector.domain/live")
    }

    func testValidLiveUrlWithCustomDomain() throws {
        let videoInfo = try VideoInfo.from(
            "https://mycustom.domain/li77ACbZjzEJgmr8d0tm4xFt.m3u8",
            collectorDomainURL: "https://mycustom.collector.domain"
        )
        XCTAssertEqual(videoInfo.videoId, "li77ACbZjzEJgmr8d0tm4xFt")
        XCTAssertEqual(videoInfo.videoType, VideoType.LIVE)
        XCTAssertEqual(videoInfo.pingUrl.absoluteString, "https://mycustom.collector.domain/live")
    }

    func testValidPrivateLiveUrlWithCustomDomain() throws {
        let videoInfo = try VideoInfo.from(
            "https://mycustom.domain/private/PRIVATE_TOKEN/li77ACbZjzEJgmr8d0tm4xFt.m3u8",
            collectorDomainURL: "https://mycustom.collector.domain"
        )
        XCTAssertEqual(videoInfo.videoId, "li77ACbZjzEJgmr8d0tm4xFt")
        XCTAssertEqual(videoInfo.videoType, VideoType.LIVE)
        XCTAssertEqual(videoInfo.pingUrl.absoluteString, "https://mycustom.collector.domain/live")
    }

    func testInvalidUrl() throws {
        XCTAssertThrowsError(
            try VideoInfo.from(
                "https://mydomain/video.m3u8"
            )
        )
    }
}
