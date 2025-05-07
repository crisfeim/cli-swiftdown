import Foundation

struct TemplateRenderer {
	let folder: URL
	let data: [String: String]
	var index: URL {
		folder.appendingPathComponent("index.html")
	}
	func render() throws -> String {
		data.reduce(try String(contentsOf: index, encoding: .utf8)) { content, data in
			content.replacingOccurrences(of: data.key, with: data.value)
		}
	}
}

final class TemplateRendererTests {
	
	func run() throws {
		let themeFolder = try makeTemporaryFolder(name: "theme")
		try "$title\n$content".write(to: themeFolder.appendingPathComponent("index.html"), atomically: true, encoding: .utf8)
		
		let sut = TemplateRenderer(folder: themeFolder, data: ["$title": "Hello world!", "$content": "Template rendered"])
		let rendered = try sut.render()
		
		assert(rendered == "Hello world!\nTemplate rendered")
	}
	
	@discardableResult
	func makeTemporaryFolder(name: String) throws -> URL {
		let tmpFolder  = FileManager.default.temporaryDirectory.appendingPathComponent(name)
		try FileManager.default.createDirectory(at: tmpFolder, withIntermediateDirectories: true, attributes: nil)
		try FileManager.default.createDirectory(at: tmpFolder, withIntermediateDirectories: true, attributes: nil)
		return tmpFolder
	} 
}