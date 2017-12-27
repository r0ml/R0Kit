
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


#if false
extension UIView {
  /*func onTapGesture(_ fn : @escaping () -> Void) {
    let x = ClosX(fn)
    self.addGestureRecognizer( UITapGestureRecognizer(target: x, action: x.selector ) )
  }*/
  func onTapGesture(_ fn : @escaping (UITapGestureRecognizer) -> Void) {
    let x = Unmanaged.passRetained(XR(gesture: { z in fn(z as! UITapGestureRecognizer) } )).takeUnretainedValue()
    self.addGestureRecognizer( UITapGestureRecognizer(target: x, action: #selector(XR.goGesture(_:)) ) )
  }
  
  func onSwipeGesture(_ dir : UISwipeGestureRecognizerDirection, _ fn : @escaping(UISwipeGestureRecognizer) -> Void) {
    let x = Unmanaged.passRetained(XR(gesture: { z in fn(z as! UISwipeGestureRecognizer) } )).takeUnretainedValue()
    let swipeRight = UISwipeGestureRecognizer(target: x, action: #selector(XR.goGesture(_:)) )
    swipeRight.direction = dir
    self.addGestureRecognizer(swipeRight)
  }
  
  func onRotationGesture(_ fn : @escaping(UIRotationGestureRecognizer) -> Void) {
    let x = Unmanaged.passRetained(XR(gesture: { z in fn(z as! UIRotationGestureRecognizer) } )).takeUnretainedValue()
    let swipeRot = UIRotationGestureRecognizer(target: x, action: #selector(XR.goGesture(_:)) )
    self.addGestureRecognizer(swipeRot)
  }
  
}

#endif

// ====================================================================================================
// Layout
// ====================================================================================================

extension View {
  public func stacker(vertical : Bool = false) -> Stacker { return Stacker(self, vertical: vertical) }
  
  /*public func stack(_ s : Stackable ...) {
    let sx = Stacker(self)
    s.forEach { sx ~ $0 }
  }*/
}

infix operator ~ : AdditionPrecedence

public enum Stackable {
  case bottom
  case trailing
  case pad(CGFloat)
  case view(View)
}

public class Stacker {
  let view : View
  var prev : View? = nil
  var pad : CGFloat = 0
  var cntr : Bool = false
  var vert : Bool
  var ins : CGFloat = 5
  
/* var subvs = [View]()
   var pads = [CGFloat]()
 */
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
        p.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -pad).isActive = true
    } else {
        p.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad).isActive = true
    }
    prev = nil
    pad = 0
    ins = 5
    cntr = false
  }
}

/*
@discardableResult public func ~(lhs: Stacker, rhs: Stackable ) -> Stacker {
    switch rhs {
    case .view(let v): // the view gets added as a subview.  The leading (left) anchor then gets pinned to "the last thing" -- which is initially the superview
      // there could be a "pending pad" -- in which case it is applied.
      // unfortunately, at this moment, there is no way of knowing if the final application is going to be a trailing or a bottom.
      // the other option is to then accumulate all views and pads until the final one.
      // under accumulation, the pads and views alternate (or get skipped).
      // if the previous append was a pad, the view gets appended.
      // if the previous append was not a pad, a zero pad gets appended, then the view.
      if lhs.subvs.count == lhs.pads.count {
        lhs.pads.append(0)
      }
      lhs.subvs.append(v)
    case .pad(let p):  // pend the pad.  If there is a pending pad, this pad gets added to it
      if lhs.pads.count == lhs.subvs.count {
        lhs.pads.append(p)
      } else {
        lhs.pads[lhs.pads.count-1]=lhs.pads[lhs.pads.count-1]+p
      }
    case .trailing: // This is the end of the line -- resolve the subviews by generating horizontal constraints
      if lhs.pads.count == lhs.subvs.count {
        lhs.pads.append(0)
      }
      if lhs.subvs.count > 0 {
        lhs.view.addSubview(lhs.subvs[0])
        lhs.subvs[0].leadingAnchor.constraint(equalTo: lhs.view.leadingAnchor, constant: lhs.pads[0]).isActive = true
        for i in 1..<lhs.subvs.count {
          lhs.view.addSubview(lhs.subvs[i])
          lhs.subvs[i].leadingAnchor.constraint(equalTo: lhs.subvs[i-1].trailingAnchor, constant: lhs.pads[i]).isActive = true
        }
        // greaterThanOrEqualTo ?
        lhs.subvs[lhs.subvs.count-1].trailingAnchor.constraint(equalTo: lhs.view.trailingAnchor, constant: -lhs.pads[lhs.subvs.count]).isActive = true
      } else {
        lhs.view.leadingAnchor.constraint(equalTo: lhs.view.trailingAnchor, constant: -lhs.pads[0]).isActive = true
      }
      lhs.subvs.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
      lhs.subvs.forEach { $0.heightAnchor.constraint(equalTo: lhs.view.heightAnchor).isActive = true }
      lhs.subvs.forEach { $0.topAnchor.constraint(equalTo: lhs.view.topAnchor).isActive = true }
      lhs.subvs = []
      lhs.pads = []
    case .bottom:  // This is the end of the line -- resolve the subviews by generating vertical constraints
      if lhs.pads.count == lhs.subvs.count {
        lhs.pads.append(0)
      }
      if lhs.subvs.count > 0 {
        lhs.view.addSubview(lhs.subvs[0])
        lhs.subvs[0].topAnchor.constraint(equalTo: lhs.view.topAnchor, constant: lhs.pads[0]).isActive = true
        for i in 1..<lhs.subvs.count {
          lhs.view.addSubview(lhs.subvs[i])
          lhs.subvs[i].topAnchor.constraint(equalTo: lhs.subvs[i-1].bottomAnchor, constant: lhs.pads[i]).isActive = true
        }
        // greaterThanOrEqualTo ?
        lhs.subvs[lhs.subvs.count-1].bottomAnchor.constraint(equalTo: lhs.view.bottomAnchor, constant: -lhs.pads[lhs.subvs.count]).isActive = true
      } else {
        lhs.view.topAnchor.constraint(equalTo: lhs.view.bottomAnchor, constant: -lhs.pads[0]).isActive = true
      }
      lhs.subvs.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
      lhs.subvs.forEach { $0.widthAnchor.constraint(equalTo: lhs.view.widthAnchor).isActive = true }
      lhs.subvs.forEach { $0.leadingAnchor.constraint(equalTo: lhs.view.leadingAnchor).isActive = true }
      lhs.subvs = []
      lhs.pads = []
    }
    return lhs
  }
*/

