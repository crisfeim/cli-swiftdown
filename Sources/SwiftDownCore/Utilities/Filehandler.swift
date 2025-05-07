import Foundation

public struct TextFile {
	let name: String
	let content: String
}

protocol FileHandler: FileReader, FileWriter {}

public protocol FileReader {}
public extension FileReader {
	var fm: FileManager {.default}
	
	func getFileURLs(in folderURL: URL) throws -> [URL] {
		return try fm.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
	}
	
	func readFile(at url: URL) throws -> String {
		try String(contentsOf: url, encoding: .utf8)
	}
	
	static func readFile(at url: URL) throws -> String {
		try String(contentsOf: url, encoding: .utf8)
	}
	
	func isFile(at url: URL) throws -> Bool {
		var isDirectory: ObjCBool = false
		fm.fileExists(atPath: url.path, isDirectory: &isDirectory) 
		return !isDirectory.boolValue
	}
	
	func isNotDStore(at url: URL) -> Bool {!url.lastPathComponent.contains(".DS_Store")}
	
	func readContentsOfAllFiles(in folderURL: URL) throws -> [TextFile] {
		return try getFileURLs(in: folderURL)
		.filter(isFile)
		.filter(isNotDStore)
		.map {
			TextFile(
				name: $0.lastPathComponent, 
				content: try readFile(at: $0) 
			)
		}
	}
	
	func copyFiles(from sourceURL: URL, to destinationURL: URL, excluding excludedFileNames: [String]) throws {
		let fileManager = FileManager.default
		if !fileManager.fileExists(atPath: destinationURL.path) {
			try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)
		}
		
		let fileURLs = try fileManager.contentsOfDirectory(at: sourceURL, includingPropertiesForKeys: nil)
		
		for fileURL in fileURLs {
			if excludedFileNames.contains(fileURL.lastPathComponent) { continue }
			let destinationFileURL = destinationURL.appendingPathComponent(fileURL.lastPathComponent)
			
			if fileManager.fileExists(atPath: destinationFileURL.path) {
				try fileManager.removeItem(at: destinationFileURL)
			}
			
			try fileManager.copyItem(at: fileURL, to: destinationFileURL)
		}
	}
}


protocol FileWriter  {}
extension FileWriter {
	func write(_ string: String, to url: URL) throws {
		let folderURL = url.deletingLastPathComponent()
		let fileManager = FileManager.default
		if !fileManager.fileExists(atPath: folderURL.path) {
			try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
		}
		
		try string.write(to: url, atomically: true, encoding: .utf8)
	}
}


