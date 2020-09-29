// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

#if canImport(AppKit)

import AppKit
import CoreGraphics

extension NSImage {
/*
 func stroke(normalizedPath : CGPath, color : CGColor, lineWidth: CGFloat) {
    self.lockFocus()
    var p3 = CGAffineTransform(scaleX: self.size.width, y: self.size.height)
    let p2 = normalizedPath.copy(using: &p3)!
    let cx = NSGraphicsContext.current!.cgContext
    cx.setStrokeColor(color)
    cx.setLineWidth(lineWidth)
    cx.addPath(p2)
    cx.strokePath()
    self.unlockFocus()
  }
*/

  // Create an NSImage from a CIImage
  public convenience init(ciImage im : CIImage) {
    let rep = NSCIImageRep(ciImage: im)
    self.init(size: rep.size)
    self.addRepresentation(rep)
  }

  // I would have preferred a variable, but this matches the UIImage implementation
  public func pngData() -> Data? {
    guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
    let newRep = NSBitmapImageRep(cgImage: cgImage)
    newRep.size = self.size
    guard let pngd = newRep.representation(using: .png, properties: [:]) else { return nil }
    return pngd
  }

  public var ciImage : CIImage?  {
    if let imageData = tiffRepresentation {
      return CIImage(data: imageData)
    }
    return nil
  }

}

#endif
