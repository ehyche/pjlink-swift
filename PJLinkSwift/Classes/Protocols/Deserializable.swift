//
//  Deserializable.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/14/20.
//

import Foundation

public enum DeserializationError: Error {
    case badAsciiData
    case notEnoughData
    case unexpectedHeader(Character)
    case unexpectedClass(Character)
    case unrecognizedCommandCode(String)
    case unexpectedSeparator(Character)
    case tooMuchParameterData(Int)
    case tooMuchResponseData(Int)
    case notTerminated
    case missingConnectionResponsePrefix
    case invalidConnectionResponse
    case incompleteConnectionResponse
    case invalidRandomNumber(String)
    case invalidSetResponseCode(String)
    case noCommands
    case invalidGetCommandResponse(CommandCode)
    case invalidStatusResponse(CommandCode)
    case invalidIntegerString(String)
    case invalidFreezeState(String)
}

public protocol Deserializable {

    init(fromString string: String) throws

}

extension Deserializable {

    init(fromData data: Data) throws {
        guard let str = String(data: data, encoding: .utf8) else {
            throw DeserializationError.badAsciiData
        }
        try self.init(fromString: str)
    }

}
