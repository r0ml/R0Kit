
// Definitions to make iOS and macOS closer than they are.  This allows for more code sharing

@_exported import CloudKit
@_exported import os.log
import Foundation

#if os(iOS)
  @_exported import UIKit
  import UserNotifications
  
  public typealias Responder = UIResponder
  public typealias Image = UIImage
  public typealias Color = UIColor
  public typealias ImageView = UIImageView
  public typealias View = UIView
  public typealias BezierPath = UIBezierPath
  public typealias Font = UIFont
  public typealias TextField = UITextField
  public typealias TableView = UITableView
  public typealias TableViewDelegate = UITableViewDelegate
  public typealias TableViewDataSource = UITableViewDataSource

  public typealias CollectionView = UICollectionView
  public typealias CollectionViewDelegate = UICollectionViewDelegate
  public typealias CollectionViewDataSource = UICollectionViewDataSource
  public typealias CollectionViewItem = UICollectionViewCell
  public typealias CollectionViewDelegateFlowLayout = UICollectionViewDelegateFlowLayout
  
  public typealias Application = UIApplication
  public typealias ApplicationDelegate = UIApplicationDelegate
  
  public typealias UserNotificationCenter = UNUserNotificationCenter
  public typealias UserNotificationCenterDelegate = UNUserNotificationCenterDelegate
  
#elseif os(macOS)
  @_exported import AppKit
  
  public typealias Responder = NSResponder
  public typealias Image = NSImage
  public typealias Color = NSColor
  public typealias ImageView = NSImageView
  public typealias View = NSView
  public typealias BezierPath = NSBezierPath
  public typealias Font = NSFont
  public typealias TextField = NSTextField
  public typealias TableView = NSTableView
  public typealias TableViewDelegate = NSTableViewDelegate
  public typealias TableViewDataSource = NSTableViewDataSource
  
  public typealias CollectionView = NSCollectionView
  public typealias CollectionViewDelegate = NSCollectionViewDelegate
  public typealias CollectionViewDataSource = NSCollectionViewDataSource
  public typealias CollectionViewItem = NSCollectionViewItem
  public typealias CollectionViewDelegateFlowLayout = NSCollectionViewDelegateFlowLayout
  
  public typealias Application = NSApplication
  public typealias ApplicationDelegate = NSApplicationDelegate
  
  public typealias UserNotificationCenter = NSUserNotificationCenter
  public typealias UserNotificationCenterDelegate = NSUserNotificationCenterDelegate

#endif

