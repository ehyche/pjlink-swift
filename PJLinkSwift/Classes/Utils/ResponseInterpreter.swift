//
//  ResponseInterpreter.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/5/20.
//

import Foundation

typealias CommandResponsePair = (command:Command,response:Response)

struct ResponseInterpreter {

    static func matchCommands(_ commands: [Command], toResponses responses: [Response]) -> [CommandResponsePair] {
        var pairs = [CommandResponsePair]()
        
        var mutableCommands = commands
        for response in responses {
            // Look for the first command in the list with the same command code.
            if let firstIndex = mutableCommands.firstIndex(where: { $0.code == response.code }) {
                // We found a command with a matching command code, so pair them up
                let command = mutableCommands.remove(at: firstIndex)
                pairs.append(CommandResponsePair(command: command, response: response))
            }
        }
        
        return pairs
    }
    
}
