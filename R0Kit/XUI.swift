
import CommonCrypto

#if os(iOS)
  public class XR : NSObject {
    var fn : (()->Void)? = nil
    var fng : ((UIGestureRecognizer) -> Void)? = nil
    public init(_ fn : @escaping ()->Void) { self.fn = fn }
    public init(gesture fn : @escaping (UIGestureRecognizer) -> Void) { self.fng = fn }
    @objc public func goFilter(_ x : AnyObject?) {
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

public class X : NSObject {
  let fn : (()->Void)
  public init(_ fn : @escaping ()->Void) { self.fn = fn }
  @objc public func goFilter(_ x : AnyObject?) {
    fn()
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
      let aa = UIApplicationOpenSettingsURLString
      // let aa = "app-settings"
      if let appSettings = URL(string: aa) {
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
    print("not ok")
    
  }
#endif



#if os(macOS)
  public class CollectionViewFlowLayout : NSCollectionViewFlowLayout {
    public override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
      return true
    }
  }
#elseif os(iOS)
  public class CollectionViewFlowLayout : UICollectionViewFlowLayout {
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
      return true
    }
}
#endif

