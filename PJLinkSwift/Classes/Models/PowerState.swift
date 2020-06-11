//
//  PowerState.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/20/20.
//

import Foundation

public enum PowerState: String, Codable {
    case off = "0"
    case on  = "1"
    case cooling = "2"
    case warmup = "3"
}

extension PowerState: Serializable {

    public func toString() -> String {
        return self.rawValue
    }

}

public enum PowerStateError: Error {
    case invalidPowerState(String)
}

extension PowerState: Deserializable {
    
    public init(fromString string: String) throws {
        guard let state = PowerState(rawValue: string) else {
            throw PowerStateError.invalidPowerState(string)
        }
        self = state
    }
    
}
