//
//  UDPClient.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/9/20.
//
import Foundation
import Network

class UDPClient {
    
    // MARK: - Public typealiases
    
    public typealias OnReceiveData = (Data) -> Void
    public typealias OnEnd = (Error?) -> Void

    // MARK: - Public properties

    public let host: String
    public let port: UInt16
    public var onReceiveData: OnReceiveData?
    public var onEnd: OnEnd?

    // MARK: - Private properties
    
    private let nwConnection: NWConnection

    // MARK: - Initializers
    
    public init?(host: String, port: UInt16) {
        print("UDPClient(host=\(host),port=\(port))")
        self.host = host
        self.port = port
        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            return nil
        }
        nwConnection = NWConnection(host: NWEndpoint.Host(host), port: nwPort, using: .udp)
    }
    
    // MARK: - Public methods
    
    public func start(on queue: DispatchQueue) {
        print("UDPClient.start(on=\(queue))")
        nwConnection.stateUpdateHandler = { [weak self] in
            self?.handleStateChange($0)
        }
        nwConnection.pathUpdateHandler = { [weak self] in
            self?.handlePathUpdate($0)
        }
        nwConnection.viabilityUpdateHandler = { [weak self] in
            self?.handleViabilityUpdate($0)
        }
        nwConnection.betterPathUpdateHandler = { [weak self] in
            self?.betterPathAvailableUpdate($0)
        }
        setupReceive()
        nwConnection.start(queue: queue)
    }
    
    public func stop() {
        print("UDPClient.stop()")
        stop(withError: nil)
    }
    
    public func send(_ data: Data) {
        print("UDPClient.send(data=\(data))")
        nwConnection.send(content: data, completion: .contentProcessed({ [weak self] (error) in
            print("UDPClient.NWConnection.sendCompletion(error=\(String(describing: error))")
            if let error = error {
                self?.stop(withError: error)
            }
        }))
    }
    
    // MARK: - Private methods
    
    private func setupReceive() {
        print("UDPClient.setupReceive()")
        nwConnection.receiveMessage { [weak self] (data, context, isComplete, error) in
            print("UDPClient.NWConnection.receiveMessageCompletion(data=\(String(describing: data)),context=\(String(describing: context)),isComplete=\(isComplete),error=\(String(describing: error)))")
            if let data = data {
                self?.onReceiveData?(data)
            }
            if let error = error {
                self?.stop(withError: error)
            } else {
                self?.setupReceive()
            }
        }
    }

    private func handleStateChange(_ state: NWConnection.State) {
        print("UDPClient.handleStateChange(\(state))")
        switch state {
        case .failed(let error):
            stop(withError: error)
        case .waiting(let error):
            stop(withError: error)
        default:
            break
        }
    }
    
    private func handlePathUpdate(_ path: NWPath) {
        print("UDPClient.handlePathUpdate(\(path))")
    }
    
    private func handleViabilityUpdate(_ viable: Bool) {
        print("UDPClient.handleViabilityUpdate(\(viable))")
    }
    
    private func betterPathAvailableUpdate(_ available: Bool) {
        print("UDPClient.betterPathAvailableUpdate(\(available))")
    }
    
    private func stop(withError error: Error?) {
        print("UDPClient.stop(error=\(String(describing: error)))")
        nwConnection.stateUpdateHandler = nil
        nwConnection.pathUpdateHandler = nil
        nwConnection.viabilityUpdateHandler = nil
        nwConnection.betterPathUpdateHandler = nil
        nwConnection.cancel()
        if let onEnd = onEnd {
            self.onEnd = nil
            onEnd(error)
        }
    }

}
