// Created by Cristian Felipe Patiño Rojas on 7/5/25.


import Foundation
import ArgumentParser
import SwiftDownCore
import SimpleServer

enum Composer {
    static func compose(with pathURL: String) throws -> (SwiftDown, Server) {
        let folderURL   = URL(fileURLWithPath: pathURL).standardizedFileURL
        let sourcesURL  = folderURL.appendingPathComponent("sources")
        let themeURL    = folderURL.appendingPathComponent("theme")
        let outputURL   = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                           .appendingPathComponent("build")

        guard FileManager.default.fileExists(atPath: sourcesURL.path) else {
            throw ValidationError("Sources folder not found at: \(sourcesURL.path)")
        }
        guard FileManager.default.fileExists(atPath: themeURL.path) else {
            throw ValidationError("Sources folder not found at: \(themeURL.path)")
        }
        
        return make(sourcesURL: sourcesURL, themeURL: themeURL, outputURL: outputURL)
    }
    
   private static func make(
        sourcesURL: URL,
        themeURL: URL,
        outputURL: URL
    ) -> (SwiftDown, Server) {

        let ssg = SwiftDown(
            runner: CodeRunner.swift,
            syntaxParser: SwiftSyntaxHighlighter(),
            logsParser: LogsParser(),
            markdownParser: MarkdownParser(),
            sourcesURL: sourcesURL,
            outputURL: outputURL,
            themeURL: themeURL,
            langExtension: "swift",
            author: .init(name: "Cristian Felipe Patiño Rojas", website: "https://crisfe.me")
        )
        
        let requestHandler = SwiftDown.RequestHandler(
            parser: ssg.parse,
            themeURL: themeURL,
            sourcesURL: sourcesURL,
            sourceExtension: "swift"
        )
        
        let server = Server(
            port: 4000,
            requestHandler: requestHandler.process
        )
        
        return (ssg, server)
    }
}
