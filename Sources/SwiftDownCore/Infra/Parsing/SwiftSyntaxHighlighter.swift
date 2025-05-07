import Foundation
import Splash

public struct SwiftSyntaxHighlighter {
    
    private let splash = SyntaxHighlighter(format: HTMLOutputFormat())
	private let lineInjector = LineInjector()
	private let defintionHighlighter = DefinitionsHighlighter()
	private let customTypeParser = CustomTypeHighlighter()
	
    
    public init() {}
	 func run(_ string: String) -> String {
		let customTypes = customTypeParser.extractCustomTypes(from: string)
		let paserCustomTypes = { customTypeParser.run($0, from: customTypes) }
		return (
			splash.highlight >>>
			lineInjector.run >>>
			defintionHighlighter.run >>>
			parseKeywords >>>
			paserCustomTypes >>>
			parseComments >>>
			parseOperators
		)(string)
	}

	public func parse(_ string: String) -> String { run(string) }
	
	fileprivate func parseKeywords(on string: String) -> String {
		
		string.replacingOccurrences(
			of: #"<span class="call">throws</span>"#, 
			with: #"<span class="keyword">throws</span>"#
		)
		.replacingOccurrences(
			of: #"<span class="keyword">extension</span>"#,
			with: #"<span class="keyword-extension">extension</span>"#
		)
	}
	
