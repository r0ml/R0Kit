

var downloadingQ : DispatchQueue = DispatchQueue(label: "downloading", qos: .background,  attributes: .concurrent)

public func getImage(sync: Bool = false, _ url : String, f : Optional<(Error?, Data) -> Void> = nil) {
  let lsem = DispatchSemaphore(value: 0)
  if let u = URL(string: url) {
    downloadingQ.async {
      let r = URLRequest(url: u, timeoutInterval: 30.0)
      
      let task = session.dataTask(with: r) { data, response, error in
        var dat : Data
        if let _ = error {
          // print("failed to download (getImage): \(url) \(e.localizedDescription)")
          dat = Data()
        } else {
          dat = data!
        }
        if let f = f { downloadingQ.async {
          f(error, dat); lsem.signal() } }
        else { lsem.signal() }
      }
      task.resume()
    }
  } else {
    if let f = f { f( nil, Data() ) }
    lsem.signal()
  }
  
  if sync { let _ = lsem.wait( timeout: .now() + 30 ) }
}

