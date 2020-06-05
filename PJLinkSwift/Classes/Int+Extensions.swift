//
//  Int+Extensions.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/5/20.
//

import Foundation

extension Int: Serializable {

    public func toString() -> String {
        return "\(self)"
    }

}

extension Int: Deserializable {

    public init(fromString string: String) throws {
        guard let strInt = Int(string) else {
            throw DeserializationError.invalidIntegerString(string)
        }
        self = strInt
    }

}
