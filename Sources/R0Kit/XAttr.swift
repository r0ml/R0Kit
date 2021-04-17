// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation

/** Support for reading and writing extended file attribures */
public class XAttr {
  private var url : URL

  public init(_ u : URL) {
    url = u
  }

  /** Get extended file attribute.
      Usage will look like:
    <code> try? XAttr(fileurl).get(forName: "xattrname") </code>
   It might throw a PosixError
   */
  func get(forName name: String) throws -> Data  {
    return try url.withUnsafeFileSystemRepresentation { fileSystemPath -> Data in
      let length = getxattr(fileSystemPath, name, nil, 0, 0, 0)  // Determine attribute size:
      guard length >= 0 else { throw POSIXError.status(errno) }
      var data = Data(count: length)
      let result =  data.withUnsafeMutableBytes { [count = data.count] in
        getxattr(fileSystemPath, name, $0.baseAddress, count, 0, 0)
      }
      guard result >= 0 else { throw POSIXError.status(errno) }
      return data
    }
  }

  /** Write extended file attribute
   Usage will look like:
   <code> try? XAttr(fileurl).set(data: data, forName: "xattrname") </code>
   It might throw a PosixError
   */
  func set(data: Data, forName name: String) throws {
    try url.withUnsafeFileSystemRepresentation { fileSystemPath in
      let result = data.withUnsafeBytes {
        setxattr(fileSystemPath, name, $0.baseAddress, data.count, 0, 0)
      }
      guard result >= 0 else { throw POSIXError.status(errno) }
    }
  }

  /** Delete extended file attribute */
  func remove(forName name: String) throws {
    try url.withUnsafeFileSystemRepresentation { fileSystemPath in
      let result = removexattr(fileSystemPath, name, 0)
      guard result >= 0 else { throw POSIXError.status(errno) }
    }
  }

  /** List extended file attributes */
  func list() throws -> [String] {
    return try url.withUnsafeFileSystemRepresentation { fileSystemPath -> [String] in
      let length = listxattr(fileSystemPath, nil, 0, 0)
      guard length >= 0 else { throw POSIXError.status(errno) }

      // Create buffer with required size:
      var namebuf = Array<CChar>(repeating: 0, count: length)
      let result = listxattr(fileSystemPath, &namebuf, namebuf.count, 0)
      guard result >= 0 else { throw POSIXError.status(errno) }

      // Extract attribute names:
      let list = namebuf.split(separator: 0).compactMap {
        $0.withUnsafeBufferPointer {
          $0.withMemoryRebound(to: UInt8.self) {
            String(bytes: $0, encoding: .utf8)
          }
        }
      }
      return list
    }
  }
}

/** Error type for XAttr functions */
enum POSIXError : LocalizedError {
  case status(_ errno : Int32)

  public var errorDescription : String? {
    switch self {
    case .status(errno: let errno):
      return String(cString: strerror(errno))
    }
  }
}
