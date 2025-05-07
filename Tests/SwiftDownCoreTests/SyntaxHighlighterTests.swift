// Created by Cristian Felipe Patiño Rojas on 8/5/25.

import XCTest
import Core

class DefinitionsHighlighterTests: XCTestCase {
    
    func test_class() {
        let sut = SwiftSyntaxHighlighter.DefinitionsHighlighter()
        let input = #"<span class="keyword">class</span> MyType"#
        let expectedOutput = #"<span class="keyword">class</span> <span class="type-definition">MyType</span>"#
        let output = sut.highlightDefinition(on: input, .class)
        XCTAssertEqual(output, expectedOutput)
    }
    
    func test_enum() {
        let sut = SwiftSyntaxHighlighter.DefinitionsHighlighter()
        let input = #"<span class="keyword">enum</span> MyType"#
        let expectedOutput = #"<span class="keyword">enum</span> <span class="type-definition">MyType</span>"#
        let output = sut.highlightDefinition(on: input, .enum)
        XCTAssertEqual(output, expectedOutput)
    }
    
    func test() {
        let sut = SwiftSyntaxHighlighter.DefinitionsHighlighter()
        let input = #"<span class="keyword">class</span> MyType"#
        let expectedOutput = #"<span class="keyword">class</span> <span class="type-definition">MyType</span>"#
        let output = sut.run(input)
        XCTAssertEqual(output, expectedOutput)
    }
}


class LineInjectorTests: XCTestCase {
    func testRunWithEmptyString() {
        let injector = SwiftSyntaxHighlighter.LineInjector()
        let input = ""
        let expectedOutput = "<span id=\"line-1\" class=\"line-number empty-line\">1</span>\n"
        let output = injector.run(input)
        XCTAssertEqual(output, expectedOutput)
    }
}
