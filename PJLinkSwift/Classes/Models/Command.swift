//
//  Command.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 4/24/20.
//

import Foundation

public struct Command {
    
    // MARK: - Public properties

    public private(set) var cmdClass: CommandClass
    public private(set) var code: CommandCode
    public private(set) var parameters: String

    // MARK: - Internal static constants
    static let header: Character = "%"
    static let terminator: Character = "\n"

    // MARK: - Private static constants

    private static let space: Character = " "
    private static let query: Character = "?"
    private static let maxDataLength = 128
    
    // MARK: - Get Commands

    public static let getPower                        = GetCommand(code: .power)
    public static let getInputClass1                  = GetCommand(cmdClass: .one, code: .input)
    public static let getInputClass2                  = GetCommand(cmdClass: .two, code: .input)
    public static let getMute                         = GetCommand(code: .avMute)
    public static let getErrorStatus                  = GetCommand(code: .errorStatus)
    public static let getLampStatus                   = GetCommand(code: .lamp)
    public static let getInputListClass1              = GetCommand(cmdClass: .one, code: .inputList)
    public static let getInputListClass2              = GetCommand(cmdClass: .two, code: .inputList)
    public static let getDeviceName                   = GetCommand(code: .deviceName)
    public static let getManufacturerName             = GetCommand(code: .manufacturerName)
    public static let getProductName                  = GetCommand(code: .productName)
    public static let getOtherInfo                    = GetCommand(code: .otherInfo)
    public static let getClassInfo                    = GetCommand(code: .classInfo)
    public static let getSerialNumber                 = GetCommand(cmdClass: .two, code: .serialNumber)
    public static let getSoftwareVersion              = GetCommand(cmdClass: .two, code: .softwareVersion)
    public static let getInputResolution              = GetCommand(cmdClass: .two, code: .inputResolution)
    public static let getRecommendedResolution        = GetCommand(cmdClass: .two, code: .recommendedResolution)
    public static let getFilterUsageTime              = GetCommand(cmdClass: .two, code: .filterUsageTime)
    public static let getLampReplacementModelNumber   = GetCommand(cmdClass: .two, code: .lampReplacementModelNumber)
    public static let getFilterReplacementModelNumber = GetCommand(cmdClass: .two, code: .filterReplacementModelNumber)
    public static let getScreenFreezeState            = GetCommand(cmdClass: .two, code: .freeze)

    public static func getInputTerminalName(forInputSource inputSource: String) -> Command {
        return Command(cmdClass: .two, code: .inputTerminalName, parameters: String(query) + inputSource)
    }
    
    // MARK: - Set Commands
    
    public static func setPower(toState state: PowerState) -> Command {
        return SetCommand(code: .power, parameters: state.rawValue)
    }

    public static func setInput(toInputType inputType: InputType, inputChannel channel: String? = nil) -> Command {
        if let channel = channel {
            return SetCommand(cmdClass: .two, code: .input, parameters: inputType.rawValue + channel)
        } else {
            return SetCommand(cmdClass: .one, code: .input, parameters: inputType.rawValue)
        }
    }
    
    public static func setMute(forAudioVideo audioVideo: AudioVideo, toState state: MuteState) -> Command {
        return SetCommand(code: .avMute, parameters: audioVideo.rawValue + state.rawValue)
    }
    
    public static func setSpeakerVolumeAdjustment(_ adjustment: VolumeAdjustment) -> Command {
        return SetCommand(cmdClass: .two, code: .speakerVolumeAdjustment, parameters: adjustment.rawValue)
    }
    
    public static func setMicrophoneVolumeAdjustment(_ adjustment: VolumeAdjustment) -> Command {
        return SetCommand(cmdClass: .two, code: .microphoneVolumeAdjustment, parameters: adjustment.rawValue)
    }
    
    public static func setScreenFreeze(_ state: FreezeState) -> Command {
        return SetCommand(cmdClass: .two, code: .freeze, parameters: state.rawValue)
    }
    
    public var isGet: Bool {
        return parameters == String(Command.query)
    }
    
    // MARK: - Private methods
    
    private static func GetCommand(cmdClass: CommandClass = .one, code: CommandCode) -> Command {
        return Command(cmdClass: cmdClass, code: code, parameters: String(query))
    }
    
    private static func SetCommand(cmdClass: CommandClass = .one, code: CommandCode, parameters: String) -> Command {
        return Command(cmdClass: cmdClass, code: code, parameters: parameters)
    }

}

extension Command: Serializable {

    public func toString() -> String {
        return String(Command.header) + cmdClass.rawValue + code.rawValue + String(Command.space) + parameters + String(Command.terminator)
    }

}

extension Command: Deserializable {

    public init(fromString string: String) throws {
        let chars = Array(string)
        guard chars.count >= 9 else {
            throw DeserializationError.notEnoughData
        }

        guard chars[0] == Command.header else {
            throw DeserializationError.unexpectedHeader(chars[0])
        }
        
        guard let classEnum = CommandClass(rawValue: String(chars[1])) else {
            throw DeserializationError.unexpectedClass(chars[1])
        }
        cmdClass = classEnum
        
        let commandStr = String(chars[2...5])
        guard let commandEnum = CommandCode(caseInsensitiveRawValue: commandStr) else {
            throw DeserializationError.unrecognizedCommandCode(commandStr)
        }
        code = commandEnum

        guard chars[6] == Command.space else {
            throw DeserializationError.unexpectedSeparator(chars[6])
        }
        
        // Scan forward until we hit the terminator.
        // Put everything in between the separator and the terminator into the data string.
        let dataStartIndex = 7
        var i = dataStartIndex
        while i < chars.count && chars[i] != Command.terminator {
            i += 1
        }
        
        // Make sure that we ended on a terminator
        guard i < chars.count && chars[i] == Command.terminator else {
            throw DeserializationError.notTerminated
        }
        
        // Make sure we have at least one data byte
        let dataEndIndex = i - 1
        let dataLength = dataEndIndex - dataStartIndex + 1
        guard dataLength >= 0 && dataLength <= Command.maxDataLength else {
            throw DeserializationError.tooMuchParameterData(dataLength)
        }
        parameters = String(chars[dataStartIndex...dataEndIndex])
    }
    
}
