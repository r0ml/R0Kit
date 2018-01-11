
let textFont = Font(name: "Utopia Std", size: 14)!

public class TagFieldController : CollectionViewController<String, TagView>, CollectionViewDelegateFlowLayout {
  var _tags = [String]()
  public var tags : [String] {
    get { return _tags }
    set { _tags = newValue; self.collectionView.reloadData(); self.collectionView.setNeedsLayout(); self.collectionView.needsDisplay = true }
  }
  
  override public func setup() {
    view = collectionView
    // FIXME: calculate my size?
    view.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
    view.myLayer.backgroundColor = Color.purple.cgColor
    
    // FIXME: I do this because when the scrolling of the superview begins -- the contents
    // of this collectionview shift slightly.  I don't know why or how to prevent that.
    // this prevents the right edge of the slightly shifted collection view from being clipped.
    // The shifting happens the first time the view is scrolled, but then remains that way.
    // So something about the pre-scrolled view is wrong?
    // Perhaps this can be fixed by coercing a scroll?
    view.myLayer.masksToBounds = false
    
  }
  
  
  // section 1 is optical, section 2 is sunglasses?
  override public func numberOfSections(in collectionView: CollectionView) -> Int {
    return 1 // maybe 4 !!
  }
  
  public override func collectionView(_ collectionView: CollectionView, numberOfItemsInSection section: Int) -> Int {
    return tags.count
  }
  
  public override func collectionView(cellForItemAt indexPath: IndexPath, in collectionView: CollectionView ) -> Shim {
    let item = collectionView.makeCell(indexPath) { (x : TagView) -> Void in
      if indexPath.item < self.tags.count {
        x.setRepresentedObject( self.tags[indexPath.item] )
      } else {
        print("cellForItemAt: indexPath: \(indexPath.item), tags.count = \(self.tags.count)")
      }
    }
    return item
  }
  
  override public func collectionView(_ collectionView: CollectionView, layout collectionViewLayout: CollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
   // let titleLabel = Label()
   // if indexPath.item < tags.count {
   //   titleLabel.text = tags[indexPath.item]
   // } else {
   //   print("sizeForItemAt: indexPath: \(indexPath.item), tags.count = \(self.tags.count)")
   // }
    var size = tags[indexPath.item].size(withAttributes: [NSAttributedStringKey.font: textFont]) ?? CGSize.zero

    // FIXME:  Don't know why this 4
    size.width += 4
    
    // FIXME: I did this in order to round to the nearest integer in case this was causing
    // the minor shift of the collection items.
    size.width = floor(size.width + 1)
    return size
  }
  
  /*public func collectionView(_ collectionView: CollectionView, layout collectionViewLayout: CollectionViewLayout, insetForSectionAt section: Int) -> EdgeInsets {
    return EdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
  }*/
  
  override public func collectionView(_ collectionView: CollectionView, layout collectionViewLayout: CollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 5
  }

  override public func collectionView(_ collectionView: CollectionView, layout collectionViewLayout: CollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 2
  }
  
}

public class TagView : CollectionReusableView<String> {
  public var lab = Label()
  
/*  override public var isHidden : Bool {
    get { return super.isHidden }
    set {
      print("tagview isHidden = \(newValue)")
      super.isHidden = newValue
    }
  } */
  
  /*override public func viewDidUnhide() {
    print("viewDidUnhide")
  }
  
  override public func viewDidHide() {
    print("viewDidHide")
    self.isHidden = false // .viewDidHide()
  } */
  
  override public func setup() {
    lab.myLayer.backgroundColor = Color.orange.cgColor
    lab.font = textFont
    lab.addInto(self)
  }
  
  override public func setRepresentedObject(_ x: String) {
    lab.text = x
  }
  
  public override func prepareForReuse() {
    lab.text = ""
  }
  
}


/*
open class TagListView: UIView {
    
    // MARK: - Manage tags
    
    override open var intrinsicContentSize: CGSize {
        var height = CGFloat(rows) * (tagViewHeight + marginY)
        if rows > 0 {
            height -= marginY
        }
        return CGSize(width: frame.width, height: height)
    }
}
 
 private func setupView() {
 titleLabel?.lineBreakMode = titleLineBreakMode
 
 frame.size = intrinsicContentSize
 addSubview(removeButton)
 removeButton.tagView = self
 
 let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
 self.addGestureRecognizer(longPress)
 }

 // MARK: - layout
 
 override open var intrinsicContentSize: CGSize {
 var size = titleLabel?.text?.size(withAttributes: [NSAttributedStringKey.font: textFont]) ?? CGSize.zero
 size.height = textFont.pointSize + paddingY * 2
 size.width += paddingX * 2
 if size.width < size.height {
 size.width = size.height
 }
 if enableRemoveButton {
 size.width += removeButtonIconSize + paddingX
 }
 return size
 }

 
 
 
 */
