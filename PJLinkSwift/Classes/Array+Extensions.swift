//
//  Array+Extensions.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 6/4/20.
//

import Foundation

extension Array: Serializable where Array.Element: Serializable {

    public func toString() -> String {
        return map({ $0.toString() }).joined(separator: String(Response.arraySeparator))
    }

}

extension Array: Deserializable where Array.Element: Deserializable {

    public init(fromString string: String) throws {
        // This assumes that there are no internal spaces
        // inside each Array.Element.
        let splits = string.split(separator: Response.arraySeparator, omittingEmptySubsequences: true)
        var elements = [Array.Element]()
        for split in splits {
            let element = try Array.Element(fromString: String(split))
            elements.append(element)
        }
        self = elements
    }

}

