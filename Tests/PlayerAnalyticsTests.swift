import XCTest
@testable import ApiVideoPlayerAnalytics

@available(iOS 10.0, *)
final class PlayerAnalyticsTests: XCTestCase {
    func testSuccessTask() throws {
        let task = MockedTasksExecutor()
        guard let url = Bundle(for: MockedTasksExecutor.self).url(forResource: "uploadSuccess", withExtension: "json"),
              let returnData = try? Data(contentsOf: url)else{
                  return
              }
        
        let request = RequestsBuilder().postClientUrlRequestBuilder(apiPath: "url")
        let session = RequestsBuilder().buildUrlSession()

        task.execute(session: session, request: request){ (data, response) in
            XCTAssertEqual(returnData, data)
            XCTAssertNil(response)
        }
        
    }
    
    func testErrorTask() throws {
        let task = MockedTasksExecutor()
        
        let request = RequestsBuilder().postClientUrlRequestBuilder(apiPath: "url")
        let session = RequestsBuilder().buildUrlSession()

        task.executefailed(session: session, request: request){ (data, response) in
            XCTAssertNotNil(response)
        }
    }
    
    @available(iOS 11.0, *)
    func testPlaySuccess() throws{
        var isSuccess = false
        let option = try Options(mediaUrl: "https://cdn.api.video/vod/vi21aJxFa0A1AFM6FPVmjnhA/hls/manifest.m3u8", metadata: [["string 1": "String 2"], ["string 3": "String 4"]], onSessionIdReceived: { (id) in
        })
        let api = PlayerAnalytics(options: option)
        api.play(){ (result) in
            switch result{
            case .success(_):
                isSuccess = true
            case .failure(_):
                isSuccess = false
            }
            XCTAssertTrue(isSuccess)
        }
    }
}
