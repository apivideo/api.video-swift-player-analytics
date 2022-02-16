//
//  File.swift
//  
//
//  Created by Romain Petit on 09/02/2022.
//

import Foundation
public class TasksExecutor{
    private let decoder = JSONDecoder()
    public func execute(session: URLSession, request: URLRequest, group: DispatchGroup?, completion: @escaping (Data?, Response?) -> ()){
        var resp: Response? = nil
        var task: URLSessionTask?
        task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            let httpResponse = response as? HTTPURLResponse
            let statuscode = httpResponse?.statusCode
            print("statuscode : \(statuscode)")
            switch statuscode!{
            case 200 ... 299:
                task?.cancel()
                completion(data, resp)
            case 400, 401, 404:
                let json = try? JSONSerialization.jsonObject(with: data!) as? Dictionary<String, AnyObject>
                print("error json : \(json)")
                if(json != nil){
                    let data: Data? = nil
                    let stringStatus = String(json!["status"] as? Int ?? httpResponse!.statusCode)
                    resp = Response(url: json!["type"] as? String, statusCode: stringStatus, message: json!["title"] as? String)
                    task?.cancel()
                    completion(data,resp)
                }
            default:
                let json = try? JSONSerialization.jsonObject(with: data!) as? Dictionary<String, AnyObject>
                if(json != nil){
                    let data: Data?  = nil
                    let stringStatus = String(json!["status"] as? Int ?? httpResponse!.statusCode)
                    resp = Response(url: json!["type"] as? String, statusCode: stringStatus, message: json!["title"] as? String)
                    task?.cancel()
                    completion(data,resp)
                }
            }
            if(group != nil){
                group!.leave()
            }
        })
        task!.resume()
    }
    public func execute(session: URLSession, request: URLRequest, completion: @escaping (Data?, Response?) -> ()){
        execute(session: session, request: request, group: nil){(data, response) in
            completion(data, response)
        }
    }
}
