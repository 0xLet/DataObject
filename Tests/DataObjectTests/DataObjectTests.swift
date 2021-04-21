import XCTest

@testable import DataObject

import SURL
import WTV

internal struct SMObj: Codable {
    var id: Int = 1
    var string: String = "DataObject"
}

final class DataObjectTests: XCTestCase {
    func testBasic() {
        XCTAssertNil(DataObject(0).value(as: Double.self))
    }
    
    func testBasicInit() {
        let obj = DataObject("init_value")
            .set(variable: "SomeValue", value: "qwerty")
            .set(variable: "nil", value: nil)
        
        XCTAssertEqual(obj.value(), "init_value")
        XCTAssertEqual(obj.SomeValue.value(), "qwerty")
        XCTAssertEqual(obj.nil, DataObject())
    }
    
    func testObjectInit() {
        let obj = DataObject("init_value") { o in
            o.set(variable: "SomeObject", value: DataObject("qwerty"))
        }
        
        XCTAssertEqual(obj.value(), "init_value")
        XCTAssertEqual(obj.SomeObject.value(), "qwerty")
    }
    
    func testObjectConsumeInit() {
        let obj = DataObject(DataObject("init_value")) { o in
            o.set(variable: 3.14, value: "pi")
        }
        
        XCTAssertEqual(obj.value(), "init_value")
    }
    
    func testComplexInit() {
        let innerObject = DataObject("init_value") { o in
            o.set(variable: "SomeValue", value: "qwerty")
            o.set(variable: 3.14, value: "pi")
        }
        
        let otherObject = DataObject("other_value") { o in
            o.set(variable: "SomeOtherValue", value: "otherqwerty")
            o.set(variable: 3.14, value: 3.14)
        }
        
        let obj = DataObject { p in
            p.set(childObject: innerObject)
        }
        
        innerObject.set(childObject: otherObject)
        
        otherObject.set(childObject: DataObject())
        
        print(obj)
        
        XCTAssertEqual(obj.value(as: DataObject.self)?.description, DataObject().description)
        XCTAssertEqual(obj.child.value(), "init_value")
        XCTAssertEqual(obj.child.SomeValue.value(), "qwerty")
    }
    
    func testObject() {
        let obj = DataObject()
        obj.variables["qwerty"] = 123456
        
        let newObj = DataObject(obj)
        
        XCTAssertEqual(newObj.qwerty.value(), 123456)
    }
    
    func testArray() {
        let obj = DataObject((1 ... 100).map { $0 })
        
        XCTAssertEqual(obj.array.count, 100)
    }
    
    func testDictionary() {
        let obj = DataObject([
            "some": 3.14,
            3.14: "some"
        ])
        
        XCTAssertEqual(obj.some.value(), 3.14)
        XCTAssertEqual(obj.variable(named: 3.14).value(), "some")
    }
    
    func testCodableObject() {
        let obj = SMObj().object
        
        XCTAssertEqual(obj.id.value(), 1)
        XCTAssertEqual(obj.string.value(), "DataObject")
        
        let smObj = obj.value(decodedAs: SMObj.self)
        
        XCTAssertEqual(smObj?.id, 1)
        XCTAssertEqual(smObj?.string, "DataObject")
    }
    
    func testConsume() {
        let smObj = SMObj().object
        
        let dictObj = DataObject([
            "some": 3.14,
            3.14: "some"
        ])
        
        let arrayObj = DataObject((1 ... 100).map { $0 })
        
        let obj = DataObject(
            ["id": 10]
        )
        XCTAssertEqual(obj.id.value(), 10)
        XCTAssertEqual(obj.array.count, 0)
        
        XCTAssertNil(obj.some.value(as: Double.self))
        XCTAssertNil(obj.variable(named: 3.14).value(as: String.self))
        XCTAssertNil(obj.string.value(as: String.self))
        
        [smObj, dictObj, arrayObj]
            .forEach {
                obj.consume($0)
            }
        
        XCTAssertNotEqual(obj.id.value(), 10)
        
        XCTAssertNotNil(obj.some.value(as: Double.self))
        XCTAssertNotNil(obj.variable(named: 3.14).value(as: String.self))
        XCTAssertNotNil(obj.string.value(as: String.self))
        
        XCTAssertEqual(obj.id.value(), smObj.id.value() ?? -1)
        XCTAssertEqual(obj.string.value(), "DataObject")
        XCTAssertEqual(obj.array.count, arrayObj.array.count)
        XCTAssertEqual(obj.some.value(), 3.14)
        XCTAssertEqual(obj.variable(named: 3.14).value(), "some")
    }
    
