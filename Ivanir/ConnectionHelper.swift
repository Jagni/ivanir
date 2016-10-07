//
//  ConnectionHelper.swift
//  Ivanir
//
//  Created by Jagni Dasa Horta Bezerra on 9/6/16.
//  Copyright © 2016 Jagni. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

let serverURL = "https://melros.co/ivanimonth/server/update.php"
let jsonURL = "https://melros.co/ivanimonth/server/data/data.json"
//let jsonURL = "http://192.168.0.128:8888/ivanir/ios-charadas.json"

open class ConnectionHelper{
    
    open class func getJSON(_ completionHandler : @escaping ((_ json: JSON, _ error: Bool) -> Void)){
        URLCache.shared.removeAllCachedResponses()
        Alamofire.request(jsonURL, parameters: nil)
            .validate()
            .responseJSON { response in
                
                if let _ = response.result.value{
                    completionHandler(JSON(response.result.value!),false)
                }
                else{
                    completionHandler(JSON(false),true)
                }
                
        }
        
    }
    
    class func sendJSON(json: [String : Any], completionHandler:  @escaping (_ response: Bool) -> Void){
        
        URLCache.shared.removeAllCachedResponses()
        var newJSON = json
        newJSON["key"] = "$2y$10$8FsbCh6lJCkt48IckWDLNe4RNoVNvlDhyFwcRFZCkHV0tK8Yv.yeG"
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: newJSON, options: .prettyPrinted)
            
            // create post request
            let url = URL(string: serverURL)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            // insert json data to the request
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
            concurrentQueue.async {
                let task = URLSession.shared.dataTask(with: request){ data, response, error in
                    if error != nil{
                        print("Error -> \(error)")
                        return
                    }
                    
                        let result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        
                        completionHandler(result == "true")
                    
                }
                
                task.resume()
            }
            
            
        } catch {
            print(error)
        }
        
        
        
        
//        Alamofire.request(serverURL, method: HTTPMethod.post, parameters: json, encoding: JSONEncoding.default)
//            .validate()
//            .responseJSON { response in
//                if let value = response.result.value{
//                    let requestJSON = JSON(value)
//                    completionHandler(requestJSON, false)
//                }
//                else{
//                    let requestJSON = JSON(false)
//                    completionHandler(requestJSON, true)
//                }
//                
//        }
        
        
    }
    
}
