//
//  TCPServer.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/11/20.
//

import Foundation
import Network

public class TCPServer {

    // MARK: - Public typealiases

    public typealias OnConnectionClosure = (Int) -> Void
    public typealias OnDataClosure = (Data, Int) -> Void

    // MARK: - Public enums

    public enum TCPServerError: Error {
        case invalidPort(UInt16)
        case listenerCreationFailure(Error)
    }

    // MARK: - Public properties

    public var onNewConnection: OnConnectionClosure?
    public var onConnectionEnd: OnConnectionClosure?
    public var onData: OnDataClosure?
    public static let defaultPort: UInt16 = 4352

    // MARK: - Private properties

    private let listener: NWListener
    private var connectionId = 0
    private var connectionMap = [Int:TCPServerConnection]()

    // MARK: - Initializers

    public init(port: UInt16 = TCPServer.defaultPort) throws {
        print("TCPServer(port: \(port))")
        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            throw TCPServerError.invalidPort(port)
        }
        let params = NWParameters.tcp
        do {
            listener = try NWListener(using: params, on: nwPort)
        } catch {
            throw TCPServerError.listenerCreationFailure(error)
        }
    }

    // MARK: - Public methods

    public func start(on queue: DispatchQueue) {
        print("TCPServer.start(on: \(queue))")
        listener.stateUpdateHandler = { [weak self] state in
            self?.stateWasUpdated(state)
        }
        listener.newConnectionHandler = { [weak self] connection in
            self?.handleNewConnection(connection)
        }
        listener.start(queue: queue)
    }

    public func stop() {
        print("TCPServer.stop()")
        stop(withError: nil)
    }
    
    public func send(_ data: Data, onConnectionWithId connectionId: Int) {
        let str = String(data: data, encoding: .utf8)!
        print("TCPServer.send(,onConnectionWithId: \(connectionId)) data=\"\(str)\"")
        if let conn = connectionMap[connectionId] {
            conn.send(data)
        }
    }

    // MARK: - Private methods

    private func stateWasUpdated(_ state: NWListener.State) {
        print("TCPServer.stateWasUpdated(\(state))")
        switch state {
        case .failed(let error):
            stop(withError: error)
        default:
            break
        }
    }

    private func handleNewConnection(_ connection: NWConnection) {
        print("TCPServer.handleNewConnection(\(connection))")
        guard let queue = listener.queue else {
            return
        }
        
        let tcpConnection = TCPServerConnection(nwConnection: connection, connectionId: connectionId)
        tcpConnection.onData = { [weak self] (conn, data) in
            self?.handleConnectionData(conn, data: data)
        }
        tcpConnection.onEnd = { [weak self] (conn, error) in
            self?.handleConnectionEnd(conn, error: error)
        }
        connectionMap[connectionId] = tcpConnection
        connectionId += 1

        tcpConnection.start(on: queue)
        
        onNewConnection?(tcpConnection.connectionId)
    }

    private func handleConnectionData(_ conn: TCPServerConnection, data: Data) {
        print("TCPServer.handleConnectionData(\(conn),\(data))")
        onData?(data, conn.connectionId)
    }

    private func handleConnectionEnd(_ conn: TCPServerConnection, error: Error?) {
        print("TCPServer.handleConnectionData(\(conn),\(String(describing: error)))")
        connectionMap.removeValue(forKey: conn.connectionId)
        onConnectionEnd?(conn.connectionId)
    }

    private func stop(withError error: Error?) {
        print("TCPServer.stop(\(String(describing: error)))")
        listener.stateUpdateHandler = nil
        listener.newConnectionHandler = nil
        listener.cancel()
        for udpConnection in connectionMap.values {
            udpConnection.onEnd = nil
            udpConnection.stop()
        }
        connectionMap.removeAll()
    }
}

