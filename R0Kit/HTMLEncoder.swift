//
//  Copyright © 2017 Semasiology. All rights reserved.
//

// This is used to represent a hierarchy of parent-child records as the result of a decoding
// in theory, this allows writing the whole tree up to iCloud.
// perhaps I could have a "base" containing multiple types to represent the entire nested
// structure, rather than a separate "base" for each record type.

// I could represet the entire zone by an object -- and have each record type in the zone.

public extension RawRepresentable where Self : HTMLable, RawValue : CustomStringConvertible {
  public var htmlValue : String { return String(describing: self.rawValue) }
  public static func from(htmlValue: String) -> Self {
    return Self.init(rawValue: htmlValue as! RawValue)!
  }
}

public protocol HTMLable {
  var htmlValue : String { get }
  static func from(htmlValue: String) -> Self
}

/*extension Set : HTMLable {
  public var recordValue : CKRecordValue { get {
    return (self.map { $0 as! CKRecordValue }) as CKRecordValue
    }}
  public static func from(recordValue: CKRecordValue) -> Set<Element> {
    if let a = recordValue as? Array<Element> {
      return Set<Element>(a)
    }
    fatalError("Set from CKRecordValue not yet implemented")
  }
}*/

public class HTMLEncoder : Encoder {
  public var html : String
  public var codingPath: [CodingKey] { return [] }
  public var userInfo: [CodingUserInfoKey : Any] { return [:] }
  
  public init() {
    html = ""
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
    return HTMLUnkeyedContainer(encoder: self)
  }
  
  public func singleValueContainer() -> SingleValueEncodingContainer {
    return HTMLUnkeyedContainer(encoder: self)
  }
  
  private struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    var encoder: HTMLEncoder
    var codingPath: [CodingKey] { return [] }
    
    func encode<T: RawRepresentable>(_ valv: T, forKey key: Key) throws  where T.RawValue : Encodable {
      try encode(valv.rawValue, forKey: key)
    }
    
    
    func encode<T>(_ valu: T, forKey key: Key) throws where T : Encodable {

      /*
 '&' => "&amp;"
 '"' => "&quot;"
 '\'' => "&#39;"
 '>' => "&gt;"
 '<' => "&lt;"
 */
      if key.stringValue == "encodedSystemFields" { return }
      
      
      if let v = valu as? LosslessStringConvertible {
        // encoder.html.append("<td>\(key.stringValue)</td><td>\(String(describing: v))</td>")
        encoder.html.append("<td>\(String(describing: v))</td>")
      } else if let v = valu as? Array<LosslessStringConvertible> {
        let j = v.map { "<td>\(String(describing: $0))</td>" }
        let k = j.joined()
        // let m = "<td><table><tr>\(k)</tr></table></td>"
        let m = k // .appending("<td></td>")
        encoder.html.append(m)
      } else if let v = valu as? CustomStringConvertible {
        encoder.html.append("<td>\(String(describing: v))</td>")
      } else if let v = valu as?  HTMLable {
        encoder.html.append("<td>\(v.htmlValue)</td>")
      } else if let v = valu as? LocalAsset {
        encoder.html.append("<td>\(v.url.absoluteString)</td>")
      } else {
        print("failed to html encode \(valu) for \(key.stringValue)")
      }
    }
    
    func encodeNil(forKey key: Key) throws {
      encoder.html.append("<td></td>")
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
  
  private struct HTMLUnkeyedContainer: UnkeyedEncodingContainer, SingleValueEncodingContainer {
    var encoder: HTMLEncoder
    
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


