import Foundation

protocol Runner {
	func run(_ code: String, with tmpFilename: String, extension ext: String?) throws -> String
}

protocol Parser {
	func parse(_ string: String) -> String
}

struct SwiftDown: FileHandler {
	
	let runner         : Runner
	
	let syntaxParser   : Parser
	let logsParser     : Parser
	let markdownParser : Parser
	
	let sourcesURL	   : URL
	let outputURL      : URL 
	let themeURL       : URL
	let langExtension  : String
	
	let author         : Author
	
	func build() throws {
		try FileManager.default.createDirectory(
			at: outputURL, 
			withIntermediateDirectories: true, 
			attributes: nil
		)
		
		try writeTemplateAssets()
		
		try getFileURLs().forEach {
			let rendered = try parse($0)
			let outputURL = outputURL.appendingPathComponent($0.lastPathComponent + ".html")
			try write(rendered, to: outputURL)
		}
	}
	
	func getFileURLs() throws -> [URL] {
		try getFileURLs(in: sourcesURL).filter { $0.lastPathComponent.contains(".\(langExtension)") }
	}
	
	// @nicetohave:
	// If I had a more sophisticated templating engine,
	// this wouldn't be render here...
	func renderFiles() throws -> String {
		let elements = try getFileURLs().reduce("") { current, next in
			let path = next.lastPathComponent
			return current + """
			<li>
			<a	href="#"
				onclick="loadContent('/\(path)', 'main'); return false;">
				\(path)
			</a>
			"""
		}
		return "<ul>\(elements)</ul>"
	}
	
	func parse(_ url: URL) throws -> String {
		let filename = url.lastPathComponent
		let contents = try String(contentsOf: url, encoding: .utf8)
		
		let logs = logsParser.parse(try runner.run(contents, with: filename, extension: nil))
		
		var parse: (String) -> String { syntaxParser.parse >>> markdownParser.parse }
		
		let data = [
			"$title": filename,
			"$content": parse(contents),
			"$author-name": author.name,
			"$author-website": author.website,
			"$logs": logs,
			"$files": try renderFiles()
		]
		
		return try TemplateRenderer(folder: themeURL, data: data).render()	
	}
	
	func writeTemplateAssets() throws {
		try copyFiles(from: themeURL, to: outputURL, excluding: ["index.html"])
	}
}

infix operator >>> : AdditionPrecedence
func >>><A>(first: @escaping (A) -> A, second: @escaping (A) -> A) -> (A) -> A {
	return { input in second(first(input)) }
}

extension SwiftDown {
	struct Author {
		let name: String
		let website: String
	}
}

extension SwiftSyntaxHighlighter: Parser {}
extension MarkdownParser		: Parser {}
extension LogsParser			: Parser {}
extension CodeRunner			: Runner {}

final class Tests: FileReader {
	
	lazy var currentDir   = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
	lazy var testsFolder  = currentDir.appendingPathComponent("input/sources")
	lazy var themeFolder  = currentDir.appendingPathComponent("input/theme")
	lazy var outputFolder = currentDir.appendingPathComponent("input/output")
	
	func run() throws {
		try test_theme_resources_are_coppied()
		try test_codesource_files_are_copied_as_html()
	}
	
	func makeSUT() -> SwiftDown {
		SwiftDown(
			runner: CodeRunner.swift, 
			syntaxParser: SwiftSyntaxHighlighter(), 
			logsParser: LogsParser(),
			markdownParser: MarkdownParser(),
			sourcesURL: testsFolder,
			outputURL: outputFolder,
			themeURL: themeFolder,
			langExtension: "swift",
			author: .init(name: "Cristian Felipe Patiño Rojas", website: "https://cristian.lat")
		)
	}
	
	func test_theme_resources_are_coppied() throws {
		try makeSUT().build()
		
		let outputFiles = try fm.contentsOfDirectory(atPath: outputFolder.path)
		assert(outputFiles.contains("css"))
		assert(outputFiles.contains("js"))
		assert(outputFiles.contains("fonts"))
		assert(outputFiles.contains("assets"))
		assert(!outputFiles.contains("index.html"))
	}
	
	func test_codesource_files_are_copied_as_html() throws {
		try makeSUT().build()
		
		let outputFiles = try fm.contentsOfDirectory(atPath: outputFolder.path)
		assert(outputFiles.contains("example.swift.html"))
	}
	
	func getFileContents(fileName: String) throws -> String {
		let url = currentDir.appendingPathComponent("example.swift")
		return try String(contentsOfFile: url.path, encoding: .utf8)
	}
}

func launch_server() {
	
	let currentDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
	
	let themeURL   = currentDir.appendingPathComponent("input/theme")
	let sourcesURL = currentDir.appendingPathComponent("input/sources")
	let outputURL  = currentDir.appendingPathComponent("input/output")
	
	let publisher = SwiftDown(
		runner: CodeRunner.swift, 
		syntaxParser: SwiftSyntaxHighlighter(), 
		logsParser: LogsParser(),
		markdownParser: MarkdownParser(),
		sourcesURL: sourcesURL,
		outputURL: outputURL,
		themeURL: themeURL,
		langExtension: "swift",
		author: .init(name: "Cristian Felipe Patiño Rojas", website: "https://cristian.lat")
	)
	
	let rh = PublisherRequestHandler(
		parser: publisher.parse, 
		themeURL: themeURL,
		sourcesURL: sourcesURL, 
		sourceExtension: "swift"
	)
	
	Server(port: 8080, requestHandler: rh).run()
}

