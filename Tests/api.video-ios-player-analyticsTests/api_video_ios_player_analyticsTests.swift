import XCTest
@testable import api_video_ios_player_analytics

@available(iOS 10.0, *)
final class api_video_ios_player_analyticsTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(api_video_ios_player_analytics().text, "Hello, World!")
    }
    
    func testPlay() throws {
        api_video_ios_player_analytics().schedule()
        
    }
}
