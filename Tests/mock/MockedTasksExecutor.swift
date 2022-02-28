
import Foundation
import ApiVideoPlayerAnalytics
class MockedTasksExecutor: TasksExecutorProtocol {
    static func execute(session: URLSession, request: URLRequest, completion: @escaping (Data?, Error?) -> ()) {
        execute(session: session, request: request){(data, error) in
            guard let url = Bundle(for: MockedTasksExecutor.self).url(forResource: "uploadSuccess", withExtension: "json"),
                  let data = try? Data(contentsOf: url)else{
                      completion(nil, nil)
                      return
                  }
            
            completion(data, nil)
        }
    }
    
    public static func executefailed(session: URLSession, request: URLRequest, completion: @escaping (Data?, Error?) -> ()){
        execute(session: session, request: request){(data, error) in
            guard let url = Bundle(for: MockedTasksExecutor.self).url(forResource: "uploadError", withExtension: "json"),
                  let data = try? Data(contentsOf: url)else{
                      completion(nil, nil)
                      return
                  }
            completion(data, error)
        }
    }
}
