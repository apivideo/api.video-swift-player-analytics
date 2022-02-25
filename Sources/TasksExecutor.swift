
import Foundation
public class TasksExecutor: TasksExecutorProtocol{
    private let decoder = JSONDecoder()
    public static func execute(session: URLSession, request: URLRequest, completion: @escaping (Data?, Error?) -> ()){
        
        let task = session.dataTask(with: request){(data, response, error) in
            completion(data, error)
        }
        task.resume()
    }
}

