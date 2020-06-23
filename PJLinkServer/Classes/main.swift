//
//  main.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/11/20.
//

import Foundation
import PJLinkSwift

guard CommandLine.arguments.count == 2 else {
    print("Usage: PJLinkSwift <configfile.json>")
    exit(0)
}

let configFile = CommandLine.arguments[1]
guard let data = FileManager.default.contents(atPath: configFile) else {
    print("Could not open configuration file at \(configFile)")
    exit(0)
}

let decoder = JSONDecoder()

var server: PJLinkServer? = nil

do {
    let state = try decoder.decode(ProjectorState.self, from: data)
    let pjServer = try PJLinkServer(state: state)
    pjServer.start(on: DispatchQueue.main)
    server = pjServer
    RunLoop.current.run()
} catch {
    print("Error: \(error)")
    server?.stop()
}
