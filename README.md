# DataObject

*DataObject(Any)*

## Basic Example
```swift
let obj = DataObject("init_value")
    .add(variable: "SomeValue", value: "qwerty")
    .add(variable: "nil", value: nil)

XCTAssertEqual(obj.value(), "init_value")
XCTAssertEqual(obj.SomeValue.value(), "qwerty")
XCTAssertEqual(obj.nil, DataObject())
```

## [SURL](https://github.com/0xLeif/SURL) JSON Example
```swift
"https://jsonplaceholder.typicode.com/users/7".url?
    .get { (obj) in
        print(obj.variables.keys) // [AnyHashable("response"), AnyHashable("data")]
        print(obj.data)
}
```

<details> 
  <summary>JSON</summary> 

```json 
{
  "id": 7,
  "name": "Kurtis Weissnat",
  "username": "Elwyn.Skiles",
  "email": "Telly.Hoeger@billy.biz",
  "address": {
    "street": "Rex Trail",
    "suite": "Suite 280",
    "city": "Howemouth",
    "zipcode": "58804-1099",
    "geo": {
      "lat": "24.8918",
      "lng": "21.8984"
    }
  },
  "phone": "210.067.6132",
  "website": "elvis.io",
  "company": {
    "name": "Johns Group",
    "catchPhrase": "Configurable multimedia task-force",
    "bs": "generate enterprise e-tailers"
  }
}
```

</details> 

### Output: obj.data 
```swift
DataObject {
|    Variables
|    * id: 7 (__NSCFNumber)
|    * value: 500 bytes (Data)
|    * address: {
    city = Howemouth;
    geo =     {
        lat = "24.8918";
        lng = "21.8984";
    };
    street = "Rex Trail";
    suite = "Suite 280";
    zipcode = "58804-1099";
} (__NSDictionaryI)
|    * email: Telly.Hoeger@billy.biz (__NSCFString)
|    * json: {
  "id": 7,
  "name": "Kurtis Weissnat",
  "username": "Elwyn.Skiles",
  "email": "Telly.Hoeger@billy.biz",
  "address": {
    "street": "Rex Trail",
    "suite": "Suite 280",
    "city": "Howemouth",
    "zipcode": "58804-1099",
    "geo": {
      "lat": "24.8918",
      "lng": "21.8984"
    }
  },
  "phone": "210.067.6132",
  "website": "elvis.io",
  "company": {
    "name": "Johns Group",
    "catchPhrase": "Configurable multimedia task-force",
    "bs": "generate enterprise e-tailers"
  }
} (String)
|    * website: elvis.io (NSTaggedPointerString)
|    * username: Elwyn.Skiles (__NSCFString)
|    * company: {
    bs = "generate enterprise e-tailers";
    catchPhrase = "Configurable multimedia task-force";
    name = "Johns Group";
} (__NSDictionaryI)
|    * phone: 210.067.6132 (__NSCFString)
|    * name: Kurtis Weissnat (__NSCFString)
}
```

## [WTV](https://github.com/0xLeif/WTV) Example
```swift
"https://jsonplaceholder.typicode.com/users/7".url?
    .get { (obj) in
        print(obj.data.wtv(named: "name")!)
}
```

### Output: obj.data.wtv(named: "name")
```swift
DataObject.variables["company"]["name"] 👉 FOUND: (label: Optional("name"), value: Johns Group)
DataObject.variables["name"] 👉 FOUND: (label: Optional("name"), value: Kurtis Weissnat)
```
