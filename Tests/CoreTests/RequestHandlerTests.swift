// Created by Cristian Felipe Patiño Rojas on 7/5/25.

import XCTest
import MiniSwiftServer
import swiftdown

final class RequestHandlerTests: XCTestCase {
    
    func test_process_requestWithURLParametersIgnoresParametersAndCorrectlyReturnResourceContent() throws {
        let sut = makeSUT()
        let response = sut.process(anyRequestWithURLParameter(onPath: "css/styles.css"))
        let expectedResult = try readThemeResource("css/styles.css")
        XCTAssertEqual(response.contentType, "text/css")
        XCTAssertEqual(response.bodyAsText, expectedResult)
    }
    
    func test_process_swiftFileRequestReturnsSwiftFile() throws {
        let sut = makeSUT()
        let request = Request(method: .get, path: "example.swift.txt")
        let response = sut.process(request)
        let expectedResult = try readSwiftFile("example.swift.txt")
        XCTAssertEqual(response.bodyAsText, expectedResult)
    }
    
    func test_process_cssFileRequestReturnsCSSFile() throws {
        let sut = makeSUT()
        let request = Request(method: .get, body: nil, path: "css/styles.css")
        let response = sut.process(request)
        let expectedResult = try readThemeResource("css/styles.css")
        XCTAssertEqual(response.contentType , "text/css")
        XCTAssertEqual(response.bodyAsText , expectedResult)
    }
    
    func test_process_imageRequestsReturnsImage() throws {
        let sut = makeSUT()
        let response = sut.process(Request(method: .get, body: nil, path: "assets/author.jpg"))
        let expectedResult = try readThemeResourceAsData("assets/author.jpg")
        
        XCTAssertEqual(response.contentType , "image/jpeg")
        XCTAssertEqual(response.binaryData , expectedResult)
    }
    
    func makeSUT() -> RequestHandler {
        RequestHandler(
            parser: {try String(contentsOf: $0, encoding: .utf8)},
            themeURL: themeFolder(),
            sourcesURL: sourcesFolder(),
            sourceExtension: "txt"
        )
    }
}

extension RequestHandlerTests {
    
    private func anyRequestWithURLParameter(onPath path: String) -> Request {
        Request(method: .get, path: "\(path)?livereload=1729723229700")
    }
    
    private func readSwiftFile(_ path: String) throws -> String {
        try String(
            contentsOf: sourcesFolder().appendingPathComponent(path),
            encoding: .utf8
        )
    }
    
    private func readThemeResourceAsData(_ path: String) throws -> Data {
        try Data(contentsOf: themeFolder().appendingPathComponent(path))
    }
    
    private func readThemeResource(_ path: String) throws -> String {
        try String(
            contentsOf: themeFolder().appendingPathComponent(path),
            encoding: .utf8
        )
    }
    
    func testsResourceDirectory() -> URL {
        Bundle.module.bundleURL.appendingPathComponent("Contents/Resources")
    }
    
    func sourcesFolder() -> URL {
        inputFolder().appendingPathComponent("sources")
    }
    
    func inputFolder() -> URL {
        testsResourceDirectory().appendingPathComponent("input")
    }
    
    func themeFolder() -> URL {
        inputFolder().appendingPathComponent("theme")
    }
    
    func outputFolder() -> URL {
        testsResourceDirectory().appendingPathExtension("output")
    }
}
