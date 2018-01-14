

#if os(iOS)
  @_exported import UIKit
  
  public typealias Responder = UIResponder
  public typealias Image = UIImage
  public typealias Color = UIColor
  public typealias ImageView = UIImageView
  public typealias View = UIView
  public typealias BezierPath = UIBezierPath
  public typealias Font = UIFont
  
  public typealias Event = UIEvent
  
  public typealias EdgeInsets = UIEdgeInsets
  public typealias LayoutGuide = UILayoutGuide
  public typealias ScrollView = UIScrollView
  
  public typealias TextField = UITextField
  public typealias TextView = UITextView
  public typealias TextViewDelegate = UITextViewDelegate
  
  public typealias TableView = UITableView
  public typealias TableViewDelegate = UITableViewDelegate
  public typealias TableViewDataSource = UITableViewDataSource
  
  public typealias GestureRecognizer = UIGestureRecognizer
  
  public typealias ClickGestureRecognizer = UITapGestureRecognizer
  public typealias PressGestureRecognizer = UILongPressGestureRecognizer
  
#elseif os(macOS)
  @_exported import AppKit
  
  public typealias Responder = NSResponder
  public typealias Image = NSImage
  public typealias Color = NSColor
  public typealias ImageView = NSImageView
  public typealias View = NSView
  public typealias BezierPath = NSBezierPath
  public typealias Font = NSFont
  
  public typealias Event = NSEvent
  
  public typealias EdgeInsets = NSEdgeInsets
  public typealias LayoutGuide = NSLayoutGuide
  public typealias ScrollView = NSScrollView
  
  public typealias TextField = NSTextField
  // public typealias TextView = NSTextView
  public typealias TextViewDelegate = NSTextViewDelegate
  
  public typealias TableView = NSTableView
  public typealias TableViewDelegate = NSTableViewDelegate
  public typealias TableViewDataSource = NSTableViewDataSource
  
  public typealias GestureRecognizer = NSGestureRecognizer
  public typealias ClickGestureRecognizer = NSClickGestureRecognizer
  public typealias PressGestureRecognizer = NSPressGestureRecognizer
  
#endif

#if os(iOS)
  
  public typealias TapGestureRecognizer = UITapGestureRecognizer
  public typealias SwipeGestureRecognizer = UISwipeGestureRecognizer
  public typealias PanGestureRecognizer = UISwipeGestureRecognizer
  public typealias RotationGestureRecognizer = UIRotationGestureRecognizer
  public typealias ZoomGestureRecognizer = UIPinchGestureRecognizer
  
#elseif os(macOS)
  
  public typealias TapGestureRecognizer = NSClickGestureRecognizer
  public typealias SwipeGestureRecognizer = NSPanGestureRecognizer
  public typealias PanGestureRecognizer = NSPanGestureRecognizer
  public typealias RotationGestureRecognizer = NSRotationGestureRecognizer
  public typealias ZoomGestureRecognizer = NSMagnificationGestureRecognizer
  
#endif

// =============================== UIDevice ==================================
#if os(iOS)
  extension UIDevice {
    /** This can be used to determine if this code is running in the simulator
     It is an alternative to #ifdef'ing simulator specific code */
    #if (arch(i386) || arch(x86_64))
    public static let isSimulator = true
    #else
    public static let isSimulator = false
    #endif
  }
  
#elseif os(macOS)
  /** This can be used to determine if this code is running in the simulator
   It is an alternative to #ifdef'ing simulator specific code */
  public class UIDevice {
    public static let isSimulator: Bool = false
  }
#endif

// ============================= Label ===================================

#if os(iOS)
  public typealias Label = UILabel
  
#elseif os(macOS)
  /** A subclass of TextField to create a read-only text control.
      This is meant to be identical to UILabel */
  open class Label : TextField {
    required override public init(frame: CGRect) {
      super.init(frame: frame)
      self.isEditable = false
      self.isBordered = false
      self.setTransparentBackground()
    }
    
    /** This is not implemented and should not be used */
    public required init?(coder: NSCoder) {
      super.init(coder: coder)
    }
    
    /** Match the name (maximumNumberOfLines) to iOS */
    public var numberOfLines : Int {
      get { return maximumNumberOfLines }
      set { maximumNumberOfLines = newValue }
    }
    
    /** Match the name (alignment) to iOS */
    public var textAlignment : NSTextAlignment {
      get { return alignment }
      set { alignment = newValue }
    }
  }
  
  extension NSControl {
  }
  
  open class TextView : NSTextView {
    public var userInteractionEnabled : Bool = true
    
    override open func becomeFirstResponder() -> Bool {
      return userInteractionEnabled
    }
  }

