
// FIXME switch to using CollectionView from TableView
#if os(macOS)

  
  /*class MyTableView : TableView {
} */
  
  
public class Transcript: CollectionViewController<NSAttributedString, MyCell>, CollectionViewDelegateFlowLayout {
  var lines: [NSAttributedString] = []
  var limit : Int = 1000
  
    
  override public func setup() {
    NotificationCenter.default.addObserver(forName: Notification.Name.statusUpdate, object: nil, queue: nil) { noti in
      DispatchQueue.main.async {
        if let line = noti.userInfo?["msg"] as? String {
          self.append( line )
        }
      }
    }
    
    NotificationCenter.default.addObserver(forName: Notification.Name.errorReport, object: nil, queue: nil) { noti in
      DispatchQueue.main.async {
        let err = noti.userInfo?["err"] ?? "unknown error"
        let msg = noti.userInfo?["msg"] ?? "unknown msg"
        self.append( "*** \(msg): \(err) ***" )
      }
    }

    }
  
  
  public func append(_ z : String) {
    // before adding stuff, am I at the end?
    
    
    /*let vh = tblv.visibleRect.minY + tblv.visibleRect.height
    let hml = tblv.bounds.height - (lines.count == 0 ? 0 : tblv.rect(ofRow: lines.count-1).height)
    let scrollQ = vh >= hml
    */
    //    if (!scrollQ) {
    //      scrollQ = true
    //     }
    
    let zz = NSAttributedString(string: z)
    lines.append(zz)
    
    
    // self.collectionView.beginUpdates()
    if lines.count > limit {
      lines.removeFirst( lines.count - limit)
      (self.view as! CollectionView).deleteItems(at: [IndexPath(item: 0, section: 0)])
    }
    (self.view as! CollectionView).insertItems(at: [IndexPath(item: lines.count-1, section: 0)])
    // tblv.endUpdates()
    
    /*if scrollQ {
      let st = tblv.bounds.height - tblv.visibleRect.height
      tblv.scroll(CGPoint(x: 0, y: st+tblv.visibleRect.minY ))
    } */
  }

  
  public func makeWindow() -> NSWindow {
    let wnd = NSWindow(contentRect: CGRect(x: 100, y: 100, width: 600, height: 200)
      , styleMask: [.closable, .resizable, .titled, .miniaturizable], backing: .buffered, defer: true)
    wnd.isReleasedWhenClosed = false
    wnd.title = "Transcript"
    wnd.isOpaque = false
    wnd.center()
    let fan = NSWindow.FrameAutosaveName(rawValue: "Transcript")
    
    wnd.setFrameAutosaveName(fan)
    
    let tblv = self.view
    
    let sv = NSScrollView(frame: CGRect.zero)
    sv.hasVerticalScroller = true
    sv.documentView = tblv
    sv.hasHorizontalScroller = true
    sv.autohidesScrollers = false
    
    wnd.contentView = sv

    return wnd
    
  }

  public func open() {
    // wnd.contentView = v
    let wnd = self.makeWindow()
    wnd.makeKeyAndOrderFront(nil)
  }
  

  // section 1 is optical, section 2 is sunglasses?
  override public func numberOfSections(in collectionView: CollectionView) -> Int {
    return 1 // maybe 4 !!
  }
  
  public override func collectionView(_ collectionView: CollectionView, numberOfItemsInSection section: Int) -> Int {
    return lines.count
  }
  
  public override func collectionView(cellForItemAt indexPath: IndexPath, in collectionView: CollectionView ) -> Shim {
    let item = collectionView.makeCell(indexPath) { (x : MyCell) -> Void in
      x.setRepresentedObject( self.lines[indexPath.item] )
      if (indexPath.item % 2) == 1 { x.myLayer.backgroundColor = Color(hex: 0xFCFCFC).cgColor }
    }
    return item
  }
  
  override public func collectionView(_ collectionView: CollectionView, layout collectionViewLayout: CollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if let sv = collectionView.enclosingScrollView?.contentInset {
    let svx = sv.left + sv.right
    let w = collectionView.frame.width - 10 - svx
      
     // let l = self.collectionView(cellForItemAt: indexPath, in: collectionView)
     
      let l = Label()
      l.attributedText = lines[indexPath.item]
      let x = l.sizeThatFits(CGSize(width: w, height: -1))
      return CGSize(width: w, height: x.height)
    } else {
      return CGSize(width: collectionView.frame.width - 10, height: 22)
    }
  }
  
  public func collectionView(_ collectionView: CollectionView, layout collectionViewLayout: CollectionViewLayout, insetForSectionAt section: Int) -> EdgeInsets {
    return EdgeInsets(horiz: 5, vert: 0)
    // return EdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
  }
  
  override public func collectionView(_ collectionView: CollectionView, layout collectionViewLayout: CollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  override public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  }

  /*
public class Transcript : View {
  var lines : [String] = []
  var limit : Int = 1000
  var wnd : NSWindow!
  var tblv : TableView!
  var font : Font?
  
  @objc public override func changeFont(_ x : Any?) {
    let fm = x as? NSFontManager
    // let ff = fm?.selectedFont
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


  public override init(frame: CGRect) {
    super.init(frame: frame)
    makeWindow()
    

  }
  
  public required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
}
*/
  
  /*
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
*/
  

  /*
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
      
      tableView.rowHeight = 2 + l.intrinsicContentSize.height
      
      return l
    default:
      return nil
    }
  }
}
  */
  
  
  public class MyCell: CollectionReusableView<NSAttributedString> {
    public var textField : Label!
    
    override public func setup() {
      let l = Label()
      self.textField = l
      l.isBordered = false
      l.textColor = Color.darkGray
      l.drawsBackground = false
      
      l.addInto(self)
    }
    
    public override func prepareForReuse() {
    }

    override public func setRepresentedObject(_ x: NSAttributedString) {
        let l = self.textField!

        // l.font = ProximaNova(30, bold: true)
      
        l.attributedText = x
      
        let z = l.sizeThatFits(CGSize(width: -1, height: -1))
      // l.setFrameSize(z)

        l.myLayer.shadowColor = Color.white.cgColor
        l.myLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        l.myLayer.shadowOpacity = 1.0
        l.myLayer.shadowRadius = 3.0
        l.myLayer.zPosition = 5
      }
    
  }


#endif


