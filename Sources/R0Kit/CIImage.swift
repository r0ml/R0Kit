// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import CoreImage

fileprivate let ctx : CIContext = CIContext(options: nil)

extension CIImage {
  public var asCGImage : CGImage? { get {
    return ctx.createCGImage(self, from: self.extent)
  }
  }

  public var pngData : Data? {
    get {
      return ctx.pngRepresentation(of: self, format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.extendedSRGB)!, options: [:])
    }
  }

  public var tiffData : Data? {
    get {
      return ctx.tiffRepresentation(of: self, format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.extendedSRGB)!, options: [:])
    }
  }
}

