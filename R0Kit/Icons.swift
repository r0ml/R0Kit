//
//  Copyright © 2017 Semasiology. All rights reserved.
//

// UIGraphicsBeginImageContextWithOptions
// UIGraphicsGetImageFromCurrentImageContext

/*
 public func makeImage(_ sz : CGSize, _ fn : @escaping (CGSize)->Void) -> Image? {
 let im = NSImage(size: sz)
 im.lockFocus()
 fn(sz)
 return im
 }*/

/*
 public enum IconType {
 case downArrow
 case upArrow
 case cloud
 case downloadCloud
 case uploadCloud
 }
 
 public class IconView : ImageView {
 let iconType : IconType
 let fn : (NSEvent) -> Void
 
 public init(_ t : IconType, frame: CGRect, _ fn : @escaping (NSEvent) -> Void ) {
 iconType = t
 self.fn = fn
 super.init(frame: frame)
 }
 
 public required init?(coder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
 }
 
 override public func mouseDown(with event: NSEvent) {
 fn(event)
 }
 
 override public func draw(_ drect : CGRect) {
 switch(iconType) {
 case .downArrow: drawArrow(self.bounds, false )
 case .upArrow: drawArrow(self.bounds, true)
 */

public class Icon {
  static let lineWidth: CGFloat = 2
  static let lineColor: Color = Color.darkGray.withAlphaComponent(0.54)
  static let fillColor: Color = Color.green.withAlphaComponent(0.3)
  
  public static func downArrow(_ size: CGSize) {
    drawArrow(CGRect(origin: CGPoint.zero, size: size), false, lineWidth: lineWidth, lineColor: lineColor, fillColor: fillColor)
  }
  
  public static func upArrow(_ size: CGSize) {
    drawArrow(CGRect(origin: CGPoint.zero, size: size), true, lineWidth: lineWidth, lineColor: lineColor, fillColor: fillColor)
  }
  
  public static func cloud(_ size : CGSize) {
    let fi = CGFloat((sqrt(5) + 1)/2)
    let h = size.height / fi
    let o = (size.height - h) / 2
    
    let r = CGRect(origin: CGPoint(x: 0, y: o), size: CGSize(width: size.width, height: h))
    drawCloud(r, lineWidth: lineWidth, lineColor: lineColor, fillColor: fillColor )
  }
  
  public static func downloadCloud(_ size: CGSize) {
    let fi = CGFloat((sqrt(5) + 1) / 2)
    let h = size.height / fi
    let r = CGRect(origin: CGPoint(x: 0, y: size.height - h), size: CGSize(width: size.width,
                                                                           height: h))
    drawCloud(r, lineWidth: lineWidth, lineColor: lineColor, fillColor: fillColor)
    let n = size.width / 2
    let r2 = CGRect(origin: CGPoint(x: n / 2, y: 0), size: CGSize(width: n, height: h))
    drawArrow(r2, false, lineWidth: lineWidth, lineColor: lineColor, fillColor: fillColor)
  }
  
  public static func uploadCloud(_ size : CGSize) {
    let fi = CGFloat((sqrt(5) + 1) / 2)
    let h = size.height / fi
    let r = CGRect(origin: CGPoint(x: 0, y: size.height - h), size: CGSize(width: size.width, height: h))
    drawCloud(r, lineWidth: lineWidth, lineColor: lineColor, fillColor: fillColor)
    let n = size.width / 2
    let r2 = CGRect(origin: CGPoint(x: n / 2, y: h / 4), size: CGSize(width: n, height: h))
    drawArrow(r2, true, lineWidth: lineWidth, lineColor: lineColor, fillColor: fillColor)
  }
  
