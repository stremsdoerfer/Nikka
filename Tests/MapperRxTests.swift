//
//  MapperRxTests.swift
//  Nikka
//
//  Created by Emilien on 10/15/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import XCTest
@testable import Nikka
@testable import RxSwift
@testable import StreemMapper

class MapperRxTests: XCTestCase {

    let bag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testObservableObject() {
        struct TestIP: Mappable {
            let ip: String

            init(map: Mapper) throws {
                try ip = map |> "origin"
            }
        }

        let expectation = self.expectation(description: "GET request should succeed")

        let provider = TestProvider()
        let futureIP: Observable<TestIP> = provider.request(.ip).responseObject()

        futureIP.subscribe(onNext: { testIP in
            expectation.fulfill()
            XCTAssertNotEqual(testIP.ip, "")
        }).addDisposableTo(bag)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testDeserializeArray() {
        struct TestValue: Mappable {
            let value: Int

            init(map: Mapper) throws {
                try value = map |> "value"
            }
        }

        let expectation = self.expectation(description: "GET request should succeed")

        let provider = TestProvider()
        let json = ["test":[["value":1], ["value":2], ["value":3]]]
        let valuesObs: Observable<[TestValue]> = provider.request(.postJSON(json)).responseArray(rootKey:"json.test")

        valuesObs.subscribe(onNext: { (values: [TestValue]) in
            expectation.fulfill()
            XCTAssertEqual(values.count, 3)
            XCTAssertEqual(values[2].value, 3)
        }).addDisposableTo(bag)
        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testFutureObjectError() {
        struct TestIP: Mappable {
            let ip: String

            init(map: Mapper) throws {
                try ip = map |> "blah"
            }
        }

        let expectation = self.expectation(description: "GET request should succeed")

        let provider = TestProvider()
        let ipObs: Observable<TestIP> = provider.request(.ip).responseObject()

        ipObs.subscribe(onError: { (error) in
            expectation.fulfill()
            let err = error as? NikkaError
            XCTAssertTrue(err!.isEqual(err:NikkaNetworkingError.jsonMapping("")))
        }).addDisposableTo(bag)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testDeserializeArrayError() {
        struct TestValue: Mappable {
            let value: Int

            init(map: Mapper) throws {
                try value = map |> "value"
            }
        }

        let expectation = self.expectation(description: "GET request should succeed")

        let provider = TestProvider()
        let json = ["test":[["value":1], ["value":2], ["value":3]]]
        let valuesObs: Observable<[TestValue]> = provider.request(.postJSON(json)).responseArray(rootKey:"blah")

        valuesObs.subscribe(onError: { (error) in
            expectation.fulfill()
            let err = error as? NikkaError
            XCTAssertTrue(err!.isEqual(err:NikkaNetworkingError.jsonMapping("")))
        }).addDisposableTo(bag)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testChainingFutures() {
        struct TestIP: Mappable {
            let ip: String
            init(map: Mapper) throws {
                try ip = map |> "origin"
            }
        }

        struct TestResponse: Mappable {
            let ip: String
            init(map: Mapper) throws {
                try ip = map |> "json.origin"
            }
        }

        let expectation = self.expectation(description: "Chaining request should succeed")

        let provider = TestProvider()
        let ipObs: Observable<TestIP> = provider.request(.ip).responseObject()
        let postIPObs: Observable<TestResponse> = ipObs.flatMap({provider.request(.postJSON(["origin":$0.ip])).responseObject()})
        postIPObs.subscribe(onNext: { (response: TestResponse) in
            expectation.fulfill()
            XCTAssertNotEqual(response.ip, "")
        }).addDisposableTo(bag)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testChainingObsError1() {
        struct TestIP: Mappable {
            let ip: String
            init(map: Mapper) throws {
                try ip = map |> "blah"
            }
        }

        struct TestResponse: Mappable {
            let ip: String
            init(map: Mapper) throws {
                try ip = map |> "json.origin"
            }
        }

        let expectation = self.expectation(description: "Chaining request should fail")

        let provider = TestProvider()
        let ipObs: Observable<TestIP> = provider.request(.ip).responseObject()
        let postIPObs: Observable<TestResponse> = ipObs.flatMap({provider.request(.postJSON(["origin":$0.ip])).responseObject()})
        postIPObs.subscribe(onError: { (error) in
            expectation.fulfill()
            let err = error as? NikkaError
            XCTAssertTrue(err!.isEqual(err:NikkaNetworkingError.jsonMapping("")))
        }).addDisposableTo(bag)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testChainingObsError2() {
        struct TestIP: Mappable {
            let ip: String
            init(map: Mapper) throws {
                try ip = map |> "origin"
            }
        }

        struct TestResponse: Mappable {
            let ip: String
            init(map: Mapper) throws {
                try ip = map |> "blah"
            }
        }

        let expectation = self.expectation(description: "Chaining request should fail")

        let provider = TestProvider()
        let ipObs: Observable<TestIP> = provider.request(.ip).responseObject()
        let postIPObs: Observable<TestResponse> = ipObs.flatMap({provider.request(.postJSON(["origin":$0.ip])).responseObject()})
        postIPObs.subscribe(onError: { (error) in
            expectation.fulfill()
            let err = error as? NikkaError
            XCTAssertTrue(err!.isEqual(err:NikkaNetworkingError.jsonMapping("")))
        }).addDisposableTo(bag)

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
