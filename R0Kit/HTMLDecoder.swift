//
//  Copyright © 2017 Semasiology. All rights reserved.
//

// FIXME:  This hasn't been implemented yet

#if os(macOS)
public class HTMLDecoder : Decoder {
  let htmlDoc : XMLDocument
  
  public var codingPath: [CodingKey] { return [] }
  public var userInfo: [CodingUserInfoKey : Any] { return [:] }
  
  public init?(_ s : String) {
    do {
      self.htmlDoc = try XMLDocument(xmlString: s, options: XMLNode.Options.documentTidyHTML )
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
  
  func decode<T: Decodable>(_ type: T.Type) throws -> T {
    switch type {
    default: return try T.init(from: self)
    }
  }
  
  public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
    return KeyedDecodingContainer(HTMLKeyedContainer<Key>(decoder: self))
  }
  
  public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    return HTMLUnkeyedDecodingContainer(decoder: self)
  }
  
  public func singleValueContainer() throws -> SingleValueDecodingContainer {
    return HTMLUnkeyedDecodingContainer(decoder: self)
  }
}

fileprivate struct HTMLKeyedContainer<Key : CodingKey> : KeyedDecodingContainerProtocol {
  var decoder : HTMLDecoder
  var codingPath: [CodingKey] { return [] }
  var allKeys: [Key] { return [] }
  
  func contains(_ key: Key) -> Bool {
    return true
  }
  
  func decodeNil(forKey key: Key) throws -> Bool {
    // FIXME: figure out what to do here
    return false
  }
  
  func decode<T>(_ typ: T.Type, forKey key: Key) throws -> T where T : Decodable {
    // FIXME: figure out what to do here
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

fileprivate struct HTMLUnkeyedDecodingContainer : UnkeyedDecodingContainer, SingleValueDecodingContainer {
  var decoder : HTMLDecoder
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
#endif