  public static func drawArrow( _ rect : CGRect, _ isFlipped: Bool, lineWidth: CGFloat, lineColor : Color, fillColor : Color) {
    let path = BezierPath()
    let context = UIGraphicsGetCurrentContext()
    context?.saveGState()
    
    context?.translateBy(x: rect.origin.x, y: rect.origin.y + (isFlipped ? rect.height : 0) )
    context?.scaleBy(x: 1, y : isFlipped ? -1 : 1)
    path.lineWidth = lineWidth
    path.lineCapStyle = .round // NSBezierPath.LineCapStyle.roundLineCapStyle
    let aw = rect.width * 0.15
    let hw = aw * 2.6
    let hh = rect.height * 0.35
    path.move(to: CGPoint(x: rect.width / 2 - aw, y: rect.height-1))
    path.addLine(to: CGPoint(x: rect.width / 2 - aw, y: hh))
    path.addLine(to: CGPoint(x: rect.width / 2 - hw, y: hh))
    path.addLine(to: CGPoint(x: rect.width / 2, y: 1 ))
    path.addLine(to: CGPoint(x: rect.width / 2 + hw, y: hh ))
    path.addLine(to: CGPoint(x: rect.width / 2 + aw, y: hh))
    path.addLine(to: CGPoint(x:rect.width / 2 + aw, y: rect.height-1))
    path.addLine(to: CGPoint(x: rect.width / 2 - aw, y : rect.height-1))
    
    // FIXME: extend NSBezierPath to handle "line"
    // path.addLine(to: CGPoint(x: iconFrame.maxX, y: iconFrame.maxY))
    lineColor.setStroke()
    path.stroke()
    fillColor.setFill()
    path.fill()
    
    context?.restoreGState()
  }
  
  public static func drawCloud(_ rect : CGRect, lineWidth: CGFloat, lineColor: Color, fillColor: Color) {
    let context = UIGraphicsGetCurrentContext()
    context?.saveGState()
    context?.translateBy(x: rect.origin.x, y: rect.origin.y)
    
    let path = BezierPath()
    path.lineWidth = lineWidth
    path.lineCapStyle = .round //  BezierPath.LineCapStyle.roundLineCapStyle
    path.lineJoinStyle = .bevel   //   .bevelLineJoinStyle
    
    let lw = lineWidth
    
    let fi = CGFloat((sqrt(5) + 1) / 2)
    let scl = floor(CGFloat(rect.width - lw) / fi )
    
    let pt = CGPoint(x: (lw/2)+(scl/(2*fi)), y: (lw/2) )
    
    path.move(to: pt)
    let pt2 = CGPoint( x: (scl * (fi-0.25)) - (lw/2), y: lw/2)
    // path.line(to: pt2)
    path.addLine(to: pt2)
    
    let pt3 = pt2 + CGPoint(x: 0, y: scl * 0.25 )
    // path.appendArc(from: pt2, to: pt3, radius: CGFloat(scl) )
    // path.appendArc(withCenter: pt3, radius: scl * 0.25, startAngle: -90, endAngle: 83.8)
    path.addArc(withCenter: pt3, radius: scl * 0.25, startAngle: -90, endAngle: 83.8, clockwise: false)
    
    let pt4 = CGPoint(x: (lw/2) + scl, y: (lw/2) + scl * (1-(fi*0.25)) )
    // path.appendArc(withCenter: pt4, radius: scl * (fi * 0.25), startAngle: -13.4, endAngle: 142)
    path.addArc(withCenter: pt4, radius: scl * (fi * 0.25), startAngle: -13.4, endAngle: 142, clockwise: false)
    
    let x6 = (lw/2)+(scl / (2*fi) ) + (scl/(2*fi*fi))
    let pt6 = CGPoint(x: x6, y : (lw/2) + (scl / fi))
    // path.appendArc(withCenter: pt6, radius: scl / (2 * fi * fi), startAngle: 49, endAngle: 180)
    path.addArc(withCenter: pt6, radius: scl / (2 * fi * fi), startAngle: 49, endAngle: 180, clockwise: false)
    
    let x5 = (lw/2) + scl / (2 * fi)
    let pt5 = CGPoint(x: x5, y: x5)
    // path.appendArc(withCenter: pt5, radius: scl / (2 * fi), startAngle: 90, endAngle: 270)
    path.addArc(withCenter: pt5, radius: scl / ( 2 * fi), startAngle: 90, endAngle: 270, clockwise: false)
    
    // FIXME: extend NSBezierPath to handle "line"
    // path.addLine(to: CGPoint(x: iconFrame.maxX, y: iconFrame.maxY))
    lineColor.setStroke()
    path.stroke()
    
    fillColor.setFill()
    path.fill()
    
    context?.restoreGState()
  }
  
  
}
