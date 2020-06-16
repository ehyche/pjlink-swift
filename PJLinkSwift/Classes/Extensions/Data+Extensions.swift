//
//  Data+Extensions.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/4/20.
//

import Foundation
import CryptoKit

extension Data {

    public static func responses(fromData data: Data, inResponseToCommands commands: [Command]) throws -> [ResponseInfo] {
        guard let dataStr = String(data: data, encoding: .utf8) else {
            throw DeserializationError.badAsciiData
        }
        let responses = try dataStr.responses()
        // Pair up the commands the responses and create ResponseInfo's from the pairs
        return try ResponseInterpreter.matchCommands(commands, toResponses: responses).map { try ResponseInfo(command: $0.command, response: $0.response) }
    }
    
    public func parseAsPJLinkRequest() throws -> (auth: String, commands: [Command]) {
        guard let dataStr = String(data: self, encoding: .utf8) else {
            throw DeserializationError.badAsciiData
        }
        let request = dataStr.parseAsPJLinkRequest()
        let commands = try request.commands.map({ try Command(fromString: $0) })
        return (auth: request.auth, commands: commands)
    }
    
    public var md5: Data {
        return Data(Insecure.MD5.hash(data: self))
    }

    public var asHexString: String {
        return self.map({ String(format: "%02hhx", $0) }).joined()
    }

}
