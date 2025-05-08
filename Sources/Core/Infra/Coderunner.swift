// Copyright © 2025 Cristian Felipe Patiño Rojas
// Released under the MIT License

import Foundation

public struct CodeRunner {
    let executablePath: String

    func run(_ code: String) throws -> String {
        try run(code, with: "temp", extension: nil)
    }

    public func run(_ code: String, with tmpFilename: String, extension ext: String?) throws -> String {
        let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "\(tmpFilename).\(ext ?? "no-extension")")
        try write(code, to: tempFileURL)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = [tempFileURL.path]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe

        try process.run()
        process.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let log = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Unable to read output", code: 0)
        }
        return log
    }

    func write(_ string: String, to url: URL) throws {
        let folderURL = url.deletingLastPathComponent()
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.createDirectory(
                at: folderURL, withIntermediateDirectories: true, attributes: nil)
        }

        try string.write(to: url, atomically: true, encoding: .utf8)
    }

    nonisolated(unsafe) public static let swift = CodeRunner(executablePath: "/usr/bin/swift")
}
