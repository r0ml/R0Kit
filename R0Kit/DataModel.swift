
import CloudKit

public class DataCache<T : DataModel> : NSObject {
  var _singleton : [String : T] = [:]
  var rootID: CKRecordID?
  var dbx : CKDatabase
  var zonid : CKRecordZoneID
  
  public init(_ db : CKDatabase, _ zid : CKRecordZoneID) {
    zonid = zid
    dbx = db
    super.init()
    findShare()
  }
  
  public func findShare() {
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
    // deletes all existing shares
    let query = CKQuery(recordType: "RootRecord", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
    query.sortDescriptors = [NSSortDescriptor(key: "___modTime", ascending: false)] // latest time first
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
      rootID = recid
      return
    }
    return
  }
  
  public var singleton : [String : T] { get { return _singleton}
    set {
      _singleton = newValue
      NotificationCenter.default.post( Notification( name: Notification.Name(rawValue: T.name), object: nil, userInfo: [:]) )
      
      // TODO: This can be optimized by scheduling a future save, and not bothering if one is already scheduled
      // FIXME:  how to indicate that the datamodel is "dirty" and needs to be saved
    }
  }
  
  public func save() {
    Notification.statusUpdate("\(singleton.count) \(T.name) saved")

    let fnam = T.filename
    let g = fnam.deletingLastPathComponent()
    if !FileManager.default.fileExists(atPath: g.path) {
      try? FileManager.default.createDirectory(atPath: g.path, withIntermediateDirectories: true, attributes: nil)
    }
    
    do {
      try singleton.encode()?.write(to: fnam)
    } catch let err {
      print("writing \(T.name) to \(T.filename): \(err.localizedDescription)")
    }
  }
  
  // this downloads (and stores locally) the iCloud table by running a query
  public func fromICloud() {
    let query = CKQuery(recordType: T.name, predicate: NSPredicate(value: true))
    repeatCursor(db : dbx, zoneID: zonid, query: query,
                 recordHandler: { self.cache(T.init(record: $0)) },
                 blockHandler: {}, completionHandler: { self.pbCopy(); self.save() } )
  }
  
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
  
  public static func restoreFromFile(db: CKDatabase, zid: CKRecordZoneID) -> DataCache<T> {
    let a = DataCache<T>( db, zid)
    a.restoreFromFile()
    return a
  }
  
  public func cache(_ v : T?) {
    if let v = v  { singleton[v.getKey()] = v }
    // TODO: this should trigger a delayed save() -- but additional invocations should use the same delayed save()
  }
  
  public func uploadToICloud() {
    // TODO: what if I have write access to the shared zone?
    
    var candidates = singleton
    var pendingUpdates = [CKRecord]()
    
    let cmp = candidates.values.map {
          CKRecordID(recordName: $0.getKey(), zoneID: zonid) }
    
    // probably what needs to be done here is that all of the record ids for all of the sub-records
    // need to be fetched.
    
    // then the Records-to-be-saved need to be merged with the records-that-were-already-there
    // when I cache locally, to I save the "records-that-were-already-there metadata?
    
    
    var tu : [CKRecord] = candidates.values.flatMap { (_ m : DataModel) -> CKRecord? in
      let r = RecordEncoder(m, self.zonid)
      do {
        try m.encode(to: r )
        // I can set the parent to something else?
        if (r.record.parent == nil) {  r.record.setParent(self.rootID) }
        return r.record // r.record.allRecords
      } catch {
        print(error)
        return nil
      }
    }
    
    // FIXME:  If the local records don't have metadata, then they are presumably inserts
    /*
    let fo = CKFetchRecordsOperation(recordIDs: cmp)
    fo.qualityOfService = .userInitiated
    
    // this is reading the existing (if any) records to be updated
    fo.perRecordCompletionBlock = { rec, rid, err in
      if var rr = rec,
        let r = candidates[rr.recordID.recordName]
      {
        
        let re = RecordEncoder(record: &rr)
        do {
          try r.encode(to: re)
        } catch {
          print(error)
        }
        
        let pu = re.record.allRecords
        // this is the pending update records
        pendingUpdates.append(contentsOf: pu)
        
        // as part of the encoding -- can I also acquire the affected subrecords?
        
        candidates.removeValue(forKey: rr.recordID.recordName)
      } else {
        os_log("fetch datamodel key error: %@", type:.error, err?.localizedDescription ?? "unknown")
      }
      
      // print("got \(rec) \(rid) \(err)")
    }
    fo.fetchRecordsCompletionBlock =  { recs, err in
      if let e = err {
        if let cke = e as? CKError,
          let ue = cke.userInfo["NSUnderlyingError"],
          let ne = ue as? NSError {
          if ne.code == 1011 {
          } else {
            Notification.errorReport("fetching data model records", e)
            return
          }
        }
      }
      let z = pendingUpdates
      // modifies here
      pendingUpdates.removeAll()
      */
    modifyRecords(tu)
    
  }
  
