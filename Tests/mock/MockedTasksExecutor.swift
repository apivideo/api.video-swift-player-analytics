import ApiVideoPlayerAnalytics
import Foundation

class MockedTasksExecutor: TasksExecutorProtocol {
    enum MockedTaskExecutorError: Error {
        case resourceNotFound(String)
        case invalidData(String)
        case testError(String)
    }
    
    static func execute(
        session _: URLSession, request _: URLRequest, completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard
            let url = Bundle(for: MockedTasksExecutor.self).url(
                forResource: "uploadSuccess", withExtension: "json"
            ) else
        {
            completion(.failure(MockedTaskExecutorError.resourceNotFound("uploadSuccess.json")))
            return
        }
        guard let data = try? Data(contentsOf: url) else {
            completion(.failure(MockedTaskExecutorError.invalidData("for \(url)")))
            return
        }
        completion(.success(data))
    }

    public static func executefailed(
        session _: URLSession, request _: URLRequest, completion: @escaping (Result<Data, Error>) -> Void
    ) {
        completion(.failure(MockedTaskExecutorError.testError("dummy error for test")))
    }
}
