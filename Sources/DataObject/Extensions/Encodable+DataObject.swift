//
//  Encodable+DataObject.swift
//  
//
//  Created by Leif on 3/14/21.
//

import Foundation

public extension Encodable {
    var object: DataObject {
        guard let data =  try? JSONEncoder().encode(self) else {
            return DataObject(self)
        }
        return DataObject(data)
    }
}
