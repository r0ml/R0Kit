// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import CoreImage

extension CIImage {
  public var cgImage : CGImage? { get {
    return CIContext(options:nil).createCGImage(self, from: self.extent)
  }
  }

  public var pngData : Data? {
    get {
      return CIContext().pngRepresentation(of: self, format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.extendedSRGB)!, options: [:])
    }
  }

  public var tiffData : Data? {
    get {
      return CIContext().tiffRepresentation(of: self, format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.extendedSRGB)!, options: [:])
    }
  }
}

