//
//  Serializable.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/14/20.
//

import Foundation

public enum SerializationError: Error {
    case notRepresentableAsAscii
}

public protocol Serializable {

    func toString() -> String
    
}

extension Serializable {

    func toData() throws -> Data {
        guard let data = toString().data(using: .utf8) else {
            throw SerializationError.notRepresentableAsAscii
        }
        return data
    }
    
}
