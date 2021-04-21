//
//  DataObject+CustomStringConvertible.swift
//  
//
//  Created by Leif on 3/14/21.
//

extension DataObject: CustomStringConvertible {
    public var description: String {
        """
        DataObject {
        \(
            variables
                .map { (key, value) in
                    guard let object = value as? DataObject else {
                        return "|\t* \(key): \(value) (\(type(of: value)))"
                    }
                    
                    let values = object.description.split(separator: "\n")
                        .dropFirst()
                    
                    if values.dropLast().isEmpty {
                        return "|\t* \(key): DataObject { }"
                    }
                    
                    return "|\t* \(key): DataObject {\n\(values.map { "|\t \($0)" }.joined(separator: "\n"))"
                }
                .joined(separator: "\n")
        )
        }
        """
    }
}