#endif

// ============================= ImageView ===============================

#if os(iOS)
  public extension ImageView {
    /** scale the image while maintaing aspect ratio */
    public func scaleMe() {
      self.contentMode = .scaleAspectFit
    }
  }

#elseif os(macOS)
  
  public extension ImageView {
    /** scale the image while retaining aspect ratio */
    public func scaleMe() {
      self.imageScaling = .scaleProportionallyUpOrDown
    }
  }
  
#endif

// ============================= UIControl ===============================

// FIXME:  The use case of this is ifdef'd.  Move the ifdef in here.
#if os(iOS)
  extension UIControl {
    public func addTarget( for forevent: UIControlEvents, _ fn: @escaping (AnyObject?)->Void ) -> Void {
      let x = ClosX(fn)
      addTarget(x, action: x.selector, for: forevent)
    }
  }
#endif

// =============================

#if os(iOS)
  public class XR : NSObject {
    var fn : (()->Void)? = nil
    var fng : ((UIGestureRecognizer) -> Void)? = nil
    public init(_ fn : @escaping ()->Void) { self.fn = fn }
    public init(gesture fn : @escaping (UIGestureRecognizer) -> Void) { self.fng = fn }
    @objc public func method(_ x : AnyObject?) {
      fn?()
    }
    @objc public func goGesture(_ x : AnyObject?) {
      fng?(x as! UIGestureRecognizer)
    }
  }
  
  extension UITextView {
    open var myTextContainer: NSTextContainer {
      get { return self.textContainer }
    }
  }
  
  extension UIBarButtonItem {
    public convenience init(title: String, _ fn : @escaping (AnyObject?) -> Void) {
      let t = ClosX(fn)
      self.init(title: title, style: .plain, target: t, action: t.selector)
    }
    
    public convenience init(image: UIImage?, style: UIBarButtonItemStyle, _ fn : @escaping (() -> Void)) {
        let x = ClosX({ _ in fn() } )
        self.init(image: image, style: style, target: x, action: x.selector)
      }

    public convenience init(title: String?, style: UIBarButtonItemStyle, _ fn : @escaping (() -> Void)) {
        let x = ClosX( { _ in fn() } )
        self.init(title: title, style: style, target: x, action: x.selector)
      }
    
  }
  
  public class Button : UIButton {
    // public var draggable : Draggable.Type?
    public func setAttributedTitle(_ str : NSAttributedString) {
      self.setAttributedTitle(str, for: .normal)
    }
  }
  
  public protocol  Draggable : AnyObject {
    //  static func doDrop(_ pb : NSPasteboard) -> Bool
    //  static var types : [NSPasteboard.PasteboardType] {
    //    get
    //  }
  }
  
  
  public extension UIImage {
    public var pngData: Data? {
      return UIImagePNGRepresentation(self)
    }
    
    public static func from(bundle: Bundle, named: String) -> UIImage? {
      return Image.init(named: named, in: bundle, compatibleWith: nil)
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
    open var myLayer: CALayer {
      get { return self.layer }
    }
    
    open var needsDisplay : Bool {
      get { return false }
      set { self.setNeedsDisplay() }
    }
    
    open func setTransparentBackground() {
      self.backgroundColor = Color.clear
    }
  }
  
  open class ViewController : UIViewController {
    public required init() {
      super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
#endif
  

public class ClosX : NSObject {
  // I need to hang on to the objs to keep them for the ObjC machinery.
  // Swift can't tell that they must not be garbage collected
  static var objs = [ClosX]()
  let fn : ((AnyObject?)->Void)
  public var selector : Selector { return #selector(ClosX.method(_:)) }
  public init(_ fn : @escaping (AnyObject?)->Void) { self.fn = fn; super.init(); ClosX.objs.append(self) }
  @objc public func method(_ x : AnyObject?) {
    fn(x)
  }
}

extension GestureRecognizer {
  public convenience init(_ fn : @escaping ((AnyObject?) -> Void)) {
    let x = ClosX(fn)
    self.init(target: x, action: x.selector)
  }
}

// -----------------------------------------------------------------------------

#if os(iOS)
  public func raiseAlert(title: String, message: String, window: UIWindow? = nil, _ fn : @escaping () -> ()) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
      // let aa = UIApplicationOpenSettingsURLString
      // let aa = "app-settings"
     // if let appSettings = URL(string: "App-Prefs:root=General") {
      if let appSettings = URL(string: "App-Prefs:root=ACCOUNT_SETTINGS") {
        // "\(aa):root=Safari") {
        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
      }
      fn() }))
    // dq.signal()
    DispatchQueue.main.async {
      let window = UIWindow(frame: UIScreen.main.bounds)
      window.rootViewController = UIViewController()
      window.makeKeyAndVisible()
      window.rootViewController!.present(alert, animated: true, completion: nil )
      // dq.signal()
    }
  }
  
