
import CloudKit

public class DataCache<T : DataModel> : NSObject {
  var _singleton : [String : T] = [:]
  public var rootID: CKRecordID!
  
  public func findShare(_ dbx : CKDatabase, _ zonid : CKRecordZoneID) {
    if let _ = rootID { return }
    if let z = UserDefaults.standard.data(forKey: "RootRecord") {
      // This value will be nil if it is not the machine that originally created the RootRecord
      // If it is nil, then I must retrieve the Root Record from CloudKit
      // If I am the owner, it will exist
      rootID = NSKeyedUnarchiver.unarchiveObject(with: z) as? CKRecordID
      if let _ = rootID { return }
    }
    
    var recid : CKRecordID?
    let sem = DispatchSemaphore(value: 0)
    
    // FIXME:  Do I really want to delete all shares?
    // deletes all existing shares
    let query = CKQuery(recordType: "RootRecord", predicate: NSPredicate(value: true))
    // query.sortDescriptors = [NSSortDescriptor(key: "___modTime", ascending: false)] // latest time first
    
    dbx.perform(query, inZoneWith: zonid) { (records, error) in
      Notification.errorReport("finding root records failed", error)
      if let recs = records, recs.count > 0 {
        recid = recs[0].recordID
      }
      sem.signal()
    }
    sem.wait()
    if let recid = recid {
      let zz = NSKeyedArchiver.archivedData(withRootObject: recid)
      os_log("root recordId %@", type: .info, recid)
      UserDefaults.standard.set( zz , forKey: "RootRecord")
      UserDefaults.standard.synchronize()
      rootID = recid
      return
    }
    return
  }
  
  // these are used to schedule a save one second in the future.
  // this allows for multiple updates without saving after each one.
  let myQ = DispatchQueue(label: "\(T.name)-saver")
  var queued : Bool = false
  
  public var singleton : [String : T] { get { return _singleton}
    set {
      _singleton = newValue
      notify()
      if !queued {
        queued = true
        myQ.asyncAfter(deadline: .now() + 1.0) {
          self.queued = false
          self.save()
        }
      }
    }
  }
  
  public func notify() {
    NotificationCenter.default.post( Notification( name: Notification.Name(rawValue: T.name), object: nil, userInfo: [:]) )
  }
  
  public func save() {
    // This notification is really just for updating a status line to indicate that a save was attempted.
    Notification.statusUpdate("\(singleton.count) \(T.name) saved")
    
    let fnam = T.filename
    let g = fnam.deletingLastPathComponent()
    if !FileManager.default.fileExists(atPath: g.path) {
      try? FileManager.default.createDirectory(atPath: g.path, withIntermediateDirectories: true, attributes: nil)
    }
    
    do {
      try singleton.encode()?.write(to: fnam)
    } catch let err {
      os_log("writing %@ to %@ failed: %@", type: .error , T.name, T.filename.path, err.localizedDescription )
    }
  }
  
  // this downloads (and stores locally) the iCloud table by running a query
  public func fromICloud(_ dbx : CKDatabase, _ zonid : CKRecordZoneID) {
    var changeTag = UserDefaults.standard.string(forKey: "RecordChangeTag")
 
    let query = CKQuery(recordType: T.name, predicate: NSPredicate(value: true))
    repeatCursor(db : dbx, zoneID: zonid, query: query,
                 recordHandler: { rec in
                  if let z = rec.recordChangeTag {
                    // print("record change tag \(z)")
                    if let ct = changeTag {
                      if z > ct  { changeTag = z }
                    } else {
                      changeTag = z
                    }
                    self.cache(T.init(record: rec))
                  }
                  },
                 blockHandler: {
                  // print("writing change token \(changeTag)")
                  UserDefaults.standard.set(changeTag, forKey: "RecordChangeTag")
                  UserDefaults.standard.synchronize()
    }, completionHandler: {
                  self.pbCopy();
    } )
    
    T.downloadRelated(dbx, zonid)
  }
  
  // FIXME: I should figure out how to get this to work on iOS
  public func pbCopy() {
    #if os(macOS)
      let j = Array(_singleton.values)
      NSPasteboard.general.clearContents()
      
      let ke : [String] = j.map { let he = HTMLEncoder(); try? $0.encode(to: he); return he.html  }
      var kj = ke.reduce("<html><head><meta http-equiv=Content-Type content=\"text/html; charset=utf-8\"></head><body><table>") {
        $0.appending("<tr>\($1)</tr>") }
      kj.append("</table></body></html>")
      // NSPasteboard.general.setData(kj.data(using: .utf8), forType: .html)
      NSPasteboard.general.setString( kj, forType: .html )
    #endif
  }
  
