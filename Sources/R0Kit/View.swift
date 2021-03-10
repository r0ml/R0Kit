// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

/// This extension adds the abilkity to specify conditional modifiers 
extension View {
  
  @ViewBuilder func modifier<TrueContent: View>(
    if condition: Bool,
    then trueContent: (Self) -> TrueContent
  ) -> some View {
    if condition {
      trueContent(self)
    } else {
      self
    }
  }
  
  @ViewBuilder func modifier<TrueContent: View, FalseContent: View>(
    if condition: Bool,
    then trueContent: (Self) -> TrueContent,
    else falseContent: (Self) -> FalseContent
  ) -> some View {
    if condition {
      trueContent(self)
    } else {
      falseContent(self)
    }
  }
}