// ------------------------------------------------------------------------------
#if os(iOS)
  extension UserNotificationCenter {
    public static var `default` : UserNotificationCenter {
      get {
        return UserNotificationCenter.current()
      }
    }
  }
  
  
  public typealias Label = UILabel

  
  
  public class Button : UIButton {
    // public var draggable : Draggable.Type?
  }

  public protocol Draggable : AnyObject {
  //  static func doDrop(_ pb : NSPasteboard) -> Bool
  //  static var types : [NSPasteboard.PasteboardType] {
  //    get
  //  }
  }

  public extension UIImage {
    public var pngData: Data? {
      return UIImagePNGRepresentation(self)
    }
    
    func scaledTo(_ newSize:CGSize? = nil) -> Image {
      if let newSize = newSize {
        let ow = self.size.width
        let oh = self.size.height
        let nw = newSize.width == 0 ? ow : newSize.width
        let nh = newSize.height == 0 ? oh : newSize.height
        
        let sf = min(1, min(nw/ow, nh/oh))
        
        let cw = sf * ow
        let ch = sf * oh
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: cw, height: ch), false, 0.0);
        self.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: cw, height: ch)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
      } else {
        return self
      }
    }
    
    func flipped() -> Image {
      return Image.init(cgImage: self.cgImage!, scale: 1.0, orientation: UIImageOrientation.upMirrored)
    }
  }
  
  extension View {
    var xlayer : CALayer { return self.layer }
  }
  
  /*
  extension TextField {
    public var stringValue : String {
      get {
        return self.text ?? ""
      }
      set {
        self.text = stringValue
      }
    }
  }
 */
  extension UIControl {
    public func addTarget( for forevent: UIControlEvents, _ fn: @escaping ()->Void ) -> Void {
      let x = Unmanaged.passRetained(X(fn))
      addTarget(x.takeUnretainedValue(), action: #selector(X.goFilter(_:)), for: forevent)
    }
  }
  
#elseif os(macOS)
  
  // public typealias IndexPath = NSIndexPath
  
  extension NSMenuItem {
    public static func new(withTitle: String, keyEquivalent: String, _ fn: @escaping () -> Void) -> NSMenuItem {
      let nmi = NSMenuItem(title: withTitle, action: #selector(X.goFilter(_:)), keyEquivalent: keyEquivalent)
      let x = Unmanaged.passRetained(X(fn))
      nmi.target = x.takeUnretainedValue()
      return nmi
    }
  }
  
  extension NSApplication {
    public func registerForRemoteNotifications() {
      self.registerForRemoteNotifications(matching: [.badge, .alert, .sound])
    }
  }
  
  open class Label : TextField {
    required override public init(frame: CGRect) {
      super.init(frame: frame)
      self.isEditable = false
    }
    
    public required init?(coder: NSCoder) {
      super.init(coder: coder)
    }
    
    open override func calcSize() {
      super.calcSize()
    }
    
    public var numberOfLines : Int {
      get { return maximumNumberOfLines }
      set { maximumNumberOfLines = newValue }
    }
    
    public var attributedText : NSAttributedString {
      get { return attributedStringValue }
      set { attributedStringValue = newValue }
    }
    
    public var textAlignment : NSTextAlignment {
      get { return alignment }
      set { alignment = newValue }
    }
    // What I really want is for my superclass (e.g. VStack) to ignore my desired size, and force
    // the label to remain fixed-size
    open override var intrinsicContentSize: NSSize {
      get {
        let d = super.intrinsicContentSize
        return NSSize(width: min(d.width, 600), height: d.height)
      }
    }
  }
  public protocol Draggable : AnyObject /*, NSPasteboardReading */ {
    static func doDrop(_ pb : NSPasteboard) -> Bool
    static var types : [NSPasteboard.PasteboardType] {
      get
    }
  }

  public class Button : NSButton {
    public var draggable : Draggable.Type?
  }
  
  public extension NSImage {
    public var pngData: Data? {
      guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
      return bitmapImage.representation(using: .png, properties: [:])
    }
    
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
      do {
        try pngData?.write(to: url, options: options)
        return true
      } catch {
        os_log("pngWrite: %@", error.localizedDescription)
        return false
      }
    }
    
    func scaledTo(_ newSize:CGSize? = nil) -> Image {
      if let newSize = newSize {
        let ow = self.size.width
        let oh = self.size.height
        let nw = newSize.width == 0 ? ow : newSize.width
        let nh = newSize.height == 0 ? oh : newSize.height
        
        let sf = min(1, min(nw/ow, nh/oh))
        
        let cw = sf * ow
        let ch = sf * oh
        
        if let bitmapRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(cw), pixelsHigh: Int(ch), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0) {
          bitmapRep.size = newSize
          NSGraphicsContext.saveGraphicsState()
          NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
          self.draw(in: NSRect(x: 0, y: 0, width: cw, height: ch), from: NSZeroRect, operation: .copy, fraction: 1.0)
          NSGraphicsContext.restoreGraphicsState()
          
          let resizedImage = NSImage(size: newSize)
          resizedImage.addRepresentation(bitmapRep)
          return resizedImage
        } else {
          return self
        }
      } else {
        return self
      }
    }
    
    func flipped() -> Image {
      let transform = NSAffineTransform()
      let dimensions = self.size
      let flip = NSAffineTransformStruct(m11: -1.0, m12: 0.0, m21: 0.0, m22: 1.0, tX: dimensions.width, tY: 0.0)
      let tmpImage = NSImage.init(size: self.size)
      tmpImage.lockFocus()
      transform.transformStruct = flip
      transform.concat()
      self.draw(at: NSMakePoint(0,0),
                from: NSMakeRect(0,0, dimensions.width, dimensions.height),
                operation: .copy,
                fraction:1.0)
      tmpImage.unlockFocus()
      return tmpImage
    }
    
  }
  
  extension View {
    var xlayer : CALayer { return self.layer! }
  }
  
  extension TextField {
    public var text : String? {
      get {
        return self.stringValue
      }
      set {
        self.stringValue = newValue ?? ""
      }
    }
  }
  
  /*   extension View {
   var layoutMarginsGuide : NSLayoutGuide {
   get {
   return self.layoutGuides.first ?? NSLayoutGuide() }
   }
   } */
  
  extension TableView {
    
    // this presumes that there is no "section" in the table
    public func deleteRows(at: [IndexPath], with: TableView.AnimationOptions) {
      var z = IndexSet()
      at.forEach { z.insert($0.item ) }
      return removeRows(at: z, withAnimation: with)
    }
    
    // this presumes that there is no "section" in the table
    public func insertRows(at: [IndexPath], with: TableView.AnimationOptions) {
      var z = IndexSet()
      at.forEach { z.insert($0.item ) }
      return insertRows(at: z, withAnimation: with)
    }

  }
  
  extension Font {
    public static func italicSystemFont(ofSize : CGFloat) -> Font {
      return Font.systemFont(ofSize: ofSize)
    }
  }
  
