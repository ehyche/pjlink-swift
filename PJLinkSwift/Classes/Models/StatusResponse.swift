//
//  StatusResponse.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/18/20.
//

import Foundation

public enum StatusResponseData {
    case acknowledged(String)
    case linkupStatus(String)
    case errorStatus(ErrorData)
    case power(PowerState)
    case input(String)

    public init(withCommandCode commandCode: CommandCode, string: String) throws {
        switch commandCode {
        case .acknowledged:
            self = .acknowledged(string)
        case .linkupStatus:
            self = .linkupStatus(string)
        case .errorStatus:
            let errorData = try ErrorData(fromString: string)
            self = .errorStatus(errorData)
        case .power:
            let powerState = try PowerState(fromString: string)
            self = .power(powerState)
        case .input:
            self = .input(string)
        default:
            throw DeserializationError.invalidStatusResponse(commandCode)
        }
    }
}

public struct StatusResponse {
    public var response: Response
    public var status: StatusResponseData
    
    public init(withResponse response: Response) throws {
        self.response = response
        status = try StatusResponseData(withCommandCode: response.code, string: response.data)
    }
}

extension StatusResponse: Serializable {

    public func toString() -> String {
        return response.toString()
    }

}

extension StatusResponse: Deserializable {

    public init(fromString string: String) throws {
        let resp = try Response(fromString: string)
        try self.init(withResponse: resp)
    }

}