  public func restoreFromFile() {
    _singleton = [String : T].decode(from: FileManager.default.contents(atPath: T.filename.path)) ?? [:]
  }
  
  public static func restoreFromFile() -> DataCache<T> {
    let a = DataCache<T>()
    a.restoreFromFile()
    return a
  }
  
  public func cache(_ v : T?) {
    if let v = v  { singleton[v.getKey()] = v
      // TODO: this should trigger a delayed save() -- but additional invocations should use the same delayed save()
      
      // this creates a notification so that views that depend on this model can update themselves
      // FIXME:  if I could indicate whether it was an insert, delete, or update -- and what was being modified,
      //         that would make view udpates smoother.
      NotificationCenter.default.post( Notification( name: Notification.Name(rawValue: T.name), object: nil, userInfo: [:]) )
    }
  }
  
  public func uploadToICloud(_ dbx : CKDatabase, _ zonid : CKRecordZoneID) {
    // TODO: what if I have write access to the shared zone?
    if let _ = self.rootID { }
    else {
      self.findShare(dbx, zonid)
    }
    
    if self.rootID == nil {
      print("*** the rootID is nil!!! ***")
    }
    
    var candidates = singleton
    
    // FIXME:  am I keeping track of which records have been locally modified -- and only uploading those?
    let tux : [CKRecord] = candidates.values.flatMap { (_ m : T) -> CKRecord? in
      // at one time, the record encoder returned an array of records to support the ORM-like notion that
      // an object could have master/detail records.
      // Now the mapping is: one object = one record.
      let r = RecordEncoder(m, zonid)
      do {
        try m.encode(to: r )
        // FIXME:  are there scenarios where the parent wants to be something other than the rootID
        //    e.g.  the parent of a frame is the style?
        if (r.record.parent == nil) {  r.record.setParent(self.rootID) }
        return r.record
      } catch {
        os_log("encoding data to %@ record failed: %@", type: .error , type(of: m).name, error.localizedDescription )
        return nil
      }
    }
    
    // FIXME:  If the local records don't have metadata, then they are presumably inserts
    let sn = 300
    for i in stride(from: 0, to: tux.count, by: sn) {
      modifyRecords(dbx, Array(tux[i..<min(tux.count, i+sn)]))
    }
    
    // FIXME
    // I could collect all the operations from the above operations, and add them as dependencies
    // for what comes next.
    
    T.uploadRelated(dbx, zonid)
    
    
  }
  
  func modifyRecords(_ dbx : CKDatabase, _ tux : [CKRecord] ) {
    let mro = CKModifyRecordsOperation(recordsToSave: tux, recordIDsToDelete: nil)
    if #available(iOS 11.0, *) {
      let oc = CKOperationConfiguration()
      oc.timeoutIntervalForRequest = 10
      mro.configuration = oc
    }
    mro.modifyRecordsCompletionBlock = { recs, rids, error in
      if let err = error {
        // FIXME:  1) I want: (err as! CKError).partialErrorsByItemID.debugDescription
        // 2) If the error is "record to insert already exists" -- that means I should probably
        //    refresh by reloading from iCloud.
        //    BUT I might want to keep any local changes ?
        os_log("modify %@ failed: %@", type: .error , T.name, err.localizedDescription )
        let a = (err as! CKError).partialErrorsByItemID!
        a.forEach { v in
          let (key, value) = v
          os_log("%@: %@)", type: .error, (key as! CKRecordID).recordName, (value as! CKError).localizedDescription)
        }
      }
      os_log("modify %@ wrote %d records", type: .info, T.name, recs?.count ?? 0)
      
      // if the record was successfully modified, I need to update the local cache to have the
      // right encoded system fields
      if let xrecs = recs {
        xrecs.forEach { wrot in
          if let h = T.init(record: wrot) {
            T.base.cache(h)
          }
        }
        Notification.statusUpdate("\(xrecs.count) records updated")
      }
    }
    dbx.add(mro)
  }
  
  // views which need to be notified up updates can use this.
  public func watch(using block: @escaping (Notification) -> Void) {
    NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: T.name), object: nil, queue: nil, using: block)
  }
  
  // FIXME: If I want to paste in data, get this working again.
  // NSPasteboardReading -------------------------------------------------------------------------------------
  /* public required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
   switch( type ) {
   /*case .string: // public.utf8-plain-text
   // FIXME
   do { BulletPoints.lastImport = try JSONDecoder().decode([String:[String]].self, from: propertyList as! Data )}
   catch {
   os_log("json decoding failed for bullets: %@", type: .error,  error.localizedDescription)
   }*/
   case .html: // public.html
   do {
   let zz = try XMLDocument(data: propertyList as! Data, options: XMLNode.Options.documentTidyHTML )
   if let yy = try zz.rootElement()?.nodes(forXPath: "//table"),
   yy.count > 0 {
   let xx = try yy[0].nodes(forXPath: "*\/tr")
   let qq = xx.map { (n : XMLNode) -> [String] in
   do { var ss = try n.nodes(forXPath: "td//text()").map { $0.stringValue ?? "??" }
   while(ss.last == "\n") { ss.removeLast() }
   return ss
   }
   catch { return [""] }
   }
   var bb = [String:T]()
   qq.forEach { strs in
   if strs.count > 0 {
   let a = T(cmsID: strs[0], bullets: Array(strs[1...]))
   bb[a.getKey()] = a
   }
   }
   }
   else {
   os_log("html parsing failed", type: .error)
   }
   // p (try zz.rootElement()?.nodes(forXPath: "//table"))![0]!.nodes(forXPath: "*\/tr/td//text()").debugDescription
   } catch {
   os_log("xml document parsing failed: %@", type: .error, error.localizedDescription)
   }
   /*if let z = HTMLParser(data: propertyList as! Data).parseTable() {
   os_log("don't know how to paste html %@", type: .error, z)
   } else {
   os_log("didn't parse HTML table")
   return nil
   }*/
   default:
   os_log("don't know how to paste this: %@", type: .error, type.rawValue )
   return nil
   }
   
   }
   
   public static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
   return [NSPasteboard.PasteboardType.html,
   NSPasteboard.PasteboardType.string,
   NSPasteboard.PasteboardType(rawValue: "public.json")]
   }
   */
}

