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
 Request is a wrapper around the URLRequest that will be sent with URLSession
 */
open class Request {

    /**
     The wrapped URLRequest
    */
    let urlRequest: URLRequest

    /**
     The provider the request is being sent with
     */
    let provider: HTTPProvider

    /**
     Any data received by the request will be put into this buffer
    */
    private var buffer = Data()

    /**
     Expected size of the response
    */
    var expectedContentSize: Int?

    /**
     Instance variable that allows us to keep the state of the response if it arrives before the handler is added
    */
    private var responseDataTmp: (HTTPURLResponse?, Data, NikkaError?)?

    /**
     Instance variable that allows us to keep the state of the response if it arrives before the handler is added
     */
    private var responseJSONTmp: (Response<Any>)?

    /**
     An instance closure that can be define with the matching function:
     func downloadProgress(_ handler:@escaping (( _ receivedSize:Int, _ expectedSize:Int)->Void))
     */
    private var onDownloadPogress:((_ receivedSize: Int, _ expectedSize: Int) -> Void)?

    /**
     An instance closure that can be define with the matching function:
     func uploadProgress(_ handler:@escaping (( _ bytesSent:Int64, _ totalBytes:Int64)->Void))
     */
    private var onUploadProgress:((_ sentBytes: Int64, _ totalBytes: Int64) -> Void)?

    /**
     An instance closure that can be define with the matching function:
     func responseJSON(_ handler:@escaping ((Response<Any>)->Void))
     */
    private var onCompleteJSON: ((Response<Any>) -> Void)?

    /**
     An instance closure that can be define with the matching function:
     func response(_ handler:@escaping ((URLResponse?, Data, Error?)->Void))
     */
    private var onCompleteData: ((HTTPURLResponse?, Data, NikkaError?) -> Void)?

    /**
     Initializer of Request
     - parameter urlRequest: The actual URLRequest that we want to wrap
     - parameter provider: The provider used to send the request
     */
    init(urlRequest: URLRequest, provider: HTTPProvider) {
        self.urlRequest = urlRequest
        self.provider = provider
    }

    /**
     Method that will append data to the current buffer
     - parameter data: the data that needs to be appended
    */
    func append(data: Data) {
        self.buffer.append(data)

        if self.expectedContentSize != nil && self.expectedContentSize! > 0 {
            self.onDownloadPogress?(buffer.count, expectedContentSize!)
        }
    }

    /**
     Method that will update the progress of an upload
     - parameter bytesSent: the total number of bytes already sent
     - parameter bytesToSend: the total number of bytes to send
    */
    func setUploadProgress(bytesSent: Int64, bytesToSend: Int64) {
        self.onUploadProgress?(bytesSent, bytesToSend)
    }

    /**
     Method that needs to be called when the request has completed.
     - parameter response: the URLResponse received if any
     - parameter error: the error received if any
    */
    func onComplete(response: URLResponse?, error: Error?) {
        let httpResponse = response as? HTTPURLResponse
        var error = error
        if httpResponse == nil && error == nil {
            error = (response != nil) ? NikkaNetworkingError.nonHTTPResponse : NikkaNetworkingError.unknown("Response and Error are nil")
        }

        let validatedError = provider.validate(response: httpResponse, data: buffer, error: error)

        if let err = validatedError {
            if provider.shouldContinue(with: err) {
                onCompleteJSON?(Response(response: httpResponse, data: buffer, result: .failure(err)))
                onCompleteData?(httpResponse, buffer, validatedError)
            }
            return
        }
        responseDataTmp = (httpResponse, buffer, validatedError)
        onCompleteData?(httpResponse, buffer, validatedError)

        var responseToReturn: Response<Any>!
        if let json = try? JSONSerialization.jsonObject(with: buffer as Data, options: JSONSerialization.ReadingOptions.allowFragments) {
            responseToReturn = Response(response: httpResponse, data: buffer, result: .success(json))
        } else if buffer.count == 0 {
            responseToReturn = Response(response: httpResponse, data: buffer, result: .failure(NikkaNetworkingError.emptyResponse))
        } else {
            responseToReturn = Response(response: httpResponse, data: buffer, result: .failure(NikkaNetworkingError.jsonDeserialization))
        }
        responseJSONTmp = responseToReturn
        onCompleteJSON?(responseToReturn)
    }

    /**
     Method that allows you to track the progress of a request.
     - parameter handler: A closure that takes the received size and the expected size as parameters
     - returns: itself
    */
    @discardableResult
    open func uploadProgress(_ handler:@escaping (( _ bytesSent: Int64, _ totalBytes: Int64) -> Void)) -> Self {
        self.onUploadProgress = handler
        return self
    }

    /**
     Method that allows you to track the progress of a request.
     - parameter handler: A closure that takes the received size and the expected size as parameters
     - returns: itself
     */
    @discardableResult
    open func downloadProgress(_ handler:@escaping (( _ receivedSize: Int, _ expectedSize: Int) -> Void)) -> Self {
        self.onDownloadPogress = handler
        return self
    }

    /**
     Method that allows you to track when a request is completed
     - parameter handler: A closure that takes the URLResponse, the Data received (empty if no data), and any error as parameters
     - returns: itself
     */
    @discardableResult
    open func response(_ handler:@escaping ((HTTPURLResponse?, Data, NikkaError?) -> Void)) -> Self {
        self.onCompleteData = handler
        if let response = responseDataTmp {
            handler(response.0, response.1, response.2)
        }
        return self
    }

    /**
     Method that allows you to track when a request is completed
     - parameter handler: A closure that takes a Response object as parameters
     - returns: itself
     */
    @discardableResult
    open func responseJSON(_ handler:@escaping ((Response<Any>) -> Void)) -> Self {
        self.onCompleteJSON = handler
        if let response = responseJSONTmp {
            handler(response)
        }
        return self
    }

    /**
     Method that allows you to track when a request is completed
     - parameter handler: A closure that takes a Response object as parameters
     - returns: itself
     */
    @discardableResult
    open func responseObject<T: Decodable>(_ handler:@escaping ((Response<T>) -> Void)) -> Self {
        let newHandler: ((HTTPURLResponse?, Data, NikkaError?) -> Void) = { (response, data, error) in
            if let err = error {
                handler(Response(response: response, data: data, result: .failure(err)))
            } else if let object = try? JSONDecoder().decode(T.self, from: data) {
                handler(Response(response: response, data: data, result: .success(object)))
            } else {
                handler(Response(response: response, data: data, result: .failure(NikkaNetworkingError.jsonMapping(data))))
            }
        }
        self.onCompleteData = newHandler
        if let response = responseDataTmp {
            newHandler(response.0, response.1, response.2)
        }
        return self
    }
}
