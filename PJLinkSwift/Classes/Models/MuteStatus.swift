//
//  MuteStatus.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/20/20.
//

import Foundation

public struct MuteStatus {
    public var channels: AudioVideo
    public var mute: MuteState
}

extension MuteStatus: Serializable {

    public func toString() -> String {
        return channels.rawValue + mute.rawValue
    }

}

public enum MuteStatusDeserializationError: Error {
    case notEnoughData
    case invalidChannelValue(Character)
    case invalidMuteState(Character)
}

extension MuteStatus: Deserializable {

    public init(fromString string: String) throws {
        guard string.count >= 2 else {
            throw MuteStatusDeserializationError.notEnoughData
        }
        let chars = Array(string)
        guard let channels = AudioVideo(rawValue: String(chars[0])) else {
            throw MuteStatusDeserializationError.invalidChannelValue(chars[0])
        }
        guard let mute = MuteState(rawValue: String(chars[1])) else {
            throw MuteStatusDeserializationError.invalidMuteState(chars[1])
        }
        self.channels = channels
        self.mute = mute
    }

}
