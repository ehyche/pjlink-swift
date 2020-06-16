//
//  String+Extensions.swift
//  PJLinkSwift
//
//  Created by Eric Hyche on 5/20/20.
//

import Foundation

extension String: Deserializable {

    public init(fromString string: String) throws {
        self = string
    }

}

extension String: Serializable {

    public func toString() -> String {
        return self
    }

}

extension String {
    
    func nextIndex(of element: Character, from: Index) -> Index? {
        var index = from
        while index >= self.startIndex && index < self.endIndex {
            if self[index] == element {
                return index
            }
            index = self.index(after: index)
        }
        return nil
    }
    
    func asCommandStrings() -> [String] {
        var cmds = [String]()

        var index: String.Index? = self.startIndex
        while index != nil {
            // Search for header
            index = self.nextIndex(of: Command.header, from: index!)
            if index != nil {
                let headerIndex = index!
                // Search for terminator
                index = self.nextIndex(of: Command.terminator, from: self.index(after: headerIndex))
                if index != nil {
                    let terminatorIndex = index!
                    // Create a string from the range headerIndex...terminatorIndex
                    cmds.append(String(self[headerIndex...terminatorIndex]))
                    // Update to start the search after the terminator
                    index = self.index(after: terminatorIndex)
                }
            }
        }

        return cmds
    }
    
    func parseAsPJLinkRequest() -> (auth: String, commands: [String]) {
        var auth = ""
        var cmds = [String]()

        var firstHeader = true
        var index: String.Index? = self.startIndex
        while index != nil {
            // Search for command header
            index = self.nextIndex(of: Command.header, from: index!)
            if index != nil {
                let headerIndex = index!
                if firstHeader {
                    auth = String(self[startIndex..<headerIndex]).trimmingCharacters(in: CharacterSet.whitespaces)
                    firstHeader = false
                }
                // Search for command terminator
                index = self.nextIndex(of: Command.terminator, from: self.index(after: headerIndex))
                if index != nil {
                    let terminatorIndex = index!
                    // Create a string from the range headerIndex...terminatorIndex
                    cmds.append(String(self[headerIndex...terminatorIndex]))
                    // Update to start the search after the terminator
                    index = self.index(after: terminatorIndex)
                }
            }
        }

        return (auth: auth, commands: cmds)
    }
    
    public func responses() throws -> [Response] {
        var resp = [Response]()

        let cmdStrings = asCommandStrings()
        guard !cmdStrings.isEmpty else {
            throw DeserializationError.noCommands
        }

        for cmdString in cmdStrings {
            let response = try Response(fromString: cmdString)
            resp.append(response)
        }

        return resp
    }
    
    public func asUTF8Data() throws -> Data {
        guard let data = self.data(using: .utf8) else {
            throw DeserializationError.badAsciiData
        }
        return data
    }

}
