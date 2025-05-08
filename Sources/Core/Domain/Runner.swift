// Copyright © 2025 Cristian Felipe Patiño Rojas
// Released under the MIT License

import Foundation

public protocol Runner {
	func run(_ code: String, with tmpFilename: String, extension ext: String?) throws -> String
}
