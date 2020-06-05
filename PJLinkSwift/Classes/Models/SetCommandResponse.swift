//
//  SetCommandResponse.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/18/20.
//

import Foundation

public struct SetCommandResponse {
    public var response: Response
    public var code: SetResponseCode
    
    public init(withResponse response: Response) throws {
        self.response = response
        guard let responseCode = SetResponseCode(rawValue: response.data) else {
            throw DeserializationError.invalidSetResponseCode(response.data)
        }
        code = responseCode
    }
}

extension SetCommandResponse: SetCommandResponseProtocol {}

extension SetCommandResponse: Serializable {

    public func toString() -> String {
        return response.toString()
    }

}

extension SetCommandResponse: Deserializable {

    public init(fromString string: String) throws {
        let resp = try Response(fromString: string)
        try self.init(withResponse: resp)
    }

}
