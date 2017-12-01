//
//  Copyright © 2017 Semasiology. All rights reserved.
//

func drawX(_ rect : CGRect) {
  var iconSize: CGFloat = 10
  var lineWidth: CGFloat = 1
  var lineColor: Color = Color.white.withAlphaComponent(0.54)
  
    let path = BezierPath()
    
    path.lineWidth = lineWidth
    path.lineCapStyle = NSBezierPath.LineCapStyle.roundLineCapStyle
    
    let iconFrame = CGRect(
      x: (rect.width - iconSize) / 2.0,
      y: (rect.height - iconSize) / 2.0,
      width: iconSize,
      height: iconSize
    )
    
    path.move(to: iconFrame.origin)
  
  // FIXME: extend NSBezierPath to handle "line"
    // path.addLine(to: CGPoint(x: iconFrame.maxX, y: iconFrame.maxY))
  path.line(to: CGPoint(x: iconFrame.maxX, y: iconFrame.maxY))
  
    path.move(to: CGPoint(x: iconFrame.maxX, y: iconFrame.minY))
    // path.addLine(to: CGPoint(x: iconFrame.minX, y: iconFrame.maxY))
    path.line(to: CGPoint(x: iconFrame.minX, y: iconFrame.maxY))
  
    lineColor.setStroke()
    
    path.stroke()
  
}



// UIGraphicsBeginImageContextWithOptions
// UIGraphicsGetImageFromCurrentImageContext

public class DownView : ImageView {
  override public func draw(_ drect : CGRect) {
  
    let lineWidth: CGFloat = 2
    let lineColor: Color = Color.darkGray.withAlphaComponent(0.54)
  
  let path = BezierPath()
  
  let rect = self.bounds
  path.lineWidth = lineWidth
  path.lineCapStyle = NSBezierPath.LineCapStyle.roundLineCapStyle
  
  path.move(to: CGPoint(x: rect.width / 2 - 5, y: rect.height-1))
    path.line(to: CGPoint(x: rect.width / 2 - 5, y: rect.height * 0.25))
    path.line(to: CGPoint(x: rect.width / 2 - 15, y: rect.height * 0.25))
    path.line(to: CGPoint(x: rect.width / 2, y: 1 ))
  path.line(to: CGPoint(x: rect.width / 2 + 15, y: rect.height * 0.25 ))
  path.line(to: CGPoint(x: rect.width / 2 + 5, y: rect.height * 0.25))
  path.line(to: CGPoint(x:rect.width / 2 + 5, y: rect.height-1))
    path.line(to: CGPoint(x: rect.width / 2 - 5, y : rect.height-1))
    
  // FIXME: extend NSBezierPath to handle "line"
  // path.addLine(to: CGPoint(x: iconFrame.maxX, y: iconFrame.maxY))
  lineColor.setStroke()
  path.stroke()
    Color.green.withAlphaComponent(0.3).setFill()
    path.fill()
}
}
extension CGPoint {
  static func +(a:CGPoint, b:CGPoint) -> CGPoint {
    return CGPoint(x: a.x+b.x, y: a.y+b.y)
  }
}

public class CloudView : ImageView {
  override public func draw(_ drect : CGRect) {
    
    let lineWidth: CGFloat = 2
    let lineColor: Color = Color.darkGray.withAlphaComponent(0.54)
    
    let path = BezierPath()
    
    let rect = self.bounds
    path.lineWidth = lineWidth
    path.lineCapStyle = NSBezierPath.LineCapStyle.roundLineCapStyle
    path.lineJoinStyle = .miterLineJoinStyle
  
    let lw = lineWidth
    
    let fi = CGFloat((sqrt(5) + 1) / 2)
    let scl = floor(CGFloat(rect.width - lw) / fi )

    let pt = CGPoint(x: (lw/2)+(scl/(2*fi)), y: (lw/2) )

    path.move(to: pt)
    let pt2 = CGPoint( x: (scl * (fi-0.25)) - (lw/2), y: lw/2)
    path.line(to: pt2)
    
    let pt3 = pt2 + CGPoint(x: 0, y: scl * 0.25 )
    // path.appendArc(from: pt2, to: pt3, radius: CGFloat(scl) )
    path.appendArc(withCenter: pt3, radius: scl * 0.25, startAngle: -90, endAngle: 83)
    
    let pt4 = CGPoint(x: (lw/2) + scl, y: (lw/2) + scl * (1-(fi*0.25)) )
    path.appendArc(withCenter: pt4, radius: scl * (fi * 0.25), startAngle: -13, endAngle: 142)

    let x6 = (lw/2)+(scl / (2*fi) ) + (scl/(2*fi*fi))
    let pt6 = CGPoint(x: x6, y : (lw/2) + (scl / fi))
    path.appendArc(withCenter: pt6, radius: scl / (2 * fi * fi), startAngle: 49, endAngle: 180)

    let x5 = (lw/2) + scl / (2 * fi)
    let pt5 = CGPoint(x: x5, y: x5)
    path.appendArc(withCenter: pt5, radius: scl / (2 * fi), startAngle: 90, endAngle: 270)
    
    
    // FIXME: extend NSBezierPath to handle "line"
    // path.addLine(to: CGPoint(x: iconFrame.maxX, y: iconFrame.maxY))
    lineColor.setStroke()
    path.stroke()
    
    Color.green.withAlphaComponent(0.3).setFill()
    path.fill()
  }
}



