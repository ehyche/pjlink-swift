//
//  ResolutionInfo.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/21/20.
//

import Foundation

public struct ResolutionInfo {
    public var horizontal: Int
    public var vertical: Int

    private static let separatorToken: Character = "x"
}

extension ResolutionInfo: Serializable {

    public func toString() -> String {
        return "\(horizontal)" + String(ResolutionInfo.separatorToken) + "\(vertical)"
    }

}

public enum ResolutionInfoDeserializationError: Error {
    case invalidFormat(String)
    case invalidHorizontalResolution(String)
    case invalidVerticalResolution(String)
}

extension ResolutionInfo: Deserializable {

    public init(fromString string: String) throws {
        let words = string.split(separator: ResolutionInfo.separatorToken)
        guard words.count == 2 else {
            throw ResolutionInfoDeserializationError.invalidFormat(string)
        }
        guard let horizontal = Int(words[0]) else {
            throw ResolutionInfoDeserializationError.invalidHorizontalResolution(String(words[0]))
        }
        self.horizontal = horizontal
        guard let vertical = Int(words[1]) else {
            throw ResolutionInfoDeserializationError.invalidVerticalResolution(String(words[1]))
        }
        self.vertical = vertical
    }

}

