
import Foundation
import api_video_ios_player_analytics
class MockedTasksExecutor: TasksExecutorProtocol {
    func execute(session: URLSession, request: URLRequest, group: DispatchGroup?, completion: @escaping (Data?, Response?) -> ()) {
        completion(nil, nil)
    }
    
    public func execute(session: URLSession, request: URLRequest, completion: @escaping (Data?, Response?) -> ()){
        execute(session: session, request: request, group: nil){(data, response) in
            guard let url = Bundle(for: MockedTasksExecutor.self).url(forResource: "uploadSuccess", withExtension: "json"),
                  let data = try? Data(contentsOf: url)else{
                      completion(nil, nil)
                      return
                  }
            
            completion(data, nil)
        }
    }
    
    public func executefailed(session: URLSession, request: URLRequest, completion: @escaping (Data?, Response?) -> ()){
        execute(session: session, request: request, group: nil){(data, response) in
            guard let url = Bundle(for: MockedTasksExecutor.self).url(forResource: "uploadError", withExtension: "json"),
                  let data = try? Data(contentsOf: url)else{
                      completion(nil, nil)
                      return
                  }
            let resp = Response(url: "url", statusCode: "400", message: "error")
            
            completion(data, resp)
        }
    }
}
