import ApiVideoPlayerAnalytics
import Foundation

class MockedTasksExecutor: TasksExecutorProtocol {
  static func execute(
    session: URLSession, request: URLRequest, completion: @escaping (Data?, Error?) -> Void
  ) {
    guard
      let url = Bundle(for: MockedTasksExecutor.self).url(
        forResource: "uploadSuccess", withExtension: "json")
    else {
      completion(nil, nil)
      return
    }
    guard let data = try? Data(contentsOf: url) else {
      completion(nil, nil)
      return
    }
    completion(data, nil)
  }

  public static func executefailed(
    session: URLSession, request: URLRequest, completion: @escaping (Data?, Error?) -> Void
  ) {
    let error = UrlError.malformedUrl("error media url")
    completion(nil, error)
  }
}
