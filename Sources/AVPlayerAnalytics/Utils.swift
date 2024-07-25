import Foundation

enum Utils {
    /// Parse media URL to get mediaId
    static func parseMediaUrl(_ mediaURL: URL) -> String? {
        let mediaUrlStr = mediaURL.absoluteString
        let pattern = "https://[^/]+/(?>(?<type>vod|live)/)?(?>.*/)?(?<id>(vi|li)[^/^.]*).*"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        guard let match = regex?.firstMatch(
            in: mediaUrlStr,
            range: NSRange(location: 0, length: mediaUrlStr.utf16.count)
        ) else {
            print("No match found for \(mediaUrlStr)")
            return nil
        }

        if let videoIdRange = Range(match.range(withName: "id"), in: mediaUrlStr) {
            return String(mediaUrlStr[videoIdRange])
        } else {
            print("Can not get video id from URL: \(mediaUrlStr)")
            return nil
        }
    }
}
