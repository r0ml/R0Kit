//
//  Copyright © 2017 Semasiology. All rights reserved.
//

import CloudKit

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
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
      try encoder.record[key.stringValue] = value as! CKRecordValue 
    }
    
    func encodeNil(forKey key: Key) throws {}
    
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
      try encoder.encode(value)
    }
  }
}

