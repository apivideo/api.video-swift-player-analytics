@testable import ApiVideoPlayerAnalytics
import XCTest

class EventTest: XCTestCase {
    private let jsonEncoder = JSONEncoder()

    override func setUp() {
        jsonEncoder.outputFormatting = .sortedKeys
    }

    func testSerialization() {
        let expected = """
        {"eat":1710147604622,"eco":0,"pau":false,"typ":2,"vhe":1280,"vti":0.1,"vwi":720}
        """
        let event = Event(
            emittedAtInMs: 1_710_147_604_622,
            type: .play,
            videoTimeInS: 0.1,
            videoWidth: 720,
            videoHeight: 1_280,
            paused: false,
            errorCode: .none
        )
        do {
            let actual = try jsonEncoder.encode(event)
            XCTAssertEqual(expected, String(data: actual, encoding: .utf8))
        } catch {
            XCTFail("Failed to encode Event: \(error)")
        }
    }

    func testEquality() {
        let event1 = Event(
            emittedAtInMs: 1_710_147_604_622,
            type: .play,
            videoTimeInS: 0.1,
            videoWidth: 720,
            videoHeight: 1_280,
            paused: false,
            errorCode: .none
        )
        let event2 = Event(
            emittedAtInMs: 1_710_147_604_623,
            type: .play,
            videoTimeInS: 0.3,
            videoWidth: 480,
            videoHeight: 640,
            paused: false,
            errorCode: .abort
        )
        XCTAssertEqual(event1, event2)

        // Test different types
        let event3 = Event(
            emittedAtInMs: 1_710_147_604_622,
            type: .pause,
            videoTimeInS: 0.1,
            videoWidth: 720,
            videoHeight: 1_280,
            paused: false,
            errorCode: .none
        )
        XCTAssertNotEqual(event1, event3)

        // Test different paused
        let event4 = Event(
            emittedAtInMs: 1_710_147_604_622,
            type: .play,
            videoTimeInS: 0.1,
            videoWidth: 720,
            videoHeight: 1_280,
            paused: true,
            errorCode: .none
        )
        XCTAssertNotEqual(event1, event4)
    }
}