	private func parseOperators(on string: String) -> String {
		string.replacingOccurrences(of: "infix operator", with: #"<span class="keyword">infix operator</span>"#)
		.replacingOccurrences(of: "prefix operator", with: #"<span class="keyword">prefix operator</span>"#)
		.replacingOccurrences(of: "postfix operator", with: #"<span class="keyword">postfix operator</span>"#)
	}
	
	private func parseComments(on string: String) -> String {
		string
		.replacingOccurrences(of: "/// ", with: "")
		.replacingOccurrences(of: "// ", with: "")
		.replacingOccurrences(of: "///", with: "")
		.replacingOccurrences(of: "//", with: "")
		.replacingOccurrences(of: "/*", with: "")
		.replacingOccurrences(of: "*/", with: "")
	}
}


fileprivate final class SwiftSyntaxHighlighterTests {
	func run() {
		test_keyword()
	}
	
	
	func test_keyword() {
		let sut = SwiftSyntaxHighlighter()
		let sourceCode = """
		<span class="call">throws</span>
		<span class="keyword">extension</span>
		"""
		let result = sut.parseKeywords(on: sourceCode)
		let expectedResult = """
		<span class="keyword">throws</span>
		<span class="keyword-extension">extension</span>
		"""
		
		assert(result == expectedResult)
	}
}



infix operator >>> : AdditionPrecedence
fileprivate func >>>(first: @escaping (String) -> String, second: @escaping (String) -> String) -> (String) -> String {
	return { input in second(first(input)) }
}

// MARK: - Definitions
extension SwiftSyntaxHighlighter {
	struct DefinitionsHighlighter {
		enum Definition: String, CaseIterable {
			case `class`
			case `enum` 
			case `struct`
			case `protocol`
			case `typealias`
			case `func`
			case `let`
			case `var`
			case `case`
			
			var cssClassName: String {
				switch self {
					case .func, .let, .var, .case: return "other-definition"
					default: return "type-definition"
				}
			}
		}
		
		
		func run(_ string: String) -> String {
			highlightDefinition(on: Definition.allCases.reduce(string) { current, keyword in
				highlightDefinition(on: current, keyword)
			}, definition: "final class", cssClassName: "type-definition")
		}
		
		func highlightDefinition(on string: String,_ definition: Definition) -> String {
			highlightDefinition(on: string, definition: definition.rawValue, cssClassName: definition.cssClassName)
		} 
		
		func highlightDefinition(on string: String, definition: String, cssClassName: String) -> String {
			let pattern = "(<span class=\"keyword\">\(definition)</span>)\\s+([A-Za-z][A-Za-z0-9_]*)"
			
			let template = "$1 <span class=\"\(cssClassName)\">$2</span>"
			
			do {
				let regex = try NSRegularExpression(pattern: pattern, options: [])
				let range = NSRange(string.startIndex..<string.endIndex, in: string)
				
				let modifiedString = regex.stringByReplacingMatches(
					in: string,
					options: [],
					range: range,
					withTemplate: template
				)
				
				return modifiedString
			} catch {
				print("Error en la regex: \(error)")
				return string
			}
		}
	}
}


#warning("Move to test target")
class DefinitionsHighlighterTests {
	func run() {
		test_class()
		test_enum()
		test()
	}
	
	func test_class() {
		let sut = SwiftSyntaxHighlighter.DefinitionsHighlighter() 
		let input = #"<span class="keyword">class</span> MyType"#
		let expectedOutput = #"<span class="keyword">class</span> <span class="type-definition">MyType</span>"#
		let output = sut.highlightDefinition(on: input, .class)
		assert(output == expectedOutput)
	}
	
	func test_enum() {
		let sut = SwiftSyntaxHighlighter.DefinitionsHighlighter() 
		let input = #"<span class="keyword">enum</span> MyType"#
		let expectedOutput = #"<span class="keyword">enum</span> <span class="type-definition">MyType</span>"#
		let output = sut.highlightDefinition(on: input, .enum)
		assert(output == expectedOutput)
	}
	
	func test() {
		let sut = SwiftSyntaxHighlighter.DefinitionsHighlighter()
		let input = #"<span class="keyword">class</span> MyType"#
		let expectedOutput = #"<span class="keyword">class</span> <span class="type-definition">MyType</span>"#
		let output = sut.run(input)
		print(output)
		assert(output == expectedOutput)
	}
}

// MARK: - LineInjector
extension SwiftSyntaxHighlighter {
	fileprivate struct LineInjector {
		// Injects lines as html `<span>`
		func run(_ string: String) -> String {
			string.components(separatedBy: "\n").enumerated().reduce("") { (result, line) in
				let (index, content) = line
				return result + makeLine(index, content)
			}
		}
		
		private func makeLine(_ index: Int, _ content: String) -> String {
			"<span id=\"line-\(index + 1)\" class=\"line-number \(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "empty-line" : "")\">\(index + 1)</span>" + content + "\n"
		}
	}
}

class LineInjectorTests {
	func run() {
		testRunWithEmptyString()
	}
	
	func testRunWithEmptyString() {
		let injector = SwiftSyntaxHighlighter.LineInjector()
		let input = ""
		let expectedOutput = "<span id=\"line-1\" class=\"line-number empty-line\">1</span>\n"
		let output = injector.run(input)
		assert(output == expectedOutput)
	}
}

extension SwiftSyntaxHighlighter {
	static func runTests() {
		SwiftSyntaxHighlighterTests().run()
		DefinitionsHighlighterTests().run()
		LineInjectorTests().run()
	}
}

// MARK: - CustopType 
extension SwiftSyntaxHighlighter {

	fileprivate struct CustomTypeHighlighter {
		
		func run(_ string: String, from types: Set<String>) -> String {
//			let types = extractCustomTypes(from: string)
			var result = string
			
			let pattern = #"<span class="type">([^<]+)</span>"#
			
			guard let regex = try? NSRegularExpression(pattern: pattern) else {
				return string
			}
			
			let matches = regex.matches(in: string, range: NSRange(string.startIndex..., in: string))
			
			for match in matches.reversed() {
				guard let typeRange = Range(match.range(at: 1), in: string) else { continue }
				let foundType = String(string[typeRange])
				
				if types.contains(foundType) {
					if let matchRange = Range(match.range, in: string) {
						let replacement = "<span class=\"custom-type\">\(foundType)</span>"
						result = result.replacingCharacters(in: matchRange, with: replacement)
					}
				}
			}
			return result
		}
	
		/// Gets custom types (created by the developper) on a given swift sourceCode
		func extractCustomTypes(from sourceCode: String) -> Set<String> {
			let typeDeclarationPatterns = [
						#"(?:class|struct|enum|protocol|typealias)\s+(\w+)"#
					]
			
			var customTypes = Set<String>()
			for pattern in typeDeclarationPatterns {
				guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
				let matches = regex.matches(
					in: sourceCode,
					range: NSRange(sourceCode.startIndex..., in: sourceCode)
				)
				for match in matches {
					if let range = Range(match.range(at: 1), in: sourceCode) {
						let typeName = String(sourceCode[range])
						customTypes.insert(typeName)
					}
				}
			}
			return customTypes
		}
	}
}
