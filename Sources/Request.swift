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

open class Request{
    
    let urlRequest:URLRequest
    let provider:HTTPProvider
    
    private var buffer = Data()
    var expectedContentSize:Int?
    
    var onPogress:((_ receivedSize:Int, _ expectedSize:Int) -> Void)?
    var onCompleteJSON:((Response<Any>)->Void)?
    var onCompleteData:((HTTPURLResponse?, Data, StreemError?) -> Void)?
    
    init(urlRequest:URLRequest, provider:HTTPProvider){
        self.urlRequest = urlRequest
        self.provider = provider
    }
    
    func append(receivedData:Data){
        self.buffer.append(receivedData)
        
        if self.expectedContentSize != nil && self.expectedContentSize! > 0 {
            self.onPogress?(buffer.count, expectedContentSize!)
        }
    }
    
    func onComplete(response:URLResponse?, error:Error?){
        guard let response = response as? HTTPURLResponse else {return}
        let validatedError = provider.validate(response: response, data: buffer, error: error)
 
        if let err = validatedError {
            if provider.shouldContinue(with: err){
                onCompleteJSON?(Response(response: response, data: buffer, result: .failure(err)))
                onCompleteData?(response, buffer, validatedError)
            }
            return
        }
        
        onCompleteData?(response, buffer, validatedError)
        if let json = try? JSONSerialization.jsonObject(with: buffer as Data, options: JSONSerialization.ReadingOptions.allowFragments){
            onCompleteJSON?(Response(response: response, data: buffer, result: .success(json)))
        }else if buffer.count == 0{
            onCompleteJSON?(Response(response: response, data: buffer, result: .failure(StreemNetworkingError.emptyResponse)))
        }else{
            onCompleteJSON?(Response(response: response, data: buffer, result: .failure(StreemNetworkingError.jsonDeserialization)))
        }
    }
    
    @discardableResult
    open func progress(_ handler:@escaping (( _ receivedSize:Int, _ expectedSize:Int)->Void)) -> Self {
        self.onPogress = handler
        return self
    }
    
    @discardableResult
    open func response(_ handler:@escaping ((URLResponse?, Data, StreemError?)->Void)) -> Self {
        self.onCompleteData = handler
        return self
    }
    
    @discardableResult
    open func responseJSON(_ handler:@escaping ((Response<Any>)->Void)) -> Self {
        self.onCompleteJSON = handler
        return self
    }
}
