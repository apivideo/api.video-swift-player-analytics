import AVFoundation
import Foundation

extension AVError {
    var analyticsErrorCode: ErrorCode {
        switch code {
        case .contentIsUnavailable, .noLongerPlayable:
            return .network

        case .decodeFailed:
            return .decoding

        // case .decoderNotFound, .decoderTemporarilyUnavailable, .formatUnsupported, .incompatibleAsset:
        default: return .noSupport // Nothing
        }
    }
}
