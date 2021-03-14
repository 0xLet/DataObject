//
//  DataObject+WTV.swift
//  
//
//  Created by Leif on 3/14/21.
//

import WTV

public extension DataObject {
    func wtv(named: String) -> String? {
        WTV(self).variable(named: named)
    }
    
    func wtv(nameContains: String) -> String? {
        WTV(self).variable(nameContains: nameContains)
    }
}
