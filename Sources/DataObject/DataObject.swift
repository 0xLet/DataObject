import Foundation
import SwiftFu

@dynamicMemberLookup
public class DataObject: FuableClass {
    public enum ObjectVariable: String, Hashable {
        case value
        case child
        case array
        case json
    }
    /// Variables of the object
    public var variables: [AnyHashable: Any] = [:]
    /// @dynamicMemberLookup
    public subscript(dynamicMember member: String) -> DataObject {
        variable(named: member)
    }
    
    // MARK: public init
    
    public init() { }
    public convenience init(_ closure: (DataObject) -> Void) {
        self.init()
        
        closure(self)
    }
    public init(_ value: Any? = nil, _ closure: ((DataObject) -> Void)? = nil) {
        defer {
            if let closure = closure {
                configure(closure)
            }
        }
        
        guard let value = value else {
            return
        }
        let unwrappedValue = unwrap(value)
        if let _ = unwrappedValue as? NSNull {
            return
        }
        if let object = unwrappedValue as? DataObject {
            consume(object)
        } else if let array = unwrappedValue as? [Any] {
            consume(DataObject(array: array))
        } else if let dictionary = unwrappedValue as? [AnyHashable: Any] {
            consume(DataObject(dictionary: dictionary))
        } else if let data = unwrappedValue as? Data {
            consume(DataObject(data: data))
        } else {
            consume(DataObject {
                $0.add(value: unwrappedValue)
            })
        }
    }
    
    // MARK: private init
    
    private init(array: [Any]) {
        add(variable: ObjectVariable.array, value: array.map {
            DataObject($0)
        })
    }
    private init(dictionary: [AnyHashable: Any]) {
        variables = dictionary
    }
    private init(data: Data) {
        defer {
            variables[ObjectVariable.json] = String(data: data, encoding: .utf8)
            add(value: data)
        }
        if let json = try? JSONSerialization.jsonObject(with: data,
                                                        options: .allowFragments) as? [Any] {
            add(variable: ObjectVariable.array, value: json)
            return
        }
        guard let json = try? JSONSerialization.jsonObject(with: data,
                                                           options: .allowFragments) as? [AnyHashable: Any] else {
            return
        }
        consume(DataObject(json))
    }
}

// MARK: public variables


public extension DataObject {
    var array: [DataObject] {
        if let array = variables[ObjectVariable.array] as? [Data] {
            return array.map { DataObject(data: $0) }
        } else if let array = variables[ObjectVariable.array] as? [Any] {
            return array.map { value in
                guard let json = value as? [AnyHashable: Any] else {
                    return DataObject(value)
                }
                return DataObject(dictionary: json)
            }
        }
        return []
    }
    
    var child: DataObject {
        (variables[ObjectVariable.child] as? DataObject) ?? DataObject()
    }
    
    var value: Any {
        variables[ObjectVariable.value] ?? DataObject()
    }
}

// MARK: public functions


public extension DataObject {
    /// Retrieve a Value from the current object
    @discardableResult
    func variable(named: AnyHashable) -> DataObject {
        guard let value = variables[named] else {
            return DataObject()
        }
        if let array = value as? [Any] {
            return DataObject(array: array)
        }
        guard let object = value as? DataObject else {
            return DataObject(unwrap(value))
        }
        return object
    }
    /// Add a Value with a name to the current object
    @discardableResult
    func add(variable named: AnyHashable = ObjectVariable.value, value: Any?) -> Self {
        guard let value = value,
              (unwrap(value) as? NSNull) == nil else {
            return self
        }
        
        variables[named] = value
        
        return self
    }
    /// Modify a Value with a name to the current object
    @discardableResult
    func modify<T>(variable named: AnyHashable = ObjectVariable.value, modifier: (T?) -> T?) -> Self {
        guard let variable = variables[named],
              let value = variable as? T else {
            variables[named] = modifier(nil)
            
            return self
        }
        variables[named] = modifier(value)
        
        return self
    }
    /// Set a Value with a name to the current object
    @discardableResult
    func set<T>(variable named: AnyHashable = ObjectVariable.value, modifier: (T) -> T?) -> Self {
        guard let variable = variables[named],
              let value = variable as? T else {
            return self
        }
        variables[named] = modifier(value)
        
        return self
    }
    /// Update a Value with a name to the current object
    @discardableResult
    func update<T>(variable named: AnyHashable = ObjectVariable.value, modifier: (T) -> T) -> Self {
        guard let variable = variables[named],
              let value = variable as? T else {
            return self
        }
        variables[named] = modifier(value)
        
        return self
    }
    /// Add a ChildObject with a name of `_object` to the current object
    @discardableResult
    func add(childObject object: DataObject) -> Self {
        variables[ObjectVariable.child] = object
        
        return self
    }
    /// Add an Array with a name of `_array` to the current object
    @discardableResult
    func add(array: [Any]) -> Self {
        variables[ObjectVariable.array] = array
        
        return self
    }
    
    @discardableResult
    func configure(_ closure: (DataObject) -> Void) -> DataObject {
        closure(self)
        
        return self
    }
    
    @discardableResult
    func consume(_ object: DataObject) -> DataObject {
        object.variables.forEach { (key, value) in
            self.add(variable: key, value: value)
        }
        
        return self
    }
    
    func value<T>(as type: T.Type? = nil) -> T? {
        value as? T
    }
    
    func value<T>(decodedAs type: T.Type) -> T? where T: Decodable {
        guard let data = value(as: Data.self) else {
            return nil
        }
        
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

private extension DataObject {
    /// Unwraps the <Optional> Any type
    func unwrap(_ value: Any) -> Any {
        let mValue = Mirror(reflecting: value)
        let isValueOptional = mValue.displayStyle != .optional
        let isValueEmpty = mValue.children.isEmpty
        if isValueOptional { return value }
        if isValueEmpty { return NSNull() }
        guard let (_, unwrappedValue) = mValue.children.first else { return NSNull() }
        return unwrappedValue
    }
}
