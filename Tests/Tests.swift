// Created by Cristian Felipe Patiño Rojas on 7/5/25.

import XCTest

final class Test: XCTest {
    func test() {
        XCTExpectFailure {
            XCTFail()
        }
    }
}
