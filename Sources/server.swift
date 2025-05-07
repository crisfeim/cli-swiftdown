import Foundation


import Foundation

struct Request  {
	enum Method: String {
		case get
		case post
		case patch
		case put
		case delete
	}
	
	enum Error: Swift.Error {
		case noMethodFound
		case invalidMethod(String)
		case noPathFound
	}
	
	let method: Method
	let body: Data?
	let path: String
}

extension Request {
	init(_ request: String) throws {
		let components = request.components(separatedBy: "\n\n")
		let headers = components.first?.components(separatedBy: "\n") ?? []
		let payload = components.count > 1 ? components[1].trimmingCharacters(in: .whitespacesAndNewlines) : nil
		
		method = try Self.method(headers)
		body   = try Self.body  (payload)
		path   = try Self.path  (headers)
	}
	
	init(_ buffer: Array<UInt8>) throws {
		try self.init(String(bytes: buffer, encoding: .utf8) ?? "")
	}
}

extension Request {
	static func method(_ headers: [String]) throws -> Method {
		let firstLine = headers.first?.components(separatedBy: " ")
		
		guard let stringMethod = firstLine?.first?.lowercased() else {
			throw Error.noMethodFound
		}
		
		guard let method = Method.init(rawValue: stringMethod) else {
			throw Error.invalidMethod(stringMethod)
		}
		
		return method        
	}
	
	static func body(_ payload: String?) throws -> Data? {
		guard let payload, let data = payload.data(using: .utf8) else { return nil }
		let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
		let normalizedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
		
		return normalizedData
	}
	
	static func path(_ headers: [String]) throws -> String {
		let firstLine = headers.first?.components(separatedBy: " ")
		guard let path = firstLine?[idx: 1] else { throw Error.noPathFound }
		return path.first == "/" ? String(path.dropFirst()) : path
	}
}

fileprivate extension Array {
	subscript(idx idx: Int) -> Element? {
		indices.contains(idx) ? self[idx] : nil
	}
}


struct Response {
	let statusCode: Int
	let contentType: String
	let body: Body
	
	enum Body {
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
	
	var bodyAsText: String? {
		switch body {
			case .text(let text): return text
			default: return nil
		}
	}
	
	var binaryData: Data? {
		switch body {
		case .binary(let binaryBody):
			return binaryBody
		case .text:
			return nil
		}
	}
}

protocol RequestHandler {
	func process(_ request: Request) -> Response
}

struct Server {
	
	let port: UInt16
	let requestHandler: RequestHandler

	func run() {
		
		let _socket = socket(AF_INET, SOCK_STREAM, 0)
		guard _socket >= 0 else {
			fatalError("Unable to create socket")
		}
		
		var value: Int32 = 1
		setsockopt(_socket, SOL_SOCKET, SO_REUSEADDR, &value, socklen_t(MemoryLayout<Int32>.size))
		
		var serverAddress = sockaddr_in()
		serverAddress.sin_family = sa_family_t(AF_INET)
		serverAddress.sin_port = in_port_t(port).bigEndian
		serverAddress.sin_addr = in_addr(s_addr: INADDR_ANY)
		
		let bindResult = withUnsafePointer(to: &serverAddress) {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
				bind(_socket, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
			}
		}
		guard bindResult >= 0 else {
			fatalError("Error al enlazar el socket.")
		}
		
		guard listen(_socket, 10) >= 0 else {
			fatalError("Error al escuchar en el socket.")
		}
		
		print("Servidor escuchando en el puerto \(port)...")
		
		while true {
			var clientAddress = sockaddr_in()
			var clientAddressLength = socklen_t(MemoryLayout<sockaddr_in>.size)
			let clientSocket = withUnsafeMutablePointer(to: &clientAddress) {
				$0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
					accept(_socket, $0, &clientAddressLength)
				}
			}
			
			guard clientSocket >= 0 else {
				print("Error al aceptar la conexión.")
				continue
			}
			
			var buffer = [UInt8](repeating: 0, count: 1024)
			let bytesRead = read(clientSocket, &buffer, 1024)
			
			guard bytesRead > 0 else {
				print("No se leyeron datos.")
				close(clientSocket)
				continue
			}
			
			do {
				
				let request = try Request(buffer)
				let response = requestHandler.process(request)
				
				let headersAndBody = response.toHTTPResponse()
				
					// Enviamos los encabezados
					write(clientSocket, headersAndBody, headersAndBody.utf8.count)
				
					// Luego, enviamos el cuerpo en función de su tipo
					if let binaryData = response.binaryData {
						// Enviar datos binarios
						_ = binaryData.withUnsafeBytes { bytes in
							write(clientSocket, bytes.baseAddress!, binaryData.count)
						}
					}
				
				
				if response.statusCode != 200 {
					print("Failed response at \(request.path):")
					print(response)
				}
				
				close(clientSocket)
			}
			catch {
				print(error.localizedDescription)
			}
		}
	}
	
	
	enum ServerError: Error {
		case noEndpointFound(String)
		
