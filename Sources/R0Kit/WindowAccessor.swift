// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

#if canImport(AppKit)

import AppKit

/**
 This lets a SwiftUI get access to the NSWindow it is in.

 Usage is:

@main struct MyApp : App {

 @State var window: NSWindow?

 ....

 var body: some Scene {

 WindowGroup {
        AppView()
         .environmentObject( MakeObject(window) )
         .background(WindowAccessor(window: $window))
 ...
  }
 }
}

.....

 The $window variable can capture the window -- and the EnvironmentObject needs a constructor to assign a property to the window.
 Then, the window can be accessed by using the EnvironmentObject

 */
public struct WindowAccessor: NSViewRepresentable {
  @Binding var window : NSWindow?
  public init(window : Binding<NSWindow?>) {
    self._window = window
  }
  
  public func makeNSView(context: Context) -> NSView {
    let view = NSView()
    DispatchQueue.main.async {
      self.window = view.window   // << right after inserted in window
    }
    return view
  }

  public func updateNSView(_ nsView: NSView, context: Context) {}
}

#endif
