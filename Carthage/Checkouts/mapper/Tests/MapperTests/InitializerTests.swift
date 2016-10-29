import Mapper
import XCTest

private struct TestExtension {
    let string: String
}

extension TestExtension: Mappable {
    init(map: Mapper) throws {
        try self.string = map.from(field:"string")
    }
}

final class InitializerTests: XCTestCase {

    // MARK: from NSDictionary

    func testCreatingInvalidFromJSON() {
        struct Test: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"foo")
            }
        }

        let test = Test.from(JSON: [:])
        XCTAssertNil(test)
    }

    func testCreatingValidFromJSON() {
        struct Test: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"string")
            }
        }

        let test = Test.from(JSON: ["string": "Hi"])
        XCTAssertTrue(test?.string == "Hi")
    }

    // MARK: from NSArray

    func testCreatingFromArrayOfJSON() {
        struct Test: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"string")
            }
        }

        let tests = [Test].from(JSON: [["string": "Hi"], ["string": "Bye"]])
        XCTAssertTrue(tests?.count == 2)
    }

    func testCreatingFromPartiallyInvalidArrayOfJSON() {
        struct Test: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"string")
            }
        }

        let tests = [Test].from(JSON: [["string": "Hi"], ["nope": "Bye"]])
        XCTAssertTrue(tests?.count == 1)
    }

    func testCreatingFromInvalidArray() {
        struct Test: Mappable {
            let string: String
            init(map: Mapper) throws {
                try self.string = map.from(field:"string")
            }
        }

        let tests = [Test].from(JSON: ["hi"])
        XCTAssertNil(tests)
    }

    // MARK: Testing http://www.openradar.me/23376350

    func testCreatingWithConformanceInExtension() {
        let test = TestExtension.from(JSON: ["string": "Hi"])
        XCTAssertTrue(test?.string == "Hi")
    }
}
