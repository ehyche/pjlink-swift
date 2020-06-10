//
//  PJLinkURLProtocol.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 4/23/20.
//

import Foundation

public class PJLinkURLProtocol: URLProtocol {
    
    // MARK: - Public properties
    
    public static let scheme = "pjlink"
    public static let defaultPort = 4352
    
    // MARK: - Private properties

    // MARK: - Initializers
    
    public override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }
    
    public convenience init(task: URLSessionTask, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        self.init(request: task.originalRequest!, cachedResponse: cachedResponse, client: client)
    }
    
    // MARK: - Public URLProtocol overrides

    public override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.scheme == PJLinkURLProtocol.scheme
    }
    
    public override class func canInit(with task: URLSessionTask) -> Bool {
        guard let request = task.currentRequest else {
            return false
        }
        return canInit(with: request)
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    public override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        // Check the scheme
        guard let schemeA = a.url?.scheme,
              let schemeB = b.url?.scheme,
              schemeA == schemeB,
              schemeA == PJLinkURLProtocol.scheme else {
            return false
        }
        
        // Check the host
        guard let hostA = a.url?.host,
              let hostB = b.url?.host,
            hostA == hostB else {
            return false
        }
        
        // Check the body data
        guard let bodyA = a.httpBody, let bodyB = b.httpBody, bodyA == bodyB else {
            return false
        }
        
        return true
    }

    public override func startLoading() {
        
    }

    public override func stopLoading() {
        
    }

}
