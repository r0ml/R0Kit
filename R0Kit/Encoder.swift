//
//  Copyright © 2017 Semasiology. All rights reserved.
//

import CloudKit

public extension RawRepresentable where Self : Recordable {
  public var recordValue : CKRecordValue { return self.rawValue as! CKRecordValue }
  public static func from(recordValue: CKRecordValue) -> Self {
    return Self.init(rawValue: recordValue as! Self.RawValue)!
  }
}

public protocol Recordable {
  var recordValue : CKRecordValue { get }
  static func from(recordValue: CKRecordValue) -> Self
}

extension Set : Recordable {
  public var recordValue : CKRecordValue { get {
    return (self.map { $0 as! CKRecordValue }) as CKRecordValue
    }}
  public static func from(recordValue: CKRecordValue) -> Set<Element> {
    if let a = recordValue as? Array<Element> {
      return Set<Element>(a)
    }
    fatalError("Set from RecordValue not yet implemented")
  }
}
/*public protocol RecordEncodable {}

public extension RecordEncodable where Self: RawRepresentable, Self.RawValue: CKRecordValue {
  func box() -> CKRecordValue {
    return rawValue
  }
}*/

/*public protocol Encodable {
  
  func encode() -> Encoder
}*/

/*public extension Encodable where Self: RawRepresentable, Self.RawValue: Encodable {
  
  public func encode() -> Data? {
    return rawValue.encode()
  }
}*/

public class RecordEncoder : Encoder {
  public var record: CKRecord

  public var codingPath: [CodingKey] { return [] }
  public var userInfo: [CodingUserInfoKey : Any] { return [:] }
  
  public init(_ s : String, _ n : String, _ zid : CKRecordZoneID) {
    record = CKRecord.init(recordType: s, recordID: CKRecordID.init(recordName: n, zoneID: zid))
  }
  
  public init<T>(_ m : T, _ zid : CKRecordZoneID) where T : DataModel {
    record = CKRecord.init(recordType: m.name, recordID: CKRecordID.init(recordName: m.getKey(), zoneID: zid ))
  }
  
  public init(record: inout CKRecord) {
    self.record = record
  }

  func encode(_ value: Bool) throws {
    try encode(value ? 1 as UInt8 : 0 as UInt8)
  }
  
  func encode(_ encodable: Encodable) throws {
    switch encodable {
      default: try encodable.encode(to: self)
    }
  }

  public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
    return KeyedEncodingContainer(KeyedContainer<Key>(encoder: self))
  }
  
  public func unkeyedContainer() -> UnkeyedEncodingContainer {
    return RecordUnkeyedContainer(encoder: self)
  }
  
  public func singleValueContainer() -> SingleValueEncodingContainer {
    return RecordUnkeyedContainer(encoder: self)
  }
  
  private struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    var encoder: RecordEncoder
    
    var codingPath: [CodingKey] { return [] }
    
    func encode<T>(_ valu: T, forKey key: Key) throws where T : Encodable {
      var t : CKRecordValue
      if let v = valu as? Recordable {
        t = v.recordValue
      } else {
        t = valu as! CKRecordValue
      }
      encoder.record[key.stringValue] = t
    }
    
    func encodeNil(forKey key: Key) throws {
      encoder.record[key.stringValue] = nil
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
      return encoder.container(keyedBy: keyType)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
      return encoder.unkeyedContainer()
    }
    
    func superEncoder() -> Encoder {
      return encoder
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
      return encoder
    }
  }
  
  private struct RecordUnkeyedContainer: UnkeyedEncodingContainer, SingleValueEncodingContainer {
    var encoder: RecordEncoder
    
    var codingPath: [CodingKey] { return [] }
    var count: Int { return 0 }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
      return encoder.container(keyedBy: keyType)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
      return self
    }
    
    func superEncoder() -> Encoder {
      return encoder
    }
    
    func encodeNil() throws {}
    
    func encode<T>(_ value: T) throws where T : Encodable {
      throw NSError.init(domain: "clem", code: 3)
      // try encoder.encode(value)
    }
  }
}

