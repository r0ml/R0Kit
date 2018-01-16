
let textFont = Font(name: "Utopia Std", size: 14)!

public class TagFieldController : CollectionViewController<String, TagView>, CollectionViewDelegateFlowLayout {
  
  var widthConstraint : NSLayoutConstraint!
  
  var heightConstraint : NSLayoutConstraint!
  
  var _tags = [String]()
  public var tags : [String] {
    get { return _tags }
    set { _tags = newValue.sorted()
      self.reloadData()
      self.scrollView.setNeedsLayout()
    }
  }
  
  /** This, in combination with the same function in ScrollView,
      has the effect of  passing the scrolling to the next higher scrolling view */
  /* FIXME:  in the event that I want to handle the scrolling myself, I might need
     to do something else */
  #if os(macOS)
  public override func scrollWheel(with event: Event) {
    self.nextResponder?.scrollWheel(with: event)
  }
  #endif
  
  convenience public init(tags ts : Set<String>) {
    self.init()
//    widthConstraint = self.view.widthAnchor.constraint(equalToConstant: 0)
//    heightConstraint = self.view.heightAnchor.constraint(equalToConstant: 0)
    tags = Array(ts)
//    (self.collectionView.collectionViewLayout as! CollectionViewFlowLayout).scrollDirection = .horizontal
  }
  
  public func intrinsicContentSize(_ s : CGSize) -> CGSize {
    #if os(macOS)
      self.view.setFrameSize(s)
      let ss = self.collectionView.collectionViewLayout!.collectionViewContentSize
    #elseif os(iOS)
      self.view.bounds = CGRect(origin: CGPoint.zero, size: s)
      // let ss = self.collectionView.collectionViewLayout.collectionViewContentSize
      let ss = self.collectionView.contentSize
    #endif
    return ss
  }
  
  override public func setup() {
    
    self.collectionView.backgroundColor = Color(hex: 0xF3F3F3)

    // FIXME: should I keep this?
    // view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    
    // view.myLayer.backgroundColor = Color.purple.cgColor

    // FIXME: I do this because when the scrolling of the superview begins -- the contents
    // of this collectionview shift slightly.  I don't know why or how to prevent that.
    // this prevents the right edge of the slightly shifted collection view from being clipped.
    // The shifting happens the first time the view is scrolled, but then remains that way.
    // So something about the pre-scrolled view is wrong?
    // Perhaps this can be fixed by coercing a scroll?
    
    // view.myLayer.masksToBounds = false
    
    // FIXME: calculate my size
    
  }
  
  /** This is required in order to get the collectionView to size properly in containers */
  #if os(macOS)
  override public func viewDidLayout() {
    doLayout()
  }
  #elseif os(iOS)
  override public func viewDidLayoutSubviews() {
    doLayout()
  }
  #endif
  
  func doLayout() {
    let s = self.intrinsicContentSize( self.scrollView.contentSize)
    if let c = self.widthConstraint {
      c.constant = s.width
    } else {
      self.widthConstraint = self.view.widthAnchor.constraint(equalToConstant: s.width)
    }
    
    if let h = self.heightConstraint {
      h.constant = s.height
    } else {
      self.heightConstraint = self.view.heightAnchor.constraint(equalToConstant: s.height)
    }
    self.widthConstraint.isActive = true
    self.heightConstraint.isActive = true
    
  }

  /*override public func viewWillLayoutSubviews() {
    print("will layout subviews", self.view.frame)
  }
  override public func viewLayoutMarginsDidChange() {
    print("layout margins", self.view.layoutMargins)
  } */
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    /** This is required because the superclass (which is a UIScrollKit) enables
        the pan gesture when the view will appear -- so I need to disable it to prevent
        'scroll within scroll' */
    // self.scrollView.panGestureRecognizer.isEnabled = false
    
    #if os(iOS)
    self.scrollView.isScrollEnabled = false
    #endif
    
    #if os(macOS)
    self.scrollView.verticalScrollElasticity = .none
      self.scrollView.userInteractionEnabled = false
    #endif
    
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
    var size = tags[indexPath.item].size(withAttributes: [NSAttributedStringKey.font: textFont])

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

  override public func setup() {
    // lab.myLayer.backgroundColor = Color.orange.cgColor
    lab.font = textFont
    self.translatesAutoresizingMaskIntoConstraints = false
    lab.addInto(self)
  }
  
  override public func setRepresentedObject(_ x: String) {
    lab.text = x
  }
  
  public override func prepareForReuse() {
    lab.text = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
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
