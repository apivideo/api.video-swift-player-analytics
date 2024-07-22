import Foundation

/// An enum representing an error code that is emitted by the player.
enum ErrorCode: Int, Codable {
    /// No error
    case none = 0
    /// The action was aborted by user.
    case abort = 1
    /// Some kind of network error occurred which prevented the media from being successfully fetched, despite having previously been available.
    case network = 2
    /// Despite having previously been determined to be usable, an error occurred while trying to decode the media resource, resulting in an error.
    case decoding = 3
    /// The media resource was determined to be unsuitable.
    case noSupport = 4
}
