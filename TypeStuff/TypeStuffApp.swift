//
//  TypeStuffApp.swift
//  TypeStuff
//
//  Created by Alex Bird on 30/05/2026.
//

import Cocoa

@main
class TypeStuffMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }
}
