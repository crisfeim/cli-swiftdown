// Created by Cristian Felipe Patiño Rojas on 7/5/25.
import XCTest
import swiftdown

final class TemplateEngineTests: XCTestCase {
    
    func test() throws {
        let themeFolder = try makeTemporaryFolder(name: "theme")
        
        try "$title\n$content".write(
            to: themeFolder.appendingPathComponent("index.html"),
            atomically: true,
            encoding: .utf8
        )
        
        let sut = TemplateEngine(
            folder: themeFolder,
            data: ["$title": "Hello world!", "$content": "Template rendered"]
        )
        let rendered = try sut.render()
        
        XCTAssertEqual(rendered, "Hello world!\nTemplate rendered")
    }
    
    @discardableResult
    func makeTemporaryFolder(name: String) throws -> URL {
        let tmpFolder  = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try FileManager.default.createDirectory(at: tmpFolder, withIntermediateDirectories: true, attributes: nil)
        try FileManager.default.createDirectory(at: tmpFolder, withIntermediateDirectories: true, attributes: nil)
        return tmpFolder
    }
}
