import Foundation

protocol AnalyticsError: LocalizedError, CustomDebugStringConvertible {
    /// The underlying `Error` value, if any.
    var cause: Error? { get }
}

extension AnalyticsError {
    /// The underlying `Error` value, if any. Defaults to `nil`.
    var cause: Error? { nil }

    /// Description of the error for debugging.
    var localizedDescription: String {
        debugDescription
    }

    /// Description of the error for debugging.
    var errorDescription: String? {
        debugDescription
    }
}

extension AnalyticsError {
    func appendCause(to errorMessage: String) -> String {
        guard let cause = cause else {
            return errorMessage
        }

        let separator = errorMessage.hasSuffix(".") ? "" : "."
        return "\(errorMessage)\(separator) Cause: \(String(describing: cause))"
    }
}

protocol AnalyticsAPIErrorProtocol: AnalyticsError {
    /// The HTTP status code associated with the error.
    var statusCode: Int { get }

    /// Additional information about the error.
    var info: [String: Any] { get }

    /// Creates an error
    init(info: [String: Any], statusCode: Int)
}

extension AnalyticsAPIErrorProtocol {
    init(info: [String: Any], statusCode: Int = 0) {
        self.init(info: info, statusCode: statusCode)
    }

    init(cause error: Error, statusCode: Int = 0) {
        let info: [String: Any] = [
            "description": "Unable to complete the operation.",
            "cause": error
        ]
        self.init(info: info, statusCode: statusCode)
    }

    init(description: String?, statusCode: Int = 0) {
        let info: [String: Any] = [
            "description": description ?? "Empty response body."
        ]
        self.init(info: info, statusCode: statusCode)
    }

    init(from response: Response) {
        self.init(description: string(response.data), statusCode: response.response?.statusCode ?? 0)
    }
}

struct AnalyticsAPIError: AnalyticsAPIErrorProtocol {
    /// Additional information about the error.
    let info: [String: Any]

    /// HTTP status code of the response.
    let statusCode: Int

    /// Creates an error from a JSON response.
    ///
    /// - Parameters:
    ///   - info:       JSON response from Auth0.
    ///   - statusCode: HTTP status code of the response.
    ///
    /// - Returns: A new `ManagementError`.
    init(info: [String: Any], statusCode: Int) {
        var values = info
        values["statusCode"] = statusCode
        self.info = values
        self.statusCode = statusCode
    }

    /// The underlying `Error` value, if any. Defaults to `nil`.
    var cause: Error? {
        info["cause"] as? Error
    }

    var message: String {
        if let string = info["description"] as? String {
            return string
        }
        return "Failed with unknown error \(info)."
    }

    /// Description of the error for debugging.
    public var debugDescription: String {
        appendCause(to: message)
    }
}
