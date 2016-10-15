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




func +<K, V>(left: [K: V], right: [K: V]?) -> [K: V] {
    var dict = left
    if let right = right {
        for (k, v) in right {
            dict[k] = v
        }
    }
    return dict
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
