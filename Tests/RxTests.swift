//
//  RxTests.swift
//  StreemNetworking
//
//  Created by Emilien on 10/22/16.
//  Copyright © 2016 Emilien Stremsdoerfer. All rights reserved.
//

import XCTest
@testable import StreemNetworking
@testable import RxSwift

class RxTests: XCTestCase {

    let bag = DisposeBag()

    func testJSONObs() {
        let provider = TestProvider()
        let ipObs: Observable<Any> = provider.request(.ip).responseJSON()

        let expectation = self.expectation(description: "JSON request should succeed")

        ipObs.subscribe(onNext: { json in
            expectation.fulfill()
            guard let jsonDict = json as? [String:Any], let ip = jsonDict["origin"] as? String else {
                XCTFail()
                return
            }
            XCTAssertNotEqual(ip, "")
        }).addDisposableTo(bag)

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testDataObs() {
        let provider = TestProvider()
        let ipObs: Observable<(HTTPURLResponse, Data)> = provider.request(.ip).response()
        let expectation = self.expectation(description: "JSON request should succeed")

        ipObs.subscribe(onNext: { (response: (HTTPURLResponse, Data)) in
            expectation.fulfill()
            XCTAssertEqual(response.0.statusCode, 200)
            let object = try? JSONSerialization.jsonObject(with: response.1, options: .allowFragments)
            XCTAssertNotNil(object)
        }).addDisposableTo(bag)

        waitForExpectations(timeout: timeout, handler: nil)
    }

}
