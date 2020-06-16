//
//  Session.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/11/20.
//
import Foundation

public struct Session {
    public enum SessionState {
        case connected
        case awaitingCommand
    }
    
    public enum SessionError: Error {
        case missingInputData
    }
    
    public typealias ResponseInfo = (responseData: Data, updatedState: ProjectorState)

    public static var nextSessionId = 0

    public var sessionId: Int
    public var connectionId: Int
    public var random: String
    public var hashedPassword: String = ""
    public var state: SessionState

    public init(connectionId: Int) {
        sessionId = Session.nextId()
        self.connectionId = connectionId
        random = AuthHelper.randomString()
        state = .connected
    }

    public mutating func response(forRequestData requestData: Data?, projectorState: ProjectorState) throws -> ResponseInfo {
        switch state {
        case .connected:
            let authenticated = projectorState.password != nil
            if authenticated {
                hashedPassword = try AuthHelper.hash(fromPassword: projectorState.password!, randomString: random)
            }
            let response = ConnectionResponse(authenticated: authenticated, randomHexString: authenticated ? random : nil)
            let responseData = try response.toData()
            state = .awaitingCommand
            return (responseData: responseData, updatedState: projectorState)
        case .awaitingCommand:
            guard let data = requestData else {
                throw SessionError.missingInputData
            }
            let request = try data.parseAsPJLinkRequest()
            // Try authentication
            if try authenticate(withAuth: request.auth, password: projectorState.password) {
                var responses = [Response]()
                var mutableState = projectorState
                for command in request.commands {
                    let response = mutableState.response(toCommand: command)
                    responses.append(response)
                }
                let responseData = try responses.map({ $0.toString() }).joined().asUTF8Data()
                return (responseData: responseData, updatedState: mutableState)
            } else {
                // Authentication failure - return auth error
                let authErrorData = try AuthError().toString().asUTF8Data()
                return (responseData: authErrorData, updatedState: projectorState)
            }
        }
    }

    private static func nextId() -> Int {
        let id = Session.nextSessionId
        Session.nextSessionId += 1
        return id
    }
    
    private func authenticate(withAuth auth: String, password: String?) throws -> Bool {
        // If we don't have a password in our projector,
        // then we automatically pass authentication.
        guard password != nil else {
            return true
        }
        return auth == hashedPassword
    }
}
