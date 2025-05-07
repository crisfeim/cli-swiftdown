import Foundation

public struct TemplateEngine {
	let folder: URL
	let data: [String: String]

	var index: URL {
		folder.appendingPathComponent("index.html")
	}
    
    public init(folder: URL, data: [String : String]) {
        self.folder = folder
        self.data = data
    }
    
	public func render() throws -> String {
		data.reduce(try String(contentsOf: index, encoding: .utf8)) { content, data in
			content.replacingOccurrences(of: data.key, with: data.value)
		}
	}
}
