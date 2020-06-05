//
//  ConnectionResponse.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/14/20.
//

import Foundation

public struct ConnectionResponse {

    public var authenticated: Bool
    public var randomHexString: String?
    
    private static let pjlink = "PJLINK"
    private static let space: Character = " "
    private static let authChar: Character = "1"
    private static let noAuthChar: Character = "0"
    private static let terminator: Character = "\n"
}

extension ConnectionResponse: Deserializable {

    public init(fromString string: String) throws {
        let chars = Array(string)
        guard chars.count >= 8 else {
            throw DeserializationError.notEnoughData
        }
        
        let signature = String(chars[0...5])
        guard signature == ConnectionResponse.pjlink else {
            throw DeserializationError.missingConnectionResponsePrefix
        }
        
        guard chars[6] == ConnectionResponse.space,
              (chars[7] == ConnectionResponse.authChar || chars[7] == ConnectionResponse.noAuthChar) else {
            throw DeserializationError.invalidConnectionResponse
        }

        authenticated = (chars[7] == ConnectionResponse.authChar ? true : false)
        
        // Scan forward until we hit the terminator
        let startIndex = 8
        var i = startIndex
        while i < chars.count && chars[i] != ConnectionResponse.terminator {
            i += 1
        }

        // Make sure that we ended on a terminator
        guard i < chars.count && chars[i] == ConnectionResponse.terminator else {
            throw DeserializationError.notTerminated
        }
        
        
        if authenticated {
            let endIndex = i
            let dataLength = endIndex - startIndex
            guard dataLength >= 9 else {
                throw DeserializationError.incompleteConnectionResponse
            }
            
            guard chars[startIndex] == ConnectionResponse.space else {
                throw DeserializationError.invalidConnectionResponse
            }
            
            // Make sure that this can be decoded as a hex string
            let hexStr = String(chars[startIndex+1..<endIndex])
            guard Int(hexStr, radix: 16) != nil else {
                throw DeserializationError.invalidRandomNumber(hexStr)
            }
            randomHexString = hexStr
        } else {
            randomHexString = nil
        }
    }

}

extension ConnectionResponse: Serializable {

    public func toString() -> String {
        var str = ConnectionResponse.pjlink + String(ConnectionResponse.space) + (authenticated ? "1" : "0")
        if authenticated {
            str += String(ConnectionResponse.space)
            str += randomHexString ?? ""
        }
        str += String(ConnectionResponse.terminator)
        return str
    }

}
