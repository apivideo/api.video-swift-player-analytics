
import Foundation
public protocol TasksExecutorProtocol{    
    func execute(session: URLSession, request: URLRequest, completion: @escaping (Data?, Error?) -> ())
    
}
