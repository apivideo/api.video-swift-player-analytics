import Foundation

public enum RequestsBuilder {
    private static func setContentType(request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    private static func buildPostUrlRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        setContentType(request: &request)
        request.httpMethod = "POST"
        return request
    }

    private static func buildUrlSession() -> URLSession {
        URLSession(configuration: URLSessionConfiguration.default)
    }

    static func sendPing(
        taskExecutor: TasksExecutorProtocol.Type,
        url: URL,
        payload: PlaybackPingMessage,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        var request = buildPostUrlRequest(url: url)
        let session = buildUrlSession()

        do {
            let encoder = JSONEncoder()
            let jsonPayload = try encoder.encode(payload)
            let data = String(data: jsonPayload, encoding: .utf8)!.data(using: .utf8)!
            let body = try (JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])!
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
        }

        taskExecutor.execute(session: session, request: request) { data, error in
            if let data = data {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] else {
                        completion(.failure(JSONError.castError("Could not cast json to [String: AnyObject]")))
                        return
                    }
                    guard let sessionId = json["session"] as? String else {
                        completion(.failure(JSONError.castError("Could not cast session Id from JSON")))
                        return
                    }
                    completion(.success(sessionId))
                } catch {
                    completion(.failure(error))
                }
            } else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    fatalError("No data nor error")
                }
            }
        }
    }
}
