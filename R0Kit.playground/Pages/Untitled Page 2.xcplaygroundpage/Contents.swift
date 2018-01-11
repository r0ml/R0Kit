//: [Previous](@previous)

import PlaygroundSupport
import R0Kit

// NSScreen.main.backingScaleFactor

let z = TagFieldController()

z.tags = ["one", "two", "three"]
z.setup()
z.view.setFrameSize(CGSize( width: 600, height: 50))
z.view.backgroundColor = Color.systemPink

// PlaygroundPage.current.liveView = z

