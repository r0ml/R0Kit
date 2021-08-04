// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation
import CloudKit
import SwiftUI
import Combine
import os

fileprivate let localLog = Logger()

extension Notification.Name {
  public static let reportStatus = Notification.Name(rawValue: "reportStatus" )
  public static let reportError = Notification.Name(rawValue: "reportError" )
}

extension Notification {
  public static func reportStatus(_ m : String) {
    localLog.info("\(m)")
    let noti = Notification( name: .reportStatus, object: nil, userInfo: ["msg":m])
    DispatchQueue.main.async { NotificationCenter.default.post(noti) }
  }

  public static func reportError(_ m : String, _ err : Error?) {
    if let e = err {
      localLog.error("\(m) \(e.localizedDescription)")
      var mmm = e.localizedDescription
      if let ee = e as? CKError {
        if let mm = ee.userInfo["NSUnderlyingError"] as? NSError {
          mmm = mm.localizedDescription
        }

      }
      let noti = Notification( name: .reportError, object: nil, userInfo: ["msg":m, "err": mmm])
      DispatchQueue.main.async { NotificationCenter.default.post(noti) }
    }
  }
  public static func reportError(_ m : String, _ e : String) {
    let noti = Notification( name: .reportError, object: nil, userInfo: ["msg":m, "err": e])
    DispatchQueue.main.async { NotificationCenter.default.post(noti) }
  }
}

public struct StatusView : View {
  private var labelColor : Color {
    get {
      #if os(iOS)
      return Color(.label)
      #elseif os(macOS)
      return Color(.labelColor)
      #endif
    }
  }
  @State private var errorMsg : String = " "
  @State private var color : Color = Color.clear

  private var pub : Publishers.Merge<NotificationCenter.Publisher,NotificationCenter.Publisher>

  public init() {
    pub = NotificationCenter.default.publisher(for: Notification.Name.reportError)
      .merge(with: NotificationCenter.default.publisher(for: Notification.Name.reportStatus))
  }

  public var body : some View {
    Text(errorMsg).foregroundColor(Color.red)
      .onReceive(pub) { not in
        self.color = not.name == .reportError ? Color.red : labelColor
        self.errorMsg = not.userInfo?["msg"] as? String ?? " "
      }
  }
}
