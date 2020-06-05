//
//  ResponseInfo.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/4/20.
//

import Foundation

public enum SetOrGetResponse {
    case set(SetCommandResponse)
    case get(GetCommandResponse)
}

public struct ResponseInfo {
    public var command: Command
    public var response: SetOrGetResponse

    public init(command: Command, response: Response) throws {
        self.command = command
        self.response = command.isGet ?
                        .get(try GetCommandResponse(withResponse: response)) :
                        .set(try SetCommandResponse(withResponse: response))
    }

}
