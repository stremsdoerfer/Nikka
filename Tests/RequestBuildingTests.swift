//
//  StreemNetworkingTests.swift
//  StreemNetworkingTests
//
//  Created by Emilien on 10/8/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import XCTest
@testable import StreemNetworking

class RequestBuilingTests: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    //MARK:- Request Building
    
    func testGetBuild() {
        let provider = TestProvider()
        let request = provider.request(.get)
        
        XCTAssertEqual(request.urlRequest.httpMethod, "GET")
        XCTAssertEqual(request.urlRequest.url?.absoluteString, "\(provider.baseURL)/get")
    }

    func testPostBuild(){
        let provider = TestProvider()
        let request = provider.request(.postJSON([:]))
        
        XCTAssertEqual(request.urlRequest.httpMethod, "POST")
        XCTAssertEqual(request.urlRequest.url?.absoluteString, "\(provider.baseURL)/post")
    }
    
    func testPutBuild(){
        let provider = TestProvider()
        let request = provider.request(.putJSON([:]))
        
        XCTAssertEqual(request.urlRequest.httpMethod, "PUT")
        XCTAssertEqual(request.urlRequest.url?.absoluteString, "\(provider.baseURL)/put")
    }
    
    func testDeleteBuild(){
        let provider = TestProvider()
        let request = provider.request(.delete)
        
        XCTAssertEqual(request.urlRequest.httpMethod, "DELETE")
        XCTAssertEqual(request.urlRequest.url?.absoluteString, "\(provider.baseURL)/delete")
    }
   
    
    //MARK:- Parameters Building
    
    func testGetParamBuild() {
        let provider = TestProvider()
        let request = provider.request(.getParams(["foo":"bar","test":123]))
        
        XCTAssertTrue(request.urlRequest.url?.query == "foo=bar&test=123" || request.urlRequest.url?.query ==  "test=123&foo=bar")
    }
    
    func testGetDefaultParams(){
        let provider = TestParamsProvider()
        let request = provider.request(.getParams(["foo":"bar"]))
        XCTAssertTrue(request.urlRequest.url?.query == "foo=bar&token=12345" || request.urlRequest.url?.query ==  "token=12345&foo=bar")
    }
    
    func testPostFormParam(){
        let provider = TestProvider()
        let request = provider.request(.postForm(["foo":"bar","test":123]))
        
        let body = String(data:request.urlRequest.httpBody!, encoding:String.Encoding.utf8)
        XCTAssertTrue(body == "foo=bar&test=123" || body ==  "test=123&foo=bar")
    }
    
    func testPostJSONParam(){
        let provider = TestProvider()
        let request = provider.request(.postJSON(["foo":"bar","test":123]))
        
        let body = String(data:request.urlRequest.httpBody!, encoding:String.Encoding.utf8)
        XCTAssertTrue(body == "{\"foo\":\"bar\",\"test\":123}" || body ==  "{\"test\":123,\"foo\":\"bar\"}")
    }
    
    func testPostFormDefaultParams(){
        let provider = TestParamsProvider()
        let request = provider.request(.postForm(["foo":"bar"]))
        let body = String(data:request.urlRequest.httpBody!, encoding:String.Encoding.utf8)
        XCTAssertTrue(body == "foo=bar&token=12345" || body ==  "token=12345&foo=bar")
    }
    
    func testPostJSONParamDefaultParams(){
        let provider = TestParamsProvider()
        let request = provider.request(.postJSON(["foo":"bar"]))
        
        let body = String(data:request.urlRequest.httpBody!, encoding:String.Encoding.utf8)
        XCTAssertTrue(body == "{\"foo\":\"bar\",\"token\":12345}" || body ==  "{\"token\":12345,\"foo\":\"bar\"}")
    }
    
    func testPutFormParam(){
        let provider = TestProvider()
        let request = provider.request(.putForm(["foo":"bar","test":123]))
        
        let body = String(data:request.urlRequest.httpBody!, encoding:String.Encoding.utf8)
        XCTAssertTrue(body == "foo=bar&test=123" || body ==  "test=123&foo=bar")
    }
    
    func testPutJSONParam(){
        let provider = TestProvider()
        let request = provider.request(.putJSON(["foo":"bar","test":123]))
        
        let body = String(data:request.urlRequest.httpBody!, encoding:String.Encoding.utf8)
        XCTAssertTrue(body == "{\"foo\":\"bar\",\"test\":123}" || body ==  "{\"test\":123,\"foo\":\"bar\"}")
    }
    
    
    //MARK:- Headers Building
    
    func testCustomHeaders(){
        let provider = TestProvider()
        let request = provider.request(.getHeaders(["customHeader":"value"]))
        XCTAssertEqual(request.urlRequest.allHTTPHeaderFields!["customHeader"], "value")
    }
    
    func testDefaultHeaders(){
        let provider = TestHeadersProvider()
        let request = provider.request(.getHeaders(["customHeader":"value"]))
        XCTAssertEqual(request.urlRequest.allHTTPHeaderFields!["TestHeader"], "TestHeaderValue")
    }
    
    func testCustomHeaderWithDefault(){
        let provider = TestHeadersProvider()
        let request = provider.request(.getHeaders(["customHeader":"value"]))
        XCTAssertEqual(request.urlRequest.allHTTPHeaderFields!["customHeader"], "value")
    }
}