    func testAdd() {
        let smObj = SMObj().object
        
        let dictObj = DataObject([
            "some": 3.14,
            3.14: "some"
        ])
        
        let arrayObj = DataObject((1 ... 100).map { $0 })
        
        let empty = DataObject()
        let obj = DataObject(
            ["id": 10]
        )
        XCTAssertEqual(obj.id.value(), 10)
        XCTAssertEqual(obj.array.count, 0)
        
        XCTAssertNil(obj.some.value(as: Double.self))
        XCTAssertNil(obj.variable(named: 3.14).value(as: String.self))
        XCTAssertNil(obj.string.value(as: String.self))
        
        [smObj, dictObj]
            .forEach {
                empty.consume($0)
            }
        obj.set(childObject: empty)
        obj.set(array: arrayObj.array)
        
        XCTAssertEqual(obj.id.value(), 10)
        XCTAssertNotEqual(obj.id.value(), smObj.id.value() ?? -1)
        
        XCTAssertNotNil(obj.child.some.value(as: Double.self))
        XCTAssertNotNil(obj.child.variable(named: 3.14).value(as: String.self))
        XCTAssertNotNil(obj.child.string.value(as: String.self))
        
        XCTAssertEqual(obj.child.id.value(), smObj.id.value() ?? -1)
        XCTAssertEqual(obj.child.string.value(), "DataObject")
        XCTAssertEqual(obj.array.count, arrayObj.array.count)
        XCTAssertEqual(obj.child.some.value(), 3.14)
        XCTAssertEqual(obj.child.variable(named: 3.14).value(), "some")
    }
    
    func testFetchObject() {
        let sema = DispatchSemaphore(value: 0)
        
        "https://jsonplaceholder.typicode.com/posts/1".url?
            .get { (obj) in
                
                XCTAssertEqual(obj.data.userId.value(), 1)
                XCTAssertEqual(obj.data.id.value(), 1)
                XCTAssertEqual(obj.data.title.value(), "sunt aut facere repellat provident occaecati excepturi optio reprehenderit")
                XCTAssertEqual(obj.data.body.value(), "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
                
                sema.signal()
            }
        
        sema.wait()
    }
    
    func testFetch100Objects() {
        let sema = DispatchSemaphore(value: 0)
        
        "https://jsonplaceholder.typicode.com/posts".url?
            .get { (obj) in
                
                XCTAssertEqual(obj.data.array.count, 100)
                
                let first: DataObject? = obj.data.array.first
                
                XCTAssertEqual(first?.userId.value(), 1)
                XCTAssertEqual(first?.id.value(), 1)
                XCTAssertEqual(first?.title.value(), "sunt aut facere repellat provident occaecati excepturi optio reprehenderit")
                XCTAssertEqual(first?.body.value(), "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")
                
                sema.signal()
            }
        
        sema.wait()
    }
    
    func testDive() {
        let sema = DispatchSemaphore(value: 0)
        
        "https://jsonplaceholder.typicode.com/users/7".url?
            .get { (obj) in
                XCTAssertEqual(obj.data.address.street.value(), "Rex Trail")
                XCTAssertEqual(obj.data.address.geo.lng.value(), "21.8984")
                XCTAssertEqual(obj.data.address.geo.lat.value(), "24.8918")
                
                sema.signal()
            }
        
        sema.wait()
    }
    
    func testHashable() {
        var objDict = [DataObject: DataObject]()
        
        let someObjectValue = DataObject("Some Value")
        let someObjectKey = DataObject("Some Key")
        
        objDict[someObjectKey] = someObjectValue
        
        XCTAssertEqual(objDict[someObjectKey], someObjectValue)
    }
    
    func testHashableModify() {
        var objDict = [DataObject: DataObject]()
        
        let someObjectValue = DataObject("Some Value")
        let someOtherObject = DataObject(someObjectValue)
        let someObjectKey = DataObject("Some Key")
        let emptyObject = DataObject()
        
        someObjectValue.modify { (value: String?) in
            guard let _ = value else {
                return "Some Value"
            }
            
            return nil
        }
        
        someOtherObject.modify { _ in
            "Hello World!"
        }
        
        emptyObject.modify { _ in "This should modify!" }
        
        objDict[someObjectKey] = someObjectValue
        
        XCTAssertNil(someObjectValue.variables["_value"])
        XCTAssertEqual(objDict[someObjectKey], DataObject())
        XCTAssertEqual(someOtherObject.value(), "Hello World!")
        XCTAssertEqual(emptyObject, DataObject("This should modify!"))
    }
    
    func testHashableUpdate() {
        var objDict = [DataObject: DataObject]()
        
        let someObjectValue = DataObject("Some Value")
        let someOtherObject = DataObject(someObjectValue)
        let someObjectKey = DataObject("Some Key")
        let emptyObject = DataObject()
        
        someObjectValue.update { value in
            value + ": Hello World!"
        }
        
        someOtherObject
            .update { $0 + ": Hello World!" }
        
        emptyObject.update { _ in "This should not update!" }
        
        objDict[someObjectKey] = someObjectValue
        
        XCTAssertEqual(objDict[someObjectKey], someObjectValue)
        XCTAssertEqual(someOtherObject, someObjectValue)
        XCTAssertEqual(emptyObject, DataObject())
        XCTAssertNotEqual(emptyObject, DataObject("This should not update!"))
    }
    
    static var allTests = [
        ("testBasic", testBasic),
        ("testBasicInit", testBasicInit),
        ("testObjectInit", testObjectInit),
        ("testObjectConsumeInit", testObjectConsumeInit),
        ("testComplexInit", testComplexInit),
        ("testObject", testObject),
        ("testArray", testArray),
        ("testDictionary", testDictionary),
        ("testCodableObject", testCodableObject),
        ("testConsume", testConsume),
        ("testAdd", testAdd),
        ("testFetchObject", testFetchObject),
        ("testFetch100Objects", testFetch100Objects),
        ("testDive", testDive),
        ("testHashable", testHashable),
        ("testHashableModify", testHashableModify),
        ("testHashableUpdate", testHashableUpdate)
    ]
}
