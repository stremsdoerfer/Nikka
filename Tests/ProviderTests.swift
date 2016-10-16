//
//  ProviderTests.swift
//  StreemNetworking
//
//  Created by Emilien on 10/15/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import XCTest
@testable import StreemNetworking

class ProviderTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    //MARK:- Basic response
    
    func testDefault404Error(){
        let expectation = self.expectation(description: "Request should return 404")
        
        let provider = TestProvider()
        provider.request(.getError(404)).response { (response:URLResponse?, data:Data, error:StreemError?) in
            expectation.fulfill()
            let is404 = (error as! StreemNetworkingError) == StreemNetworkingError.http(404)
            XCTAssertTrue(is404)
            XCTAssertNotNil(response)
            XCTAssertEqual(data.count, 0)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testDefault401Error(){
        let expectation = self.expectation(description: "Request should return 401")
        
        let provider = TestProvider()
        provider.request(.getError(401)).response { (response:URLResponse?, data:Data, error:StreemError?) in
            expectation.fulfill()
            let is401 = (error as! StreemNetworkingError) == StreemNetworkingError.http(401)
            let is404 = (error as! StreemNetworkingError) == StreemNetworkingError.http(404)
            XCTAssertTrue(is401)
            XCTAssertFalse(is404)
            XCTAssertNotNil(response)
            XCTAssertEqual(data.count, 0)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testNoHTTPError(){
        let expectation = self.expectation(description: "Request should return no error")
        
        let provider = TestProviderValidateAllHTTPCode()
        provider.request(.getError(401)).response { (response:URLResponse?, data:Data, error:StreemError?) in
            expectation.fulfill()
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertEqual(data.count, 0)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testDeezerError(){
        let expectation = self.expectation(description: "Request should return an error")
        
        let provider = TestProviderDeezer()
        provider.request(.track(98675843679)).response { (response:URLResponse?, data:Data, error:StreemError?) in
            expectation.fulfill()
            let error = error as! DeezerError
            XCTAssertEqual(error.code, 800)
            XCTAssertNotNil(response)
            XCTAssertGreaterThan(data.count, 0)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testDeezerNoError(){
        let expectation = self.expectation(description: "Request should return no error")
        
        let provider = TestProviderDeezer()
        provider.request(.track(3135556)).response { (response:URLResponse?, data:Data, error:StreemError?) in
            expectation.fulfill()
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertGreaterThan(data.count, 0)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    
    //MARK:- JSON Response
    
    func testJSON404Error(){
        let expectation = self.expectation(description: "Request should return 404")
        
        let provider = TestProvider()
        provider.request(.getError(404)).responseJSON { (response:Response<Any>) in
            expectation.fulfill()
            let is404 = (response.result.error as! StreemNetworkingError) == StreemNetworkingError.http(404)
            XCTAssertTrue(is404)
            XCTAssertNil(response.result.value)
            XCTAssertEqual(response.data.count, 0)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJSON401Error(){
        let expectation = self.expectation(description: "Request should return 401")
        
        let provider = TestProvider()
        provider.request(.getError(401)).responseJSON { (response:Response<Any>) in
            expectation.fulfill()
            let is401 = (response.result.error as! StreemNetworkingError) == StreemNetworkingError.http(401)
            let is404 = (response.result.error as! StreemNetworkingError) == StreemNetworkingError.http(404)
            XCTAssertTrue(is401)
            XCTAssertFalse(is404)
            XCTAssertNil(response.result.value)
            XCTAssertEqual(response.data.count, 0)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJSONNoHTTPError(){
        let expectation = self.expectation(description: "Request should return an error emptyResponse")
        
        let provider = TestProviderValidateAllHTTPCode()
        provider.request(.getError(401)).responseJSON { (response:Response<Any>) in
            expectation.fulfill()
            let isEmpty = (response.result.error as! StreemNetworkingError) == StreemNetworkingError.emptyResponse
            XCTAssertTrue(isEmpty)
            XCTAssertNil(response.result.value)
            XCTAssertEqual(response.data.count, 0)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJSONDeezerError(){
        let expectation = self.expectation(description: "Request should return an error")
        
        let provider = TestProviderDeezer()
        provider.request(.track(98675843679)).responseJSON { (response:Response<Any>) in
            expectation.fulfill()
            let error = response.result.error as! DeezerError
            XCTAssertEqual(error.code, 800)
            XCTAssertNil(response.result.value)
            XCTAssertGreaterThan(response.data.count, 0)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testJSONDeezerNoError(){
        let expectation = self.expectation(description: "Request should return no error")
        
        let provider = TestProviderDeezer()
        provider.request(.track(3135556)).responseJSON { (response:Response<Any>) in
            expectation.fulfill()
            XCTAssertNil(response.result.error)
            XCTAssertNotNil(response.result.value)
            XCTAssertGreaterThan(response.data.count, 0)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
}
