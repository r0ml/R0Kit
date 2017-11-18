//
//  R0KitTests.swift
//  R0KitTests
//
//  Created by Robert M. Lefkowitz on 11/17/17.
//  Copyright © 2017 Semasiology. All rights reserved.
//

import XCTest
@testable import R0Kit

class Testing : Decodable, Encodable {
  var one : Int
  var two : String
  init() {one = 12; two = "maybe"}
}
class R0KitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
      let t = Testing()
      t.one = 33
      t.two = "blessed"
      let z = RecordEncoder("Clem", "nam", CKRecordZone(zoneName: "Warby").zoneID)
      do { try [t].encode(to: z)
      } catch { print(error) }
      print(z)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