// To be Codable into a Record, I want to know the key (used for the RecordName)
// I will store encodedSystemFields in order to sync with the iCloud storage -- but the Codable/Decodable
// wants to treat that specially
public protocol DataModel : Codable {
  // return the key from the object
  func getKey() -> String
  static var name : String { get }
  var encodedSystemFields : Data? { get set }
  static func downloadFromAPI()
  static var base : DataCache<Self> { get }
  
  static func uploadRelated(_ : CKDatabase, _ : CKRecordZoneID)
  static func downloadRelated(_ : CKDatabase, _ : CKRecordZoneID)
}

// the local data is stored on a file and retrieved therefrom.
// in order to support Playgrounds, I use a special filename in the Shared Playground Data folder
// Somebody needs to put a copy of the required data into that folder, since Playgrounds cannot access CloudKit
extension DataModel {
  public static var filename : URL  { get {
    if Bundle.allBundles.contains(where: { ($0.bundleIdentifier ?? "").hasPrefix("com.apple.dt.") }) {
      return playgroundFilename
    } else {
      return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
    } }
  }
  
  public static var playgroundFilename : URL { get {
    let nsu = NSUserName()
    return URL(fileURLWithPath: "/Users/\(nsu)/Documents/Shared Playground Data/\(name)")
    }}
  
  // If this data was created from iCloud, it has system fields, and knows which zone it lives in.
  // for new data (inserts), it needs to know the zone in order to create the record.
  public func toRecord(_ zid : CKRecordZoneID) -> CKRecord {
    if let es = encodedSystemFields {
      let coder = NSKeyedUnarchiver(forReadingWith: es)
      coder.requiresSecureCoding = true
      if let re = CKRecord(coder: coder) {
        coder.finishDecoding()
        return re
      }
    }
    let n = type(of: self).name
    let k = getKey()
    let re = RecordEncoder(n, k, zid)
    do {
      try self.encode(to: re)
    } catch {
      os_log("record encoding of %@ (%@) failed: %@", type: .error , n, k, error.localizedDescription )
    }
    return re.record
  }
  
  public init?(record: CKRecord) {
    do {
      try self.init(from: RecordDecoder(record))
    } catch {
      os_log("decoding %@ failed: %@", type: .error , record.recordType, error.localizedDescription )
      return nil
    }
    self.updateSystemFields(record)
  }
  
  mutating public func updateSystemFields(_ record: CKRecord) {
    // Locally store the cloud metadata
    let data = NSMutableData()
    let coder = NSKeyedArchiver.init(forWritingWith: data)
    coder.requiresSecureCoding = true
    record.encodeSystemFields(with: coder)
    coder.finishEncoding()
    
    // store this metadata on your local object
    self.encodedSystemFields = data as Data
  }
}

public class LocalAsset : Codable {
  public var relativeFile : String // local file URL
  public init(_ u : String) { relativeFile = u }
  lazy var url : URL = {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(relativeFile)
  }()
  public var data : Data? { get { return try? Data(contentsOf: url) } }
  public var image : Image? { get { return data?.image } }
}
