//
//  Protocols.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/18/20.
//

import Foundation

public protocol ResponseProtocol {

    var response: Response { get }

}

public protocol SetCommandResponseProtocol: ResponseProtocol {

    var code: SetResponseCode { get }

}

public protocol GetCommandResponseProtocol: ResponseProtocol {

    var result: Swift.Result<GetResponseData,GetErrorCode> { get }

}

