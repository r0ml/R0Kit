//
//  Copyright © 2017 Semasiology. All rights reserved.
//

public class RecordDecoder : Decoder {
  let record : CKRecord

  public var codingPath: [CodingKey] { return [] }
  public var userInfo: [CodingUserInfoKey : Any] { return [:] }

  public init(_ s : CKRecord) {
    self.record = s
  }
  
  func decode<T: Decodable>(_ type: T.Type) throws -> T {
    switch type {
    default: return try T.init(from: self)
    }
  }
  
  public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
    return KeyedDecodingContainer(RecordKeyedContainer<Key>(decoder: self))
  }
  
  public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    return RecordUnkeyedDecodingContainer(decoder: self)
  }
  
  public func singleValueContainer() throws -> SingleValueDecodingContainer {
    return RecordUnkeyedDecodingContainer(decoder: self)
  }
}

public class DataModelError : Error {
  var msg : String
  init(_ m : String) {
    msg = m
  }
  
  var localizedDescription : String { get {
    return msg
    }
  }
}

fileprivate struct RecordKeyedContainer<Key : CodingKey> : KeyedDecodingContainerProtocol {
  var decoder : RecordDecoder
  var codingPath: [CodingKey] { return [] }
  var allKeys: [Key] { return [] }
  
  func contains(_ key: Key) -> Bool {
    return true
  }
  
  func decodeNil(forKey key: Key) throws -> Bool {
    let v = decoder.record[key.stringValue]
    return v == nil
  }
  
  func decode<T>(_ typ: T.Type, forKey key: Key) throws -> T where T : Decodable {
    // return try decoder.decode(T.self)
    
    // if the field I'm being asked to decode is an array of DataModel -- then this is the parent, and those are the children.
    // so here, the parent will be childless
    // print(typ)
    
    if let v = decoder.record[key.stringValue] {
      if typ is CKRecordValuable.Type {
        return (typ as! CKRecordValuable.Type).from(recordValue: v) as! T
      } else if let z = v as? T {
        return z
      } else if typ == LocalAsset.self, let z = v as? CKAsset {
        // let filename = ProcessInfo.processInfo.globallyUniqueString
        // FIXME:  I might also need ownerName from zone
        let tempdir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(decoder.record.recordID.zoneID.zoneName).appendingPathComponent(decoder.record.recordType).appendingPathComponent(key.stringValue)
        // FIXME: create a directory for this zone?
        do {
          try FileManager.default.createDirectory(atPath: tempdir.path, withIntermediateDirectories: true, attributes: nil)
          let tempurl = tempdir.appendingPathComponent(decoder.record.recordID.recordName)
          let d = try Data(contentsOf: z.fileURL)
          try d.write(to: tempurl, options: .atomicWrite)
          return LocalAsset(tempurl) as! T
        } catch {
          print("trying to save asset: ", error.localizedDescription)
        }
      }
    }
    throw DataModelError("nil value for \(key)")
  }
  
  func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
    return try decoder.container(keyedBy: type)
  }
  
  func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
    return try decoder.unkeyedContainer()
  }
  
  func superDecoder() throws -> Decoder {
    return decoder
  }
  
  func superDecoder(forKey key: Key) throws -> Decoder {
    return decoder
  }
}

fileprivate struct RecordUnkeyedDecodingContainer : UnkeyedDecodingContainer, SingleValueDecodingContainer {
  var decoder : RecordDecoder
  var codingPath: [CodingKey] { return [] }
  var count: Int? { return nil }
  
  var isAtEnd: Bool {
    // return decoder.cursor >= decoder.record.count
    return true
  }
  
  var currentIndex: Int { return 0 }
  
  func decodeNil() -> Bool {
    return true
  }
  
  func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
    return try decoder.decode(type)
  }
  
  func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
    return try decoder.container(keyedBy: type)
  }
  
  func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
    return self
  }
  
  func superDecoder() throws -> Decoder {
    return decoder
  }
}
