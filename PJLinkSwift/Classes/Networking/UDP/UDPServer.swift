//
//  UDPServer.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/9/20.
//
import Foundation
import Network

public class UDPServer {
    
    // MARK: - Public typealiases
    
    public typealias OnDataClosure = (NWEndpoint, Data) -> Void
    
    // MARK: - Public enums
    
    public enum UDPServerError: Error {
        case invalidPort(UInt16)
        case listenerCreationFailure(Error)
    }
    
    // MARK: - Public properties
    
    public var onData: OnDataClosure?
    
    // MARK: - Private properties
    
    private let listener: NWListener
    private var connectionId = 0
    private var connectionMap = [Int:UDPServerConnection]()
    
    // MARK: - Initializers
    
    public init(port: UInt16) throws {
        print("UDPServer(port: \(port))")
        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            throw UDPServerError.invalidPort(port)
        }
        let params = NWParameters.udp
        do {
            listener = try NWListener(using: params, on: nwPort)
        } catch {
            throw UDPServerError.listenerCreationFailure(error)
        }
    }
    
    // MARK: - Public methods
    
    public func start(on queue: DispatchQueue) {
        print("UDPServer.start(on: \(queue))")
        listener.stateUpdateHandler = { [weak self] state in
            self?.stateWasUpdated(state)
        }
        listener.newConnectionHandler = { [weak self] connection in
            self?.handleNewConnection(connection)
        }
        listener.start(queue: queue)
    }
    
    public func stop() {
        print("UDPServer.stop()")
        stop(withError: nil)
    }
    
    // MARK: - Private methods
    
    private func stateWasUpdated(_ state: NWListener.State) {
        print("UDPServer.stateWasUpdated(\(state))")
        switch state {
        case .failed(let error):
            stop(withError: error)
        case .waiting(let error):
            stop(withError: error)
        default:
            break
        }
    }
    
    private func handleNewConnection(_ connection: NWConnection) {
        print("UDPServer.handleNewConnection(\(connection))")
        let udpConnection = UDPServerConnection(nwConnection: connection, connectionId: connectionId)
        udpConnection.onData = { [weak self] (conn, data) in
            self?.handleConnectionData(conn, data: data)
        }
        udpConnection.onEnd = { [weak self] (conn, error) in
            self?.handleConnectionEnd(conn, error: error)
        }
        connectionId += 1
        connectionMap[connectionId] = udpConnection
        
        // Start the connection
        if let queue = listener.queue {
            udpConnection.start(on: queue)
        }
    }
    
    private func handleConnectionData(_ conn: UDPServerConnection, data: Data) {
        print("UDPServer.handleConnectionData(\(conn),\(data))")
        onData?(conn.nwConnection.endpoint, data)
    }
    
    private func handleConnectionEnd(_ conn: UDPServerConnection, error: Error?) {
        print("UDPServer.handleConnectionData(\(conn),\(String(describing: error)))")
        connectionMap.removeValue(forKey: conn.connectionId)
    }
    
    private func stop(withError error: Error?) {
        print("UDPServer.stop(\(String(describing: error)))")
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

