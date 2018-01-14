// ==============================  Stacker *====================================

extension View {
  /** Create an instance of Stacker for this view to be used to lay out horizontal
   or vertical subview stacks */
  public func stacker(vertical : Bool = false) -> Stacker {
    self.translatesAutoresizingMaskIntoConstraints = false
    return Stacker(self, vertical: vertical)
  }
}

/** This is a helper class which lets me create horizontal
 or vertical stacks of views using constraints */
public class Stacker {
  let view : View
  var prev : View? = nil
  var pad : CGFloat = 0
  var cntr : Bool = false
  var vert : Bool
  var ins : CGFloat = 5
  var pct : CGFloat = 0
  
  init(_ v : View, vertical : Bool) { view = v; vert = vertical }
  
  @discardableResult public func pad(_ p : CGFloat) -> Stacker {
    pad = p
    return self
  }
  
  @discardableResult public func spread(_ p : CGFloat) -> Stacker {
    pct = p
    return self
  }
  
  @discardableResult public func center() -> Stacker {
    cntr = true
    return self
  }
  
  @discardableResult public func inset(_ i : CGFloat) -> Stacker {
    ins = i
    cntr = false
    return self
  }
  
  @discardableResult public func views(_ v : [View]) -> Stacker {
    v.forEach { self.view($0) }
    return self
  }
  
  /** Add a view to the stack */
  // TODO: If the view is a HideableView, automatically remove the pad?
  // HideableViews would need to embed a "when I'm visible this is my padding" parameter
  @discardableResult public func view(_ v : View) -> Stacker {
    view.addSubview(v)
    v.translatesAutoresizingMaskIntoConstraints = false
    if let p = prev {
      if vert {
        v.topAnchor.constraint(equalTo: p.bottomAnchor, constant: pad).isActive = true
      } else {
        v.leadingAnchor.constraint(equalTo: p.trailingAnchor, constant: pad).isActive = true
      }
    } else {
      if vert {
        v.topAnchor.constraint(equalTo: view.topAnchor, constant: pad).isActive = true
      } else {
        v.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad).isActive = true
      }
    }
    if vert {
      if cntr {
        v.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
      } else {
        v.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ins).isActive = true
      }
      v.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -2 * ins).isActive = true
      
      if pct != 0 {
        v.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: pct, constant: -2 * pad).isActive = true
      } else {
        let vz = v.intrinsicContentSize
        // FIXME:  This breaks the Swatch selector -- but if I can find a better way,
        // I should use that -- this constraint conflicts with height==width
        if vz.height > 0 && v.classForCoder == Label.self {
          v.heightAnchor.constraint(equalToConstant: vz.height).isActive = true
        }
      }
    } else {
      if cntr {
        v.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
      } else {
        v.topAnchor.constraint(equalTo: view.topAnchor, constant: ins).isActive = true
      }
      v.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -2 * ins).isActive = true
      if pct != 0 {
        v.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: pct, constant: -2 * pad).isActive = true
      } else {
        // FIXME:
      }
    }
    prev = v
    return self
  }
  
  /** wrap up the creation of a stack by adding constraints from the last
   view in the stack to the parent's edge */
  @discardableResult public func end() -> View {
    let p = prev == nil ? view : prev!
    if vert {
      // FIXME:  This seems to work if I toss an empty view before the end()
      // if that's the case, I should automatically toss an empty view in here
      
      // The reason for
      // p.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -pad).isActive = true
      p.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -pad).isActive = true
    } else {
      // p.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -pad).isActive = true
      p.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad).isActive = true
    }
    prev = nil
    pad = 0
    pct = 0
    ins = 5
    cntr = false
    return view
  }
}

// =========================== fitInto / addInto ===========================

