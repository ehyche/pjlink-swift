//
//  Response.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/14/20.
//

import Foundation

public struct Response {
    
    // MARK: - Public properties
    
    public var cmdClass: CommandClass
    public var code: CommandCode
    public var data: String
    
    // MARK: - Internal static constants
    static let arraySeparator: Character = " "

    // MARK: - Private static constants
    
    private static let header: Character = "%"
    private static let equal: Character = "="
    private static let terminator: Character = "\n"
    private static let maxDataLength = 128
    
}

extension Response: Deserializable {
    
    public init(fromString string: String) throws {
        let chars = Array(string)
        guard chars.count >= 8 else {
            throw DeserializationError.notEnoughData
        }
        
        guard chars[0] == Response.header else {
            throw DeserializationError.unexpectedHeader(chars[0])
        }
        
        guard let classEnum = CommandClass(rawValue: String(chars[1])) else {
            throw DeserializationError.unexpectedClass(chars[1])
        }
        cmdClass = classEnum

        let commandStr = String(chars[2...5])
        guard let commandEnum = CommandCode(caseInsensitiveRawValue: commandStr) else {
            throw DeserializationError.unrecognizedCommandCode(commandStr)
        }
        code = commandEnum

        guard chars[6] == Response.equal else {
            throw DeserializationError.unexpectedSeparator(chars[6])
        }

        // Scan forward until we hit the terminator.
        // Put everything in between the separator and the terminator into the data string.
        let dataStartIndex = 7
        var i = dataStartIndex
        while i < chars.count && chars[i] != Response.terminator {
            i += 1
        }
        
        // Make sure that we ended on a terminator
        guard i < chars.count && chars[i] == Response.terminator else {
            throw DeserializationError.notTerminated
        }
        
        // Make sure we have at least one data byte
        let dataEndIndex = i - 1
        let dataLength = dataEndIndex - dataStartIndex + 1
        guard dataLength >= 0 && dataLength <= Response.maxDataLength else {
            throw DeserializationError.tooMuchResponseData(dataLength)
        }
        data = String(chars[dataStartIndex...dataEndIndex])
    }
    
}

extension Response: Serializable {
    
    public func toString() -> String {
        return String(Response.header) + cmdClass.rawValue + code.rawValue + String(Response.equal) + data + String(Response.terminator)
    }
    
}
