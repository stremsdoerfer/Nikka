//
//  MapperFuturesTests.swift
//  StreemNetworking
//
//  Created by Emilien on 10/15/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import XCTest
@testable import StreemNetworking
@testable import Mapper

class MapperFuturesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testFutureObject(){
        struct TestIP:Mappable{
            let ip:String
            
            init(map: Mapper) throws {
                try ip = map |> "origin"
            }
        }
        
        let expectation = self.expectation(description: "GET request should succeed")
        
        let provider = TestProvider()
        let futureIP:Future<TestIP> = provider.request(.ip).response()
        
        futureIP.onComplete { (result:Result<TestIP>) in
            expectation.fulfill()
            XCTAssertNil(result.error)
            XCTAssertNotNil(result.value)
            XCTAssertNotEqual(result.value?.ip, "")
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testDeserializeArray(){
        struct TestValue:Mappable{
            let value:Int
            
            init(map: Mapper) throws {
                try value = map |> "value"
            }
        }
        
        let expectation = self.expectation(description: "GET request should succeed")
        
        let provider = TestProvider()
        let json = ["test":[["value":1],["value":2],["value":3]]]
        let futureValues:Future<[TestValue]> = provider.request(.postJSON(json)).response(rootKey:"json.test")
        
        futureValues.onComplete { (result:Result<[TestValue]>) in
            expectation.fulfill()
            XCTAssertNil(result.error)
            XCTAssertNotNil(result.value)
            XCTAssertEqual(result.value?.count, 3)
            XCTAssertEqual(result.value?[2].value, 3)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testFutureObjectError(){
        struct TestIP:Mappable{
            let ip:String
            
            init(map: Mapper) throws {
                try ip = map |> "blah"
            }
        }
        
        let expectation = self.expectation(description: "GET request should succeed")
        
        let provider = TestProvider()
        let futureIP:Future<TestIP> = provider.request(.ip).response()
        
        futureIP.onComplete { (result:Result<TestIP>) in
            expectation.fulfill()
            XCTAssertNil(result.value)
            let errorPrefix = result.error?.description.hasPrefix("Could not deserialize object: ")
            XCTAssertTrue(errorPrefix!)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testDeserializeArrayError(){
        struct TestValue:Mappable{
            let value:Int
            
            init(map: Mapper) throws {
                try value = map |> "value"
            }
        }
        
        let expectation = self.expectation(description: "GET request should succeed")
        
        let provider = TestProvider()
        let json = ["test":[["value":1],["value":2],["value":3]]]
        let futureValues:Future<[TestValue]> = provider.request(.postJSON(json)).response(rootKey:"blah")
        
        futureValues.onComplete { (result:Result<[TestValue]>) in
            expectation.fulfill()
            XCTAssertNil(result.value)
            let errorPrefix = result.error?.description.hasPrefix("Could not deserialize object: ")
            XCTAssertTrue(errorPrefix!)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testChainingFutures(){
        struct TestIP:Mappable{
            let ip:String
            init(map: Mapper) throws {
                try ip = map |> "origin"
            }
        }
        
        struct TestResponse:Mappable{
            let ip:String
            init(map: Mapper) throws {
                try ip = map |> "json.origin"
            }
        }
        
        let expectation = self.expectation(description: "Chaining request should succeed")

        let provider = TestProvider()
        let futureIP:Future<TestIP> = provider.request(.ip).response()
        let postIP:Future<TestResponse> = futureIP.flatMap({provider.request(.postJSON(["origin":$0.ip])).response()})
        postIP.onComplete { (result:Result<TestResponse>) in
            expectation.fulfill()
            XCTAssertNil(result.error)
            XCTAssertNotNil(result.value)
            XCTAssertNotEqual(result.value?.ip, "")
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testChainingFuturesError1(){
        struct TestIP:Mappable{
            let ip:String
            init(map: Mapper) throws {
                try ip = map |> "blah"
            }
        }
        
        struct TestResponse:Mappable{
            let ip:String
            init(map: Mapper) throws {
                try ip = map |> "json.origin"
            }
        }
        
        let expectation = self.expectation(description: "Chaining request should fail")
        
        let provider = TestProvider()
        let futureIP:Future<TestIP> = provider.request(.ip).response()
        let postIP:Future<TestResponse> = futureIP.flatMap({provider.request(.postJSON(["origin":$0.ip])).response()})
        postIP.onComplete { (result:Result<TestResponse>) in
            expectation.fulfill()
            XCTAssertNil(result.value)
            let errorPrefix = result.error?.description.hasPrefix("Could not deserialize object: ")
            XCTAssertTrue(errorPrefix!)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testChainingFuturesError2(){
        struct TestIP:Mappable{
            let ip:String
            init(map: Mapper) throws {
                try ip = map |> "origin"
            }
        }
        
        struct TestResponse:Mappable{
            let ip:String
            init(map: Mapper) throws {
                try ip = map |> "json.origin.test"
            }
        }
        
        let expectation = self.expectation(description: "Chaining request should fail")
        
        let provider = TestProvider()
        let futureIP:Future<TestIP> = provider.request(.ip).response()
        let postIP:Future<TestResponse> = futureIP.flatMap({provider.request(.postJSON(["origin":$0.ip])).response()})
        postIP.onComplete { (result:Result<TestResponse>) in
            expectation.fulfill()
            XCTAssertNil(result.value)
            let errorPrefix = result.error?.description.hasPrefix("Could not deserialize object: ")
            XCTAssertTrue(errorPrefix!)
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
