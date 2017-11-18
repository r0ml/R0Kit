//: [Previous](@previous)

import Foundation
@testable import R0Kit

var str = "Hello, playground"

//: [Next](@next)

var a = "abcd".data(using: .utf8)?.md5()


// [Int].decode(from: "1 2 3 4".data(using: .utf8))


// StrandDecoder().decode([Int].self, from: "1 2 3 4"

 let x = try [Int](from: StrandDecoder())
