// Created by Cristian Felipe Patiño Rojas on 7/5/25.


import Foundation

public protocol Runner {
	func run(_ code: String, with tmpFilename: String, extension ext: String?) throws -> String
}
