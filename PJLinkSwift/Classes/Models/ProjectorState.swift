//
//  ProjectorState.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/15/20.
//

import Foundation

public struct InputInfo: Codable {
    public var number: String
    public var name: String?
}

public struct ProjectorState: Codable {
    public var power: PowerState
    public var currentInputNumber: String
    public var audioMuted: Bool
    public var videoMuted: Bool
    public var errorStatus: ErrorData
    public var lampsStatus: [LampStatus]
    public var inputs: [InputInfo]
    public var projectorName: String?
    public var manufacturerName: String?
    public var productName: String?
    public var modelInformation: String?
    public var highestSupportedClass: CommandClass
    public var serialNumber: String?
    public var softwareVersion: String?
    public var inputResolution: ResolutionResponse?
    public var recommendedResolution: ResolutionInfo?
    public var filterUsageTime: Int?
    public var lampReplacementModelNumbers: [String]?
    public var filterReplacementModelNumbers: [String]?
    public var speakerVolume: Int?
    public var microphoneVolume: Int?
    public var screenFrozen: Bool?
    public var password: String?
    
    public var avMute: MuteStatus {
        return MuteStatus(audioMuted: audioMuted, videoMuted: videoMuted)
    }
    
    public mutating func setAVMute(_ muteStatus: MuteStatus) {
        audioMuted = muteStatus.audioMuted
        videoMuted = muteStatus.videoMuted
    }
    
    public mutating func response(toCommand command: Command) -> Response {
        if command.isGet {
            return response(forGetCommand: command)
        } else {
            return response(forSetCommand: command)
        }
    }
    
    public func response(forGetCommand command: Command) -> Response {
        // Make sure this command code supports a get and
        // that this projector can handle this class of command.
        guard command.code.hasGet,
              command.cmdClass <= highestSupportedClass else {
            let data = GetErrorCode.undefinedCommand.rawValue
            return Response(cmdClass: command.cmdClass, code: command.code, data: data)
        }
        
        switch command.code {
        case .avMute:
            return Response(cmdClass: .one, code: command.code, data: avMute.toString())
        case .classInfo:
            return Response(cmdClass: .one, code: command.code, data: highestSupportedClass.toString())
        case .deviceName:
            return Response(cmdClass: .one, code: command.code, data: projectorName ?? "")
        case .errorStatus:
            return Response(cmdClass: .one, code: command.code, data: errorStatus.toString())
        case .filterReplacementModelNumber:
            let data = filterReplacementModelNumbers?.joined(separator: " ") ?? ""
            return Response(cmdClass: .two, code: command.code, data: data)
        case .filterUsageTime:
            let usage = filterUsageTime ?? 0
            return Response(cmdClass: .two, code: command.code, data: "\(usage)")
        case .freeze:
            let data = FreezeState(frozen: screenFrozen ?? false).toString()
            return Response(cmdClass: .two, code: command.code, data: data)
        case .input:
            return Response(cmdClass: command.cmdClass, code: command.code, data: currentInputNumber)
        case .inputList:
            let data = inputs.map({ $0.number }).joined(separator: " ")
            return Response(cmdClass: command.cmdClass, code: command.code, data: data)
        case .inputResolution:
            let data = inputResolution?.toString() ?? ""
            return Response(cmdClass: .two, code: command.code, data: data)
        case .inputTerminalName:
            let data = inputs.first(where: { $0.number == command.parameters })?.name ?? ""
            return Response(cmdClass: .two, code: command.code, data: data)
        case .lamp:
            let data = LampsStatus(lampsStatus: lampsStatus).toString()
            return Response(cmdClass: .one, code: command.code, data: data)
        case .lampReplacementModelNumber:
            let data = lampReplacementModelNumbers?.joined(separator: " ") ?? ""
            return Response(cmdClass: .two, code: command.code, data: data)
        case .manufacturerName:
            return Response(cmdClass: .one, code: command.code, data: manufacturerName ?? "")
        case .otherInfo:
            return Response(cmdClass: .one, code: command.code, data: modelInformation ?? "")
        case .power:
            return Response(cmdClass: .one, code: command.code, data: power.toString())
        case .productName:
            return Response(cmdClass: .one, code: command.code, data: productName ?? "")
        case .recommendedResolution:
            let data = recommendedResolution?.toString() ?? ""
            return Response(cmdClass: .one, code: command.code, data: data)
        case .serialNumber:
            return Response(cmdClass: .two, code: command.code, data: serialNumber ?? "")
        case .softwareVersion:
            return Response(cmdClass: .two, code: command.code, data: softwareVersion ?? "")
        default:
            let data = GetErrorCode.undefinedCommand.rawValue
            return Response(cmdClass: command.cmdClass, code: command.code, data: data)
        }
    }
    
    public mutating func response(forSetCommand command: Command) -> Response {
        // Make sure this command code supports a get and
        // that this projector can handle this class of command.
        guard command.code.hasSet,
              command.cmdClass <= highestSupportedClass else {
            return Response(cmdClass: command.cmdClass, code: command.code, setResponseCode: .undefinedCommand)
        }
        
        switch command.code {
        case .power:
            // The POWR set command just turns power on and off.
            // Presumably the power goes through some sort of warm-up and cool-down.
            // We don't currently handle that yet.
            var responseCode = SetResponseCode.badParameter
            if let state = try? PowerState(fromString: command.parameters) {
                power = state
                responseCode = .success
            }
            return Response(cmdClass: .one, code: command.code, setResponseCode: responseCode)
        case .input:
            // Check if this input number is valid
            var responseCode = SetResponseCode.badParameter
            if let info = inputs.first(where: { $0.number == command.parameters }) {
                currentInputNumber = info.number
                responseCode = .success
            }
            return Response(cmdClass: .one, code: command.code, setResponseCode: responseCode)
        case .avMute:
            var responseCode = SetResponseCode.badParameter
            if let muteStatus = try? MuteStatus(fromString: command.parameters) {
                audioMuted = muteStatus.audioMuted
                videoMuted = muteStatus.videoMuted
                responseCode = .success
            }
            return Response(cmdClass: .one, code: command.code, setResponseCode: responseCode)
        case .speakerVolumeAdjustment:
            // TODO: handle min and max volume
            var responseCode = SetResponseCode.badParameter
            if let volumeAdjustment = VolumeAdjustment(rawValue: command.parameters) {
                let currentVolume = speakerVolume ?? 5
                speakerVolume = volumeAdjustment.apply(to: currentVolume)
                responseCode = .success
            }
            return Response(cmdClass: .one, code: command.code, setResponseCode: responseCode)
        case .microphoneVolumeAdjustment:
            // TODO: handle min and max volume
            var responseCode = SetResponseCode.badParameter
            if let volumeAdjustment = VolumeAdjustment(rawValue: command.parameters) {
                let currentVolume = microphoneVolume ?? 5
                microphoneVolume = volumeAdjustment.apply(to: currentVolume)
                responseCode = .success
            }
            return Response(cmdClass: .one, code: command.code, setResponseCode: responseCode)
        case .freeze:
            var responseCode = SetResponseCode.badParameter
            if let freezeStatus = try? FreezeState(fromString: command.parameters) {
                screenFrozen = freezeStatus.frozen
                responseCode = .success
            }
            return Response(cmdClass: .one, code: command.code, setResponseCode: responseCode)
        default:
            return Response(cmdClass: command.cmdClass, code: command.code, setResponseCode: .undefinedCommand)
        }
    }
}
