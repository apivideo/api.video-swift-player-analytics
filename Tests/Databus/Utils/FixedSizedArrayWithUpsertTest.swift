@testable import ApiVideoPlayerAnalytics
import XCTest

class FixedSizedArrayWithUpsertTest: XCTestCase {
    func testUpsert() throws {
        let expected = ["a", "b"]

        let actual = FixedSizedArrayWithUpsert<String>(maxSize: 2)
        actual.upsert("a")
        actual.upsert("b")
        actual.upsert("b")
        XCTAssertEqual(expected, actual.array)
    }

    func testListSize() throws {
        let expected = ["b", "c"]

        let actual = FixedSizedArrayWithUpsert<String>(maxSize: 2)
        actual.upsert("a")
        actual.upsert("b")
        actual.upsert("c")
        XCTAssertEqual(expected, actual.array)
    }
}
