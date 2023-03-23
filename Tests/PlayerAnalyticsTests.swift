import XCTest

@testable import ApiVideoPlayerAnalytics

@available(iOS 10.0, *)
final class PlayerAnalyticsTests: XCTestCase {
    func testSuccessTask() throws {
        guard
            let url = Bundle(for: MockedTasksExecutor.self).url(
                forResource: "uploadSuccess", withExtension: "json"
            ),
            let returnData = try? Data(contentsOf: url)
        else {
            return
        }

        let request = RequestsBuilder().postClientUrlRequestBuilder(apiPath: "url")
        let session = RequestsBuilder().buildUrlSession()
        MockedTasksExecutor.execute(session: session, request: request) { data, response in
            XCTAssertEqual(returnData, data)
            XCTAssertNil(response)
        }
    }

    func testErrorTask() throws {
        let request = RequestsBuilder().postClientUrlRequestBuilder(apiPath: "url")
        let session = RequestsBuilder().buildUrlSession()

        MockedTasksExecutor.executefailed(session: session, request: request) { _, response in
            XCTAssertNotNil(response)
        }
    }

    @available(iOS 11.0, *)
    func testPlaySuccess() throws {
        var isSuccess = false
        let option = try Options(
            mediaUrl: "https://vod.api.video/vod/vi21aJxFa0A1AFM6FPVmjnhA/hls/manifest.m3u8",
            metadata: [["string 1": "String 2"], ["string 3": "String 4"]],
            onSessionIdReceived: { _ in
            }
        )
        let api = PlayerAnalytics(options: option)
        api.play { result in
            switch result {
            case .success:
                isSuccess = true
            case .failure:
                isSuccess = false
            }
            XCTAssertTrue(isSuccess)
        }
    }
}
