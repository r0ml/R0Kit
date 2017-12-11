//: A UIKit based Playground for presenting user interface
  
import R0Kit
import PlaygroundSupport

class MyView : View {
  
  override public func draw(_ r : CGRect) {
    Icon.drawThumbsUp_3(r.size)
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

let vv = MyView(frame: CGRect(x:0, y:0, width: 100, height: 100))
 vv.backgroundColor = Color.orange

PlaygroundPage.current.liveView =  vv // MyViewController()
