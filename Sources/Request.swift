//
//  Request.swift
//  HerPlayground
//
//  Created by Emilien on 10/4/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import Foundation

open class Request{
    
    let urlRequest:URLRequest
    
    private var buffer = Data()
    var expectedContentSize:Int?
    
    var onPogress:((_ receivedSize:Int, _ expectedSize:Int) -> Void)?
    var onCompleteJSON:((Response<Any>)->Void)?
    var onCompleteData:((HTTPURLResponse?, Data, Error?) -> Void)?
    
    init(urlRequest:URLRequest){
        self.urlRequest = urlRequest
    }
    
    func append(receivedData:Data){
        self.buffer.append(receivedData)
        
        if self.expectedContentSize != nil && self.expectedContentSize! > 0 {
            self.onPogress?(buffer.count, expectedContentSize!)
        }
    }
    
    func onComplete(response:URLResponse?, error:Error?){
        guard let response = response as? HTTPURLResponse else {return}
        onCompleteData?(response, buffer, error)
        
        if error == nil {
            if response.statusCode >= 400 {
                onCompleteJSON?(Response(response: response, data: buffer, result: .failure(StreemNetworkingError.errorWith(httpCode: response.statusCode))))
            }
            if let json = try? JSONSerialization.jsonObject(with: buffer as Data, options: JSONSerialization.ReadingOptions.allowFragments){
                onCompleteJSON?(Response(response: response, data: buffer, result: .success(json)))
            }else{
                onCompleteJSON?(Response(response: response, data: buffer, result: .failure(StreemNetworkingError.jsonDeserialization)))
            }
        }else{
            onCompleteJSON?(Response(response: response, data: buffer, result: .failure(StreemNetworkingError.errorWith(error: error!))))
        }
    }
    
    @discardableResult
    open func progress(_ handler:@escaping (( _ receivedSize:Int, _ expectedSize:Int)->Void)) -> Self {
        self.onPogress = handler
        return self
    }
    
    @discardableResult
    open func response(_ handler:@escaping ((URLResponse?, Data, Error?)->Void)) -> Self {
        self.onCompleteData = handler
        return self
    }
    
    @discardableResult
    open func responseJSON(_ handler:@escaping ((Response<Any>)->Void)) -> Self {
        self.onCompleteJSON = handler
        return self
    }
}
