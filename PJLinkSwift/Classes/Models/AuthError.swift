//
//  AuthError.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/14/20.
//

import Foundation

public struct AuthError {

    private static let pjlink = "PJLINK"
    private static let space: Character = " "
    private static let error: String = "ERRA"
    private static let terminator: Character = "\n"
}

extension AuthError: Serializable {

    public func toString() -> String {
        return AuthError.pjlink + String(AuthError.space) + AuthError.error + String(AuthError.terminator)
    }

}
