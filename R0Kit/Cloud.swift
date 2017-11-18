//
//  Cloud.swift
//  WPKit
//
//  Created by Robert M. Lefkowitz on 11/4/17.
//

import CloudKit

public var _rootID : CKRecordID?

public func findShare(_ db : CKDatabase, _ zid : CKRecordZoneID) -> CKRecordID? {
  if let rid = _rootID { return rid}
  if let z = UserDefaults.standard.data(forKey: "RootRecord") {
    // This value will be nil if it is not the machine that originally created the RootRecord
    // If it is nil, then I must retrieve the Root Record from CloudKit
    // If I am the owner, it will exist
    _rootID = NSKeyedUnarchiver.unarchiveObject(with: z) as? CKRecordID
    if let r = _rootID { return r }
  }
  
  var recid : CKRecordID?
  let sem = DispatchSemaphore(value: 0)
  // deletes all existing shares
  let query = CKQuery(recordType: "RootRecord", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
  query.sortDescriptors = [NSSortDescriptor(key: "___modTime", ascending: false)] // latest time first
  db.perform(query, inZoneWith: zid) { (records, error) in
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
    _rootID = recid
    return recid
  }
  return nil
}

public func repeatCursor(db : CKDatabase, zoneID zid: CKRecordZoneID, query qry : CKQuery,
                         recordHandler fn : @escaping (CKRecord)->Void, blockHandler xfn : @escaping () -> Void,
                         completionHandler zfn : @escaping () -> Void ) {
  let op = CKQueryOperation(query: qry)
  op.zoneID = zid
  
  func mkc() -> ((CKQueryCursor?, Error?) -> Void) { return
  { cursor, error in
    if let e = error {
      os_log("getting repeating cursor: %@", e.localizedDescription)
    } else {
      xfn() // this is the "I've finished this block" code
      if let c = cursor {
        let ck = CKQueryOperation(cursor: c)
        ck.zoneID = zid
        ck.recordFetchedBlock = fn
        ck.queryCompletionBlock = mkc()
        db.add(ck)
      } else {
        zfn() // this is the "I'm done now" code
      }
    }
    }
  }
  op.recordFetchedBlock = fn
  op.queryCompletionBlock = mkc()
  op.zoneID = zid
  db.add(op)
}

public func findZone(_ db : CKDatabase, _ nam : String) -> CKRecordZoneID? {
  var rz : CKRecordZoneID?
  
  let dq = DispatchSemaphore(value: 0)
  db.fetchAllRecordZones { (recordZone, error) in
    if let err = error {
      print(err.localizedDescription)
    }
    if let recordZones = recordZone {
      // Here you'll have an array of CKRecordZone that is in your SharedDB!
      rz = recordZones.first(where: {$0.zoneID.zoneName == nam})?.zoneID
      if (rz == nil) {
        print("couldn't figure out the zoneID for product catalog")
      }
    }
    dq.signal()
  }
  dq.wait()
  return rz
}

