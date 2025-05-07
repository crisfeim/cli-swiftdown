import Foundation
import RegexBuilder

public struct LogsParser {
	
    public init() {}
	public func parse(_ string: String) -> String {
		replaceLineNumberWithButton(in: string)
	}
	
	func replaceLineNumberWithButton(in text: String) -> String {
		let regex = Regex {
			Capture {
				OneOrMore(.digit)
			}
			OneOrMore(.whitespace) 
			Capture {
				ChoiceOf { 
					"✅"
					"❌"
				}
			}
			OneOrMore(.whitespace) 
		}
		
		let result = text.replacing(regex) { match in
			let lineNumber = match.1
			let symbol = match.2
			return "<button onclick=\"gotomatchingline(\(lineNumber))\">\(lineNumber)</button> \(symbol) "
		}
        return ""
	}
}

func test_logparser() {
	let sut = LogsParser()
	let output = sut.parse("207 ✅ test_login_success()")
	let expectedOutput = #"<button onclick="gotomatchingline(207)">207</button> ✅ test_login_success()"#
	print(output)
	assert(output == expectedOutput)
}
