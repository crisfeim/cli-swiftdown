import Foundation

enum Token {
	case keyword(Keyword)
	case definition(String)
	case openingBracket(matching: Int?)
	case closingBrackets(matching: Int?)
	case call(String)
	case string(String)
	case openingParenthesis
	case closingParenthesis
}

enum Keyword: String, CaseIterable {
	case `func`
	case `class`
	case `struct`
	case `enum`
	case `typealias`
	case `import`
	case `let`
	case `var`
	case `IBOulet`
	case `switch`
	case `do`
	case `catch`
	case final
	case `frozen`
}

struct Highlighter {
	func parse(_ string: String) -> [Int: [Token]] {
		let lines = string.components(separatedBy: "\n")
		var dict = [Int:[Token]]()
		lines.enumerated().forEach { index, line in
			dict[index + 1] = parseLine(line)
		}
		return dict
	}
	
	func parseLine(_ line: String) -> [Token] {
		let words = line.components(separatedBy: " ")
		return words.map { word in
			parseWord(word)
		} 
	}
	
	func parseWord(_ word: String) -> Token {
		if word.contains("()") {
			return Token.definition(word.components(separatedBy: "()")[0])
		}
		
		if let keyword = Keyword(rawValue: word) {
			return Token.keyword(keyword)
		}
		
		return Token.openingBracket(matching: nil)
	}
}

func test() {
	let sut = Highlighter()
	let code = """
	func myFunc() {
		print("hello world")
	}
	"""
	let output = sut.parse(code)
	let expectedOutput = [
		1: [
			Token.keyword(.func), 
			Token.definition("myFunc"), 
			Token.openingBracket(matching: 3)
		],
		2: [
			Token.call("print"),
			Token.openingParenthesis,
			Token.string("hello world"),
			Token.closingParenthesis
		],
		3: [
			Token.closingBrackets(matching: 1)
		]
	]
	
	print(output[1]!)
	assert(output as NSDictionary == expectedOutput as NSDictionary)
}

