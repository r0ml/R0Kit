
// ===========================  HideableView ===================================

/** A HideableView merely wraps an inner view.  The view can then be hidden by
 removing it from the wrapper view.  To show it, the inner view is re-added
 to the wrapper view.
 
 Cleverness about fiddling with constraints (and the like) seemed to cause more
 problems than they solved */
public class HideableView<T : View> : View {
  public var innerView : T
  
  public var zconst = [NSLayoutConstraint]()
  /* public var xconst = [NSLayoutConstraint]()
   public var yconst = [NSLayoutConstraint]()
   */
  
  /** The view which this HideableView wraps */
  public init(_ view : T) {
    self.innerView = view
    super.init(frame: CGRect.zero)
    innerView.addInto(self)
    
    /*self.xconst = self.constraints
     self.yconst = innerView.constraints
     */
    
    // FIXME:  It works right for vertical stacks
    // a horizontal stack should use a constraint in the other direction
     self.zconst = [
     // FIXME: None of this seems to work right
     // self.widthAnchor.constraint(equalToConstant: 0),
       self.heightAnchor.constraint(equalToConstant: 0)
     // innerView.widthAnchor.constraint(equalToConstant: 0),
     // innerView.heightAnchor.constraint(equalToConstant: 0)
     ]
     /*self.constraints.forEach { $0.priority = UILayoutPriority(rawValue: Float(min(999, Int($0.priority.rawValue)))) } */
  }
  
  /** This is not implemented and shouldn't be used */
  public required init(coder: NSCoder) {
    fatalError("not implemented yet")
  }
  
  /** When a view 'isHidden', it still participates in auto-layout.
   A HideableView overrides this behavior by removing the view from
   the subviews, and then restoring it when it is no longer hidden
   */
  override public var isHidden : Bool { get {
    return super.isHidden
    }
    set {
      if newValue {
        super.isHidden = true
        innerView.isHidden = true
        /*self.yconst.forEach { $0.isActive = false }
         self.xconst.forEach { $0.isActive = false }
         */
        
        innerView.removeFromSuperview()
        zconst.forEach { $0.isActive = true }
        
        
        /*let cc = self.constraints.filter { if let j = $0.secondItem as? View, j == self { return true } else { return false }}
         self.removeConstraints(cc)*/
        
      } else {
        super.isHidden = false
        innerView.isHidden = false
        zconst.forEach { $0.isActive = false }
        /* xconst.forEach { $0.isActive = true }
         yconst.forEach { $0.isActive = true }*/
        innerView.addInto(self)
      }
      self.setNeedsLayout()
    }
  }
  
 /* override public var intrinsicContentSize : CGSize { get { return innerView.intrinsicContentSize }}
  
  override public var fittingSize : CGSize { get { return innerView.fittingSize }}
  */
  
}

// ============================ Convenience methods ==========================

extension Color {
  public convenience init(hex: UInt32) {
    let f = { (x:UInt32,y:Int) in CGFloat( (x >> y) & 0xff) / 255.0 }
    self.init(red: f(hex, 16) , green: f(hex, 8), blue: f(hex, 0), alpha: 1)
  }
}

extension CGPoint {
  public static func +(a:CGPoint, b:CGPoint) -> CGPoint {
    return CGPoint(x: a.x+b.x, y: a.y+b.y)
  }
}
