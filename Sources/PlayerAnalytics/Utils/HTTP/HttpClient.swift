import Foundation

class HttpClient {
    private let session = URLSession(configuration: .default)
    private let url: URL

    init(_ url: URL) {
        self.url = url
    }

    func post(_ codable: Encodable, completion: @escaping (Response) -> Void) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(codable)
            post(data, completion: completion)
        } catch {
            completion(Response(data: nil, response: nil, error: error))
        }
    }

    func post(_ data: Data, completion: @escaping (Response) -> Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let request = Request(session: session, request: urlRequest)
        request.launch(completion: completion)
    }
}
