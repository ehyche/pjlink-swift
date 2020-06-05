//
//  Data+Extensions.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/4/20.
//

import Foundation

extension Data {

    public static func responses(fromData data: Data, inResponseToCommands commands: [Command]) throws -> [ResponseInfo] {
        guard let dataStr = String(data: data, encoding: .utf8) else {
            throw DeserializationError.badAsciiData
        }
        let responses = try dataStr.responses()
        // Pair up the commands the responses and create ResponseInfo's from the pairs
        return try ResponseInterpreter.matchCommands(commands, toResponses: responses).map { try ResponseInfo(command: $0.command, response: $0.response) }
    }

}
