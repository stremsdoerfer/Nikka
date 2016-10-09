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
    
    public func request(_ route:Route) -> Request {
        
        let path = baseURL.appendingPathComponent(route.path)
        
        var request = URLRequest(url: path)
        request.encode(parameters: route.params, encoding: route.encoding)
        
        request.httpMethod = route.method.rawValue
        
        let headers = defaultHeaders + route.headers
        headers.forEach({
            request.setValue($1, forHTTPHeaderField: $0)
        })
        
        let r = Request(urlRequest: request)
        
        let task = session.dataTask(with: request)
        SessionManager.sharedInstance.requests[task] = r
        task.resume()
        
        return r
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
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}
