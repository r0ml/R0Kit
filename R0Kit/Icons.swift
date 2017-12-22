//
//  Copyright © 2017 Semasiology. All rights reserved.
//

// algorithmically generated icons

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
  
  public static func drawThumbsUp_1(_ size : CGSize) {
    let context = UIGraphicsGetCurrentContext()!
    
    //// Resize to Target Frame
    context.saveGState()

    // context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
    context.scaleBy(x: size.width / 100, y: size.height / 100)
    
    
    //// Color Declarations
    let fillColor3 = Color(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
    let fillColor4 = Color(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
    
    //// thumbs-up-24107.svg Group
    //// Bezier Drawing
    let bezierPath = BezierPath()
    bezierPath.move(to: CGPoint(x: 85.78, y: 41.31))
    bezierPath.addCurve(to: CGPoint(x: 70.03, y: 44.98), controlPoint1: CGPoint(x: 85.78, y: 41.31), controlPoint2: CGPoint(x: 72.69, y: 47.82))
    bezierPath.addCurve(to: CGPoint(x: 63.24, y: 25.94), controlPoint1: CGPoint(x: 67.38, y: 42.14), controlPoint2: CGPoint(x: 66.72, y: 36.63))
    bezierPath.addCurve(to: CGPoint(x: 57.1, y: 6.56), controlPoint1: CGPoint(x: 59.75, y: 15.25), controlPoint2: CGPoint(x: 58.76, y: 8.9))
    bezierPath.addCurve(to: CGPoint(x: 46.66, y: 16.25), controlPoint1: CGPoint(x: 55.44, y: 4.22), controlPoint2: CGPoint(x: 46.66, y: 11.4))
    bezierPath.addCurve(to: CGPoint(x: 47.65, y: 41.47), controlPoint1: CGPoint(x: 46.66, y: 21.09), controlPoint2: CGPoint(x: 48.48, y: 40.97))
    bezierPath.addCurve(to: CGPoint(x: 27.26, y: 44.65), controlPoint1: CGPoint(x: 46.82, y: 41.98), controlPoint2: CGPoint(x: 29.08, y: 44.48))
    bezierPath.addCurve(to: CGPoint(x: 13.83, y: 44.48), controlPoint1: CGPoint(x: 25.43, y: 44.81), controlPoint2: CGPoint(x: 13.5, y: 41.64))
    bezierPath.addCurve(to: CGPoint(x: 13.33, y: 56.01), controlPoint1: CGPoint(x: 14.16, y: 47.32), controlPoint2: CGPoint(x: 12.5, y: 53))
    bezierPath.addCurve(to: CGPoint(x: 16.65, y: 71.38), controlPoint1: CGPoint(x: 14.16, y: 59.01), controlPoint2: CGPoint(x: 10.18, y: 68.7))
    bezierPath.addCurve(to: CGPoint(x: 23.61, y: 88.92), controlPoint1: CGPoint(x: 11.18, y: 81.06), controlPoint2: CGPoint(x: 15.82, y: 88.58))
    bezierPath.addCurve(to: CGPoint(x: 41.02, y: 94.26), controlPoint1: CGPoint(x: 27.59, y: 89.25), controlPoint2: CGPoint(x: 37.21, y: 96.6))
    bezierPath.addCurve(to: CGPoint(x: 66.39, y: 83.4), controlPoint1: CGPoint(x: 46.66, y: 92.42), controlPoint2: CGPoint(x: 64.23, y: 84.41))
    bezierPath.addCurve(to: CGPoint(x: 76, y: 75.55), controlPoint1: CGPoint(x: 68.38, y: 82.4), controlPoint2: CGPoint(x: 73.52, y: 79.23))
    bezierPath.addCurve(to: CGPoint(x: 89.43, y: 60.02), controlPoint1: CGPoint(x: 78.16, y: 70.54), controlPoint2: CGPoint(x: 89.6, y: 64.86))
    bezierPath.addCurve(to: CGPoint(x: 85.78, y: 41.31), controlPoint1: CGPoint(x: 89.27, y: 55.17), controlPoint2: CGPoint(x: 88.6, y: 40.81))
    bezierPath.close()
    
    bezierPath.usesEvenOddFillRule = true
    
    fillColor3.setFill()
    bezierPath.fill()
    
    
    //// Bezier 2 Drawing
    let bezier2Path = BezierPath()
    bezier2Path.move(to: CGPoint(x: 57.82, y: 3))
    bezier2Path.addCurve(to: CGPoint(x: 50.32, y: 8.12), controlPoint1: CGPoint(x: 55.13, y: 4.48), controlPoint2: CGPoint(x: 52.08, y: 5.41))
    bezier2Path.addCurve(to: CGPoint(x: 43.32, y: 30.51), controlPoint1: CGPoint(x: 44.77, y: 14), controlPoint2: CGPoint(x: 41.55, y: 22.41))
    bezier2Path.addCurve(to: CGPoint(x: 47.13, y: 41.51), controlPoint1: CGPoint(x: 44.21, y: 33.41), controlPoint2: CGPoint(x: 44.8, y: 40.67))
    bezier2Path.addCurve(to: CGPoint(x: 50.71, y: 41.22), controlPoint1: CGPoint(x: 48.14, y: 40.58), controlPoint2: CGPoint(x: 50.75, y: 42.5))
    bezier2Path.addCurve(to: CGPoint(x: 50.47, y: 12.53), controlPoint1: CGPoint(x: 47, y: 33.59), controlPoint2: CGPoint(x: 45.92, y: 20.07))
    bezier2Path.addCurve(to: CGPoint(x: 52.26, y: 25.97), controlPoint1: CGPoint(x: 50.67, y: 16.79), controlPoint2: CGPoint(x: 48.21, y: 23.49))
    bezier2Path.addCurve(to: CGPoint(x: 58.68, y: 22.93), controlPoint1: CGPoint(x: 54.81, y: 26.04), controlPoint2: CGPoint(x: 56.84, y: 24.5))
    bezier2Path.addCurve(to: CGPoint(x: 66.93, y: 48.28), controlPoint1: CGPoint(x: 59.2, y: 31.95), controlPoint2: CGPoint(x: 62.62, y: 40.46))
    bezier2Path.addCurve(to: CGPoint(x: 71.99, y: 46.26), controlPoint1: CGPoint(x: 68.6, y: 47.53), controlPoint2: CGPoint(x: 70.02, y: 45.83))
    bezier2Path.addCurve(to: CGPoint(x: 84.19, y: 42.86), controlPoint1: CGPoint(x: 76.16, y: 45.88), controlPoint2: CGPoint(x: 80.9, y: 45.58))
    bezier2Path.addCurve(to: CGPoint(x: 86.72, y: 61.16), controlPoint1: CGPoint(x: 84.68, y: 49.29), controlPoint2: CGPoint(x: 87.03, y: 54.73))
    bezier2Path.addCurve(to: CGPoint(x: 77.74, y: 71.78), controlPoint1: CGPoint(x: 84.35, y: 65.2), controlPoint2: CGPoint(x: 81.54, y: 68.98))
    bezier2Path.addCurve(to: CGPoint(x: 67.93, y: 82.34), controlPoint1: CGPoint(x: 74.13, y: 74.95), controlPoint2: CGPoint(x: 71.12, y: 78.81))
    bezier2Path.addCurve(to: CGPoint(x: 53.75, y: 87.98), controlPoint1: CGPoint(x: 63.13, y: 84.01), controlPoint2: CGPoint(x: 58.08, y: 85.15))
    bezier2Path.addCurve(to: CGPoint(x: 36.47, y: 92.92), controlPoint1: CGPoint(x: 48.59, y: 91.23), controlPoint2: CGPoint(x: 42.57, y: 93.16))
    bezier2Path.addCurve(to: CGPoint(x: 28.77, y: 87.62), controlPoint1: CGPoint(x: 33.94, y: 91.85), controlPoint2: CGPoint(x: 27.03, y: 90.52))
    bezier2Path.addCurve(to: CGPoint(x: 44.7, y: 81.35), controlPoint1: CGPoint(x: 33.72, y: 84.62), controlPoint2: CGPoint(x: 39.48, y: 83.68))
    bezier2Path.addCurve(to: CGPoint(x: 47.11, y: 78.62), controlPoint1: CGPoint(x: 46.33, y: 80.92), controlPoint2: CGPoint(x: 50.84, y: 76.54))
    bezier2Path.addCurve(to: CGPoint(x: 38, y: 81.95), controlPoint1: CGPoint(x: 44.23, y: 79.76), controlPoint2: CGPoint(x: 40.06, y: 81.47))
    bezier2Path.addCurve(to: CGPoint(x: 21.33, y: 86.86), controlPoint1: CGPoint(x: 32.67, y: 84.02), controlPoint2: CGPoint(x: 27.36, y: 88.54))
    bezier2Path.addCurve(to: CGPoint(x: 16.16, y: 75.24), controlPoint1: CGPoint(x: 17.19, y: 84.99), controlPoint2: CGPoint(x: 14.06, y: 79.73))
    bezier2Path.addCurve(to: CGPoint(x: 27.11, y: 72.81), controlPoint1: CGPoint(x: 17.04, y: 69.88), controlPoint2: CGPoint(x: 23.47, y: 75.35))
    bezier2Path.addCurve(to: CGPoint(x: 41.76, y: 67.63), controlPoint1: CGPoint(x: 32.09, y: 71.36), controlPoint2: CGPoint(x: 36.68, y: 68.6))
    bezier2Path.addLine(to: CGPoint(x: 45.77, y: 64.62))
    bezier2Path.addCurve(to: CGPoint(x: 22.79, y: 69.81), controlPoint1: CGPoint(x: 37.91, y: 65.59), controlPoint2: CGPoint(x: 31.04, y: 72.28))
    bezier2Path.addCurve(to: CGPoint(x: 13.32, y: 64.62), controlPoint1: CGPoint(x: 19.65, y: 68.43), controlPoint2: CGPoint(x: 14.13, y: 68.27))
    bezier2Path.addCurve(to: CGPoint(x: 17.47, y: 59.31), controlPoint1: CGPoint(x: 13.22, y: 61.38), controlPoint2: CGPoint(x: 13.39, y: 55.16))
    bezier2Path.addCurve(to: CGPoint(x: 30.61, y: 61.44), controlPoint1: CGPoint(x: 21.43, y: 61.57), controlPoint2: CGPoint(x: 26.14, y: 63.05))
    bezier2Path.addCurve(to: CGPoint(x: 39.15, y: 56.36), controlPoint1: CGPoint(x: 33.81, y: 60.47), controlPoint2: CGPoint(x: 36.67, y: 58.59))
    bezier2Path.addCurve(to: CGPoint(x: 27.56, y: 59.07), controlPoint1: CGPoint(x: 35.51, y: 57.97), controlPoint2: CGPoint(x: 31.52, y: 59.05))
    bezier2Path.addCurve(to: CGPoint(x: 16.85, y: 53.37), controlPoint1: CGPoint(x: 24.21, y: 57.31), controlPoint2: CGPoint(x: 20.02, y: 55.91))
    bezier2Path.addCurve(to: CGPoint(x: 19.59, y: 45.45), controlPoint1: CGPoint(x: 12.32, y: 51.5), controlPoint2: CGPoint(x: 15.06, y: 40.83))
    bezier2Path.addCurve(to: CGPoint(x: 45.45, y: 43.67), controlPoint1: CGPoint(x: 28.27, y: 48.14), controlPoint2: CGPoint(x: 36.74, y: 41.07))
    bezier2Path.addLine(to: CGPoint(x: 50.37, y: 41.62))
    bezier2Path.addCurve(to: CGPoint(x: 28.23, y: 43.01), controlPoint1: CGPoint(x: 43.26, y: 37.56), controlPoint2: CGPoint(x: 35.56, y: 42.62))
    bezier2Path.addCurve(to: CGPoint(x: 15.39, y: 41.61), controlPoint1: CGPoint(x: 23.56, y: 44.18), controlPoint2: CGPoint(x: 19.73, y: 37.69))
    bezier2Path.addCurve(to: CGPoint(x: 9.78, y: 52.24), controlPoint1: CGPoint(x: 12.4, y: 44.27), controlPoint2: CGPoint(x: 9.83, y: 48.12))
    bezier2Path.addCurve(to: CGPoint(x: 10.27, y: 57.21), controlPoint1: CGPoint(x: 10.52, y: 54.88), controlPoint2: CGPoint(x: 12.52, y: 55.44))
    bezier2Path.addCurve(to: CGPoint(x: 12.09, y: 70.5), controlPoint1: CGPoint(x: 9.3, y: 61.47), controlPoint2: CGPoint(x: 5.98, y: 68.96))
    bezier2Path.addCurve(to: CGPoint(x: 13.53, y: 73.54), controlPoint1: CGPoint(x: 14.72, y: 71.34), controlPoint2: CGPoint(x: 16.69, y: 72.08))
    bezier2Path.addCurve(to: CGPoint(x: 12.14, y: 85.04), controlPoint1: CGPoint(x: 9.56, y: 75.99), controlPoint2: CGPoint(x: 9.6, y: 81.56))
    bezier2Path.addCurve(to: CGPoint(x: 21.26, y: 90.26), controlPoint1: CGPoint(x: 13.93, y: 88.32), controlPoint2: CGPoint(x: 17.33, y: 91.1))
    bezier2Path.addCurve(to: CGPoint(x: 23.09, y: 90.12), controlPoint1: CGPoint(x: 22.3, y: 90.25), controlPoint2: CGPoint(x: 25.42, y: 89.03))
    bezier2Path.addCurve(to: CGPoint(x: 33.66, y: 96.1), controlPoint1: CGPoint(x: 24.5, y: 94.15), controlPoint2: CGPoint(x: 29.83, y: 95.37))
    bezier2Path.addCurve(to: CGPoint(x: 50.25, y: 91.04), controlPoint1: CGPoint(x: 39.55, y: 96.03), controlPoint2: CGPoint(x: 45.23, y: 94.08))
    bezier2Path.addCurve(to: CGPoint(x: 63.08, y: 85.69), controlPoint1: CGPoint(x: 54.2, y: 88.46), controlPoint2: CGPoint(x: 58.74, y: 87.34))
    bezier2Path.addCurve(to: CGPoint(x: 77.96, y: 74.4), controlPoint1: CGPoint(x: 68.97, y: 83.38), controlPoint2: CGPoint(x: 74.13, y: 79.46))
    bezier2Path.addCurve(to: CGPoint(x: 90.03, y: 61), controlPoint1: CGPoint(x: 81.7, y: 69.73), controlPoint2: CGPoint(x: 87.89, y: 66.62))
    bezier2Path.addCurve(to: CGPoint(x: 90.22, y: 49.53), controlPoint1: CGPoint(x: 93.09, y: 57.89), controlPoint2: CGPoint(x: 90.52, y: 53.27))
    bezier2Path.addCurve(to: CGPoint(x: 88.06, y: 39.49), controlPoint1: CGPoint(x: 89.21, y: 46.47), controlPoint2: CGPoint(x: 89.24, y: 41.39))
    bezier2Path.addCurve(to: CGPoint(x: 80.55, y: 42.4), controlPoint1: CGPoint(x: 87.35, y: 39.79), controlPoint2: CGPoint(x: 81.8, y: 42.44))
    bezier2Path.addCurve(to: CGPoint(x: 70.1, y: 42.06), controlPoint1: CGPoint(x: 77.18, y: 43.44), controlPoint2: CGPoint(x: 73.35, y: 43.7))
    bezier2Path.addCurve(to: CGPoint(x: 65.58, y: 32.72), controlPoint1: CGPoint(x: 67.93, y: 40.65), controlPoint2: CGPoint(x: 66.87, y: 35.63))
    bezier2Path.addCurve(to: CGPoint(x: 60.21, y: 7.58), controlPoint1: CGPoint(x: 62.74, y: 24.57), controlPoint2: CGPoint(x: 63.84, y: 15.52))
    bezier2Path.addCurve(to: CGPoint(x: 57.82, y: 3), controlPoint1: CGPoint(x: 59.54, y: 5.99), controlPoint2: CGPoint(x: 58.75, y: 4.45))
    bezier2Path.addLine(to: CGPoint(x: 57.82, y: 3))
    bezier2Path.close()
    bezier2Path.move(to: CGPoint(x: 55.31, y: 9.48))
    bezier2Path.addCurve(to: CGPoint(x: 57.63, y: 22.65), controlPoint1: CGPoint(x: 56.6, y: 13.39), controlPoint2: CGPoint(x: 59.6, y: 19.52))
    bezier2Path.addCurve(to: CGPoint(x: 55.05, y: 11.72), controlPoint1: CGPoint(x: 52.66, y: 22.92), controlPoint2: CGPoint(x: 55.5, y: 15.09))
    bezier2Path.addCurve(to: CGPoint(x: 55.31, y: 9.48), controlPoint1: CGPoint(x: 55.12, y: 10.97), controlPoint2: CGPoint(x: 55.2, y: 10.23))
    bezier2Path.close()
    fillColor4.setFill()
    bezier2Path.fill()
    
    context.restoreGState()
  }
  
  public static func drawThumbsUp_2(_ size : CGSize) {
    let context = UIGraphicsGetCurrentContext()!
    
    //// Resize to Target Frame
    context.saveGState()

    // context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
    // context.translateBy(x: size.width, y: size.height)
    context.scaleBy(x: size.width / 100, y: size.height / 100)
    
    // context.translateBy(x: size.width, y: size.height)
    // context.scaleBy(x: -1, y: -1)
    
    //// Color Declarations
    let strokeColor = Color(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
    let fillColor = Color(red: 1.000, green: 0.702, blue: 0.502, alpha: 1.000)
    let fillColor2 = Color(red: 1.000, green: 0.835, blue: 0.835, alpha: 1.000)
    
    //// Group 2
    //// Group 3
    //// Bezier Drawing
    let bezierPath = BezierPath()
    bezierPath.move(to: CGPoint(x: 49.79, y: 11.46))
    bezierPath.addCurve(to: CGPoint(x: 44.09, y: 13.73), controlPoint1: CGPoint(x: 48.22, y: 12.67), controlPoint2: CGPoint(x: 45.35, y: 12.42))
    bezierPath.addCurve(to: CGPoint(x: 41.1, y: 21.29), controlPoint1: CGPoint(x: 42, y: 15.87), controlPoint2: CGPoint(x: 40.9, y: 18.67))
    bezierPath.addCurve(to: CGPoint(x: 42.11, y: 27.57), controlPoint1: CGPoint(x: 41.27, y: 23.42), controlPoint2: CGPoint(x: 40.58, y: 25.7))
    bezierPath.addCurve(to: CGPoint(x: 42.5, y: 34.57), controlPoint1: CGPoint(x: 43.75, y: 29.56), controlPoint2: CGPoint(x: 42.76, y: 32.22))
    bezierPath.addCurve(to: CGPoint(x: 43.22, y: 41.11), controlPoint1: CGPoint(x: 42.41, y: 36.74), controlPoint2: CGPoint(x: 42.54, y: 38.99))
    bezierPath.addCurve(to: CGPoint(x: 25.75, y: 44.09), controlPoint1: CGPoint(x: 36.88, y: 42.15), controlPoint2: CGPoint(x: 32.24, y: 42.75))
    bezierPath.addCurve(to: CGPoint(x: 35.76, y: 87.08), controlPoint1: CGPoint(x: 20.8, y: 57.92), controlPoint2: CGPoint(x: 19.63, y: 71.98))
    bezierPath.addLine(to: CGPoint(x: 49.24, y: 85.41))
    bezierPath.addCurve(to: CGPoint(x: 57.76, y: 85.04), controlPoint1: CGPoint(x: 49.24, y: 85.41), controlPoint2: CGPoint(x: 55.11, y: 85.67))
    bezierPath.addCurve(to: CGPoint(x: 70.79, y: 77.63), controlPoint1: CGPoint(x: 63.19, y: 83.75), controlPoint2: CGPoint(x: 70.79, y: 77.63))
    bezierPath.addCurve(to: CGPoint(x: 80.03, y: 76.69), controlPoint1: CGPoint(x: 70.79, y: 77.63), controlPoint2: CGPoint(x: 76.65, y: 77.93))
    bezierPath.addCurve(to: CGPoint(x: 80.5, y: 42.77), controlPoint1: CGPoint(x: 87.69, y: 73.88), controlPoint2: CGPoint(x: 89.47, y: 44.47))
    bezierPath.addCurve(to: CGPoint(x: 67.19, y: 40.87), controlPoint1: CGPoint(x: 76.08, y: 42.09), controlPoint2: CGPoint(x: 71.68, y: 41.25))
    bezierPath.addCurve(to: CGPoint(x: 58.1, y: 33.7), controlPoint1: CGPoint(x: 64.51, y: 39.1), controlPoint2: CGPoint(x: 62.98, y: 37.79))
    bezierPath.addCurve(to: CGPoint(x: 54.72, y: 26.78), controlPoint1: CGPoint(x: 57.32, y: 31.32), controlPoint2: CGPoint(x: 56.53, y: 29.01))
    bezierPath.addCurve(to: CGPoint(x: 49.79, y: 11.46), controlPoint1: CGPoint(x: 53.01, y: 21.69), controlPoint2: CGPoint(x: 50.4, y: 16.71))
    bezierPath.close()
    fillColor.setFill()
    bezierPath.fill()
    strokeColor.setStroke()
    bezierPath.lineWidth = 0.5
    bezierPath.miterLimit = 4
    bezierPath.stroke()
    
    
    //// Group 4
    //// Bezier 2 Drawing
    let bezier2Path = BezierPath()
    bezier2Path.move(to: CGPoint(x: 49.25, y: 11.15))
    bezier2Path.addCurve(to: CGPoint(x: 50.74, y: 21.14), controlPoint1: CGPoint(x: 48.42, y: 14.23), controlPoint2: CGPoint(x: 50.13, y: 18.41))
    bezier2Path.addCurve(to: CGPoint(x: 52.31, y: 23.27), controlPoint1: CGPoint(x: 50.78, y: 21.34), controlPoint2: CGPoint(x: 52.5, y: 23.23))
    bezier2Path.addCurve(to: CGPoint(x: 52.74, y: 20.17), controlPoint1: CGPoint(x: 52.55, y: 22.52), controlPoint2: CGPoint(x: 52.8, y: 21.23))
    bezier2Path.addCurve(to: CGPoint(x: 49.25, y: 11.15), controlPoint1: CGPoint(x: 52.16, y: 17.55), controlPoint2: CGPoint(x: 52.32, y: 10.77))
    bezier2Path.close()
    fillColor2.setFill()
    bezier2Path.fill()
    strokeColor.setStroke()
    bezier2Path.lineWidth = 0.5
    bezier2Path.miterLimit = 4
    bezier2Path.stroke()
    
    
    
    
    //// Bezier 3 Drawing
    let bezier3Path = BezierPath()
    bezier3Path.move(to: CGPoint(x: 44.63, y: 50.34))
    bezier3Path.addCurve(to: CGPoint(x: 62.86, y: 59.52), controlPoint1: CGPoint(x: 48.3, y: 56.68), controlPoint2: CGPoint(x: 53.86, y: 58.79))
    strokeColor.setStroke()
    bezier3Path.lineWidth = 0.5
    bezier3Path.miterLimit = 4
    bezier3Path.stroke()
    
    
    //// Bezier 4 Drawing
    let bezier4Path = BezierPath()
    bezier4Path.move(to: CGPoint(x: 65.47, y: 65.3))
    bezier4Path.addCurve(to: CGPoint(x: 55.48, y: 75.16), controlPoint1: CGPoint(x: 61.52, y: 67.76), controlPoint2: CGPoint(x: 55.68, y: 73.48))
    strokeColor.setStroke()
    bezier4Path.lineWidth = 0.5
    bezier4Path.miterLimit = 4
    bezier4Path.stroke()
    
    
    //// Group 5
    //// Bezier 5 Drawing
    let bezier5Path = BezierPath()
    bezier5Path.move(to: CGPoint(x: 46.82, y: 68.88))
    bezier5Path.addCurve(to: CGPoint(x: 50.75, y: 76.35), controlPoint1: CGPoint(x: 49.14, y: 70.79), controlPoint2: CGPoint(x: 53.94, y: 74.9))
    bezier5Path.addCurve(to: CGPoint(x: 34.31, y: 79.53), controlPoint1: CGPoint(x: 46.35, y: 78.37), controlPoint2: CGPoint(x: 39.91, y: 79.68))
    bezier5Path.addCurve(to: CGPoint(x: 27.05, y: 78.57), controlPoint1: CGPoint(x: 30.66, y: 79.44), controlPoint2: CGPoint(x: 27.05, y: 78.57))
    bezier5Path.move(to: CGPoint(x: 44.13, y: 59.76))
    bezier5Path.addCurve(to: CGPoint(x: 49.6, y: 67.75), controlPoint1: CGPoint(x: 45.86, y: 59.73), controlPoint2: CGPoint(x: 50.99, y: 65.71))
    bezier5Path.addCurve(to: CGPoint(x: 33.47, y: 71.38), controlPoint1: CGPoint(x: 48.8, y: 68.94), controlPoint2: CGPoint(x: 38.49, y: 71.33))
    bezier5Path.addCurve(to: CGPoint(x: 22.48, y: 68.68), controlPoint1: CGPoint(x: 29.68, y: 71.42), controlPoint2: CGPoint(x: 22.48, y: 68.68))
    bezier5Path.move(to: CGPoint(x: 26.66, y: 50.57))
    bezier5Path.addCurve(to: CGPoint(x: 29.98, y: 51.46), controlPoint1: CGPoint(x: 26.66, y: 50.57), controlPoint2: CGPoint(x: 28.84, y: 51.31))
    bezier5Path.addCurve(to: CGPoint(x: 39.14, y: 51.49), controlPoint1: CGPoint(x: 33, y: 51.86), controlPoint2: CGPoint(x: 39.14, y: 51.49))
    bezier5Path.addCurve(to: CGPoint(x: 44.86, y: 54.41), controlPoint1: CGPoint(x: 41.33, y: 51.5), controlPoint2: CGPoint(x: 43.38, y: 52.94))
    bezier5Path.addCurve(to: CGPoint(x: 47.22, y: 59.08), controlPoint1: CGPoint(x: 46.14, y: 55.67), controlPoint2: CGPoint(x: 47.22, y: 59.08))
    bezier5Path.addCurve(to: CGPoint(x: 32.36, y: 62.6), controlPoint1: CGPoint(x: 47.22, y: 59.08), controlPoint2: CGPoint(x: 37.48, y: 62.69))
    bezier5Path.addCurve(to: CGPoint(x: 21.62, y: 59.76), controlPoint1: CGPoint(x: 28.22, y: 62.52), controlPoint2: CGPoint(x: 21.62, y: 59.76))
    bezier5Path.move(to: CGPoint(x: 46.73, y: 77.41))
    bezier5Path.addCurve(to: CGPoint(x: 50.03, y: 84.94), controlPoint1: CGPoint(x: 46.73, y: 77.41), controlPoint2: CGPoint(x: 52.48, y: 83.41))
    bezier5Path.addCurve(to: CGPoint(x: 38.99, y: 87.36), controlPoint1: CGPoint(x: 47.83, y: 86.31), controlPoint2: CGPoint(x: 42.71, y: 86.69))
    bezier5Path.addCurve(to: CGPoint(x: 34.63, y: 88.15), controlPoint1: CGPoint(x: 38.99, y: 87.36), controlPoint2: CGPoint(x: 36.11, y: 88.05))
    bezier5Path.addCurve(to: CGPoint(x: 31.13, y: 87.98), controlPoint1: CGPoint(x: 33.46, y: 88.22), controlPoint2: CGPoint(x: 32.26, y: 88.23))
    bezier5Path.addCurve(to: CGPoint(x: 25.27, y: 83.14), controlPoint1: CGPoint(x: 27.8, y: 87.26), controlPoint2: CGPoint(x: 26.08, y: 86.14))
    bezier5Path.addCurve(to: CGPoint(x: 26.09, y: 79.89), controlPoint1: CGPoint(x: 24.98, y: 82.06), controlPoint2: CGPoint(x: 25.99, y: 81))
    bezier5Path.addCurve(to: CGPoint(x: 26.02, y: 78.54), controlPoint1: CGPoint(x: 26.14, y: 79.44), controlPoint2: CGPoint(x: 26.32, y: 78.9))
    bezier5Path.addCurve(to: CGPoint(x: 22.11, y: 77.53), controlPoint1: CGPoint(x: 25.17, y: 77.58), controlPoint2: CGPoint(x: 22.11, y: 77.53))
    bezier5Path.addCurve(to: CGPoint(x: 19.89, y: 74.78), controlPoint1: CGPoint(x: 20.91, y: 77.22), controlPoint2: CGPoint(x: 20.31, y: 75.85))
    bezier5Path.addCurve(to: CGPoint(x: 19.74, y: 72.09), controlPoint1: CGPoint(x: 19.56, y: 73.94), controlPoint2: CGPoint(x: 19.53, y: 72.97))
    bezier5Path.addCurve(to: CGPoint(x: 21.26, y: 69.37), controlPoint1: CGPoint(x: 19.97, y: 71.1), controlPoint2: CGPoint(x: 21.2, y: 70.39))
    bezier5Path.addCurve(to: CGPoint(x: 20.74, y: 68.13), controlPoint1: CGPoint(x: 21.29, y: 68.93), controlPoint2: CGPoint(x: 21.04, y: 68.48))
    bezier5Path.addCurve(to: CGPoint(x: 17.7, y: 66.15), controlPoint1: CGPoint(x: 19.98, y: 67.23), controlPoint2: CGPoint(x: 18.35, y: 67.12))
    bezier5Path.addCurve(to: CGPoint(x: 17.2, y: 63.2), controlPoint1: CGPoint(x: 17.13, y: 65.31), controlPoint2: CGPoint(x: 17.01, y: 64.18))
    bezier5Path.addCurve(to: CGPoint(x: 20.07, y: 58.48), controlPoint1: CGPoint(x: 17.55, y: 61.43), controlPoint2: CGPoint(x: 19.82, y: 60.27))
    bezier5Path.addCurve(to: CGPoint(x: 18.23, y: 55.06), controlPoint1: CGPoint(x: 20.27, y: 57.03), controlPoint2: CGPoint(x: 18.57, y: 56.49))
    bezier5Path.addCurve(to: CGPoint(x: 17.93, y: 49.68), controlPoint1: CGPoint(x: 17.86, y: 53.55), controlPoint2: CGPoint(x: 17.68, y: 51.21))
    bezier5Path.addCurve(to: CGPoint(x: 19.83, y: 46.28), controlPoint1: CGPoint(x: 18.13, y: 48.42), controlPoint2: CGPoint(x: 18.83, y: 47.16))
    bezier5Path.addCurve(to: CGPoint(x: 25.45, y: 43.85), controlPoint1: CGPoint(x: 21.32, y: 44.96), controlPoint2: CGPoint(x: 25.45, y: 43.85))
    bezier5Path.addLine(to: CGPoint(x: 31.49, y: 43.04))
    fillColor.setFill()
    bezier5Path.fill()
    strokeColor.setStroke()
    bezier5Path.lineWidth = 0.5
    bezier5Path.miterLimit = 4
    bezier5Path.stroke()
    
    
    //// Bezier 6 Drawing
    let bezier6Path = BezierPath()
    bezier6Path.move(to: CGPoint(x: 41.08, y: 56.64))
    bezier6Path.addCurve(to: CGPoint(x: 38.03, y: 61.22), controlPoint1: CGPoint(x: 40.05, y: 56.97), controlPoint2: CGPoint(x: 36.02, y: 60.59))
    bezier6Path.addCurve(to: CGPoint(x: 47.33, y: 58.92), controlPoint1: CGPoint(x: 39.71, y: 61.74), controlPoint2: CGPoint(x: 47.13, y: 59.82))
    bezier6Path.addCurve(to: CGPoint(x: 41.08, y: 56.64), controlPoint1: CGPoint(x: 47.69, y: 57.29), controlPoint2: CGPoint(x: 43.79, y: 55.1))
    bezier6Path.close()
    fillColor2.setFill()
    bezier6Path.fill()
    strokeColor.setStroke()
    bezier6Path.lineWidth = 0.5
    bezier6Path.miterLimit = 4
    bezier6Path.stroke()
    
    
    //// Bezier 7 Drawing
    let bezier7Path = BezierPath()
    bezier7Path.move(to: CGPoint(x: 43.35, y: 66.01))
    bezier7Path.addCurve(to: CGPoint(x: 40.78, y: 70.45), controlPoint1: CGPoint(x: 42.41, y: 66.38), controlPoint2: CGPoint(x: 38.86, y: 69.97))
    bezier7Path.addCurve(to: CGPoint(x: 50.03, y: 67.79), controlPoint1: CGPoint(x: 42.38, y: 70.86), controlPoint2: CGPoint(x: 49.51, y: 68.5))
    bezier7Path.addCurve(to: CGPoint(x: 43.35, y: 66.01), controlPoint1: CGPoint(x: 50.83, y: 66.69), controlPoint2: CGPoint(x: 45.79, y: 64.44))
    bezier7Path.close()
    fillColor2.setFill()
    bezier7Path.fill()
    strokeColor.setStroke()
    bezier7Path.lineWidth = 0.5
    bezier7Path.miterLimit = 4
    bezier7Path.stroke()
    
    
    //// Bezier 8 Drawing
    let bezier8Path = BezierPath()
    bezier8Path.move(to: CGPoint(x: 45.43, y: 74.77))
    bezier8Path.addCurve(to: CGPoint(x: 43.4, y: 78.78), controlPoint1: CGPoint(x: 44.56, y: 75.18), controlPoint2: CGPoint(x: 41.51, y: 78.58))
    bezier8Path.addCurve(to: CGPoint(x: 52.04, y: 75.51), controlPoint1: CGPoint(x: 44.99, y: 78.94), controlPoint2: CGPoint(x: 51.61, y: 76.17))
    bezier8Path.addCurve(to: CGPoint(x: 45.43, y: 74.77), controlPoint1: CGPoint(x: 52.69, y: 74.5), controlPoint2: CGPoint(x: 47.62, y: 73.17))
    bezier8Path.close()
    fillColor2.setFill()
    bezier8Path.fill()
    strokeColor.setStroke()
    bezier8Path.lineWidth = 0.5
    bezier8Path.miterLimit = 4
    bezier8Path.stroke()
    
    
    //// Bezier 9 Drawing
    let bezier9Path = BezierPath()
    bezier9Path.move(to: CGPoint(x: 44.68, y: 82.68))
    bezier9Path.addCurve(to: CGPoint(x: 42.01, y: 86.68), controlPoint1: CGPoint(x: 43.78, y: 82.97), controlPoint2: CGPoint(x: 40.25, y: 86.13))
    bezier9Path.addCurve(to: CGPoint(x: 50.79, y: 84.67), controlPoint1: CGPoint(x: 43.48, y: 87.14), controlPoint2: CGPoint(x: 50.26, y: 85.31))
    bezier9Path.addCurve(to: CGPoint(x: 44.68, y: 82.68), controlPoint1: CGPoint(x: 51.6, y: 83.69), controlPoint2: CGPoint(x: 47.05, y: 81.34))
    bezier9Path.close()
    fillColor2.setFill()
    bezier9Path.fill()
    strokeColor.setStroke()
    bezier9Path.lineWidth = 0.5
    bezier9Path.miterLimit = 4
    bezier9Path.stroke()
    
    context.restoreGState()

  }

  public static func drawThumbsUp_3(_ size : CGSize) {
    let context = UIGraphicsGetCurrentContext()!
    
    //// Resize to Target Frame
    context.saveGState()
    // context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
    context.scaleBy(x: size.width / 100, y: size.height / 100)
    
    
    //// Color Declarations
    let strokeColor = Color(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
    
    //// noun_1084878_cc.svg Group
    //// Group 2
    //// Bezier Drawing
    let bezierPath = BezierPath()
    bezierPath.move(to: CGPoint(x: 13.8, y: 47.51))
    bezierPath.addCurve(to: CGPoint(x: 13.11, y: 55.82), controlPoint1: CGPoint(x: 13.53, y: 50.09), controlPoint2: CGPoint(x: 13.26, y: 52.68))
    bezierPath.addCurve(to: CGPoint(x: 13.15, y: 66.35), controlPoint1: CGPoint(x: 12.97, y: 58.96), controlPoint2: CGPoint(x: 12.95, y: 62.65))
    bezierPath.addCurve(to: CGPoint(x: 14.46, y: 77.34), controlPoint1: CGPoint(x: 13.36, y: 70.05), controlPoint2: CGPoint(x: 13.8, y: 73.76))
    bezierPath.addCurve(to: CGPoint(x: 16.76, y: 86.79), controlPoint1: CGPoint(x: 15.13, y: 80.92), controlPoint2: CGPoint(x: 16.04, y: 84.37))
    bezierPath.addCurve(to: CGPoint(x: 18.57, y: 91.98), controlPoint1: CGPoint(x: 17.48, y: 89.21), controlPoint2: CGPoint(x: 18.03, y: 90.6))
    strokeColor.setStroke()
    bezierPath.lineWidth = 1
    bezierPath.miterLimit = 4
    bezierPath.lineCapStyle = .round
    bezierPath.lineJoinStyle = .round
    bezierPath.stroke()
    
    
    //// Bezier 2 Drawing
    let bezier2Path = BezierPath()
    bezier2Path.move(to: CGPoint(x: 18.57, y: 91.98))
    bezier2Path.addCurve(to: CGPoint(x: 25.82, y: 91.16), controlPoint1: CGPoint(x: 21.01, y: 91.67), controlPoint2: CGPoint(x: 23.46, y: 91.35))
    bezier2Path.addCurve(to: CGPoint(x: 32.96, y: 91.02), controlPoint1: CGPoint(x: 28.18, y: 90.98), controlPoint2: CGPoint(x: 30.46, y: 90.93))
    bezier2Path.addCurve(to: CGPoint(x: 40.83, y: 91.8), controlPoint1: CGPoint(x: 35.46, y: 91.11), controlPoint2: CGPoint(x: 38.19, y: 91.36))
    bezier2Path.addCurve(to: CGPoint(x: 48.34, y: 93.38), controlPoint1: CGPoint(x: 43.46, y: 92.24), controlPoint2: CGPoint(x: 46.01, y: 92.88))
    bezier2Path.addCurve(to: CGPoint(x: 55.28, y: 94.53), controlPoint1: CGPoint(x: 50.67, y: 93.88), controlPoint2: CGPoint(x: 52.79, y: 94.23))
    bezier2Path.addCurve(to: CGPoint(x: 63.61, y: 94.98), controlPoint1: CGPoint(x: 57.77, y: 94.83), controlPoint2: CGPoint(x: 60.64, y: 95.07))
    bezier2Path.addCurve(to: CGPoint(x: 71.55, y: 94.12), controlPoint1: CGPoint(x: 66.57, y: 94.88), controlPoint2: CGPoint(x: 69.63, y: 94.45))
    bezier2Path.addCurve(to: CGPoint(x: 75.03, y: 92.74), controlPoint1: CGPoint(x: 73.46, y: 93.78), controlPoint2: CGPoint(x: 74.23, y: 93.53))
    bezier2Path.addCurve(to: CGPoint(x: 77.08, y: 89.33), controlPoint1: CGPoint(x: 75.82, y: 91.95), controlPoint2: CGPoint(x: 76.65, y: 90.62))
    bezier2Path.addCurve(to: CGPoint(x: 77.32, y: 85.86), controlPoint1: CGPoint(x: 77.52, y: 88.05), controlPoint2: CGPoint(x: 77.58, y: 86.82))
    bezier2Path.addCurve(to: CGPoint(x: 75.91, y: 83.48), controlPoint1: CGPoint(x: 77.06, y: 84.89), controlPoint2: CGPoint(x: 76.49, y: 84.18))
    strokeColor.setStroke()
    bezier2Path.lineWidth = 1
    bezier2Path.miterLimit = 4
    bezier2Path.lineCapStyle = .round
    bezier2Path.lineJoinStyle = .round
    bezier2Path.stroke()
    
    
    //// Bezier 3 Drawing
    let bezier3Path = BezierPath()
    bezier3Path.move(to: CGPoint(x: 75.91, y: 83.48))
    bezier3Path.addCurve(to: CGPoint(x: 79.45, y: 82.59), controlPoint1: CGPoint(x: 77.14, y: 83.25), controlPoint2: CGPoint(x: 78.36, y: 83.02))
    bezier3Path.addCurve(to: CGPoint(x: 82.19, y: 80.71), controlPoint1: CGPoint(x: 80.53, y: 82.15), controlPoint2: CGPoint(x: 81.47, y: 81.5))
    bezier3Path.addCurve(to: CGPoint(x: 83.69, y: 77.83), controlPoint1: CGPoint(x: 82.91, y: 79.92), controlPoint2: CGPoint(x: 83.41, y: 78.98))
    bezier3Path.addCurve(to: CGPoint(x: 83.86, y: 74.28), controlPoint1: CGPoint(x: 83.97, y: 76.68), controlPoint2: CGPoint(x: 84.04, y: 75.31))
    bezier3Path.addCurve(to: CGPoint(x: 82.75, y: 71.91), controlPoint1: CGPoint(x: 83.68, y: 73.25), controlPoint2: CGPoint(x: 83.26, y: 72.55))
    bezier3Path.addCurve(to: CGPoint(x: 81.09, y: 70.14), controlPoint1: CGPoint(x: 82.25, y: 71.28), controlPoint2: CGPoint(x: 81.67, y: 70.71))
    strokeColor.setStroke()
    bezier3Path.lineWidth = 1
    bezier3Path.miterLimit = 4
    bezier3Path.lineCapStyle = .round
    bezier3Path.lineJoinStyle = .round
    bezier3Path.stroke()
    
    
    //// Bezier 4 Drawing
    let bezier4Path = BezierPath()
    bezier4Path.move(to: CGPoint(x: 81.09, y: 70.14))
    bezier4Path.addCurve(to: CGPoint(x: 84.22, y: 68.21), controlPoint1: CGPoint(x: 82.18, y: 69.5), controlPoint2: CGPoint(x: 83.28, y: 68.86))
    bezier4Path.addCurve(to: CGPoint(x: 86.52, y: 66.04), controlPoint1: CGPoint(x: 85.16, y: 67.56), controlPoint2: CGPoint(x: 85.95, y: 66.91))
    bezier4Path.addCurve(to: CGPoint(x: 87.56, y: 63.14), controlPoint1: CGPoint(x: 87.09, y: 65.17), controlPoint2: CGPoint(x: 87.45, y: 64.09))
    bezier4Path.addCurve(to: CGPoint(x: 87.3, y: 60.6), controlPoint1: CGPoint(x: 87.68, y: 62.19), controlPoint2: CGPoint(x: 87.57, y: 61.36))
    bezier4Path.addCurve(to: CGPoint(x: 85.89, y: 58.36), controlPoint1: CGPoint(x: 87.03, y: 59.84), controlPoint2: CGPoint(x: 86.61, y: 59.14))
    bezier4Path.addCurve(to: CGPoint(x: 83.48, y: 56.22), controlPoint1: CGPoint(x: 85.17, y: 57.58), controlPoint2: CGPoint(x: 84.14, y: 56.72))
    bezier4Path.addCurve(to: CGPoint(x: 82.23, y: 55.42), controlPoint1: CGPoint(x: 82.82, y: 55.71), controlPoint2: CGPoint(x: 82.53, y: 55.56))
    strokeColor.setStroke()
    bezier4Path.lineWidth = 1
    bezier4Path.miterLimit = 4
    bezier4Path.lineCapStyle = .round
    bezier4Path.lineJoinStyle = .round
    bezier4Path.stroke()
    
    
    //// Bezier 5 Drawing
    let bezier5Path = BezierPath()
    bezier5Path.move(to: CGPoint(x: 82.23, y: 55.42))
    bezier5Path.addCurve(to: CGPoint(x: 84.92, y: 53.06), controlPoint1: CGPoint(x: 83.18, y: 54.63), controlPoint2: CGPoint(x: 84.13, y: 53.85))
    bezier5Path.addCurve(to: CGPoint(x: 86.71, y: 50.46), controlPoint1: CGPoint(x: 85.72, y: 52.27), controlPoint2: CGPoint(x: 86.36, y: 51.47))
    bezier5Path.addCurve(to: CGPoint(x: 87.02, y: 47.19), controlPoint1: CGPoint(x: 87.06, y: 49.45), controlPoint2: CGPoint(x: 87.12, y: 48.22))
    bezier5Path.addCurve(to: CGPoint(x: 86.22, y: 44.63), controlPoint1: CGPoint(x: 86.91, y: 46.16), controlPoint2: CGPoint(x: 86.65, y: 45.33))
    bezier5Path.addCurve(to: CGPoint(x: 84.49, y: 42.79), controlPoint1: CGPoint(x: 85.8, y: 43.93), controlPoint2: CGPoint(x: 85.22, y: 43.36))
    bezier5Path.addCurve(to: CGPoint(x: 82.05, y: 41.26), controlPoint1: CGPoint(x: 83.76, y: 42.21), controlPoint2: CGPoint(x: 82.87, y: 41.63))
    bezier5Path.addCurve(to: CGPoint(x: 78.9, y: 40.53), controlPoint1: CGPoint(x: 81.24, y: 40.89), controlPoint2: CGPoint(x: 80.48, y: 40.72))
    bezier5Path.addCurve(to: CGPoint(x: 72.01, y: 40.06), controlPoint1: CGPoint(x: 77.31, y: 40.33), controlPoint2: CGPoint(x: 74.89, y: 40.1))
    bezier5Path.addCurve(to: CGPoint(x: 63.57, y: 40.22), controlPoint1: CGPoint(x: 69.13, y: 40.02), controlPoint2: CGPoint(x: 65.78, y: 40.17))
    bezier5Path.addCurve(to: CGPoint(x: 59.25, y: 40.2), controlPoint1: CGPoint(x: 61.37, y: 40.28), controlPoint2: CGPoint(x: 60.31, y: 40.24))
    strokeColor.setStroke()
    bezier5Path.lineWidth = 1
    bezier5Path.miterLimit = 4
    bezier5Path.lineCapStyle = .round
    bezier5Path.lineJoinStyle = .round
    bezier5Path.stroke()
    
    
    //// Bezier 6 Drawing
    let bezier6Path = BezierPath()
    bezier6Path.move(to: CGPoint(x: 13.8, y: 47.51))
    bezier6Path.addCurve(to: CGPoint(x: 18.07, y: 47.19), controlPoint1: CGPoint(x: 15.17, y: 47.42), controlPoint2: CGPoint(x: 16.54, y: 47.34))
    bezier6Path.addCurve(to: CGPoint(x: 22.67, y: 46.27), controlPoint1: CGPoint(x: 19.59, y: 47.04), controlPoint2: CGPoint(x: 21.28, y: 46.83))
    bezier6Path.addCurve(to: CGPoint(x: 26.29, y: 43.54), controlPoint1: CGPoint(x: 24.06, y: 45.71), controlPoint2: CGPoint(x: 25.17, y: 44.79))
    bezier6Path.addCurve(to: CGPoint(x: 29.59, y: 39.35), controlPoint1: CGPoint(x: 27.41, y: 42.28), controlPoint2: CGPoint(x: 28.55, y: 40.68))
    bezier6Path.addCurve(to: CGPoint(x: 33.11, y: 35.59), controlPoint1: CGPoint(x: 30.64, y: 38.02), controlPoint2: CGPoint(x: 31.6, y: 36.97))
    bezier6Path.addCurve(to: CGPoint(x: 39.03, y: 30.68), controlPoint1: CGPoint(x: 34.62, y: 34.21), controlPoint2: CGPoint(x: 36.67, y: 32.51))
    bezier6Path.addCurve(to: CGPoint(x: 46.05, y: 25.21), controlPoint1: CGPoint(x: 41.4, y: 28.86), controlPoint2: CGPoint(x: 44.07, y: 26.91))
    bezier6Path.addCurve(to: CGPoint(x: 50.28, y: 20.79), controlPoint1: CGPoint(x: 48.02, y: 23.5), controlPoint2: CGPoint(x: 49.31, y: 22.05))
    bezier6Path.addCurve(to: CGPoint(x: 52.42, y: 17.11), controlPoint1: CGPoint(x: 51.25, y: 19.52), controlPoint2: CGPoint(x: 51.9, y: 18.45))
    bezier6Path.addCurve(to: CGPoint(x: 53.46, y: 12.84), controlPoint1: CGPoint(x: 52.94, y: 15.76), controlPoint2: CGPoint(x: 53.32, y: 14.13))
    bezier6Path.addCurve(to: CGPoint(x: 53.6, y: 9.84), controlPoint1: CGPoint(x: 53.59, y: 11.55), controlPoint2: CGPoint(x: 53.49, y: 10.59))
    bezier6Path.addCurve(to: CGPoint(x: 54.59, y: 8.03), controlPoint1: CGPoint(x: 53.71, y: 9.09), controlPoint2: CGPoint(x: 54.04, y: 8.56))
    bezier6Path.addCurve(to: CGPoint(x: 56.86, y: 6.68), controlPoint1: CGPoint(x: 55.15, y: 7.5), controlPoint2: CGPoint(x: 55.93, y: 6.98))
    bezier6Path.addCurve(to: CGPoint(x: 59.99, y: 6.25), controlPoint1: CGPoint(x: 57.78, y: 6.37), controlPoint2: CGPoint(x: 58.85, y: 6.28))
    bezier6Path.addCurve(to: CGPoint(x: 63.39, y: 6.58), controlPoint1: CGPoint(x: 61.13, y: 6.23), controlPoint2: CGPoint(x: 62.34, y: 6.27))
    bezier6Path.addCurve(to: CGPoint(x: 66.2, y: 8.26), controlPoint1: CGPoint(x: 64.44, y: 6.9), controlPoint2: CGPoint(x: 65.32, y: 7.47))
    bezier6Path.addCurve(to: CGPoint(x: 68.64, y: 11.36), controlPoint1: CGPoint(x: 67.07, y: 9.05), controlPoint2: CGPoint(x: 67.94, y: 10.03))
    bezier6Path.addCurve(to: CGPoint(x: 70.17, y: 15.86), controlPoint1: CGPoint(x: 69.33, y: 12.69), controlPoint2: CGPoint(x: 69.86, y: 14.35))
    bezier6Path.addCurve(to: CGPoint(x: 70.41, y: 20.45), controlPoint1: CGPoint(x: 70.48, y: 17.38), controlPoint2: CGPoint(x: 70.57, y: 18.75))
    bezier6Path.addCurve(to: CGPoint(x: 69.17, y: 26.08), controlPoint1: CGPoint(x: 70.26, y: 22.15), controlPoint2: CGPoint(x: 69.86, y: 24.19))
    bezier6Path.addCurve(to: CGPoint(x: 66.18, y: 31.43), controlPoint1: CGPoint(x: 68.47, y: 27.97), controlPoint2: CGPoint(x: 67.48, y: 29.71))
    bezier6Path.addCurve(to: CGPoint(x: 62.08, y: 36.34), controlPoint1: CGPoint(x: 64.89, y: 33.16), controlPoint2: CGPoint(x: 63.29, y: 34.88))
    bezier6Path.addCurve(to: CGPoint(x: 59.25, y: 40.2), controlPoint1: CGPoint(x: 60.88, y: 37.8), controlPoint2: CGPoint(x: 60.06, y: 39))
    strokeColor.setStroke()
    bezier6Path.lineWidth = 1
    bezier6Path.miterLimit = 4
    bezier6Path.lineCapStyle = .round
    bezier6Path.lineJoinStyle = .round
    bezier6Path.stroke()
    
    
    //// Bezier 7 Drawing
    let bezier7Path = BezierPath()
    bezier7Path.move(to: CGPoint(x: 53.53, y: 11.34))
    bezier7Path.addCurve(to: CGPoint(x: 56.21, y: 12.79), controlPoint1: CGPoint(x: 54.48, y: 11.65), controlPoint2: CGPoint(x: 55.42, y: 11.96))
    bezier7Path.addCurve(to: CGPoint(x: 57.7, y: 16.58), controlPoint1: CGPoint(x: 57, y: 13.62), controlPoint2: CGPoint(x: 57.63, y: 14.96))
    bezier7Path.addCurve(to: CGPoint(x: 56.44, y: 21.5), controlPoint1: CGPoint(x: 57.76, y: 18.19), controlPoint2: CGPoint(x: 57.27, y: 20.08))
    bezier7Path.addCurve(to: CGPoint(x: 53.31, y: 24.31), controlPoint1: CGPoint(x: 55.61, y: 22.92), controlPoint2: CGPoint(x: 54.44, y: 23.87))
    bezier7Path.addCurve(to: CGPoint(x: 50.26, y: 24.36), controlPoint1: CGPoint(x: 52.19, y: 24.74), controlPoint2: CGPoint(x: 51.09, y: 24.65))
    bezier7Path.addCurve(to: CGPoint(x: 48.29, y: 23.09), controlPoint1: CGPoint(x: 49.42, y: 24.07), controlPoint2: CGPoint(x: 48.86, y: 23.58))
    strokeColor.setStroke()
    bezier7Path.lineWidth = 1
    bezier7Path.miterLimit = 4
    bezier7Path.lineCapStyle = .round
    bezier7Path.lineJoinStyle = .round
    bezier7Path.stroke()
    
    context.restoreGState()

  }
  
  public static func draw_swift(_ size : CGSize) {
    //// General Declarations
    let context = UIGraphicsGetCurrentContext()!
    
    //// Color Declarations
    let gradientColor = Color(red: 0.973, green: 0.541, blue: 0.212, alpha: 1.000)
    let gradientColor2 = Color(red: 0.992, green: 0.125, blue: 0.125, alpha: 1.000)
    
    //// Gradient Declarations
    let a = CGGradient(colorsSpace: nil, colors: [gradientColor.cgColor, gradientColor2.cgColor] as CFArray, locations: [0, 1])!
    
    //// Bezier Drawing
    let bezierPath = BezierPath()
    bezierPath.move(to: CGPoint(x: 29.88, y: 33.05))
    bezierPath.addCurve(to: CGPoint(x: 12.35, y: 33.25), controlPoint1: CGPoint(x: 25.22, y: 35.74), controlPoint2: CGPoint(x: 18.8, y: 36.02))
    bezierPath.addCurve(to: CGPoint(x: 0, y: 22.69), controlPoint1: CGPoint(x: 7.12, y: 31.03), controlPoint2: CGPoint(x: 2.78, y: 27.14))
    bezierPath.addCurve(to: CGPoint(x: 4.56, y: 25.47), controlPoint1: CGPoint(x: 1.33, y: 23.8), controlPoint2: CGPoint(x: 2.89, y: 24.69))
    bezierPath.addCurve(to: CGPoint(x: 22.58, y: 25.48), controlPoint1: CGPoint(x: 11.23, y: 28.59), controlPoint2: CGPoint(x: 17.89, y: 28.38))
    bezierPath.addCurve(to: CGPoint(x: 22.58, y: 25.47), controlPoint1: CGPoint(x: 22.58, y: 25.47), controlPoint2: CGPoint(x: 22.58, y: 25.47))
    bezierPath.addCurve(to: CGPoint(x: 6.01, y: 8.23), controlPoint1: CGPoint(x: 15.9, y: 20.35), controlPoint2: CGPoint(x: 10.23, y: 13.68))
    bezierPath.addCurve(to: CGPoint(x: 3.78, y: 5.23), controlPoint1: CGPoint(x: 5.12, y: 7.34), controlPoint2: CGPoint(x: 4.45, y: 6.23))
    bezierPath.addCurve(to: CGPoint(x: 19.91, y: 17.46), controlPoint1: CGPoint(x: 8.9, y: 9.9), controlPoint2: CGPoint(x: 17.02, y: 15.79))
    bezierPath.addCurve(to: CGPoint(x: 8.56, y: 3.23), controlPoint1: CGPoint(x: 13.79, y: 11.01), controlPoint2: CGPoint(x: 8.34, y: 3))
    bezierPath.addCurve(to: CGPoint(x: 27.25, y: 18.57), controlPoint1: CGPoint(x: 18.24, y: 13.01), controlPoint2: CGPoint(x: 27.25, y: 18.57))
    bezierPath.addCurve(to: CGPoint(x: 27.96, y: 19.01), controlPoint1: CGPoint(x: 27.55, y: 18.74), controlPoint2: CGPoint(x: 27.78, y: 18.88))
    bezierPath.addCurve(to: CGPoint(x: 28.47, y: 17.46), controlPoint1: CGPoint(x: 28.16, y: 18.51), controlPoint2: CGPoint(x: 28.33, y: 18))
    bezierPath.addCurve(to: CGPoint(x: 24.36, y: 0), controlPoint1: CGPoint(x: 30.03, y: 11.79), controlPoint2: CGPoint(x: 28.25, y: 5.34))
    bezierPath.addCurve(to: CGPoint(x: 36.48, y: 24.25), controlPoint1: CGPoint(x: 33.36, y: 5.45), controlPoint2: CGPoint(x: 38.7, y: 15.68))
    bezierPath.addCurve(to: CGPoint(x: 36.29, y: 24.93), controlPoint1: CGPoint(x: 36.42, y: 24.48), controlPoint2: CGPoint(x: 36.36, y: 24.7))
    bezierPath.addCurve(to: CGPoint(x: 36.37, y: 25.02), controlPoint1: CGPoint(x: 36.32, y: 24.96), controlPoint2: CGPoint(x: 36.34, y: 24.99))
    bezierPath.addCurve(to: CGPoint(x: 39.04, y: 35.37), controlPoint1: CGPoint(x: 40.82, y: 30.59), controlPoint2: CGPoint(x: 39.59, y: 36.48))
    bezierPath.addCurve(to: CGPoint(x: 29.88, y: 33.05), controlPoint1: CGPoint(x: 36.62, y: 30.65), controlPoint2: CGPoint(x: 32.16, y: 32.09))
    bezierPath.close()
    context.saveGState()
    bezierPath.addClip()
    context.drawLinearGradient(a,
                               start: CGPoint(x: 19.81, y: 0),
                               end: CGPoint(x: 19.81, y: 35.5),
                               options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    context.restoreGState()
  }
  
  public static func draw_refresh(_ size : CGSize) {
    let context = UIGraphicsGetCurrentContext()!
    
    //// Resize to Target Frame
    context.saveGState()
    // context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
    context.scaleBy(x: size.width / 100, y: size.height / 100)
    

    //// Color Declarations
    let fillColor = Color(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
    
    //// reset.svg Group
    //// Bezier 2 Drawing
    let bezier2Path = BezierPath()
    bezier2Path.move(to: CGPoint(x: 90.09, y: 31.21))
    bezier2Path.addCurve(to: CGPoint(x: 86.49, y: 29.29), controlPoint1: CGPoint(x: 89.12, y: 30.21), controlPoint2: CGPoint(x: 88.01, y: 29.29))
    bezier2Path.addCurve(to: CGPoint(x: 79.68, y: 34.16), controlPoint1: CGPoint(x: 84.46, y: 29.29), controlPoint2: CGPoint(x: 82.96, y: 30.82))
    bezier2Path.addCurve(to: CGPoint(x: 77.59, y: 36.28), controlPoint1: CGPoint(x: 79.07, y: 34.79), controlPoint2: CGPoint(x: 78.37, y: 35.5))
    bezier2Path.addCurve(to: CGPoint(x: 67.82, y: 10.21), controlPoint1: CGPoint(x: 76.91, y: 24.67), controlPoint2: CGPoint(x: 73.69, y: 16.11))
    bezier2Path.addCurve(to: CGPoint(x: 44.44, y: 1.71), controlPoint1: CGPoint(x: 62.21, y: 4.57), controlPoint2: CGPoint(x: 54.34, y: 1.71))
    bezier2Path.addCurve(to: CGPoint(x: 12.4, y: 35.3), controlPoint1: CGPoint(x: 23.63, y: 1.71), controlPoint2: CGPoint(x: 12.4, y: 19.01))
    bezier2Path.addCurve(to: CGPoint(x: 45.74, y: 68.29), controlPoint1: CGPoint(x: 12.4, y: 51.19), controlPoint2: CGPoint(x: 22.84, y: 68.29))
    bezier2Path.addCurve(to: CGPoint(x: 51.24, y: 62.79), controlPoint1: CGPoint(x: 48.78, y: 68.29), controlPoint2: CGPoint(x: 51.24, y: 65.83))
    bezier2Path.addCurve(to: CGPoint(x: 45.74, y: 57.29), controlPoint1: CGPoint(x: 51.24, y: 59.75), controlPoint2: CGPoint(x: 48.78, y: 57.29))
    bezier2Path.addCurve(to: CGPoint(x: 23.4, y: 35.3), controlPoint1: CGPoint(x: 29.25, y: 57.29), controlPoint2: CGPoint(x: 23.4, y: 45.44))
    bezier2Path.addCurve(to: CGPoint(x: 28.87, y: 19.56), controlPoint1: CGPoint(x: 23.4, y: 29.39), controlPoint2: CGPoint(x: 25.4, y: 23.66))
    bezier2Path.addCurve(to: CGPoint(x: 44.44, y: 12.71), controlPoint1: CGPoint(x: 32.66, y: 15.08), controlPoint2: CGPoint(x: 38.05, y: 12.71))
    bezier2Path.addCurve(to: CGPoint(x: 60.02, y: 17.97), controlPoint1: CGPoint(x: 51.4, y: 12.71), controlPoint2: CGPoint(x: 56.5, y: 14.43))
    bezier2Path.addCurve(to: CGPoint(x: 66.54, y: 36.05), controlPoint1: CGPoint(x: 63.74, y: 21.71), controlPoint2: CGPoint(x: 65.93, y: 27.78))
    bezier2Path.addCurve(to: CGPoint(x: 64.69, y: 34.16), controlPoint1: CGPoint(x: 65.86, y: 35.36), controlPoint2: CGPoint(x: 65.24, y: 34.73))
    bezier2Path.addCurve(to: CGPoint(x: 57.98, y: 29.38), controlPoint1: CGPoint(x: 61.48, y: 30.88), controlPoint2: CGPoint(x: 60.02, y: 29.38))
    bezier2Path.addCurve(to: CGPoint(x: 54.44, y: 31.17), controlPoint1: CGPoint(x: 56.5, y: 29.38), controlPoint2: CGPoint(x: 55.36, y: 30.28))
    bezier2Path.addCurve(to: CGPoint(x: 60.02, y: 44.33), controlPoint1: CGPoint(x: 50.82, y: 34.67), controlPoint2: CGPoint(x: 53.7, y: 37.69))
    bezier2Path.addLine(to: CGPoint(x: 61.63, y: 46.02))
    bezier2Path.addCurve(to: CGPoint(x: 69.97, y: 53.64), controlPoint1: CGPoint(x: 65.51, y: 50.11), controlPoint2: CGPoint(x: 67.86, y: 52.59))
    bezier2Path.addCurve(to: CGPoint(x: 72.19, y: 54.24), controlPoint1: CGPoint(x: 70.67, y: 54.04), controlPoint2: CGPoint(x: 71.41, y: 54.24))
    bezier2Path.addLine(to: CGPoint(x: 72.2, y: 54.24))
    bezier2Path.addLine(to: CGPoint(x: 72.3, y: 54.24))
    bezier2Path.addLine(to: CGPoint(x: 72.3, y: 54.24))
    bezier2Path.addCurve(to: CGPoint(x: 74.52, y: 53.64), controlPoint1: CGPoint(x: 73.07, y: 54.24), controlPoint2: CGPoint(x: 73.82, y: 54.04))
    bezier2Path.addCurve(to: CGPoint(x: 82.83, y: 46.04), controlPoint1: CGPoint(x: 76.62, y: 52.59), controlPoint2: CGPoint(x: 78.97, y: 50.12))
    bezier2Path.addLine(to: CGPoint(x: 84.46, y: 44.34))
    bezier2Path.addCurve(to: CGPoint(x: 90.09, y: 31.21), controlPoint1: CGPoint(x: 90.72, y: 37.77), controlPoint2: CGPoint(x: 93.58, y: 34.77))
    bezier2Path.close()
    fillColor.setFill()
    bezier2Path.fill()
    
    context.restoreGState()

  }
  
  public static func draw_reset(_ size : CGSize) {
    let context = UIGraphicsGetCurrentContext()!
    
    //// Resize to Target Frame
    context.saveGState()

  //// Color Declarations
  let fillColor = Color(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
  let strokeColor = Color(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
  
  //// refresh.svg Group
  //// Bezier Drawing
  let bezierPath = BezierPath()
  bezierPath.move(to: CGPoint(x: 24.14, y: 21.36))
  bezierPath.addCurve(to: CGPoint(x: 17, y: 24), controlPoint1: CGPoint(x: 22.22, y: 23.01), controlPoint2: CGPoint(x: 19.73, y: 24))
  bezierPath.addCurve(to: CGPoint(x: 6, y: 13), controlPoint1: CGPoint(x: 10.93, y: 24), controlPoint2: CGPoint(x: 6, y: 19.07))
  strokeColor.setStroke()
  bezierPath.lineWidth = 2
  bezierPath.lineCapStyle = .round
  bezierPath.stroke()
  
  
  //// Bezier 2 Drawing
  let bezier2Path = BezierPath()
  bezier2Path.move(to: CGPoint(x: 9.86, y: 4.64))
  bezier2Path.addCurve(to: CGPoint(x: 17, y: 2), controlPoint1: CGPoint(x: 11.78, y: 2.99), controlPoint2: CGPoint(x: 14.27, y: 2))
  bezier2Path.addCurve(to: CGPoint(x: 28, y: 13), controlPoint1: CGPoint(x: 23.07, y: 2), controlPoint2: CGPoint(x: 28, y: 6.93))
  strokeColor.setStroke()
  bezier2Path.lineWidth = 2
  bezier2Path.lineCapStyle = .round
  bezier2Path.stroke()
  
  
  //// Bezier 3 Drawing
  let bezier3Path = BezierPath()
  bezier3Path.move(to: CGPoint(x: 28, y: 18))
  bezier3Path.addLine(to: CGPoint(x: 24, y: 12))
  bezier3Path.addLine(to: CGPoint(x: 32, y: 12))
  bezier3Path.addLine(to: CGPoint(x: 28, y: 18))
  bezier3Path.close()
  fillColor.setFill()
  bezier3Path.fill()
  
  
  //// Bezier 4 Drawing
  let bezier4Path = BezierPath()
  bezier4Path.move(to: CGPoint(x: 6, y: 8))
  bezier4Path.addLine(to: CGPoint(x: 10, y: 14))
  bezier4Path.addLine(to: CGPoint(x: 2, y: 14))
  bezier4Path.addLine(to: CGPoint(x: 6, y: 8))
  bezier4Path.close()
  fillColor.setFill()
  bezier4Path.fill()

    context.restoreGState()

  }
}
