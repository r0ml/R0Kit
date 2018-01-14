//
//  Copyright © 2017 Semasiology. All rights reserved.
//

#if os(iOS)
  @_exported import UIKit
  public typealias CollectionView = UICollectionView
  public typealias CollectionViewDelegate = UICollectionViewDelegate
  public typealias CollectionViewDataSource = UICollectionViewDataSource
  public typealias CollectionViewItem = UICollectionViewCell
  public typealias CollectionViewLayout = UICollectionViewLayout
  public typealias CollectionViewDelegateFlowLayout = UICollectionViewDelegateFlowLayout
  
#elseif os(macOS)
  @_exported import AppKit
  public typealias CollectionView = NSCollectionView
  public typealias CollectionViewDelegate = NSCollectionViewDelegate
  public typealias CollectionViewDataSource = NSCollectionViewDataSource
  public typealias CollectionViewItem = NSCollectionViewItem
  public typealias CollectionViewLayout = NSCollectionViewLayout
  public typealias CollectionViewDelegateFlowLayout = NSCollectionViewDelegateFlowLayout
  
#endif


#if os(iOS)
  
  open class CollectionViewCell : CollectionViewItem {
  // open class var identifier : String { return "GenericCollectionViewCell" }
    
    override required public init(frame: CGRect) {
      super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
  
  extension CollectionView {
    public func invalidateLayout() {
      self.collectionViewLayout.invalidateLayout()
    }
    public convenience init(empty: Bool) {
      self.init(frame: CGRect.zero, collectionViewLayout: CollectionViewFlowLayout() )
    }
    public func register<U,T>(_ cl : CollectionItemShim<U,T>.Type) {
      register(cl, forCellWithReuseIdentifier: cl.identifier)
    }
  }
  
  public class CollectionViewFlowLayout : UICollectionViewFlowLayout {
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
      return true
    }
  }
  
#elseif os(macOS)

  extension CollectionView {
    public convenience init(empty: Bool) {
      self.init(frame: CGRect.zero, collectionViewLayout: CollectionViewFlowLayout())
    }
    
    public func register<U, T>(_ cl : CollectionItemShim<U, T>.Type) {
      register(cl as AnyClass, forCellWithReuseIdentifier: cl.identifier)
    }
    
    public func register(_ cl : AnyClass, forCellWithReuseIdentifier idx: String) {
      register(cl, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: idx))
    }
    
    public func register(_ cl : AnyClass, forSupplementaryViewOfKind: String, withReuseIdentifier idx: String) {
      register(cl, forSupplementaryViewOfKind: CollectionView.SupplementaryElementKind(rawValue: forSupplementaryViewOfKind), withIdentifier: NSUserInterfaceItemIdentifier(rawValue: idx))
    }
    
    public func invalidateLayout() {
      self.collectionViewLayout?.invalidateLayout()
    }
    
    public convenience init(frame: CGRect, collectionViewLayout: CollectionViewLayout) {
      self.init(frame: frame)
      self.collectionViewLayout = collectionViewLayout
    }
    
  }
  
  open class CollectionViewCell : CollectionViewItem {
    // open class var identifier : String { return "GenericCollectionViewCell" }
    public var contentView = View()
    
    required public init(frame: CGRect) {
      super.init(nibName: nil, bundle: nil)
      self.contentView = View(frame: frame)
    }
    
    convenience public init() {
      self.init(frame: CGRect.zero) // nibName: nil, bundle: nil)
    }
    
    override convenience public init(nibName: NSNib.Name?, bundle: Bundle?) {
      self.init(frame: CGRect.zero)
    }
    
    required public init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    open override func loadView() {
      self.view = self.contentView
    }
    
    open override func prepareForReuse() {
      fatalError("you forgot to implement prepareForReuse in \(type(of: self))")
    }
    
  }
  
  public class CollectionViewFlowLayout : NSCollectionViewFlowLayout {
    public override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
      // ***************************************************
      // Although the documentation just says "return true"
      // one gets a lot of log spewage if the new size is smaller than the old size
      // These two lines fix that problem
      // ***************************************************
      
      // self.collectionView?.setFrameSize(newBounds.size)
      // self.collectionView?.invalidateLayout()
      
      // return true
      
      if let a = self.collectionView, let b = a.enclosingScrollView {
        return !(b.bounds.size == newBounds.size)
      } else {
        return true
      }
    }
  }
