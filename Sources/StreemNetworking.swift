//
//  Networking.swift
//  HerPlayground
//
//  Created by Emilien on 9/29/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation

//TODO features to add
/*
 - multipart encoding (separate file)
 - basic auth
 - oauth?
 */

public protocol HTTPProvider {
    var baseURL:URL { get }
    var session:URLSession { get }
    var defaultHeaders:[String:String] { get }
    var additionalParams:[String:Any] { get }
    func validate(response:HTTPURLResponse, data:Data, error: Error?) -> StreemError?
    func shouldContinue(with error:StreemError) -> Bool
}

func +<K, V>(left: [K: V], right: [K: V]?) -> [K: V] {
    var dict = left
    if let right = right {
        for (k, v) in right {
            dict[k] = v
        }
    }
    return dict
}

public extension HTTPProvider{
    
    var session : URLSession {
        get {
            return URLSession(configuration: .default, delegate: SessionManager.sharedInstance, delegateQueue: OperationQueue.main)
        }
    }
    
    var defaultHeaders:[String:String]{ get { return [String:String]() } }
    var additionalParams:[String:Any]{ get { return [String:Any]() } }
    
    public func request(_ route:Route) -> Request {
        
        let path = baseURL.appendingPathComponent(route.path)
        
        var request = URLRequest(url: path)
        
        let error = request.encode(parameters: additionalParams + route.params, encoding: route.encoding)
        guard error == nil else {
            let r = Request(urlRequest: request, provider:self)
            r.onComplete(response: nil, error: error)
            return r
        }
        
        request.httpMethod = route.method.rawValue
        
        let headers = defaultHeaders + route.headers
        headers.forEach({
            request.setValue($1, forHTTPHeaderField: $0)
        })
        
        let r = Request(urlRequest: request, provider:self)
        
        let task = session.dataTask(with: request)
        SessionManager.sharedInstance.requests[task] = r
        task.resume()
        
        return r
    }
    
    func validate(response:HTTPURLResponse, data:Data, error: Error?) -> StreemError?{
        if let error = error {
            return StreemNetworkingError.errorWith(error: error)
        }else{
            return response.statusCode >= 400 ? StreemNetworkingError.errorWith(httpCode: response.statusCode) : nil
        }
    }
    
    func shouldContinue(with error:StreemError) -> Bool{
        return true
    }
}


class SessionManager:NSObject, URLSessionDataDelegate{
    
    static let sharedInstance = SessionManager()
    
    var requests = [URLSessionTask:Request]()
    
//    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
//        
//    }
//    
//    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
//        //guard let request = requests[task] else {return}
//            
//        
//    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let request = requests[dataTask] else {return}
        request.append(receivedData:data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let request = requests[dataTask] else {return}
        request.expectedContentSize = Int(response.expectedContentLength)
        completionHandler(Foundation.URLSession.ResponseDisposition.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let request = requests.removeValue(forKey: task) else {return}
        request.onComplete(response: task.response, error: error)
    }
}

public enum HTTPMethod: String {
    case options, get, head, post, put, patch, delete, trace, connect
}
