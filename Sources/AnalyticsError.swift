import Foundation

public enum AnalyticsError: Error {
    case malformedUrl(String)
    case invalidParameter(String)
    case urlResponseError(String)
}
