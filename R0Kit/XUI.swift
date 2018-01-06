
import CommonCrypto

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
#endif
  
extension Encodable {
  public func encode(with encoder: JSONEncoder = JSONEncoder()) -> Data? {
    return try? encoder.encode(self)
  }
}

extension Decodable {
  public static func decode(with decoder: JSONDecoder = JSONDecoder(), from data: Data?) -> Self? {
    return data.flatMap { try? decoder.decode(Self.self, from: $0) }
  }
}

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

extension Data {
  public func md5() -> Data {
    var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
    let _ = self.withUnsafeBytes { bytes in
      CC_MD5(bytes, CC_LONG(self.count), &digest)
    }
    return Data(bytes: digest)
  }
}

extension Color {
  public convenience init(hex: UInt32) {
    let f = { (x:UInt32,y:Int) in CGFloat( (x >> y) & 0xff) / 255.0 }
    self.init(red: f(hex, 16) , green: f(hex, 8), blue: f(hex, 0), alpha: 1)
  }
}

extension CGPoint {
  public static func +(a:CGPoint, b:CGPoint) -> CGPoint {
    return CGPoint(x: a.x+b.x, y: a.y+b.y)
  }
}

extension Notification.Name {
  public static let statusUpdate = Notification.Name(rawValue: "statusUpdate" )
  public static let errorReport = Notification.Name(rawValue: "errorReport" )
}

extension Notification {
  public static func statusUpdate(_ m : String) {
    os_log("%@", type: .info, m)
    let noti = Notification( name: .statusUpdate, object: nil, userInfo: ["msg":m])
    NotificationCenter.default.post(noti)
  }
  
  public static func errorReport(_ m : String, _ err : Error?) {
    if let e = err {
      os_log("%@: %@", type: .error, m, e.localizedDescription)
      var mmm = e.localizedDescription
      if let ee = e as? CKError {
        if let mm = ee.userInfo["NSUnderlyingError"] as? NSError {
          mmm = mm.localizedDescription
        }
        
      }
      let noti = Notification( name: .errorReport, object: nil, userInfo: ["msg":m, "err": mmm])
      NotificationCenter.default.post(noti)
    }
  }
  public static func errorReport(_ m : String, _ e : String) {
    let noti = Notification( name: .errorReport, object: nil, userInfo: ["msg":m, "err": e])
    NotificationCenter.default.post(noti)
  }
  
  public static func registerStatus(_ tf : Label) {
    NotificationCenter.default.addObserver(forName: Notification.Name.statusUpdate, object: nil, queue: nil) { noti in
      DispatchQueue.main.async {
        tf.textColor = Color.gray
        tf.text = noti.userInfo?["msg"] as? String }
    }
  }
  
  public static func registerError(_ tf : Label) {
    NotificationCenter.default.addObserver(forName: Notification.Name.errorReport, object: nil, queue: nil) { noti in
      DispatchQueue.main.async {
        tf.textColor = Color.red
        tf.text = "\(noti.userInfo?["msg"] as? String ?? "") error: \(noti.userInfo?["err"] as? String ?? "unknown")"
      }
    }
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

extension View {
  public func onPressGesture( _ n : Int, _ t : TimeInterval, _ fn: @escaping(AnyObject?) -> Void) {
    let x = ClosX(fn)
    let z = PressGestureRecognizer(target: x, action: x.selector)
    z.minimumPressDuration = t
      #if os(macOS)
        z.buttonMask = n
      #endif
    
    self.addGestureRecognizer(z)
 }
}

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

extension View {
  public func onGesture<T : GestureRecognizer>(param : @escaping ((T) -> Void) = { (_ : T) in }, _ fn : @escaping (T) -> Void) {
    let x = ClosX( {
      if let d = $0 as? T { fn(d) }
    })
    let m = T(target: x, action: x.selector)
    param(m)
    self.addGestureRecognizer( m )
  }
}

// ====================================================================================================
// Layout
// ====================================================================================================

extension View {
  public func stacker(vertical : Bool = false) -> Stacker { return Stacker(self, vertical: vertical) }
}

infix operator ~ : AdditionPrecedence

public enum Stackable {
  case bottom
  case trailing
  case pad(CGFloat)
  case view(View)
}

/* This is a helper class which lets me create horizontal or vertical stacks of views
 using constraints */
public class Stacker {
  let view : View
  var prev : View? = nil
  var pad : CGFloat = 0
  var cntr : Bool = false
  var vert : Bool
  var ins : CGFloat = 5
  
  init(_ v : View, vertical : Bool) { view = v; vert = vertical }
  
  @discardableResult public func pad(_ p : CGFloat) -> Stacker {
    pad = p
    return self
  }
  
  @discardableResult public func center() -> Stacker {
    cntr = true
    return self
  }
  
  @discardableResult public func inset(_ i : CGFloat) -> Stacker {
    ins = i
    cntr = false
    return self
  }
  
  @discardableResult public func views(_ v : [View]) -> Stacker {
    v.forEach { self.view($0) }
    return self
  }
  
  @discardableResult public func view(_ v : View) -> Stacker {
    view.addSubview(v)
    v.translatesAutoresizingMaskIntoConstraints = false
    if let p = prev {
      if vert {
        v.topAnchor.constraint(equalTo: p.bottomAnchor, constant: pad).isActive = true
      } else {
        v.leadingAnchor.constraint(equalTo: p.trailingAnchor, constant: pad).isActive = true
      }
    } else {
      if vert {
        v.topAnchor.constraint(equalTo: view.topAnchor, constant: pad).isActive = true
      } else {
        v.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad).isActive = true
      }
    }
    if vert {
      if cntr {
        v.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
      } else {
        v.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ins).isActive = true
        v.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -2 * ins).isActive = true
      }
    } else {
      if cntr {
        v.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
      } else {
        v.topAnchor.constraint(equalTo: view.topAnchor, constant: ins).isActive = true
        v.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -2 * ins).isActive = true
      }
    }
    prev = v
    return self
  }
  
  public func end() {
      // greaterThanOrEqualTo ?
    let p = prev == nil ? view : prev!
    if vert {
       //  p.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -pad).isActive = true
      p.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -pad).isActive = true
    } else {
       //  p.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -pad).isActive = true
      p.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad).isActive = true
    }
    prev = nil
    pad = 0
    ins = 5
    cntr = false
  }
}

#if os(macOS)

  extension NSStackView {
      public convenience init( arrangedSubviews vs: [View]) {
          self.init(views: vs)
      }

      public var axis : NSUserInterfaceLayoutOrientation { get { return self.orientation }
          set { self.orientation = newValue }
      }
  
    }

  extension CollectionView {
      public func performBatchUpdates(_ updates: (() -> Void)?,
                                      completion: ((Bool) -> Void)? = nil) {
        self.performBatchUpdates(updates, completionHandler: completion)
    }
  }

#endif

public class HideableView<T : View> : View {
  public let innerView : T
  public init(_ view : T) {
    self.innerView = view
    super.init(frame: CGRect.zero)
    innerView.addInto(self)
  }
  
  public required init(coder: NSCoder) {
    fatalError("not implemented yet")
  }
  
  public var makeHidden : Bool { get {
      print("ask is hidden")
      return innerView.isHidden
    }
    set {
      if newValue {
        innerView.isHidden = true
        innerView.removeFromSuperview()
        let cc = self.constraints.filter { if let j = $0.secondItem as? View, j == self { return true } else { return false }}
        self.removeConstraints(cc)
      } else {
        innerView.isHidden = false
        innerView.addInto(self)
      }
    }
  }
  
}

