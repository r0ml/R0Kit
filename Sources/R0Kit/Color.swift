// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

extension Color {
  public init(hex: UInt32) {
    let f = { (x:UInt32,y:Int) -> CGFloat in CGFloat( (x >> y) & 0xff) / 255.0 }
    self.init(CGColor(red: f(hex, 16) , green: f(hex, 8), blue: f(hex, 0), alpha: 1 ))
  }
}
