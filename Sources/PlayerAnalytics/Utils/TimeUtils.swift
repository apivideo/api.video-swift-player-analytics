import Foundation

enum TimeUtils {
    static func currentTimeInMs() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1_000)
    }
}