#endif

#if os(macOS)
  extension CollectionView {
    public func makeCell<U, T : CollectionReusableView<U> >(_ indexPath: IndexPath, _ fn : @escaping (T)->Void) -> CollectionItemShim<U, T> {
      let item = self.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: T.identifier), for: indexPath) as? CollectionItemShim<U, T> ?? CollectionItemShim<U, T>.init(frame: CGRect.zero)
      item.itemView.myIndexPath = indexPath
      item.itemView.collectionView = self
      fn(item.itemView)
      return item
    }
    
   /* public func makeSupplementary<U, T : CollectionReusableView<U> >(_ indexPath: IndexPath, _ fn : @escaping (T)->Void) -> CollectionItemShim<U, T> {
      if let item = self.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: T.identifier), for: indexPath) as? CollectionItemShim<U, T> {
        fn(item.itemView)
        return item
      } else {
        let z = CollectionItemShim<U, T>.init(frame: CGRect.zero)
        fn(z.itemView)
        return z
      }
    }
*/
    
  
  public func forCell<U, T : CollectionReusableView<U> >(at indexPath: IndexPath, do fn: @escaping (T) -> Void) {
    let c : CollectionItemShim<U,T> = self.item(at: indexPath) as! CollectionItemShim<U, T>
    fn(c.itemView)
  }
    
    public var allowsSelection : Bool {
      get { return isSelectable }
      set { isSelectable = newValue }
    }
    

    
    
  }

#elseif os(iOS)
  extension CollectionView {
    public func makeCell<U, T : CollectionReusableView<U> >(_ indexPath: IndexPath, _ fn: @escaping (T) -> Void) -> CollectionItemShim<U,T> {
      if let cell = self.dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? CollectionItemShim<U,T> {
        cell.itemView.myIndexPath = indexPath
        cell.itemView.collectionView = self
        fn(cell.itemView)
        return cell
      }
      print("cant get here")
      return CollectionItemShim<U,T>()
    }
    
    public func forCell<U, T : CollectionReusableView<U> >(at indexPath: IndexPath, do fn: @escaping (T) -> Void) {
      if let c = self.cellForItem(at: indexPath) as? CollectionItemShim<U, T> {
        fn(c.itemView)
      }
    }
  /*  public func makeSupplementary<U, T : CollectionReusableView<U> >(_ indexPath: IndexPath, _ fn: @escaping (T) -> Void) -> CollectionItemShim<U,T> {
    if let cell = self.dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? CollectionItemShim<U,T> {
      fn(cell.itemView)
      return cell
    }
    print("cant get here")
    return CollectionItemShim<U,T>()
  }
 */
    
  }
  
#endif

// because macos wants "itemForRepresentedObjectAt"  and iOS wants "cellForItemAt" there doesn't appear to be a way
// to do this with typealiasing
// So I create a subclass to have a single method that serves both purposes.
// The required method (which needs to be overridden) now becomes: collectionView(cellForItemAt:in:)->CollectionViewItem
// which should look like:
// return collectionView.makeCell(indexPath) { your code here }

open class CollectionViewController<U, T : CollectionReusableView<U> > : ViewController, CollectionViewDataSource, CollectionViewDelegate {

  // This view is really a UICollectionReusableView

  var headerFn : ((View, IndexPath) -> Void)?
  var headerFnID : String! // UICollectionReusableView.Type?
  
  open func numberOfSections(in collectionView: CollectionView) -> Int {
    return 0
  }
  open func collectionView(_ collectionView: CollectionView, numberOfItemsInSection section: Int) -> Int {
    return 0
  }
 
  // public var collectionView = CollectionView(empty: true)
  public typealias Shim = CollectionItemShim<U, T>

  open func setup() {
    fatalError("failed to override CollectionViewController.setup")
  }
  
  public required init(with cellType: Shim.Type) {
    super.init()
    let v = CollectionView(empty: true)
    v.delegate = self
    v.dataSource = self
    
    // *********************************************************************************
    // THE DELEGATE, DATASOURCE, AND COLLECTIONVIEWLAYOUT MUST BE SET BEFORE REGISTERING
    // *********************************************************************************
    
    v.register(cellType)
    view = v
    setup()
  }

