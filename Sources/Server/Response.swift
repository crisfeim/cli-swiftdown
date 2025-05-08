// Copyright © 2025 Cristian Felipe Patiño Rojas
// Released under the MIT License

import Foundation

public struct Response {
    public let statusCode: Int
    public let contentType: String
    public let body: Body
    
    public init(statusCode: Int, contentType: String, body: Body) {
        self.statusCode = statusCode
        self.contentType = contentType
        self.body = body
    }
}

extension Response {
	public enum Body {
		case text(String)
		case binary(Data)
	}
	
	func toHTTPResponse() -> String {
		var response = "HTTP/1.1 \(statusCode)\r\n"
		response += "Content-Type: \(contentType)\r\n"
		
		switch body {
		case .text(let textBody):
			response += "Content-Length: \(textBody.utf8.count)\r\n"
			response += "\r\n" // Separador entre headers y body
			response += textBody
		case .binary(let binaryBody):
			response += "Content-Length: \(binaryBody.count)\r\n"
			response += "\r\n" // Separador entre headers y body
		}
		
		return response
	}
	
	public var bodyAsText: String? {
		switch body {
			case .text(let text): return text
			default: return nil
		}
	}
	
	public var binaryData: Data? {
		switch body {
		case .binary(let binaryBody):
			return binaryBody
		case .text:
			return nil
		}
	}
}
