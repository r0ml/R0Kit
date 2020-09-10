// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

#if os(macOS)
import AppKit
import CoreGraphics

extension NSImage {
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

  // Create an NSImage from a CIImage
  convenience init(im : CIImage) {
    let rep = NSCIImageRep(ciImage: im)
    self.init(size: rep.size)
    self.addRepresentation(rep)
  }

}
#endif
