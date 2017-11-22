
import CloudKit

public protocol DataModel : Codable {
  // associatedtype DataKey : Hashable
  /*
   static func fromCloud(_ db : CKDatabase ) -> [String:CKRecord]
  func writeToCloud()
  func update()
  
  // write the singleton to iCloud
  static func writeToCloud()
  */
  
  // static var myZoneID : CKRecordZoneID { get }
  
  // get the data from an API
  static func downloadFromAPI()
  
  // save the singleton to local file
  static func save()
  
  // the filename for storing this model
  // static var filename : URL { get }

  static var name : String { get }
  
  // the "global" value of this table
  // static var singleton : Any { get set }
  static var _singleton : [String : Self] { get set } // = [String:FrameCollection]()

  // create an instance from a CKRecord
  // use fromRecord instead
  // init?(record : CKRecord)
  
  // return the key from the object
  func getKey() -> String
}

extension DataModel {
  
  public static func watch(using block: @escaping (Notification) -> Void) {
    NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: Self.name), object: nil, queue: nil, using: block)
  }
  
  var name : String { get { return Self.name } }
  
  static var filename : URL  { get {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
    } }

  public static var singleton : [String : Self] {
    get {
      return _singleton
    }
    set {
      _singleton = newValue
      NotificationCenter.default.post( Notification( name: Notification.Name(rawValue: name), object: nil, userInfo: [:]) )
      
      // TODO: This can be optimized by scheduling a future save, and not bothering if one is already scheduled
      save()
      
    }
  }

  public static func restoreFromFile() -> [String : Self] {
    return [String : Self].decode(from: FileManager.default.contents(atPath: filename.path)) ?? [:]
  }

  public func cache() {
    Self.singleton[self.getKey()] = self
    // TODO: this should trigger a delayed save() -- but additional invocations should use the same delayed save()
  }

  public static func save() {
    let fnam = filename
    let g = fnam.deletingLastPathComponent()
    if !FileManager.default.fileExists(atPath: g.path) {
      try? FileManager.default.createDirectory(atPath: g.path, withIntermediateDirectories: true, attributes: nil)
    }

    do {
      try singleton.encode()?.write(to: fnam)
    } catch let err {
      print("writing \(name) to \(filename): \(err.localizedDescription)")
    }
  }
}

extension DataModel {
  public static func uploadToICloud(_ db : CKDatabase, _ zid : CKRecordZoneID) {
    let rootID = findShare(db, zid)
    
    // TODO: what if I have write access to the shared zone?
    
    // var candidates = Array(singleton.values)
    var candidates = singleton
    var pendingUpdates = [CKRecord]()
    
    let fo = CKFetchRecordsOperation(recordIDs: candidates.values.map { CKRecordID(recordName: $0.getKey(), zoneID: zid) } )
    fo.perRecordCompletionBlock = { rec, rid, err in
      if var rr = rec,
        let r = candidates[rr.recordID.recordName] {
        
        do {
          try r.encode(to: RecordEncoder(record: &rr))
        } catch {
          print(error)
        }
        // let z = RecordEncoder(name, r.getKey(), zid)
        // r.modify(record: rr)

        pendingUpdates.append(rr)
        candidates.removeValue(forKey: rr.recordID.recordName)
      } else {
        os_log("fetch datamodel key error: %@", type:.error, err?.localizedDescription ?? "unknown")
      }
      // print("got \(rec) \(rid) \(err)")
    }
    fo.fetchRecordsCompletionBlock =  { recs, err in
      let z = pendingUpdates
      // modifies here
      pendingUpdates.removeAll()
      let mro = CKModifyRecordsOperation(recordsToSave: z, recordIDsToDelete: nil)
      if #available(iOS 11.0, *) {
        let oc = CKOperationConfiguration()
        oc.timeoutIntervalForRequest = 10
        mro.configuration = oc
      }
      mro.modifyRecordsCompletionBlock = { recs, rids, error in
        if let err = error {
          os_log("modify collections failed: %@", type: .error , err.localizedDescription )
        }
        os_log("modify collections wrote %d records", type: .info, recs?.count ?? 0)
        
        // inserts here
        let pendingInserts : [CKRecord] = candidates.values.map { let a = $0.toRecord(zid); a.setParent(rootID); return a }
        let mro = CKModifyRecordsOperation(recordsToSave: pendingInserts, recordIDsToDelete: nil)
        mro.savePolicy = CKRecordSavePolicy.allKeys
        mro.modifyRecordsCompletionBlock = { recs, rids, error in
          if let err = error {
            os_log("insert %@ failed: %@", type: .error , name, err.localizedDescription )
          }
          os_log("insert %@ wrote %d records", type: .info, name, recs?.count ?? 0)
          
          // FIXME: Now I want to trigger "fetchChanges"
          
        }
        db.add(mro)

      }
      db.add(mro)
    }
    