#endif


extension Image {
  func saveToDisk() -> URL {
    var fileURL = FileManager.default.temporaryDirectory
    let filename = UUID().uuidString
    fileURL.appendPathComponent(filename)
    let data = self.pngData!
    try! data.write(to: fileURL)
    return fileURL
  }
  
  public func displayOn(_ v : ImageView, direction: String? = nil, reflect: Bool) {
    DispatchQueue.main.async {
      var z = self.scaledTo(v.bounds.size)
      // bottom and top are reversed
      if let d = direction { v.slideIn(direction: d)  } // left, right bottom
      if reflect { z = z.flipped()
        // Image.init(cgImage: z.cgImage!, scale: 1.0, orientation: UIImageOrientation.upMirrored)
      }
      // v.transform = CGAffineTransform(scaleX: -1, y: 1) }
      v.image = z
      // v.setNeedsDisplay()
    }
  }
  
}

extension View {
  
  // Name this function in a way that makes sense to you...
  // slideFromLeft, slideRight, slideLeftToRight, etc. are great alternative names
  func slideIn(duration: TimeInterval = 1.0, direction: String
    /*, completionDelegate: AnyObject? = nil */) {
    // Create a CATransition animation
    let slideInFromLeftTransition = CATransition()
    
    // Set its callback delegate to the completionDelegate that was provided (if any)
    /*  if let delegate: AnyObject = completionDelegate {
     slideInFromLeftTransition.delegate = delegate as! CAAnimationDelegate
     } */
    
    // Customize the animation's properties
    slideInFromLeftTransition.type = kCATransitionPush
    slideInFromLeftTransition.subtype = direction
    slideInFromLeftTransition.duration = duration
    slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    slideInFromLeftTransition.fillMode = kCAFillModeRemoved
    
    // Add the animation to the View's layer
    self.xlayer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
  }
}

extension CKAsset {
  public convenience init(data: Data) {
    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try! data.write(to: fileURL)
    self.init(fileURL: fileURL)
  }
  
  public convenience init(image: Image, size: CGSize? = nil) {
    let fileURL = image.scaledTo(size).saveToDisk()
    self.init(fileURL: fileURL)
  }
  
  public var image: Image? {
    return self.data?.image
  }
  
  public var data : Data? {
    return try? Data(contentsOf: fileURL)
  }
}

extension Data {
  public var image: Image? {
    return Image(data: self)
  }
}


