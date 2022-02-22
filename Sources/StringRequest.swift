
import Foundation
public class StringRequest{
    var method: Int
    var url: String
    var body: String?
    
    init(method: Int, url: String){
        self.method = method
        self.url = url
    }
    
    init(method: Int, url: String, body: String?){
        self.method = method
        self.url = url
        self.body = body
    }
}
