
import Foundation
import ApiVideoPlayerAnalytics
class MockedTasksExecutor: TasksExecutorProtocol {
    func execute(session: URLSession, request: URLRequest, group: DispatchGroup?, completion: @escaping (Data?, Error?) -> ()) {
        
    }
    
    
    public func execute(session: URLSession, request: URLRequest, completion: @escaping (Data?, Error?) -> ()){
        execute(session: session, request: request, group: nil){(data, error) in
            guard let url = Bundle(for: MockedTasksExecutor.self).url(forResource: "uploadSuccess", withExtension: "json"),
                  let data = try? Data(contentsOf: url)else{
                      completion(nil, nil)
                      return
                  }
            
            completion(data, nil)
        }
    }
    
    public func executefailed(session: URLSession, request: URLRequest, completion: @escaping (Data?, Error?) -> ()){
        execute(session: session, request: request, group: nil){(data, error) in
            guard let url = Bundle(for: MockedTasksExecutor.self).url(forResource: "uploadError", withExtension: "json"),
                  let data = try? Data(contentsOf: url)else{
                      completion(nil, nil)
                      return
                  }
            completion(data, error)
        }
    }
}
