// Copyright © 2025 Cristian Felipe Patiño Rojas
// Released under the MIT License

import Foundation

public struct MarkdownParser {
    public init() {}
	public func parse(_ string: String) -> String {
		string.replacingOccurrences(of: #"^### (.*)$"#, with: "<h3>$1</h3>", options: .regularExpression)
		.replacingOccurrences(of: #"^## (.*)$"#, with: "<h2>$1</h2>", options: .regularExpression)
		.replacingOccurrences(of: #"^# (.*)$"#, with: "<h1>$1</h1>", options: .regularExpression)
		.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "<strong>$1</strong>", options: .regularExpression)
		.replacingOccurrences(of: "\\*(.*?)\\*", with: "<em>$1</em>", options: .regularExpression)
		.replacingOccurrences(of: "__(.*?)__", with: "<u>$1</u>", options: .regularExpression)
		.replacingOccurrences(of: "~~(.*?)~~", with: "<del>$1</del>", options: .regularExpression)
		.replacingOccurrences(of: "!\\[(.*?)\\]\\((.*?)\\)", with: "<img src=\"$2\" alt=\"$1\" />", options: .regularExpression)
		.replacingOccurrences(of: "`(.*?)`", with: "<code>$1</code>")
	}
}
