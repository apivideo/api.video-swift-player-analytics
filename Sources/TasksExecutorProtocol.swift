
import Foundation
public protocol TasksExecutorProtocol{
    func execute(session: URLSession, request: URLRequest, group: DispatchGroup?, completion: @escaping (Data?, Error?) -> ())
    
    func execute(session: URLSession, request: URLRequest, completion: @escaping (Data?, Error?) -> ())
    
}
