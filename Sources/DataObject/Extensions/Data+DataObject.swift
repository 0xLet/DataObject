//
//  Data+DataObject.swift
//  
//
//  Created by Leif on 3/14/21.
//

import Foundation

public extension Data {
    var object: DataObject {
        DataObject(self)
    }
}
