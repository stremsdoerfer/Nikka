//
//  RequestSending.swift
//  StreemNetworking
//
//  Created by Emilien on 10/15/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import XCTest
@testable import StreemNetworking

let timeout:TimeInterval = 2

class RequestSendingTests: XCTestCase {
    
    //Default Response
    
    func testSendGET(){
        let expectation = self.expectation(description: "GET request should succeed")
        
        let provider = TestProvider()
        let request = provider.request(.get)
        request.response { (response:URLResponse?, data:Data, error:Error?) in
            expectation.fulfill()
            XCTAssertGreaterThan(data.count, 0)
            XCTAssertNil(error)
            XCTAssertNotNil(response)
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSendPOST(){
        let expectation = self.expectation(description: "POST request should succeed")
        
        let provider = TestProvider()
        let request = provider.request(.postForm([:]))
        request.response { (response:URLResponse?, data:Data, error:Error?) in
            expectation.fulfill()
            XCTAssertGreaterThan(data.count, 0)
            XCTAssertNil(error)
            XCTAssertNotNil(response)
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSendPUT(){
        let expectation = self.expectation(description: "PUT request should succeed")
        
        let provider = TestProvider()
        let request = provider.request(.putForm([:]))
        request.response { (response:URLResponse?, data:Data, error:Error?) in
            expectation.fulfill()
            XCTAssertGreaterThan(data.count, 0)
            XCTAssertNil(error)
            XCTAssertNotNil(response)
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSendDELETE(){
        let expectation = self.expectation(description: "DELETE request should succeed")
        
        let provider = TestProvider()
        let request = provider.request(.delete)
        request.response { (response:URLResponse?, data:Data, error:Error?) in
            expectation.fulfill()
            XCTAssertGreaterThan(data.count, 0)
            XCTAssertNil(error)
            XCTAssertNotNil(response)
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    //JSON Response
    
    func testJSONSendGET(){
        let expectation = self.expectation(description: "GET request should succeed")
        
        let provider = TestProvider()
        let request = provider.request(.get)
        request.responseJSON { (response:Response<Any>) in
            expectation.fulfill()
            XCTAssertEqual(response.response?.statusCode, 200)
            XCTAssertNotNil(response.result.value)
            XCTAssertNil(response.result.error)
            XCTAssertGreaterThan(response.data.count, 0)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJSONSendPOST(){
        let expectation = self.expectation(description: "POST request should succeed")
        
        let provider = TestProvider()
        let request = provider.request(.postJSON([:]))
        request.responseJSON { (response:Response<Any>) in
            expectation.fulfill()
            XCTAssertEqual(response.response?.statusCode, 200)
            XCTAssertNotNil(response.result.value)
            XCTAssertNil(response.result.error)
            XCTAssertGreaterThan(response.data.count, 0)
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJSONSendPUT(){
        let expectation = self.expectation(description: "PUT request should succeed")
        
        let provider = TestProvider()
        let request = provider.request(.putJSON([:]))
        request.responseJSON { (response:Response<Any>) in
            expectation.fulfill()
            XCTAssertEqual(response.response?.statusCode, 200)
            XCTAssertNotNil(response.result.value)
            XCTAssertNil(response.result.error)
            XCTAssertGreaterThan(response.data.count, 0)
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJSONSendDELETE(){
        DefaultProvider.request(Route(path:"https://website.com/api/user/1")).responseJSON { (response:Response<Any>) in
            switch response.result{
            case .success(let json):
                print("json: \(json)")
            case .failure(let error):
                print("error: \(error)")
            }
        }
        
        let expectation = self.expectation(description: "DELETE request should succeed")
        
        let provider = TestProvider()
        let request = provider.request(.delete)
        request.responseJSON { (response:Response<Any>) in
            expectation.fulfill()
            XCTAssertEqual(response.response?.statusCode, 200)
            XCTAssertNotNil(response.result.value)
            XCTAssertNil(response.result.error)
            XCTAssertGreaterThan(response.data.count, 0)
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
