//
//  LampStatus.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/20/20.
//

import Foundation

public struct LampStatus: Codable {
    public var usage: Int
    public var state: LampState
    
    static let separator: Character = " "
}

extension LampStatus: Serializable {
    
    public func toString() -> String {
        return "\(usage)" + " " + state.rawValue
    }
}

public enum LampStatusDeserializationError: Error {
    case notEnoughData
    case oddNumberOfFields
    case invalidUsage(String)
    case invalidLampState(String)
}

extension LampStatus: Deserializable {

    public init(fromString string: String) throws {
        let words = string.split(separator: LampStatus.separator)
        guard words.count >= 2 else {
            throw LampStatusDeserializationError.notEnoughData
        }
        guard let usage = Int(words[0]) else {
            throw LampStatusDeserializationError.invalidUsage(String(words[0]))
        }
        self.usage = usage
        let lampStateStr = String(words[1])
        guard let state = LampState(rawValue: lampStateStr) else {
            throw LampStatusDeserializationError.invalidLampState(lampStateStr)
        }
        self.state = state
    }

}

