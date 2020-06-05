//
//  ProjectorState.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/15/20.
//

import Foundation

public struct InputInfo {
    public var number: String
    public var name: String?
}

public struct ProjectorState {
    var power: PowerState
    var fanError: ErrorState
    var lampError: ErrorState
    var temperatureError: ErrorState
    var coverOpenError: ErrorState
    var filterError: ErrorState
    var otherError: ErrorState
    var audioMuted: Bool
    var videoMuted: Bool
    var lampsStatus: [LampStatus]
    var inputs: [InputInfo]
    var projectorName: String?
    var manufacturerName: String?
    var productName: String?
    var modelInformation: String?
    var highestSupportedClass: CommandClass
    var serialNumber: String?
    var softwareVersion: String?
    var inputResolution: ResolutionInfo?
    var recommendedResolution: ResolutionInfo?
    var filterUsageTime: Int?
    var lampReplacementModelNumbers: [String]?
    var filterReplacementModelNumbers: [String]?
    var screenFrozen: Bool?
}
