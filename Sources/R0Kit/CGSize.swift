// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import CoreGraphics

extension CGSize {
  public var flipped : CGSize {
    return CGSize(width: self.height, height: self.width)
  }
  
  public func asPoint() -> CGPoint {
    return CGPoint(x: width, y: height)
  }
}

extension CGSize : AdditiveArithmetic {

  // Arithmetic with CGSize and CGSize
  public static func /(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width / right.width, height: left.height / right.height)
  }

  public static func *(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width * right.width, height: left.height * right.height)
  }
  public static func +(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
  }
  public static func -(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
  }

  // -----------------------------------------------------------
  // Arithmetic with CGSize and CGPoint
  public static func *(left: CGSize, right: CGPoint) -> CGSize {
    return CGSize(width: left.width * right.x, height: left.height * right.y)
  }

  public static func /(left: CGSize, right: CGPoint) -> CGSize {
    return CGSize(width: left.width / right.x, height: left.height / right.y)
  }

  public static func -(left: CGSize, right: CGPoint) -> CGSize {
    return CGSize(width: left.width - right.x, height: left.height - right.y)
  }

  public static func +(left: CGSize, right: CGPoint) -> CGSize {
    return CGSize(width: left.width + right.x, height: left.height + right.y)
  }
  
  // --------------------------------------------------------------
  // Arithmetic with CGSize and CGFloat
  public static func *(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
  }

  public static func /(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width / right, height: left.height / right)
  }

  public static func -(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width - right, height: left.height - right)
  }

  public static func +(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width + right, height: left.height + right)
  }


}
