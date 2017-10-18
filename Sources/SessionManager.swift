/* This software is licensed under the Apache 2 license, quoted below.

 Copyright 2016 Emilien Stremsdoerfer <emstre@gmail.com>
 Licensed under the Apache License, Version 2.0 (the "License"); you may not
 use this file except in compliance with the License. You may obtain a copy of
 the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 License for the specific language governing permissions and limitations under
 the License.
 */

import Foundation

/**
 SessionManagerDelegate, protocol that conforms to URLSessionDataDelegate and that adds a way to store the requests being sent
 */
public protocol SessionManagerDelegate: URLSessionDataDelegate {

    /**
     Dictionary that allows to get a request based on the task generated when the request is sent
    */
    var requests: [URLSessionTask: Request] { get set}
}

/**
 Default implementation of SessionManagerDelegate
 */
class SessionManager: NSObject, SessionManagerDelegate {

    static let `default` = SessionManager()

    var requests = [URLSessionTask: Request]()

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let request = requests[task] else {return}
        request.setUploadProgress(bytesSent: totalBytesSent, bytesToSend: totalBytesExpectedToSend)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let request = requests[dataTask] else {return}
        request.append(data: data)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                    didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let request = requests[dataTask] else {return}
        request.expectedContentSize = Int(response.expectedContentLength)
        completionHandler(Foundation.URLSession.ResponseDisposition.allow)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let request = requests.removeValue(forKey: task) else {return}
        request.onComplete(response: task.response, error: error)
    }
}
