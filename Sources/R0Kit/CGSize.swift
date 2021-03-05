// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import CoreGraphics

extension CGSize {
  public var flipped : CGSize {
    return CGSize(width: self.height, height: self.width)
  }

  public static func *(left: CGSize, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.width * right.x, y: left.height * right.y)
  }

  public static func /(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width / right.width, height: left.height / right.height)
  }

}