    db.add(fo)
    
    // now lets try it by reading then writing
    // let pred = NSPredicate(format: "recordName IN %@", candidates.map { $0.getKey() } )
    
   /* let pred = NSPredicate(format: "%K IN %@", "creatorUserRecordID" ,candidates.map { CKReference(recordID: CKRecordID(recordName: $0.getKey() ), action: CKReferenceAction.none) } )
    
    
    var pendingUpdates = [CKRecord]()
    
    let query = CKQuery( recordType: name, predicate: pred )
    
    repeatCursor(db: db, zoneID: zid, query: query,
                 recordHandler: { rec in
                  // get the record
                  // update it
                  if let n = candidates.index(where: { $0.getKey() == rec["recordName"] as? String }) {
                    let thisone = candidates[n]
                    thisone.modify(record: rec)
                    pendingUpdates.append(rec)
                    candidates.remove(at: n)
                  }
    }, blockHandler: {
      let z = pendingUpdates
      pendingUpdates.removeAll()
      let mro = CKModifyRecordsOperation(recordsToSave: z, recordIDsToDelete: nil)
      if #available(iOS 11.0, *) {
        let oc = CKOperationConfiguration()
        oc.timeoutIntervalForRequest = 10
        mro.configuration = oc
      }
      mro.modifyRecordsCompletionBlock = { recs, rids, error in
        if let err = error {
          os_log("modify collections failed: %@", type: .error , err.localizedDescription )
        }
        os_log("modify collections wrote %d records", type: .info, recs?.count ?? 0)
      }
      db.add(mro)
    }
    ) { */
    
   //   }
  }
  
  public func toRecord(_ zid : CKRecordZoneID) -> CKRecord {
    var r = CKRecord(recordType: name, recordID: CKRecordID(recordName: getKey(), zoneID: zid))

    do {
      try self.encode(to: RecordEncoder(record: &r))
    } catch {
      print(error)
    }

    
    // modify(record: r)
    return r
  }
  
  public static func fromRecord(_ record : CKRecord) -> Self? {
    do {
      return try RecordDecoder(record).decode(Self.self)
    } catch {
      print(error)
      return nil
    }
  }
}

extension DataModel {
/*  public func modify(record rr: CKRecord) {
    let m = Mirror(reflecting: self)
    
    for case let (label?, value) in m.children {
      print("mirror \(label)")
      rr[label] = value as? CKRecordValue
    }
  }
 */
  
  // this downloads (and stores locally) the iCloud table by running a query
  public static func fromICloud(db : CKDatabase, zoneID zid: CKRecordZoneID ) {
    let query = CKQuery(recordType: name, predicate: NSPredicate(value: true))
    repeatCursor(db : db, zoneID: zid, query: query,
                 recordHandler: { Self.fromRecord($0)?.cache() },
                 blockHandler: {}, completionHandler: Self.save )
  }
}

/*public func dumpData(_ s : String) {
  repeatCursor(db: iCloudDBprivate, zoneID: myZoneID, query: CKQuery.init(recordType: s, predicate: NSPredicate(value: true)),
               recordHandler: { print($0.debugDescription) },
               blockHandler: { print("block ended")},
               completionHandler: { print("all done") })
}*/
