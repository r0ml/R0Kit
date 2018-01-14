
// Definitions to make iOS and macOS closer than they are.  This allows for more code sharing

@_exported import CloudKit
@_exported import os.log
import Foundation
import CommonCrypto

#if os(iOS)
  import UserNotifications
  
  public typealias Application = UIApplication
  public typealias ApplicationDelegate = UIApplicationDelegate
  
  public typealias UserNotificationCenter = UNUserNotificationCenter
  public typealias UserNotificationCenterDelegate = UNUserNotificationCenterDelegate

#elseif os(macOS)
  
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
  

#elseif os(macOS)
  
  // public typealias IndexPath = NSIndexPath
 
  extension IndexPath {
     public var row : Int { get { return self.item } }

     public init(row: Int, section: Int) {
       self.init(item: row, section: section)
     }
  }
 
  extension NSApplication {
    public func registerForRemoteNotifications() {
      self.registerForRemoteNotifications(matching: [.badge, .alert, .sound])
    }
  }
  

 
#endif


extension String {
  public func contains(_ find: String) -> Bool{
    return find.count == 0 || self.range(of: find) != nil
  }
  
  public func containsIgnoringCase(_ find: String) -> Bool{
    return find.count == 0 || self.range(of: find, options: .caseInsensitive) != nil
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

public var session = URLSession(configuration: config ) //  (withIdentifier: "downloader"))

public var config : URLSessionConfiguration {
  let a = URLSessionConfiguration.default
  a.allowsCellularAccess = false
  a.httpMaximumConnectionsPerHost = 4
  a.httpShouldUsePipelining = true
  a.timeoutIntervalForRequest = 1.0
  return a
}


extension Date {
  public static func from(_ s : String, format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.date(from: s)
  }
}

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

extension Data {
  public func md5() -> Data {
    var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
    let _ = self.withUnsafeBytes { bytes in
      CC_MD5(bytes, CC_LONG(self.count), &digest)
    }
    return Data(bytes: digest)
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
