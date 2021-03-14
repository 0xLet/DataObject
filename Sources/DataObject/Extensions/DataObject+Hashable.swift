//
//  DataObject+Hashable.swift
//  
//
//  Created by Leif on 3/14/21.
//

import Foundation

extension DataObject: Hashable {
    public static func == (lhs: DataObject, rhs: DataObject) -> Bool {
        lhs.description == rhs.description
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}
