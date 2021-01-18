import XCTest
import Composed
@testable import ComposedUI

final class SingleElementSectionTests: XCTestCase {
    func testNumberOfElementsWithOptional() {
        let section = SingleElementSection<String?>(element: nil)

        XCTAssertEqual(section.numberOfElements, 0)

        section.replace(element: "")

        XCTAssertEqual(section.numberOfElements, 1)

        section.replace(element: .none)

        XCTAssertEqual(section.numberOfElements, 0)
    }

    func testNumberOfElementsWithOptionalPerformance() {
        let section = SingleElementSection<String?>(element: nil)

        measure {
            (0..<10_000).forEach { index in
                if index % 2 != 0 {
                    section.replace(element: String(describing: index))

                    // When the element is set the delegate will likely call `numberOfElements` 1 or more times.
                    // When the section itself is moved or otherwise queried `numberOfElements` is often called,
                    // so it will usually be called more frequently than `replace(element:)`.
                    (0..<10).forEach { _ in
                        XCTAssertEqual(section.numberOfElements, 1)
                    }
                } else {
                    section.replace(element: nil)

                    (0..<10).forEach { _ in
                        XCTAssertEqual(section.numberOfElements, 0)
                    }
                }
            }
        }
    }

    func testNumberOfElementsWithNonOptionalPerformance() {
        let section = SingleElementSection<String>(element: "")

        measure {
            (0..<10_000).forEach { index in
                section.replace(element: String(describing: index))

                (0..<10).forEach { _ in
                    XCTAssertEqual(section.numberOfElements, 1)
                }
            }
        }
    }
}
