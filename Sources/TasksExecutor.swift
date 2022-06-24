import Foundation

public class TasksExecutor: TasksExecutorProtocol {
    private let decoder = JSONDecoder()
    public static func execute(
        session: URLSession, request: URLRequest, completion: @escaping (Data?, Error?) -> Void
    ) {
        
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, error)            
        }
        task.resume()
    }
}
extension URLSession {
    
    enum HTTPError: Error {
        case transportError(Error)
        case serverSideError(Int)
    }
    
    typealias DataTaskResult = Result<(HTTPURLResponse, Data), Error>
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (DataTaskResult) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(Result.failure(HTTPError.transportError(error)))
                return
            }
            let response = response as! HTTPURLResponse
            let status = response.statusCode
            guard (200...299).contains(status) else {
                completionHandler(Result.failure(HTTPError.serverSideError(status)))
                return
            }
            completionHandler(Result.success((response, data!)))
        }
    }
}
