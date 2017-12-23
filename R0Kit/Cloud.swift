
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

// find the zone with the given name.
// assuming that data is segregated by zone (because of the update notifications)
// this is how I find the data I want.
public func findZone(_ db : CKDatabase, _ nam : String) -> CKRecordZoneID? {
  var rz : CKRecordZoneID?
  
  let dq = DispatchSemaphore(value: 0)
  db.fetchAllRecordZones { (recordZone, error) in
    if let err = error {
      os_log("fetch all record zones failed: %@", type: .error , err.localizedDescription )
    }
    if let recordZones = recordZone {
      // Here you'll have an array of CKRecordZone that is in your SharedDB!
      recordZones.forEach { print($0.zoneID) }
      rz = recordZones.first(where: {$0.zoneID.zoneName == nam})?.zoneID
      if (rz == nil) {
        os_log("couldn't figure out the zoneID for product catalog", type: .error)
      }
    }
    dq.signal()
  }
  dq.wait()
  return rz
}

public func checkiCloudLogin(_ fn : @escaping () -> Void) {
  // var isLoggedIn = false

  // let testingNotLoggedIn = false
  CKContainer.default().accountStatus { accountStatus, error in
    if accountStatus == .noAccount /* || testingNotLoggedIn */ {
      
      //  DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
      DispatchQueue.main.async {
        #if os(macOS)
          let urlString = "x-apple.systempreferences:com.apple.preferences.icloud?iCloud"
          NSWorkspace.shared.open(URL(string:urlString)!)
        #elseif os(iOS)
          UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        #endif
    
      #if os(macOS)
      let z = Application.shared.orderedWindows.first
        #elseif os(iOS)
      let z = Application.shared.windows.first
        #endif
      
      if let _ = z {
      } else {
        os_log("window reference was null.  I'm going to crash now", type: .error)
      }
      raiseAlert(title: "Sign in to iCloud", message: "This app uses iCloud features to store and share data securely.  Please sign in to your iCloud account.  If you don't have an iCloud account, please create one", window: z!) {
        DispatchQueue.main.async {
          checkiCloudLogin(fn)
        }
      }
      } }
    else if accountStatus == CKAccountStatus.available {
      // let q = DispatchSemaphore(value: 0)
      
      // isLoggedIn = true
      fn()
    }
    }
  }