public class VStack : View {
  public convenience init(_ vs : [View], space sep: CGFloat ) {
    self.init(frame: .zero)
    vs.forEach {
      // $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
      // $0.setContentHuggingPriority(.defaultLow, for: .vertical)
      // $0.setContentCompressionResistancePriority( .defaultHigh, for: .vertical)
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.addInto(self, with: [.leading, .trailing]) }
    if vs.isEmpty { return }
    var nc = [NSLayoutConstraint]()
    nc.append(vs[0].topAnchor.constraint(equalTo: self.topAnchor, constant: sep/2.0))
    nc.append(vs[vs.count-1].bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -sep/2.0))
    (0..<vs.count-1).forEach {
      nc.append(vs[$0].bottomAnchor.constraint(equalTo: vs[$0+1].topAnchor, constant: -sep))
    }
    NSLayoutConstraint.activate(nc)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public class HStack : View {
  public convenience init(_ vs : [View], space sep: CGFloat ) {
    self.init(frame: .zero)
    vs.forEach {
      $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
      $0.setContentHuggingPriority(.defaultLow, for: .vertical)
      // $0.setContentCompressionResistancePriority( .defaultHigh, for: .vertical)
      // $0.setContentCompressionResistancePriority( .defaultHigh, for: .horizontal)
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.addInto(self, with: [.top, .bottom]) }
    if vs.isEmpty { return }
    var nc = [NSLayoutConstraint]()
    nc.append(vs[0].leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: sep/2.0))
    nc.append(vs[vs.count-1].trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -sep/2.0))
    (0..<vs.count-1).forEach {
      nc.append(vs[$0].trailingAnchor.constraint(equalTo: vs[$0+1].leadingAnchor, constant: -sep))
    }
    NSLayoutConstraint.activate(nc)
  }
  
  override init(frame: CGRect) { super.init(frame: frame) }
  public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension View {
  public func addInto(_ view: View, with: [Constraint] =
    [.top, .bottom, .leading, .trailing]) {
    let z = self.superview == nil ? self : self.superview!
    view.addSubview(z)
    z.fitInto(view, with: with)
  }
  
  public func fitInto(_ view: View, with: [Constraint] = [.top, .bottom, .leading, .trailing]) {
    var cs = Array<NSLayoutConstraint>()
    self.translatesAutoresizingMaskIntoConstraints = false
    with.forEach {
      switch $0 {
      case .top: cs.append(self.topAnchor.constraint(equalTo: view.topAnchor))
      case .bottom: cs.append(self.bottomAnchor.constraint(equalTo: view.bottomAnchor))
      case .leading: cs.append(self.leadingAnchor.constraint(equalTo: view.leadingAnchor))
      case .trailing: cs.append(self.trailingAnchor.constraint(equalTo: view.trailingAnchor))
      case .width: cs.append(self.widthAnchor.constraint(equalTo: view.widthAnchor))
      case .height: cs.append(self.heightAnchor.constraint(equalTo: view.heightAnchor))
      case .centerX: cs.append(self.centerXAnchor.constraint(equalTo: view.centerXAnchor))
      case .centerY: cs.append(self.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        
        /*   case .topMargin: cs.append(self.topAnchor.constraint(equalTo:
         view.layoutMarginsGuide.topAnchor))
         case .bottomMargin: cs.append(self.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor))
         case .leadingMargin: cs.append(self.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor))
         case .trailingMargin: cs.append(self.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor))
         case .widthWithMargins: cs.append(self.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor))
         case .heightWithMargins: cs.append(self.heightAnchor.constraint(equalTo: view.layoutMarginsGuide.heightAnchor))
         case .centerXWithMargins: cs.append(self.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor))
         case .centerYWithMargins: cs.append(self.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor))
         */
        
      case .widthMinus(let z): cs.append(self.widthAnchor.constraint(equalTo: view.widthAnchor,  constant: -z))
      case .heightMinus(let z): cs.append(self.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -z))

      case .topPad(let z): cs.append(self.topAnchor.constraint(equalTo: view.topAnchor, constant: z))
      case .bottomPad(let z): cs.append(self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: z))
      case .leadingPad(let z): cs.append(self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: z))
      case .trailingPad(let z): cs.append(self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: z))
      case .centerXPad(let z): cs.append(self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: z))
      case .centerYPad(let z): cs.append(self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: z))
      }
    }
    NSLayoutConstraint.activate( cs )
  }
}

extension View {
  @discardableResult public func withPadding(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> View {
    let v = View()
    // v.accessibilityIdentifier = "padding"
    // v.layoutMargins = ins
    self.translatesAutoresizingMaskIntoConstraints = false
    v.addSubview(self)
    NSLayoutConstraint.activate([
      self.topAnchor.constraint(equalTo: v.topAnchor, constant:  top),
      self.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant:  -bottom),
      self.leftAnchor.constraint(equalTo: v.leftAnchor, constant:  left),
      self.rightAnchor.constraint(equalTo: v.rightAnchor, constant:  -right),
      ])
    //    self.addInto(v)
    return v
  }
}


public enum Constraint {
  case top
  case bottom
  case leading
  case trailing
  case width
  case height
  case centerX
  case centerY
  /*   case topMargin
   case bottomMargin
   case leadingMargin
   case trailingMargin
   case widthWithMargins
   case heightWithMargins
   case centerXWithMargins
   case centerYWithMargins
   */
  case widthMinus(CGFloat)
  case heightMinus(CGFloat)
  case topPad(CGFloat)
  case bottomPad(CGFloat)
  case leadingPad(CGFloat)
  case trailingPad(CGFloat)
  case centerXPad(CGFloat)
  case centerYPad(CGFloat)
  static var all : [ Constraint ] {
    get { return [.top, .bottom, .leading, .trailing] }
  }
}

public var session = URLSession(configuration: config ) //  (withIdentifier: "downloader"))

public var config : URLSessionConfiguration {
  let a = URLSessionConfiguration.default
  a.allowsCellularAccess = false
  a.httpMaximumConnectionsPerHost = 4
  a.httpShouldUsePipelining = true
  a.timeoutIntervalForRequest = 1.0
  return a
}

public var semaphore : DispatchSemaphore = DispatchSemaphore(value: 4)


