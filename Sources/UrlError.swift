import Foundation

public enum UrlError: Error {
    case malformedUrl(String)
    case invalidParameter(String)
    case urlResponseError(String)
}
