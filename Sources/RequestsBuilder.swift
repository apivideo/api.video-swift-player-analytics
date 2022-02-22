
import Foundation
public class RequestsBuilder{
    
    private func genericUrLRequestBuilder(apiPath: String, tokenType: String, key: String, httpMethod: String) -> URLRequest{
        var request = URLRequest(url: URL(string: apiPath)!)
        request.httpMethod = httpMethod
        return request
    }
    
    
    private func setContentType(request: inout URLRequest){
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    public func postClientUrlRequestBuilder(apiPath: String) -> URLRequest{
        var request = URLRequest(url: URL(string: apiPath)!)
        setContentType(request: &request)
        request.httpMethod = "POST"
        return request
    }
    
    public func urlSessionBuilder() -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        return session
    }
    
}
