
import Foundation
public class RequestsBuilder{
    
    private func setContentType(request: inout URLRequest){
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    public func postClientUrlRequestBuilder(apiPath: String) -> URLRequest{
        var request = URLRequest(url: URL(string: apiPath)!)
        setContentType(request: &request)
        request.httpMethod = "POST"
        return request
    }
    
    public func buildUrlSession() -> URLSession {
        return URLSession(configuration: URLSessionConfiguration.default)
    }
    
}
