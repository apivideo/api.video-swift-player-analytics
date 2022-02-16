//
//  File.swift
//  
//
//  Created by Romain Petit on 09/02/2022.
//

import Foundation
public struct Response: Codable{
    public var url: String?
    public var statusCode: String?
    public var message: String?
    
    public init(url: String?, statusCode: String?, message: String?) {
        self.url = url
        self.statusCode = statusCode
        self.message = message
    }
    
    enum CodingKeys : String, CodingKey {
        case url = "type"
        case statusCode = "status"
        case message = "title"
    }
    
}