  func modifyRecords(_ tux : [CKRecord] ) {
    let z = ceil( Double(tux.count) / 300.0)
    let m = ceil (Double(tux.count) / Double(z))
    let mx = min(tux.count, Int(m))
    var tu = tux
    let mm = Array(tux[0..<mx])
    
    /*while(tu.count > 0) {
      let mx = min(tu.count, Int(m))
      let tux = Array(tu[0..<mx])
      // tu.removeFirst(mx)
      // modifyRecords(tux)
    }*/

    let mro = CKModifyRecordsOperation(recordsToSave: mm, recordIDsToDelete: nil)
    if #available(iOS 11.0, *) {
        let oc = CKOperationConfiguration()
        oc.timeoutIntervalForRequest = 10
        mro.configuration = oc
      }
      mro.modifyRecordsCompletionBlock = { recs, rids, error in
        if let err = error {
          os_log("modify %@ failed: %@", type: .error , T.name, err.localizedDescription )
        }
        os_log("modify %@ wrote %d records", type: .info, T.name, recs?.count ?? 0)
        
        var n = 0
        if let xrecs = recs, xrecs.count > 0 {
          xrecs.forEach { wrot in
            if let x = tu.index(where: { wrot.recordID.recordName == $0.recordID.recordName }) {
              tu.remove(at: x)
              n += 1
            }
          }
        }
        
        Notification.statusUpdate("\(n) records updated")
        // inserts here
        /*let tox = candidates.values.map { $0 }
        let pendingInserts : [CKRecord] = tox.map { v -> CKRecord in
          let a = v.toRecord(self.zonid);
          a.setParent(self.rootID);
          return a }*/
        
        if n > 0  { if tu.count > 0  { self.modifyRecords(tu) }
        else { Notification.statusUpdate("wrote all records") }
        } else {
          Notification.errorReport("writing records", "failed")
        }
        
        /*
        let mro2 = CKModifyRecordsOperation(recordsToSave: tu, recordIDsToDelete: nil)
        mro2.savePolicy = CKRecordSavePolicy.allKeys
        mro2.modifyRecordsCompletionBlock = { recs, rids, error in
          if let err = error {
            os_log("insert %@ failed: %@", type: .error , T.name, err.localizedDescription )
          }
          os_log("insert %@ wrote %d records", type: .info, T.name, recs?.count ?? 0)
          
          // FIXME: Now I want to trigger "fetchChanges"
          }
        }
        self.dbx.add(mro2)
        */
      }
      self.dbx.add(mro)
    }
  
  /*
    fo.completionBlock = {
      print("now what?")
    }
    
    self.dbx.add(fo)
  }*/
  
  public func watch(using block: @escaping (Notification) -> Void) {
    NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: T.name), object: nil, queue: nil, using: block)
  }

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

public protocol DataModel : Codable {
  // return the key from the object
  func getKey() -> String
  static var name : String { get }
  var encodedSystemFields : Data? { get set }
}

extension DataModel {
  static var filename : URL  { get {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
    } }
  
  public func toRecord(_ zid : CKRecordZoneID) -> CKRecord { // PCRecord {
    //  var r = CKRecord(recordType: name, recordID: CKRecordID(recordName: getKey(), zoneID: zid))
    if let es = encodedSystemFields {
      let coder = NSKeyedUnarchiver(forReadingWith: es)
      coder.requiresSecureCoding = true
      if let re = CKRecord(coder: coder) {
        coder.finishDecoding()
        return re
      }
    }
    let re = RecordEncoder(type(of: self).name, getKey(), zid)
    do {
      try self.encode(to: re)
    } catch {
      print(error)
    }
    return re.record
  }
  
  public init?(record: CKRecord) {
    do {
      try self.init(from: RecordDecoder(record))
    } catch {
      print("decoding \(record.recordType)", error.localizedDescription)
      return nil
    }
    
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

public func dumpData(db : CKDatabase, zoneID: CKRecordZoneID, table : String) {
 repeatCursor(db: db, zoneID: zoneID, query: CKQuery.init(recordType: table, predicate: NSPredicate(value: true)),
 recordHandler: { print($0.debugDescription) },
 blockHandler: { print("block ended")},
 completionHandler: { print("all done") })
 }

public class LocalAsset : Codable {
  public var url : URL // local file URL
  
  public init(_ u : URL) {
    url = u
  }
  
  public var data : Data? { get
  { return try? Data(contentsOf: url)
    }
  }
  
  public var image : Image? { get
  { return data?.image
  }
  }
}