#elseif os(macOS)
  public func raiseAlert(title: String, message: String, window: NSWindow, _ fn : @escaping () -> ()) {
    let alert = NSAlert()
    alert.messageText = title
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    alert.informativeText = message
    
    DispatchQueue.main.async {
      alert.beginSheetModal(for: window, completionHandler: { (returnCode) -> Void in
        if returnCode == NSApplication.ModalResponse.alertFirstButtonReturn {
          print("ok")
        } else if returnCode == NSApplication.ModalResponse.alertSecondButtonReturn {
          Application.shared.terminate(Application.shared)
        }
        fn()
      })
      print("ok")
    }
    print("done")
  }
  
  extension NSMenuItem {
    public static func new(withTitle: String, keyEquivalent: String, _ fn: @escaping (AnyObject?) -> Void) -> NSMenuItem {
      let x = ClosX(fn)
      let nmi = NSMenuItem(title: withTitle, action: x.selector, keyEquivalent: keyEquivalent)
      nmi.target = x
      return nmi
    }
  }
  
  extension NSView {
    
    open var myLayer: CALayer {
      get { self.wantsLayer = true; return self.layer! }
      set { self.layer = newValue }
    }
    
    public var backgroundColor : NSColor? {
      get { if let cg = self.layer?.backgroundColor { return NSColor(cgColor: cg) } else { return nil } }
      set { self.wantsLayer = true;  self.layer?.backgroundColor = newValue?.cgColor }
    }
    
    public var isOpaque : Bool {
      get { return self.layer?.isOpaque == true }
      set { self.wantsLayer = true; self.layer?.isOpaque = newValue }
    }
    
    public func setNeedsLayout() {
      self.needsLayout = true
    }
    
    public var alpha : CGFloat {
      get { return self.alphaValue }
      set { self.alphaValue = newValue }
    }
    
    /* public func setTransparentBackground() {
     // self.drawsBackground = false
     self.backgroundColor = Color.clear
     }*/

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
    
    public var attributedText : NSAttributedString? {
      get {
        return self.attributedStringValue
      }
      set {
        self.attributedStringValue = newValue ?? NSAttributedString()
      }
    }
  }
  
  extension NSTextView {
    public var text : String {
      get {
        return self.string
      }
      set {
        self.string = newValue
      }
    }
    
    open var myTextContainer: NSTextContainer {
      get { return self.textContainer! }
      set { self.textContainer = newValue }
    }
    
    public var textAlignment : NSTextAlignment {
      get { return alignment }
      set { alignment = newValue }
    }
    
    public var attributedText : NSAttributedString {
      get { return self.textStorage ?? NSAttributedString(string: "") }
      set { self.textStorage?.setAttributedString( newValue ) }
    }
  }
  
  // FIXME: This only exists for Transcript.
  // Change Transcript to use CollectionView -- then this won't be needed
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
  
  open class ViewController : NSViewController {
    open func viewWillLayoutSubviews() {
      self.viewWillLayout()
    }
    
    public required init() {
      super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
  
  
  extension ScrollView {
    public var showsVerticalScrollIndicator : Bool {
      get { return hasVerticalScroller }
      set { hasVerticalScroller = newValue }
    }
    public var showsHorizontalScrollIndicator : Bool {
      get { return hasHorizontalScroller }
      set { hasHorizontalScroller = newValue }
    }
    
    public var contentInset : NSEdgeInsets {
      get { return self.contentInsets }
    }
  }
  
  extension TextField {
    public func setTransparentBackground() {
      self.drawsBackground = false
    }
  }
  
  extension TextView {
    public func setTransparentBackground() {
      self.drawsBackground = false
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
    
    public func setAttributedTitle(_ str : NSAttributedString) {
      self.attributedTitle = str
    }
  }
  
  public extension NSImage {
    public convenience init?(named: String) {
      self.init(named: NSImage.Name(rawValue: named))
    }
    
    public static func from(bundle: Bundle, named: String) -> NSImage? {
      return bundle.image(forResource: NSImage.Name.init(rawValue: named))
    }
    
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
  
#endif

#if os(macOS)
  
  extension NSBezierPath {
    public func addArc(withCenter: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool = false) {
      let sa = clockwise ? endAngle : startAngle
      let ea = clockwise ? startAngle : endAngle
      self.appendArc(withCenter: withCenter, radius : radius, startAngle: sa, endAngle: ea)
    }
    
    public func addLine(to: CGPoint) {
      self.line(to: to)
    }
    
    public func addCurve(to: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
      self.curve(to: to, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
    
    public var usesEvenOddFillRule : Bool {
      get { return self.windingRule == .evenOddWindingRule }
      set { self.windingRule = newValue ? .evenOddWindingRule : .nonZeroWindingRule }
    }
  }
  
  extension NSBezierPath.LineCapStyle {
    public static let round = roundLineCapStyle
  }
  
  extension NSBezierPath.LineJoinStyle {
    public static let bevel = bevelLineJoinStyle
    public static let round = roundLineJoinStyle
  }
  
  public extension NSBezierPath {
    public var cgPath: CGPath {
      let path = CGMutablePath()
      var points = [CGPoint](repeating: .zero, count: 3)
      for i in 0 ..< self.elementCount {
        let type = self.element(at: i, associatedPoints: &points)
        switch type {
        case .moveToBezierPathElement: path.move(to: CGPoint(x: points[0].x, y: points[0].y) )
        case .lineToBezierPathElement: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y) )
        case .curveToBezierPathElement: path.addCurve(      to: CGPoint(x: points[2].x, y: points[2].y),
                                                            control1: CGPoint(x: points[0].x, y: points[0].y),
                                                            control2: CGPoint(x: points[1].x, y: points[1].y) )
        case .closePathBezierPathElement: path.closeSubpath()
        }
      }
      return path
    }
  }
  
  public func UIGraphicsGetCurrentContext() -> CGContext? {
    return NSGraphicsContext.current?.cgContext
/*      context.saveGState()
      
      let tne = context.convertToUserSpace(CGSize(width: 1, height: 1))
      context.scaleBy(x: tne.width, y : tne.height )
      let tnx = context.convertToUserSpace(CGPoint(x: 0, y: 0))
      context.translateBy(x: tnx.x, y: tnx.y )
      return context
    } else {
      return nil
    }
 */
  }
  
  public func makeImage(_ sz : CGSize, _ fn : @escaping (CGSize)->Void) -> Image? {
    if let bitmapRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(sz.width), pixelsHigh: Int(sz.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0) {
      if let gc = NSGraphicsContext.init(bitmapImageRep: bitmapRep) {
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = gc
         let context = gc.cgContext
        let tne = context.convertToUserSpace(CGSize(width: 1, height: 1))
        context.scaleBy(x: tne.width, y : tne.height )
        let tnx = context.convertToUserSpace(CGPoint(x: 0, y: 0))
        context.translateBy(x: tnx.x, y: tnx.y )

        // context.scaleBy(x: rect.size.width / CGFloat(context.width), y: rect.size.height / CGFloat(context.height) )
        // let bb = gc.cgContext.boundingBoxOfClipPath
        
        fn(sz)
        NSGraphicsContext.restoreGraphicsState()
        
        let im = Image(size: sz)
        im.addRepresentation(bitmapRep)
        return im
      }
    }
    return nil
  }
  
#endif

#if os(iOS)

  public func makeImage(_ sz: CGSize, _ fn: @escaping (CGSize) -> Void) -> Image? {
    UIGraphicsBeginImageContextWithOptions(sz, false, 2.0)
    fn(sz)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
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
