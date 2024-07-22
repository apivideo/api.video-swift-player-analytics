import Foundation

enum Utils {
    static func inferManifestURL(mediaId: String) -> URL {
        let url: URL?
        if mediaId.hasPrefix("vi") {
            url = URL(string: "https://vod.api.video/vod/\(mediaId)/hls/manifest.m3u8")
        } else if mediaId.hasPrefix("li") {
            url = URL(string: "https://live.api.video/\(mediaId).m3u8")
        } else {
            fatalError("Invalid mediaId: \(mediaId)")
        }
        guard let url else {
            fatalError("Invalid url for \(mediaId)")
        }
        return url
    }
}