extension View {
  public func guide(insetBy: EdgeInsets) -> LayoutGuide {
    let z = LayoutGuide()
    self.addLayoutGuide(z)
    
    #if os(macOS)
      let rtol = self.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirection.rightToLeft
    #elseif os(iOS)
      let rtol = self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft
      // let rtol = UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == UIUserInterfaceLayoutDirection.rightToLeft
    #endif
    
    (z.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -insetBy.bottom)).isActive=true
    (z.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: rtol ? -insetBy.right : insetBy.left)).isActive = true
    (z.topAnchor.constraint(equalTo: self.topAnchor, constant: insetBy.top)).isActive=true
    (z.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: rtol ? insetBy.left : -insetBy.right)).isActive=true
    return z
  }
  
  public func addInto(guide: LayoutGuide, with: [Constraint] = [.top, .bottom, .leading, .trailing] ) {
    if let ov = guide.owningView {
      let z = self // .superview == nil ? self : self.superview!
      ov.addSubview(z)
      z.fitInto(guide, with: with)
    }
  }
  
  public func addInto(_ view: View, with: [Constraint] =
    [.top, .bottom, .leading, .trailing]) {
    let z = self // self.superview == nil ? self : self.superview!
    view.addSubview(z)
    z.fitInto(view.guide(insetBy: EdgeInsets() ), with: with)
  }
  
  public func fitInto(_ view: LayoutGuide, with: [Constraint] = [.top, .bottom, .leading, .trailing]) {
    var cs = Array<NSLayoutConstraint>()
    self.translatesAutoresizingMaskIntoConstraints = false
    with.forEach {
      switch $0 {
      case .top: cs.append(self.topAnchor.constraint(equalTo: view.topAnchor))
      case .bottom: cs.append(self.bottomAnchor.constraint(equalTo: view.bottomAnchor))
      case .leading: cs.append(self.leadingAnchor.constraint(equalTo: view.leadingAnchor))
      case .trailing: cs.append(self.trailingAnchor.constraint(equalTo: view.trailingAnchor))
      case .width: cs.append(self.widthAnchor.constraint(equalTo: view.widthAnchor))
      case .height: cs.append(self.heightAnchor.constraint(equalTo: view.heightAnchor))
      case .centerX: cs.append(self.centerXAnchor.constraint(equalTo: view.centerXAnchor))
      case .centerY: cs.append(self.centerYAnchor.constraint(equalTo: view.centerYAnchor))
      case .widthMinus(let z): cs.append(self.widthAnchor.constraint(equalTo: view.widthAnchor,  constant: -z))
      case .heightMinus(let z): cs.append(self.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -z))
        
      case .topPad(let z): cs.append(self.topAnchor.constraint(equalTo: view.topAnchor, constant: z))
      case .bottomPad(let z): cs.append(self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -z))
      case .leadingPad(let z): cs.append(self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: z))
      case .trailingPad(let z): cs.append(self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -z))
      case .centerXOffset(let z): cs.append(self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: z))
      case .centerYOffset(let z): cs.append(self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: z))
      }
    }
    NSLayoutConstraint.activate( cs )
  }
}

/** This enumeration defines the constraints which can be used when
 specifying an 'addInto' view.  Each case is a constraint relating
 a constraint from an attribute of the subview to the corresponding
 attribute of its superview */
public enum Constraint {
  case top
  case bottom
  case leading
  case trailing
  case width
  case height
  case centerX
  case centerY
  /*   case topMargin
   case bottomMargin
   case leadingMargin
   case trailingMargin
   case widthWithMargins
   case heightWithMargins
   case centerXWithMargins
   case centerYWithMargins
   */
  case widthMinus(CGFloat)
  case heightMinus(CGFloat)
  case topPad(CGFloat)
  case bottomPad(CGFloat)
  case leadingPad(CGFloat)
  case trailingPad(CGFloat)
  case centerXOffset(CGFloat)
  case centerYOffset(CGFloat)
  static var all : [ Constraint ] {
    get { return [.top, .bottom, .leading, .trailing] }
  }
}

// ======================== Transition animation =============================
extension View {
  
  // Name this function in a way that makes sense to you...
  // slideFromLeft, slideRight, slideLeftToRight, etc. are great alternative names
  func slideIn(duration: TimeInterval = 1.0, direction: String
    /*, completionDelegate: AnyObject? = nil */) {
    // Create a CATransition animation
    let slideInFromLeftTransition = CATransition()
    
    // Set its callback delegate to the completionDelegate that was provided (if any)
    /*  if let delegate: AnyObject = completionDelegate {
     slideInFromLeftTransition.delegate = delegate as! CAAnimationDelegate
     } */
    
    // Customize the animation's properties
    slideInFromLeftTransition.type = kCATransitionPush
    slideInFromLeftTransition.subtype = direction
    slideInFromLeftTransition.duration = duration
    slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    slideInFromLeftTransition.fillMode = kCAFillModeRemoved
    
    // Add the animation to the View's layer
    self.myLayer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
  }
}