  public required convenience init() {
    self.init(with: Shim.self)
  }

  public required convenience init?(coder: NSCoder) {
    fatalError("init?(coder:) not implemented")
  }
  
  public func reloadData() {
    (self.view as! CollectionView).reloadData()
  }

  public var itemsAreSelectable : Bool {
      get { return (self.view as! CollectionView).allowsSelection }
      set { (self.view as! CollectionView).allowsSelection = newValue }
}
/*
    #elseif os(iOS)
      get { return true }
      set { }
    #endif
  }*/
  
  
  #if os(macOS)

  var lastBounds : CGRect = CGRect.zero
  
  open override func viewWillLayout() {
  super.viewWillLayout()
  let z = view.bounds
  if z == lastBounds { return }
  lastBounds = z
  (view as! CollectionView).invalidateLayout()
  }
  
  // FIXME: should this be true or false?
  open override func viewWillAppear() {
  self.viewWillAppear(false) // I don't know if this should be true or false
  }
  
  open func viewWillAppear(_ animated: Bool) { // just so I can have an override
  }

  
  public func collectionView(_ collectionView : CollectionView,
                             itemForRepresentedObjectAt indexPath: IndexPath) -> CollectionViewItem {
    return self.collectionView(cellForItemAt: indexPath, in: collectionView)
  }
  

  #elseif os(iOS)
  
  
    public static func addToMenu() {
    }
  
  /*
  public func supplementaryHeader<Y, Z : CollectionReusableView<Y>>(_ fn: @escaping (Z, IndexPath) -> Void) {
  
    headerFn = { (a,x) in fn(a as! Z, x) }
    headerFnID = Z.identifier
    
  self.collectionView.register(Z.self, forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: headerFnID)
  }
  */
  
  #endif
  
  public func supplementaryHeader<Y, Z : CollectionReusableView<Y>>(_ fn: @escaping (Z, IndexPath) -> Void) {
    
    headerFn = { (a,x) in fn( a as! Z, x) }
    headerFnID = Z.identifier
    
    (self.view as! CollectionView).register(Z.self, forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: Z.identifier)
  }
  

  
  open func collectionView(cellForItemAt indexPath: IndexPath, in collectionView: CollectionView ) -> CollectionItemShim<U, T> {
    return collectionView.makeCell(indexPath) { (T) -> Void in }
  }
  
  public func collectionView(_ collectionView : CollectionView,
                             cellForItemAt indexPath: IndexPath) -> CollectionViewItem {
    return self.collectionView(cellForItemAt: indexPath, in: collectionView)
  }
  

  
  #if os(macOS)
  open func collectionView(_ collectionView: CollectionView, viewForSupplementaryElementOfKind kind: CollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> View {

    switch kind {
    case .sectionFooter:
      break
    case .sectionHeader:
      let cell = collectionView.makeSupplementaryView(ofKind: .sectionHeader, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: headerFnID), for: indexPath)
      headerFn!(cell, indexPath)
      return cell
    default:
      break
    }
    fatalError("there is way out -- I'm trying to get a supplementary view that doesn't exist")
  
  }
  
  open func collectionView(_ collectionView: CollectionView, didChangeItemsAt indexPaths: Set<IndexPath>, to highlightState: NSCollectionViewItem.HighlightState) {
  indexPaths.forEach {
  switch highlightState {
  case .forSelection:
  self.collectionView(collectionView, didHighlightItemAt: $0)
  case .forDeselection:
  self.collectionView(collectionView, didUnhighlightItemAt: $0)
  case .asDropTarget:
  // FIXME: highlight for Drop Target
  break
  case .none:
  break // v.backgroundColor = Color.white

  }
  }
  }
  
  #elseif os(iOS)
  
