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
      /*case is Int.Type:
      let c = record[record.index(record.startIndex, offsetBy: cursor)]
      cursor+=2
      return Int(String(c)) as! T

    case is String.Type:
      let c = record[record.index(record.startIndex, offsetBy: cursor)..<record.endIndex]
      cursor = record.count
      return String(c) as! T */
    default:    return try T.init(from: self)
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
  
  func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
    // return try decoder.decode(T.self)
    let v = decoder.record[key.stringValue]
    if type is Recordable.Type {
      return (type as! Recordable.Type).from(recordValue: v!) as! T
    } else if let z = v as? T {
      return z
    } else {
      throw DataModelError("nil value for \(key)")
    }
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
