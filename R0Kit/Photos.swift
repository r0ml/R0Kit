
#if os(macOS)
  // in iOS I would use Photos, but in macos apparently it is Media Library

  import MediaLibrary
  
  private struct MLMediaLibraryPropertyKeys {
    static let mediaSourcesKey = "mediaSources"
    static let rootMediaGroupKey = "rootMediaGroup"
    static let mediaObjectsKey = "mediaObjects"
    static let contentTypeKey = "contentType"
  }

  public class PhotoAlbum : NSObject {
    var library : MLMediaLibrary!
    var mediaSource : MLMediaSource!
    var rootMediaGroup : MLMediaGroup!
    var swatchGroup : MLMediaGroup!
    let album : String
    var _images : [String:Image]?
    let ready = DispatchSemaphore(value: 0)
    
    public init(album : String) {
      self.album = album
      let options: [String : AnyObject] =
        [MLMediaLoadSourceTypesKey: MLMediaSourceType.image.rawValue as AnyObject,
         MLMediaLoadIncludeSourcesKey: [MLMediaSourcePhotosIdentifier, MLMediaSourceiPhotoIdentifier] as AnyObject]
      
      library = MLMediaLibrary(options: options)
      super.init()

      library.addObserver(self, forKeyPath: MLMediaLibraryPropertyKeys.mediaSourcesKey, options: NSKeyValueObservingOptions.new, context: nil)
      if let z = library.mediaSources {}
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      
      if keyPath == MLMediaLibraryPropertyKeys.mediaSourcesKey {
        if let mediaSources = library.mediaSources {
          self.mediaSource = mediaSources["com.apple.Photos"] ?? mediaSources["com.apple.iPhoto"]
        }
        self.mediaSource.addObserver(self, forKeyPath: MLMediaLibraryPropertyKeys.rootMediaGroupKey,
                                     options: NSKeyValueObservingOptions.new, context: nil)
        if let _ = self.mediaSource.rootMediaGroup {}
      } else if keyPath == MLMediaLibraryPropertyKeys.rootMediaGroupKey {
        self.mediaSource.removeObserver(self, forKeyPath: MLMediaLibraryPropertyKeys.rootMediaGroupKey)
        self.rootMediaGroup = self.mediaSource.rootMediaGroup
        if let cg = self.mediaSource.mediaGroup(forIdentifier: "TopLevelAlbums") {
          swatchGroup = cg.childGroups!.filter { $0.typeIdentifier == "com.apple.Photos.Album" && $0.name == self.album }.first
        }
        self.swatchGroup.addObserver(self, forKeyPath: MLMediaLibraryPropertyKeys.mediaObjectsKey, context: nil)
        if let mo = self.swatchGroup.mediaObjects { }
      } else if keyPath == MLMediaLibraryPropertyKeys.mediaObjectsKey {
        self.swatchGroup.removeObserver(self, forKeyPath: MLMediaLibraryPropertyKeys.mediaObjectsKey)
        // self.rootMediaGroup.removeObserver(self, forKeyPath: MLMediaLibraryPropertyKeys.mediaObjectsKey)
        if let mediaObjects = self.swatchGroup.mediaObjects {
          _images = [:]
          mediaObjects.forEach { if let z = $0.artworkImage, let y = $0.name { _images![y] = z } }
         // for mo in mediaObjects {
         //   print(mo.name, mo.attributes, mo.modificationDate, mo.originalURL)
         // }
          ready.signal()
        }
      }
    }
    
    var images : [String:Image] {
      get {
        if let i = _images { return i }
        else {
          ready.wait()
          return _images ?? [:]
        }
      }
    }
    
    deinit {
      // Make sure to remove us as an observer before "mediaLibrary" is released.
      library.removeObserver(self, forKeyPath: MLMediaLibraryPropertyKeys.mediaSourcesKey)
    }
  }
  
#elseif os(iOS)
  import Photos

#endif


// something about EXIF storage
/*
 if let ir : CGImageSource = CGImageSourceCreateWithData(imgdat as CFData, nil),
 let uti = CGImageSourceGetType(ir),
 let dest : CGImageDestination = CGImageDestinationCreateWithData(dwx as CFMutableData, uti, 1, nil) {
 
 let techniqueAdd = true
 if techniqueAdd {
 let ip = CGImageSourceCopyPropertiesAtIndex(ir, 0, nil)! as NSDictionary
 let mip = ip.mutableCopy() as! NSMutableDictionary
 mip[kCGImageDestinationLossyCompressionQuality] = 0.9
 
 let exif = mip[kCGImagePropertyExifDictionary] as? NSMutableDictionary ?? NSMutableDictionary()
 exif[kCGImagePropertyExifUserComment] = xcmnt
 exif[kCGImagePropertyExifCameraOwnerName] = "Robert M. Lefkowitz" as NSString
 mip[kCGImagePropertyExifDictionary] = exif
 
 let iptc = mip[kCGImagePropertyIPTCDictionary] as? NSMutableDictionary ?? NSMutableDictionary()
 iptc[kCGImagePropertyIPTCCopyrightNotice] = "Copyright r0ml" as NSString
 mip[kCGImagePropertyIPTCDictionary] = iptc
 CGImageDestinationAddImageFromSource(dest, ir, 0, mip as CFDictionary )
 #if false
 CGImageDestinationAddImageFromSource(destcombo!, ir, 0, mip as CFDictionary)
 #endif
 CGImageDestinationFinalize(dest)
 } else {
 let mdx = CGImageSourceCopyMetadataAtIndex(ir, 0, nil)!
 let mmm = CGImageMetadataCreateMutableCopy(mdx)!
 CGImageMetadataSetValueMatchingImageProperty(mmm,
 kCGImagePropertyExifDictionary, kCGImagePropertyExifUserComment, xcmnt)
 CGImageMetadataSetValueMatchingImageProperty(mmm,
 kCGImagePropertyIPTCDictionary, kCGImagePropertyIPTCCopyrightNotice, "Copyright (c) r0ml" as NSString)
 let mz = NSMutableDictionary()
 mz[kCGImageDestinationMergeMetadata] = 1
 mz[kCGImageDestinationMetadata] = mmm
 
 var err : Unmanaged<CFError>? = nil
 CGImageDestinationCopyImageSource(dest, ir, mz, &err)
 print( err?.takeUnretainedValue() )
 // at this point, dwx is the data to be written
 }
 } */




