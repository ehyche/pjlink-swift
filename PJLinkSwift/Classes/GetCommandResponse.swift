//
//  GetCommandResponse.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/18/20.
//

import Foundation

public enum GetResponseData {
    case power(PowerState)
    case input(String)
    case avMute(MuteStatus)
    case errorStatus(ErrorData)
    case lamp(LampsStatus)
    case inputList([String])
    case deviceName(String)
    case manufacturerName(String)
    case productName(String)
    case otherInfo(String)
    case classInfo(CommandClass)
    case serialNumber(String)
    case softwareVersion(String)
    case inputTerminalName(String)
    case inputResolution(ResolutionResponse)
    case recommendedResolution(ResolutionInfo)
    case filterUsageTime(Int)
    case lampReplacementModelNumber([String])
    case filterReplacementModelNumber([String])
    case freeze(FreezeState)
    
    public init(withCommandCode commandCode: CommandCode, string: String) throws {
        switch commandCode {
        case .power:
            let powerState = try PowerState(fromString: string)
            self = .power(powerState)
        case .input:
            self = .input(string)
        case .avMute:
            let muteStatus = try MuteStatus(fromString: string)
            self = .avMute(muteStatus)
        case .errorStatus:
            let errorData = try ErrorData(fromString: string)
            self = .errorStatus(errorData)
        case .lamp:
            let lampsStatus = try LampsStatus(fromString: string)
            self = .lamp(lampsStatus)
        case .inputList:
            let list = string.split(separator: Response.arraySeparator).map({ String($0) })
            self = .inputList(list)
        case .deviceName:
            self = .deviceName(string)
        case .manufacturerName:
            self = .manufacturerName(string)
        case .productName:
            self = .productName(string)
        case .otherInfo:
            self = .otherInfo(string)
        case .classInfo:
            let cls = try CommandClass(fromString: string)
            self = .classInfo(cls)
        case .serialNumber:
            self = .serialNumber(string)
        case .softwareVersion:
            self = .softwareVersion(string)
        case .inputTerminalName:
            self = .inputTerminalName(string)
        case .inputResolution:
            let resolutionResponse = try ResolutionResponse(fromString: string)
            self = .inputResolution(resolutionResponse)
        case .recommendedResolution:
            let resolution = try ResolutionInfo(fromString: string)
            self = .recommendedResolution(resolution)
        case .filterUsageTime:
            let usage = try Int(fromString: string)
            self = .filterUsageTime(usage)
        case .lampReplacementModelNumber:
            let list = string.split(separator: Response.arraySeparator).map({ String($0) })
            self = .lampReplacementModelNumber(list)
        case .filterReplacementModelNumber:
            let list = string.split(separator: Response.arraySeparator).map({ String($0) })
            self = .filterReplacementModelNumber(list)
        case .freeze:
            let state = try FreezeState(fromString: string)
            self = .freeze(state)
        default:
            throw DeserializationError.invalidGetCommandResponse(commandCode)
        }
    }
}

public struct GetCommandResponse {
    public var response: Response
    public var result: Swift.Result<GetResponseData,GetErrorCode>
    
    public init(withResponse response: Response) throws {
        self.response = response
        if let errorCode = GetErrorCode(rawValue: response.data) {
            result = .failure(errorCode)
        } else {
            let getResponseData = try GetResponseData(withCommandCode: response.code, string: response.data)
            result = .success(getResponseData)
        }
    }
}

extension GetCommandResponse: GetCommandResponseProtocol {}

extension GetCommandResponse: Serializable {

    public func toString() -> String {
        return response.toString()
    }

}

extension GetCommandResponse: Deserializable {

    public init(fromString string: String) throws {
        let resp = try Response(fromString: string)
        try self.init(withResponse: resp)
    }

}
