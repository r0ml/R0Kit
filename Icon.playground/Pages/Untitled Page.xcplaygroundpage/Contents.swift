//: A UIKit based Playground for presenting user interface
  
import R0Kit
import PlaygroundSupport

class MyView : View {
  
  override public func draw(_ r : CGRect) {
    
    
    if let context = UIGraphicsGetCurrentContext() {
    
      // let aa = NSScreen.main?.backingScaleFactor ?? 1
     // let aa = CGFloat(4)
      // context.scaleBy(x: aa * r.size.width / 100, y: aa * r.size.height / 100)

      Icon.drawCloud(r, lineWidth: 3, lineColor: Color.green, fillColor: Color.blue )
  }
  }

}

let z = "clean"

/*
class MyViewController : ViewController {
    override func loadView() {
      self.view = MyView(frame: CGRect(x:0, y:0, width: 100, height: 100))
      self.view.backgroundColor = Color.green
    }
}
*/


// Present the view controller in the Live View window

let vv = MyView(frame: CGRect(x:0, y:0, width: 500, height: 500))
  vv.backgroundColor = Color.orange

PlaygroundPage.current.liveView =  vv // MyViewController()
