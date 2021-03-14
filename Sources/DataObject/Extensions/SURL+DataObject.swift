//
//  SURL+DataObject.swift
//  
//
//  Created by Leif on 3/14/21.
//

import Foundation
import SURL

public extension URL {
    func get(
        withHandler handler: @escaping (DataObject) -> Void
    ) {
        urlRequest(forHTTPMethod: .GET)
            .dataTask(
                withHandler: { (data, response, error) in
                    handler(DataObject()
                                .add(variable: "data", value: data)
                                .add(variable: "response", value: response)
                                .add(variable: "error", value: error))
                }
            )
            .resume()
    }
    
    func head(
        withHandler handler: @escaping (DataObject) -> Void
    ) {
        urlRequest(forHTTPMethod: .HEAD)
            .dataTask(
                withHandler: { (_, response, error) in
                    handler(DataObject()
                                .add(variable: "response", value: response)
                                .add(variable: "error", value: error))
                }
            )
            .resume()
    }
    
    func connect(
        withHandler handler: @escaping (DataObject) -> Void
    ) {
        urlRequest(forHTTPMethod: .CONNECT)
            .dataTask(
                withHandler: { (data, response, error) in
                    handler(DataObject()
                                .add(variable: "data", value: data)
                                .add(variable: "response", value: response)
                                .add(variable: "error", value: error))
                }
            )
            .resume()
    }
    
    func options(
        withHandler handler: @escaping (DataObject) -> Void
    ) {
        urlRequest(forHTTPMethod: .OPTIONS)
            .dataTask(
                withHandler: { (data, response, error) in
                    handler(DataObject()
                                .add(variable: "data", value: data)
                                .add(variable: "response", value: response)
                                .add(variable: "error", value: error))
                }
            )
            .resume()
    }
    
    func trace(
        withHandler handler: @escaping (DataObject) -> Void
    ) {
        urlRequest(forHTTPMethod: .TRACE)
            .dataTask(
                withHandler: { (data, response, error) in
                    handler(DataObject()
                                .add(variable: "response", value: response)
                                .add(variable: "error", value: error))
                }
            )
            .resume()
    }
    
    func post(
        data: Data?,
        withHandler handler: @escaping (DataObject) -> Void
    ) {
        var request = urlRequest(forHTTPMethod: .POST)
        
        request.httpBody = data
        
        request
            .dataTask(
                withHandler: { (data, response, error) in
                    handler(DataObject()
                                .add(variable: "data", value: data)
                                .add(variable: "response", value: response)
                                .add(variable: "error", value: error))
                }
            )
            .resume()
    }
    
    func put(
        data: Data?,
        withHandler handler: @escaping (DataObject) -> Void
    ) {
        var request = urlRequest(forHTTPMethod: .PUT)
        
        request.httpBody = data
        
        request
            .dataTask(
                withHandler: { (data, response, error) in
                    handler(DataObject()
                                .add(variable: "response", value: response)
                                .add(variable: "error", value: error))
                }
            )
            .resume()
    }
    
    func patch(
        data: Data?,
        withHandler handler: @escaping (DataObject) -> Void
    ) {
        var request = urlRequest(forHTTPMethod: .PATCH)
        
        request.httpBody = data
        
        request
            .dataTask(
                withHandler: { (data, response, error) in
                    handler(DataObject()
                                .add(variable: "data", value: data)
                                .add(variable: "response", value: response)
                                .add(variable: "error", value: error))
                }
            )
            .resume()
    }
    
    func delete(
        data: Data?,
        withHandler handler: @escaping (DataObject) -> Void
    ) {
        var request = urlRequest(forHTTPMethod: .DELETE)
        
        request.httpBody = data
        
        request
            .dataTask(
                withHandler: { (data, response, error) in
                    handler(DataObject()
                                .add(variable: "data", value: data)
                                .add(variable: "response", value: response)
                                .add(variable: "error", value: error))
                }
            )
            .resume()
    }
    
}
