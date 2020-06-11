//
//  NetworkMonitor.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/9/20.
//

import Foundation
import Network

public class NetworkMonitor {
    
    // MARK: - Public properties

    public static let shared = NetworkMonitor()
    
    public var isWiFiAvailable: Bool {
        return NetworkMonitor.isWiFiAvailable(in: monitor?.currentPath)
    }
    
    // MARK: - Private properties

    private let queue = DispatchQueue(label: "NetworkMonitor queue")
    private var monitor: NWPathMonitor? = nil

    // MARK: - Public methods

    public func start() {
        if monitor == nil {
            monitor = NWPathMonitor()
        }
        monitor?.pathUpdateHandler = { [weak self] path in
            self?.pathDidUpdate(path)
        }
        monitor?.start(queue: queue)
    }

    public func stop() {
        monitor?.pathUpdateHandler = nil
        monitor?.cancel()
        monitor = nil
    }

    // MARK: - Private methods

    private func pathDidUpdate(_ path: NWPath) {
        
    }

    private class func isWiFiAvailable(in path: NWPath?) -> Bool {
        guard let path = path else {
            return false
        }
        guard path.status == .satisfied else {
            return false
        }
        return path.usesInterfaceType(.wifi)
    }
    
}

