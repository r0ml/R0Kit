// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import CoreGraphics

extension CGPoint {

    public static func *(left: CGPoint, right: CGPoint) -> CGPoint {
      return CGPoint(x: left.x * right.x, y: left.y * right.y)
    }

    public static func *(left: CGPoint, right: CGSize) -> CGPoint {
      return CGPoint(x: left.x * right.width, y: left.y * right.height)
    }

    public var flipped : CGPoint {
      return CGPoint(x: self.y, y: self.x)
    }

    public static func -(left: CGPoint, right: CGPoint) -> CGPoint {
      return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    public static func +(left: CGPoint, right: CGPoint) -> CGPoint {
      return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    public static func *(left: CGPoint, right: CGFloat) -> CGPoint {
      return CGPoint(x: left.x * right, y: left.y * right)
    }

    public init(_ z : CGFloat) {
      self.init(x: z, y: z)
    }


  public func distance(to: CGPoint) -> CGFloat {
    let j = self.x - to.x
    let k = self.y - to.y
    return CGFloat(sqrt( j*j + k * k))
  }

  // tests if a I am Left|On|Right of an infinite line.
  public func isLeft(_ p0 : CGPoint, _ p1 : CGPoint) -> CGFloat {
    //    Input:  three points P0, P1, and P2
    //    Return: >0 for P2 left of the line through P0 and P1
    //            =0 for P2  on the line
    //            <0 for P2  right of the line
    //    See: Algorithm 1 "Area of Triangles and Polygons"
    return (p1.x - p0.x) * (self.y - p0.y) - (self.x -  p0.x) * (p1.y - p0.y)
  }

  // wn_PnPoly(): winding number test for a point in a polygon
  //      Input:   P = a point,
  //               V[] = vertex points of a polygon V[n+1] with V[n]=V[0]
  //      Return:  wn = the winding number (=0 only when P is outside)

  public func contained( in vv : [CGPoint] ) -> Bool {
    var wn : Int = 0    // the  winding number counter
    let v = vv + [vv[0]]
    let eps = CGFloat(1e-10)

    // loop through all edges of the polygon
    for i in 0..<vv.count {   // edge from V[i] to  V[i+1]
      if (v[i].y <= self.y) {          // start y <= P.y
        if (v[i+1].y  > self.y) {      // an upward crossing
          if isLeft( v[i], v[i+1]) > eps  { // P left of  edge
            wn += 1            // have  a valid up intersect
          }
        }
      }
      else {                        // start y > P.y (no test needed)
        if (v[i+1].y  <= self.y) {    // a downward crossing
          if isLeft( v[i], v[i+1]) < -eps {  // P right of  edge
            wn -= 1            // have  a valid down intersect
          }
        }
      }
    }
    return wn != 0;
  }

}