// ============================ Gestures ========================================
extension View {
  public func onGesture<T : GestureRecognizer>(param : @escaping ((T) -> Void) = { (_ : T) in }, _ fn : @escaping (T) -> Void) {
    let x = ClosX( {
      if let d = $0 as? T { fn(d) }
    })
    let m = T(target: x, action: x.selector)
    param(m)
    self.addGestureRecognizer( m )
  }
}

// =========================== EdgeInsets =====================================
extension EdgeInsets {
  public init(all: CGFloat) {
    self.init(top: all, left: all, bottom: all, right: all)
  }
  public init(horiz: CGFloat, vert: CGFloat) {
    self.init(top: vert, left: horiz, bottom: vert, right: horiz)
  }
}

// ============================= Gestures ====================================
extension View {
  public func onPressGesture( _ n : Int, _ t : TimeInterval, _ fn: @escaping(AnyObject?) -> Void) {
    let x = ClosX(fn)
    let z = PressGestureRecognizer(target: x, action: x.selector)
    z.minimumPressDuration = t
    #if os(macOS)
      z.buttonMask = n
    #endif
    
    self.addGestureRecognizer(z)
  }
}



// ==========================================================================

// ========================== Image Preview =================================

#if os(iOS)

  public class PopupImageController : UIViewController {
    
    
    var imageView: UIImageView!
    
    public override func viewDidLoad() {
      super.viewDidLoad()
      
     
      self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
      self.view.layer.cornerRadius = 5
      self.view.layer.shadowOpacity = 0.5
      self.view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
      
      self.imageView = ImageView()
      imageView.addInto(self.view)
      
      //Tap gesture on image
    /*  let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(_:)))
      imageView.isUserInteractionEnabled = true
      imageView.addGestureRecognizer(tapGestureRecognizer)
      self.view.isUserInteractionEnabled = true
      */
      
      imageView.isUserInteractionEnabled = true
      imageView.onGesture { (x : TapGestureRecognizer) in
        self.dismiss(animated: true) {
          
        }
      }
      
      // Do any additional setup after loading the view.
    }
    
    public override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
    }
    
    public func showInView(_ aView: ViewController, withImage image : UIImage!,animated: Bool)
    {
      if imageView == nil {
        self.viewDidLoad()
      }
      
      imageView.image = image

      // aView.addSubview(self.view)
      self.modalPresentationStyle = .overCurrentContext
      aView.present(self, animated: true) {
          print("all done")
      }
      
      //        let imageView = UIImageView(image: image!)
      //        imageView.image = image;
      
      /** Get Device Screen Size **/
      //        let screenSize = UIScreen.main.bounds
      //        let cgFloatWidth: CGFloat = screenSize.width
      //        let width = Float(cgFloatWidth)
      //        let cgFloatHeight: CGFloat = screenSize.height
      //        let height = Float(cgFloatHeight)
      //
      //
      //        print(image.size.height);
      //        print(image.size.width);
      //
      //        print(screenSize.height);
      //        print(screenSize.width);
      //
      //        var x:Float = 0.0
      //        var y:Float = 0.0
      //        if(image.size.width > screenSize.width || image.size.height > screenSize.height){
      //            x = width-80.0;
      //            y = height-250.0;
      //        }else{
      //            x = width;
      //            y = height;
      //        }
      
      
      //self.popUpView.frame = CGRect(x:0, y:0 , width:Int(x), height:Int(y))
      //imageView.frame = CGRect(x: 0, y: 0, width: Int(x), height: Int(y));
      // self.popUpView.addSubview(imageView);
      
      if animated
      {
        self.showAnimate()
      }
    }
    
    func showAnimate()
    {
      self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
      self.view.alpha = 0.0;
      UIView.animate(withDuration: 0.25, animations: {
        self.view.alpha = 1.0
        self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
      });
    }
    
    /*func removeAnimate()
    {
      UIView.animate(withDuration: 0.25, animations: {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
      }, completion:{(finished : Bool)  in
        if (finished)
        {
          self.dismiss.removeFromSuperview()
        }
      });
    } */
   /*
    @objc func imageTapped(_ tapGestureRecognizer: UITapGestureRecognizer)
    {
      self.removeAnimate()
    }
*/
}

#endif

