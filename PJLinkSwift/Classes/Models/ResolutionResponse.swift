//
//  ResolutionResponse.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/21/20.
//

import Foundation

public enum ResolutionResponse {
    case valid(ResolutionInfo)
    case noSignalInput
    case unknownSignal

    private static let noSignalInputToken = "-"
    private static let unknownSignalToken = "*"
}

extension ResolutionResponse: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.toString())
    }

}

extension ResolutionResponse: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(fromString: string)
    }

}

extension ResolutionResponse: Serializable {

    public func toString() -> String {
        switch self {
        case .noSignalInput:
            return ResolutionResponse.noSignalInputToken
        case .unknownSignal:
            return ResolutionResponse.unknownSignalToken
        case .valid(let info):
            return info.toString()
        }
    }

}

extension ResolutionResponse: Deserializable {

    public init(fromString string: String) throws {
        switch string {
        case ResolutionResponse.noSignalInputToken:
            self = .noSignalInput
        case ResolutionResponse.unknownSignalToken:
            self = .unknownSignal
        default:
            let info = try ResolutionInfo(fromString: string)
            self = .valid(info)
        }
    }

}
