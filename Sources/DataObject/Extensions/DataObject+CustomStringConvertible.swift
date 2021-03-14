//
//  DataObject+CustomStringConvertible.swift
//  
//
//  Created by Leif on 3/14/21.
//

extension DataObject: CustomStringConvertible {
    public var description: String {
        var varDescription: String? = "|\tVariables\n"
        
        if variables.isEmpty {
            varDescription = nil
        } else {
            varDescription? += variables
                .map { (key, value) in
                    guard let object = value as? DataObject else {
                        return "|\t* \(key): \(value) (\(type(of: value)))"
                    }
                    
                    return "|\t \(key): DataObject {\n\(object.description.split(separator: "\n").map { "|\t \($0)" }.dropFirst().joined(separator: "\n"))"
                }
                .joined(separator: "\n")
        }
        
        return ["DataObject {", varDescription, "}"].compactMap { $0 }.joined(separator: "\n")
    }
}
