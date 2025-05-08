// Copyright © 2025 Cristian Felipe Patiño Rojas
// Released under the MIT License

import Foundation

public struct Request  {
	public let method: Method
	public let body: Data?
	public let path: String
    
    public init(method: Method, body: Data? = nil, path: String) {
        self.method = method
        self.body = body
        self.path = path
    }
}

extension Request {
    public enum Method: String {
        case get
        case post
        case patch
        case put
        case delete
    }
    
    public enum Error: Swift.Error {
        case noMethodFound
        case invalidMethod(String)
        case noPathFound
    }
    
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