		var message: String {
			switch self {
				case .noEndpointFound(let path): return "No endpoint found for \(path)"
			}
		}
	}
	
}

enum ServerTests {
	static func launch() {
		let themeURL   = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("input/theme")
		let sourcesURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("input/sources")
		let rh = PublisherRequestHandler(parser: {"parsed: \($0)"}, themeURL: themeURL, sourcesURL: sourcesURL, sourceExtension: "swift")
		Server(port: 8080, requestHandler: rh).run()
	}
}


struct PublisherRequestHandler: RequestHandler {
	let parser    : (URL) throws -> String
	let themeURL  : URL
	let sourcesURL: URL
	let sourceExtension: String
		
	func process(_ request: Request) -> Response {
		// if request has parameters, it's a resource
		guard !request.path.contains("?") else {
			return handleResourceFileWithParameters(request)
		}
		
		guard let ext = request.path.components(separatedBy: ".").last else {
			return Response(statusCode: 400, contentType: "text/html", body: .text("Paths need to have an extension"))
		}
		
		if ext == sourceExtension {
			return handleSourceFile(request.path)
		} else if ext == "html" {
			return handleSourceFileWithHTMLExtension(request.path)
		} else {
			return handleResourceFile(request.path, ext: ext)
		}
	}
	
	func handleSourceFileWithHTMLExtension(_ path: String) -> Response {
		handleSourceFile(path.replacingOccurrences(of: ".html", with: "") + ".swift")
	}
	
	func handleSourceFile(_ path: String) -> Response {
		let fileURL = sourcesURL.appendingPathComponent(path)
		guard let parsed = try? parser(fileURL) else {
			return Response(statusCode: 400, contentType: "text/html", body: .text("Unable to parse contents of \(path)"))
		}
		return Response(statusCode: 200, contentType: "text/html", body: .text(parsed))
	}
	
	// Ignore any param in the url, useful when using 
	// livereloadx
	func handleResourceFileWithParameters(_ request: Request) -> Response {
		let cleanPath = request.path.components(separatedBy: "?").first ?? request.path
		guard let ext = cleanPath.components(separatedBy: ".").last else {
			return Response(statusCode: 400, contentType: "text/html", body: .text("Paths need to have an extension"))
		}
		return handleResourceFile(cleanPath, ext: ext)
	}
	