  open func collectionView(_ collectionView: CollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
    switch kind {
      case "UICollectionElementKindSectionFooter":
        break
      case "UICollectionElementKindSectionHeader":
        
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerFnID, for: indexPath)
          headerFn!(cell, indexPath)
          return cell
      default:
        break
      }
  fatalError("there is way out -- I'm trying to get a supplementary view that doesn't exist")
    }
  
  #endif

  final public func collectionView(_ collectionView: CollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    indexPaths.forEach { self.collectionView(collectionView, didSelectItemAt: $0) }
  }
  
  open func collectionView(_ collectionView : CollectionView, didSelectItemAt indexPath: IndexPath) {
    print("forgot to override CollectionViewController.didSelectItemAt")
  }
  
  final public func collectionView(_ collectionView: CollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
    indexPaths.forEach { self.collectionView(collectionView, didDeselectItemAt: $0) }
  }
  
  open func collectionView(_ collectionView : CollectionView, didDeselectItemAt indexPath: IndexPath) {
    print("forgot to override CollectionViewController.didDeselectItemAt")
  }

  open func collectionView(_ collectionView: CollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) {
    print("forgot to override CollectionViewController.shouldSelectItemsAt")
  }
  
  open func collectionView(_ collectionView : CollectionView, shouldSelectItemAt indexPath: IndexPath) {
    print("forgot to override CollectionViewController.shouldSelectItemAt")
  }

  open func collectionView(_ collectionView: CollectionView, shouldDeselectItemsAt indexPaths: Set<IndexPath>) {
    print("forgot to override CollectionViewController.shouldDeselectItemsAt")
  }
  
  open func collectionView(_ collectionView : CollectionView, shouldDeselectItemAt indexPath: IndexPath) {
    print("forgot to override CollectionViewController.shouldDeselectItemAt")
  }
  
  open func collectionView(_ collectionView: CollectionView, layout collectionViewLayout: CollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    fatalError("forgot to override CollectionViewController.sizeForItemAt")
  }
  
  open func collectionView(_ collectionView: CollectionView, layout collectionViewLayout: CollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 2
  }
  
  open func collectionView(_ collectionView: CollectionView, layout collectionViewLayout: CollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 2
  }
  
  open func collectionView(_ collectionView: CollectionView, didHighlightItemAt indexPath: IndexPath) {
    print("forgot to override CollectionViewController.didHighlightItemAt")
  }
  
  open func collectionView(_ collectionView: CollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    print("forgot to override CollectionViewController.didUnhighlightItemAt")
  }
  
}

// CollectionViewController
#if os(iOS)
  open class CollectionReusableView<T> : UICollectionReusableView {
    open var myIndexPath : IndexPath?
    open var collectionView : CollectionView?
    
    // private var representedObject : T // since the view is reusable, this has to be modifiable
    open func setRepresentedObject(_ x: T) {
      // representedObject = x
      fatalError("subclass did not override setRepresentedObject")
    }
    
    override public required init(frame: CGRect) {
      super.init(frame: frame)
      self.setup()
    }
    
    public required init?(coder: NSCoder) {
      super.init(coder: coder)
    }
    
    open func setup() {
      fatalError("failed to override CollectionReusableView.setup")
    }
    
    open class var identifier : String { return String(describing: T.self) }
    
  }

#elseif os(macOS)
  
  open class CollectionReusableView<T> : View {
    open class var identifier : String { return String(describing: T.self) }
    
    open var myIndexPath : IndexPath?
    open var collectionView : CollectionView?
    
    public var R0Class : T.Type { return T.self }
    
    // private var representedObject : T?
    open func setRepresentedObject(_ x: T) {
      fatalError("subclass did not override setRepresentedObject")
    }
    
    public override required init(frame: CGRect) {
      super.init(frame: frame)
      self.setup()
    }
    
    public required init?(coder: NSCoder) {
      super.init(coder: coder)
    }
    
    open func setup() {
      fatalError("failed to override CollectionReusableView.setup")
    }
  }
#endif


#if os(macOS)
  
  extension CollectionView {
    public func performBatchUpdates(_ updates: (() -> Void)?,
                                    completion: ((Bool) -> Void)? = nil) {
      self.performBatchUpdates(updates, completionHandler: completion)
    }
  }
  
#endif

open class CollectionItemShim<UU, TT : CollectionReusableView<UU> > : CollectionViewCell {
  open class var identifier : String { return TT.identifier }
  
  public var itemView: TT
  
  public required init(frame: CGRect) {
    itemView = TT(frame: frame)
    super.init(frame: frame)
    // ***** DON'T FORGET THIS, OR NOTHING WIL SHOW UP ***
    itemView.addInto(self.contentView)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func prepareForReuse() {
    itemView.prepareForReuse()
  }
}


