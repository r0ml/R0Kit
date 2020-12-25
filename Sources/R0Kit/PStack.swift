// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

struct PStack<Content> : View where Content: View {
  var isVertical: Bool = true
  let content: () -> Content

  init(isVertical: Bool, @ViewBuilder content: @escaping () -> Content) {
    self.content = content
    self.isVertical = isVertical
  }

  var body: some View {
      if isVertical {
        return AnyView { VStack {
          content()
        } }
      } else {
        return AnyView { HStack() {
          content()
        } }
      }
    }
}
