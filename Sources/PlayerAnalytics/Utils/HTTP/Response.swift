import Foundation

func json(_ data: Data?) -> Any? {
    guard let data = data else { return nil }
    return try? JSONSerialization.jsonObject(with: data, options: [])
}

func string(_ data: Data?) -> String? {
    guard let data = data else { return nil }
    return String(data: data, encoding: .utf8)
}

struct Response {
    let data: Data?
    let response: HTTPURLResponse?
    let error: Error?

    func result() throws -> Any? {
        guard error == nil else {
            throw AnalyticsAPIError(description: "Unknown error", statusCode: response?.statusCode ?? 0)
        }
        guard let response = response else { throw AnalyticsAPIError(description: nil) }
        guard (200 ... 300).contains(response.statusCode) else {
            if let json = json(data) as? [String: Any] {
                throw AnalyticsAPIError(info: json, statusCode: response.statusCode)
            }
            throw AnalyticsAPIError(from: self)
        }
        guard let data = data, !data.isEmpty else {
            if response.statusCode == 204 {
                return nil
            }
            // Not using the custom initializer because data could be empty
            throw AnalyticsAPIError(description: nil, statusCode: response.statusCode)
        }
        if let json = json(data) {
            return json
        }
        throw AnalyticsAPIError(from: self)
    }
}
