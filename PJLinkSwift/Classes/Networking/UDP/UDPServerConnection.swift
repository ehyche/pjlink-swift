//
//  UDPServerConnection.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/9/20.
//
import Foundation
import Network

class UDPServerConnection {
    
    // MARK: - Public typealiases
    
    public typealias OnDataClosure = (UDPServerConnection, Data) -> Void
    public typealias OnEndClosure = (UDPServerConnection, Error?) -> Void
    
    // MARK: - Public properties
    
    public var onData: OnDataClosure?
    public var onEnd: OnEndClosure?
    public let connectionId: Int
    public let nwConnection: NWConnection

    // MARK: - Initializers
    
    public init(nwConnection: NWConnection, connectionId: Int) {
        print("UDPServerConnection(nwConnection=\(nwConnection),id=\(connectionId))")
        self.nwConnection = nwConnection
        self.connectionId = connectionId
    }
    
    // MARK: - Public methods
    
    public func start(on queue: DispatchQueue) {
        print("UDPServerConnection[\(connectionId)].start(\(queue))")
        nwConnection.stateUpdateHandler = { [weak self] state in
            self?.stateDidChange(state)
        }
        nwConnection.start(queue: queue)
    }
    
    public func stop() {
        print("UDPServerConnection[\(connectionId)].stop()")
        stop(withError: nil)
    }
    
    // MARK: - Private methods
    
    private func stateDidChange(_ state: NWConnection.State) {
        print("UDPServerConnection[\(connectionId)].stateDidChange(\(state))")
        switch state {
        case .failed(let error):
            self.stop(withError: error)
        case .waiting(let error):
            self.stop(withError: error)
        default:
            break
        }
    }
    
    private func setupReceiveMessage() {
        print("UDPServerConnection[\(connectionId)].setupReceiveMessage()")
        nwConnection.receiveMessage { [weak self] (data, context, isComplete, error) in
            print("UDPClient.NWConnection.receiveMessageCompletion(data=\(String(describing: data)),context=\(String(describing: context)),isComplete=\(isComplete),error=\(String(describing: error)))")
            guard let strongSelf = self else {
                return
            }
            if let data = data {
                strongSelf.onData?(strongSelf, data)
            }
            if let error = error {
                strongSelf.stop(withError: error)
            } else {
                strongSelf.setupReceiveMessage()
            }
        }
    }
    
    private func stop(withError error: Error?) {
        print("UDPServerConnection[\(connectionId)].stop(\(String(describing: error)))")
        nwConnection.stateUpdateHandler = nil
        nwConnection.cancel()
        if let onEnd = onEnd {
            self.onEnd = nil
            onEnd(self, error)
        }
    }

}

