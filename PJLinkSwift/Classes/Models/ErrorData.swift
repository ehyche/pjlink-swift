//
//  ErrorData.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/20/20.
//

import Foundation

public struct ErrorData: Codable {
    public var fan: ErrorState
    public var lamp: ErrorState
    public var temperature: ErrorState
    public var coverOpen: ErrorState
    public var filter: ErrorState
    public var other: ErrorState
}

extension ErrorData: Serializable {

    public func toString() -> String {
        return fan.rawValue + lamp.rawValue + temperature.rawValue + coverOpen.rawValue + filter.rawValue + other.rawValue
    }

}

public enum ErrorDataDeserializationError: Error {
    case notEnoughData
    case invalidFanError(Character)
    case invalidLampError(Character)
    case invalidTemperatureError(Character)
    case invalidCoverOpenError(Character)
    case invalidFilterError(Character)
    case invalidOtherError(Character)
}

extension ErrorData: Deserializable {

    public init(fromString string: String) throws {
        guard string.count >= 6 else {
            throw ErrorDataDeserializationError.notEnoughData
        }
        let chars = Array(string)
        guard let fan = ErrorState(rawValue: String(chars[0])) else {
            throw ErrorDataDeserializationError.invalidFanError(chars[0])
        }
        self.fan = fan
        guard let lamp = ErrorState(rawValue: String(chars[1])) else {
            throw ErrorDataDeserializationError.invalidLampError(chars[1])
        }
        self.lamp = lamp
        guard let temperature = ErrorState(rawValue: String(chars[2])) else {
            throw ErrorDataDeserializationError.invalidTemperatureError(chars[2])
        }
        self.temperature = temperature
        guard let coverOpen = ErrorState(rawValue: String(chars[3])) else {
            throw ErrorDataDeserializationError.invalidCoverOpenError(chars[3])
        }
        self.coverOpen = coverOpen
        guard let filter = ErrorState(rawValue: String(chars[4])) else {
            throw ErrorDataDeserializationError.invalidFilterError(chars[4])
        }
        self.filter = filter
        guard let other = ErrorState(rawValue: String(chars[5])) else {
            throw ErrorDataDeserializationError.invalidOtherError(chars[5])
        }
        self.other = other
    }

}
