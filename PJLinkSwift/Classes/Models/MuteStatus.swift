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
    
    public var audioMuted: Bool {
        return mute == .on && (channels == .audio || channels == .audioAndVideo)
    }
    
    public var videoMuted: Bool {
        return mute == .on && (channels == .video || channels == .audioAndVideo)
    }
    
    public init(audioMuted: Bool, videoMuted: Bool) {
        switch (audioMuted, videoMuted) {
        case (false, false):
            channels = .audioAndVideo
            mute = .off
        case (false, true):
            channels = .video
            mute = .on
        case (true, false):
            channels = .audio
            mute = .on
        case (true, true):
            channels = .audioAndVideo
            mute = .on
        }
    }
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
