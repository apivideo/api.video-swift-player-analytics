import Foundation

protocol Requestable {
    func launch(completion: @escaping (Response) -> Void)
}

class Request: Requestable {
    private let session: URLSession
    private let request: URLRequest

    init(session: URLSession, request: URLRequest) {
        self.session = session
        self.request = request
    }

    func launch(completion: @escaping (Response) -> Void) {
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            completion(Response(data: data, response: response as? HTTPURLResponse, error: error))
        })
        task.resume()
    }
}
