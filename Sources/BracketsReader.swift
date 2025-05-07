import Foundation

final class BracketsReader {
	
	func parse(_ string: String) -> [Int: Int] {
		var dict = [Int: Int]()
		var stack = [Int]()
		
		string.components(separatedBy: "\n").enumerated().forEach { index, line in
			let lineNumber = index + 1
			
			if line.contains("{") {
				stack.append(lineNumber)
			}
			
			if line.contains("}") {
				if let lastOpenLine = stack.popLast() {
					dict[lastOpenLine] = lineNumber
				}
			}
		}
		
		return dict
	}
}

func test_() {
	let sut = BracketsReader()
	let input = """
	func myFunc() { // 1
		struct Test { // 2 
			enum Test { // 3
				case hello() // 4
			}  // 5
		} // 6
	} // 7
	"""
	let output = sut.parse(input)
	let expectedOutput = [1:7,2:6,3:5]
	assert(output == expectedOutput)
}

