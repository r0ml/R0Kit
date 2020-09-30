// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import os

fileprivate let log = Logger()

// useful when a TextOutputStream needs to be conditionally disabled
public class LoggingOutputStream : TextOutputStream {
  var debugging : Bool

  public init(_ d : Bool) {
    debugging = d
  }

  public func write(_ string : String) {
    if debugging { log.debug("\(string)") }
  }
}
