//
//  TCPServerConnection.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/9/20.
//
import Foundation
import Network

public class TCPServerConnection {
    
    // MARK: - Public typealiases
    
    public typealias OnDataClosure = (TCPServerConnection, Data) -> Void
    public typealias OnEndClosure = (TCPServerConnection, Error?) -> Void
    
    // MARK: - Public properties
    
    public var onData: OnDataClosure?
    public var onEnd: OnEndClosure?
    public let connectionId: Int
    public let nwConnection: NWConnection
    
    // MARK: - Private properties
    
    private let minimumByteCount = 1
    private let maximumByteCount = 65535

    // MARK: - Initializers
    
    public init(nwConnection: NWConnection, connectionId: Int) {
        print("TCPServerConnection(nwConnection=\(nwConnection),id=\(connectionId))")
        self.nwConnection = nwConnection
        self.connectionId = connectionId
    }
    
    // MARK: - Public methods
    
    public func start(on queue: DispatchQueue) {
        print("TCPServerConnection[\(connectionId)].start(\(queue))")
        nwConnection.stateUpdateHandler = { [weak self] state in
            self?.stateDidChange(state)
        }
        setupReceive()
        nwConnection.start(queue: queue)
    }
    
    public func stop() {
        print("TCPServerConnection[\(connectionId)].stop()")
        stop(withError: nil)
    }
    
    public func send(_ data: Data) {
        print("TCPServerConnection.send(data=\(data))")
        nwConnection.send(content: data, completion: .contentProcessed({ [weak self] (error) in
            print("TCPServerConnection.NWConnection.sendCompletion(error=\(String(describing: error))")
            if let error = error {
                self?.stop(withError: error)
            }
        }))
    }
    
    // MARK: - Private methods
    
    private func stateDidChange(_ state: NWConnection.State) {
        print("TCPServerConnection[\(connectionId)].stateDidChange(\(state))")
        switch state {
        case .failed(let error):
            self.stop(withError: error)
        case .waiting(let error):
            self.stop(withError: error)
        default:
            break
        }
    }
    
    private func setupReceive() {
        print("TCPServerConnection[\(connectionId)].setupReceiveMessage()")
        nwConnection.receive(minimumIncompleteLength: minimumByteCount, maximumLength: maximumByteCount) { [weak self] (data, context, isComplete, error) in
            print("TCPServerConnection.NWConnection.receiveCompletion(data=\(String(describing: data)),context=\(String(describing: context)),isComplete=\(isComplete),error=\(String(describing: error)))")
            guard let strongSelf = self else {
                return
            }
            if let data = data {
                strongSelf.onData?(strongSelf, data)
            }
            if let error = error {
                strongSelf.stop(withError: error)
            } else {
                strongSelf.setupReceive()
            }
        }
    }
    
    private func stop(withError error: Error?) {
        print("TCPServerConnection[\(connectionId)].stop(\(String(describing: error)))")
        nwConnection.stateUpdateHandler = nil
        nwConnection.cancel()
        if let onEnd = onEnd {
            self.onEnd = nil
            onEnd(self, error)
        }
    }

}

