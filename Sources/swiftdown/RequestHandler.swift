// Copyright © 2025 Cristian Felipe Patiño Rojas
// Released under the MIT License

import Foundation
import Server
import Core

public struct RequestHandler {
    let parser    : (URL) throws -> String
    let themeURL  : URL
    let sourcesURL: URL
    let sourceExtension: String
    
    public init(
        parser: @escaping (URL) throws -> String,
        themeURL: URL,
        sourcesURL: URL,
        sourceExtension: String
    ) {
        self.parser = parser
        self.themeURL = themeURL
        self.sourcesURL = sourcesURL
        self.sourceExtension = sourceExtension
    }
    
    public func process(_ request: Request) -> Response {
        if request.path == "/" || request.path.isEmpty {
            return handleIndex()
        }
        // if request has parameters, it's a resource
        guard !request.path.contains("?") else {
            return handleResourceFileWithParameters(request)
        }
        
        guard let ext = request.path.components(separatedBy: ".").last else {
            return Response(
                statusCode: 400,
                contentType: "text/html",
                body: .text("Paths need to have an extension")
            )
        }
        
        if ext == sourceExtension {
            return handleSourceFile(request.path)
        } else if ext == "html" {
            return handleSourceFileWithHTMLExtension(request.path)
        } else {
            return handleResourceFile(request.path, ext: ext)
        }
    }
    
    private func handleIndex() -> Response {
        let fileURL = sourcesURL.appendingPathComponent("main.\(sourceExtension)")
        guard let parsed = try? parser(fileURL) else {
            return Response(statusCode: 400, contentType: "text/html", body: .text("Add your main.swift file!"))
        }
        
        return Response(statusCode: 200, contentType: "text/html", body: .text(parsed))
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
