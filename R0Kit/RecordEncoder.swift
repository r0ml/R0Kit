//
//  Copyright © 2017 Semasiology. All rights reserved.
//

import CloudKit

// This is used to represent a hierarchy of parent-child records as the result of a decoding
// in theory, this allows writing the whole tree up to iCloud.
// perhaps I could have a "base" containing multiple types to represent the entire nested
// structure, rather than a separate "base" for each record type.

// I could represet the entire zone by an object -- and have each record type in the zone.
/*public struct PCRecord {
  public var p : CKRecord
  public var cs : [PCRecord]
  
  public var allRecords : [CKRecord] {
    var res = [p]
    cs.forEach { res.append(contentsOf: $0.allRecords )}
    return res
  }
}*/

public extension RawRepresentable where Self : CKRecordValuable {
  public var recordValue : CKRecordValue { return self.rawValue as! CKRecordValue }
  public static func from(recordValue: CKRecordValue) -> Self {
    return Self.init(rawValue: recordValue as! Self.RawValue)!
  }
}

public protocol CKRecordValuable {
  var recordValue : CKRecordValue { get }
  static func from(recordValue: CKRecordValue) -> Self
}

extension Set : CKRecordValuable {
  public var recordValue : CKRecordValue { get {
    return (self.map { $0 as! CKRecordValue }) as CKRecordValue
    }}
  public static func from(recordValue: CKRecordValue) -> Set<Element> {
    if let a = recordValue as? Array<Element> {
      return Set<Element>(a)
    }
    fatalError("Set from CKRecordValue not yet implemented")
  }
}

public class RecordEncoder : Encoder {
  // public var record: CKRecord
  // public var subRecords : [ String : CKRecord ] = [:]
  
  public var record : CKRecord // was PCRecord
  public var zoneID : CKRecordZoneID

  public var codingPath: [CodingKey] { return [] }
  public var userInfo: [CodingUserInfoKey : Any] { return [:] }
  
  public init(_ s : String, _ n : String, _ zid : CKRecordZoneID) {
    zoneID = zid
    // record = PCRecord(p: CKRecord.init(recordType: s, recordID: CKRecordID.init(recordName: n, zoneID: zid)), cs: [])
    record = CKRecord.init(recordType: s, recordID: CKRecordID.init(recordName: n, zoneID: zid))
  }
  
  public init(_ m : DataModel, _ zid : CKRecordZoneID) {
    zoneID = zid
    var pr : CKRecord
    if let esf = m.encodedSystemFields {
    // set up the CKRecord with its metadata
      let coder = NSKeyedUnarchiver(forReadingWith: esf)
      coder.requiresSecureCoding = true
      pr = CKRecord(coder: coder)!
      coder.finishDecoding()
    } else {
      pr = CKRecord.init(recordType: type(of: m).name, recordID: CKRecordID.init(recordName: m.getKey(), zoneID: zid ))
    }
    record = pr // PCRecord(p: pr, cs: [])
  }
  
  /*public init(record: inout CKRecord) {
    self.zoneID = record.recordID.zoneID
    self.record = PCRecord(p: record, cs: [])
  }*/

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
    
    
    func encode<T: RawRepresentable>(_ valv: T, forKey key: Key) throws  where T.RawValue : Encodable {
      try encode(valv.rawValue, forKey: key)
    }

/* encoded system fields?
 self.recordID = record.recordID
 self.recordType = record.recordType
 self.creationDate = record.creationDate ?? Date()
 self.creatorUserRecordID = record.creatorUserRecordID
 self.modificationDate = record.modificationDate ?? Date()
 self.lastModifiedUserRecordID = record.lastModifiedUserRecordID
 self.recordChangeTag = record.recordChangeTag
*/
    func encode<T>(_ valu: T, forKey key: Key) throws where T : Encodable {
      if key.stringValue == "encodedSystemFields" {
        return // this has been taken care of when it was initialized
      }
      if let v = valu as? CKRecordValuable {
        encoder.record[key.stringValue] = v.recordValue
      } else if let v = valu as? CKRecordValue {
        encoder.record[key.stringValue] = v
      } else {
        print("failed to encode \(valu) for \(key.stringValue)")
      }
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

