//
//  File.swift
//  
//
//  Created by Romain Petit on 09/02/2022.
//

import Foundation
public class RequestsBuilder{
    
    private func genericUrLRequestBuilder(apiPath: String, tokenType: String, key: String, httpMethod: String) -> URLRequest{
        var request = URLRequest(url: URL(string: apiPath)!)
        //request.setValue("\(tokenType) \(key)", forHTTPHeaderField: "Authorization")
        //request.setValue("api.video SDK (ios; v:0.1.7; )", forHTTPHeaderField: "User-Agent")
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
//        sessionConfig.httpAdditionalHeaders = ["User-Agent": "api.video SDK (ios; v:0.1.7; )"]
        let session = URLSession(configuration: sessionConfig)
        return session
    }
    
}
