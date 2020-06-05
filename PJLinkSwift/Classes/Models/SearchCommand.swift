//
//  SearchCommand.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/15/20.
//

import Foundation

public struct SearchCommand {
    
    private static let header: Character = "%"
    private static let cmdClass = CommandClass.two
    private static let code = CommandCode.searchStart
    private static let terminator: Character = "\n"

}

extension SearchCommand: Deserializable {

    public init(fromString string: String) throws {
        let chars = Array(string)
        guard chars.count >= 7 else {
            throw DeserializationError.notEnoughData
        }
        
        guard chars[0] == SearchCommand.header else {
            throw DeserializationError.unexpectedHeader(chars[0])
        }
        
        guard CommandClass(rawValue: String(chars[1])) != nil else {
            throw DeserializationError.unexpectedClass(chars[1])
        }
        
        let cmdStr = String(chars[2...5])
        guard cmdStr == CommandCode.searchStart.rawValue else {
            throw DeserializationError.unrecognizedCommandCode(cmdStr)
        }
        
        guard chars[6] == SearchCommand.terminator else {
            throw DeserializationError.notTerminated
        }
    }

}

extension SearchCommand: Serializable {

    public func toString() -> String {
        return String(SearchCommand.header) + SearchCommand.cmdClass.rawValue + SearchCommand.code.rawValue + String(SearchCommand.terminator)
    }

}
