import XCTest
@testable import api_video_ios_player_analytics

@available(iOS 10.0, *)
final class api_video_ios_player_analyticsTests: XCTestCase {
    func testSuccessTask() throws {
        let task = MockedTasksExecutor()
        guard let url = Bundle(for: MockedTasksExecutor.self).url(forResource: "uploadSuccess", withExtension: "json"),
              let returnData = try? Data(contentsOf: url)else{
                  return
              }
        
        let request = RequestsBuilder().postClientUrlRequestBuilder(apiPath: "url")
        let session = RequestsBuilder().urlSessionBuilder()

        task.execute(session: session, request: request){ (data, response) in
            XCTAssertEqual(returnData, data)
            XCTAssertNil(response)
        }
        
    }
    
    func testErrorTask() throws {
        let task = MockedTasksExecutor()
        
        let request = RequestsBuilder().postClientUrlRequestBuilder(apiPath: "url")
        let session = RequestsBuilder().urlSessionBuilder()

        task.executefailed(session: session, request: request){ (data, response) in
            XCTAssertNotNil(response)
        }
        
    }
}
