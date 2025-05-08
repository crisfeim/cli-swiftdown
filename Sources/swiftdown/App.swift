// Copyright © 2025 Cristian Felipe Patiño Rojas
// Released under the MIT License

import Foundation
import ArgumentParser
import Core

@main
struct SwiftDownCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swiftdown",
        abstract: "Static-site generator for Swift snippets.",
        subcommands: [Build.self, Serve.self]
    )
}

extension SwiftDownCLI {
    struct Build: ParsableCommand {
        @Argument(help: "Project folder's path")
                var folder: String = "."
        
        func run() throws {
            let (ssg, _) = try Composer.compose(with: folder)
            try ssg.build()
        }
    }
    
    struct Serve: ParsableCommand {
        @Argument(help: "Project folder's path")
                var folder: String = "."
        func run() throws {
            let (_, server) = try Composer.compose(with: folder)
            server.run()
        }
    }
}


