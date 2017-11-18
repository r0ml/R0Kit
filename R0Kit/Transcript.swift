//
//  Transcript.swift
//  WPKit
//
//  Created by Robert M. Lefkowitz on 11/9/17.
//

#if os(macOS)
class MyTableView : TableView {
}

public class Transcript : View {
  var lines : [String] = []
  var limit : Int = 1000
  var wnd : NSWindow!
  var tblv : TableView!
  var font : Font?
  
  @objc public override func changeFont(_ x : Any?) {
    print("change font")
    let fm = x as? NSFontManager
    let ff = fm?.selectedFont
    print(ff)
    let oldfont = self.font == nil ? Font.systemFont(ofSize: 22) : self.font!
    
    let newfont = fm?.convert(oldfont)
    self.font = newfont
    
    
    if let nf = newfont {
      let f = Label()
      f.font = nf
      f.text = "Measure"
      f.isBordered = false

      let z = f.intrinsicContentSize
      tblv.rowHeight = z.height + 2 // where does the 2 come from?
    }
    
    tblv.reloadData()
  }

  public func append(_ z : String) {
    // before adding stuff, am I at the end?
    let vh = tblv.visibleRect.minY + tblv.visibleRect.height
    let hml = tblv.bounds.height - (lines.count == 0 ? 0 : tblv.rect(ofRow: lines.count-1).height)
    var scrollQ = vh >= hml
    
//    if (!scrollQ) {
//      scrollQ = true
//     }
    lines.append(z)
    tblv.beginUpdates()
    if lines.count > limit {
      lines.removeFirst( lines.count - limit)
      tblv.deleteRows(at: [IndexPath(item: 0, section: 0)], with: TableView.AnimationOptions.slideUp)
    }
    tblv.insertRows(at: [IndexPath(item: lines.count-1, section: 0)], with: TableView.AnimationOptions.effectFade)
    tblv.endUpdates()
    if scrollQ {
      let st = tblv.bounds.height - tblv.visibleRect.height
      tblv.scroll(CGPoint(x: 0, y: st+tblv.visibleRect.minY ))
    }
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    makeWindow()
    
    NotificationCenter.default.addObserver(forName: Notification.Name.statusUpdate, object: nil, queue: nil) { noti in
      DispatchQueue.main.async {
        if let line = noti.userInfo?["msg"] as? String {
          self.append( line )
        }
      }
    }
  }
  
  public required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func makeWindow() {
    wnd = NSWindow(contentRect: CGRect(x: 100, y: 100, width: 600, height: 200)
      , styleMask: [.closable, .resizable, .titled, .miniaturizable], backing: .buffered, defer: true)
    wnd.isReleasedWhenClosed = false
    wnd.title = "Transcript"
    wnd.isOpaque = false
    wnd.center()
    let fan = NSWindow.FrameAutosaveName(rawValue: "Transcript")
    
    wnd.setFrameAutosaveName(fan)
    
    tblv = NSTableView(frame: CGRect.zero)
    let a = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Msg"))
    a.headerCell.title = "Msg"
    a.width = 100
    a.minWidth = 50
    a.maxWidth = 500
    tblv.addTableColumn(a)
    tblv.dataSource = self
    tblv.delegate = self
    tblv.usesAutomaticRowHeights = true
    tblv.usesAlternatingRowBackgroundColors = true
    
    let sv = NSScrollView(frame: CGRect.zero)
    sv.hasVerticalScroller = true
    sv.documentView = tblv
    sv.hasHorizontalScroller = true
    sv.autohidesScrollers = false
    
    sv.addInto(self)
    
    wnd.contentView = self
    
  }
  
  public func open() {
    // wnd.contentView = v

    wnd.makeKeyAndOrderFront(nil)
  }
  
}

// this is to redraw the selection
public class MyNSTableRowView: NSTableRowView {
  
  public override func drawSelection(in dirtyRect: NSRect) {
    if self.selectionHighlightStyle != .none {
      let selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
      Color(white: 0.65, alpha: 1).setStroke()
      Color(white: 0.82, alpha: 1).setFill()
      let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
      selectionPath.fill()
      selectionPath.stroke()
    }
  }
}

extension Transcript : TableViewDelegate {
  public func tableView(_ tableView: TableView, rowViewForRow row: Int) -> NSTableRowView? {
    return MyNSTableRowView()
  }
}

extension Transcript : TableViewDataSource {
  public func numberOfRows(in tableView: TableView) -> Int {
    return lines.count
  }

  public func tableView(_ tableView: TableView, viewFor tableColumn: NSTableColumn?, row: Int) -> View? {
    switch tableColumn!.identifier.rawValue {
    case "Msg":
      var l : Label
      if let t = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? Label {
        l = t
      } else {
        l = Label()
        l.isBordered = false
        l.textColor = Color.darkGray
        l.drawsBackground = false
      }
      l.text = lines[row]
      l.font = self.font
      
      // print("size: ", l.intrinsicContentSize)
      tableView.rowHeight = 2 + l.intrinsicContentSize.height
      
      return l
    default:
      return nil
    }
  }
  
  /*
  public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    switch tableColumn!.identifier.rawValue {
    case "Msg":
      return lines[row]
    default:
      return nil
    }
  }*/
  
  /*
  public func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
    if let x = cell as? NSTextFieldCell {
      x.changeFont(NSFontManager.shared)
      // x.font = tableView.font
    }

   }
 */
  
  
}

#endif


