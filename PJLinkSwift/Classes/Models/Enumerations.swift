//
//  Enumerations.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 4/24/20.
//

import Foundation

public enum CommandClass: String {
    case one = "1"
    case two = "2"
}

extension CommandClass: Serializable {

    public func toString() -> String {
        return rawValue
    }

}

extension CommandClass: Deserializable {

    public init(fromString string: String) throws {
        guard let cls = CommandClass(rawValue: string) else {
            throw DeserializationError.unrecognizedCommandCode(string)
        }
        self = cls
    }

}

public enum SetResponseCode: String {
    case success            = "OK"
    case undefinedCommand   = "ERR1"
    case badParameter       = "ERR2"
    case commandUnavailable = "ERR3"
    case deviceFailure      = "ERR4"
}

public enum GetErrorCode: String, Error {
    case undefinedCommand   = "ERR1"
    case badParameter       = "ERR2"
    case commandUnavailable = "ERR3"
    case deviceFailure      = "ERR4"
}

public enum CommandCode: String {
    case search = "SRCH"
    case acknowledged = "ACKN"
    case linkupStatus = "LKUP"
    case errorStatus = "ERST"
    case power = "POWR"
    case input = "INPT"
    case avMute = "AVMT"
    case lamp = "LAMP"
    case inputList = "INST"
    case deviceName = "NAME"
    case manufacturerName = "INF1"
    case productName = "INF2"
    case otherInfo = "INFO"
    case classInfo = "CLSS"
    case serialNumber = "SNUM"
    case softwareVersion = "SVER"
    case inputTerminalName = "INNM"
    case inputResolution = "IRES"
    case recommendedResolution = "RRES"
    case filterUsageTime = "FILT"
    case lampReplacementModelNumber = "RLMP"
    case filterReplacementModelNumber = "RFIL"
    case speakerVolumeAdjustment = "SVOL"
    case microphoneVolumeAdjustment = "MVOL"
    case freeze = "FREZ"
    
    init?(caseInsensitiveRawValue: String) {
        self.init(rawValue: caseInsensitiveRawValue.uppercased())
    }
}

public enum InputType: String {
    case rgb        = "1"
    case video      = "2"
    case digital    = "3"
    case storage    = "4"
    case network    = "5"
    case `internal` = "6"
}

public enum AudioVideo: String {
    case video = "1"
    case audio = "2"
    case audioAndVideo = "3"
}

public enum MuteState: String {
    case off = "0"
    case on  = "1"
}

public enum VolumeAdjustment: String {
    case increase = "1"
    case decrease = "0"
}

public enum FreezeState: String {
    case freeze = "1"
    case unfreeze = "0"
}

extension FreezeState: Serializable {

    public func toString() -> String {
        return rawValue
    }

}

extension FreezeState: Deserializable {

    public init(fromString string: String) throws {
        guard let state = FreezeState(rawValue: string) else {
            throw DeserializationError.invalidFreezeState(string)
        }
        self = state
    }

}

public enum ErrorState: String {
    case noError = "0"
    case warning = "1"
    case error = "2"
}

public enum LampState: String {
    case off = "0"
    case on = "1"
}
