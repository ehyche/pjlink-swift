//
//  StatusManager.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/9/20.
//

import Foundation
import Network

public class StatusManager {
    
    // MARK: - Public typealiases
    
    public typealias OnStatusUpdateClosure = (NWEndpoint, StatusResponse) -> Void
    
    // MARK: - Public properties
    
    public var onStatusUpdate: OnStatusUpdateClosure?
    
    // MARK: - Private properties
    
    private let udpServer: UDPServer
    private let udpClient: UDPClient? = nil
    
    // MARK: - Initializers
    
    public init() throws {
        udpServer = try UDPServer()
    }

    // MARK: - Public methods
    
    public func startListening(on queue: DispatchQueue) {
        udpServer.onData = { [weak self] (nwEndpoint, data) in
            self?.handleData(data, fromEndpoint: nwEndpoint)
        }
        udpServer.start(on: queue)
    }
    
    public func stopListening() {
        udpServer.onData = nil
        udpServer.stop()
    }
    
    public func sendSearchBroadcast() {
        
    }
    
    // MARK: - Private methods
    
    private func handleData(_ data: Data, fromEndpoint endpoint: NWEndpoint) {
        do {
            let statusResponse = try StatusResponse(fromData: data)
            onStatusUpdate?(endpoint, statusResponse)
        } catch {
            print("Error parsing StatusResponse error=\(error)")
        }
    }
    
}
