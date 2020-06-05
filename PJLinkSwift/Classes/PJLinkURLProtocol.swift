//
//  PJLinkURLProtocol.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 4/23/20.
//

import Foundation

class PJLinkURLProtocol: URLProtocol {

    init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        
    }

    convenience init(task: URLSessionTask, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        
    }

    class func canInit(with request: URLRequest) -> Bool {
        guard let urlScheme = request.url?.scheme else {
            return false
        }
        return urlScheme = "pjlink"
    }

    class func canInit(with task: URLSessionTask) -> Bool {
        guard let request = task.currentRequest else {
            return false
        }
        return canInit(with: request)
    }

    class func canonicalRequest(for request: URLRequest) -> URLRequest {
        
    }

    class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return true
    }

    func startLoading() {
        
    }

    func stopLoading() {
        
    }

}
