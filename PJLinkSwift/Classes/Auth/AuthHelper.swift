//
//  AuthHelper.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/4/20.
//

import Foundation

public struct AuthHelper {

    public enum AuthHelperError: Error {
        case utf8EncodingError(String)
        case incorrectHashLength(Int)
    }

    public static func randomString() -> String {
        return String(format: "%8x", randomInt32())
    }

    public static func hash(fromPassword password: String, randomString: String) throws -> String {
        let preHashString = randomString + password
        guard let preHashData = preHashString.data(using: .utf8) else {
            throw AuthHelperError.utf8EncodingError(preHashString)
        }
        let hashedString = preHashData.md5.asHexString
        guard hashedString.count == 32 else {
            throw AuthHelperError.incorrectHashLength(hashedString.count)
        }
        return hashedString
    }

    private static func randomInt32() -> Int32 {
        return Int32.random(in: Int32.min...Int32.max)
    }
}
