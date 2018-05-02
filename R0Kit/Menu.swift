//
//  Menu.swift
//  R0Kit
//
//  Created by Robert M. Lefkowitz on 4/16/18.
//  Copyright © 2018 Semasiology. All rights reserved.
//

extension NSMenu {
  @discardableResult public func addItem( withTitle title : String, keyEquivalent: String, _ fn : @escaping (AnyObject?) -> Void ) -> NSMenu {
    self.addItem( R0MenuItem(title: title, keyEquivalent: keyEquivalent, fn) )
    return self
  }

  /*  @discardableResult public func addSeparator() -> NSMenu {
    self.addItem( R0MenuItem.separator() )
    return self
  }
  */
  
  @discardableResult public func addItem(chained : NSMenuItem) -> NSMenu {
    self.addItem( chained)
    return self
  }
  
  @discardableResult public static func += (a : NSMenu, b : NSMenuItem) -> NSMenu {
    return a.addItem(chained: b)
  }
  
  public func addSubmenu( withTitle title: String ) -> NSMenu {
    let subItem = R0MenuItem(title: title, keyEquivalent: "") {_ in }
    subItem.isEnabled = true
    let submenu = NSMenu(title: title)
    subItem.submenu = submenu
    self.addItem(subItem)
    return submenu
  }
}

public class R0MenuItem : NSMenuItem {
  var closx : ClosX!
  
  public init(title: String, keyEquivalent: String, _ fn: @escaping (AnyObject?) -> Void) {
    closx = ClosX(fn)
    let ke : String
    if keyEquivalent.starts(with: "@") {
      ke = String(keyEquivalent.suffix(1))
    } else {
      ke = keyEquivalent
    }
    
    super.init(title: title, action: closx.selector, keyEquivalent: ke)
    if ke != keyEquivalent { self.keyEquivalentModifierMask = [.option, .command] }
    self.target = closx
  }
  
  public required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override convenience init(title: String, action: Selector?, keyEquivalent: String) {
    if let a = action {
      print("action set for R0MenuItem is an error: ", title, a)
    }
    self.init(title: title, keyEquivalent: keyEquivalent) { _ in }
  }
}

