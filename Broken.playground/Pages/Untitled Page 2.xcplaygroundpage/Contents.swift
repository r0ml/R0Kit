//: [Previous](@previous)

import AppKit

var str = "Hello, playground"

NSScreen.main?.backingScaleFactor

NSScreen.screens.map { print($0.backingScaleFactor) }

NSScreen.screens
