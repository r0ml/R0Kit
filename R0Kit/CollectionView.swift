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
    public func register<T>(_ cl : CollectionItemShim<T>.Type) {
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
    
    public func register<T>(_ cl : CollectionItemShim<T>.Type) {
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
      return true
    }
  }
#endif

#if os(macOS)
  extension CollectionView {
    public func makeCell<U, T : CollectionReusableView<U> >(_ indexPath: IndexPath, _ fn : @escaping (T)->Void) -> CollectionItemShim<T> {
      if let item = self.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: T.identifier), for: indexPath) as? CollectionItemShim<T> {
        fn(item.itemView as! T)
        return item
      } else {
        let z = CollectionItemShim<T>.init(frame: CGRect.zero)
        fn(z.itemView as! T)
        return z
      }
    }
  }
  
#elseif os(iOS)
  extension CollectionView {
    public func makeCell<U, T : CollectionReusableView<U> >(_ indexPath: IndexPath, _ fn: @escaping (T) -> Void) -> CollectionItemShim<T> {
      if let cell = self.dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? CollectionItemShim<T> {
        fn(cell.itemView as! T)
        return cell
      }
      print("cant get here")
      return CollectionItemShim<T>()
    }
  }
#endif

// because macos wants "itemForRepresentedObjectAt"  and iOS wants "cellForItemAt" there doesn't appear to be a way
// to do this with typealiasing
// So I create a subclass to have a single method that serves both purposes.
// The required method (which needs to be overridden) now becomes: collectionView(cellForItemAt:in:)->CollectionViewItem
// which should look like:
// return collectionView.makeCell(indexPath) { your code here }

open class CollectionViewController<U, T : CollectionReusableView<U> > : ViewController, CollectionViewDataSource, CollectionViewDelegate {

  open func numberOfSections(in collectionView: CollectionView) -> Int {
    return 0
  }
  open func collectionView(_ collectionView: CollectionView, numberOfItemsInSection section: Int) -> Int {
    return 0
  }
  
  #if os(macOS)
  public func collectionView(_ collectionView : CollectionView,
                             itemForRepresentedObjectAt indexPath: IndexPath) -> CollectionViewItem {
    return self.collectionView(cellForItemAt: indexPath, in: collectionView)
  }
  #elseif os(iOS)
  public func collectionView(_ collectionView : CollectionView,
                             cellForItemAt indexPath: IndexPath) -> CollectionViewItem {
    return self.collectionView(cellForItemAt: indexPath, in: collectionView)
  }
  #endif
  
  open func collectionView( cellForItemAt indexPath: IndexPath, in collectionView: CollectionView ) -> CollectionItemShim<T> {
    return collectionView.makeCell(indexPath) { (T) -> Void in }
  }
  
  #if os(macOS)
  open func collectionView(_ collectionView: CollectionView, viewForSupplementaryElementOfKind kind: CollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> View {
    return View()
  }
  #endif

  
}


// CollectionViewController

#if os(iOS)
  open class R0CollectionViewController<VV, UU : CollectionReusableView<VV>> : CollectionViewController<VV, UU> {
    
    public typealias Shim = CollectionItemShim<UU>
    
    public var collectionView = CollectionView(empty: true)
    
    public static func addToMenu() {
    }
    
    open func setup() {
      fatalError("failed to override R0CollectionViewController.setup")
    }

    public required init(with cellType: Shim.Type) {
      super.init()
      collectionView.delegate = self
      collectionView.dataSource = self
      collectionView.register(cellType)
      setup()
    }
    
    public required convenience init() {
      self.init(with: Shim.self)
    }
    
    public required convenience init?(coder: NSCoder) {
      fatalError("init?(coder:) not implemented")
    }
    
  }
  
#endif

#if os(macOS)
  
  open class R0CollectionViewController<VV, UU: CollectionReusableView<VV>> : CollectionViewController<VV, UU> {
    public var collectionView = CollectionView(empty: true)
    
    public typealias Shim = CollectionItemShim<UU>

    open func setup() {
      fatalError("failed to override R0CollectionViewController.setup")
    }
    
    public required init(with cellType: Shim.Type) {
      super.init()
      collectionView.delegate = self
      collectionView.dataSource = self
      
      // *********************************************************************************
      // THE DELEGATE, DATASOURCE, AND COLLECTIONVIEWLAYOUT MUST BE SET BEFORE REGISTERING
      // *********************************************************************************
      
      collectionView.register(cellType)
      setup()
    }
    
    public required convenience init() {
      self.init(with: Shim.self) // ("call init(on:, with:)")
    }
    
    public required convenience init?(coder: NSCoder) {
      fatalError("init?(coder:) not implemented")
    }
    
  }
  
  
  
#endif

open class CollectionItemShim<T> : CollectionViewCell {
  open class var identifier : String { return CollectionReusableView<T>.identifier }
  
  var itemView: CollectionReusableView<T>
  
  public required init(frame: CGRect) {
    itemView = CollectionReusableView<T>()
    super.init(frame: frame)
    // ***** DON'T FORGET THIS, OR NOTHING WILL SHOW UP ***
    itemView.addInto(self.contentView)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func prepareForReuse() {
    itemView.prepareForReuse()
  }
}


