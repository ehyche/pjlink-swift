//
//  PJLinkServer.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/11/20.
//

import Foundation

public class PJLinkServer {

    // MARK: - Public properties
    
    // MARK: - Private properties
    
    private var state: ProjectorState
    private let tcpServer: TCPServer
    private var sessions = [Int:Session]()

    // MARK: - Initializers
    
    public init(state: ProjectorState) throws {
        self.state = state
        self.tcpServer = try TCPServer()
    }
    
    // MARK: - Public methods
    
    public func start(on queue: DispatchQueue) {
        tcpServer.onNewConnection = { [weak self] connId in
            self?.handleNewConnection(connectionId: connId)
        }
        tcpServer.onData = { [weak self] (data, connId) in
            self?.handleData(data: data, connectionId: connId)
        }
        tcpServer.onConnectionEnd = { [weak self] connId in
            self?.handleConnectionEnd(connectionId: connId)
        }
        tcpServer.start(on: queue)
    }
    
    public func stop() {
        tcpServer.onNewConnection = nil
        tcpServer.onData = nil
        tcpServer.onConnectionEnd = nil
        tcpServer.stop()
    }

    // MARK: - Private methods

    private func handleNewConnection(connectionId: Int) {
        print("PJLinkServer.handleNewConnection(\(connectionId))")
        let session = Session(connectionId: connectionId)
        sessions[connectionId] = session

        sendResponse(toRequestData: nil, onConnectionId: connectionId)
    }

    private func handleData(data: Data, connectionId: Int) {
        print("PJLinkServer.handleData(\(data),connectionId:\(connectionId))")
        sendResponse(toRequestData: data, onConnectionId: connectionId)
    }

    private func handleConnectionEnd(connectionId: Int) {
        print("PJLinkServer.handleConnectionEnd(connectionId:\(connectionId))")
        sessions.removeValue(forKey: connectionId)
    }

    private func handleError(_ error: Error) {
        print("PJLinkServer.handleError(\(error))")
    }

    private func sendResponse(toRequestData data: Data?, onConnectionId connectionId: Int) {
        guard var session = sessions[connectionId] else {
            return
        }

        do {
            let responseInfo = try session.response(forRequestData: data, projectorState: state)
            sessions[connectionId] = session
            state = responseInfo.updatedState
            tcpServer.send(responseInfo.responseData, onConnectionWithId: connectionId)
        } catch {
            handleError(error)
        }
    }

}
