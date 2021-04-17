// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import CloudKit
import os

/** Store AWS secrets in a CloudKit record.  This retrieves the access key, secret key and region from CloudKit.
 The CloudKit CKRecord will have the recordName used as a key to retrieve the secret.
 This avoids keeping the AWS secrets in one's source code repository  */
func getSecret(_ key : String) -> (String, String, String)? {
  let c : CKContainer = CKContainer.default()
  let pd = c.publicCloudDatabase
  let id = CKRecord.ID.init(recordName: key)
  var res : (String, String, String)?
  let sem = DispatchSemaphore(value: 0)
  pd.fetch(withRecordID: id) { (rec, err) in
    if let e = err {
      os_log("failed to get secret % %", type: .error, CKContainer.default().containerIdentifier ?? "no container identifier", e.localizedDescription)
      return
    }
    guard let rec = rec else {
      os_log("failed to get secret %", type: .error, CKContainer.default().containerIdentifier ?? "no container identifier")
      return
    }
    res = (rec["access"] as! String, rec["secret"] as! String, rec["region"] as! String)
    sem.signal()
  }
  let _ = sem.wait(wallTimeout: DispatchWallTime.now()+DispatchTimeInterval.seconds(2))
  return res
}
