//
//  PurchaseAPIService.swift
//  PocketCellar
//
//  Created by IE MacBook Pro 2014 on 12/04/24.
//

import Foundation

class PurchaseAPIService: NSObject {
    
    static func verifyInAppReceipt(requestBody: [String:Any],
                                   withCompletionHandler completionHandler: @escaping (_ response: Data? , _ erorr: Error? ) -> ()) {
        
        //BaseURL
        let constant = IAPConstant.self
        
        let baseURL = constant.kReceiptProductionVerifyURL
        //let baseURL = constant.kReceiptVerifyURL  //Development
        
        guard let url = URL(string: baseURL) else {
            return
        }
        
        //Print Request
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            if let jsonString = String(data: bodyData, encoding: String.Encoding.utf8) {
                print("RequestJSON: \(jsonString)")
                
                //Check network connection
//                if DTMNetworkManager.sharedInstance.reachability.connection != .none {
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.httpBody = bodyData
                    
                    let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
                        
                        if let receivedData = responseData, let httpResponse = response as? HTTPURLResponse,
                            error == nil, httpResponse.statusCode == 200 {
                            print("^Received 200, verifying data...")
                            do {
                                if let jsonResponse = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>,
                                    let status = jsonResponse["status"] as? Int64 {
                                    switch status {
                                    case 0: // receipt verified in Production
                                        print("^Verification with Production succesful, updating expiration date...")
                                        if let error = error {
                                            completionHandler(nil, error)
                                        } else if let responseData = responseData,
                                            let jsonString = String(data: responseData, encoding: String.Encoding.utf8) {
                                            print("ResponseString:\(jsonString)")
                                            completionHandler(responseData, nil)
                                        }
                                    case 21007:
                                        // Means that our receipt is from sandbox environment, need to validate it there instead
                                        print("^need to repeat evrything with Sandbox")
                                        let baseSURL = constant.kReceiptVerifyURL
                                        guard let sandboxUrl = URL(string: baseSURL) else {
                                            return
                                        }
                                        var request = URLRequest(url: sandboxUrl)
                                        request.httpMethod = "POST"
                                        request.httpBody = bodyData
                                        let session = URLSession(configuration: URLSessionConfiguration.default)
                                        print("^Connecting to Sandbox...")
                                        let task = session.dataTask(with: request) { responseData, response, error in
                                            // BEGIN of closure #2 - verification with Sandbox
                                            if let receivedData = responseData, let httpResponse = response as? HTTPURLResponse,
                                                error == nil, httpResponse.statusCode == 200 {
                                                print("^Received 200, verifying data...")
                                                do {
                                                    if let jsonResponse = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>,
                                                        let status = jsonResponse["status"] as? Int64 {
                                                        switch status {
                                                        case 0: // receipt verified in Sandbox
                                                            print("^Verification succesfull, updating expiration date...")
                                                            if let error = error {
                                                                completionHandler(nil, error)
                                                            } else if let responseData = responseData,
                                                                let jsonString = String(data: responseData, encoding: String.Encoding.utf8) {
                                                                print("ResponseString:\(jsonString)")
                                                                completionHandler(responseData, nil)
                                                            }
                                                        default:
                                                            print(status)
                                                        }
                                                    } else {
                                                        print("Failed to cast serialized JSON to Dictionary<String, AnyObject>")
                                                    }
                                                } catch {
                                                    print("Couldn't serialize JSON with error: " + error.localizedDescription)
                                                }
                                            } else {
                                                print("Error \(String(describing: error?.localizedDescription))")
                                            }
                                        }
                                        // END of closure #2 = verification with Sandbox
                                        task.resume()
                                    default:
                                        print(status)
                                    }
                                } else { print("Failed to cast serialized JSON to Dictionary<String, AnyObject>") }
                            } catch { print("Couldn't serialize JSON with error: \(error.localizedDescription)") }
                        }
                    }
                    task.resume()
            }
        } catch {
            print("Exception occurs")
        }
    }

}
