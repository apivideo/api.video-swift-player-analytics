import XCTest

@testable import ApiVideoPlayerAnalytics

@available(iOS 10.0, *)
final class PlayerAnalyticsTests: XCTestCase {
    func testPlayVodSuccess() throws {
        let expectationSuccess = expectation(description: "Expect a success POST of play event")

        let option = try Options(
            mediaUrl: "https://vod.api.video/vod/\(VideoIds.validVodVideoId)/hls/manifest.m3u8",
            metadata: ["string 1": "String 2", "string 3": "String 4"],
            onSessionIdReceived: { _ in
            }
        )
        let api = PlayerAnalytics(options: option)
        api.play { result in
            switch result {
            case .success: expectationSuccess.fulfill()
            default: break
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testPlayLiveSuccess() throws {
        let expectationSuccess = expectation(description: "Expect a success POST of play event")

        let option = try Options(
            mediaUrl: "https://live.api.video/\(VideoIds.validLiveStreamId).m3u8",
            metadata: ["string 1": "String 2", "string 3": "String 4"],
            onSessionIdReceived: { _ in
            }
        )
        let api = PlayerAnalytics(options: option)
        api.play { result in
            switch result {
            case .success: expectationSuccess.fulfill()
            default: break
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testPauseVodSuccess() throws {
        let expectationSuccess = expectation(description: "Expect a success POST of pause event")

        let option = try Options(
            mediaUrl: "https://vod.api.video/vod/\(VideoIds.validVodVideoId)/hls/manifest.m3u8",
            metadata: ["string 1": "String 2", "string 3": "String 4"],
            onSessionIdReceived: { _ in
            }
        )
        let api = PlayerAnalytics(options: option)
        api.pause { result in
            switch result {
            case .success: expectationSuccess.fulfill()
            default: break
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testPauseLiveSuccess() throws {
        let expectationSuccess = expectation(description: "Expect a success POST of pause event")

        let option = try Options(
            mediaUrl: "https://live.api.video/\(VideoIds.validLiveStreamId).m3u8",
            metadata: ["string 1": "String 2", "string 3": "String 4"],
            onSessionIdReceived: { _ in
            }
        )
        let api = PlayerAnalytics(options: option)
        api.pause { result in
            switch result {
            case .success: expectationSuccess.fulfill()
            default: break
            }
        }
        waitForExpectations(timeout: 10)
    }
}
