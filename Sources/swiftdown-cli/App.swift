// Created by Cristian Felipe Patiño Rojas on 7/5/25.

import Foundation
import ArgumentParser
import swiftdown

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
            let (ssg, _) = try Composer.compose(folder)
            try ssg.build()
        }
    }
    
    struct Serve: ParsableCommand {
        @Argument(help: "Project folder's path")
                var folder: String = "."
        func run() throws {
            let (_, server) = try Composer.compose(folder)
            server.run()
        }
    }
}


