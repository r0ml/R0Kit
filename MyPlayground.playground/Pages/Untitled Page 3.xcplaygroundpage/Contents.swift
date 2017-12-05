//: [Previous](@previous)

import Foundation
import R0Kit

var str = "Hello, playground"

//: [Next](@next)

/*IconView(.downArrow, frame: CGRect(x:0, y:0, width:540, height: 540))

IconView(.upArrow, frame: CGRect(x:0, y:0, width:540, height: 540))


IconView(.cloud, frame: CGRect(x:0, y:0, width: 580, height: 580))

IconView(.downloadCloud, frame: CGRect(x:0, y:0, width: 600, height: 600))

IconView(.uploadCloud, frame: CGRect(x:0, y:0, width: 600, height: 600))
*/

sqrt(5)

let fr = CGRect(origin: CGPoint.zero, size: CGSize(width: 40, height: 40))
let imv : IconView = IconView.init(IconType.downArrow, frame : fr ) { _ in } 
makeImage(CGSize(width: 40, height: 40)) { (imv.drawArrow(CGRect(origin: CGPoint.zero, size: $0), false)) }
