//
//  Cloud.swift
//  WPKit
//
//  Created by Robert M. Lefkowitz on 11/4/17.
//

import CloudKit

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