	func handleResourceFile(_ path: String, ext: String) -> Response {
		
		let fileURL = themeURL.appendingPathComponent(path)
		
		let data = try? Data(contentsOf: fileURL)
		let content = try? String(contentsOf: fileURL, encoding: .utf8)

		if ext == "woff2", let data = data {
			return Response(statusCode: 200, contentType: "font/woff2", body: .binary(data))
		}
		
		if ext == "woff", let data = data {
			return Response(statusCode: 200, contentType: "font/woff", body: .binary(data))
		}
		
		if ext == "jpg", let data = data {
			return Response(statusCode: 200, contentType: "image/jpeg", body: .binary(data))
		}
		
		if ext == "css", let content {
			return Response(statusCode: 200, contentType: "text/css", body: .text(content))
		}
		
		if ext == "js", let content {
			return Response(statusCode: 200, contentType: "application/javascript", body: .text(content))
		}
		
		return Response(statusCode: 400, contentType: "text/html", body: .text("Unable to handle extension on \(path)"))
	}
	
	
}

struct PublisherRequestHandlerTests {
	
	func run() {
		test_source_file_is_parsed()
		launch(test_get_resource_with_params)
		launch(test_get_css)
		launch(test_get_font)
		launch(test_get_jpg)
	}
	
	let currentDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
	var themeURL  : URL { currentDir.appendingPathComponent("input/theme") }
	var sourcesURL: URL { currentDir.appendingPathComponent("input/sources") }
	
	func test_get_resource_with_params() throws {
		
		let parser = { (url: URL) in try String(contentsOf: url.appendingPathComponent("css/styles.css"), encoding: .utf8) }
		let sut = makeSUT(parser: parser)
		
		let response = sut.process(Request(method: .get, body: nil, path: "css/styles.css?livereload=1729723229700"))
		let expectedResult = try String(contentsOf: themeURL.appendingPathComponent("css/styles.css"), encoding: .utf8)
		
		assert(response.contentType == "text/css")
		assert(response.bodyAsText == expectedResult)	
	}

	func test_source_file_is_parsed() {
		let sut = makeSUT {
			"parsed: " + (try! String(contentsOf: $0, encoding: .utf8)) 
		}
		let response = sut.process(Request(method: .get, body: nil, path: "example.swift"))
		let expectedResult = "parsed: " + (try! String(contentsOf: sourcesURL.appendingPathComponent("example.swift"), encoding: .utf8))
		assert(response.bodyAsText == expectedResult)
	}
	
	
	func test_get_css() throws {
		let sut = makeSUT {
			try String(contentsOf: $0.appendingPathComponent("css/styles.css"), encoding: .utf8)
		}
		let response = sut.process(Request(method: .get, body: nil, path: "css/styles.css"))
		let expectedResult = try String(contentsOf: themeURL.appendingPathComponent("css/styles.css"), encoding: .utf8)
		
		assert(response.contentType == "text/css")
		assert(response.bodyAsText == expectedResult)	
	}
	
	func test_get_font() throws {
		let sut = makeSUT {_ in ""}
		let response = sut.process(Request(method: .get, body: nil, path: "fonts/iAWriterQuattroS-Regular.woff2"))
		
		let expectedResult = try Data(contentsOf: themeURL.appendingPathComponent("fonts/iAWriterQuattroS-Regular.woff2")) 
		
		assert(response.contentType == "font/woff2")
		assert(response.binaryData == expectedResult)	
	}
	
	func test_get_jpg() throws {
		let sut = makeSUT {_ in ""}
		let response = sut.process(Request(method: .get, body: nil, path: "assets/author.jpg"))
		
		let expectedResult = try Data(contentsOf: themeURL.appendingPathComponent("assets/author.jpg")) 
		
		assert(response.contentType == "image/jpeg")
		assert(response.binaryData == expectedResult)	
	}
	
	
	func makeSUT(parser: @escaping (URL) throws -> String = { _ in "" }) -> PublisherRequestHandler {
		
		return PublisherRequestHandler(
			parser: parser, 
			themeURL: themeURL, 
			sourcesURL: sourcesURL, 
			sourceExtension: "swift"
		)
	}
	
	func launch(_ test: () throws -> Void) {
		do {
			try test()
		} catch {
			print(error)
		}
	}
}
