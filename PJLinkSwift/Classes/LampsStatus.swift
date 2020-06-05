//
//  LampsStatus.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/4/20.
//

import Foundation

public struct LampsStatus {
    public var lampsStatus: [LampStatus]
}

extension LampsStatus: Serializable {

    public func toString() -> String {
        lampsStatus.map({ $0.toString() }).joined(separator: String(Response.arraySeparator))
    }

}

extension LampsStatus: Deserializable {

    public init(fromString string: String) throws {
        // Each LampStatus has a usage and a lamp state that is separated by a space.
        // In addition, each one of the LampStatus for each lamp is separated by a space.
        // For example, if there were three lamps in the projector, then the response would
        // look like:
        //
        // <Lamp0Usage> + " " + <Lamp0State> + " " +
        // <Lamp1Usage> + " " + <Lamp1State> + " " +
        // <Lamp2Usage> + " " + <Lamp2State>
        // So if there are N lamps, then there should be N "internal" spaces
        // plus N-1 space separators between the LampStatus of each lamp.
        let splits = string.split(separator: Response.arraySeparator, omittingEmptySubsequences: true)
        var statuses = [LampStatus]()
        for i in stride(from: 0, to: splits.count, by: 2) {
            guard i + 1 < splits.count else {
                break
            }
            let statusString = String(splits[i]) + String(LampStatus.separator) + String(splits[i + 1])
            let status = try LampStatus(fromString: statusString)
            statuses.append(status)
        }
        lampsStatus = statuses
    }

}
