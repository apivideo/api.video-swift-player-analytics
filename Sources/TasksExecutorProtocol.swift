import Foundation

public protocol TasksExecutorProtocol {
    static func execute(
        session: URLSession, request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void
    )
}
